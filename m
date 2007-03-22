From: Bernhard Walle <bwalle@suse.de>
Subject: Re: [PATCH] Fix crash in tg3 when using irqpoll
Date: Fri, 23 Mar 2007 00:20:48 +0100
Message-ID: <20070322232048.GC3333@sykes.suse.de>
References: <20070322204635.GA27152@strauss.suse.de> <1174601067.9753.42.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:38227 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933389AbXCVXUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 19:20:54 -0400
Content-Disposition: inline
In-Reply-To: <1174601067.9753.42.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

* Michael Chan <mchan@broadcom.com> [2007-03-22 23:04]:
> On Thu, 2007-03-22 at 21:46 +0100, Bernhard Walle wrote:
> 
> > This patch makes sure that even the tr32() instruction in the interrupt handler
> > is not executed which accesses PCI memory. Accessing PCI memory when
> > pci_restore_state() is called is a bad idea because that function modifies
> > the BARs of the PCI device.
> 
> It is not caused by the BAR as it doesn't get changed in this case.  The
> pci_restore_state() call is to restore the memory enable bit in the PCI
> command register.  The tr32() call in tg3_interrupt() will cause a
> master abort if it is called before the memory enable bit has been
> restored.

Ok, thanks for the explanation. I wondered why you call
pci_restore_state() here, normally that's only called from .resume
handlers.

> > --- mainline-msi-init.orig/drivers/net/tg3.c
> > +++ mainline-msi-init/drivers/net/tg3.c
> > @@ -3561,7 +3561,10 @@ static irqreturn_t tg3_interrupt(int irq
> >  	struct net_device *dev = dev_id;
> >  	struct tg3 *tp = netdev_priv(dev);
> >  	struct tg3_hw_status *sblk = tp->hw_status;
> > -	unsigned int handled = 1;
> > +	unsigned int handled = 0;
> > +
> > +	if (tg3_irq_sync(tp))
> > +		goto out;
> 
> 
> This will break other things.  When we disable interrupts, we set the
> irq_sync flag but allow one more interrupt to be generated.  The irq
> handler will simply mask off the interrupt when it sees the irq_sync
> flag.  With the above change, the irq handler can no longer mask off
> this trailing interrupt and you may get screaming interrupts as a
> result.

You're right, I had only the case in mind where the network device
doesn't generate any interrupts (in initialisation phase and in
shutdown phase) because it's disabled in the device, and the interrupt
handler is only called because of IRQ-sharing/irqpoll.

> Thanks for reporting this.  I'll try to come up with a good solution.

Could you please CC me, I'd like to test it here.


Thanks,
   Bernhard
