From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] skge: internal stats
Date: Tue, 16 Oct 2007 12:15:52 -0700
Message-ID: <20071016191734.066569112@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53946 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934099AbXJPTTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:36 -0400
Content-Disposition: inline; filename=skge-stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use internal stats structure 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/skge.c	2007-10-16 11:23:09.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 11:23:14.000000000 -0700
@@ -445,15 +445,15 @@ static struct net_device_stats *skge_get
 	else
 		yukon_get_stats(skge, data);
 
-	skge->net_stats.tx_bytes = data[0];
-	skge->net_stats.rx_bytes = data[1];
-	skge->net_stats.tx_packets = data[2] + data[4] + data[6];
-	skge->net_stats.rx_packets = data[3] + data[5] + data[7];
-	skge->net_stats.multicast = data[3] + data[5];
-	skge->net_stats.collisions = data[10];
-	skge->net_stats.tx_aborted_errors = data[12];
+	dev->stats.tx_bytes = data[0];
+	dev->stats.rx_bytes = data[1];
+	dev->stats.tx_packets = data[2] + data[4] + data[6];
+	dev->stats.rx_packets = data[3] + data[5] + data[7];
+	dev->stats.multicast = data[3] + data[5];
+	dev->stats.collisions = data[10];
+	dev->stats.tx_aborted_errors = data[12];
 
-	return &skge->net_stats;
+	return &dev->stats;
 }
 
 static void skge_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -1684,12 +1684,13 @@ static void genesis_get_stats(struct skg
 
 static void genesis_mac_intr(struct skge_hw *hw, int port)
 {
-	struct skge_port *skge = netdev_priv(hw->dev[port]);
+	struct net_device *dev = hw->dev[port];
+	struct skge_port *skge = netdev_priv(dev);
 	u16 status = xm_read16(hw, port, XM_ISRC);
 
 	if (netif_msg_intr(skge))
 		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
-		       skge->netdev->name, status);
+		       dev->name, status);
 
 	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS)) {
   		xm_link_down(hw, port);
@@ -1698,12 +1699,12 @@ static void genesis_mac_intr(struct skge
 
 	if (status & XM_IS_TXF_UR) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
-		++skge->net_stats.tx_fifo_errors;
+		++dev->stats.tx_fifo_errors;
 	}
 
 	if (status & XM_IS_RXF_OV) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FRF);
-		++skge->net_stats.rx_fifo_errors;
+		++dev->stats.rx_fifo_errors;
 	}
 }
 
@@ -2200,12 +2201,12 @@ static void yukon_mac_intr(struct skge_h
 		       dev->name, status);
 
 	if (status & GM_IS_RX_FF_OR) {
-		++skge->net_stats.rx_fifo_errors;
+		++dev->stats.rx_fifo_errors;
 		skge_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_CLI_RX_FO);
 	}
 
 	if (status & GM_IS_TX_FF_UR) {
-		++skge->net_stats.tx_fifo_errors;
+		++dev->stats.tx_fifo_errors;
 		skge_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_CLI_TX_FU);
 	}
 
@@ -3039,18 +3040,18 @@ error:
 
 	if (skge->hw->chip_id == CHIP_ID_GENESIS) {
 		if (status & (XMR_FS_RUNT|XMR_FS_LNG_ERR))
-			skge->net_stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (status & XMR_FS_FRA_ERR)
-			skge->net_stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & XMR_FS_FCS_ERR)
-			skge->net_stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		if (status & (GMR_FS_LONG_ERR|GMR_FS_UN_SIZE))
-			skge->net_stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (status & GMR_FS_FRAGMENT)
-			skge->net_stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & GMR_FS_CRC_ERR)
-			skge->net_stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	}
 
 resubmit:
@@ -3148,10 +3149,7 @@ static void skge_mac_parity(struct skge_
 {
 	struct net_device *dev = hw->dev[port];
 
-	if (dev) {
-		struct skge_port *skge = netdev_priv(dev);
-		++skge->net_stats.tx_heartbeat_errors;
-	}
+	++dev->stats.tx_heartbeat_errors;
 
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1),
@@ -3304,9 +3302,7 @@ static irqreturn_t skge_intr(int irq, vo
 		skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_TX1);
 
 	if (status & IS_PA_TO_RX1) {
-		struct skge_port *skge = netdev_priv(hw->dev[0]);
-
-		++skge->net_stats.rx_over_errors;
+		++hw->dev[0]->stats.rx_over_errors;
 		skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_RX1);
 	}
 
@@ -3323,7 +3319,7 @@ static irqreturn_t skge_intr(int irq, vo
 		}
 
 		if (status & IS_PA_TO_RX2) {
-			++skge->net_stats.rx_over_errors;
+			++hw->dev[1]->stats.rx_over_errors;
 			skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_RX2);
 		}
 
--- a/drivers/net/skge.h	2007-10-16 11:23:09.000000000 -0700
+++ b/drivers/net/skge.h	2007-10-16 11:23:14.000000000 -0700
@@ -2467,8 +2467,6 @@ struct skge_port {
 	void		     *mem;	/* PCI memory for rings */
 	dma_addr_t	     dma;
 	unsigned long	     mem_size;
-
-	struct net_device_stats net_stats;
 };
 
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

