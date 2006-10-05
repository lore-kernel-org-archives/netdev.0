From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/4] skge: fix stuck irq when fiber down
Date: Thu, 05 Oct 2006 15:49:50 -0700
Message-ID: <20061005225209.242959391@osdl.org>
References: <20061005224949.456192755@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15056 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932438AbWJEX4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:56:05 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-irq-link-down.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY interrupt from the internal fiber is getting
stuck on when the link is down. Add code to handle the
transition and mask it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/skge.c |   53 +++++++++++++++++++++++++++++++++++------------------
 drivers/net/skge.h |    3 ++-
 2 files changed, 37 insertions(+), 19 deletions(-)

--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -884,6 +884,29 @@ static void skge_link_down(struct skge_p
 		printk(KERN_INFO PFX "%s: Link is down.\n", skge->netdev->name);
 }
 
+
+static void xm_link_down(struct skge_hw *hw, int port)
+{
+	struct net_device *dev = hw->dev[port];
+	struct skge_port *skge = netdev_priv(dev);
+	u16 cmd, msk;
+
+	if (hw->phy_type == SK_PHY_XMAC) {
+		msk = xm_read16(hw, port, XM_IMSK);
+		msk |= XM_IS_INP_ASS | XM_IS_LIPA_RC | XM_IS_RX_PAGE | XM_IS_AND;
+		xm_write16(hw, port, XM_IMSK, msk);
+	}
+
+	cmd = xm_read16(hw, port, XM_MMU_CMD);
+	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
+	xm_write16(hw, port, XM_MMU_CMD, cmd);
+	/* dummy read to ensure writing */
+	(void) xm_read16(hw, port, XM_MMU_CMD);
+
+	if (netif_carrier_ok(dev))
+		skge_link_down(skge);
+}
+
 static int __xm_phy_read(struct skge_hw *hw, int port, u16 reg, u16 *val)
 {
 	int i;
@@ -1008,14 +1031,7 @@ static void bcom_check_link(struct skge_
 	status = xm_phy_read(hw, port, PHY_BCOM_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
-		u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
-		cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
-		xm_write16(hw, port, XM_MMU_CMD, cmd);
-		/* dummy read to ensure writing */
-		(void) xm_read16(hw, port, XM_MMU_CMD);
-
-		if (netif_carrier_ok(dev))
-			skge_link_down(skge);
+		xm_link_down(hw, port);
 		return;
 	}
 
@@ -1235,14 +1251,7 @@ static void xm_check_link(struct net_dev
 	status = xm_phy_read(hw, port, PHY_XMAC_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
-		u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
-		cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
-		xm_write16(hw, port, XM_MMU_CMD, cmd);
-		/* dummy read to ensure writing */
-		(void) xm_read16(hw, port, XM_MMU_CMD);
-
-		if (netif_carrier_ok(dev))
-			skge_link_down(skge);
+		xm_link_down(hw, port);
 		return;
 	}
 
@@ -1568,6 +1577,10 @@ static void genesis_mac_intr(struct skge
 		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
 		       skge->netdev->name, status);
 
+	if (hw->phy_type == SK_PHY_XMAC &&
+	    (status & (XM_IS_INP_ASS | XM_IS_LIPA_RC)))
+		xm_link_down(hw, port);
+
 	if (status & XM_IS_TXF_UR) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
 		++skge->net_stats.tx_fifo_errors;
@@ -1582,7 +1595,7 @@ static void genesis_link_up(struct skge_
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u16 cmd;
+	u16 cmd, msk;
 	u32 mode;
 
 	cmd = xm_read16(hw, port, XM_MMU_CMD);
@@ -1631,7 +1644,11 @@ static void genesis_link_up(struct skge_
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
-	xm_write16(hw, port, XM_IMSK, XM_DEF_MSK);
+	msk = XM_DEF_MSK;
+	if (hw->phy_type != SK_PHY_XMAC)
+		msk |= XM_IS_INP_ASS;	/* disable GP0 interrupt bit */
+
+	xm_write16(hw, port, XM_IMSK, msk);
 	xm_read16(hw, port, XM_ISRC);
 
 	/* get MMU Command Reg. */
--- linux-2.6.orig/drivers/net/skge.h
+++ linux-2.6/drivers/net/skge.h
@@ -2195,7 +2195,8 @@ enum {
 	XM_IS_RX_COMP	= 1<<0,	/* Bit  0:	Frame Rx Complete */
 };
 
-#define XM_DEF_MSK	(~(XM_IS_RXC_OV | XM_IS_TXC_OV | XM_IS_RXF_OV | XM_IS_TXF_UR))
+#define XM_DEF_MSK	(~(XM_IS_INP_ASS | XM_IS_LIPA_RC | \
+			   XM_IS_RXF_OV | XM_IS_TXF_UR))
 
 
 /*	XM_HW_CFG	16 bit r/w	Hardware Config Register */

--
Stephen Hemminger <shemminger@osdl.org>

