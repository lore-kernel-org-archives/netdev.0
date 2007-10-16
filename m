From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] skge: fix ram buffer size calculation
Date: Tue, 16 Oct 2007 12:15:49 -0700
Message-ID: <20071016191733.868358630@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57743 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751203AbXJPTSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:18:50 -0400
Content-Disposition: inline; filename=skge-ram-buffer-fix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes problems with transmit hangs on older fiber based SysKonnect boards.

Adjust ram buffer sizing calculation to make it correct on all boards
and make it like the code in sky2 driver. 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/skge.c	2007-10-16 10:55:13.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 10:55:33.000000000 -0700
@@ -2403,32 +2403,31 @@ static int skge_ioctl(struct net_device 
 	return err;
 }
 
-static void skge_ramset(struct skge_hw *hw, u16 q, u32 start, size_t len)
+/* Assign Ram Buffer allocation to queue */
+static void skge_ramset(struct skge_hw *hw, u16 q, u32 start, u32 space)
 {
 	u32 end;
 
-	start /= 8;
-	len /= 8;
-	end = start + len - 1;
+	/* convert from K bytes to qwords used for hw register */
+	start *= 1024/8;
+	space *= 1024/8;
+	end = start + space - 1;
 
 	skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_RST_CLR);
 	skge_write32(hw, RB_ADDR(q, RB_START), start);
+	skge_write32(hw, RB_ADDR(q, RB_END), end);
 	skge_write32(hw, RB_ADDR(q, RB_WP), start);
 	skge_write32(hw, RB_ADDR(q, RB_RP), start);
-	skge_write32(hw, RB_ADDR(q, RB_END), end);
 
 	if (q == Q_R1 || q == Q_R2) {
+		u32 tp = space - space/4;
+
 		/* Set thresholds on receive queue's */
-		skge_write32(hw, RB_ADDR(q, RB_RX_UTPP),
-			     start + (2*len)/3);
-		skge_write32(hw, RB_ADDR(q, RB_RX_LTPP),
-			     start + (len/3));
-	} else {
-		/* Enable store & forward on Tx queue's because
-		 * Tx FIFO is only 4K on Genesis and 1K on Yukon
-		 */
+		skge_write32(hw, RB_ADDR(q, RB_RX_UTPP), tp);
+		skge_write32(hw, RB_ADDR(q, RB_RX_LTPP), space/4);
+	} else if (hw->chip_id != CHIP_ID_GENESIS)
+		/* Genesis Tx Fifo is too small for normal store/forward */
 		skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_ENA_STFWD);
-	}
 
 	skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_ENA_OP_MD);
 }
@@ -2456,7 +2455,7 @@ static int skge_up(struct net_device *de
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u32 chunk, ram_addr;
+	u32 ramaddr, ramsize, rxspace;
 	size_t rx_size, tx_size;
 	int err;
 
@@ -2511,14 +2510,15 @@ static int skge_up(struct net_device *de
 	spin_unlock_bh(&hw->phy_lock);
 
 	/* Configure RAMbuffers */
-	chunk = hw->ram_size / ((hw->ports + 1)*2);
-	ram_addr = hw->ram_offset + 2 * chunk * port;
+	ramsize = (hw->ram_size - hw->ram_offset) / hw->ports;
+	ramaddr = hw->ram_offset + port * ramsize;
+	rxspace = 8 + (2*(ramsize - 16))/3;
 
-	skge_ramset(hw, rxqaddr[port], ram_addr, chunk);
-	skge_qset(skge, rxqaddr[port], skge->rx_ring.to_clean);
+	skge_ramset(hw, rxqaddr[port], ramaddr, rxspace);
+	skge_ramset(hw, txqaddr[port], ramaddr + rxspace, ramsize - rxspace);
 
+	skge_qset(skge, rxqaddr[port], skge->rx_ring.to_clean);
 	BUG_ON(skge->tx_ring.to_use != skge->tx_ring.to_clean);
-	skge_ramset(hw, txqaddr[port], ram_addr+chunk, chunk);
 	skge_qset(skge, txqaddr[port], skge->tx_ring.to_use);
 
 	/* Start receiver BMU */
@@ -3450,15 +3450,12 @@ static int skge_reset(struct skge_hw *hw
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		if (t8 == 3) {
 			/* special case: 4 x 64k x 36, offset = 0x80000 */
-			hw->ram_size = 0x100000;
-			hw->ram_offset = 0x80000;
+			hw->ram_size = 1024;
+			hw->ram_offset = 512;
 		} else
 			hw->ram_size = t8 * 512;
-	}
-	else if (t8 == 0)
-		hw->ram_size = 0x20000;
-	else
-		hw->ram_size = t8 * 4096;
+	} else /* Yukon */
+		hw->ram_size = t8 ? t8 * 4 : 128;
 
 	hw->intr_mask = IS_HW_ERR;
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

