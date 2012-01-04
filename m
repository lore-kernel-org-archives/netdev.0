From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/4] CS89x0 : add platform driver support
Date: Wed, 4 Jan 2012 10:20:00 +0100
Message-ID: <20120104092000.GP5446@pengutronix.de>
References: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58868 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab2ADJUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 04:20:06 -0500
Content-Disposition: inline
In-Reply-To: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Jaccon,

Thanks for continuing this. Some comments inline.

On Tue, Jan 03, 2012 at 11:12:09PM +0100, Jaccon Bastiaansen wrote:
> @@ -151,6 +153,9 @@
>  #include <asm/system.h>
>  #include <asm/io.h>
>  #include <asm/irq.h>
> +#ifdef CONFIG_CS89x0_PLATFORM
> +#include <linux/atomic.h>
> +#endif

No need to ifdef includes.

>  #if ALLOW_DMA
>  #include <asm/dma.h>
>  #endif
> @@ -173,6 +178,7 @@ static char version[] __initdata =
>  /* The cs8900 has 4 IRQ pins, software selectable. cs8900_irq_map maps
>     them to system IRQ numbers. This mapping is card specific and is set to
>     the configuration of the Cirrus Eval board for this chip. */
> +#if defined(CONFIG_CS89x0_PLATFORM)
>  #if defined(CONFIG_MACH_IXDP2351)
>  static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
>  static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
> @@ -188,7 +194,17 @@ static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
>  static unsigned int netcard_portlist[] __used __initdata = {
>  	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>  };
> -static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
> +static unsigned int cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
> +#else
> +/*
> + * Counter for the number of CS89x0 platform device instances, which is needed
> + * because this driver currently supports only one CS89x0 platform device
> + * instance.
> + */
> +static atomic_t platform_dev_cnt = ATOMIC_INIT(0);
> +static unsigned int cs8900_irq_map[] = {0, 0, 0, 0};
> +static unsigned int netcard_portlist[] __used __initdata = {0, 0};
> +#endif
>  #else
>  static unsigned int netcard_portlist[] __used __initdata =
>     { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
> @@ -737,7 +753,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
>  	} else {
>  		i = lp->isa_config & INT_NO_MASK;
>  		if (lp->chip_type == CS8900) {

[...]

>  
> -#ifdef MODULE
> +#if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)
>  
>  static struct net_device *dev_cs89x0;
>  
> @@ -1900,7 +1916,78 @@ cleanup_module(void)
>  	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
>  	free_netdev(dev_cs89x0);
>  }
> -#endif /* MODULE */
> +#endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
> +
> +#ifdef CONFIG_CS89x0_PLATFORM
> +static int cs89x0_platform_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
> +	struct resource *mem_res;
> +	struct resource *irq_res;
> +	int err;
> +
> +	if (!dev)
> +		return -ENODEV;
> +
> +	if (atomic_inc_return(&platform_dev_cnt) != 1)
> +		return -EBUSY;

This deserves a comment like this:

/*
 * This driver uses global variables. Until this is fixed we can
 * only support a single instance.
 */

> +
> +	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);

Don't use virtual addresses in resources. It's wrong. Pass in physical
addresses here and use ioremap() in the driver.

> +	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (mem_res == NULL || irq_res == NULL) {
> +		pr_warning("memory and/or interrupt resource missing.\n");

dev_warn please

> +		err = -ENOENT;
> +		goto out;
> +	}
> +
> +	cs8900_irq_map[0] = irq_res->start;
> +	err = cs89x0_probe1(dev, mem_res->start, 0);
> +	if (err) {
> +		pr_warning("no cs8900 or cs8920 detected.\n");

ditto

> +		goto out;
> +	}
> +
> +	platform_set_drvdata(pdev, dev);
> +	return 0;
> +
> +out:
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static int cs89x0_platform_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +
> +	unregister_netdev(dev);
> +	free_netdev(dev);
> +	return 0;
> +}
> +
> +static struct platform_driver cs89x0_platform_driver = {
> +	.driver = {
> +		.name	= DRV_NAME,
> +		.owner	= THIS_MODULE
> +	},
> +	.probe	= cs89x0_platform_probe,
> +	.remove	= cs89x0_platform_remove

Please add a comma at the end of the last elements aswell. The rationale
if that we can add elements later without touching the existing lines.

>  
>  /*
>   * Local variables:
> @@ -1911,3 +1998,4 @@ cleanup_module(void)
>   * End:
>   *
>   */
> +

Please don't add blank lines at the end of files.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
