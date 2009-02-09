From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] MX27 FEC add mii_bus
Date: Mon, 9 Feb 2009 15:44:26 +0100
Message-ID: <20090209144426.GC25267@pengutronix.de>
References: <d99e615c0902090222q53bfbeb4pffa8eaea9ca9214b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, gerg@snapgear.com,
	netdev@vger.kernel.org
To: frederic rodo <fred.rodo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40752 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbZBIOoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 09:44:32 -0500
Content-Disposition: inline
In-Reply-To: <d99e615c0902090222q53bfbeb4pffa8eaea9ca9214b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Feb 09, 2009 at 11:22:57AM +0100, frederic rodo wrote:
> Hi,
> 
> This patch add the mii bus to the fec driver from the Sasha Hauer's tree.
>  I don't know why some times a mii transfer failed (hardware or driver
> problem). So I've add a test case in the adjust_link callback.
> 
> Is there's another way to do this?

I have no idea, but some other comments instead ;)

First of all I tried this patch and it works for me.

You should combine the two patches into one since you include linux/fec.h in
this patch but add the file itself in the next patch. Also, please add a
select PHYLIB to Kconfig.

some minor things inline.

Sascha

> Signed-off-by: Frederic Rodo <fred.rodo@gmail.com>
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index ed4825b..24df187 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -40,6 +40,7 @@
>  #include <linux/irq.h>
>  #include <linux/clk.h>
>  #include <linux/platform_device.h>
> +#include <linux/phy.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -51,6 +52,7 @@
>  #include "fec.h"
>  
>  #ifdef CONFIG_ARCH_MXC
> +#include <linux/fec.h>
>  #include <mach/hardware.h>
>  #define FEC_ALIGNMENT	0xf
>  #else
> @@ -110,8 +112,6 @@ static unsigned char	fec_mac_default[] = {
>  #define	FEC_FLASHMAC	0
>  #endif
>  
> -#endif /* FEC_LEGACY */
> -
>  /* Forward declarations of some structures to support different PHYs
>  */
>  
> @@ -130,6 +130,8 @@ typedef struct {
>  	const phy_cmd_t *shutdown;
>  } phy_info_t;
>  
> +#endif /* FEC_LEGACY */
> +
>  /* The number of Tx and Rx buffers.  These are allocated from the page
>   * pool.  The code may assume these are power of two, so it it best
>   * to keep them that size.
> @@ -213,13 +215,13 @@ struct fec_enet_private {
>  	uint	tx_full;
>  	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
>  	spinlock_t hw_lock;
> +#ifdef FEC_LEGACY
>  	/* hold while accessing the mii_list_t() elements */
>  	spinlock_t mii_lock;
>  
>  	uint	phy_id;
>  	uint	phy_id_done;
>  	uint	phy_status;
> -	uint	phy_speed;
>  	phy_info_t const	*phy;
>  	struct work_struct phy_task;
>  
> @@ -228,16 +230,25 @@ struct fec_enet_private {
>  
>  	uint	phy_addr;
>  
> +	int	old_link;
> +#else
> +	struct	platform_device *pdev;
> +	struct	mii_bus *mii_bus;
> +	struct	phy_device *phy_dev;
> +	int	mii_timeout;
> +#endif
> +	uint	phy_speed;
>  	int	index;
>  	int	opened;
>  	int	link;
> -	int	old_link;
>  	int	full_duplex;
>  };
>  
>  static int fec_enet_open(struct net_device *dev);
>  static int fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +#ifdef FEC_LEGACY
>  static void fec_enet_mii(struct net_device *dev);
> +#endif
>  static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
>  static void fec_enet_tx(struct net_device *dev);
>  static void fec_enet_rx(struct net_device *dev);
> @@ -248,6 +259,11 @@ static void fec_stop(struct net_device *dev);
>  static void fec_set_mac_address(struct net_device *dev);
>  
>  
> +/* Transmitter timeout.
> +*/
> +#define TX_TIMEOUT (2*HZ)
> +
> +#ifdef FEC_LEGACY
>  /* MII processing.  We keep this as simple as possible.  Requests are
>   * placed on the list (if there is room).  When the request is finished
>   * by the MII, an optional function may be called.
> @@ -274,10 +290,6 @@ static int	mii_queue(struct net_device *dev, int request,
>  						(VAL & 0xffff))
>  #define mk_mii_end	0
>  
> -/* Transmitter timeout.
> -*/
> -#define TX_TIMEOUT (2*HZ)
> -
>  /* Register definitions for the PHY.
>  */
>  
> @@ -310,6 +322,18 @@ static int	mii_queue(struct net_device *dev, int request,
>  #define PHY_STAT_100HDX	0x4000  /* 100 Mbit half duplex selected */
>  #define PHY_STAT_100FDX	0x8000  /* 100 Mbit full duplex selected */
>  
> +#else
> +/* FEC MMFR bits definition */
> +#define FEC_MMFR_ST		(1 << 30)
> +#define FEC_MMFR_OP_READ	(2 << 28)
> +#define FEC_MMFR_OP_WRITE	(1 << 28)
> +#define FEC_MMFR_PA(v)		((v & 0x1f) << 23)
> +#define FEC_MMFR_RA(v)		((v & 0x1f) << 18)
> +#define FEC_MMFR_TA		(2 << 16)
> +#define FEC_MMFR_DATA(v)	(v & 0xffff)
> +
> +#define FEC_MII_TRIES		10000
> +#endif
>  
>  static int
>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> @@ -490,10 +514,12 @@ fec_enet_interrupt(int irq, void * dev_id)
>  			fec_enet_tx(dev);
>  		}
>  
> +#ifdef FEC_LEGACY
>  		if (int_events & FEC_ENET_MII) {
>  			ret = IRQ_HANDLED;
>  			fec_enet_mii(dev);
>  		}
> +#endif
>  
>  	} while (int_events);
>  
> @@ -711,6 +737,7 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
>  }
>  
>  
> +#ifdef FEC_LEGACY
>  /* called from interrupt context */
>  static void
>  fec_enet_mii(struct net_device *dev)
> @@ -1238,6 +1265,7 @@ static phy_info_t const * const phy_info[] = {
>  	NULL
>  };
>  
> +#endif /* FEC_LEGACY */
>  /* ------------------------------------------------------------------------- */
>  #ifdef HAVE_mii_link_interrupt
>  static irqreturn_t
> @@ -1726,6 +1754,7 @@ static void __inline__ fec_phy_ack_intr(void)
>  
>  /* ------------------------------------------------------------------------- */
>  
> +#ifdef FEC_LEGACY
>  static void mii_display_status(struct net_device *dev)
>  {
>  	struct fec_enet_private *fep = netdev_priv(dev);
> @@ -1927,9 +1956,7 @@ mii_discover_phy(uint mii_reg, struct net_device *dev)
>  		printk("FEC: No PHY device found.\n");
>  		/* Disable external MII interface */
>  		fecp->fec_mii_speed = fep->phy_speed = 0;
> -#ifdef FREC_LEGACY
>  		fec_disable_phy_intr();
> -#endif
>  	}
>  }
>  
> @@ -1954,6 +1981,289 @@ mii_link_interrupt(int irq, void * dev_id)
>  	return IRQ_HANDLED;
>  }
>  #endif
> +#else
> +static void fec_enet_handle_link_change(struct net_device *dev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phy_dev = fep->phy_dev;
> +	unsigned long flags;
> +
> +	int status_change = 0;
> +
> +	spin_lock_irqsave(&fep->hw_lock, flags);
> +
> +	/* Prevent a state halted on mii error */
> +	if (fep->mii_timeout && phy_dev->state == PHY_HALTED) {
> +		printk(KERN_INFO "%s: mii resume\n", dev->name);
> +		phy_dev->state = PHY_RESUMING;
> +		goto spin_unlock;
> +	}
> +
> +	if (phy_dev->link) {
> +		if (fep->full_duplex != phy_dev->duplex) {
> +			fec_restart(dev, phy_dev->duplex);
> +			status_change = 1;
> +		}
> +	}
> +
> +	if (phy_dev->link != fep->link) {
> +		fep->link = phy_dev->link;
> +		if (phy_dev->link)
> +			fec_restart(dev, phy_dev->duplex);
> +		else
> +			fec_stop(dev);
> +		status_change = 1;
> +	}
> +spin_unlock:
> +	spin_unlock_irqrestore(&fep->hw_lock, flags);
> +
> +	if (status_change) {
> +		if (phy_dev->link)
> +			printk(KERN_INFO "%s: link up (%d/%s)\n",
> +			       dev->name, phy_dev->speed,
> +			       DUPLEX_FULL == phy_dev->duplex ? "Full"
> +			       : "Half");
> +		else
> +			printk(KERN_INFO "%s: link down\n", dev->name);

You can use phy_print_status() instead.

> +	}
> +}
> +
> +/* Phy section
> + * NOTE: a mii transaction is during around 25 us, so polling it...
> + */
> +static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
> +{
> +	struct fec_enet_private *fep = bus->priv;
> +	volatile fec_t *ep;
> +	int tries = FEC_MII_TRIES;
> +
> +	fep->mii_timeout = 0;
> +	ep = fep->hwp;
> +
> +	/* clear MII end of tranfert bit*/

s/tranfert/transfer/

> +	ep->fec_ievent = FEC_ENET_MII;
> +
> +	/* start a read op */
> +	ep->fec_mii_data = FEC_MMFR_ST | FEC_MMFR_OP_READ |
> +			   FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
> +			   FEC_MMFR_TA;
> +
> +	/* wait for end of transfer */
> +	while (!(ep->fec_ievent & FEC_ENET_MII) && --tries)
> +		cpu_relax();
> +
> +	if (!tries) {
> +		fep->mii_timeout = 1;
> +		return -ETIMEDOUT;
> +	}
> +
> +	/* return value */
> +	return FEC_MMFR_DATA(ep->fec_mii_data);
> +}
> +
> +static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
> +			   u16 value)
> +{
> +	struct fec_enet_private *fep = bus->priv;
> +	volatile fec_t	*ep;
> +	int tries = FEC_MII_TRIES;
> +
> +	fep->mii_timeout = 0;
> +	ep = fep->hwp;
> +
> +	/* clear MII end of tranfert bit*/
> +	ep->fec_ievent = FEC_ENET_MII;
> +
> +	/* start a read op */
> +	ep->fec_mii_data = FEC_MMFR_ST | FEC_MMFR_OP_READ |
> +			   FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
> +			   FEC_MMFR_TA | FEC_MMFR_DATA(value);
> +
> +	/* wait for end of transfer */
> +	while (!(ep->fec_ievent & FEC_ENET_MII) && --tries)
> +		cpu_relax();
> +
> +	if (!tries) {
> +		fep->mii_timeout = 1;
> +		return -ETIMEDOUT;
> +	}
> +	return 0;
> +}
> +
> +static int fec_enet_mdio_reset(struct mii_bus *bus)
> +{
> +	return 0;
> +}
> +
> +static int fec_enet_mii_probe(struct net_device *dev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phy_dev = NULL;
> +	int phy_addr;
> +
> +	/* find the first phy */
> +	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> +		if (fep->mii_bus->phy_map[phy_addr]) {
> +			phy_dev = fep->mii_bus->phy_map[phy_addr];
> +			break;
> +		}
> +	}
> +
> +	if (!phy_dev) {
> +		printk(KERN_ERR "%s: no PHY found\n", dev->name);
> +		return -1;
> +	}
> +
> +	/* attach the mac to the phy */
> +	phy_dev = phy_connect(dev, phy_dev->dev.bus_id,
> +			     &fec_enet_handle_link_change, 0,
> +			     PHY_INTERFACE_MODE_MII);
> +	if (IS_ERR(phy_dev)) {
> +		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
> +		return PTR_ERR(phy_dev);
> +	}
> +
> +	/* mask with MAC supported features */
> +	phy_dev->supported &= PHY_BASIC_FEATURES;
> +	phy_dev->advertising = phy_dev->supported;
> +
> +	fep->phy_dev = phy_dev;
> +	fep->link = 0;
> +	fep->full_duplex = 0;
> +
> +	return 0;
> +}
> +
> +static int fec_enet_mii_init(struct platform_device *pdev)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct fec_enet_platform_data *pdata;
> +	volatile fec_t	*ep;
> +	int err = -ENXIO, i;
> +
> +	ep = fep->hwp;
> +
> +	fep->mii_timeout = 0;
> +	/*
> +	 * Set MII speed to 2.5 MHz
> +	 */
> +	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
> +					/ 2500000) / 2) & 0x3F) << 1;
> +	ep->fec_mii_speed = fep->phy_speed;
> +
> +	fep->mii_bus = mdiobus_alloc();
> +	if (fep->mii_bus == NULL) {
> +		err = -ENOMEM;
> +		goto err_out;
> +	}
> +
> +	fep->mii_bus->name = "fec_enet_mii_bus";
> +	fep->mii_bus->read = &fec_enet_mdio_read;
> +	fep->mii_bus->write = &fec_enet_mdio_write;
> +	fep->mii_bus->reset = &fec_enet_mdio_reset;
> +	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
> +	fep->mii_bus->priv = fep;
> +	fep->mii_bus->parent = &pdev->dev;
> +	pdata = pdev->dev.platform_data;
> +
> +	if (pdata)
> +		fep->mii_bus->phy_mask = pdata->phy_mask;
> +
> +	fep->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);

Please add spaces before and after the *.

> +	if (!fep->mii_bus->irq) {
> +		err = -ENOMEM;
> +		goto err_out_free_mdiobus;
> +	}
> +
> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		fep->mii_bus->irq[i] = PHY_POLL;
> +
> +	platform_set_drvdata(dev, fep->mii_bus);
> +
> +	if (mdiobus_register(fep->mii_bus))
> +		goto err_out_free_mdio_irq;
> +
> +	if (fec_enet_mii_probe(dev) != 0)
> +		goto err_out_unregister_bus;
> +
> +	return 0;
> +
> +err_out_unregister_bus:
> +	mdiobus_unregister(fep->mii_bus);
> +err_out_free_mdio_irq:
> +	kfree(fep->mii_bus->irq);
> +err_out_free_mdiobus:
> +	mdiobus_free(fep->mii_bus);
> +err_out:
> +	return err;
> +}
> +
> +static void fec_enet_mii_remove(struct fec_enet_private *fep)
> +{
> +	if (fep->phy_dev)
> +		phy_disconnect(fep->phy_dev);
> +	mdiobus_unregister(fep->mii_bus);
> +	kfree(fep->mii_bus->irq);
> +	mdiobus_free(fep->mii_bus);
> +}
> +
> +
> +static int fec_enet_get_settings(struct net_device *dev,
> +				  struct ethtool_cmd *cmd)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phydev = fep->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_ethtool_gset(phydev, cmd);
> +}
> +
> +static int fec_enet_set_settings(struct net_device *dev,
> +				 struct ethtool_cmd *cmd)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phydev = fep->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_ethtool_sset(phydev, cmd);
> +}
> +
> +static void fec_enet_get_drvinfo(struct net_device *dev,
> +				 struct ethtool_drvinfo *info)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +
> +	strcpy(info->driver, fep->pdev->dev.driver->name);
> +	strcpy(info->version, "Revision: 1.0");
> +	strcpy(info->bus_info, fep->pdev->dev.bus_id);
> +}
> +
> +static struct ethtool_ops fec_enet_ethtool_ops = {
> +	.get_settings		= fec_enet_get_settings,
> +	.set_settings		= fec_enet_set_settings,
> +	.get_drvinfo		= fec_enet_get_drvinfo,
> +	.get_link		= ethtool_op_get_link,
> +};
> +
> +static int fec_enet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phydev = fep->phy_dev;
> +
> +	if (!netif_running(dev))
> +		return -EINVAL;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
> +}
> +#endif /* FEC_LEGACY */
>  
>  static int
>  fec_enet_open(struct net_device *dev)
> @@ -1965,9 +2275,10 @@ fec_enet_open(struct net_device *dev)
>  	 */
>  	fec_set_mac_address(dev);
>  
> -	fep->sequence_done = 0;
>  	fep->link = 0;
>  
> +#ifdef FEC_LEGACY
> +	fep->sequence_done = 0;
>  	if (fep->phy) {
>  		mii_do_cmd(dev, fep->phy->ack_int);
>  		mii_do_cmd(dev, fep->phy->config);
> @@ -1996,6 +2307,10 @@ fec_enet_open(struct net_device *dev)
>  		fec_restart(dev, 1);
>  	}
>  
> +#else
> +	/* schedule a link state check */
> +	phy_start(fep->phy_dev);
> +#endif
>  	netif_start_queue(dev);
>  	fep->opened = 1;
>  	return 0;		/* Success */
> @@ -2009,6 +2324,9 @@ fec_enet_close(struct net_device *dev)
>  	/* Don't know what to do yet.
>  	*/
>  	fep->opened = 0;
> +#ifndef FEC_LEGACY
> +	phy_stop(fep->phy_dev);
> +#endif
>  	netif_stop_queue(dev);
>  	fec_stop(dev);
>  
> @@ -2134,7 +2452,9 @@ int __init fec_enet_init(struct net_device *dev, int index)
>  	}
>  
>  	spin_lock_init(&fep->hw_lock);
> +#ifdef FEC_LEGACY
>  	spin_lock_init(&fep->mii_lock);
> +#endif
>  
>  	/* Create an Ethernet device instance.
>  	*/
> @@ -2258,28 +2578,28 @@ int __init fec_enet_init(struct net_device *dev, int index)
>  	dev->stop = fec_enet_close;
>  	dev->set_multicast_list = set_multicast_list;
>  
> +#ifdef FEC_LEGACY
>  	for (i=0; i<NMII-1; i++)
>  		mii_cmds[i].mii_next = &mii_cmds[i+1];
>  	mii_free = mii_cmds;
>  
>  	/* setup MII interface */
> -#ifdef FEC_LEGACY
>  	fec_set_mii(dev, fep);
>  #else
> +	dev->do_ioctl = fec_enet_ioctl;
> +	dev->ethtool_ops = &fec_enet_ethtool_ops;
> +
>  	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
>  	fecp->fec_x_cntrl = 0x00;
> +#endif
>  
> -	/*
> -	 * Set MII speed to 2.5 MHz
> -	 */
> -	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
> -					/ 2500000) / 2) & 0x3F) << 1;
> -	fecp->fec_mii_speed = fep->phy_speed;
> +#ifdef FEC_LEGACY
>  	fec_restart(dev, 0);
>  #endif
>  
>  	/* Clear and enable interrupts */
>  	fecp->fec_ievent = 0xffc00000;
> +#ifdef FEC_LEGACY
>  	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
>  
>  	/* Queue up command to detect the PHY and initialize the
> @@ -2288,6 +2608,9 @@ int __init fec_enet_init(struct net_device *dev, int index)
>  	fep->phy_id_done = 0;
>  	fep->phy_addr = 0;
>  	mii_queue(dev, mk_mii_read(MII_REG_PHYIR1), mii_discover_phy);
> +#else
> +	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF);
> +#endif
>  
>  	return 0;
>  }
> @@ -2314,7 +2637,7 @@ fec_restart(struct net_device *dev, int duplex)
>  
>  	/* Clear any outstanding interrupt.
>  	*/
> -	fecp->fec_ievent = 0xffc00000;
> +	fecp->fec_ievent = 0xffc00000 & ~FEC_ENET_MII;
>  
>  	/* Set station address.
>  	*/
> @@ -2403,7 +2726,11 @@ fec_restart(struct net_device *dev, int duplex)
>  
>  	/* Enable interrupts we wish to service.
>  	*/
> +#ifdef FEC_LEGACY
>  	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
> +#else
> +	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF);
> +#endif
>  }
>  
>  static void
> @@ -2435,7 +2762,11 @@ fec_stop(struct net_device *dev)
>  	*/
>  	fecp->fec_ievent = FEC_ENET_MII;
>  
> +#ifdef FEC_LEGACY
>  	fecp->fec_imask = FEC_ENET_MII;
> +#else
> +	fecp->fec_imask = 0;
> +#endif
>  	fecp->fec_mii_speed = fep->phy_speed;
>  }
>  
> @@ -2497,6 +2828,7 @@ fec_probe(struct platform_device *pdev)
>  	memset(fep, 0, sizeof(*fep));
>  
>  	ndev->base_addr = (unsigned long)ioremap(r->start, resource_size(r));
> +	fep->pdev = pdev;
>  
>  	if (!ndev->base_addr) {
>  		ret = -ENOMEM;
> @@ -2532,13 +2864,24 @@ fec_probe(struct platform_device *pdev)
>  	if (ret)
>  		goto failed_init;
>  
> +	ret = fec_enet_mii_init(pdev);
> +	if (ret)
> +		goto failed_mii_init;
> +
>  	ret = register_netdev(ndev);
>  	if (ret)
>  		goto failed_register;
>  
> +	printk(KERN_INFO "%s: Freescale FEC PHY driver [%s] "
> +	       "(mii_bus:phy_addr=%s, irq=%d)\n", ndev->name,
> +	       fep->phy_dev->drv->name, fep->phy_dev->dev.bus_id,
> +	       fep->phy_dev->irq);
> +
>  	return 0;
>  
>  failed_register:
> +	fec_enet_mii_remove(fep);
> +failed_mii_init:
>  failed_init:
>  	clk_disable(fep->clk);
>  	clk_put(fep->clk);
> @@ -2565,6 +2908,7 @@ fec_drv_remove(struct platform_device *pdev)
>  	platform_set_drvdata(pdev, NULL);
>  
>  	fec_stop(ndev);
> +	fec_enet_mii_remove(fep);
>  	clk_disable(fep->clk);
>  	clk_put(fep->clk);
>  	iounmap((void __iomem *)ndev->base_addr);
> 
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
