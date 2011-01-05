From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v3 05/10] net/fec: add dual fec support for mx28
Date: Wed, 5 Jan 2011 17:34:49 +0100
Message-ID: <20110105163449.GU25121@pengutronix.de>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-6-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56702 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1AEQfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 11:35:19 -0500
Content-Disposition: inline
In-Reply-To: <1294236457-17476-6-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Jan 05, 2011 at 10:07:32PM +0800, Shawn Guo wrote:
> This patch is to add mx28 dual fec support. Here are some key notes
> for mx28 fec controller.
>=20
>  - The mx28 fec controller naming ENET-MAC is a different IP from FEC
>    used on other i.mx variants.  But they are basically compatible
>    on software interface, so it's possible to share the same driver.
>  - ENET-MAC design made an improper assumption that it runs on a
>    big-endian system. As the result, driver has to swap every frame
>    going to and coming from the controller.
>  - The external phys can only be configured by fec0, which means fec1
>    can not work independently and both phys need to be configured by
>    mii_bus attached on fec0.
>  - ENET-MAC reset will get mac address registers reset too.
>  - ENET-MAC MII/RMII mode and 10M/100M speed are configured
>    differently FEC.
>  - ETHER_EN bit must be set to get ENET-MAC interrupt work.
>=20
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v3:
>  - Move v2 changes into patch #3
>  - Use device name to check if it's running on ENET-MAC
>=20
>  drivers/net/Kconfig |    7 ++-
>  drivers/net/fec.c   |  140 +++++++++++++++++++++++++++++++++++++++++=
++++------
>  drivers/net/fec.h   |    5 +-
>  3 files changed, 131 insertions(+), 21 deletions(-)
>=20
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4f1755b..f34629b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1944,18 +1944,19 @@ config 68360_ENET
>  config FEC
>  	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
>  	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
> -		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5
> +		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5 || SOC_IMX28
>  	select PHYLIB
>  	help
>  	  Say Y here if you want to use the built-in 10/100 Fast ethernet
>  	  controller on some Motorola ColdFire and Freescale i.MX processor=
s.
> =20
>  config FEC2
> -	bool "Second FEC ethernet controller (on some ColdFire CPUs)"
> +	bool "Second FEC ethernet controller"
>  	depends on FEC
>  	help
>  	  Say Y here if you want to use the second built-in 10/100 Fast
> -	  ethernet controller on some Motorola ColdFire processors.
> +	  ethernet controller on some Motorola ColdFire and Freescale
> +	  i.MX processors.
> =20
>  config FEC_MPC52xx
>  	tristate "MPC52xx FEC driver"
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 8a1c51f..67ba263 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -17,6 +17,8 @@
>   *
>   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
>   * Copyright (c) 2004-2006 Macq Electronique SA.
> + *
> + * Copyright (C) 2010 Freescale Semiconductor, Inc.
>   */
> =20
>  #include <linux/module.h>
> @@ -45,20 +47,33 @@
> =20
>  #include <asm/cacheflush.h>
> =20
> -#ifndef CONFIG_ARCH_MXC
> +#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
maybe !defined(CONFIG_ARM)?

>  #include <asm/coldfire.h>
>  #include <asm/mcfsim.h>
>  #endif
> =20
>  #include "fec.h"
> =20
> -#ifdef CONFIG_ARCH_MXC
> -#include <mach/hardware.h>
> +#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
>  #define FEC_ALIGNMENT	0xf
>  #else
>  #define FEC_ALIGNMENT	0x3
>  #endif
> =20
> +#define DRIVER_NAME	"fec"
> +#define ENET_MAC_NAME	"enet-mac"
> +
> +static struct platform_device_id fec_devtype[] =3D {
> +	{
> +		.name =3D DRIVER_NAME,
> +	}, {
> +		.name =3D ENET_MAC_NAME,
> +	}
I'd done it differently:

	{
		.name =3D "fec",
		.driver_data =3D 0,
	}, {
		.name =3D "imx28-fec",
		.driver_data =3D HAS_ENET_MAC | ...,
	}

and then test the bits in driver_data (which you get using
platform_get_device_id() when you need to distinguish.
Comparing names doesn't scale, assume there are three further features
to distinguish, then you need to use strtok or index and get device
names like enet-mac-with-feature1-but-without-feature2-and-feature3.

> +};
> +
> +static unsigned fec_is_enetmac;
> +static struct mii_bus *fec_mii_bus;
In practice this might work, but actually these are per-device
properties, not driver-global.  So it should go into the private data
struct.

> +
>  static unsigned char macaddr[ETH_ALEN];
>  module_param_array(macaddr, byte, NULL, 0);
>  MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> @@ -129,7 +144,8 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC addre=
ss");
>   * account when setting it.
>   */
>  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG=
_M528x) || \
> -    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG=
_ARCH_MXC)
> +    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
> +    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
>  #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
>  #else
>  #define	OPT_FRAME_SIZE	0
> @@ -208,6 +224,17 @@ static void fec_stop(struct net_device *dev);
>  /* Transmitter timeout */
>  #define TX_TIMEOUT (2 * HZ)
> =20
> +static void *swap_buffer(void *bufaddr, int len)
> +{
> +	int i;
> +	unsigned int *buf =3D bufaddr;
> +
> +	for (i =3D 0; i < (len + 3) / 4; i++, buf++)
> +		*buf =3D __swab32(*buf);
Would it better to use cpu_to_be32 here?  Then the compiler might
be smart enough to optimize it away on BE.  (Currently the code
generated for a BE build would be wrong with your patch, wouldn't it?)
> +
> +	return bufaddr;
> +}
> +
>  static netdev_tx_t
>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> @@ -256,6 +283,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *dev)
>  		bufaddr =3D fep->tx_bounce[index];
>  	}
> =20
> +	/*
> +	 * enet-mac design made an improper assumption that it's running
> +	 * on a big endian system. As the result, driver has to swap
if he was really aware that he limits the performant use of the fec to
big endian systems, can you please make him stop designing hardware!?

> +	 * every frame going to and coming from the controller.
> +	 */
> +	if (fec_is_enetmac)
> +		swap_buffer(bufaddr, skb->len);
> +
>  	/* Save skb pointer */
>  	fep->tx_skbuff[fep->skb_cur] =3D skb;
> =20
> @@ -487,6 +522,9 @@ fec_enet_rx(struct net_device *dev)
>  	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
>          			DMA_FROM_DEVICE);
> =20
> +		if (fec_is_enetmac)
> +			swap_buffer(data, pkt_len);
> +
>  		/* This does 16 byte alignment, exactly what we need.
>  		 * The packet length includes FCS, but we don't want to
>  		 * include that when passing upstream as it messes up
> @@ -689,6 +727,7 @@ static int fec_enet_mii_probe(struct net_device *=
dev)
>  	char mdio_bus_id[MII_BUS_ID_SIZE];
>  	char phy_name[MII_BUS_ID_SIZE + 3];
>  	int phy_id;
> +	int dev_id =3D fep->pdev->id;
> =20
>  	fep->phy_dev =3D NULL;
> =20
> @@ -700,6 +739,8 @@ static int fec_enet_mii_probe(struct net_device *=
dev)
>  			continue;
>  		if (fep->mii_bus->phy_map[phy_id]->phy_id =3D=3D 0)
>  			continue;
> +		if (fec_is_enetmac && dev_id--)
> +			continue;
>  		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
>  		break;
>  	}
> @@ -741,6 +782,28 @@ static int fec_enet_mii_init(struct platform_dev=
ice *pdev)
>  	struct fec_enet_private *fep =3D netdev_priv(dev);
>  	int err =3D -ENXIO, i;
> =20
> +	/*
> +	 * The dual fec interfaces are not equivalent with enet-mac.
> +	 * Here are the differences:
> +	 *
> +	 *  - fec0 supports MII & RMII modes while fec1 only supports RMII
> +	 *  - fec0 acts as the 1588 time master while fec1 is slave
> +	 *  - external phys can only be configured by fec0
> +	 *
> +	 * That is to say fec1 can not work independently. It only works
> +	 * when fec0 is working. The reason behind this design is that the
> +	 * second interface is added primarily for Switch mode.
> +	 *
> +	 * Because of the last point above, both phys are attached on fec0
> +	 * mdio interface in board design, and need to be configured by
> +	 * fec0 mii_bus.
> +	 */
> +	if (fec_is_enetmac && pdev->id) {
> +		/* fec1 uses fec0 mii_bus */
> +		fep->mii_bus =3D fec_mii_bus;
> +		return 0;
> +	}
> +
>  	fep->mii_timeout =3D 0;
> =20
>  	/*
> @@ -777,6 +840,10 @@ static int fec_enet_mii_init(struct platform_dev=
ice *pdev)
>  	if (mdiobus_register(fep->mii_bus))
>  		goto err_out_free_mdio_irq;
> =20
> +	/* save fec0 mii_bus */
> +	if (fec_is_enetmac)
> +		fec_mii_bus =3D fep->mii_bus;
> +
>  	return 0;
> =20
>  err_out_free_mdio_irq:
> @@ -1149,11 +1216,22 @@ fec_restart(struct net_device *dev, int duple=
x)
>  {
>  	struct fec_enet_private *fep =3D netdev_priv(dev);
>  	int i;
> +	u32 val, temp_mac[2];
> =20
>  	/* Whack a reset.  We should wait for this. */
>  	writel(1, fep->hwp + FEC_ECNTRL);
>  	udelay(10);
> =20
> +	/*
> +	 * enet-mac reset will reset mac address registers too,
> +	 * so need to reconfigure it.
> +	 */
> +	if (fec_is_enetmac) {
> +		memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
> +		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
> +		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
where is the value saved to temp_mac[]?  For me it looks you write
uninitialized data into the mac registers.
> +	}
> +
>  	/* Clear any outstanding interrupt. */
>  	writel(0xffc00000, fep->hwp + FEC_IEVENT);
> =20
> @@ -1200,20 +1278,45 @@ fec_restart(struct net_device *dev, int duple=
x)
>  	/* Set MII speed */
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> =20
> -#ifdef FEC_MIIGSK_ENR
> -	if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII) {
> -		/* disable the gasket and wait */
> -		writel(0, fep->hwp + FEC_MIIGSK_ENR);
> -		while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
> -			udelay(1);
> +	/*
> +	 * The phy interface and speed need to get configured
> +	 * differently on enet-mac.
> +	 */
> +	if (fec_is_enetmac) {
> +		val =3D readl(fep->hwp + FEC_R_CNTRL);
> =20
> -		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
> -		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +		/* MII or RMII */
> +		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
> +			val |=3D (1 << 8);
> +		else
> +			val &=3D ~(1 << 8);
> =20
> -		/* re-enable the gasket */
> -		writel(2, fep->hwp + FEC_MIIGSK_ENR);
> -	}
> +		/* 10M or 100M */
> +		if (fep->phy_dev && fep->phy_dev->speed =3D=3D SPEED_100)
> +			val &=3D ~(1 << 9);
> +		else
> +			val |=3D (1 << 9);
> +
> +		writel(val, fep->hwp + FEC_R_CNTRL);
> +	} else {
> +#ifdef FEC_MIIGSK_ENR
> +		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII) {
> +			/* disable the gasket and wait */
> +			writel(0, fep->hwp + FEC_MIIGSK_ENR);
> +			while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
> +				udelay(1);
> +
> +			/*
> +			 * configure the gasket:
> +			 *   RMII, 50 MHz, no loopback, no echo
> +			 */
> +			writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +
> +			/* re-enable the gasket */
> +			writel(2, fep->hwp + FEC_MIIGSK_ENR);
> +		}
>  #endif
> +	}
> =20
>  	/* And last, enable the transmit and receive processing */
>  	writel(2, fep->hwp + FEC_ECNTRL);
> @@ -1301,6 +1404,10 @@ fec_probe(struct platform_device *pdev)
>  		}
>  	}
> =20
> +	/* check if it's ENET-MAC controller via device name */
> +	if (!strcmp(pdev->name, ENET_MAC_NAME))
> +		fec_is_enetmac =3D 1;
> +
>  	fep->clk =3D clk_get(&pdev->dev, "fec_clk");
>  	if (IS_ERR(fep->clk)) {
>  		ret =3D PTR_ERR(fep->clk);
> @@ -1410,12 +1517,13 @@ static const struct dev_pm_ops fec_pm_ops =3D=
 {
> =20
>  static struct platform_driver fec_driver =3D {
>  	.driver	=3D {
> -		.name	=3D "fec",
> +		.name	=3D DRIVER_NAME,
>  		.owner	=3D THIS_MODULE,
>  #ifdef CONFIG_PM
>  		.pm	=3D &fec_pm_ops,
>  #endif
>  	},
> +	.id_table =3D fec_devtype,
>  	.probe	=3D fec_probe,
>  	.remove	=3D __devexit_p(fec_drv_remove),
>  };
> diff --git a/drivers/net/fec.h b/drivers/net/fec.h
> index 2c48b25..ace318d 100644
> --- a/drivers/net/fec.h
> +++ b/drivers/net/fec.h
> @@ -14,7 +14,8 @@
>  /*******************************************************************=
*********/
> =20
>  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG=
_M528x) || \
> -    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG=
_ARCH_MXC)
> +    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
> +    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
>  /*
>   *	Just figures, Motorola would have to change the offsets for
>   *	registers in the same peripheral device on different models
> @@ -78,7 +79,7 @@
>  /*
>   *	Define the buffer descriptor structure.
>   */
> -#ifdef CONFIG_ARCH_MXC
> +#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
>  struct bufdesc {
>  	unsigned short cbd_datlen;	/* Data length */
>  	unsigned short cbd_sc;	/* Control and status info */
> --=20
> 1.7.1
>=20
>=20
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>=20

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
