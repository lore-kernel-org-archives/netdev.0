From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v5 3/3] net/fec: add imx6q enet support
Date: Fri, 23 Sep 2011 20:12:48 +0800
Message-ID: <1316779968-21390-4-git-send-email-shawn.guo@linaro.org>
References: <1316779968-21390-1-git-send-email-shawn.guo@linaro.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@linaro.org, Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39464 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab1IWML2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 08:11:28 -0400
Received: by mail-gy0-f174.google.com with SMTP id 10so2477814gyg.19
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 05:11:28 -0700 (PDT)
In-Reply-To: <1316779968-21390-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The imx6q enet is a derivative of imx28 enet controller.  It fixed
the frame endian issue found on imx28, and added 1 Gbps support.

It also fixes a typo on vendor name in Kconfig.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/Kconfig |    9 ++--
 drivers/net/ethernet/freescale/fec.c   |   66 +++++++++++++++++++++++++------
 2 files changed, 57 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 4dbe41f..1cf6716 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -7,7 +7,7 @@ config NET_VENDOR_FREESCALE
 	default y
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC || \
+		   ARCH_MXC || ARCH_MXS || \
 		   (PPC_MPC52xx && PPC_BESTCOMM)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
@@ -16,16 +16,15 @@ config NET_VENDOR_FREESCALE
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-	  the questions about IBM devices. If you say Y, you will be asked for
-	  your specific card in the following questions.
+	  the questions about Freescale devices. If you say Y, you will be
+	  asked for your specific card in the following questions.
 
 if NET_VENDOR_FREESCALE
 
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
-		    IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC)
-	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
+		   ARCH_MXC || ARCH_MXS)
 	select PHYLIB
 	---help---
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 2bbe6a5..cce78ce 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -18,7 +18,7 @@
  * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
  * Copyright (c) 2004-2006 Macq Electronique SA.
  *
- * Copyright (C) 2010 Freescale Semiconductor, Inc.
+ * Copyright (C) 2010-2011 Freescale Semiconductor, Inc.
  */
 
 #include <linux/module.h>
@@ -72,6 +72,8 @@
 #define FEC_QUIRK_SWAP_FRAME		(1 << 1)
 /* Controller uses gasket */
 #define FEC_QUIRK_USE_GASKET		(1 << 2)
+/* Controller has GBIT support */
+#define FEC_QUIRK_HAS_GBIT		(1 << 3)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -88,6 +90,9 @@ static struct platform_device_id fec_devtype[] = {
 		.name = "imx28-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
 	}, {
+		.name = "imx6q-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
+	}, {
 		/* sentinel */
 	}
 };
@@ -97,12 +102,14 @@ enum imx_fec_type {
 	IMX25_FEC = 1, 	/* runs on i.mx25/50/53 */
 	IMX27_FEC,	/* runs on i.mx27/35/51 */
 	IMX28_FEC,
+	IMX6Q_FEC,
 };
 
 static const struct of_device_id fec_dt_ids[] = {
 	{ .compatible = "fsl,imx25-fec", .data = &fec_devtype[IMX25_FEC], },
 	{ .compatible = "fsl,imx27-fec", .data = &fec_devtype[IMX27_FEC], },
 	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },
+	{ .compatible = "fsl,imx6q-fec", .data = &fec_devtype[IMX6Q_FEC], },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, fec_dt_ids);
@@ -373,6 +380,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	int i;
 	u32 temp_mac[2];
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
+	u32 ecntl = 0x2; /* ETHEREN */
 
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
@@ -442,18 +450,23 @@ fec_restart(struct net_device *ndev, int duplex)
 		/* Enable flow control and length check */
 		rcntl |= 0x40000000 | 0x00000020;
 
-		/* MII or RMII */
-		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
+		/* RGMII, RMII or MII */
+		if (fep->phy_interface == PHY_INTERFACE_MODE_RGMII)
+			rcntl |= (1 << 6);
+		else if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
 			rcntl |= (1 << 8);
 		else
 			rcntl &= ~(1 << 8);
 
-		/* 10M or 100M */
-		if (fep->phy_dev && fep->phy_dev->speed == SPEED_100)
-			rcntl &= ~(1 << 9);
-		else
-			rcntl |= (1 << 9);
-
+		/* 1G, 100M or 10M */
+		if (fep->phy_dev) {
+			if (fep->phy_dev->speed == SPEED_1000)
+				ecntl |= (1 << 5);
+			else if (fep->phy_dev->speed == SPEED_100)
+				rcntl &= ~(1 << 9);
+			else
+				rcntl |= (1 << 9);
+		}
 	} else {
 #ifdef FEC_MIIGSK_ENR
 		if (id_entry->driver_data & FEC_QUIRK_USE_GASKET) {
@@ -478,8 +491,15 @@ fec_restart(struct net_device *ndev, int duplex)
 	}
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+		/* enable ENET endian swap */
+		ecntl |= (1 << 8);
+		/* enable ENET store and forward mode */
+		writel(1 << 8, fep->hwp + FEC_X_WMRK);
+	}
+
 	/* And last, enable the transmit and receive processing */
-	writel(2, fep->hwp + FEC_ECNTRL);
+	writel(ecntl, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
 	/* Enable interrupts we wish to service */
@@ -490,6 +510,8 @@ static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
@@ -504,6 +526,10 @@ fec_stop(struct net_device *ndev)
 	udelay(10);
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+	/* We have to keep ENET enabled to have MII interrupt stay working */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+		writel(2, fep->hwp + FEC_ECNTRL);
 }
 
 
@@ -918,6 +944,8 @@ static int fec_enet_mdio_reset(struct mii_bus *bus)
 static int fec_enet_mii_probe(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	struct phy_device *phy_dev = NULL;
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
@@ -949,14 +977,18 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 
 	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
 	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
-		PHY_INTERFACE_MODE_MII);
+			      fep->phy_interface);
 	if (IS_ERR(phy_dev)) {
 		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phy_dev);
 	}
 
 	/* mask with MAC supported features */
-	phy_dev->supported &= PHY_BASIC_FEATURES;
+	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT)
+		phy_dev->supported &= PHY_GBIT_FEATURES;
+	else
+		phy_dev->supported &= PHY_BASIC_FEATURES;
+
 	phy_dev->advertising = phy_dev->supported;
 
 	fep->phy_dev = phy_dev;
@@ -1006,8 +1038,16 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 
 	/*
 	 * Set MII speed to 2.5 MHz (= clk_get_rate() / 2 * phy_speed)
+	 *
+	 * The formula for FEC MDC is 'ref_freq / (MII_SPEED x 2)' while
+	 * for ENET-MAC is 'ref_freq / ((MII_SPEED + 1) x 2)'.  The i.MX28
+	 * Reference Manual has an error on this, and gets fixed on i.MX6Q
+	 * document.
 	 */
-	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000) << 1;
+	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+		fep->phy_speed--;
+	fep->phy_speed <<= 1;
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
 	fep->mii_bus = mdiobus_alloc();
-- 
1.7.4.1
