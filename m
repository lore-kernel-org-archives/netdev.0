From: Pavel Machek <pavel@ucw.cz>
Subject: Re: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 22:48:54 +0200
Message-ID: <20130709204854.GA21438@amd.pavel.ucw.cz>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
 <D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
 <20130709170242.GA14112@amd.pavel.ucw.cz>
 <1373390146.4286.1.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:48703 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab3GIUs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 16:48:56 -0400
Content-Disposition: inline
In-Reply-To: <1373390146.4286.1.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue 2013-07-09 17:15:48, Waskiewicz Jr, Peter P wrote:
> On Tue, 2013-07-09 at 19:02 +0200, Pavel Machek wrote:
> > Hi!
> > 
> > > Nothing appears to be wrong.  If the system is seeing ping packets
> > >at all means that device is generating interrupts and that they are
> > >being processed.  If you are looking at performance then sharing
> > 
> > No, that's not true. There is other interrupt load, and e1000e has big
> > enough buffers; that means that packets eventually get processed. I
> > strongly suspect e1000e generates little or no interrupts and packets
> > only get processed when other devices on shared interrupt line
> > generate interrupt. 
> 
> If the interrupt is shared, e1000e checks if it's the hardware that
> generated it before processing packets.  Consuming an interrupt that
> isn't meant for this device will throw major warnings in the kernel
> about bad interrupt routing, etc.  Here's the code from the interrupt
> handler (note the last part of the pasted code):

Yeah, of course you need to ask e1000e if it generated the
interrupt. That part works. The part that actually generates the
interrupt does not. Take a look at original mail...

packet comes
e1000e sets E1000_ICR_INT_ASSERTED bit
e1000e tries to generate an interrupt and fails
50msec passes
AHCI generates interrupt
all the handlers are called
    AHCI processes its interrupt, handles disk read
    e1000_intr notices E1000_ICR_INT_ASSERTED bit, delivers the packet.

Network still works, only slowly. Ping goes lower when I use the
disk. That matches what I see.

Do you have other explanation?
									Pavel

> /**
>  * e1000_intr - Interrupt Handler
>  * @irq: interrupt number
>  * @data: pointer to a network interface device structure
>  **/
> static irqreturn_t e1000_intr(int __always_unused irq, void *data)
> {
>         struct net_device *netdev = data;
>         struct e1000_adapter *adapter = netdev_priv(netdev);
>         struct e1000_hw *hw = &adapter->hw;
>         u32 rctl, icr = er32(ICR);
> 
>         if (!icr || test_bit(__E1000_DOWN, &adapter->state))
>                 return IRQ_NONE;  /* Not our interrupt */
> 
>         /* IMS will not auto-mask if INT_ASSERTED is not set, and if it
> is
>          * not set, then the adapter didn't send an interrupt
>          */
>         if (!(icr & E1000_ICR_INT_ASSERTED))
>                 return IRQ_NONE;
> 
> Cheers,
> -PJ

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
