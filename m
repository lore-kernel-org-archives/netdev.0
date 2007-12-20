From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/9][BNX2]: Add function to fetch hardware tx index.
Date: Thu, 20 Dec 2007 12:31:07 -0800
Message-ID: <1198182667.9163.27.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3541 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbXLTTqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:46:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add function to fetch hardware tx index.

This makes the code cleaner and easier to support different tx rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 469d259..f19a1e9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2323,17 +2323,25 @@ bnx2_phy_int(struct bnx2 *bp)
 
 }
 
+static inline u16
+bnx2_get_hw_tx_cons(struct bnx2 *bp)
+{
+	u16 cons;
+
+	cons = bp->status_blk->status_tx_quick_consumer_index0;
+
+	if (unlikely((cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT))
+		cons++;
+	return cons;
+}
+
 static void
 bnx2_tx_int(struct bnx2 *bp)
 {
-	struct status_block *sblk = bp->status_blk;
 	u16 hw_cons, sw_cons, sw_ring_cons;
 	int tx_free_bd = 0;
 
-	hw_cons = bp->hw_tx_cons = sblk->status_tx_quick_consumer_index0;
-	if ((hw_cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT) {
-		hw_cons++;
-	}
+	hw_cons = bnx2_get_hw_tx_cons(bp);
 	sw_cons = bp->tx_cons;
 
 	while (sw_cons != hw_cons) {
@@ -2385,14 +2393,10 @@ bnx2_tx_int(struct bnx2 *bp)
 
 		dev_kfree_skb(skb);
 
-		hw_cons = bp->hw_tx_cons =
-			sblk->status_tx_quick_consumer_index0;
-
-		if ((hw_cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT) {
-			hw_cons++;
-		}
+		hw_cons = bnx2_get_hw_tx_cons(bp);
 	}
 
+	bp->hw_tx_cons = hw_cons;
 	bp->tx_cons = sw_cons;
 	/* Need to make the tx_cons update visible to bnx2_start_xmit()
 	 * before checking for netif_queue_stopped().  Without the
@@ -2822,7 +2826,7 @@ bnx2_has_work(struct bnx2 *bp)
 	struct status_block *sblk = bp->status_blk;
 
 	if ((bnx2_get_hw_rx_cons(bp) != bp->rx_cons) ||
-	    (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons))
+	    (bnx2_get_hw_tx_cons(bp) != bp->hw_tx_cons))
 		return 1;
 
 	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
@@ -2851,7 +2855,7 @@ static int bnx2_poll_work(struct bnx2 *bp, int work_done, int budget)
 		REG_RD(bp, BNX2_HC_COMMAND);
 	}
 
-	if (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons)
+	if (bnx2_get_hw_tx_cons(bp) != bp->hw_tx_cons)
 		bnx2_tx_int(bp);
 
 	if (bnx2_get_hw_rx_cons(bp) != bp->rx_cons)
@@ -4917,7 +4921,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	REG_RD(bp, BNX2_HC_COMMAND);
 
 	udelay(5);
-	rx_start_idx = bp->status_blk->status_rx_quick_consumer_index0;
+	rx_start_idx = bnx2_get_hw_rx_cons(bp);
 
 	num_pkts = 0;
 
@@ -4947,11 +4951,10 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
 	dev_kfree_skb(skb);
 
-	if (bp->status_blk->status_tx_quick_consumer_index0 != bp->tx_prod) {
+	if (bnx2_get_hw_tx_cons(bp) != bp->tx_prod)
 		goto loopback_test_done;
-	}
 
-	rx_idx = bp->status_blk->status_rx_quick_consumer_index0;
+	rx_idx = bnx2_get_hw_rx_cons(bp);
 	if (rx_idx != rx_start_idx + num_pkts) {
 		goto loopback_test_done;
 	}


