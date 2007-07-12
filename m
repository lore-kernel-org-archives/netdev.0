From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] skge: fiber carrier handling
Date: Thu, 12 Jul 2007 14:56:01 -0700
Message-ID: <20070712145601.72417b42@freepuppy.rosehill.hemminger.net>
References: <20070710183953.GA8898@havoc.gtf.org>
	<Pine.LNX.4.64.0707111128330.31463@twin.jikos.cz>
	<Pine.LNX.4.64.0707110920270.11697@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jikos@jikos.cz>, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38686 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758458AbXGLV4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 17:56:30 -0400
In-Reply-To: <Pine.LNX.4.64.0707110920270.11697@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does this fix your problems?  I don't have dual port boards but have an old SK-9843 fiber board.
====

The XM PHY can give IRQ on lost carrier, which is better than polling.
This version also solves an number of bonding/carrier related bugs.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-07-12 14:19:55.000000000 -0700
+++ b/drivers/net/skge.c	2007-07-12 14:53:39.000000000 -0700
@@ -1091,13 +1091,7 @@ static void xm_link_down(struct skge_hw 
 {
 	struct net_device *dev = hw->dev[port];
 	struct skge_port *skge = netdev_priv(dev);
-	u16 cmd, msk;
-
-	if (hw->phy_type == SK_PHY_XMAC) {
-		msk = xm_read16(hw, port, XM_IMSK);
-		msk |= XM_IS_INP_ASS | XM_IS_LIPA_RC | XM_IS_RX_PAGE | XM_IS_AND;
-		xm_write16(hw, port, XM_IMSK, msk);
-	}
+	u16 cmd;
 
 	cmd = xm_read16(hw, port, XM_MMU_CMD);
 	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
@@ -1107,6 +1101,10 @@ static void xm_link_down(struct skge_hw 
 
 	if (netif_carrier_ok(dev))
 		skge_link_down(skge);
+
+	/* If needed start polling for link to come up */
+	if (netif_running(dev) && hw->phy_type == SK_PHY_XMAC)
+		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static int __xm_phy_read(struct skge_hw *hw, int port, u16 reg, u16 *val)
@@ -1434,30 +1432,25 @@ static void xm_phy_init(struct skge_port
 
 	xm_phy_write(hw, port, PHY_XMAC_CTRL, ctrl);
 
-	/* Poll PHY for status changes */
-	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
+	/* Poll for link coming up */
+	mod_timer(&skge->link_timer, jiffies);
 }
 
-static void xm_check_link(struct net_device *dev)
+/* Check status of link and change state */
+static void xm_link_up(struct skge_port *skge)
 {
-	struct skge_port *skge = netdev_priv(dev);
+	struct net_device *dev = skge->netdev;
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u16 status;
-
-	/* read twice because of latch */
-	(void) xm_phy_read(hw, port, PHY_XMAC_STAT);
-	status = xm_phy_read(hw, port, PHY_XMAC_STAT);
+	u16 isrc = xm_read16(hw, port, XM_ISRC);
 
-	if ((status & PHY_ST_LSYNC) == 0) {
-		xm_link_down(hw, port);
-		return;
-	}
+	if (netif_msg_intr(skge))
+		printk(KERN_DEBUG PFX "%s: fiber status %#x\n", dev->name, isrc);
 
 	if (skge->autoneg == AUTONEG_ENABLE) {
 		u16 lpa, res;
 
-		if (!(status & PHY_ST_AN_OVER))
+		if (!(isrc & XM_IS_AND))
 			return;
 
 		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
@@ -1506,10 +1499,7 @@ static void xm_check_link(struct net_dev
 		genesis_link_up(skge);
 }
 
-/* Poll to check for link coming up.
- * Since internal PHY is wired to a level triggered pin, can't
- * get an interrupt when carrier is detected.
- */
+/* Poll to check for link coming up. */
 static void xm_link_timer(unsigned long arg)
 {
 	struct skge_port *skge = (struct skge_port *) arg;
@@ -1520,23 +1510,18 @@ static void xm_link_timer(unsigned long 
 	if (!netif_running(dev))
 		return;
 
-	if (netif_carrier_ok(dev)) {
-		xm_read16(hw, port, XM_ISRC);
-		if (!(xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS))
-			goto nochange;
-	} else {
-		if (xm_read32(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
-			goto nochange;
-		xm_read16(hw, port, XM_ISRC);
-		if (xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS)
-			goto nochange;
-	}
+	if (xm_read32(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
+		goto resync;
 
 	spin_lock(&hw->phy_lock);
-	xm_check_link(dev);
+	xm_link_up(skge);
 	spin_unlock(&hw->phy_lock);
 
-nochange:
+	/* Link up, timer no longer needed */
+	if (netif_carrier_ok(dev))
+		return;
+
+resync:
 	if (netif_running(dev))
 		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
@@ -1593,6 +1578,9 @@ static void genesis_mac_init(struct skge
 		bcom_check_link(hw, port);
 	}
 
+	/* Clear any irq */
+	xm_read16(hw, port, XM_ISRC);
+
 	/* Set Station Address */
 	xm_outaddr(hw, port, XM_SA, dev->dev_addr);
 
@@ -1782,8 +1770,7 @@ static void genesis_mac_intr(struct skge
 		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
 		       skge->netdev->name, status);
 
-	if (hw->phy_type == SK_PHY_XMAC &&
-	    (status & (XM_IS_INP_ASS | XM_IS_LIPA_RC)))
+	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS))
 		xm_link_down(hw, port);
 
 	if (status & XM_IS_TXF_UR) {
