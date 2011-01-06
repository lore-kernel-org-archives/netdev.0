From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Thu, 6 Jan 2011 15:13:13 +0800
Message-ID: <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:1651 "EHLO
	VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753972Ab1AFHLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:11:53 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add mx28 dual fec support. Here are some key notes
for mx28 fec controller.

 - The mx28 fec controller naming ENET-MAC is a different IP from FEC
   used on other i.mx variants.  But they are basically compatible
   on software interface, so it's possible to share the same driver.
 - ENET-MAC design on mx28 made an improper assumption that it runs
   on a big-endian system. As the result, driver has to swap every
   frame going to and coming from the controller.
 - The external phys can only be configured by fec0, which means fec1
   can not work independently and both phys need to be configured by
   mii_bus attached on fec0.
 - ENET-MAC reset will get mac address registers reset too.
 - ENET-MAC MII/RMII mode and 10M/100M speed are configured
   differently FEC.
 - ETHER_EN bit must be set to get ENET-MAC interrupt work.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v4:
 - Use #ifndef CONFIG_ARM to include ColdFire header files
 - Define quirk bits in id_entry.driver_data to handle controller
   difference, which is more scalable than using device name
 - Define fec0_mii_bus as a static function in fec_enet_mii_init
   to fold the mii_bus instance attached on fec0
 - Use cpu_to_be32 over __swab32 in function swap_buffer

Changes for v3:
 - Move v2 changes into patch #3
 - Use device name to check if it's running on ENET-MAC

 drivers/net/Kconfig |    7 ++-
 drivers/net/fec.c   |  148 +++++++++++++++++++++++++++++++++++++++++++++------
 drivers/net/fec.h   |    5 +-
 3 files changed, 139 insertions(+), 21 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4f1755b..f34629b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1944,18 +1944,19 @@ config 68360_ENET
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
-		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5
+		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5 || SOC_IMX28
 	select PHYLIB
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
 
 config FEC2
-	bool "Second FEC ethernet controller (on some ColdFire CPUs)"
+	bool "Second FEC ethernet controller"
 	depends on FEC
 	help
 	  Say Y here if you want to use the second built-in 10/100 Fast
-	  ethernet controller on some Motorola ColdFire processors.
+	  ethernet controller on some Motorola ColdFire and Freescale
+	  i.MX processors.
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 8a1c51f..2a71373 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -17,6 +17,8 @@
  *
  * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
  * Copyright (c) 2004-2006 Macq Electronique SA.
+ *
+ * Copyright (C) 2010 Freescale Semiconductor, Inc.
  */
 
 #include <linux/module.h>
@@ -45,20 +47,36 @@
 
 #include <asm/cacheflush.h>
 
-#ifndef CONFIG_ARCH_MXC
+#ifndef CONFIG_ARM
 #include <asm/coldfire.h>
 #include <asm/mcfsim.h>
 #endif
 
 #include "fec.h"
 
-#ifdef CONFIG_ARCH_MXC
-#include <mach/hardware.h>
+#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 #define FEC_ALIGNMENT	0xf
 #else
 #define FEC_ALIGNMENT	0x3
 #endif
 
+#define DRIVER_NAME	"fec"
+
+/* Controller is ENET-MAC */
+#define FEC_QUIRK_ENET_MAC		(1 << 0)
+/* Controller needs driver to swap frame */
+#define FEC_QUIRK_SWAP_FRAME		(1 << 1)
+
+static struct platform_device_id fec_devtype[] = {
+	{
+		.name = DRIVER_NAME,
+		.driver_data = 0,
+	}, {
+		.name = "imx28-fec",
+		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
+	}
+};
+
 static unsigned char macaddr[ETH_ALEN];
 module_param_array(macaddr, byte, NULL, 0);
 MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
@@ -129,7 +147,8 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
  * account when setting it.
  */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
+    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 #else
 #define	OPT_FRAME_SIZE	0
@@ -208,10 +227,23 @@ static void fec_stop(struct net_device *dev);
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
 
+static void *swap_buffer(void *bufaddr, int len)
+{
+	int i;
+	unsigned int *buf = bufaddr;
+
+	for (i = 0; i < (len + 3) / 4; i++, buf++)
+		*buf = cpu_to_be32(*buf);
+
+	return bufaddr;
+}
+
 static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	struct bufdesc *bdp;
 	void *bufaddr;
 	unsigned short	status;
@@ -256,6 +288,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		bufaddr = fep->tx_bounce[index];
 	}
 
+	/*
+	 * Some design made an incorrect assumption on endian mode of
+	 * the system that it's running on. As the result, driver has to
+	 * swap every frame going to and coming from the controller.
+	 */
+	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		swap_buffer(bufaddr, skb->len);
+
 	/* Save skb pointer */
 	fep->tx_skbuff[fep->skb_cur] = skb;
 
@@ -424,6 +464,8 @@ static void
 fec_enet_rx(struct net_device *dev)
 {
 	struct	fec_enet_private *fep = netdev_priv(dev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
@@ -487,6 +529,9 @@ fec_enet_rx(struct net_device *dev)
 	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
         			DMA_FROM_DEVICE);
 
+		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+			swap_buffer(data, pkt_len);
+
 		/* This does 16 byte alignment, exactly what we need.
 		 * The packet length includes FCS, but we don't want to
 		 * include that when passing upstream as it messes up
@@ -689,6 +734,7 @@ static int fec_enet_mii_probe(struct net_device *dev)
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
 	int phy_id;
+	int dev_id = fep->pdev->id;
 
 	fep->phy_dev = NULL;
 
@@ -700,6 +746,8 @@ static int fec_enet_mii_probe(struct net_device *dev)
 			continue;
 		if (fep->mii_bus->phy_map[phy_id]->phy_id == 0)
 			continue;
+		if (dev_id--)
+			continue;
 		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
 		break;
 	}
@@ -737,10 +785,35 @@ static int fec_enet_mii_probe(struct net_device *dev)
 
 static int fec_enet_mii_init(struct platform_device *pdev)
 {
+	static struct mii_bus *fec0_mii_bus;
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(dev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	int err = -ENXIO, i;
 
+	/*
+	 * The dual fec interfaces are not equivalent with enet-mac.
+	 * Here are the differences:
+	 *
+	 *  - fec0 supports MII & RMII modes while fec1 only supports RMII
+	 *  - fec0 acts as the 1588 time master while fec1 is slave
+	 *  - external phys can only be configured by fec0
+	 *
+	 * That is to say fec1 can not work independently. It only works
+	 * when fec0 is working. The reason behind this design is that the
+	 * second interface is added primarily for Switch mode.
+	 *
+	 * Because of the last point above, both phys are attached on fec0
+	 * mdio interface in board design, and need to be configured by
+	 * fec0 mii_bus.
+	 */
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id) {
+		/* fec1 uses fec0 mii_bus */
+		fep->mii_bus = fec0_mii_bus;
+		return 0;
+	}
+
 	fep->mii_timeout = 0;
 
 	/*
@@ -777,6 +850,10 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
 
+	/* save fec0 mii_bus */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+		fec0_mii_bus = fep->mii_bus;
+
 	return 0;
 
 err_out_free_mdio_irq:
@@ -1148,12 +1225,25 @@ static void
 fec_restart(struct net_device *dev, int duplex)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	int i;
+	u32 val, temp_mac[2];
 
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
+	/*
+	 * enet-mac reset will reset mac address registers too,
+	 * so need to reconfigure it.
+	 */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+		memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
+		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
+		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
+	}
+
 	/* Clear any outstanding interrupt. */
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
@@ -1200,20 +1290,45 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
-#ifdef FEC_MIIGSK_ENR
-	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
-		/* disable the gasket and wait */
-		writel(0, fep->hwp + FEC_MIIGSK_ENR);
-		while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
-			udelay(1);
+	/*
+	 * The phy interface and speed need to get configured
+	 * differently on enet-mac.
+	 */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+		val = readl(fep->hwp + FEC_R_CNTRL);
 
-		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
-		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
+		/* MII or RMII */
+		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
+			val |= (1 << 8);
+		else
+			val &= ~(1 << 8);
 
-		/* re-enable the gasket */
-		writel(2, fep->hwp + FEC_MIIGSK_ENR);
-	}
+		/* 10M or 100M */
+		if (fep->phy_dev && fep->phy_dev->speed == SPEED_100)
+			val &= ~(1 << 9);
+		else
+			val |= (1 << 9);
+
+		writel(val, fep->hwp + FEC_R_CNTRL);
+	} else {
+#ifdef FEC_MIIGSK_ENR
+		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
+			/* disable the gasket and wait */
+			writel(0, fep->hwp + FEC_MIIGSK_ENR);
+			while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
+				udelay(1);
+
+			/*
+			 * configure the gasket:
+			 *   RMII, 50 MHz, no loopback, no echo
+			 */
+			writel(1, fep->hwp + FEC_MIIGSK_CFGR);
+
+			/* re-enable the gasket */
+			writel(2, fep->hwp + FEC_MIIGSK_ENR);
+		}
 #endif
+	}
 
 	/* And last, enable the transmit and receive processing */
 	writel(2, fep->hwp + FEC_ECNTRL);
@@ -1410,12 +1525,13 @@ static const struct dev_pm_ops fec_pm_ops = {
 
 static struct platform_driver fec_driver = {
 	.driver	= {
-		.name	= "fec",
+		.name	= DRIVER_NAME,
 		.owner	= THIS_MODULE,
 #ifdef CONFIG_PM
 		.pm	= &fec_pm_ops,
 #endif
 	},
+	.id_table = fec_devtype,
 	.probe	= fec_probe,
 	.remove	= __devexit_p(fec_drv_remove),
 };
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 2c48b25..ace318d 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -14,7 +14,8 @@
 /****************************************************************************/
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
+    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 /*
  *	Just figures, Motorola would have to change the offsets for
  *	registers in the same peripheral device on different models
@@ -78,7 +79,7 @@
 /*
  *	Define the buffer descriptor structure.
  */
-#ifdef CONFIG_ARCH_MXC
+#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 struct bufdesc {
 	unsigned short cbd_datlen;	/* Data length */
 	unsigned short cbd_sc;	/* Control and status info */
-- 
1.7.1


