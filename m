From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/12) skge: fix race with receive interrupt and NAPI
Date: Thu, 3 Mar 2005 11:44:21 -0800
Message-ID: <20050303114421.5ce264b6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Avoid possible race with receive interrupt and NAPI.
Move code for chip specific mac interrupt out of main path.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-03 10:30:59.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 10:32:58.000000000 -0800
@@ -2709,6 +2709,14 @@
 	skge_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
+static void skge_mac_intr(struct skge_hw *hw, int port)
+{
+	if (hw->chip_id == CHIP_ID_GENESIS) 
+		genesis_mac_intr(hw, port);
+	else
+		yukon_mac_intr(hw, port);
+}
+
 /* Handle device specific framing and timeout interrupts */
 static void skge_error_irq(struct skge_hw *hw)
 {
@@ -2816,14 +2824,18 @@
 
 	status &= hw->intr_mask;
 
-	if (status & IS_R1_F) {
+	if ((status & IS_R1_F) && netif_rx_schedule_prep(hw->dev[0])) {
+		status &= ~IS_R1_F;
 		hw->intr_mask &= ~IS_R1_F;
-		netif_rx_schedule(hw->dev[0]);
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
+		__netif_rx_schedule(hw->dev[0]);
 	}
 
-	if (status & IS_R2_F) {
+	if ((status & IS_R2_F) && netif_rx_schedule_prep(hw->dev[1])) {
+		status &= ~IS_R2_F;
 		hw->intr_mask &= ~IS_R2_F;
-		netif_rx_schedule(hw->dev[1]);
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
+		__netif_rx_schedule(hw->dev[1]);
 	}
 
 	if (status & IS_XA1_F)
@@ -2832,19 +2844,11 @@
 	if (status & IS_XA2_F)
 		skge_tx_intr(hw->dev[1]);
 
-	if (hw->chip_id == CHIP_ID_GENESIS) {
-		if (status & IS_MAC1)
-			genesis_mac_intr(hw, 0);
-
-		if (status & IS_MAC2)
-			genesis_mac_intr(hw, 1);
-	} else {
-		if (status & IS_MAC1)
-			yukon_mac_intr(hw, 0);
-
-		if (status & IS_MAC2)
-			yukon_mac_intr(hw, 1);
-	}
+	if (status & IS_MAC1)
+		skge_mac_intr(hw, 0);
+	
+	if (status & IS_MAC2)
+		skge_mac_intr(hw, 1);
 
 	if (status & IS_HW_ERR)
 		skge_error_irq(hw);
@@ -2853,7 +2857,9 @@
 		hw->intr_mask &= ~IS_EXT_REG;
 		tasklet_schedule(&hw->ext_tasklet);
 	}
-	skge_write32(hw, B0_IMSK, hw->intr_mask);
+
+	if (status)
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
 
 	return IRQ_HANDLED;
 }
