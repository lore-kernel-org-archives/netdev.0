From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Sat, 10 Mar 2007 23:25:05 +0300
Message-ID: <45F31421.4010908@ru.mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:50780 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932201AbXCJUZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 15:25:16 -0500
In-Reply-To: <45ECE9AC.3090804@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Mark Huth wrote:

>>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>>  static void natsemi_poll_controller(struct net_device *dev)
>>>  {
>>> +     struct netdev_private *np = netdev_priv(dev);
>>> +
>>>       disable_irq(dev->irq);
>>> -     intr_handler(dev->irq, dev);
>>> +
>>> +     /*
>>> +      * A real interrupt might have already reached us at this point
>>> +      * but NAPI might still haven't called us back.  As the
>>> interrupt
>>> +      * status register is cleared by reading, we should prevent an
>>> +      * interrupt loss in this case...
>>> +      */
>>> +     if (!np->intr_status)
>>> +             intr_handler(dev->irq, dev);
>>> +
>>>       enable_irq(dev->irq);

    Oops, I was going to recast the patch but my attention switched elsewhere 
for couple of days, and it "slipped" into mainline. I'm now preparing a better 
patch to also protect...

>> Is it possible for this to run at the same time as the NAPI poll?  If so
>> then it is possible for the netpoll poll to run between np->intr_status
>> being cleared and netif_rx_complete() being called.  If the hardware
>> asserts an interrupt at the wrong moment then this could cause the

> Well, there is a whole task of analyzing the netpoll conditions under 
> smp.  There appears to me to be a race with netpoll and NAPI on another 
> processor, given that netpoll can be called with virtually any system 
> condition on a debug breakpoint or crash dump initiation.  I'm spending 
> some time looking into it, but don't have a smoking gun immediately.  
> Regardless, if such a condition does exist, it is shared across many or 
> all of the potential netpolled devices.  Since that is exactly the 
> condition  the suggested patch purports to solve, it is pointless if the 
> whole NAPI/netpoll race exists.  Such a race would lead to various and 
> imaginative failures in the system.  So don't fix that problem in a 
> particular driver.  If it exists, fix it generally in the netpoll/NAPI 
> infrastructure.

    Any takers? :-)

>> In any case, this is a problem independently of netpoll if the chip
>> shares an interrupt with anything so the interrupt handler should be
>> fixed to cope with this situation instead.

> Yes, that would appear so.  If an interrupt line is shared with this 
> device, then the interrupt handler can be called again, even though the 
> device's interrupts are disabled on the interface.  So, in the actual 
> interrupt handler, check the dev->state __LINK_STATE_SCHED flag - if 
> it's set, leave immediately, it can't be our interrupt. If it's clear, 
> read the irq enable hardware register.  If enabled, do the rest of the 
> interrupt handler.

    It seems that there's no need to read it, as it gets set to 0 
"synchronously" with setting the 'hands_off' flag (except in NAPI callback)...

> Since the isr is disabled only by the interrupt 
> handler, and enabled only by the poll routine, the race on the interrupt 
> cause register is prevented.  And, as a byproduct, the netpoll race is 
> also prevented.  You could just always read the isr enable hardware 
> register, but that means you always do an operation to the chip, which 
> can be painfully slow.

    Yeah, it seems currently unjustified.  However IntrEnable would have been 
an ultimate criterion on taking or ignoring an interrupt otherwise...

> I guess the tradeoff depends on the probability 
> of getting the isr called when NAPI is active for the device.

    Didn't get it... :-/

> If this results in netpoll not getting a packet right away, that's okay, 
> since the netpoll users should try again.

    Well, in certain stuations (like KGDBoE), netpoll callback being called 
*while* NAPI callback is being executed would mean a deadlock, I think (as 
NAPI callback will never complete)...
    BTW, it seems I've found another interrupt lossage path in the driver:

netdev_poll() -> netdev_rx() -> reset_rx()

If the netdev_rx() detects an oversized packet, it will call reset_rx() which 
will spin in a loop "collecting" interrupt status until it sees RxResetDone 
there.  The issue is 'intr_status' field will get overwritten and interrupt 
status lost after netdev_rx() returns to netdev_poll().  How do you think, is 
this corner case worth fixing (by moving netdev_rx() call to the top of a 
do/while loop)?

> Mark Huth

WBR, Sergei
