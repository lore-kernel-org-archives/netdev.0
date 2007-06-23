From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Ethernet driver for EISA only SNI RM200/RM400 machines
Date: Sat, 23 Jun 2007 09:53:01 -0700
Message-ID: <20070623095301.bfefce03.akpm@linux-foundation.org>
References: <20070622195358.GB13176@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53309 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761299AbXFWQxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 12:53:45 -0400
In-Reply-To: <20070622195358.GB13176@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 22 Jun 2007 21:53:58 +0200 tsbogend@alpha.franken.de (Thomas Bogendoerfer) wrote:
> Hi,
> 
> This is new ethernet driver, which use the code taken out of lasi_82596
> (done by the other patch I just sent).
> 
> Thomas.
> 
> 
> Ethernet driver for EISA only SNI RM200/RM400 machines
> 
> ...
>
> +static char sni_82596_string[] = "snirm_82596";

const?

> +
> +#define DMA_ALLOC                      dma_alloc_coherent
> +#define DMA_FREE                       dma_free_coherent
> +#define DMA_WBACK(priv, addr, len)     do { } while (0)
> +#define DMA_INV(priv, addr, len)       do { } while (0)
> +#define DMA_WBACK_INV(priv, addr, len) do { } while (0)
> +
> +#define SYSBUS      0x00004400
> +
> +/* big endian CPU, 82596 little endian */
> +#define SWAP32(x)   cpu_to_le32((u32)(x))
> +#define SWAP16(x)   cpu_to_le16((u16)(x))
> +
> +#define OPT_MPU_16BIT    0x01
> +
> +static inline void CA(struct net_device *dev);
> +static inline void MPU_PORT(struct net_device *dev, int c, dma_addr_t x);

These two function's implementations could be moved to before the #include,
s we wouldn't need to forward-declare them?

> +#include "lib82596.c"

ugh.  Is this really unavoidable?

> +MODULE_AUTHOR("Thomas Bogendoerfer");
> +MODULE_DESCRIPTION("i82596 driver");
> +MODULE_LICENSE("GPL");
> +module_param(i596_debug, int, 0);
> +MODULE_PARM_DESC(i596_debug, "82596 debug mask");
> +
> +static inline void CA(struct net_device *dev)
> +{
> +	struct i596_private *lp = netdev_priv(dev);
> +	
> +	writel(0, lp->ca);
> +}
> +
> +
> +static inline void MPU_PORT(struct net_device *dev, int c, dma_addr_t x)
> +{
> +	struct i596_private *lp = netdev_priv(dev);
> +
> +	u32 v = (u32) (c) | (u32) (x);
> +	
> +	if (lp->options & OPT_MPU_16BIT) {
> +		writew(v & 0xffff, lp->mpu_port);
> +		wmb(); udelay(1); /* order writes to MPU port */

Nope, please put these on separate lines.  No exceptions..

> +		writew(v >> 16, lp->mpu_port);
> +	} else {
> +		writel(v, lp->mpu_port);
> +		wmb(); udelay(1); /* order writes to MPU port */
> +		writel(v, lp->mpu_port);
> +	}
> +}

Three callsites: This looks too large to inline.

I see no reason why this and CA() are have upper-case names?

> +
> +static int __devinit sni_82596_probe(struct platform_device *dev)
> +{
> +	struct	net_device *netdevice;
> +	struct i596_private *lp;
> +	struct  resource *res, *ca, *idprom, *options;
> +	int	retval = -ENODEV;
> +	static int init;
> +	void __iomem *mpu_addr = NULL;
> +	void __iomem *ca_addr = NULL;
> +	u8 __iomem *eth_addr = NULL;
> +	
> +	if (init == 0) {
> +		printk(KERN_INFO SNI_82596_DRIVER_VERSION "\n");
> +		init++;
> +	}

Might as well do this message in the module_init() function?  There's a
per-probed-device message later on anwyay.

The patchset tries to add rather a lot of new trailing whitespace btw.

> +	res = platform_get_resource(dev, IORESOURCE_MEM, 0);
> +	if (!res)
> +		goto probe_failed;
> +	mpu_addr = ioremap_nocache(res->start, 4);
> +	if (!mpu_addr) {
> +		retval = -ENOMEM;
> +		goto probe_failed;
> +	}
> +	ca = platform_get_resource(dev, IORESOURCE_MEM, 1);
> +	if (!ca)
> +		goto probe_failed;
> +	ca_addr = ioremap_nocache(ca->start, 4);
> +	if (!ca_addr) {
> +		retval = -ENOMEM;
> +		goto probe_failed;
> +	}
> +	idprom = platform_get_resource(dev, IORESOURCE_MEM, 2);
> +	if (!idprom)
> +		goto probe_failed;
> +	eth_addr = ioremap_nocache(idprom->start, 0x10);
> +	if (!eth_addr) {
> +		retval = -ENOMEM;
> +		goto probe_failed;
> +	}
> +	options = platform_get_resource(dev, 0, 0);
> +	if (!options)
> +		goto probe_failed;
> +
> +	printk(KERN_INFO "Found i82596 at 0x%x\n", res->start);
> +
> +	netdevice = alloc_etherdev(sizeof(struct i596_private));
> +	if (!netdevice) {
> +		retval = -ENOMEM;
> +		goto probe_failed;
> +	}
> +	SET_NETDEV_DEV(netdevice, &dev->dev);
> +	platform_set_drvdata (dev, netdevice);
> +
> +	netdevice->base_addr = res->start;
> +	netdevice->irq = platform_get_irq(dev, 0);
> +		
> +	/* someone seams to like messed up stuff */
> +	netdevice->dev_addr[0] = readb(eth_addr + 0x0b);
> +	netdevice->dev_addr[1] = readb(eth_addr + 0x0a);
> +	netdevice->dev_addr[2] = readb(eth_addr + 0x09);
> +	netdevice->dev_addr[3] = readb(eth_addr + 0x08);
> +	netdevice->dev_addr[4] = readb(eth_addr + 0x07);
> +	netdevice->dev_addr[5] = readb(eth_addr + 0x06);
> +	iounmap(eth_addr);
> +	
> +	if (!netdevice->irq) {
> +		printk(KERN_ERR "%s: IRQ not found for i82596 at 0x%lx\n",
> +			__FILE__, netdevice->base_addr);
> +		goto probe_failed;
> +	}
> +	
> +	lp = netdev_priv(netdevice);
> +	lp->options = options->flags & IORESOURCE_BITS;
> +	lp->ca = ca_addr;
> +	lp->mpu_port = mpu_addr;
> +	
> +	retval = i82596_probe(netdevice);
> +	if (retval) {
> +		free_netdev(netdevice);
> +probe_failed:
> +		if (mpu_addr)
> +			iounmap(mpu_addr);
> +		if (ca_addr)
> +			iounmap(ca_addr);
> +		if (eth_addr)
> +			iounmap(ca_addr);
> +	}
> +	return retval;
> +}
> +
> +static int __devexit sni_82596_driver_remove (struct platform_device *pdev)

Extraneous space                               ^ here

> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct i596_private *lp = netdev_priv(dev);
> +
> +	unregister_netdev (dev);

and                      ^ here

checkpatch.pl will find these things.

> +	DMA_FREE(dev->dev.parent, sizeof(struct i596_private),
> +		 lp->dma, lp->dma_addr);
> +	iounmap(lp->ca);
> +	iounmap(lp->mpu_port);
> +	free_netdev (dev);
> +	return 0;
> +}
> +
> +static struct platform_driver sni_82596_driver = {
> +	.probe	= sni_82596_probe,
> +	.remove	= __devexit_p(sni_82596_driver_remove),
> +	.driver	= {
> +		.name	= sni_82596_string,
> +	},
> +};
> +
> +static int __devinit sni_82596_init(void)
> +{
> +	return platform_driver_register(&sni_82596_driver);
> +}
> +
> +
> +static void __exit sni_82596_exit(void)
> +{
> +	platform_driver_unregister(&sni_82596_driver);
> +}
> +
> +module_init(sni_82596_init);
> +module_exit(sni_82596_exit);

