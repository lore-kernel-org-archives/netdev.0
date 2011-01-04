From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Tue, 4 Jan 2011 17:24:11 +0800
Message-ID: <1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:34560
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752096Ab1ADJXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:23:14 -0500
In-Reply-To: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add mx28 dual fec support. Here are some key notes
for mx28 fec controller.

 - mx28 fec design made an assumption that it runs on a
   big-endian system, which is incorrect. As the result, the
   driver has to swap every frame going to and coming from
   the controller.
 - external phys can only be configured by fec0, which means
   fec1 can not work independently and both phys need to be
   configured by mii_bus attached on fec0.
 - mx28 fec reset will get mac address registers reset too.
 - MII/RMII mode and 10M/100M speed are configured differently
   from i.mx/mxs fec controller.
 - ETHER_EN bit must be set to get interrupt work.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v2:
 - Use module parameter fec.macaddr over new kernel command line
   fec_mac to pass mac address
 - Update comment in fec_get_mac() to stop using confusing word
   "default"
 - Fix copyright breakage in fec.h

 drivers/net/Kconfig |    7 ++-
 drivers/net/fec.c   |  139 ++++++++++++++++++++++++++++++++++++++++----------
 drivers/net/fec.h   |    5 +-
 include/linux/fec.h |    3 +-
 4 files changed, 120 insertions(+), 34 deletions(-)

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
index f147508..b2b3e37 100644
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
@@ -45,21 +47,34 @@
 
 #include <asm/cacheflush.h>
 
-#ifndef CONFIG_ARCH_MXC
+#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
 #include <asm/coldfire.h>
 #include <asm/mcfsim.h>
 #endif
 
 #include "fec.h"
 
-#ifdef CONFIG_ARCH_MXC
-#include <mach/hardware.h>
+#ifdef CONFIG_SOC_IMX28
+/*
+ * mx28 does not have MIIGSK registers
+ */
+#undef FEC_MIIGSK_ENR
+#include <mach/mxs.h>
+#else
+#define cpu_is_mx28()	(0)
+#endif
+
+#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 #define FEC_ALIGNMENT	0xf
 #else
 #define FEC_ALIGNMENT	0x3
 #endif
 
-static unsigned char fec_mac_default[ETH_ALEN];
+static unsigned char macaddr[ETH_ALEN];
+module_param_array(macaddr, byte, NULL, 0);
+MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
+
+static struct mii_bus *fec_mii_bus;
 
 #if defined(CONFIG_M5272)
 /*
@@ -127,7 +142,8 @@ static unsigned char fec_mac_default[ETH_ALEN];
  * account when setting it.
  */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
+    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
 #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 #else
 #define	OPT_FRAME_SIZE	0
@@ -206,6 +222,17 @@ static void fec_stop(struct net_device *dev);
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
 
+static void *swap_buffer(void *bufaddr, int len)
+{
+	int i;
+	unsigned int *buf = bufaddr;
+
+	for (i = 0; i < (len + 3) / 4; i++, buf++)
+		*buf = __swab32(*buf);
+
+	return bufaddr;
+}
+
 static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -254,6 +281,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		bufaddr = fep->tx_bounce[index];
 	}
 
+	/*
+	 * mx28 fec design made an incorrect assumption that it's running
+	 * on a big endian system. As the result, the driver has to swap
+	 * every frame going to and coming from the controller.
+	 */
+	if (cpu_is_mx28())
+		swap_buffer(bufaddr, skb->len);
+
 	/* Save skb pointer */
 	fep->tx_skbuff[fep->skb_cur] = skb;
 
@@ -485,6 +520,9 @@ fec_enet_rx(struct net_device *dev)
 	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
         			DMA_FROM_DEVICE);
 
+		if (cpu_is_mx28())
+			swap_buffer(data, pkt_len);
+
 		/* This does 16 byte alignment, exactly what we need.
 		 * The packet length includes FCS, but we don't want to
 		 * include that when passing upstream as it messes up
@@ -540,9 +578,10 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 	/*
 	 * try to get mac address in following order:
 	 *
-	 * 1) kernel command line fec_mac=xx:xx:xx...
+	 * 1) module parameter via kernel command line in form
+	 *    fec.macaddr=0x00,0x04,0x9f,0x01,0x30,0xe0
 	 */
-	iap = fec_mac_default;
+	iap = macaddr;
 
 	/*
 	 * 2) from flash or fuse (via platform data)
@@ -570,9 +609,9 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 
 	memcpy(dev->dev_addr, iap, ETH_ALEN);
 
-	/* Adjust MAC if using default MAC address */
-	if (iap == fec_mac_default)
-		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->pdev->id;
+	/* Adjust MAC if using macaddr */
+	if (iap == macaddr)
+		 dev->dev_addr[ETH_ALEN-1] = macaddr[ETH_ALEN-1] + fep->pdev->id;
 }
 
 /* ------------------------------------------------------------------------- */
@@ -686,6 +725,7 @@ static int fec_enet_mii_probe(struct net_device *dev)
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
 	int phy_id;
+	int dev_id = fep->pdev->id;
 
 	fep->phy_dev = NULL;
 
@@ -697,6 +737,8 @@ static int fec_enet_mii_probe(struct net_device *dev)
 			continue;
 		if (fep->mii_bus->phy_map[phy_id]->phy_id == 0)
 			continue;
+		if (cpu_is_mx28() && dev_id--)
+			continue;
 		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
 		break;
 	}
@@ -738,6 +780,28 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	struct fec_enet_private *fep = netdev_priv(dev);
 	int err = -ENXIO, i;
 
+	/*
+	 * The dual fec interfaces are not equivalent on mx28. Here are the
+	 * differences:
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
+	if (cpu_is_mx28() && pdev->id) {
+		/* fec1 uses fec0 mii_bus */
+		fep->mii_bus = fec_mii_bus;
+		return 0;
+	}
+
 	fep->mii_timeout = 0;
 
 	/*
@@ -774,6 +838,10 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
 
+	/* save fec0 mii_bus */
+	if (cpu_is_mx28())
+		fec_mii_bus = fep->mii_bus;
+
 	return 0;
 
 err_out_free_mdio_irq:
@@ -1069,24 +1137,6 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_do_ioctl           = fec_enet_ioctl,
 };
 
-static int __init fec_mac_addr_setup(char *mac_addr)
-{
-	int i;
-	unsigned int tmp;
-
-	for (i = 0; i < ETH_ALEN; i++) {
-		if (sscanf(mac_addr + 3*i, "%2x", &tmp) != 1) {
-			printk(KERN_WARNING "Malformed fec mac address\n");
-			return 0;
-		}
-		fec_mac_default[i] = tmp;
-	}
-
-	return 1;
-}
-
-__setup("fec_mac=", fec_mac_addr_setup);
-
  /*
   * XXX:  We need to clean up on failure exits here.
   *
@@ -1164,11 +1214,22 @@ fec_restart(struct net_device *dev, int duplex)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	int i;
+	u32 val, temp_mac[2];
 
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
+	/*
+	 * The fec reset on mx28 will reset mac address too,
+	 * so need to reconfigure it.
+	 */
+	if (cpu_is_mx28()) {
+		memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
+		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
+		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
+	}
+
 	/* Clear any outstanding interrupt. */
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
@@ -1215,6 +1276,28 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
+	/*
+	 * The phy interface and speed need to get configured
+	 * differently on mx28.
+	 */
+	if (cpu_is_mx28()) {
+		val = readl(fep->hwp + FEC_R_CNTRL);
+
+		/* MII or RMII */
+		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
+			val |= (1 << 8);
+		else
+			val &= ~(1 << 8);
+
+		/* 10M or 100M */
+		if (fep->phy_dev && fep->phy_dev->speed == SPEED_100)
+			val &= ~(1 << 9);
+		else
+			val |= (1 << 9);
+
+		writel(val, fep->hwp + FEC_R_CNTRL);
+	}
+
 #ifdef FEC_MIIGSK_ENR
 	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
 		/* disable the gasket and wait */
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
diff --git a/include/linux/fec.h b/include/linux/fec.h
index bf0c69f..bcff455 100644
--- a/include/linux/fec.h
+++ b/include/linux/fec.h
@@ -1,9 +1,10 @@
 /* include/linux/fec.h
  *
  * Copyright (c) 2009 Orex Computed Radiography
- * Copyright (C) 2010 Freescale Semiconductor, Inc.
  *   Baruch Siach <baruch@tkos.co.il>
  *
+ * Copyright (C) 2010 Freescale Semiconductor, Inc.
+ *
  * Header file for the FEC platform data
  *
  * This program is free software; you can redistribute it and/or modify
-- 
1.7.1


