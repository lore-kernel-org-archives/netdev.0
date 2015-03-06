From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH v2 2/2] net/macb: merge at91_ether driver into macb driver
Date: Fri, 6 Mar 2015 09:17:38 +0100
Message-ID: <20150306081738.GF3989@piout.net>
References: <1425622439-2372-1-git-send-email-boris.brezillon@free-electrons.com>
 <1425622439-2372-3-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425622439-2372-3-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2015 at 07:13:59 +0100, Boris Brezillon wrote :
> From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> 
> macb and at91_ether drivers can be compiled as modules, but the at91_ether
> driver use some functions and variables defined in the macb one, thus
> creating a dependency on the macb driver.
> 
> Since these drivers are sharing the same logic we can easily merge
> at91_ether into macb.
> 
> In order to factorize common probing logic we've added an ->init() function
> to struct macb_config (the structure associated with the compatible
> string), and moved macb specific init code from macb_probe to macb_init.
> 
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Tested-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

> ---
>  drivers/net/ethernet/cadence/Kconfig      |   8 -
>  drivers/net/ethernet/cadence/Makefile     |   1 -
>  drivers/net/ethernet/cadence/at91_ether.c | 481 ----------------------
>  drivers/net/ethernet/cadence/macb.c       | 641 ++++++++++++++++++++++--------
>  drivers/net/ethernet/cadence/macb.h       |  10 +-
>  5 files changed, 485 insertions(+), 656 deletions(-)
>  delete mode 100644 drivers/net/ethernet/cadence/at91_ether.c
> 
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 321d2ad..fb8d09b 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -20,14 +20,6 @@ config NET_CADENCE
>  
>  if NET_CADENCE
>  
> -config ARM_AT91_ETHER
> -	tristate "AT91RM9200 Ethernet support"
> -	depends on HAS_DMA && (ARCH_AT91 || COMPILE_TEST)
> -	select MACB
> -	---help---
> -	  If you wish to compile a kernel for the AT91RM9200 and enable
> -	  ethernet support, then you should always answer Y to this.
> -
>  config MACB
>  	tristate "Cadence MACB/GEM support"
>  	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL || ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST)
> diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
> index 9068b83..91f79b1 100644
> --- a/drivers/net/ethernet/cadence/Makefile
> +++ b/drivers/net/ethernet/cadence/Makefile
> @@ -2,5 +2,4 @@
>  # Makefile for the Atmel network device drivers.
>  #
>  
> -obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o
>  obj-$(CONFIG_MACB) += macb.o
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> deleted file mode 100644
> index 7ef55f5..0000000
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ /dev/null
> @@ -1,481 +0,0 @@
> -/*
> - * Ethernet driver for the Atmel AT91RM9200 (Thunder)
> - *
> - *  Copyright (C) 2003 SAN People (Pty) Ltd
> - *
> - * Based on an earlier Atmel EMAC macrocell driver by Atmel and Lineo Inc.
> - * Initial version by Rick Bronson 01/11/2003
> - *
> - * This program is free software; you can redistribute it and/or
> - * modify it under the terms of the GNU General Public License
> - * as published by the Free Software Foundation; either version
> - * 2 of the License, or (at your option) any later version.
> - */
> -
> -#include <linux/module.h>
> -#include <linux/init.h>
> -#include <linux/interrupt.h>
> -#include <linux/netdevice.h>
> -#include <linux/etherdevice.h>
> -#include <linux/skbuff.h>
> -#include <linux/dma-mapping.h>
> -#include <linux/ethtool.h>
> -#include <linux/platform_data/macb.h>
> -#include <linux/platform_device.h>
> -#include <linux/clk.h>
> -#include <linux/gfp.h>
> -#include <linux/phy.h>
> -#include <linux/io.h>
> -#include <linux/of.h>
> -#include <linux/of_device.h>
> -#include <linux/of_net.h>
> -
> -#include "macb.h"
> -
> -/* 1518 rounded up */
> -#define MAX_RBUFF_SZ	0x600
> -/* max number of receive buffers */
> -#define MAX_RX_DESCR	9
> -
> -/* Initialize and start the Receiver and Transmit subsystems */
> -static int at91ether_start(struct net_device *dev)
> -{
> -	struct macb *lp = netdev_priv(dev);
> -	dma_addr_t addr;
> -	u32 ctl;
> -	int i;
> -
> -	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
> -					 (MAX_RX_DESCR *
> -					  sizeof(struct macb_dma_desc)),
> -					 &lp->rx_ring_dma, GFP_KERNEL);
> -	if (!lp->rx_ring)
> -		return -ENOMEM;
> -
> -	lp->rx_buffers = dma_alloc_coherent(&lp->pdev->dev,
> -					    MAX_RX_DESCR * MAX_RBUFF_SZ,
> -					    &lp->rx_buffers_dma, GFP_KERNEL);
> -	if (!lp->rx_buffers) {
> -		dma_free_coherent(&lp->pdev->dev,
> -				  MAX_RX_DESCR * sizeof(struct macb_dma_desc),
> -				  lp->rx_ring, lp->rx_ring_dma);
> -		lp->rx_ring = NULL;
> -		return -ENOMEM;
> -	}
> -
> -	addr = lp->rx_buffers_dma;
> -	for (i = 0; i < MAX_RX_DESCR; i++) {
> -		lp->rx_ring[i].addr = addr;
> -		lp->rx_ring[i].ctrl = 0;
> -		addr += MAX_RBUFF_SZ;
> -	}
> -
> -	/* Set the Wrap bit on the last descriptor */
> -	lp->rx_ring[MAX_RX_DESCR - 1].addr |= MACB_BIT(RX_WRAP);
> -
> -	/* Reset buffer index */
> -	lp->rx_tail = 0;
> -
> -	/* Program address of descriptor list in Rx Buffer Queue register */
> -	macb_writel(lp, RBQP, lp->rx_ring_dma);
> -
> -	/* Enable Receive and Transmit */
> -	ctl = macb_readl(lp, NCR);
> -	macb_writel(lp, NCR, ctl | MACB_BIT(RE) | MACB_BIT(TE));
> -
> -	return 0;
> -}
> -
> -/* Open the ethernet interface */
> -static int at91ether_open(struct net_device *dev)
> -{
> -	struct macb *lp = netdev_priv(dev);
> -	u32 ctl;
> -	int ret;
> -
> -	/* Clear internal statistics */
> -	ctl = macb_readl(lp, NCR);
> -	macb_writel(lp, NCR, ctl | MACB_BIT(CLRSTAT));
> -
> -	macb_set_hwaddr(lp);
> -
> -	ret = at91ether_start(dev);
> -	if (ret)
> -		return ret;
> -
> -	/* Enable MAC interrupts */
> -	macb_writel(lp, IER, MACB_BIT(RCOMP)	|
> -			     MACB_BIT(RXUBR)	|
> -			     MACB_BIT(ISR_TUND)	|
> -			     MACB_BIT(ISR_RLE)	|
> -			     MACB_BIT(TCOMP)	|
> -			     MACB_BIT(ISR_ROVR)	|
> -			     MACB_BIT(HRESP));
> -
> -	/* schedule a link state check */
> -	phy_start(lp->phy_dev);
> -
> -	netif_start_queue(dev);
> -
> -	return 0;
> -}
> -
> -/* Close the interface */
> -static int at91ether_close(struct net_device *dev)
> -{
> -	struct macb *lp = netdev_priv(dev);
> -	u32 ctl;
> -
> -	/* Disable Receiver and Transmitter */
> -	ctl = macb_readl(lp, NCR);
> -	macb_writel(lp, NCR, ctl & ~(MACB_BIT(TE) | MACB_BIT(RE)));
> -
> -	/* Disable MAC interrupts */
> -	macb_writel(lp, IDR, MACB_BIT(RCOMP)	|
> -			     MACB_BIT(RXUBR)	|
> -			     MACB_BIT(ISR_TUND)	|
> -			     MACB_BIT(ISR_RLE)	|
> -			     MACB_BIT(TCOMP)	|
> -			     MACB_BIT(ISR_ROVR) |
> -			     MACB_BIT(HRESP));
> -
> -	netif_stop_queue(dev);
> -
> -	dma_free_coherent(&lp->pdev->dev,
> -				MAX_RX_DESCR * sizeof(struct macb_dma_desc),
> -				lp->rx_ring, lp->rx_ring_dma);
> -	lp->rx_ring = NULL;
> -
> -	dma_free_coherent(&lp->pdev->dev,
> -				MAX_RX_DESCR * MAX_RBUFF_SZ,
> -				lp->rx_buffers, lp->rx_buffers_dma);
> -	lp->rx_buffers = NULL;
> -
> -	return 0;
> -}
> -
> -/* Transmit packet */
> -static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
> -{
> -	struct macb *lp = netdev_priv(dev);
> -
> -	if (macb_readl(lp, TSR) & MACB_BIT(RM9200_BNQ)) {
> -		netif_stop_queue(dev);
> -
> -		/* Store packet information (to free when Tx completed) */
> -		lp->skb = skb;
> -		lp->skb_length = skb->len;
> -		lp->skb_physaddr = dma_map_single(NULL, skb->data, skb->len,
> -							DMA_TO_DEVICE);
> -
> -		/* Set address of the data in the Transmit Address register */
> -		macb_writel(lp, TAR, lp->skb_physaddr);
> -		/* Set length of the packet in the Transmit Control register */
> -		macb_writel(lp, TCR, skb->len);
> -
> -	} else {
> -		netdev_err(dev, "%s called, but device is busy!\n", __func__);
> -		return NETDEV_TX_BUSY;
> -	}
> -
> -	return NETDEV_TX_OK;
> -}
> -
> -/* Extract received frame from buffer descriptors and sent to upper layers.
> - * (Called from interrupt context)
> - */
> -static void at91ether_rx(struct net_device *dev)
> -{
> -	struct macb *lp = netdev_priv(dev);
> -	unsigned char *p_recv;
> -	struct sk_buff *skb;
> -	unsigned int pktlen;
> -
> -	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
> -		p_recv = lp->rx_buffers + lp->rx_tail * MAX_RBUFF_SZ;
> -		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
> -		skb = netdev_alloc_skb(dev, pktlen + 2);
> -		if (skb) {
> -			skb_reserve(skb, 2);
> -			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
> -
> -			skb->protocol = eth_type_trans(skb, dev);
> -			lp->stats.rx_packets++;
> -			lp->stats.rx_bytes += pktlen;
> -			netif_rx(skb);
> -		} else {
> -			lp->stats.rx_dropped++;
> -		}
> -
> -		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
> -			lp->stats.multicast++;
> -
> -		/* reset ownership bit */
> -		lp->rx_ring[lp->rx_tail].addr &= ~MACB_BIT(RX_USED);
> -
> -		/* wrap after last buffer */
> -		if (lp->rx_tail == MAX_RX_DESCR - 1)
> -			lp->rx_tail = 0;
> -		else
> -			lp->rx_tail++;
> -	}
> -}
> -
> -/* MAC interrupt handler */
> -static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
> -{
> -	struct net_device *dev = dev_id;
> -	struct macb *lp = netdev_priv(dev);
> -	u32 intstatus, ctl;
> -
> -	/* MAC Interrupt Status register indicates what interrupts are pending.
> -	 * It is automatically cleared once read.
> -	 */
> -	intstatus = macb_readl(lp, ISR);
> -
> -	/* Receive complete */
> -	if (intstatus & MACB_BIT(RCOMP))
> -		at91ether_rx(dev);
> -
> -	/* Transmit complete */
> -	if (intstatus & MACB_BIT(TCOMP)) {
> -		/* The TCOM bit is set even if the transmission failed */
> -		if (intstatus & (MACB_BIT(ISR_TUND) | MACB_BIT(ISR_RLE)))
> -			lp->stats.tx_errors++;
> -
> -		if (lp->skb) {
> -			dev_kfree_skb_irq(lp->skb);
> -			lp->skb = NULL;
> -			dma_unmap_single(NULL, lp->skb_physaddr, lp->skb_length, DMA_TO_DEVICE);
> -			lp->stats.tx_packets++;
> -			lp->stats.tx_bytes += lp->skb_length;
> -		}
> -		netif_wake_queue(dev);
> -	}
> -
> -	/* Work-around for EMAC Errata section 41.3.1 */
> -	if (intstatus & MACB_BIT(RXUBR)) {
> -		ctl = macb_readl(lp, NCR);
> -		macb_writel(lp, NCR, ctl & ~MACB_BIT(RE));
> -		macb_writel(lp, NCR, ctl | MACB_BIT(RE));
> -	}
> -
> -	if (intstatus & MACB_BIT(ISR_ROVR))
> -		netdev_err(dev, "ROVR error\n");
> -
> -	return IRQ_HANDLED;
> -}
> -
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -static void at91ether_poll_controller(struct net_device *dev)
> -{
> -	unsigned long flags;
> -
> -	local_irq_save(flags);
> -	at91ether_interrupt(dev->irq, dev);
> -	local_irq_restore(flags);
> -}
> -#endif
> -
> -static const struct net_device_ops at91ether_netdev_ops = {
> -	.ndo_open		= at91ether_open,
> -	.ndo_stop		= at91ether_close,
> -	.ndo_start_xmit		= at91ether_start_xmit,
> -	.ndo_get_stats		= macb_get_stats,
> -	.ndo_set_rx_mode	= macb_set_rx_mode,
> -	.ndo_set_mac_address	= eth_mac_addr,
> -	.ndo_do_ioctl		= macb_ioctl,
> -	.ndo_validate_addr	= eth_validate_addr,
> -	.ndo_change_mtu		= eth_change_mtu,
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	.ndo_poll_controller	= at91ether_poll_controller,
> -#endif
> -};
> -
> -#if defined(CONFIG_OF)
> -static const struct of_device_id at91ether_dt_ids[] = {
> -	{ .compatible = "cdns,at91rm9200-emac" },
> -	{ .compatible = "cdns,emac" },
> -	{ /* sentinel */ }
> -};
> -MODULE_DEVICE_TABLE(of, at91ether_dt_ids);
> -#endif
> -
> -/* Detect MAC & PHY and perform ethernet interface initialization */
> -static int __init at91ether_probe(struct platform_device *pdev)
> -{
> -	struct macb_platform_data *board_data = dev_get_platdata(&pdev->dev);
> -	struct resource *regs;
> -	struct net_device *dev;
> -	struct phy_device *phydev;
> -	struct macb *lp;
> -	int res;
> -	u32 reg;
> -	const char *mac;
> -
> -	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (!regs)
> -		return -ENOENT;
> -
> -	dev = alloc_etherdev(sizeof(struct macb));
> -	if (!dev)
> -		return -ENOMEM;
> -
> -	lp = netdev_priv(dev);
> -	lp->pdev = pdev;
> -	lp->dev = dev;
> -	spin_lock_init(&lp->lock);
> -
> -	/* physical base address */
> -	dev->base_addr = regs->start;
> -	lp->regs = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
> -	if (!lp->regs) {
> -		res = -ENOMEM;
> -		goto err_free_dev;
> -	}
> -
> -	/* Clock */
> -	lp->pclk = devm_clk_get(&pdev->dev, "ether_clk");
> -	if (IS_ERR(lp->pclk)) {
> -		res = PTR_ERR(lp->pclk);
> -		goto err_free_dev;
> -	}
> -	clk_prepare_enable(lp->pclk);
> -
> -	lp->hclk = ERR_PTR(-ENOENT);
> -	lp->tx_clk = ERR_PTR(-ENOENT);
> -
> -	/* Install the interrupt handler */
> -	dev->irq = platform_get_irq(pdev, 0);
> -	res = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt, 0, dev->name, dev);
> -	if (res)
> -		goto err_disable_clock;
> -
> -	dev->netdev_ops = &at91ether_netdev_ops;
> -	dev->ethtool_ops = &macb_ethtool_ops;
> -	platform_set_drvdata(pdev, dev);
> -	SET_NETDEV_DEV(dev, &pdev->dev);
> -
> -	mac = of_get_mac_address(pdev->dev.of_node);
> -	if (mac)
> -		memcpy(lp->dev->dev_addr, mac, ETH_ALEN);
> -	else
> -		macb_get_hwaddr(lp);
> -
> -	res = of_get_phy_mode(pdev->dev.of_node);
> -	if (res < 0) {
> -		if (board_data && board_data->is_rmii)
> -			lp->phy_interface = PHY_INTERFACE_MODE_RMII;
> -		else
> -			lp->phy_interface = PHY_INTERFACE_MODE_MII;
> -	} else {
> -		lp->phy_interface = res;
> -	}
> -
> -	macb_writel(lp, NCR, 0);
> -
> -	reg = MACB_BF(CLK, MACB_CLK_DIV32) | MACB_BIT(BIG);
> -	if (lp->phy_interface == PHY_INTERFACE_MODE_RMII)
> -		reg |= MACB_BIT(RM9200_RMII);
> -
> -	macb_writel(lp, NCFGR, reg);
> -
> -	/* Register the network interface */
> -	res = register_netdev(dev);
> -	if (res)
> -		goto err_disable_clock;
> -
> -	res = macb_mii_init(lp);
> -	if (res)
> -		goto err_out_unregister_netdev;
> -
> -	/* will be enabled in open() */
> -	netif_carrier_off(dev);
> -
> -	phydev = lp->phy_dev;
> -	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
> -				phydev->drv->name, dev_name(&phydev->dev),
> -				phydev->irq);
> -
> -	/* Display ethernet banner */
> -	netdev_info(dev, "AT91 ethernet at 0x%08lx int=%d (%pM)\n",
> -				dev->base_addr, dev->irq, dev->dev_addr);
> -
> -	return 0;
> -
> -err_out_unregister_netdev:
> -	unregister_netdev(dev);
> -err_disable_clock:
> -	clk_disable_unprepare(lp->pclk);
> -err_free_dev:
> -	free_netdev(dev);
> -	return res;
> -}
> -
> -static int at91ether_remove(struct platform_device *pdev)
> -{
> -	struct net_device *dev = platform_get_drvdata(pdev);
> -	struct macb *lp = netdev_priv(dev);
> -
> -	if (lp->phy_dev)
> -		phy_disconnect(lp->phy_dev);
> -
> -	mdiobus_unregister(lp->mii_bus);
> -	kfree(lp->mii_bus->irq);
> -	mdiobus_free(lp->mii_bus);
> -	unregister_netdev(dev);
> -	clk_disable_unprepare(lp->pclk);
> -	free_netdev(dev);
> -
> -	return 0;
> -}
> -
> -#ifdef CONFIG_PM
> -static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
> -{
> -	struct net_device *net_dev = platform_get_drvdata(pdev);
> -	struct macb *lp = netdev_priv(net_dev);
> -
> -	if (netif_running(net_dev)) {
> -		netif_stop_queue(net_dev);
> -		netif_device_detach(net_dev);
> -
> -		clk_disable_unprepare(lp->pclk);
> -	}
> -	return 0;
> -}
> -
> -static int at91ether_resume(struct platform_device *pdev)
> -{
> -	struct net_device *net_dev = platform_get_drvdata(pdev);
> -	struct macb *lp = netdev_priv(net_dev);
> -
> -	if (netif_running(net_dev)) {
> -		clk_prepare_enable(lp->pclk);
> -
> -		netif_device_attach(net_dev);
> -		netif_start_queue(net_dev);
> -	}
> -	return 0;
> -}
> -#else
> -#define at91ether_suspend	NULL
> -#define at91ether_resume	NULL
> -#endif
> -
> -static struct platform_driver at91ether_driver = {
> -	.remove		= at91ether_remove,
> -	.suspend	= at91ether_suspend,
> -	.resume		= at91ether_resume,
> -	.driver		= {
> -		.name	= "at91_ether",
> -		.of_match_table	= of_match_ptr(at91ether_dt_ids),
> -	},
> -};
> -
> -module_platform_driver_probe(at91ether_driver, at91ether_probe);
> -
> -MODULE_LICENSE("GPL");
> -MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
> -MODULE_AUTHOR("Andrew Victor");
> -MODULE_ALIAS("platform:at91_ether");
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index a429cf8..5c8243fe 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -102,7 +102,7 @@ static void *macb_rx_buffer(struct macb *bp, unsigned int index)
>  	return bp->rx_buffers + bp->rx_buffer_size * macb_rx_ring_wrap(index);
>  }
>  
> -void macb_set_hwaddr(struct macb *bp)
> +static void macb_set_hwaddr(struct macb *bp)
>  {
>  	u32 bottom;
>  	u16 top;
> @@ -120,9 +120,8 @@ void macb_set_hwaddr(struct macb *bp)
>  	macb_or_gem_writel(bp, SA4B, 0);
>  	macb_or_gem_writel(bp, SA4T, 0);
>  }
> -EXPORT_SYMBOL_GPL(macb_set_hwaddr);
>  
> -void macb_get_hwaddr(struct macb *bp)
> +static void macb_get_hwaddr(struct macb *bp)
>  {
>  	struct macb_platform_data *pdata;
>  	u32 bottom;
> @@ -162,7 +161,6 @@ void macb_get_hwaddr(struct macb *bp)
>  	netdev_info(bp->dev, "invalid hw address, using random\n");
>  	eth_hw_addr_random(bp->dev);
>  }
> -EXPORT_SYMBOL_GPL(macb_get_hwaddr);
>  
>  static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>  {
> @@ -359,7 +357,7 @@ static int macb_mii_probe(struct net_device *dev)
>  	return 0;
>  }
>  
> -int macb_mii_init(struct macb *bp)
> +static int macb_mii_init(struct macb *bp)
>  {
>  	struct macb_platform_data *pdata;
>  	struct device_node *np;
> @@ -440,7 +438,6 @@ err_out_free_mdiobus:
>  err_out:
>  	return err;
>  }
> -EXPORT_SYMBOL_GPL(macb_mii_init);
>  
>  static void macb_update_stats(struct macb *bp)
>  {
> @@ -1725,7 +1722,7 @@ static void macb_sethashtable(struct net_device *dev)
>  /*
>   * Enable/Disable promiscuous and multicast modes.
>   */
> -void macb_set_rx_mode(struct net_device *dev)
> +static void macb_set_rx_mode(struct net_device *dev)
>  {
>  	unsigned long cfg;
>  	struct macb *bp = netdev_priv(dev);
> @@ -1766,7 +1763,6 @@ void macb_set_rx_mode(struct net_device *dev)
>  
>  	macb_writel(bp, NCFGR, cfg);
>  }
> -EXPORT_SYMBOL_GPL(macb_set_rx_mode);
>  
>  static int macb_open(struct net_device *dev)
>  {
> @@ -1919,7 +1915,7 @@ static void gem_get_ethtool_strings(struct net_device *dev, u32 sset, u8 *p)
>  	}
>  }
>  
> -struct net_device_stats *macb_get_stats(struct net_device *dev)
> +static struct net_device_stats *macb_get_stats(struct net_device *dev)
>  {
>  	struct macb *bp = netdev_priv(dev);
>  	struct net_device_stats *nstat = &bp->stats;
> @@ -1965,7 +1961,6 @@ struct net_device_stats *macb_get_stats(struct net_device *dev)
>  
>  	return nstat;
>  }
> -EXPORT_SYMBOL_GPL(macb_get_stats);
>  
>  static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  {
> @@ -2027,7 +2022,7 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>  	}
>  }
>  
> -const struct ethtool_ops macb_ethtool_ops = {
> +static const struct ethtool_ops macb_ethtool_ops = {
>  	.get_settings		= macb_get_settings,
>  	.set_settings		= macb_set_settings,
>  	.get_regs_len		= macb_get_regs_len,
> @@ -2035,7 +2030,6 @@ const struct ethtool_ops macb_ethtool_ops = {
>  	.get_link		= ethtool_op_get_link,
>  	.get_ts_info		= ethtool_op_get_ts_info,
>  };
> -EXPORT_SYMBOL_GPL(macb_ethtool_ops);
>  
>  static const struct ethtool_ops gem_ethtool_ops = {
>  	.get_settings		= macb_get_settings,
> @@ -2049,7 +2043,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
>  	.get_sset_count		= gem_get_sset_count,
>  };
>  
> -int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  {
>  	struct macb *bp = netdev_priv(dev);
>  	struct phy_device *phydev = bp->phy_dev;
> @@ -2062,7 +2056,6 @@ int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  
>  	return phy_mii_ioctl(phydev, rq, cmd);
>  }
> -EXPORT_SYMBOL_GPL(macb_ioctl);
>  
>  static int macb_set_features(struct net_device *netdev,
>  			     netdev_features_t features)
> @@ -2114,39 +2107,6 @@ static const struct net_device_ops macb_netdev_ops = {
>  	.ndo_set_features	= macb_set_features,
>  };
>  
> -#if defined(CONFIG_OF)
> -static struct macb_config at91sam9260_config = {
> -	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
> -};
> -
> -static struct macb_config pc302gem_config = {
> -	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
> -	.dma_burst_length = 16,
> -};
> -
> -static struct macb_config sama5d3_config = {
> -	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
> -	.dma_burst_length = 16,
> -};
> -
> -static struct macb_config sama5d4_config = {
> -	.caps = 0,
> -	.dma_burst_length = 4,
> -};
> -
> -static const struct of_device_id macb_dt_ids[] = {
> -	{ .compatible = "cdns,at32ap7000-macb" },
> -	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
> -	{ .compatible = "cdns,macb" },
> -	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
> -	{ .compatible = "cdns,gem", .data = &pc302gem_config },
> -	{ .compatible = "atmel,sama5d3-gem", .data = &sama5d3_config },
> -	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
> -	{ /* sentinel */ }
> -};
> -MODULE_DEVICE_TABLE(of, macb_dt_ids);
> -#endif
> -
>  /*
>   * Configure peripheral capacities according to device tree
>   * and integration options used
> @@ -2154,22 +2114,6 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
>  static void macb_configure_caps(struct macb *bp)
>  {
>  	u32 dcfg;
> -	const struct of_device_id *match;
> -	const struct macb_config *config;
> -
> -	if (bp->pdev->dev.of_node) {
> -		match = of_match_node(macb_dt_ids, bp->pdev->dev.of_node);
> -		if (match && match->data) {
> -			config = (const struct macb_config *)match->data;
> -
> -			bp->caps = config->caps;
> -			/*
> -			 * As we have access to the matching node, configure
> -			 * DMA burst length as well
> -			 */
> -			bp->dma_burst_length = config->dma_burst_length;
> -		}
> -	}
>  
>  	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2)
>  		bp->caps |= MACB_CAPS_MACB_IS_GEM;
> @@ -2210,92 +2154,57 @@ static void macb_probe_queues(void __iomem *mem,
>  			(*num_queues)++;
>  }
>  
> -static int macb_probe(struct platform_device *pdev)
> +static int macb_init(struct platform_device *pdev)
>  {
> -	struct macb_platform_data *pdata;
> -	struct resource *regs;
> -	struct net_device *dev;
> -	struct macb *bp;
> -	struct macb_queue *queue;
> -	struct phy_device *phydev;
> -	u32 config;
> -	int err = -ENXIO;
> -	const char *mac;
> -	void __iomem *mem;
> +	struct net_device *dev = platform_get_drvdata(pdev);
>  	unsigned int hw_q, queue_mask, q, num_queues;
> -	struct clk *pclk, *hclk, *tx_clk;
> -
> -	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (!regs) {
> -		dev_err(&pdev->dev, "no mmio resource defined\n");
> -		goto err_out;
> -	}
> +	struct macb *bp = netdev_priv(dev);
> +	struct macb_queue *queue;
> +	int err;
> +	u32 val;
>  
> -	pclk = devm_clk_get(&pdev->dev, "pclk");
> -	if (IS_ERR(pclk)) {
> -		err = PTR_ERR(pclk);
> +	bp->pclk = devm_clk_get(&pdev->dev, "pclk");
> +	if (IS_ERR(bp->pclk)) {
> +		err = PTR_ERR(bp->pclk);
>  		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", err);
> -		goto err_out;
> +		return err;
>  	}
>  
> -	hclk = devm_clk_get(&pdev->dev, "hclk");
> -	if (IS_ERR(hclk)) {
> -		err = PTR_ERR(hclk);
> +	bp->hclk = devm_clk_get(&pdev->dev, "hclk");
> +	if (IS_ERR(bp->hclk)) {
> +		err = PTR_ERR(bp->hclk);
>  		dev_err(&pdev->dev, "failed to get hclk (%u)\n", err);
> -		goto err_out;
> +		return err;
>  	}
>  
> -	tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
> -	if (IS_ERR(tx_clk))
> -		tx_clk = NULL;
> +	bp->tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
> +	if (IS_ERR(bp->tx_clk))
> +		bp->tx_clk = NULL;
>  
> -	err = clk_prepare_enable(pclk);
> +	err = clk_prepare_enable(bp->pclk);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
> -		goto err_out;
> +		return err;
>  	}
>  
> -	err = clk_prepare_enable(hclk);
> +	err = clk_prepare_enable(bp->hclk);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to enable hclk (%u)\n", err);
> -		goto err_out_disable_pclk;
> +		goto err_disable_pclk;
>  	}
>  
> -	err = clk_prepare_enable(tx_clk);
> +	err = clk_prepare_enable(bp->tx_clk);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n", err);
> -		goto err_out_disable_hclk;
> -	}
> -
> -	err = -ENOMEM;
> -	mem = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
> -	if (!mem) {
> -		dev_err(&pdev->dev, "failed to map registers, aborting.\n");
> -		goto err_out_disable_clocks;
> +		goto err_disable_hclk;
>  	}
>  
> -	macb_probe_queues(mem, &queue_mask, &num_queues);
> -	dev = alloc_etherdev_mq(sizeof(*bp), num_queues);
> -	if (!dev)
> -		goto err_out_disable_clocks;
> -
> -	SET_NETDEV_DEV(dev, &pdev->dev);
> -
> -	bp = netdev_priv(dev);
> -	bp->pdev = pdev;
> -	bp->dev = dev;
> -	bp->regs = mem;
> -	bp->num_queues = num_queues;
> -	bp->pclk = pclk;
> -	bp->hclk = hclk;
> -	bp->tx_clk = tx_clk;
> -
> -	spin_lock_init(&bp->lock);
> -
>  	/* set the queue register mapping once for all: queue0 has a special
>  	 * register mapping but we don't want to test the queue index then
>  	 * compute the corresponding register offset at run time.
>  	 */
> +	macb_probe_queues(bp->regs, &queue_mask, &num_queues);
> +
>  	for (hw_q = 0, q = 0; hw_q < MACB_MAX_QUEUES; ++hw_q) {
>  		if (!(queue_mask & (1 << hw_q)))
>  			continue;
> @@ -2329,22 +2238,16 @@ static int macb_probe(struct platform_device *pdev)
>  			dev_err(&pdev->dev,
>  				"Unable to request IRQ %d (error %d)\n",
>  				queue->irq, err);
> -			goto err_out_free_netdev;
> +			goto err_disable_tx_clk;
>  		}
>  
>  		INIT_WORK(&queue->tx_error_task, macb_tx_error_task);
>  		q++;
>  	}
> -	dev->irq = bp->queues[0].irq;
>  
>  	dev->netdev_ops = &macb_netdev_ops;
>  	netif_napi_add(dev, &bp->napi, macb_poll, 64);
>  
> -	dev->base_addr = regs->start;
> -
> -	/* setup capacities */
> -	macb_configure_caps(bp);
> -
>  	/* setup appropriated routines according to adapter type */
>  	if (macb_is_gem(bp)) {
>  		bp->max_tx_length = GEM_MAX_TX_LEN;
> @@ -2371,18 +2274,440 @@ static int macb_probe(struct platform_device *pdev)
>  		dev->hw_features &= ~NETIF_F_SG;
>  	dev->features = dev->hw_features;
>  
> +	val = 0;
> +	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
> +		val = GEM_BIT(RGMII);
> +	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
> +		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +		val = MACB_BIT(RMII);
> +	else if (bp->phy_interface == PHY_INTERFACE_MODE_MII &&
> +		 !(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +		val = MACB_BIT(MII);
> +
> +	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
> +		val |= MACB_BIT(CLKEN);
> +
> +	macb_or_gem_writel(bp, USRIO, val);
> +
> +	/* setup capacities */
> +	macb_configure_caps(bp);
> +
>  	/* Set MII management clock divider */
> -	config = macb_mdc_clk_div(bp);
> -	config |= macb_dbw(bp);
> -	macb_writel(bp, NCFGR, config);
> +	val = macb_mdc_clk_div(bp);
> +	val |= macb_dbw(bp);
> +	macb_writel(bp, NCFGR, val);
> +
> +	return 0;
> +
> +err_disable_tx_clk:
> +	clk_disable_unprepare(bp->tx_clk);
> +
> +err_disable_hclk:
> +	clk_disable_unprepare(bp->hclk);
> +
> +err_disable_pclk:
> +	clk_disable_unprepare(bp->pclk);
> +
> +	return err;
> +}
> +
> +#if defined(CONFIG_OF)
> +/* 1518 rounded up */
> +#define AT91ETHER_MAX_RBUFF_SZ	0x600
> +/* max number of receive buffers */
> +#define AT91ETHER_MAX_RX_DESCR	9
> +
> +/* Initialize and start the Receiver and Transmit subsystems */
> +static int at91ether_start(struct net_device *dev)
> +{
> +	struct macb *lp = netdev_priv(dev);
> +	dma_addr_t addr;
> +	u32 ctl;
> +	int i;
> +
> +	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
> +					 (AT91ETHER_MAX_RX_DESCR *
> +					  sizeof(struct macb_dma_desc)),
> +					 &lp->rx_ring_dma, GFP_KERNEL);
> +	if (!lp->rx_ring)
> +		return -ENOMEM;
> +
> +	lp->rx_buffers = dma_alloc_coherent(&lp->pdev->dev,
> +					    AT91ETHER_MAX_RX_DESCR *
> +					    AT91ETHER_MAX_RBUFF_SZ,
> +					    &lp->rx_buffers_dma, GFP_KERNEL);
> +	if (!lp->rx_buffers) {
> +		dma_free_coherent(&lp->pdev->dev,
> +				  AT91ETHER_MAX_RX_DESCR *
> +				  sizeof(struct macb_dma_desc),
> +				  lp->rx_ring, lp->rx_ring_dma);
> +		lp->rx_ring = NULL;
> +		return -ENOMEM;
> +	}
> +
> +	addr = lp->rx_buffers_dma;
> +	for (i = 0; i < AT91ETHER_MAX_RX_DESCR; i++) {
> +		lp->rx_ring[i].addr = addr;
> +		lp->rx_ring[i].ctrl = 0;
> +		addr += AT91ETHER_MAX_RBUFF_SZ;
> +	}
> +
> +	/* Set the Wrap bit on the last descriptor */
> +	lp->rx_ring[AT91ETHER_MAX_RX_DESCR - 1].addr |= MACB_BIT(RX_WRAP);
> +
> +	/* Reset buffer index */
> +	lp->rx_tail = 0;
> +
> +	/* Program address of descriptor list in Rx Buffer Queue register */
> +	macb_writel(lp, RBQP, lp->rx_ring_dma);
> +
> +	/* Enable Receive and Transmit */
> +	ctl = macb_readl(lp, NCR);
> +	macb_writel(lp, NCR, ctl | MACB_BIT(RE) | MACB_BIT(TE));
> +
> +	return 0;
> +}
> +
> +/* Open the ethernet interface */
> +static int at91ether_open(struct net_device *dev)
> +{
> +	struct macb *lp = netdev_priv(dev);
> +	u32 ctl;
> +	int ret;
> +
> +	/* Clear internal statistics */
> +	ctl = macb_readl(lp, NCR);
> +	macb_writel(lp, NCR, ctl | MACB_BIT(CLRSTAT));
> +
> +	macb_set_hwaddr(lp);
> +
> +	ret = at91ether_start(dev);
> +	if (ret)
> +		return ret;
> +
> +	/* Enable MAC interrupts */
> +	macb_writel(lp, IER, MACB_BIT(RCOMP)	|
> +			     MACB_BIT(RXUBR)	|
> +			     MACB_BIT(ISR_TUND)	|
> +			     MACB_BIT(ISR_RLE)	|
> +			     MACB_BIT(TCOMP)	|
> +			     MACB_BIT(ISR_ROVR)	|
> +			     MACB_BIT(HRESP));
> +
> +	/* schedule a link state check */
> +	phy_start(lp->phy_dev);
> +
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +/* Close the interface */
> +static int at91ether_close(struct net_device *dev)
> +{
> +	struct macb *lp = netdev_priv(dev);
> +	u32 ctl;
> +
> +	/* Disable Receiver and Transmitter */
> +	ctl = macb_readl(lp, NCR);
> +	macb_writel(lp, NCR, ctl & ~(MACB_BIT(TE) | MACB_BIT(RE)));
> +
> +	/* Disable MAC interrupts */
> +	macb_writel(lp, IDR, MACB_BIT(RCOMP)	|
> +			     MACB_BIT(RXUBR)	|
> +			     MACB_BIT(ISR_TUND)	|
> +			     MACB_BIT(ISR_RLE)	|
> +			     MACB_BIT(TCOMP)	|
> +			     MACB_BIT(ISR_ROVR) |
> +			     MACB_BIT(HRESP));
> +
> +	netif_stop_queue(dev);
> +
> +	dma_free_coherent(&lp->pdev->dev,
> +			  AT91ETHER_MAX_RX_DESCR *
> +			  sizeof(struct macb_dma_desc),
> +			  lp->rx_ring, lp->rx_ring_dma);
> +	lp->rx_ring = NULL;
> +
> +	dma_free_coherent(&lp->pdev->dev,
> +			  AT91ETHER_MAX_RX_DESCR * AT91ETHER_MAX_RBUFF_SZ,
> +			  lp->rx_buffers, lp->rx_buffers_dma);
> +	lp->rx_buffers = NULL;
> +
> +	return 0;
> +}
> +
> +/* Transmit packet */
> +static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct macb *lp = netdev_priv(dev);
> +
> +	if (macb_readl(lp, TSR) & MACB_BIT(RM9200_BNQ)) {
> +		netif_stop_queue(dev);
> +
> +		/* Store packet information (to free when Tx completed) */
> +		lp->skb = skb;
> +		lp->skb_length = skb->len;
> +		lp->skb_physaddr = dma_map_single(NULL, skb->data, skb->len,
> +							DMA_TO_DEVICE);
> +
> +		/* Set address of the data in the Transmit Address register */
> +		macb_writel(lp, TAR, lp->skb_physaddr);
> +		/* Set length of the packet in the Transmit Control register */
> +		macb_writel(lp, TCR, skb->len);
>  
> -	mac = of_get_mac_address(pdev->dev.of_node);
> +	} else {
> +		netdev_err(dev, "%s called, but device is busy!\n", __func__);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +/* Extract received frame from buffer descriptors and sent to upper layers.
> + * (Called from interrupt context)
> + */
> +static void at91ether_rx(struct net_device *dev)
> +{
> +	struct macb *lp = netdev_priv(dev);
> +	unsigned char *p_recv;
> +	struct sk_buff *skb;
> +	unsigned int pktlen;
> +
> +	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
> +		p_recv = lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
> +		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
> +		skb = netdev_alloc_skb(dev, pktlen + 2);
> +		if (skb) {
> +			skb_reserve(skb, 2);
> +			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
> +
> +			skb->protocol = eth_type_trans(skb, dev);
> +			lp->stats.rx_packets++;
> +			lp->stats.rx_bytes += pktlen;
> +			netif_rx(skb);
> +		} else {
> +			lp->stats.rx_dropped++;
> +		}
> +
> +		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
> +			lp->stats.multicast++;
> +
> +		/* reset ownership bit */
> +		lp->rx_ring[lp->rx_tail].addr &= ~MACB_BIT(RX_USED);
> +
> +		/* wrap after last buffer */
> +		if (lp->rx_tail == AT91ETHER_MAX_RX_DESCR - 1)
> +			lp->rx_tail = 0;
> +		else
> +			lp->rx_tail++;
> +	}
> +}
> +
> +/* MAC interrupt handler */
> +static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct macb *lp = netdev_priv(dev);
> +	u32 intstatus, ctl;
> +
> +	/* MAC Interrupt Status register indicates what interrupts are pending.
> +	 * It is automatically cleared once read.
> +	 */
> +	intstatus = macb_readl(lp, ISR);
> +
> +	/* Receive complete */
> +	if (intstatus & MACB_BIT(RCOMP))
> +		at91ether_rx(dev);
> +
> +	/* Transmit complete */
> +	if (intstatus & MACB_BIT(TCOMP)) {
> +		/* The TCOM bit is set even if the transmission failed */
> +		if (intstatus & (MACB_BIT(ISR_TUND) | MACB_BIT(ISR_RLE)))
> +			lp->stats.tx_errors++;
> +
> +		if (lp->skb) {
> +			dev_kfree_skb_irq(lp->skb);
> +			lp->skb = NULL;
> +			dma_unmap_single(NULL, lp->skb_physaddr,
> +					 lp->skb_length, DMA_TO_DEVICE);
> +			lp->stats.tx_packets++;
> +			lp->stats.tx_bytes += lp->skb_length;
> +		}
> +		netif_wake_queue(dev);
> +	}
> +
> +	/* Work-around for EMAC Errata section 41.3.1 */
> +	if (intstatus & MACB_BIT(RXUBR)) {
> +		ctl = macb_readl(lp, NCR);
> +		macb_writel(lp, NCR, ctl & ~MACB_BIT(RE));
> +		macb_writel(lp, NCR, ctl | MACB_BIT(RE));
> +	}
> +
> +	if (intstatus & MACB_BIT(ISR_ROVR))
> +		netdev_err(dev, "ROVR error\n");
> +
> +	return IRQ_HANDLED;
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void at91ether_poll_controller(struct net_device *dev)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	at91ether_interrupt(dev->irq, dev);
> +	local_irq_restore(flags);
> +}
> +#endif
> +
> +static const struct net_device_ops at91ether_netdev_ops = {
> +	.ndo_open		= at91ether_open,
> +	.ndo_stop		= at91ether_close,
> +	.ndo_start_xmit		= at91ether_start_xmit,
> +	.ndo_get_stats		= macb_get_stats,
> +	.ndo_set_rx_mode	= macb_set_rx_mode,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_do_ioctl		= macb_ioctl,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_change_mtu		= eth_change_mtu,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	= at91ether_poll_controller,
> +#endif
> +};
> +
> +static int at91ether_init(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct macb *bp = netdev_priv(dev);
> +	int err;
> +	u32 reg;
> +
> +	bp->pclk = devm_clk_get(&pdev->dev, "ether_clk");
> +	if (IS_ERR(bp->pclk))
> +		return PTR_ERR(bp->pclk);
> +
> +	err = clk_prepare_enable(bp->pclk);
> +	if (err) {
> +		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
> +		return err;
> +	}
> +
> +	dev->netdev_ops = &at91ether_netdev_ops;
> +	dev->ethtool_ops = &macb_ethtool_ops;
> +
> +	err = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt,
> +			       0, dev->name, dev);
> +	if (err)
> +		goto err_disable_clk;
> +
> +	macb_writel(bp, NCR, 0);
> +
> +	reg = MACB_BF(CLK, MACB_CLK_DIV32) | MACB_BIT(BIG);
> +	if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
> +		reg |= MACB_BIT(RM9200_RMII);
> +
> +	macb_writel(bp, NCFGR, reg);
> +
> +	return 0;
> +
> +err_disable_clk:
> +	clk_disable_unprepare(bp->pclk);
> +
> +	return err;
> +}
> +
> +static struct macb_config at91sam9260_config = {
> +	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
> +	.init = macb_init,
> +};
> +
> +static struct macb_config pc302gem_config = {
> +	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
> +	.dma_burst_length = 16,
> +	.init = macb_init,
> +};
> +
> +static struct macb_config sama5d3_config = {
> +	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
> +	.dma_burst_length = 16,
> +	.init = macb_init,
> +};
> +
> +static struct macb_config sama5d4_config = {
> +	.caps = 0,
> +	.dma_burst_length = 4,
> +	.init = macb_init,
> +};
> +
> +static struct macb_config emac_config = {
> +	.init = at91ether_init,
> +};
> +
> +static const struct of_device_id macb_dt_ids[] = {
> +	{ .compatible = "cdns,at32ap7000-macb" },
> +	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
> +	{ .compatible = "cdns,macb" },
> +	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
> +	{ .compatible = "cdns,gem", .data = &pc302gem_config },
> +	{ .compatible = "atmel,sama5d3-gem", .data = &sama5d3_config },
> +	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
> +	{ .compatible = "cdns,at91rm9200-emac", .data = &emac_config },
> +	{ .compatible = "cdns,emac", .data = &emac_config },
> +	{ /* sentinel */ }
> +};
> +MODULE_DEVICE_TABLE(of, macb_dt_ids);
> +#endif /* CONFIG_OF */
> +
> +static int macb_probe(struct platform_device *pdev)
> +{
> +	int (*init)(struct platform_device *) = macb_init;
> +	struct device_node *np = pdev->dev.of_node;
> +	const struct macb_config *macb_config = NULL;
> +	unsigned int queue_mask, num_queues;
> +	struct macb_platform_data *pdata;
> +	struct phy_device *phydev;
> +	struct net_device *dev;
> +	struct resource *regs;
> +	void __iomem *mem;
> +	const char *mac;
> +	struct macb *bp;
> +	int err;
> +
> +	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	mem = devm_ioremap_resource(&pdev->dev, regs);
> +	if (IS_ERR(mem))
> +		return PTR_ERR(mem);
> +
> +	macb_probe_queues(mem, &queue_mask, &num_queues);
> +	dev = alloc_etherdev_mq(sizeof(*bp), num_queues);
> +	if (!dev)
> +		return -ENOMEM;
> +
> +	dev->base_addr = regs->start;
> +
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	bp = netdev_priv(dev);
> +	bp->pdev = pdev;
> +	bp->dev = dev;
> +	bp->regs = mem;
> +	bp->num_queues = num_queues;
> +	spin_lock_init(&bp->lock);
> +
> +	platform_set_drvdata(pdev, dev);
> +
> +	dev->irq = platform_get_irq(pdev, 0);
> +	if (dev->irq < 0)
> +		return dev->irq;
> +
> +	mac = of_get_mac_address(np);
>  	if (mac)
>  		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
>  	else
>  		macb_get_hwaddr(bp);
>  
> -	err = of_get_phy_mode(pdev->dev.of_node);
> +	err = of_get_phy_mode(np);
>  	if (err < 0) {
>  		pdata = dev_get_platdata(&pdev->dev);
>  		if (pdata && pdata->is_rmii)
> @@ -2393,33 +2718,35 @@ static int macb_probe(struct platform_device *pdev)
>  		bp->phy_interface = err;
>  	}
>  
> -	config = 0;
> -	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
> -		config = GEM_BIT(RGMII);
> -	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
> -		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> -		config = MACB_BIT(RMII);
> -	else if (bp->phy_interface == PHY_INTERFACE_MODE_MII &&
> -		 !(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> -		config = MACB_BIT(MII);
> +	if (np) {
> +		const struct of_device_id *match;
>  
> -	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
> -		config |= MACB_BIT(CLKEN);
> +		match = of_match_node(macb_dt_ids, np);
> +		if (match)
> +			macb_config = match->data;
> +	}
> +
> +	if (macb_config) {
> +		bp->caps = macb_config->caps;
> +		bp->dma_burst_length = macb_config->dma_burst_length;
> +		init = macb_config->init;
> +	}
>  
> -	macb_or_gem_writel(bp, USRIO, config);
> +	/* IP specific init */
> +	err = init(pdev);
> +	if (err)
> +		goto err_out_free_netdev;
>  
>  	err = register_netdev(dev);
>  	if (err) {
>  		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> -		goto err_out_free_netdev;
> +		goto err_disable_clocks;
>  	}
>  
>  	err = macb_mii_init(bp);
>  	if (err)
>  		goto err_out_unregister_netdev;
>  
> -	platform_set_drvdata(pdev, dev);
> -
>  	netif_carrier_off(dev);
>  
>  	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
> @@ -2434,15 +2761,15 @@ static int macb_probe(struct platform_device *pdev)
>  
>  err_out_unregister_netdev:
>  	unregister_netdev(dev);
> +
> +err_disable_clocks:
> +	clk_disable_unprepare(bp->tx_clk);
> +	clk_disable_unprepare(bp->hclk);
> +	clk_disable_unprepare(bp->pclk);
> +
>  err_out_free_netdev:
>  	free_netdev(dev);
> -err_out_disable_clocks:
> -	clk_disable_unprepare(tx_clk);
> -err_out_disable_hclk:
> -	clk_disable_unprepare(hclk);
> -err_out_disable_pclk:
> -	clk_disable_unprepare(pclk);
> -err_out:
> +
>  	return err;
>  }
>  
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index efe0247..113253b 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -752,6 +752,7 @@ struct macb_or_gem_ops {
>  struct macb_config {
>  	u32			caps;
>  	unsigned int		dma_burst_length;
> +	int	(*init)(struct platform_device *pdev);
>  };
>  
>  struct macb_queue {
> @@ -822,15 +823,6 @@ struct macb {
>  	u64			ethtool_stats[GEM_STATS_LEN];
>  };
>  
> -extern const struct ethtool_ops macb_ethtool_ops;
> -
> -int macb_mii_init(struct macb *bp);
> -int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> -struct net_device_stats *macb_get_stats(struct net_device *dev);
> -void macb_set_rx_mode(struct net_device *dev);
> -void macb_set_hwaddr(struct macb *bp);
> -void macb_get_hwaddr(struct macb *bp);
> -
>  static inline bool macb_is_gem(struct macb *bp)
>  {
>  	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
> -- 
> 1.9.1
> 

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
