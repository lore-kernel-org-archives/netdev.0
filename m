From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Sun, 9 Jun 2013 08:53:20 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5CB230@DE02WEMBXB.internal.synopsys.com>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
 <20130607203231.GA14077@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	"Mischa Jonker" <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Grant Likely" <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"joe@perches.com" <joe@perches.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/08/2013 12:33 AM, Francois Romieu wrote:
 > Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
[]
 >> + * Vineet Gupta: Nov 2009
 >> + *  -Rewrote the driver register access macros so that multiple 
accesses
 >> + *   in same function use "anchor" reg to save the base addr causing
 >> + *   shorter instructions
 >
 > The kernel has been using git for some time: even if you don't remove 
this
 > stuff, you shouldn't add more of it.

As replied to Joe I just want to name people contributed in this driver.
What is a appropriate way to do it?

 >> +#define NAPI_WEIGHT 40		/* Workload for NAPI */
 >
 > ARC_EMAC_NAPI_WEIGHT ?

If it makes sense I may rename this one. I didn't do it earlier just 
because this symbol is not exposed to anything outside this driver so 
short and might be common name shouldn't hurt.

 >> +struct arc_emac_bd_t {
 >> +	unsigned int info;
 >> +	void *data;
 >
 > Why no char * ?
 >
 > It's skb->data after all.

Makes sense - will correct.

 > [...]
 >> +static const struct ethtool_ops arc_emac_ethtool_ops = {
 >> +	.get_settings = arc_emac_get_settings,
 >> +	.set_settings = arc_emac_set_settings,
 >> +	.get_drvinfo = arc_emac_get_drvinfo,
 >> +	.get_link = ethtool_op_get_link,
 >
 > 	.get_settings	= arc_emac_get_settings,
 > 	.set_settings	= arc_emac_set_settings,
 > 	.get_drvinfo	= arc_emac_get_drvinfo,
 > 	.get_link	= ethtool_op_get_link,

Good point. Thanks.

 >> +};
 >> +
 >> +static int arc_emac_poll(struct napi_struct *napi, int budget)
 >> +{
 >> +	struct net_device *net_dev = napi->dev;
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +	struct sk_buff *skb, *skbnew;
 >> +	unsigned int i, loop, len, info, work_done = 0;
 >
 > You may reduce the scope of several variables.

Correct.

 >> +
 >> +			/* Make a note that we saw a packet at this BD.
 >> +			 * So next time, driver starts from this + 1
 >> +			 */
 >> +			priv->last_rx_bd = i;
 >> +
 >> +			/* Packet fits in one BD (Non Fragmented) */
 >> +			if (likely((info & (FRST_MASK | LAST_MASK)) ==
 >> +			    (FRST_MASK | LAST_MASK))) {
 >
 > You may #define (FRST_MASK | LAST_MASK)

This combo is used in only 2 places so is it worth to introduce another 
define? With these (FRST_MASK | LAST_MASK) I suppose reader will 
understand that these are 2 separate bits. But still it might be just my 
vision and if #define (FRST_MASK | LAST_MASK) looks better then I'll add 
it immediately.

 >> +
 >> +				len = info & LEN_MASK;
 >> +				priv->stats.rx_packets++;
 >> +				priv->stats.rx_bytes += len;
 >> +				skb = priv->rx_skbuff[i];
 >> +
 >> +				/* Get a new SKB from stack */
 >> +				skbnew = netdev_alloc_skb(net_dev,
 >> +							  net_dev->mtu +
 >> +							  EMAC_BUFFER_PAD);
 >> +
 >> +				if (!skbnew) {
 >> +					netdev_err(net_dev, "Out of memory, "
 >> +						   "dropping packet\n");
 >
 > Rate limit or do nothing.

Not clear what do you mean. Could you please clarify?

 >> +
 >> +					/* Return buffer to EMAC */
 >> +					priv->rxbd[i].info = FOR_EMAC |
 >> +					       (net_dev->mtu + EMAC_BUFFER_PAD);
 >> +					priv->stats.rx_dropped++;
 >> +					continue;
 >> +				}
 >> +
 >> +				/* Actually preparing the BD for next cycle
 >> +				 * IP header align, eth is 14 bytes
 >> +				 */
 >> +				skb_reserve(skbnew, 2);
 >
 > netdev_alloc_skb_ip_align

Thanks, will use this one instead.

 >> +				priv->rx_skbuff[i] = skbnew;
 >> +
 >> +				priv->rxbd[i].data = skbnew->data;
 >> +				priv->rxbd[i].info = FOR_EMAC |
 >> +					       (net_dev->mtu + EMAC_BUFFER_PAD);
 >> +
 >> +				/* Prepare arrived pkt for delivery to stack */
 >> +				dma_map_single(&net_dev->dev, (void *)skb->data,
 >> +					       len, DMA_FROM_DEVICE);
 >
 > dma_map_single may fail.

Correct. Will add test of returned value.

 > Speaking of it, where are dma_unmap and dma_sync ?

Oops, this is something I need to look at a bit now)

 > [...]
 >> +/**
 >> + * arc_emac_intr - Global interrupt handler for EMAC.
 >> + * @irq:		irq number.
 >> + * @net_dev:	net_device pointer.
 >> + *
 >> + * returns: IRQ_HANDLED for all cases.
 >> + *
 >> + * ARC EMAC has only 1 interrupt line, and depending on bits raised in
 >> + * STATUS register we may tell what is a reason for interrupt to fire.
 >> + */
 >> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 >> +{
 >> +	struct net_device *net_dev = (struct net_device *)dev_instance;
 >
 > Useless cast from void *

Agree.

 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +	unsigned int status;
 >> +
 >> +	/* Read STATUS register from EMAC */
 >> +	status = EMAC_REG_GET(priv->reg_base_addr, R_STATUS);
 >> +
 >> +	/* Mask all bits except "MDIO complete" */
 >> +	status &= ~MDIO_MASK;
 >> +
 >> +	/* To reset any bit in STATUS register we need to write "1" in
 >> +	 * corresponding bit. That's why we write only masked bits back.
 >> +	 */
 >> +	EMAC_REG_SET(priv->reg_base_addr, R_STATUS, status);
 >> +
 >> +	if (likely(status & (RXINT_MASK | TXINT_MASK))) {
 >> +		if (status & RXINT_MASK) {
 >> +			if (likely(napi_schedule_prep(&priv->napi))) {
 >> +				EMAC_REG_CLR(priv->reg_base_addr, R_ENABLE,
 >> +					     RXINT_MASK);
 >> +				__napi_schedule(&priv->napi);
 >> +			}
 >> +		}
 >> +		if (status & TXINT_MASK) {
 >> +			unsigned int i, info;
 >> +			struct sk_buff *skb;
 >> +
 >> +			for (i = 0; i < TX_BD_NUM; i++) {
 >> +				info = priv->txbd[priv->txbd_dirty].info;
 >> +
 >> +				if (info & (DROP | DEFR | LTCL | UFLO))
 >> +					netdev_warn(net_dev,
 >> +						    "add Tx errors to stats\n");
 >> +
 >> +				if ((info & FOR_EMAC) ||
 >> +					!priv->txbd[priv->txbd_dirty].data)
 >
 > 				if ((info & FOR_EMAC) ||
 > 				    !priv->txbd[priv->txbd_dirty].data)
 >

Incorrect indentation, I see this now.

 >> +					break;
 >> +
 >> +				if (info & LAST_MASK) {
 >> +					skb = priv->tx_skbuff[priv->txbd_dirty];
 >> +					priv->stats.tx_packets++;
 >> +					priv->stats.tx_bytes += skb->len;
 >> +
 >> +					/* return the sk_buff to system */
 >> +					dev_kfree_skb_irq(skb);
 >> +				}
 >> +				priv->txbd[priv->txbd_dirty].data = 0x0;
 >> +				priv->txbd[priv->txbd_dirty].info = 0x0;
 >> +				priv->txbd_dirty = (priv->txbd_dirty + 1) %
 >> +						                      TX_BD_NUM;
 >> +			}
 >> +		}
 >> +	} else {
 >> +		if (status & ERR_MASK) {
 >> +			/* MSER/RXCR/RXFR/RXFL interrupt fires on corresponding
 >> +			 * 8-bit error counter overrun.
 >> +			 * Because of this fact we add 256 items each time
 >> +			 * overrun interrupt happens.
 >> +			 */
 >
 > Please use a local &priv->stats variable.

Ok, makes sense.

 >> +
 >> +			if (status & TXCH_MASK) {
 >> +				priv->stats.tx_errors++;
 >> +				priv->stats.tx_aborted_errors++;
 >> +				netdev_err(priv->net_dev,
 >> +					   "Tx chaining err! txbd_dirty = %u\n",
 >> +					   priv->txbd_dirty);
 >> +			} else if (status & MSER_MASK) {
 >> +				priv->stats.rx_missed_errors += 255;
 >> +				priv->stats.rx_errors += 255;
 >> +			} else if (status & RXCR_MASK) {
 >> +				priv->stats.rx_crc_errors += 255;
 >> +				priv->stats.rx_errors += 255;
 >> +			} else if (status & RXFR_MASK) {
 >> +				priv->stats.rx_frame_errors += 255;
 >> +				priv->stats.rx_errors += 255;
 >> +			} else if (status & RXFL_MASK) {
 >> +				priv->stats.rx_over_errors += 255;
 >> +				priv->stats.rx_errors += 255;
 >> +			} else {
 >> +				netdev_err(priv->net_dev,
 >> +					   "unknown err. Status reg is 0x%x\n",
 >> +					   status);
 >> +			}
 >> +		}
 >> +	}
 >> +	return IRQ_HANDLED;
 >> +}
 >> +
 >> +/**
 >> + * arc_emac_open - Open the network device.
 >> + * @net_dev:	Pointer to the network device.
 >> + *
 >> + * returns: 0, on success or non-zero error value on failure.
 >> + *
 >> + * This function sets the MAC address, requests and enables an IRQ
 >> + * for the EMAC device and starts the Tx queue.
 >> + * It also connects to the phy device.
 >> + */
 >> +int arc_emac_open(struct net_device *net_dev)
 >
 > static
 >

Why didn't I put static for every other function? Will fix it now.

 >> +{
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +	struct arc_emac_bd_t *bd;
 >> +	struct sk_buff *skb;
 >> +	int i;
 >> +
 >> +	if (!priv->phy_node) {
 >> +		netdev_err(net_dev, "arc_emac_open: phy device is absent\n");
 >> +		return -ENODEV;
 >> +	}
 >> +
 >> +	priv->phy_dev = of_phy_connect(net_dev, priv->phy_node,
 >> +				       arc_emac_adjust_link, 0,
 >> +				       PHY_INTERFACE_MODE_MII);
 >> +
 >> +	if (!priv->phy_dev) {
 >> +		netdev_err(net_dev, "of_phy_connect() failed\n");
 >> +		return -ENODEV;
 >> +	}
 >
 > Is there a reason why it could not be done in probe and thus save
 > some !priv->phy_dev checks ?

I think that I saw in couple of drivers phy connection is done in 
"open". That's why I put mine here too. In general I think it's possible 
to move this functionality in "probe" easily.

 >> +
 >> +	netdev_info(net_dev, "connected to %s phy with id 0x%x\n",
 >> +		    priv->phy_dev->drv->name, priv->phy_dev->phy_id);
 >> +
 >> +	priv->phy_dev->autoneg = AUTONEG_ENABLE;
 >> +	priv->phy_dev->speed = 0;
 >> +	priv->phy_dev->duplex = 0;
 >> +
 >> +	/* We support only up-to 100mbps speeds */
 >> +	priv->phy_dev->advertising = priv->phy_dev->supported;
 >> +	priv->phy_dev->advertising &= PHY_BASIC_FEATURES;
 >> +	priv->phy_dev->advertising |= ADVERTISED_Autoneg;
 >
 > I'd go for a local priv->phy_dev.

Makes sense.

 >> +
 >> +	/* Restart auto negotiation */
 >> +	phy_start_aneg(priv->phy_dev);
 >> +
 >> +	netif_start_queue(net_dev);
 >
 > No need to rush. Please finish software init.

Ok.

 >> +
 >> +	/* Allocate and set buffers for Rx BD's */
 >> +	bd = priv->rxbd;
 >> +	for (i = 0; i < RX_BD_NUM; i++) {
 >> +		skb = netdev_alloc_skb(net_dev, net_dev->mtu + EMAC_BUFFER_PAD);
 >
 > Missing NULL check.

Correct. Will fix.

 >> +{
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +
 >> +	napi_disable(&priv->napi);
 >> +	netif_stop_queue(net_dev);
 >> +
 >> +	/* Disable interrupts */
 >> +	EMAC_REG_CLR(priv->reg_base_addr, R_ENABLE,
 >> +		     TXINT_MASK |	/* Tx interrupt */
 >> +		     RXINT_MASK |	/* Rx interrupt */
 >> +		     ERR_MASK |		/* Error interrupt */
 >> +		     TXCH_MASK);	/* Transmit chaining error interrupt */
 >
 > Useless comments.

Why so? Is it clear that TXCH means "Transmit chaining error interrupt"?
Or those defines should just have comments where they are defined and 
later just use them with no comments?

 >
 >> +
 >> +	if (priv->phy_dev)
 >> +		phy_disconnect(priv->phy_dev);
 >
 > arc_emac_open succeeded: priv->phy_dev can't be NULL.

Right. Useless check.

 >> +{
 >> +	int len, bitmask;
 >> +	unsigned int info;
 >> +	char *pkt;
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +
 >> +	len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
 >> +	pkt = skb->data;
 >> +	net_dev->trans_start = jiffies;
 >> +
 >> +	dma_map_single(&net_dev->dev, (void *)pkt, len, DMA_TO_DEVICE);
 >
 > dma_map_single may fail.

Check is needed I see.

 >> +static const struct net_device_ops arc_emac_netdev_ops = {
 >> +	.ndo_open = arc_emac_open,
 >> +	.ndo_stop = arc_emac_stop,
 >> +	.ndo_start_xmit = arc_emac_tx,
 >> +	.ndo_set_mac_address = arc_emac_set_address,
 >> +	.ndo_get_stats = arc_emac_stats,
 >
 > Please use tabs before "=".

Ok.

 >> +static struct platform_driver arc_emac_driver = {
 >> +		.probe = arc_emac_probe,
 >> +		.remove = arc_emac_remove,
 >> +		.driver = {
 >> +			.name = DRV_NAME,
 >> +			.owner = THIS_MODULE,
 >> +			.of_match_table  = arc_emac_dt_ids,
 >> +			},
 >
 > Excess tab.

Ok.

 > [...]
 >> diff --git a/drivers/net/ethernet/arc/arc_emac_mdio.c 
b/drivers/net/ethernet/arc/arc_emac_mdio.c
 >> new file mode 100644
 >> index 0000000..7d13dd5
 >> --- /dev/null
 >> +++ b/drivers/net/ethernet/arc/arc_emac_mdio.c
 > [...]
 >> +static int arc_mdio_complete_wait(struct arc_mdio_priv *priv)
 >> +{
 >> +	unsigned int status;
 >
 > Excess scope.

Ok.

 >> +	unsigned int count = (ARC_MDIO_COMPLETE_POLL_COUNT * 40);
 >> +
 >> +	while (1) {
 >> +		/* Read STATUS register from EMAC */
 >> +		status = EMAC_REG_GET(priv->reg_base_addr, R_STATUS);
 >
 > Useless comment.

Might be so.

 >> +
 >> +		/* Mask "MDIO complete" bit */
 >> +		status &= MDIO_MASK;
 >> +
 >> +		if (status) {
 >> +			/* Reset "MDIO complete" flag */
 >> +			EMAC_REG_SET(priv->reg_base_addr, R_STATUS, status);
 >> +			break;
 >
 > 			return 0;

I prefer 1 exit point. That's why I put here "break".

 >> +		}
 >> +
 >> +		/* Make sure we never get into infinite loop */
 >> +		if (count-- == 0) {
 >
 > KISS: use a for loop ?
 >

Good point. Indeed "for" fits better here.

 >> +			WARN_ON(1);
 >> +			return -ETIMEDOUT;
 >> +		}
 >> +		msleep(25);
 >> +	}
 >> +	return 0;
 >> +}
 > [...]
 >> +static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int 
reg_num)
 >> +{
 >> +	int error;
 >> +	unsigned int value;
 >> +	struct arc_mdio_priv *priv = bus->priv;
 >
 > Revert the xmas tree.

Not clear what does it mean? Could you please calrify?

 > [...]
 >> +int arc_mdio_probe(struct device_node *dev_node, struct 
arc_mdio_priv *priv)
 >> +{
 >> +	struct mii_bus *bus;
 >> +	int error;
 >> +
 >> +	bus = mdiobus_alloc();
 >> +	if (!bus) {
 >> +		error = -ENOMEM;
 >> +		goto cleanup;
 >
 > Nothing needs to be cleaned up.

Seems like that's true )

 > [...]
 >> diff --git a/drivers/net/ethernet/arc/arc_emac_mdio.h 
b/drivers/net/ethernet/arc/arc_emac_mdio.h
 >> new file mode 100644
 >> index 0000000..954241e
 >> --- /dev/null
 >> +++ b/drivers/net/ethernet/arc/arc_emac_mdio.h
 >> @@ -0,0 +1,22 @@
 >> +/*
 >> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. 
(www.synopsys.com)
 >> + *
 >> + * Definitions for MDIO of ARC EMAC device driver
 >> + */
 >> +
 >> +#ifndef ARC_MDIO_H
 >> +#define ARC_MDIO_H
 >> +
 >> +#include <linux/device.h>
 >> +#include <linux/phy.h>
 >> +
 >> +struct arc_mdio_priv {
 >> +	struct mii_bus *bus;
 >> +	struct device *dev;
 >> +	void __iomem *reg_base_addr; /* MAC registers base address */
 >> +};
 >
 > Overengineered ?

Why so? Not clear, sorry.

 > [...]
 >> diff --git a/drivers/net/ethernet/arc/arc_emac_regs.h 
b/drivers/net/ethernet/arc/arc_emac_regs.h
 >> new file mode 100644
 >> index 0000000..e4c8d73
 >> --- /dev/null
 >> +++ b/drivers/net/ethernet/arc/arc_emac_regs.h
 > [...]
 >> +#define EMAC_REG_SET(reg_base_addr, reg, val)	\
 >> +			iowrite32((val), reg_base_addr + reg * sizeof(int))
 >> +
 >> +#define EMAC_REG_GET(reg_base_addr, reg)	\
 >> +			ioread32(reg_base_addr + reg * sizeof(int))
 >
 > May use real non-caps functions.

Do you mean to use "io{read|write}32" directly without macro?

 >> +
 >> +#define EMAC_REG_OR(b, r, v)  EMAC_REG_SET(b, r, EMAC_REG_GET(b, r) 
| (v))
 >> +#define EMAC_REG_CLR(b, r, v) EMAC_REG_SET(b, r, EMAC_REG_GET(b, r) 
& ~(v))
 >
 > May use real non-caps functions.
 >
 > Go ahead.
 >

Thanks a lot for this deep analisys.

-Alexey
