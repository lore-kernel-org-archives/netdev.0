From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Thu, 19 Jun 2008 17:53:12 -0500
Message-ID: <1213915992.9245.71.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <48584CAD.6010509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:33295 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbYFSWzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 18:55:13 -0400
In-Reply-To: <48584CAD.6010509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 16:45 -0700, Ben Greear wrote:
> Travis Stratman wrote:
> > On Tue, 2008-06-17 at 15:31 -0700, Ben Greear wrote:
> >> Travis Stratman wrote:
> >>> I am working on an application that uses a fairly simple UDP protocol to
> >>> send data between two embedded devices. I'm noticing an issue with an
> >>> initial test that was written where datagrams are received but not seen
> >>> by the recvfrom() call until more data arrives after it. As of right now
> >>> the test case does not implement any type of lost packet protection or
> >>> other flow control, which is what makes the issue so noticeable.
> >> UDP packets can be lost anywhere..including in the receive buffer
> >> after it has been received by the NIC.
> >>
> >> You probably just need to write your code smarter to use non-blocking
> >> IO and deal with packet loss.
> > 
> > Thanks Ben.
> > 
> > I understand that there is no guarantee of anything with UDP, but it
> > seems to me that if there is a packet in the buffer (it shows up after
> > another packet comes in behind it) the system should know about it,
> > right?
> 
> Ahh, I see what you mean.
> 
> I'm afraid I don't know anything about your NIC driver, and it would
> seem to be implicated.

I agree, but it also troubles me that the x86 board that I noticed the
same issue on uses the realtek (8139too) driver, so I'm not completely
convinced that the issue is at the NIC level.

I was able to do some more extensive testing today with the macb (atmel
Eternet MAC controller) driver and noticed that the
netif_rx_schedule_prep function is returning false at times in the
interrupt handler. In the code below, the printk shows up during heavy
traffic, though it only happens a handful of times. (The else block is
code that I have added to the driver while debugging).

if (status & MACB_RX_INT_FLAGS) {
    if (netif_rx_schedule_prep(dev)) {
    /*
     * There's no point taking any more interrupts
     * until we have processed the buffers
     */
        macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
        dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
        __netif_rx_schedule(dev);
    } else {
        printk(KERN_ERR "%s: Driver bug: interrupt while in polling mode\n", dev->name);
        /* disable interrupts */
        macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
    }
}

>From what I can tell of this function, it should only return false if
polling is already enabled for the interface (though I haven't looked
much deeper than the inline for netif_rx_schedule_prep()).

I went through the poll function, and actually rewrote the whole thing
according to the guidelines in the NAPI documentation, and I can't see
anyway for it to get out of poll with interrupts enabled without first
removing itself from the polling list.

Can someone who knows more about this give me some more insight into
what might be happening here? I can post the poll function or a patch to
macb.c if it would be helpful.

Thanks,

Travis


> 
> Thanks,
> Ben
> 

