From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] skge: XM PHY handling fixes
Date: Tue, 16 Oct 2007 12:15:51 -0700
Message-ID: <20071016191734.017624366@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40952 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934577AbXJPTTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:39 -0400
Content-Disposition: inline; filename=skge-xm-phy-poll.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change how PHY is managed on SysKonnect fibre based boards.
Poll for PHY coming up 1 per second, but use interrupt to detect loss.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-10-16 12:14:08.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 12:14:09.000000000 -0700
@@ -57,7 +57,7 @@
 #define TX_WATCHDOG		(5 * HZ)
 #define NAPI_WEIGHT		64
 #define BLINK_MS		250
-#define LINK_HZ			(HZ/2)
+#define LINK_HZ			HZ
 
 MODULE_DESCRIPTION("SysKonnect Gigabit Ethernet driver");
 MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
@@ -995,19 +995,15 @@ static void xm_link_down(struct skge_hw 
 {
 	struct net_device *dev = hw->dev[port];
 	struct skge_port *skge = netdev_priv(dev);
-	u16 cmd, msk;
+	u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
 
-	if (hw->phy_type == SK_PHY_XMAC) {
-		msk = xm_read16(hw, port, XM_IMSK);
-		msk |= XM_IS_INP_ASS | XM_IS_LIPA_RC | XM_IS_RX_PAGE | XM_IS_AND;
-		xm_write16(hw, port, XM_IMSK, msk);
-	}
+	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 
-	cmd = xm_read16(hw, port, XM_MMU_CMD);
 	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
 	xm_write16(hw, port, XM_MMU_CMD, cmd);
+
 	/* dummy read to ensure writing */
-	(void) xm_read16(hw, port, XM_MMU_CMD);
+	xm_read16(hw, port, XM_MMU_CMD);
 
 	if (netif_carrier_ok(dev))
 		skge_link_down(skge);
@@ -1103,7 +1099,7 @@ static void genesis_reset(struct skge_hw
 
 	/* reset the statistics module */
 	xm_write32(hw, port, XM_GP_PORT, XM_GP_RES_STAT);
-	xm_write16(hw, port, XM_IMSK, 0xffff);	/* disable XMAC IRQs */
+	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 	xm_write32(hw, port, XM_MODE, 0);		/* clear Mode Reg */
 	xm_write16(hw, port, XM_TX_CMD, 0);	/* reset TX CMD Reg */
 	xm_write16(hw, port, XM_RX_CMD, 0);	/* reset RX CMD Reg */
@@ -1141,7 +1137,7 @@ static void bcom_check_link(struct skge_
 	u16 status;
 
 	/* read twice because of latch */
-	(void) xm_phy_read(hw, port, PHY_BCOM_STAT);
+	xm_phy_read(hw, port, PHY_BCOM_STAT);
 	status = xm_phy_read(hw, port, PHY_BCOM_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
@@ -1342,7 +1338,7 @@ static void xm_phy_init(struct skge_port
 	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
-static void xm_check_link(struct net_device *dev)
+static int xm_check_link(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
@@ -1350,25 +1346,25 @@ static void xm_check_link(struct net_dev
 	u16 status;
 
 	/* read twice because of latch */
-	(void) xm_phy_read(hw, port, PHY_XMAC_STAT);
+	xm_phy_read(hw, port, PHY_XMAC_STAT);
 	status = xm_phy_read(hw, port, PHY_XMAC_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
 		xm_link_down(hw, port);
-		return;
+		return 0;
 	}
 
 	if (skge->autoneg == AUTONEG_ENABLE) {
 		u16 lpa, res;
 
 		if (!(status & PHY_ST_AN_OVER))
-			return;
+			return 0;
 
 		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
 		if (lpa & PHY_B_AN_RF) {
 			printk(KERN_NOTICE PFX "%s: remote fault\n",
 			       dev->name);
-			return;
+			return 0;
 		}
 
 		res = xm_phy_read(hw, port, PHY_XMAC_RES_ABI);
@@ -1384,7 +1380,7 @@ static void xm_check_link(struct net_dev
 		default:
 			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
 			       dev->name);
-			return;
+			return 0;
 		}
 
 		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
@@ -1408,11 +1404,14 @@ static void xm_check_link(struct net_dev
 
 	if (!netif_carrier_ok(dev))
 		genesis_link_up(skge);
+	return 1;
 }
 
 /* Poll to check for link coming up.
+ *
  * Since internal PHY is wired to a level triggered pin, can't
- * get an interrupt when carrier is detected.
+ * get an interrupt when carrier is detected, need to poll for
+ * link coming up.
  */
 static void xm_link_timer(unsigned long arg)
 {
@@ -1420,29 +1419,35 @@ static void xm_link_timer(unsigned long 
 	struct net_device *dev = skge->netdev;
  	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
+	int i;
+	unsigned long flags;
 
 	if (!netif_running(dev))
 		return;
 
-	if (netif_carrier_ok(dev)) {
+	spin_lock_irqsave(&hw->phy_lock, flags);
+
+	/*
+	 * Verify that the link by checking GPIO register three times.
+	 * This pin has the signal from the link_sync pin connected to it.
+	 */
+	for (i = 0; i < 3; i++) {
+		if (xm_read16(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
+			goto link_down;
+	}
+
+        /* Re-enable interrupt to detect link down */
+	if (xm_check_link(dev)) {
+		u16 msk = xm_read16(hw, port, XM_IMSK);
+		msk &= ~XM_IS_INP_ASS;
+		xm_write16(hw, port, XM_IMSK, msk);
 		xm_read16(hw, port, XM_ISRC);
-		if (!(xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS))
-			goto nochange;
 	} else {
-		if (xm_read32(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
-			goto nochange;
-		xm_read16(hw, port, XM_ISRC);
-		if (xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS)
-			goto nochange;
+link_down:
+		mod_timer(&skge->link_timer,
+			  round_jiffies(jiffies + LINK_HZ));
 	}
-
-	spin_lock(&hw->phy_lock);
-	xm_check_link(dev);
-	spin_unlock(&hw->phy_lock);
-
-nochange:
-	if (netif_running(dev))
-		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
+	spin_unlock_irqrestore(&hw->phy_lock, flags);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -1686,14 +1691,16 @@ static void genesis_mac_intr(struct skge
 		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
 		       skge->netdev->name, status);
 
-	if (hw->phy_type == SK_PHY_XMAC &&
-	    (status & (XM_IS_INP_ASS | XM_IS_LIPA_RC)))
-		xm_link_down(hw, port);
+	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS)) {
+  		xm_link_down(hw, port);
+		mod_timer(&skge->link_timer, jiffies + 1);
+	}
 
 	if (status & XM_IS_TXF_UR) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
 		++skge->net_stats.tx_fifo_errors;
 	}
+
 	if (status & XM_IS_RXF_OV) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FRF);
 		++skge->net_stats.rx_fifo_errors;
@@ -1753,11 +1760,12 @@ static void genesis_link_up(struct skge_
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
-	msk = XM_DEF_MSK;
-	if (hw->phy_type != SK_PHY_XMAC)
-		msk |= XM_IS_INP_ASS;	/* disable GP0 interrupt bit */
 
+	/* Turn on detection of Tx underrun, Rx overrun */
+	msk = xm_read16(hw, port, XM_IMSK);
+	msk &= ~(XM_IS_RXF_OV | XM_IS_TXF_UR);
 	xm_write16(hw, port, XM_IMSK, msk);
+
 	xm_read16(hw, port, XM_ISRC);
 
 	/* get MMU Command Reg. */
--- a/drivers/net/skge.h	2007-10-16 10:57:54.000000000 -0700
+++ b/drivers/net/skge.h	2007-10-16 12:14:09.000000000 -0700
@@ -2191,11 +2191,9 @@ enum {
 	XM_IS_TXF_UR	= 1<<2,	/* Bit  2:	Transmit FIFO Underrun */
 	XM_IS_TX_COMP	= 1<<1,	/* Bit  1:	Frame Tx Complete */
 	XM_IS_RX_COMP	= 1<<0,	/* Bit  0:	Frame Rx Complete */
-};
-
-#define XM_DEF_MSK	(~(XM_IS_INP_ASS | XM_IS_LIPA_RC | \
-			   XM_IS_RXF_OV | XM_IS_TXF_UR))
 
+	XM_IMSK_DISABLE	= 0xffff,
+};
 
 /*	XM_HW_CFG	16 bit r/w	Hardware Config Register */
 enum {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

