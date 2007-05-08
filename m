From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 8 May 2007 16:40:01 +0200
Message-ID: <20070508144001.GC387@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m31whs5ehn.fsf_-_@maximus.localdomain> <20070508113232.GA32055@xi.wantstofly.org> <m3k5vj76bi.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:50208 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967391AbXEHOkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 10:40:04 -0400
Content-Disposition: inline
In-Reply-To: <m3k5vj76bi.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 04:12:17PM +0200, Krzysztof Halasa wrote:

> > The queue manager interrupts should probably be implemented as an
> > irqchip, in the same way that GPIO interrupts are implemented.  (I.e.
> > allocate 'real' interrupt numbers for them, and use the interrupt
> > cascade mechanism.)  You probably want to have separate irqchips for
> > the upper and lower halves, too.  This way, drivers can just use
> > request_irq() instead of having to bother with platform-specific
> > qmgr_set_irq() methods.
> 
> Is there a sample somewhere?

See for example arch/arm/mach-ep93xx/core.c, handling of the A/B/F
port GPIO interrupts.

In a nutshell, it goes like this.

1) Allocate a set of IRQ numbers.  E.g. in include/asm-arm/arch-ixp4xx/irqs.h:

	#define IRQ_IXP4XX_QUEUE_0	64
	#define IRQ_IXP4XX_QUEUE_1	65
	[...]

   Adjust NR_IRQS, too.

2) Implement interrupt chip functions:

	static void ixp4xx_queue_low_irq_mask_ack(unsigned int irq)
	{
		[...]
	}

	static void ixp4xx_queue_low_irq_mask(unsigned int irq)
	{
		[...]
	}

	static void ixp4xx_queue_low_irq_unmask(unsigned int irq)
	{
		[...]
	}

	static void ixp4xx_queue_low_irq_set_type(unsigned int irq)
	{
		[...]
	}

	static struct irq_chip ixp4xx_queue_low_irq_chip = {
		.name		= "QMGR low",
		.ack		= ixp4xx_queue_low_irq_mask_ack,
		.mask		= ixp4xx_queue_low_irq_mask,
		.unmask		= ixp4xx_queue_low_irq_unmask,
		.set_type	= ixp4xx_queue_low_irq_set_type,
	};

3) Hook up the queue interrupts:

	for (i = IRQ_IXP4XX_QUEUE_0; i <= IRQ_IXP4XX_QUEUE_31; i++) {
		set_irq_chip(i, &ixp4xx_queue_low_irq_chip);
		set_irq_handler(i, handle_level_irq);
		set_irq_flags(i, IRQF_VALID);
	}

4) Implement an interrupt handler for the parent interrupt:

	static void ixp4xx_qmgr_low_irq_handler(unsigned int irq, struct irq_des c *desc)
	{
		u32 status;
		int i;

		status = __raw_readl(IXP4XX_WHATEVER_QMGR_LOW_STATUS_REGISTER);
		for (i = 0; i < 32; i++) {
			if (status & (1 << i)) {
				desc = irq_desc + IRQ_IXP4XX_QUEUE_0 + i;
				desc_handle_irq(IRQ_IXP4XX_QUEUE_0 + i, desc);
			}
		}
	}

5) Hook up the parent interrupt:

	set_irq_chained_handler(IRQ_IXP4XX_QM1, ixp4xx_qmgr_low_irq_handler);


Or something like that.


> > As with Christian's driver, I don't know whether an SRAM allocator
> > makes much sense.  We can just set up a static allocation map for the
> > in-tree drivers and leave out the allocator altogether.  I.e. I don't
> > think it's worth the complexity (and just because the butt-ugly Intel
> > code has an allocator isn't a very good reason. :-)
> 
> It's a very simple allocator. I don't whink we have enough SRAM
> without it. For now it would work but it's probably too small
> for all potential users at a time.
> 
> There may be up to 6 Ethernet ports (not sure about hardware
> status, not yet supported even by Intel) - 7 queues * 128 entries
> each = ~ 3.5 KB. Add 2 long queues (RX) for HSS and something
> for TX, and then crypto, and maybe other things.

You're unlikely to be using all of those at the same time, though.

And what do you do if the user does compile all of these features into
his kernel and then tries to use them all at the same time?  Return
-ENOMEM?

Shouldn't we make sure that at least the features that are compiled in
can be used at the same time?  If you want that guarantee, then you
might as well determine the SRAM map at compile time.
