From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH V3 1/4] CS89x0 : add platform driver support
Date: Mon, 16 Jan 2012 11:09:07 +0000
Message-ID: <20120116110907.GU1068@n2100.arm.linux.org.uk>
References: <1326570996-27818-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43275 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab2APLJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 06:09:32 -0500
Content-Disposition: inline
In-Reply-To: <1326570996-27818-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2012 at 08:56:36PM +0100, Jaccon Bastiaansen wrote:
> The CS89x0 ethernet controller is used on a number of evaluation
> boards, such as the MX31ADS. The current driver has memory address and
> IRQ settings for each board on which this controller is used. Driver
> updates are therefore required to support other boards that also use
> the CS89x0. To avoid these driver updates, a better mechanism
> (platform driver support) is added to communicate the board dependent
> settings to the driver.

Please check your changes with sparse and checkpatch.

> @@ -236,6 +243,11 @@ struct net_local {
>  	unsigned char *end_dma_buff;	/* points to the end of the buffer */
>  	unsigned char *rx_dma_ptr;	/* points to the next packet  */
>  #endif
> +#ifdef CONFIG_CS89x0_PLATFORM
> +	void *virt_addr;	/* Virtual address for accessing the CS89x0. */

	void __iomem *virt_addr;

> +#ifdef CONFIG_CS89x0_PLATFORM
> +static int __init cs89x0_platform_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
> +	struct net_local *lp = netdev_priv(dev);
> +	struct resource *mem_res;
> +	int err;
> +
> +	if (!dev)
> +		return -ENODEV;

Wouldn't -ENOMEM be better?  Also, organise this as:

	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
	struct net_local *lp;

	if (!dev)
		return -ENOMEM;

	lp = netdev_priv(dev);

because you don't shouldn't how netdev_priv() works, or whether it
dereferences a pointer within the net_device.  (How netdev_priv()
works is not something that should concern you as a driver writer -
it's there to hide the details, which may change over time.)

> +
> +	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	dev->irq = platform_get_irq(pdev, 0);
> +	if (mem_res == NULL || dev->irq <= 0) {
> +		dev_warn(&dev->dev, "memory/interrupt resource missing.\n");
> +		err = -ENOENT;

Other patches return -ENXIO for this.

> +		goto free;
> +	}
> +
> +	lp->phys_addr = mem_res->start;
> +	lp->size = mem_res->end - mem_res->start + 1;

lp->size = resource_size(mem_res);

> +	if (!request_mem_region(lp->phys_addr, lp->size, DRV_NAME)) {
> +		dev_warn(&dev->dev, "request_mem_region() failed.\n");
> +		err = -ENOMEM;

If the region is busy, then this fails.  It's return value should therefore
be -EBUSY.

> +		goto free;
> +	}
> +
> +	lp->virt_addr = ioremap(lp->phys_addr, lp->size);
> +	if (!lp->virt_addr) {
> +		dev_warn(&dev->dev, "ioremap() failed.\n");
> +		err = -ENOMEM;
> +		goto release;
> +	}
> +
> +	err = cs89x0_probe1(dev, (int)lp->virt_addr, 0);

Have you checked whether this causes a compiler warning?  Normally if you
cast a pointer to 'int', it'll complain about a narrowing cast.

There are architectures Linux supports where int is 32-bit and a pointer
is 64-bit, so this won't work.  It needs the 'port' type changed to
something which pointers can be casted (I suggest unsigned long, as we
do elsewhere.)
