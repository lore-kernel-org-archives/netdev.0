From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 3/6 resend] b44: add parameter
Date: Tue, 20 Jun 2006 15:34:26 -0700
Message-ID: <1150842866.21197.55.camel@dhcp-10-7-81-7.broadcom.com>
References: <1150485561.8716.52.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:50437 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751450AbWFTWe5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:34:57 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <1150485561.8716.52.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a parameter to init_hw() to not completely initialize
the nic for wol. 

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 73ca729..12fc67a 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -101,7 +101,7 @@ MODULE_DEVICE_TABLE(pci, b44_pci_tbl);
 
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
-static void b44_init_hw(struct b44 *);
+static void b44_init_hw(struct b44 *, int);
 
 static int dma_desc_align_mask;
 static int dma_desc_sync_size;
@@ -873,7 +873,7 @@ static int b44_poll(struct net_device *n
 		spin_lock_irq(&bp->lock);
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp);
+		b44_init_hw(bp, 1);
 		netif_wake_queue(bp->dev);
 		spin_unlock_irq(&bp->lock);
 		done = 1;
@@ -942,7 +942,7 @@ static void b44_tx_timeout(struct net_de
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, 1);
 
 	spin_unlock_irq(&bp->lock);
 
@@ -1059,7 +1059,7 @@ static int b44_change_mtu(struct net_dev
 	b44_halt(bp);
 	dev->mtu = new_mtu;
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, 1);
 	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
@@ -1356,13 +1356,15 @@ static int b44_set_mac_addr(struct net_d
  * packet processing.  Invoked with bp->lock held.
  */
 static void __b44_set_rx_mode(struct net_device *);
-static void b44_init_hw(struct b44 *bp)
+static void b44_init_hw(struct b44 *bp, int full_reset)
 {
 	u32 val;
 
 	b44_chip_reset(bp);
-	b44_phy_reset(bp);
-	b44_setup_phy(bp);
+	if (full_reset) {
+		b44_phy_reset(bp);
+		b44_setup_phy(bp);
+	}
 
 	/* Enable CRC32, set proper LED modes and power on PHY */
 	bw32(bp, B44_MAC_CTRL, MAC_CTRL_CRC32_ENAB | MAC_CTRL_PHY_LEDCTRL);
@@ -1376,16 +1378,21 @@ static void b44_init_hw(struct b44 *bp)
 	bw32(bp, B44_TXMAXLEN, bp->dev->mtu + ETH_HLEN + 8 + RX_HEADER_LEN);
 
 	bw32(bp, B44_TX_WMARK, 56); /* XXX magic */
-	bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
-	bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
-	bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
-			      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
-	bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
+	if (full_reset) {
+		bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
+		bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
+		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
+				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+		bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
 
-	bw32(bp, B44_DMARX_PTR, bp->rx_pending);
-	bp->rx_prod = bp->rx_pending;
+		bw32(bp, B44_DMARX_PTR, bp->rx_pending);
+		bp->rx_prod = bp->rx_pending;
 
-	bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
+		bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
+	} else {
+		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
+				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+	}
 
 	val = br32(bp, B44_ENET_CTRL);
 	bw32(bp, B44_ENET_CTRL, (val | ENET_CTRL_ENABLE));
@@ -1401,7 +1408,7 @@ static int b44_open(struct net_device *d
 		goto out;
 
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, 1);
 
 	b44_check_phy(bp);
 
@@ -1511,7 +1518,7 @@ static int b44_close(struct net_device *
 	netif_poll_enable(dev);
 
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
-		b44_init_hw(bp);
+		b44_init_hw(bp, 0);
 		b44_setup_wol(bp);
 	}
 
@@ -1786,7 +1793,7 @@ static int b44_set_ringparam(struct net_
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, 1);
 	netif_wake_queue(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
@@ -1829,7 +1836,7 @@ static int b44_set_pauseparam(struct net
 	if (bp->flags & B44_FLAG_PAUSE_AUTO) {
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp);
+		b44_init_hw(bp, 1);
 	} else {
 		__b44_set_flow_ctrl(bp, bp->flags);
 	}
@@ -2188,7 +2195,7 @@ static int b44_suspend(struct pci_dev *p
 
 	free_irq(dev->irq, dev);
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
-		b44_init_hw(bp);
+		b44_init_hw(bp, 0);
 		b44_setup_wol(bp);
 	}
 	pci_disable_device(pdev);
@@ -2213,7 +2220,7 @@ static int b44_resume(struct pci_dev *pd
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, 1);
 	netif_device_attach(bp->dev);
 	spin_unlock_irq(&bp->lock);
 


