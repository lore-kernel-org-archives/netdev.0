From: Ray Jui <ray.jui@broadcom.com>
Subject: Re: [RFC 5/7] net: ethernet: bgmac: Add platform device support
Date: Thu, 30 Jun 2016 10:58:31 -0700
Message-ID: <65b8801d-b066-0179-273c-647c51a5ec8f@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-6-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35654 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbcF3R6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:58:43 -0400
Received: by mail-pa0-f45.google.com with SMTP id hl6so30467670pac.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:58:42 -0700 (PDT)
In-Reply-To: <1467142484-11161-6-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jon,

On 6/28/2016 12:34 PM, Jon Mason wrote:
> The bcma portion of the driver has been split off into a bcma specifi=
c
> driver.  This has been mirrored for the platform driver.  The last
> references to the bcma core struct have been changed into a generic
> function call.  These function calls are wrappers to either the origi=
nal
> bcma code or new platform functions that access the same areas via MM=
IO.
> This necessitated adding function pointers for both platform and bcma=
 to
> hide which backend is being used from the generic bgmac code.
>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/Kconfig          |  23 +-
>  drivers/net/ethernet/broadcom/Makefile         |   4 +-
>  drivers/net/ethernet/broadcom/bgmac-bcma.c     | 315 +++++++++++++++=
+++++++++
>  drivers/net/ethernet/broadcom/bgmac-platform.c | 208 +++++++++++++++=
+
>  drivers/net/ethernet/broadcom/bgmac.c          | 327 ++++-----------=
----------
>  drivers/net/ethernet/broadcom/bgmac.h          |  73 +++++-
>  6 files changed, 666 insertions(+), 284 deletions(-)
>  create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma.c
>  create mode 100644 drivers/net/ethernet/broadcom/bgmac-platform.c
>
> diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethe=
rnet/broadcom/Kconfig
> index d74a92e..bd8c80c 100644
> --- a/drivers/net/ethernet/broadcom/Kconfig
> +++ b/drivers/net/ethernet/broadcom/Kconfig
> @@ -140,10 +140,18 @@ config BNX2X_SRIOV
>  	  allows for virtual function acceleration in virtual environments.
>
>  config BGMAC
> -	tristate "BCMA bus GBit core support"
> +	tristate
> +	help
> +	  This enables the integrated ethernet controller support for many
> +	  Broadcom (mostly iProc) SoCs. An appropriate bus interface driver
> +	  needs to be enabled to select this.
> +
> +config BGMAC_BCMA
> +	tristate "Broadcom iProc GBit BCMA support"
>  	depends on BCMA && BCMA_HOST_SOC
>  	depends on HAS_DMA
>  	depends on BCM47XX || ARCH_BCM_5301X || COMPILE_TEST
> +	select BGMAC
>  	select PHYLIB
>  	select FIXED_PHY
>  	---help---
> @@ -152,6 +160,19 @@ config BGMAC
>  	  In case of using this driver on BCM4706 it's also requires to ena=
ble
>  	  BCMA_DRIVER_GMAC_CMN to make it work.
>
> +config BGMAC_PLATFORM
> +	tristate "Broadcom iProc GBit platform support"
> +	depends on HAS_DMA
> +	depends on ARCH_BCM_IPROC || COMPILE_TEST
> +	depends on OF
> +	select BGMAC
> +	select PHYLIB
> +	select FIXED_PHY
> +	default ARCH_BCM_IPROC
> +	---help---
> +	  Say Y here if you want to use the Broadcom iProc Gigabit Ethernet
> +	  controller through the generic platform interface
> +
>  config SYSTEMPORT
>  	tristate "Broadcom SYSTEMPORT internal MAC support"
>  	depends on OF
> diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/eth=
ernet/broadcom/Makefile
> index f559794..79f2372 100644
> --- a/drivers/net/ethernet/broadcom/Makefile
> +++ b/drivers/net/ethernet/broadcom/Makefile
> @@ -10,6 +10,8 @@ obj-$(CONFIG_CNIC) +=3D cnic.o
>  obj-$(CONFIG_BNX2X) +=3D bnx2x/
>  obj-$(CONFIG_SB1250_MAC) +=3D sb1250-mac.o
>  obj-$(CONFIG_TIGON3) +=3D tg3.o
> -obj-$(CONFIG_BGMAC) +=3D bgmac.o bgmac-bcma-mdio.o
> +obj-$(CONFIG_BGMAC) +=3D bgmac.o
> +obj-$(CONFIG_BGMAC_BCMA) +=3D bgmac-bcma.o bgmac-bcma-mdio.o
> +obj-$(CONFIG_BGMAC_PLATFORM) +=3D bgmac-platform.o
>  obj-$(CONFIG_SYSTEMPORT) +=3D bcmsysport.o
>  obj-$(CONFIG_BNXT) +=3D bnxt/
> diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net=
/ethernet/broadcom/bgmac-bcma.c
> new file mode 100644
> index 0000000..9a9745c4
> --- /dev/null
> +++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
> @@ -0,0 +1,315 @@
> +/*
> + * Driver for (BCM4706)? GBit MAC core on BCMA bus.
> + *
> + * Copyright (C) 2012 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> + *
> + * Licensed under the GNU/GPL. See COPYING for details.
> + */
> +
> +#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
> +
> +#include <linux/bcma/bcma.h>
> +#include <linux/brcmphy.h>
> +#include <linux/etherdevice.h>
> +#include "bgmac.h"
> +
> +static inline bool bgmac_is_bcm4707_family(struct bcma_device *core)
> +{
> +	switch (core->bus->chipinfo.id) {
> +	case BCMA_CHIP_ID_BCM4707:
> +	case BCMA_CHIP_ID_BCM47094:
> +	case BCMA_CHIP_ID_BCM53018:
> +		return true;
> +	default:
> +		return false;
> +	}
> +}
> +
> +/**************************************************
> + * BCMA bus ops
> + **************************************************/
> +
> +static u32 bcma_bgmac_read(struct bgmac *bgmac, u16 offset)
> +{
> +	return bcma_read32(bgmac->bcma.core, offset);
> +}
> +
> +static void bcma_bgmac_write(struct bgmac *bgmac, u16 offset, u32 va=
lue)
> +{
> +	bcma_write32(bgmac->bcma.core, offset, value);
> +}
> +
> +static u32 bcma_bgmac_idm_read(struct bgmac *bgmac, u16 offset)
> +{
> +	return bcma_aread32(bgmac->bcma.core, offset);
> +}
> +
> +static void bcma_bgmac_idm_write(struct bgmac *bgmac, u16 offset, u3=
2 value)
> +{
> +	return bcma_awrite32(bgmac->bcma.core, offset, value);
> +}
> +
> +static bool bcma_bgmac_clk_enabled(struct bgmac *bgmac)
> +{
> +	return bcma_core_is_enabled(bgmac->bcma.core);
> +}
> +
> +static void bcma_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
> +{
> +	bcma_core_enable(bgmac->bcma.core, flags);
> +}
> +
> +static void bcma_bgmac_cco_ctl_maskset(struct bgmac *bgmac, u32 offs=
et,
> +				       u32 mask, u32 set)
> +{
> +	struct bcma_drv_cc *cc =3D &bgmac->bcma.core->bus->drv_cc;
> +
> +	bcma_chipco_chipctl_maskset(cc, offset, mask, set);
> +}
> +
> +static u32 bcma_bgmac_get_bus_clock(struct bgmac *bgmac)
> +{
> +	struct bcma_drv_cc *cc =3D &bgmac->bcma.core->bus->drv_cc;
> +
> +	return bcma_pmu_get_bus_clock(cc);
> +}
> +
> +static void bcma_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset=
, u32 mask,
> +				     u32 set)
> +{
> +	bcma_maskset32(bgmac->bcma.cmn, offset, mask, set);
> +}
> +
> +static const struct bcma_device_id bgmac_bcma_tbl[] =3D {
> +	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT,
> +		  BCMA_ANY_REV, BCMA_ANY_CLASS),
> +	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV,
> +		  BCMA_ANY_CLASS),
> +	{},
> +};
> +MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
> +
> +/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
> +static int bgmac_probe(struct bcma_device *core)
> +{
> +	struct ssb_sprom *sprom =3D &core->bus->sprom;
> +	struct mii_bus *mii_bus;
> +	struct bgmac *bgmac;
> +	u8 *mac;
> +	int err;
> +
> +	bgmac =3D kzalloc(sizeof(*bgmac), GFP_KERNEL);
> +	if (!bgmac)
> +		return -ENOMEM;
> +
> +	bgmac->bcma.core =3D core;
> +	bgmac->dev =3D &core->dev;
> +	bgmac->dma_dev =3D core->dma_dev;
> +	bgmac->irq =3D core->irq;
> +
> +	bcma_set_drvdata(core, bgmac);
> +
> +	switch (core->core_unit) {
> +	case 0:
> +		mac =3D sprom->et0mac;
> +		break;
> +	case 1:
> +		mac =3D sprom->et1mac;
> +		break;
> +	case 2:
> +		mac =3D sprom->et2mac;
> +		break;
> +	default:
> +		dev_err(bgmac->dev, "Unsupported core_unit %d\n",
> +			core->core_unit);
> +		err =3D -ENOTSUPP;
> +		goto err;
> +	}
> +
> +	ether_addr_copy(bgmac->mac_addr, mac);
> +
> +	/* On BCM4706 we need common core to access PHY */
> +	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT &&
> +	    !core->bus->drv_gmac_cmn.core) {
> +		dev_err(bgmac->dev, "GMAC CMN core not found (required for BCM4706=
)\n");
> +		err =3D -ENODEV;
> +		goto err;
> +	}
> +	bgmac->bcma.cmn =3D core->bus->drv_gmac_cmn.core;
> +
> +	switch (core->core_unit) {
> +	case 0:
> +		bgmac->phyaddr =3D sprom->et0phyaddr;
> +		break;
> +	case 1:
> +		bgmac->phyaddr =3D sprom->et1phyaddr;
> +		break;
> +	case 2:
> +		bgmac->phyaddr =3D sprom->et2phyaddr;
> +		break;
> +	}
> +	bgmac->phyaddr &=3D BGMAC_PHY_MASK;
> +	if (bgmac->phyaddr =3D=3D BGMAC_PHY_MASK) {
> +		dev_err(bgmac->dev, "No PHY found\n");
> +		err =3D -ENODEV;
> +		goto err;
> +	}
> +	dev_info(bgmac->dev, "Found PHY addr: %d%s\n", bgmac->phyaddr,
> +		 bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS ? " (NOREGS)" : "");
> +
> +	if (!bgmac_is_bcm4707_family(core)) {
> +		mii_bus =3D bcma_mdio_mii_register(core, bgmac->phyaddr);
> +		if (!IS_ERR(mii_bus)) {
> +			err =3D PTR_ERR(mii_bus);
> +			goto err;
> +		}
> +
> +		bgmac->mii_bus =3D mii_bus;
> +	}
> +
> +	if (core->bus->hosttype =3D=3D BCMA_HOSTTYPE_PCI) {
> +		dev_err(bgmac->dev, "PCI setup not implemented\n");
> +		err =3D -ENOTSUPP;
> +		goto err1;
> +	}
> +
> +	bgmac->has_robosw =3D !!(core->bus->sprom.boardflags_lo &
> +			       BGMAC_BFL_ENETROBO);
> +	if (bgmac->has_robosw)
> +		dev_warn(bgmac->dev, "Support for Roboswitch not implemented\n");
> +
> +	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
> +		dev_warn(bgmac->dev, "Support for ADMtek ethernet switch not imple=
mented\n");
> +
> +	/* Feature Flags */
> +	switch (core->bus->chipinfo.id) {
> +	case BCMA_CHIP_ID_BCM5357:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
> +		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47186) {
> +			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
> +			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
> +		}
> +		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM5358)
> +			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_EPHYRMII;
> +		break;
> +	case BCMA_CHIP_ID_BCM53572:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
> +		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47188) {
> +			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
> +			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
> +		}
> +		break;
> +	case BCMA_CHIP_ID_BCM4749:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
> +		if (core->bus->chipinfo.pkg =3D=3D 10) {
> +			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
> +			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
> +		}
> +		break;
> +	case BCMA_CHIP_ID_BCM4716:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		/* fallthrough */
> +	case BCMA_CHIP_ID_BCM47162:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL2;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
> +		break;
> +	/* bcm4707_family */
> +	case BCMA_CHIP_ID_BCM4707:
> +	case BCMA_CHIP_ID_BCM47094:
> +	case BCMA_CHIP_ID_BCM53018:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_NO_RESET;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_FORCE_SPEED_2500;
> +		break;
> +	default:
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
> +	}
> +
> +	if (!bgmac_is_bcm4707_family(core) && core->id.rev > 2)
> +		bgmac->feature_flags |=3D BGMAC_FEAT_MISC_PLL_REQ;
> +
> +	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CMN_PHY_CTL;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_NO_CLR_MIB;
> +	}
> +
> +	if (core->id.rev >=3D 4) {
> +		bgmac->feature_flags |=3D BGMAC_FEAT_CMDCFG_SR_REV4;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_TX_MASK_SETUP;
> +		bgmac->feature_flags |=3D BGMAC_FEAT_RX_MASK_SETUP;
> +	}
> +
> +	bgmac->read =3D bcma_bgmac_read;
> +	bgmac->write =3D bcma_bgmac_write;
> +	bgmac->idm_read =3D bcma_bgmac_idm_read;
> +	bgmac->idm_write =3D bcma_bgmac_idm_write;
> +	bgmac->clk_enabled =3D bcma_bgmac_clk_enabled;
> +	bgmac->clk_enable =3D bcma_bgmac_clk_enable;
> +	bgmac->cco_ctl_maskset =3D bcma_bgmac_cco_ctl_maskset;
> +	bgmac->get_bus_clock =3D bcma_bgmac_get_bus_clock;
> +	bgmac->cmn_maskset32 =3D bcma_bgmac_cmn_maskset32;
> +
> +	err =3D bgmac_enet_probe(bgmac);
> +	if (err)
> +		goto err1;
> +
> +	return 0;
> +
> +err1:
> +	bcma_mdio_mii_unregister(bgmac->mii_bus);
> +err:
> +	kfree(bgmac);
> +	bcma_set_drvdata(core, NULL);
> +
> +	return err;
> +}
> +
> +static void bgmac_remove(struct bcma_device *core)
> +{
> +	struct bgmac *bgmac =3D bcma_get_drvdata(core);
> +
> +	bcma_mdio_mii_unregister(bgmac->mii_bus);
> +	bgmac_enet_remove(bgmac);
> +	bcma_set_drvdata(core, NULL);
> +	kfree(bgmac);
> +}
> +
> +static struct bcma_driver bgmac_bcma_driver =3D {
> +	.name		=3D KBUILD_MODNAME,
> +	.id_table	=3D bgmac_bcma_tbl,
> +	.probe		=3D bgmac_probe,
> +	.remove		=3D bgmac_remove,
> +};
> +
> +static int __init bgmac_init(void)
> +{
> +	int err;
> +
> +	err =3D bcma_driver_register(&bgmac_bcma_driver);
> +	if (err)
> +		return err;
> +	pr_info("Broadcom 47xx GBit MAC driver loaded\n");
> +
> +	return 0;
> +}
> +
> +static void __exit bgmac_exit(void)
> +{
> +	bcma_driver_unregister(&bgmac_bcma_driver);
> +}
> +
> +module_init(bgmac_init)
> +module_exit(bgmac_exit)
> +
> +MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers=
/net/ethernet/broadcom/bgmac-platform.c
> new file mode 100644
> index 0000000..fac93c0
> --- /dev/null
> +++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
> @@ -0,0 +1,208 @@
> +/*
> + * Copyright (C) 2016 Broadcom
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warran=
ty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
> +
> +#include <linux/bcma/bcma.h>
> +#include <linux/etherdevice.h>
> +#include <linux/of_address.h>
> +#include <linux/of_net.h>
> +#include "bgmac.h"
> +
> +static u32 platform_bgmac_read(struct bgmac *bgmac, u16 offset)
> +{
> +	return readl(bgmac->plat.base + offset);
> +}
> +
> +static void platform_bgmac_write(struct bgmac *bgmac, u16 offset, u3=
2 value)
> +{
> +	writel(value, bgmac->plat.base + offset);
> +}
> +
> +static u32 platform_bgmac_idm_read(struct bgmac *bgmac, u16 offset)
> +{
> +	return readl(bgmac->plat.idm_base + offset);
> +}
> +
> +static void platform_bgmac_idm_write(struct bgmac *bgmac, u16 offset=
, u32 value)
> +{
> +	return writel(value, bgmac->plat.idm_base + offset);
> +}
> +
> +static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
> +{
> +	if ((bgmac_idm_read(bgmac, BCMA_IOCTL) &
> +	     (BCMA_IOCTL_CLK | BCMA_IOCTL_FGC)) !=3D BCMA_IOCTL_CLK)
> +		return false;
> +	if (bgmac_idm_read(bgmac, BCMA_RESET_CTL) & BCMA_RESET_CTL_RESET)
> +		return false;
> +	return true;
> +}
> +
> +static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags=
)
> +{
> +	bgmac_idm_write(bgmac, BCMA_IOCTL,
> +			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
> +	bgmac_idm_read(bgmac, BCMA_IOCTL);
> +
> +	bgmac_idm_write(bgmac, BCMA_RESET_CTL, 0);
> +	bgmac_idm_read(bgmac, BCMA_RESET_CTL);
> +	udelay(1);
> +
> +	bgmac_idm_write(bgmac, BCMA_IOCTL, (BCMA_IOCTL_CLK | flags));
> +	bgmac_idm_read(bgmac, BCMA_IOCTL);
> +	udelay(1);
> +}
> +
> +static void platform_bgmac_cco_ctl_maskset(struct bgmac *bgmac, u32 =
offset,
> +					   u32 mask, u32 set)
> +{
> +	/* This shouldn't be encountered */
> +	WARN_ON(1);
> +}
> +
> +static u32 platform_bgmac_get_bus_clock(struct bgmac *bgmac)
> +{
> +	/* This shouldn't be encountered */
> +	WARN_ON(1);
> +
> +	return 0;
> +}
> +
> +static void platform_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 of=
fset,
> +					 u32 mask, u32 set)
> +{
> +	/* This shouldn't be encountered */
> +	WARN_ON(1);
> +}
> +
> +static int bgmac_probe(struct platform_device *pdev)
> +{
> +	struct device_node *np =3D pdev->dev.of_node;
> +	struct bgmac *bgmac;
> +	struct resource regs;
> +	const u8 *mac_addr;
> +	int rc;
> +
> +	bgmac =3D kzalloc(sizeof(*bgmac), GFP_KERNEL);

The trend has been using devm_xxx based API to let the devm framework=20
deals with device resource management. This will help to reduce all the=
=20
code that is currently needed to free the resource below and in the=20
remove function.

> +	if (!bgmac)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, bgmac);
> +
> +	/* Set the features of the 4707 family */
> +	bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
> +	bgmac->feature_flags |=3D BGMAC_FEAT_NO_RESET;
> +	bgmac->feature_flags |=3D BGMAC_FEAT_FORCE_SPEED_2500;
> +	bgmac->feature_flags |=3D BGMAC_FEAT_CMDCFG_SR_REV4;
> +	bgmac->feature_flags |=3D BGMAC_FEAT_TX_MASK_SETUP;
> +	bgmac->feature_flags |=3D BGMAC_FEAT_RX_MASK_SETUP;
> +
> +	bgmac->dev =3D &pdev->dev;
> +	bgmac->dma_dev =3D &pdev->dev;
> +
> +	mac_addr =3D of_get_mac_address(np);
> +	if (mac_addr)
> +		ether_addr_copy(bgmac->mac_addr, mac_addr);
> +	else
> +		dev_warn(&pdev->dev, "MAC address not present in device tree\n");
> +
> +	bgmac->irq =3D platform_get_irq(pdev, 0);

> +	if (bgmac->irq < 0) {
> +		rc =3D bgmac->irq;
> +		dev_err(&pdev->dev, "Unable to obtain IRQ\n");
> +		goto err;
> +	}
> +
> +	rc =3D of_address_to_resource(np, 0, &regs);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Unable to obtain base resource\n");
> +		goto err;
> +	}
> +
> +	bgmac->plat.base =3D ioremap(regs.start, resource_size(&regs));

Again, there's devm based API to use, and the resource should be marked=
=20
reserved so no one else can remap it.

platform_get_resource
devm_ioremap_resource

> +	if (!bgmac->plat.base) {
> +		dev_err(&pdev->dev, "Unable to map base resource\n");
> +		rc =3D -ENOMEM;
> +		goto err;
> +	}
> +
> +	rc =3D of_address_to_resource(np, 1, &regs);
> +	if (rc < 0) {
> +		dev_err(&pdev->dev, "Unable to obtain idm resource\n");
> +		goto err1;
> +	}
> +
> +	bgmac->plat.idm_base =3D ioremap(regs.start, resource_size(&regs));
> +	if (!bgmac->plat.base) {
> +		dev_err(&pdev->dev, "Unable to map idm resource\n");
> +		rc =3D -ENOMEM;
> +		goto err1;
> +	}

same here

> +
> +	bgmac->read =3D platform_bgmac_read;
> +	bgmac->write =3D platform_bgmac_write;
> +	bgmac->idm_read =3D platform_bgmac_idm_read;
> +	bgmac->idm_write =3D platform_bgmac_idm_write;
> +	bgmac->clk_enabled =3D platform_bgmac_clk_enabled;
> +	bgmac->clk_enable =3D platform_bgmac_clk_enable;
> +	bgmac->cco_ctl_maskset =3D platform_bgmac_cco_ctl_maskset;
> +	bgmac->get_bus_clock =3D platform_bgmac_get_bus_clock;
> +	bgmac->cmn_maskset32 =3D platform_bgmac_cmn_maskset32;
> +
> +	rc =3D bgmac_enet_probe(bgmac);
> +	if (rc)
> +		goto err2;
> +
> +	return 0;
> +
> +err2:
> +	iounmap(bgmac->plat.idm_base);
> +err1:
> +	iounmap(bgmac->plat.base);
> +err:
> +	kfree(bgmac);

All of the above error handling code can be gone.

> +
> +	return rc;
> +}
> +
> +static int bgmac_remove(struct platform_device *pdev)
> +{
> +	struct bgmac *bgmac =3D platform_get_drvdata(pdev);
> +
> +	bgmac_enet_remove(bgmac);
> +	iounmap(bgmac->plat.idm_base);
> +	iounmap(bgmac->plat.base);
> +	kfree(bgmac);

Here too.

> +
> +	return 0;
> +}
> +
> +static const struct of_device_id bgmac_of_enet_match[] =3D {
> +	{.compatible =3D "brcm,bgmac-enet",},
> +	{},
> +};
> +
> +MODULE_DEVICE_TABLE(of, bgmac_of_enet_match);
> +
> +static struct platform_driver bgmac_enet_driver =3D {
> +	.driver =3D {
> +		.name  =3D "bgmac-enet",
> +		.of_match_table =3D bgmac_of_enet_match,
> +	},
> +	.probe =3D bgmac_probe,
> +	.remove =3D bgmac_remove,
> +};
> +
> +module_platform_driver(bgmac_enet_driver);
> +MODULE_LICENSE("GPL");

=2E..
=2E..

Thanks,

Ray
