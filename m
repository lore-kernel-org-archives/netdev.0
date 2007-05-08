From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 8 May 2007 13:32:32 +0200
Message-ID: <20070508113232.GA32055@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m31whs5ehn.fsf_-_@maximus.localdomain>
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
Received: from alephnull.demon.nl ([83.160.184.112]:49919 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934544AbXEHLch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 07:32:37 -0400
Content-Disposition: inline
In-Reply-To: <m31whs5ehn.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure what the latest versions are, so I'm not sure which
patches to review and which patches are obsolete.


On Tue, May 08, 2007 at 02:46:28AM +0200, Krzysztof Halasa wrote:

> +struct qmgr_regs __iomem *qmgr_regs;
> +static struct resource *mem_res;
> +static spinlock_t qmgr_lock;
> +static u32 used_sram_bitmap[4]; /* 128 16-dword pages */
> +static void (*irq_handlers[HALF_QUEUES])(void *pdev);
> +static void *irq_pdevs[HALF_QUEUES];
> +
> +void qmgr_set_irq(unsigned int queue, int src,
> +		  void (*handler)(void *pdev), void *pdev)
> +{
> +	u32 __iomem *reg = &qmgr_regs->irqsrc[queue / 8]; /* 8 queues / u32 */
> +	int bit = (queue % 8) * 4; /* 3 bits + 1 reserved bit per queue */
> +	unsigned long flags;
> +
> +	src &= 7;
> +	spin_lock_irqsave(&qmgr_lock, flags);
> +	__raw_writel((__raw_readl(reg) & ~(7 << bit)) | (src << bit), reg);
> +	irq_handlers[queue] = handler;
> +	irq_pdevs[queue] = pdev;
> +	spin_unlock_irqrestore(&qmgr_lock, flags);
> +}

The queue manager interrupts should probably be implemented as an
irqchip, in the same way that GPIO interrupts are implemented.  (I.e.
allocate 'real' interrupt numbers for them, and use the interrupt
cascade mechanism.)  You probably want to have separate irqchips for
the upper and lower halves, too.  This way, drivers can just use
request_irq() instead of having to bother with platform-specific
qmgr_set_irq() methods.  I think I also made this review comment
with Christian's driver.


> +int qmgr_request_queue(unsigned int queue, unsigned int len /* dwords */,
> +		       unsigned int nearly_empty_watermark,
> +		       unsigned int nearly_full_watermark)
> +{
> +	u32 cfg, addr = 0, mask[4]; /* in 16-dwords */
> +	int err;
> +
> +	if (queue >= HALF_QUEUES)
> +		return -ERANGE;
> +
> +	if ((nearly_empty_watermark | nearly_full_watermark) & ~7)
> +		return -EINVAL;
> +
> +	switch (len) {
> +	case  16:
> +		cfg = 0 << 24;
> +		mask[0] = 0x1;
> +		break;
> +	case  32:
> +		cfg = 1 << 24;
> +		mask[0] = 0x3;
> +		break;
> +	case  64:
> +		cfg = 2 << 24;
> +		mask[0] = 0xF;
> +		break;
> +	case 128:
> +		cfg = 3 << 24;
> +		mask[0] = 0xFF;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	cfg |= nearly_empty_watermark << 26;
> +	cfg |= nearly_full_watermark << 29;
> +	len /= 16;		/* in 16-dwords: 1, 2, 4 or 8 */
> +	mask[1] = mask[2] = mask[3] = 0;
> +
> +	if (!try_module_get(THIS_MODULE))
> +		return -ENODEV;
> +
> +	spin_lock_irq(&qmgr_lock);
> +	if (__raw_readl(&qmgr_regs->sram[queue])) {
> +		err = -EBUSY;
> +		goto err;
> +	}
> +
> +	while (1) {
> +		if (!(used_sram_bitmap[0] & mask[0]) &&
> +		    !(used_sram_bitmap[1] & mask[1]) &&
> +		    !(used_sram_bitmap[2] & mask[2]) &&
> +		    !(used_sram_bitmap[3] & mask[3]))
> +			break; /* found free space */
> +
> +		addr++;
> +		shift_mask(mask);
> +		if (addr + len > ARRAY_SIZE(qmgr_regs->sram)) {
> +			printk(KERN_ERR "qmgr: no free SRAM space for"
> +			       " queue %i\n", queue);
> +			err = -ENOMEM;
> +			goto err;
> +		}
> +	}
> +
> +	used_sram_bitmap[0] |= mask[0];
> +	used_sram_bitmap[1] |= mask[1];
> +	used_sram_bitmap[2] |= mask[2];
> +	used_sram_bitmap[3] |= mask[3];
> +	__raw_writel(cfg | (addr << 14), &qmgr_regs->sram[queue]);
> +	spin_unlock_irq(&qmgr_lock);
> +
> +#if DEBUG
> +	printk(KERN_DEBUG "qmgr: requested queue %i, addr = 0x%02X\n",
> +	       queue, addr);
> +#endif
> +	return 0;
> +
> +err:
> +	spin_unlock_irq(&qmgr_lock);
> +	module_put(THIS_MODULE);
> +	return err;
> +}

As with Christian's driver, I don't know whether an SRAM allocator
makes much sense.  We can just set up a static allocation map for the
in-tree drivers and leave out the allocator altogether.  I.e. I don't
think it's worth the complexity (and just because the butt-ugly Intel
code has an allocator isn't a very good reason. :-)

I.e. an API a la:

	ixp4xx_qmgr_config_queue(int queue_nr, int sram_base_address, int queue_size, ...);

might simply suffice.
