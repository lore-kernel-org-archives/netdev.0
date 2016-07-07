From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v2 5/6] net: ethernet: bgmac: Add platform device support
Date: Thu,  7 Jul 2016 19:08:57 -0400
Message-ID: <1467932938-21819-6-git-send-email-jon.mason@broadcom.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bcma portion of the driver has been split off into a bcma specific
driver.  This has been mirrored for the platform driver.  The last
references to the bcma core struct have been changed into a generic
function call.  These function calls are wrappers to either the origina=
l
bcma code or new platform functions that access the same areas via MMIO=
=2E
This necessitated adding function pointers for both platform and bcma t=
o
hide which backend is being used from the generic bgmac code.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/Kconfig           |  23 +-
 drivers/net/ethernet/broadcom/Makefile          |   4 +-
 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c |   2 +
 drivers/net/ethernet/broadcom/bgmac-bcma.c      | 315 ++++++++++++++++=
+++++++
 drivers/net/ethernet/broadcom/bgmac-platform.c  | 189 ++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.c           | 329 ++++------------=
--------
 drivers/net/ethernet/broadcom/bgmac.h           |  73 +++++-
 7 files changed, 650 insertions(+), 285 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma.c
 create mode 100644 drivers/net/ethernet/broadcom/bgmac-platform.c

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethern=
et/broadcom/Kconfig
index d74a92e..bd8c80c 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -140,10 +140,18 @@ config BNX2X_SRIOV
 	  allows for virtual function acceleration in virtual environments.
=20
 config BGMAC
-	tristate "BCMA bus GBit core support"
+	tristate
+	help
+	  This enables the integrated ethernet controller support for many
+	  Broadcom (mostly iProc) SoCs. An appropriate bus interface driver
+	  needs to be enabled to select this.
+
+config BGMAC_BCMA
+	tristate "Broadcom iProc GBit BCMA support"
 	depends on BCMA && BCMA_HOST_SOC
 	depends on HAS_DMA
 	depends on BCM47XX || ARCH_BCM_5301X || COMPILE_TEST
+	select BGMAC
 	select PHYLIB
 	select FIXED_PHY
 	---help---
@@ -152,6 +160,19 @@ config BGMAC
 	  In case of using this driver on BCM4706 it's also requires to enabl=
e
 	  BCMA_DRIVER_GMAC_CMN to make it work.
=20
+config BGMAC_PLATFORM
+	tristate "Broadcom iProc GBit platform support"
+	depends on HAS_DMA
+	depends on ARCH_BCM_IPROC || COMPILE_TEST
+	depends on OF
+	select BGMAC
+	select PHYLIB
+	select FIXED_PHY
+	default ARCH_BCM_IPROC
+	---help---
+	  Say Y here if you want to use the Broadcom iProc Gigabit Ethernet
+	  controller through the generic platform interface
+
 config SYSTEMPORT
 	tristate "Broadcom SYSTEMPORT internal MAC support"
 	depends on OF
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ether=
net/broadcom/Makefile
index f559794..79f2372 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -10,6 +10,8 @@ obj-$(CONFIG_CNIC) +=3D cnic.o
 obj-$(CONFIG_BNX2X) +=3D bnx2x/
 obj-$(CONFIG_SB1250_MAC) +=3D sb1250-mac.o
 obj-$(CONFIG_TIGON3) +=3D tg3.o
-obj-$(CONFIG_BGMAC) +=3D bgmac.o bgmac-bcma-mdio.o
+obj-$(CONFIG_BGMAC) +=3D bgmac.o
+obj-$(CONFIG_BGMAC_BCMA) +=3D bgmac-bcma.o bgmac-bcma-mdio.o
+obj-$(CONFIG_BGMAC_PLATFORM) +=3D bgmac-platform.o
 obj-$(CONFIG_SYSTEMPORT) +=3D bcmsysport.o
 obj-$(CONFIG_BNXT) +=3D bnxt/
diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c b/drivers/=
net/ethernet/broadcom/bgmac-bcma-mdio.c
index 1e65349..7c19c8e 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
@@ -245,6 +245,7 @@ err:
 	kfree(bcma_mdio);
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL_GPL(bcma_mdio_mii_register);
=20
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus)
 {
@@ -259,6 +260,7 @@ void bcma_mdio_mii_unregister(struct mii_bus *mii_b=
us)
 	mdiobus_free(mii_bus);
 	kfree(bcma_mdio);
 }
+EXPORT_SYMBOL_GPL(bcma_mdio_mii_unregister);
=20
 MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/e=
thernet/broadcom/bgmac-bcma.c
new file mode 100644
index 0000000..9a9745c4
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -0,0 +1,315 @@
+/*
+ * Driver for (BCM4706)? GBit MAC core on BCMA bus.
+ *
+ * Copyright (C) 2012 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
+
+#include <linux/bcma/bcma.h>
+#include <linux/brcmphy.h>
+#include <linux/etherdevice.h>
+#include "bgmac.h"
+
+static inline bool bgmac_is_bcm4707_family(struct bcma_device *core)
+{
+	switch (core->bus->chipinfo.id) {
+	case BCMA_CHIP_ID_BCM4707:
+	case BCMA_CHIP_ID_BCM47094:
+	case BCMA_CHIP_ID_BCM53018:
+		return true;
+	default:
+		return false;
+	}
+}
+
+/**************************************************
+ * BCMA bus ops
+ **************************************************/
+
+static u32 bcma_bgmac_read(struct bgmac *bgmac, u16 offset)
+{
+	return bcma_read32(bgmac->bcma.core, offset);
+}
+
+static void bcma_bgmac_write(struct bgmac *bgmac, u16 offset, u32 valu=
e)
+{
+	bcma_write32(bgmac->bcma.core, offset, value);
+}
+
+static u32 bcma_bgmac_idm_read(struct bgmac *bgmac, u16 offset)
+{
+	return bcma_aread32(bgmac->bcma.core, offset);
+}
+
+static void bcma_bgmac_idm_write(struct bgmac *bgmac, u16 offset, u32 =
value)
+{
+	return bcma_awrite32(bgmac->bcma.core, offset, value);
+}
+
+static bool bcma_bgmac_clk_enabled(struct bgmac *bgmac)
+{
+	return bcma_core_is_enabled(bgmac->bcma.core);
+}
+
+static void bcma_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
+{
+	bcma_core_enable(bgmac->bcma.core, flags);
+}
+
+static void bcma_bgmac_cco_ctl_maskset(struct bgmac *bgmac, u32 offset=
,
+				       u32 mask, u32 set)
+{
+	struct bcma_drv_cc *cc =3D &bgmac->bcma.core->bus->drv_cc;
+
+	bcma_chipco_chipctl_maskset(cc, offset, mask, set);
+}
+
+static u32 bcma_bgmac_get_bus_clock(struct bgmac *bgmac)
+{
+	struct bcma_drv_cc *cc =3D &bgmac->bcma.core->bus->drv_cc;
+
+	return bcma_pmu_get_bus_clock(cc);
+}
+
+static void bcma_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset, =
u32 mask,
+				     u32 set)
+{
+	bcma_maskset32(bgmac->bcma.cmn, offset, mask, set);
+}
+
+static const struct bcma_device_id bgmac_bcma_tbl[] =3D {
+	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT,
+		  BCMA_ANY_REV, BCMA_ANY_CLASS),
+	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV,
+		  BCMA_ANY_CLASS),
+	{},
+};
+MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
+
+/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
+static int bgmac_probe(struct bcma_device *core)
+{
+	struct ssb_sprom *sprom =3D &core->bus->sprom;
+	struct mii_bus *mii_bus;
+	struct bgmac *bgmac;
+	u8 *mac;
+	int err;
+
+	bgmac =3D kzalloc(sizeof(*bgmac), GFP_KERNEL);
+	if (!bgmac)
+		return -ENOMEM;
+
+	bgmac->bcma.core =3D core;
+	bgmac->dev =3D &core->dev;
+	bgmac->dma_dev =3D core->dma_dev;
+	bgmac->irq =3D core->irq;
+
+	bcma_set_drvdata(core, bgmac);
+
+	switch (core->core_unit) {
+	case 0:
+		mac =3D sprom->et0mac;
+		break;
+	case 1:
+		mac =3D sprom->et1mac;
+		break;
+	case 2:
+		mac =3D sprom->et2mac;
+		break;
+	default:
+		dev_err(bgmac->dev, "Unsupported core_unit %d\n",
+			core->core_unit);
+		err =3D -ENOTSUPP;
+		goto err;
+	}
+
+	ether_addr_copy(bgmac->mac_addr, mac);
+
+	/* On BCM4706 we need common core to access PHY */
+	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT &&
+	    !core->bus->drv_gmac_cmn.core) {
+		dev_err(bgmac->dev, "GMAC CMN core not found (required for BCM4706)\=
n");
+		err =3D -ENODEV;
+		goto err;
+	}
+	bgmac->bcma.cmn =3D core->bus->drv_gmac_cmn.core;
+
+	switch (core->core_unit) {
+	case 0:
+		bgmac->phyaddr =3D sprom->et0phyaddr;
+		break;
+	case 1:
+		bgmac->phyaddr =3D sprom->et1phyaddr;
+		break;
+	case 2:
+		bgmac->phyaddr =3D sprom->et2phyaddr;
+		break;
+	}
+	bgmac->phyaddr &=3D BGMAC_PHY_MASK;
+	if (bgmac->phyaddr =3D=3D BGMAC_PHY_MASK) {
+		dev_err(bgmac->dev, "No PHY found\n");
+		err =3D -ENODEV;
+		goto err;
+	}
+	dev_info(bgmac->dev, "Found PHY addr: %d%s\n", bgmac->phyaddr,
+		 bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS ? " (NOREGS)" : "");
+
+	if (!bgmac_is_bcm4707_family(core)) {
+		mii_bus =3D bcma_mdio_mii_register(core, bgmac->phyaddr);
+		if (!IS_ERR(mii_bus)) {
+			err =3D PTR_ERR(mii_bus);
+			goto err;
+		}
+
+		bgmac->mii_bus =3D mii_bus;
+	}
+
+	if (core->bus->hosttype =3D=3D BCMA_HOSTTYPE_PCI) {
+		dev_err(bgmac->dev, "PCI setup not implemented\n");
+		err =3D -ENOTSUPP;
+		goto err1;
+	}
+
+	bgmac->has_robosw =3D !!(core->bus->sprom.boardflags_lo &
+			       BGMAC_BFL_ENETROBO);
+	if (bgmac->has_robosw)
+		dev_warn(bgmac->dev, "Support for Roboswitch not implemented\n");
+
+	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
+		dev_warn(bgmac->dev, "Support for ADMtek ethernet switch not impleme=
nted\n");
+
+	/* Feature Flags */
+	switch (core->bus->chipinfo.id) {
+	case BCMA_CHIP_ID_BCM5357:
+		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47186) {
+			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
+			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
+		}
+		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM5358)
+			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_EPHYRMII;
+		break;
+	case BCMA_CHIP_ID_BCM53572:
+		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47188) {
+			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
+			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
+		}
+		break;
+	case BCMA_CHIP_ID_BCM4749:
+		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg =3D=3D 10) {
+			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
+			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
+		}
+		break;
+	case BCMA_CHIP_ID_BCM4716:
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		/* fallthrough */
+	case BCMA_CHIP_ID_BCM47162:
+		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL2;
+		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
+		break;
+	/* bcm4707_family */
+	case BCMA_CHIP_ID_BCM4707:
+	case BCMA_CHIP_ID_BCM47094:
+	case BCMA_CHIP_ID_BCM53018:
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |=3D BGMAC_FEAT_NO_RESET;
+		bgmac->feature_flags |=3D BGMAC_FEAT_FORCE_SPEED_2500;
+		break;
+	default:
+		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
+	}
+
+	if (!bgmac_is_bcm4707_family(core) && core->id.rev > 2)
+		bgmac->feature_flags |=3D BGMAC_FEAT_MISC_PLL_REQ;
+
+	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
+		bgmac->feature_flags |=3D BGMAC_FEAT_CMN_PHY_CTL;
+		bgmac->feature_flags |=3D BGMAC_FEAT_NO_CLR_MIB;
+	}
+
+	if (core->id.rev >=3D 4) {
+		bgmac->feature_flags |=3D BGMAC_FEAT_CMDCFG_SR_REV4;
+		bgmac->feature_flags |=3D BGMAC_FEAT_TX_MASK_SETUP;
+		bgmac->feature_flags |=3D BGMAC_FEAT_RX_MASK_SETUP;
+	}
+
+	bgmac->read =3D bcma_bgmac_read;
+	bgmac->write =3D bcma_bgmac_write;
+	bgmac->idm_read =3D bcma_bgmac_idm_read;
+	bgmac->idm_write =3D bcma_bgmac_idm_write;
+	bgmac->clk_enabled =3D bcma_bgmac_clk_enabled;
+	bgmac->clk_enable =3D bcma_bgmac_clk_enable;
+	bgmac->cco_ctl_maskset =3D bcma_bgmac_cco_ctl_maskset;
+	bgmac->get_bus_clock =3D bcma_bgmac_get_bus_clock;
+	bgmac->cmn_maskset32 =3D bcma_bgmac_cmn_maskset32;
+
+	err =3D bgmac_enet_probe(bgmac);
+	if (err)
+		goto err1;
+
+	return 0;
+
+err1:
+	bcma_mdio_mii_unregister(bgmac->mii_bus);
+err:
+	kfree(bgmac);
+	bcma_set_drvdata(core, NULL);
+
+	return err;
+}
+
+static void bgmac_remove(struct bcma_device *core)
+{
+	struct bgmac *bgmac =3D bcma_get_drvdata(core);
+
+	bcma_mdio_mii_unregister(bgmac->mii_bus);
+	bgmac_enet_remove(bgmac);
+	bcma_set_drvdata(core, NULL);
+	kfree(bgmac);
+}
+
+static struct bcma_driver bgmac_bcma_driver =3D {
+	.name		=3D KBUILD_MODNAME,
+	.id_table	=3D bgmac_bcma_tbl,
+	.probe		=3D bgmac_probe,
+	.remove		=3D bgmac_remove,
+};
+
+static int __init bgmac_init(void)
+{
+	int err;
+
+	err =3D bcma_driver_register(&bgmac_bcma_driver);
+	if (err)
+		return err;
+	pr_info("Broadcom 47xx GBit MAC driver loaded\n");
+
+	return 0;
+}
+
+static void __exit bgmac_exit(void)
+{
+	bcma_driver_unregister(&bgmac_bcma_driver);
+}
+
+module_init(bgmac_init)
+module_exit(bgmac_exit)
+
+MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/n=
et/ethernet/broadcom/bgmac-platform.c
new file mode 100644
index 0000000..7a8f7ef
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -0,0 +1,189 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
+
+#include <linux/bcma/bcma.h>
+#include <linux/etherdevice.h>
+#include <linux/of_address.h>
+#include <linux/of_net.h>
+#include "bgmac.h"
+
+static u32 platform_bgmac_read(struct bgmac *bgmac, u16 offset)
+{
+	return readl(bgmac->plat.base + offset);
+}
+
+static void platform_bgmac_write(struct bgmac *bgmac, u16 offset, u32 =
value)
+{
+	writel(value, bgmac->plat.base + offset);
+}
+
+static u32 platform_bgmac_idm_read(struct bgmac *bgmac, u16 offset)
+{
+	return readl(bgmac->plat.idm_base + offset);
+}
+
+static void platform_bgmac_idm_write(struct bgmac *bgmac, u16 offset, =
u32 value)
+{
+	return writel(value, bgmac->plat.idm_base + offset);
+}
+
+static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
+{
+	if ((bgmac_idm_read(bgmac, BCMA_IOCTL) &
+	     (BCMA_IOCTL_CLK | BCMA_IOCTL_FGC)) !=3D BCMA_IOCTL_CLK)
+		return false;
+	if (bgmac_idm_read(bgmac, BCMA_RESET_CTL) & BCMA_RESET_CTL_RESET)
+		return false;
+	return true;
+}
+
+static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
+{
+	bgmac_idm_write(bgmac, BCMA_IOCTL,
+			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
+	bgmac_idm_read(bgmac, BCMA_IOCTL);
+
+	bgmac_idm_write(bgmac, BCMA_RESET_CTL, 0);
+	bgmac_idm_read(bgmac, BCMA_RESET_CTL);
+	udelay(1);
+
+	bgmac_idm_write(bgmac, BCMA_IOCTL, (BCMA_IOCTL_CLK | flags));
+	bgmac_idm_read(bgmac, BCMA_IOCTL);
+	udelay(1);
+}
+
+static void platform_bgmac_cco_ctl_maskset(struct bgmac *bgmac, u32 of=
fset,
+					   u32 mask, u32 set)
+{
+	/* This shouldn't be encountered */
+	WARN_ON(1);
+}
+
+static u32 platform_bgmac_get_bus_clock(struct bgmac *bgmac)
+{
+	/* This shouldn't be encountered */
+	WARN_ON(1);
+
+	return 0;
+}
+
+static void platform_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offs=
et,
+					 u32 mask, u32 set)
+{
+	/* This shouldn't be encountered */
+	WARN_ON(1);
+}
+
+static int bgmac_probe(struct platform_device *pdev)
+{
+	struct device_node *np =3D pdev->dev.of_node;
+	struct bgmac *bgmac;
+	struct resource *regs;
+	const u8 *mac_addr;
+
+	bgmac =3D devm_kzalloc(&pdev->dev, sizeof(*bgmac), GFP_KERNEL);
+	if (!bgmac)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, bgmac);
+
+	/* Set the features of the 4707 family */
+	bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
+	bgmac->feature_flags |=3D BGMAC_FEAT_NO_RESET;
+	bgmac->feature_flags |=3D BGMAC_FEAT_FORCE_SPEED_2500;
+	bgmac->feature_flags |=3D BGMAC_FEAT_CMDCFG_SR_REV4;
+	bgmac->feature_flags |=3D BGMAC_FEAT_TX_MASK_SETUP;
+	bgmac->feature_flags |=3D BGMAC_FEAT_RX_MASK_SETUP;
+
+	bgmac->dev =3D &pdev->dev;
+	bgmac->dma_dev =3D &pdev->dev;
+
+	mac_addr =3D of_get_mac_address(np);
+	if (mac_addr)
+		ether_addr_copy(bgmac->mac_addr, mac_addr);
+	else
+		dev_warn(&pdev->dev, "MAC address not present in device tree\n");
+
+	bgmac->irq =3D platform_get_irq(pdev, 0);
+	if (bgmac->irq < 0) {
+		dev_err(&pdev->dev, "Unable to obtain IRQ\n");
+		return bgmac->irq;
+	}
+
+	regs =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "amac_bas=
e");
+	if (!regs) {
+		dev_err(&pdev->dev, "Unable to obtain base resource\n");
+		return -EINVAL;
+	}
+
+	bgmac->plat.base =3D devm_ioremap_resource(&pdev->dev, regs);
+	if (IS_ERR(bgmac->plat.base)) {
+		dev_err(&pdev->dev, "Unable to map base resource\n");
+		return PTR_ERR(bgmac->plat.base);
+	}
+
+	regs =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "idm_base=
");
+	if (!regs) {
+		dev_err(&pdev->dev, "Unable to obtain idm resource\n");
+		return -EINVAL;
+	}
+
+	bgmac->plat.idm_base =3D devm_ioremap_resource(&pdev->dev, regs);
+	if (!bgmac->plat.idm_base) {
+		dev_err(&pdev->dev, "Unable to map idm resource\n");
+		return PTR_ERR(bgmac->plat.idm_base);
+	}
+
+	bgmac->read =3D platform_bgmac_read;
+	bgmac->write =3D platform_bgmac_write;
+	bgmac->idm_read =3D platform_bgmac_idm_read;
+	bgmac->idm_write =3D platform_bgmac_idm_write;
+	bgmac->clk_enabled =3D platform_bgmac_clk_enabled;
+	bgmac->clk_enable =3D platform_bgmac_clk_enable;
+	bgmac->cco_ctl_maskset =3D platform_bgmac_cco_ctl_maskset;
+	bgmac->get_bus_clock =3D platform_bgmac_get_bus_clock;
+	bgmac->cmn_maskset32 =3D platform_bgmac_cmn_maskset32;
+
+	return bgmac_enet_probe(bgmac);
+}
+
+static int bgmac_remove(struct platform_device *pdev)
+{
+	struct bgmac *bgmac =3D platform_get_drvdata(pdev);
+
+	bgmac_enet_remove(bgmac);
+
+	return 0;
+}
+
+static const struct of_device_id bgmac_of_enet_match[] =3D {
+	{.compatible =3D "brcm,amac",},
+	{.compatible =3D "brcm,nsp-amac",},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, bgmac_of_enet_match);
+
+static struct platform_driver bgmac_enet_driver =3D {
+	.driver =3D {
+		.name  =3D "bgmac-enet",
+		.of_match_table =3D bgmac_of_enet_match,
+	},
+	.probe =3D bgmac_probe,
+	.remove =3D bgmac_remove,
+};
+
+module_platform_driver(bgmac_enet_driver);
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index b85e39a..bba9749 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -6,51 +6,27 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
=20
-#include "bgmac.h"
=20
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/delay.h>
+#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
+
+#include <linux/bcma/bcma.h>
 #include <linux/etherdevice.h>
-#include <linux/mii.h>
-#include <linux/phy.h>
-#include <linux/phy_fixed.h>
-#include <linux/interrupt.h>
-#include <linux/dma-mapping.h>
 #include <linux/bcm47xx_nvram.h>
+#include "bgmac.h"
=20
-static const struct bcma_device_id bgmac_bcma_tbl[] =3D {
-	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT, BCMA_ANY_REV, BCMA=
_ANY_CLASS),
-	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV, BCMA_ANY_=
CLASS),
-	{},
-};
-MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
-
-static inline bool bgmac_is_bcm4707_family(struct bgmac *bgmac)
-{
-	switch (bgmac->core->bus->chipinfo.id) {
-	case BCMA_CHIP_ID_BCM4707:
-	case BCMA_CHIP_ID_BCM47094:
-	case BCMA_CHIP_ID_BCM53018:
-		return true;
-	default:
-		return false;
-	}
-}
-
-static bool bgmac_wait_value(struct bcma_device *core, u16 reg, u32 ma=
sk,
+static bool bgmac_wait_value(struct bgmac *bgmac, u16 reg, u32 mask,
 			     u32 value, int timeout)
 {
 	u32 val;
 	int i;
=20
 	for (i =3D 0; i < timeout / 10; i++) {
-		val =3D bcma_read32(core, reg);
+		val =3D bgmac_read(bgmac, reg);
 		if ((val & mask) =3D=3D value)
 			return true;
 		udelay(10);
 	}
-	dev_err(&core->dev, "Timeout waiting for reg 0x%X\n", reg);
+	dev_err(bgmac->dev, "Timeout waiting for reg 0x%X\n", reg);
 	return false;
 }
=20
@@ -89,7 +65,7 @@ static void bgmac_dma_tx_reset(struct bgmac *bgmac, s=
truct bgmac_dma_ring *ring)
=20
 	/* Remove SUSPEND bit */
 	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL, 0);
-	if (!bgmac_wait_value(bgmac->core,
+	if (!bgmac_wait_value(bgmac,
 			      ring->mmio_base + BGMAC_DMA_TX_STATUS,
 			      BGMAC_DMA_TX_STAT, BGMAC_DMA_TX_STAT_DISABLED,
 			      10000)) {
@@ -316,7 +292,7 @@ static void bgmac_dma_rx_reset(struct bgmac *bgmac,=
 struct bgmac_dma_ring *ring)
 		return;
=20
 	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL, 0);
-	if (!bgmac_wait_value(bgmac->core,
+	if (!bgmac_wait_value(bgmac,
 			      ring->mmio_base + BGMAC_DMA_RX_STATUS,
 			      BGMAC_DMA_RX_STAT, BGMAC_DMA_RX_STAT_DISABLED,
 			      10000))
@@ -639,7 +615,7 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 	BUILD_BUG_ON(BGMAC_MAX_TX_RINGS > ARRAY_SIZE(ring_base));
 	BUILD_BUG_ON(BGMAC_MAX_RX_RINGS > ARRAY_SIZE(ring_base));
=20
-	if (!(bcma_aread32(bgmac->core, BCMA_IOST) & BCMA_IOST_DMA64)) {
+	if (!(bgmac_idm_read(bgmac, BCMA_IOST) & BCMA_IOST_DMA64)) {
 		dev_err(bgmac->dev, "Core does not report 64-bit DMA\n");
 		return -ENOTSUPP;
 	}
@@ -871,12 +847,10 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
=20
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
-	struct bcma_device *core =3D bgmac->core;
-
 	if (bgmac->feature_flags & BGMAC_FEAT_FORCE_SPEED_2500) {
-		bcma_awrite32(core, BCMA_IOCTL,
-			      bcma_aread32(core, BCMA_IOCTL) | 0x40 |
-			      BGMAC_BCMA_IOCTL_SW_CLKEN);
+		bgmac_idm_write(bgmac, BCMA_IOCTL,
+				bgmac_idm_read(bgmac, BCMA_IOCTL) | 0x40 |
+				BGMAC_BCMA_IOCTL_SW_CLKEN);
 		bgmac->mac_speed =3D SPEED_2500;
 		bgmac->mac_duplex =3D DUPLEX_FULL;
 		bgmac_mac_speed(bgmac);
@@ -896,12 +870,11 @@ static void bgmac_miiconfig(struct bgmac *bgmac)
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipreset */
 static void bgmac_chip_reset(struct bgmac *bgmac)
 {
-	struct bcma_device *core =3D bgmac->core;
 	u32 cmdcfg_sr;
 	u32 iost;
 	int i;
=20
-	if (bcma_core_is_enabled(core)) {
+	if (bgmac_clk_enabled(bgmac)) {
 		if (!bgmac->stats_grabbed) {
 			/* bgmac_chip_stats_update(bgmac); */
 			bgmac->stats_grabbed =3D true;
@@ -919,7 +892,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 		/* TODO: Clear software multicast filter list */
 	}
=20
-	iost =3D bcma_aread32(core, BCMA_IOST);
+	iost =3D bgmac_idm_read(bgmac, BCMA_IOST);
 	if (bgmac->feature_flags & BGMAC_FEAT_IOST_ATTACHED)
 		iost &=3D ~BGMAC_BCMA_IOST_ATTACHED;
=20
@@ -931,21 +904,20 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			if (!bgmac->has_robosw)
 				flags |=3D BGMAC_BCMA_IOCTL_SW_RESET;
 		}
-		bcma_core_enable(core, flags);
+		bgmac_clk_enable(bgmac, flags);
 	}
=20
 	/* Request Misc PLL for corerev > 2 */
 	if (bgmac->feature_flags & BGMAC_FEAT_MISC_PLL_REQ) {
 		bgmac_set(bgmac, BCMA_CLKCTLST,
 			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
-		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
+		bgmac_wait_value(bgmac, BCMA_CLKCTLST,
 				 BGMAC_BCMA_CLKCTLST_MISC_PLL_ST,
 				 BGMAC_BCMA_CLKCTLST_MISC_PLL_ST,
 				 1000);
 	}
=20
 	if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_PHY) {
-		struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
 		u8 et_swtype =3D 0;
 		u8 sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
 			     BGMAC_CHIPCTL_1_IF_TYPE_MII;
@@ -964,16 +936,15 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			sw_type =3D BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
 				  BGMAC_CHIPCTL_1_SW_TYPE_RGMII;
 		}
-		bcma_chipco_chipctl_maskset(cc, 1,
-					    ~(BGMAC_CHIPCTL_1_IF_TYPE_MASK |
-					      BGMAC_CHIPCTL_1_SW_TYPE_MASK),
-					    sw_type);
+		bgmac_cco_ctl_maskset(bgmac, 1, ~(BGMAC_CHIPCTL_1_IF_TYPE_MASK |
+						  BGMAC_CHIPCTL_1_SW_TYPE_MASK),
+				      sw_type);
 	}
=20
 	if (iost & BGMAC_BCMA_IOST_ATTACHED && !bgmac->has_robosw)
-		bcma_awrite32(core, BCMA_IOCTL,
-			      bcma_aread32(core, BCMA_IOCTL) &
-			      ~BGMAC_BCMA_IOCTL_SW_RESET);
+		bgmac_idm_write(bgmac, BCMA_IOCTL,
+				bgmac_idm_read(bgmac, BCMA_IOCTL) &
+				~BGMAC_BCMA_IOCTL_SW_RESET);
=20
 	/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_reset
 	 * Specs don't say about using BGMAC_CMDCFG_SR, but in this routine
@@ -1009,8 +980,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
=20
 	bgmac_clear_mib(bgmac);
 	if (bgmac->feature_flags & BGMAC_FEAT_CMN_PHY_CTL)
-		bcma_maskset32(bgmac->cmn, BCMA_GMAC_CMN_PHY_CTL, ~0,
-			       BCMA_GMAC_CMN_PC_MTE);
+		bgmac_cmn_maskset32(bgmac, BCMA_GMAC_CMN_PHY_CTL, ~0,
+				    BCMA_GMAC_CMN_PC_MTE);
 	else
 		bgmac_set(bgmac, BGMAC_PHY_CNTL, BGMAC_PC_MTE);
 	bgmac_miiconfig(bgmac);
@@ -1055,8 +1026,8 @@ static void bgmac_enable(struct bgmac *bgmac)
 	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode !=3D 0)
 		bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
 	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode =3D=3D 2)
-		bcma_chipco_chipctl_maskset(&bgmac->core->bus->drv_cc, 1, ~0,
-					    BGMAC_CHIPCTL_1_RXC_DLL_BYPASS);
+		bgmac_cco_ctl_maskset(bgmac, 1, ~0,
+				      BGMAC_CHIPCTL_1_RXC_DLL_BYPASS);
=20
 	if (bgmac->feature_flags & (BGMAC_FEAT_FLW_CTRL1 |
 				    BGMAC_FEAT_FLW_CTRL2)) {
@@ -1078,8 +1049,7 @@ static void bgmac_enable(struct bgmac *bgmac)
=20
 		rxq_ctl =3D bgmac_read(bgmac, BGMAC_RXQ_CTL);
 		rxq_ctl &=3D ~BGMAC_RXQ_CTL_MDP_MASK;
-		bp_clk =3D bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) /
-				1000000;
+		bp_clk =3D bgmac_get_bus_clock(bgmac) / 1000000;
 		mdp =3D (bp_clk * 128 / 1000) - 3;
 		rxq_ctl |=3D (mdp << BGMAC_RXQ_CTL_MDP_SHIFT);
 		bgmac_write(bgmac, BGMAC_RXQ_CTL, rxq_ctl);
@@ -1174,7 +1144,7 @@ static int bgmac_open(struct net_device *net_dev)
 	/* Specs say about reclaiming rings here, but we do that in DMA init =
*/
 	bgmac_chip_init(bgmac);
=20
-	err =3D request_irq(bgmac->core->irq, bgmac_interrupt, IRQF_SHARED,
+	err =3D request_irq(bgmac->irq, bgmac_interrupt, IRQF_SHARED,
 			  KBUILD_MODNAME, net_dev);
 	if (err < 0) {
 		dev_err(bgmac->dev, "IRQ request error: %d!\n", err);
@@ -1199,7 +1169,7 @@ static int bgmac_stop(struct net_device *net_dev)
=20
 	napi_disable(&bgmac->napi);
 	bgmac_chip_intrs_off(bgmac);
-	free_irq(bgmac->core->irq, net_dev);
+	free_irq(bgmac->irq, net_dev);
=20
 	bgmac_chip_reset(bgmac);
 	bgmac_dma_cleanup(bgmac);
@@ -1378,7 +1348,7 @@ static void bgmac_get_drvinfo(struct net_device *=
net_dev,
 			      struct ethtool_drvinfo *info)
 {
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
-	strlcpy(info->bus_info, "BCMA", sizeof(info->bus_info));
+	strlcpy(info->bus_info, "AXI", sizeof(info->bus_info));
 }
=20
 static const struct ethtool_ops bgmac_ethtool_ops =3D {
@@ -1462,116 +1432,41 @@ static int bgmac_phy_connect(struct bgmac *bgm=
ac)
 	return 0;
 }
=20
-static int bgmac_probe(struct bcma_device *core)
+int bgmac_enet_probe(struct bgmac *info)
 {
 	struct net_device *net_dev;
 	struct bgmac *bgmac;
-	struct ssb_sprom *sprom =3D &core->bus->sprom;
-	u8 *mac;
 	int err;
=20
-	switch (core->core_unit) {
-	case 0:
-		mac =3D sprom->et0mac;
-		break;
-	case 1:
-		mac =3D sprom->et1mac;
-		break;
-	case 2:
-		mac =3D sprom->et2mac;
-		break;
-	default:
-		dev_err(&core->dev, "Unsupported core_unit %d\n",
-			core->core_unit);
-		return -ENOTSUPP;
-	}
-
-	if (!is_valid_ether_addr(mac)) {
-		dev_err(&core->dev, "Invalid MAC addr: %pM\n", mac);
-		eth_random_addr(mac);
-		dev_warn(&core->dev, "Using random MAC: %pM\n", mac);
-	}
-
-	/* This (reset &) enable is not preset in specs or reference driver b=
ut
-	 * Broadcom does it in arch PCI code when enabling fake PCI device.
-	 */
-	bcma_core_enable(core, 0);
-
 	/* Allocation and references */
 	net_dev =3D alloc_etherdev(sizeof(*bgmac));
 	if (!net_dev)
 		return -ENOMEM;
+
 	net_dev->netdev_ops =3D &bgmac_netdev_ops;
-	net_dev->irq =3D core->irq;
 	net_dev->ethtool_ops =3D &bgmac_ethtool_ops;
 	bgmac =3D netdev_priv(net_dev);
-	bgmac->dev =3D &core->dev;
-	bgmac->dma_dev =3D core->dma_dev;
+	memcpy(bgmac, info, sizeof(*bgmac));
 	bgmac->net_dev =3D net_dev;
-	bgmac->core =3D core;
-	bcma_set_drvdata(core, bgmac);
-	SET_NETDEV_DEV(net_dev, &core->dev);
-
-	/* Defaults */
-	memcpy(bgmac->net_dev->dev_addr, mac, ETH_ALEN);
-
-	/* On BCM4706 we need common core to access PHY */
-	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT &&
-	    !core->bus->drv_gmac_cmn.core) {
-		dev_err(bgmac->dev, "GMAC CMN core not found (required for BCM4706)\=
n");
-		err =3D -ENODEV;
-		goto err_netdev_free;
-	}
-	bgmac->cmn =3D core->bus->drv_gmac_cmn.core;
-
-	switch (core->core_unit) {
-	case 0:
-		bgmac->phyaddr =3D sprom->et0phyaddr;
-		break;
-	case 1:
-		bgmac->phyaddr =3D sprom->et1phyaddr;
-		break;
-	case 2:
-		bgmac->phyaddr =3D sprom->et2phyaddr;
-		break;
-	}
-	bgmac->phyaddr &=3D BGMAC_PHY_MASK;
-	if (bgmac->phyaddr =3D=3D BGMAC_PHY_MASK) {
-		dev_err(bgmac->dev, "No PHY found\n");
-		err =3D -ENODEV;
-		goto err_netdev_free;
+	net_dev->irq =3D bgmac->irq;
+	SET_NETDEV_DEV(net_dev, bgmac->dev);
+
+	if (!is_valid_ether_addr(bgmac->mac_addr)) {
+		dev_err(bgmac->dev, "Invalid MAC addr: %pM\n",
+			bgmac->mac_addr);
+		eth_random_addr(bgmac->mac_addr);
+		dev_warn(bgmac->dev, "Using random MAC: %pM\n",
+			 bgmac->mac_addr);
 	}
-	dev_info(bgmac->dev, "Found PHY addr: %d%s\n", bgmac->phyaddr,
-		 bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS ? " (NOREGS)" : "");
+	ether_addr_copy(net_dev->dev_addr, bgmac->mac_addr);
=20
-	if (core->bus->hosttype =3D=3D BCMA_HOSTTYPE_PCI) {
-		dev_err(bgmac->dev, "PCI setup not implemented\n");
-		err =3D -ENOTSUPP;
-		goto err_netdev_free;
-	}
+	/* This (reset &) enable is not preset in specs or reference driver b=
ut
+	 * Broadcom does it in arch PCI code when enabling fake PCI device.
+	 */
+	bgmac_clk_enable(bgmac, 0);
=20
 	bgmac_chip_reset(bgmac);
=20
-	/* For Northstar, we have to take all GMAC core out of reset */
-	if (bgmac_is_bcm4707_family(bgmac)) {
-		struct bcma_device *ns_core;
-		int ns_gmac;
-
-		/* Northstar has 4 GMAC cores */
-		for (ns_gmac =3D 0; ns_gmac < 4; ns_gmac++) {
-			/* As Northstar requirement, we have to reset all GMACs
-			 * before accessing one. bgmac_chip_reset() call
-			 * bcma_core_enable() for this core. Then the other
-			 * three GMACs didn't reset.  We do it here.
-			 */
-			ns_core =3D bcma_find_core_unit(core->bus,
-						      BCMA_CORE_MAC_GBIT,
-						      ns_gmac);
-			if (ns_core && !bcma_core_is_enabled(ns_core))
-				bcma_core_enable(ns_core, 0);
-		}
-	}
-
 	err =3D bgmac_dma_alloc(bgmac);
 	if (err) {
 		dev_err(bgmac->dev, "Unable to alloc memory for DMA\n");
@@ -1582,103 +1477,15 @@ static int bgmac_probe(struct bcma_device *cor=
e)
 	if (bcm47xx_nvram_getenv("et0_no_txint", NULL, 0) =3D=3D 0)
 		bgmac->int_mask &=3D ~BGMAC_IS_TX_MASK;
=20
-	bgmac->has_robosw =3D !!(core->bus->sprom.boardflags_lo &
-			       BGMAC_BFL_ENETROBO);
-	if (bgmac->has_robosw)
-		dev_warn(bgmac->dev, "Support for Roboswitch not implemented\n");
-
-	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
-		dev_warn(bgmac->dev, "Support for ADMtek ethernet switch not impleme=
nted\n");
-
-	/* Feature Flags */
-	switch (core->bus->chipinfo.id) {
-	case BCMA_CHIP_ID_BCM5357:
-		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
-		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47186) {
-			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
-			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
-		}
-		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM5358)
-			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_EPHYRMII;
-		break;
-	case BCMA_CHIP_ID_BCM53572:
-		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
-		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg =3D=3D BCMA_PKG_ID_BCM47188) {
-			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
-			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
-		}
-		break;
-	case BCMA_CHIP_ID_BCM4749:
-		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL1;
-		bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg =3D=3D 10) {
-			bgmac->feature_flags |=3D BGMAC_FEAT_SW_TYPE_RGMII;
-			bgmac->feature_flags |=3D BGMAC_FEAT_IOST_ATTACHED;
-		}
-		break;
-	case BCMA_CHIP_ID_BCM4716:
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		/* fallthrough */
-	case BCMA_CHIP_ID_BCM47162:
-		bgmac->feature_flags |=3D BGMAC_FEAT_FLW_CTRL2;
-		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
-		break;
-	/* bcm4707_family */
-	case BCMA_CHIP_ID_BCM4707:
-	case BCMA_CHIP_ID_BCM47094:
-	case BCMA_CHIP_ID_BCM53018:
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |=3D BGMAC_FEAT_NO_RESET;
-		bgmac->feature_flags |=3D BGMAC_FEAT_FORCE_SPEED_2500;
-		break;
-	default:
-		bgmac->feature_flags |=3D BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |=3D BGMAC_FEAT_SET_RXQ_CLK;
-	}
-
-	if (!bgmac_is_bcm4707_family(bgmac) && core->id.rev > 2)
-		bgmac->feature_flags |=3D BGMAC_FEAT_MISC_PLL_REQ;
-
-	if (core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT) {
-		bgmac->feature_flags |=3D BGMAC_FEAT_CMN_PHY_CTL;
-		bgmac->feature_flags |=3D BGMAC_FEAT_NO_CLR_MIB;
-	}
-
-	if (core->id.rev >=3D 4) {
-		bgmac->feature_flags |=3D BGMAC_FEAT_CMDCFG_SR_REV4;
-		bgmac->feature_flags |=3D BGMAC_FEAT_TX_MASK_SETUP;
-		bgmac->feature_flags |=3D BGMAC_FEAT_RX_MASK_SETUP;
-	}
-
 	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
=20
-	if (!bgmac_is_bcm4707_family(bgmac)) {
-		struct mii_bus *mii_bus;
-
-		mii_bus =3D bcma_mdio_mii_register(core, bgmac->phyaddr);
-		if (!IS_ERR(mii_bus)) {
-			err =3D PTR_ERR(mii_bus);
-			goto err_dma_free;
-		}
-
-		bgmac->mii_bus =3D mii_bus;
-	}
-
 	if (!bgmac->mii_bus)
 		err =3D bgmac_phy_connect_direct(bgmac);
 	else
 		err =3D bgmac_phy_connect(bgmac);
 	if (err) {
 		dev_err(bgmac->dev, "Cannot connect to phy\n");
-		goto err_mii_unregister;
+		goto err_dma_free;
 	}
=20
 	net_dev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSU=
M;
@@ -1697,56 +1504,24 @@ static int bgmac_probe(struct bcma_device *core=
)
=20
 err_phy_disconnect:
 	phy_disconnect(net_dev->phydev);
-err_mii_unregister:
-	bcma_mdio_mii_unregister(bgmac->mii_bus);
 err_dma_free:
 	bgmac_dma_free(bgmac);
 err_netdev_free:
-	bcma_set_drvdata(core, NULL);
 	free_netdev(net_dev);
=20
 	return err;
 }
+EXPORT_SYMBOL_GPL(bgmac_enet_probe);
=20
-static void bgmac_remove(struct bcma_device *core)
+void bgmac_enet_remove(struct bgmac *bgmac)
 {
-	struct bgmac *bgmac =3D bcma_get_drvdata(core);
-
 	unregister_netdev(bgmac->net_dev);
 	phy_disconnect(bgmac->net_dev->phydev);
-	bcma_mdio_mii_unregister(bgmac->mii_bus);
 	netif_napi_del(&bgmac->napi);
 	bgmac_dma_free(bgmac);
-	bcma_set_drvdata(core, NULL);
 	free_netdev(bgmac->net_dev);
 }
-
-static struct bcma_driver bgmac_bcma_driver =3D {
-	.name		=3D KBUILD_MODNAME,
-	.id_table	=3D bgmac_bcma_tbl,
-	.probe		=3D bgmac_probe,
-	.remove		=3D bgmac_remove,
-};
-
-static int __init bgmac_init(void)
-{
-	int err;
-
-	err =3D bcma_driver_register(&bgmac_bcma_driver);
-	if (err)
-		return err;
-	pr_info("Broadcom 47xx GBit MAC driver loaded\n");
-
-	return 0;
-}
-
-static void __exit bgmac_exit(void)
-{
-	bcma_driver_unregister(&bgmac_bcma_driver);
-}
-
-module_init(bgmac_init)
-module_exit(bgmac_exit)
+EXPORT_SYMBOL_GPL(bgmac_enet_remove);
=20
 MODULE_AUTHOR("Rafa=C5=82 Mi=C5=82ecki");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 89dfee1..24a25026 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -1,8 +1,6 @@
 #ifndef _BGMAC_H
 #define _BGMAC_H
=20
-#include <linux/bcma/bcma.h>
-#include <linux/brcmphy.h>
 #include <linux/netdevice.h>
=20
 #define BGMAC_DEV_CTL				0x000
@@ -442,11 +440,21 @@ struct bgmac_rx_header {
 };
=20
 struct bgmac {
-	struct bcma_device *core;
-	struct bcma_device *cmn; /* Reference to CMN core for BCM4706 */
+	union {
+		struct {
+			void *base;
+			void *idm_base;
+		} plat;
+		struct {
+			struct bcma_device *core;
+			/* Reference to CMN core for BCM4706 */
+			struct bcma_device *cmn;
+		} bcma;
+	};
=20
 	struct device *dev;
 	struct device *dma_dev;
+	unsigned char mac_addr[ETH_ALEN];
 	u32 feature_flags;
=20
 	struct net_device *net_dev;
@@ -463,6 +471,7 @@ struct bgmac {
 	u32 mib_rx_regs[BGMAC_NUM_MIB_RX_REGS];
=20
 	/* Int */
+	int irq;
 	u32 int_mask;
=20
 	/* Current MAC state */
@@ -473,19 +482,71 @@ struct bgmac {
 	bool has_robosw;
=20
 	bool loopback;
+
+	u32 (*read)(struct bgmac *bgmac, u16 offset);
+	void (*write)(struct bgmac *bgmac, u16 offset, u32 value);
+	u32 (*idm_read)(struct bgmac *bgmac, u16 offset);
+	void (*idm_write)(struct bgmac *bgmac, u16 offset, u32 value);
+	bool (*clk_enabled)(struct bgmac *bgmac);
+	void (*clk_enable)(struct bgmac *bgmac, u32 flags);
+	void (*cco_ctl_maskset)(struct bgmac *bgmac, u32 offset, u32 mask,
+				u32 set);
+	u32 (*get_bus_clock)(struct bgmac *bgmac);
+	void (*cmn_maskset32)(struct bgmac *bgmac, u16 offset, u32 mask,
+			      u32 set);
 };
=20
+int bgmac_enet_probe(struct bgmac *info);
+void bgmac_enet_remove(struct bgmac *bgmac);
+
 struct mii_bus *bcma_mdio_mii_register(struct bcma_device *core, u8 ph=
yaddr);
 void bcma_mdio_mii_unregister(struct mii_bus *mii_bus);
=20
 static inline u32 bgmac_read(struct bgmac *bgmac, u16 offset)
 {
-	return bcma_read32(bgmac->core, offset);
+	return bgmac->read(bgmac, offset);
 }
=20
 static inline void bgmac_write(struct bgmac *bgmac, u16 offset, u32 va=
lue)
 {
-	bcma_write32(bgmac->core, offset, value);
+	bgmac->write(bgmac, offset, value);
+}
+
+static inline u32 bgmac_idm_read(struct bgmac *bgmac, u16 offset)
+{
+	return bgmac->idm_read(bgmac, offset);
+}
+
+static inline void bgmac_idm_write(struct bgmac *bgmac, u16 offset, u3=
2 value)
+{
+	bgmac->idm_write(bgmac, offset, value);
+}
+
+static inline bool bgmac_clk_enabled(struct bgmac *bgmac)
+{
+	return bgmac->clk_enabled(bgmac);
+}
+
+static inline void bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
+{
+	bgmac->clk_enable(bgmac, flags);
+}
+
+static inline void bgmac_cco_ctl_maskset(struct bgmac *bgmac, u32 offs=
et,
+					 u32 mask, u32 set)
+{
+	bgmac->cco_ctl_maskset(bgmac, offset, mask, set);
+}
+
+static inline u32 bgmac_get_bus_clock(struct bgmac *bgmac)
+{
+	return bgmac->get_bus_clock(bgmac);
+}
+
+static inline void bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset=
,
+				       u32 mask, u32 set)
+{
+	bgmac->cmn_maskset32(bgmac, offset, mask, set);
 }
=20
 static inline void bgmac_maskset(struct bgmac *bgmac, u16 offset, u32 =
mask,
--=20
1.9.1
