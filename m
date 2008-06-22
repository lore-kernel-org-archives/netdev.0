From: James Chapman <jchapman@katalix.com>
Subject: Re: data received but not detected
Date: Sun, 22 Jun 2008 10:16:14 +0100
Message-ID: <485E185E.1090807@katalix.com>
References: <1213740538.5771.192.camel@localhost.localdomain>	 <48583B37.5070708@candelatech.com>	 <1213743506.5771.220.camel@localhost.localdomain>	 <48584CAD.6010509@candelatech.com> <1213915992.9245.71.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33061 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbYFVJQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2008 05:16:20 -0400
In-Reply-To: <1213915992.9245.71.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Travis Stratman wrote:
> I was able to do some more extensive testing today with the macb (atmel
> Eternet MAC controller) driver and noticed that the
> netif_rx_schedule_prep function is returning false at times in the
> interrupt handler. In the code below, the printk shows up during heavy
> traffic, though it only happens a handful of times. (The else block is
> code that I have added to the driver while debugging).
> 
> if (status & MACB_RX_INT_FLAGS) {
>     if (netif_rx_schedule_prep(dev)) {
>     /*
>      * There's no point taking any more interrupts
>      * until we have processed the buffers
>      */
>         macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
>         dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
>         __netif_rx_schedule(dev);
>     } else {
>         printk(KERN_ERR "%s: Driver bug: interrupt while in polling mode\n", dev->name);
>         /* disable interrupts */
>         macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
>     }
> }
> 
>>From what I can tell of this function, it should only return false if
> polling is already enabled for the interface (though I haven't looked
> much deeper than the inline for netif_rx_schedule_prep()).
> 
> I went through the poll function, and actually rewrote the whole thing
> according to the guidelines in the NAPI documentation, and I can't see
> anyway for it to get out of poll with interrupts enabled without first
> removing itself from the polling list.
> 
> Can someone who knows more about this give me some more insight into
> what might be happening here? I can post the poll function or a patch to
> macb.c if it would be helpful.

I looked at macb.c and can see that it uses napi only for rx work, 
leaving tx interrupts enabled at all times. The interrupt handler reads 
the device interrupt status when a tx interrupt happens and may find rx 
bits also set. As a result, your netif_rx_schedule_prep() will sometimes 
return false because napi might be already scheduled. The code you have 
above (i.e. the "driver bug" case) is wrong.

The napi code in the in-tree version looks suspect because it seems to 
enable rx interrupts unconditionally regardless of whether napi rx 
processing is complete.

It might help to post a patch here showing all of your changes.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

