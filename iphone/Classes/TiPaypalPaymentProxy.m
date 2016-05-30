/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiPaypalPaymentProxy.h"
#import "TiPaypalPaymentItemProxy.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation TiPaypalPaymentProxy

-(void)dealloc
{
    RELEASE_TO_NIL(payment);
    RELEASE_TO_NIL(paymentDialog);
    RELEASE_TO_NIL(configuration);
    
    [super dealloc];
}

-(PayPalPayment *)payment
{
    if (payment == nil) {
        payment = [PayPalPayment new];
    }
    
    return payment;
}

-(PayPalPaymentViewController*)paymentDialog
{
    if (paymentDialog == nil) {
        paymentDialog = [[PayPalPaymentViewController alloc] initWithPayment:[self payment]
                                                               configuration:[configuration configuration]
                                                                    delegate:self];
    }
    
    return paymentDialog;
}

-(void)show:(id)args
{
    id animated = [args valueForKey:@"animated"];
    ENSURE_TYPE_OR_NIL(animated, NSNumber);
    
    if (![[self payment] processable]) {
        NSLog(@"[ERROR] Ti.PayPal: Payment is not processable, dialog aborted!");
        return;
    }

    [[[[TiApp app] controller] topPresentedController] presentViewController:[self paymentDialog]
                                                                    animated:[TiUtils boolValue:animated def:YES]
                                                                  completion:nil];
}

-(void)setConfiguration:(id)value
{
    ENSURE_TYPE(value, TiPaypalConfigurationProxy);
    configuration = value;
}

-(void)setItems:(id)value
{
    ENSURE_TYPE(value, NSArray);
    NSMutableArray *result = [NSMutableArray new];
    
    for (id item in (NSArray*)value) {
        ENSURE_TYPE(item, TiPaypalPaymentItemProxy);
        TiPaypalPaymentItemProxy *proxy = (TiPaypalPaymentItemProxy*)item;
        [result addObject:[proxy item]];
    }

   [[self payment] setItems:result];
    RELEASE_TO_NIL(result);
}

-(void)setCurrencyCode:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self payment] setCurrencyCode:[TiUtils stringValue:value]];
}

-(void)setAmount:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [[self payment] setAmount:[NSDecimalNumber decimalNumberWithDecimal:[[TiUtils numberFromObject:value] decimalValue]]];
}

-(void)setShortDescription:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self payment] setShortDescription:[TiUtils stringValue:value]];
}

-(void)setIntent:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [[self payment] setIntent:[TiUtils intValue:value def:PayPalPaymentIntentSale]];
}

#pragma mark - Delegates

#pragma mark Simple payments

-(void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    if ([self _hasListeners:@"paymentDidCancel"]) {
        [self fireEvent:@"paymentDidCancel"];
    }
    
    [[self paymentDialog] dismissViewControllerAnimated:YES completion:nil];
    RELEASE_TO_NIL(paymentDialog);
}

-(void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController willCompletePayment:(PayPalPayment *)completedPayment completionBlock:(PayPalPaymentDelegateCompletionBlock)completionBlock
{
    if ([self _hasListeners:@"paymentWillComplete"]) {
        [self fireEvent:@"paymentWillComplete"];
    }
    completionBlock();
}

-(void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment
{
    if ([self _hasListeners:@"paymentDidComplete"]) {
        [self fireEvent:@"paymentDidComplete"];
    }
    [[self paymentDialog] dismissViewControllerAnimated:YES completion:nil];
    RELEASE_TO_NIL(paymentDialog);
}

@end
