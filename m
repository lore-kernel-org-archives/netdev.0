From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] skge: fiber link up/down fix
Date: Mon, 26 Nov 2007 11:54:51 -0800
Message-ID: <20071126195557.709511931@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43338 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753708AbXKZT7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 14:59:04 -0500
Content-Disposition: inline; filename=skge-link-down.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver would not work over fibre if other end when down then
came back up (would require reloading driver). The correct way
to manage the link the same way for both TP and fibre.

Resloves problem described in: 	 http://lkml.org/lkml/2007/11/6/395

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-11-21 14:44:02.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 14:46:34.000000000 -0800
@@ -1095,16 +1095,9 @@ static void xm_link_down(struct skge_hw 
 {
 	struct net_device *dev = hw->dev[port];
 	struct skge_port *skge = netdev_priv(dev);
-	u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
 
 	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 
-	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
-	xm_write16(hw, port, XM_MMU_CMD, cmd);
-
-	/* dummy read to ensure writing */
-	xm_read16(hw, port, XM_MMU_CMD);
-
 	if (netif_carrier_ok(dev))
 		skge_link_down(skge);
 }
@@ -1194,6 +1187,7 @@ static void genesis_init(struct skge_hw 
 static void genesis_reset(struct skge_hw *hw, int port)
 {
 	const u8 zero[8]  = { 0 };
+	u32 reg;
 
 	skge_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
 
@@ -1209,6 +1203,11 @@ static void genesis_reset(struct skge_hw
 		xm_write16(hw, port, PHY_BCOM_INT_MASK, 0xffff);
 
 	xm_outhash(hw, port, XM_HSM, zero);
+
+	/* Flush TX and RX fifo */
+	reg = xm_read32(hw, port, XM_MODE);
+	xm_write32(hw, port, XM_MODE, reg | XM_MD_FTF);
+	xm_write32(hw, port, XM_MODE, reg | XM_MD_FRF);
 }
 
 
@@ -1714,6 +1713,12 @@ static void genesis_stop(struct skge_por
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 	unsigned retries = 1000;
+	u16 cmd;
+
+ 	/* Disable Tx and Rx */
+	cmd = xm_read16(hw, port, XM_MMU_CMD);
+	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
+	xm_write16(hw, port, XM_MMU_CMD, cmd);
 
 	genesis_reset(hw, port);
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

