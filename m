From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "usb: dwc3: gadget: use allocated/queued reqs
 for LST bit"
Date: Mon, 31 Oct 2016 14:51:50 -0400 (EDT)
Message-ID: <20161031.145150.1409050078488736200.davem@davemloft.net>
References: <20161027154016.GD4617@intel.com>
        <87pomksrrm.fsf@linux.intel.com>
        <20161028163332.GL4617@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: felipe.balbi@linux.intel.com, linux-usb@vger.kernel.org,
        stable@vger.kernel.org, oneukum@suse.com, netdev@vger.kernel.org
To: ville.syrjala@linux.intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20161028163332.GL4617@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Syrjälä <ville.syrjala@linux.intel.com>
Date: Fri, 28 Oct 2016 19:33:32 +0300

> On Fri, Oct 28, 2016 at 01:16:13PM +0300, Felipe Balbi wrote:
>> Yeah, I'm guessing we're gonna need some help from networking folks. The
>> only thing we did since v4.7 was actually respect req->no_interrupt flag
>> coming from u_ether itself. No idea why that causes so much trouble for
>> u_ether.
>> 
>> BTW, Instead of reverting so many patches, you can just remove
>> throttling:
>> 
>> diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/function/u_ether.c
>> index f4a640216913..119a2e5848e8 100644
>> --- a/drivers/usb/gadget/function/u_ether.c
>> +++ b/drivers/usb/gadget/function/u_ether.c
>> @@ -589,14 +589,6 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
>>  
>>         req->length = length;
>>  
>> -       /* throttle high/super speed IRQ rate back slightly */
>> -       if (gadget_is_dualspeed(dev->gadget))
>> -               req->no_interrupt = (((dev->gadget->speed == USB_SPEED_HIGH ||
>> -                                      dev->gadget->speed == USB_SPEED_SUPER)) &&
>> -                                       !list_empty(&dev->tx_reqs))
>> -                       ? ((atomic_read(&dev->tx_qlen) % dev->qmult) != 0)
>> -                       : 0;
>> -
>>         retval = usb_ep_queue(in, req, GFP_ATOMIC);
>>         switch (retval) {
>>         default:
> 
> Ah cool. That indeed fixes the problem for me.
> 
>> 
>> I'm adding netdev and couple other folks to the loop.
>> 
>> Just to summarize, USB peripheral controller now actually throttles
>> interrupt when requested to do so and that causes lags for USB
>> networking gadgets.
>> 
>> Without throttle we, potentially, call netif_wake_queue() more
>> frequently than with throttling. I'm wondering if something changed in
>> NET layer within the past few years but the USB networking gadgets ended
>> up being forgotten.
>> 
>> Anyway, if anybody has any hints, I'd be glad to hear about them.

This throttling mechanism seems to have the same problem we've seen in
the past with some ethernet drivers trying to do TX mitigation in
software.

If I understand correctly, the interrupt bit for TX completions is set
only periodically.

However, the networking stack has a hard requirement that all SKBs
which are transmitted must have their completion signalled in a finite
amount of time.  This is because, until the SKB is freed by the
driver, it holds onto socket, netfilter, and other subsystem
resources.

So, for example, if your scheme is that only every 8th TX packet will
generate an interrupt you run into problems if you suddenly have 7
pending TX packets and no more traffic is generated for a long time.

Those 7 packets will sit in the TX queue indefinitely, and this is the
situation which drivers must avoid.

Therefore, for devices with per-TX-queue-entry interrupt bit schemes,
it's not easy to take advantage of this facility.  The safest thing to
do is to interrupt for every queue entry.

For the time being, this revert is the way to go and it should be
submitted formally, with proper commit message and signoffs, via
whatever tree this gadget driver's changes should be submitted via.

It might be possible to elide TX queue entry interrupts using the
skb->xmit_more state.  Basically, if the TX queue is not full and
skb->xmit_more is set, you can skip the interrupt indication bit
in the descriptor.

Thanks.
