From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 10/11] netdev: bfin_mac: handle timeouts with the MDIO registers gracefully
Date: Sun,  9 May 2010 06:18:56 -0400
Message-ID: <1273400337-26501-10-git-send-email-vapier@gentoo.org>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53277 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab0EIKQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 06:16:16 -0400
In-Reply-To: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have the low level MDIO functions pass back up timeout information so we
don't waste time polling them multiple times when there is a problem, and
so we don't let higher layers think the device is available when it isn't.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   53 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 00d0f25..a4c9ab2 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -81,9 +81,6 @@ static u16 pin_req[] = P_RMII0;
 static u16 pin_req[] = P_MII0;
 #endif
 
-static void bfin_mac_disable(void);
-static void bfin_mac_enable(void);
-
 static void desc_list_free(void)
 {
 	struct net_dma_desc_rx *r;
@@ -260,7 +257,7 @@ init_error:
  * MII operations
  */
 /* Wait until the previous MDC/MDIO transaction has completed */
-static void bfin_mdio_poll(void)
+static int bfin_mdio_poll(void)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
 
@@ -270,22 +267,30 @@ static void bfin_mdio_poll(void)
 		if (timeout_cnt-- < 0) {
 			printk(KERN_ERR DRV_NAME
 			": wait MDC/MDIO transaction to complete timeout\n");
-			break;
+			return -ETIMEDOUT;
 		}
 	}
+
+	return 0;
 }
 
 /* Read an off-chip register in a PHY through the MDC/MDIO port */
 static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
-	bfin_mdio_poll();
+	int ret;
+
+	ret = bfin_mdio_poll();
+	if (ret)
+		return ret;
 
 	/* read mode */
 	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
 				SET_REGAD((u16) regnum) |
 				STABUSY);
 
-	bfin_mdio_poll();
+	ret = bfin_mdio_poll();
+	if (ret)
+		return ret;
 
 	return (int) bfin_read_EMAC_STADAT();
 }
@@ -294,7 +299,11 @@ static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 			      u16 value)
 {
-	bfin_mdio_poll();
+	int ret;
+
+	ret = bfin_mdio_poll();
+	if (ret)
+		return ret;
 
 	bfin_write_EMAC_STADAT((u32) value);
 
@@ -304,9 +313,7 @@ static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 				STAOP |
 				STABUSY);
 
-	bfin_mdio_poll();
-
-	return 0;
+	return bfin_mdio_poll();
 }
 
 static int bfin_mdiobus_reset(struct mii_bus *bus)
@@ -1184,8 +1191,9 @@ static void bfin_mac_disable(void)
 /*
  * Enable Interrupts, Receive, and Transmit
  */
-static void bfin_mac_enable(void)
+static int bfin_mac_enable(void)
 {
+	int ret;
 	u32 opmode;
 
 	pr_debug("%s: %s\n", DRV_NAME, __func__);
@@ -1195,7 +1203,9 @@ static void bfin_mac_enable(void)
 	bfin_write_DMA1_CONFIG(rx_list_head->desc_a.config);
 
 	/* Wait MII done */
-	bfin_mdio_poll();
+	ret = bfin_mdio_poll();
+	if (ret)
+		return ret;
 
 	/* We enable only RX here */
 	/* ASTP   : Enable Automatic Pad Stripping
@@ -1219,6 +1229,8 @@ static void bfin_mac_enable(void)
 #endif
 	/* Turn on the EMAC rx */
 	bfin_write_EMAC_OPMODE(opmode);
+
+	return 0;
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -1333,7 +1345,7 @@ static void bfin_mac_shutdown(struct net_device *dev)
 static int bfin_mac_open(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	int retval;
+	int ret;
 	pr_debug("%s: %s\n", dev->name, __func__);
 
 	/*
@@ -1347,18 +1359,21 @@ static int bfin_mac_open(struct net_device *dev)
 	}
 
 	/* initial rx and tx list */
-	retval = desc_list_init();
-
-	if (retval)
-		return retval;
+	ret = desc_list_init();
+	if (ret)
+		return ret;
 
 	phy_start(lp->phydev);
 	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
 	setup_mac_addr(dev->dev_addr);
+
 	bfin_mac_disable();
-	bfin_mac_enable();
+	ret = bfin_mac_enable();
+	if (ret)
+		return ret;
 	pr_debug("hardware init finished\n");
+
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
 
-- 
1.7.1

