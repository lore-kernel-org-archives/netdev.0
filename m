From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3][BNX2]: Fix RX packet rot.
Date: Sun, 09 Dec 2007 13:17:14 -0800
Message-ID: <1197235034.20251.10.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2154 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbXLIUc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2007 15:32:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fix RX packet rot.

Packets can be left in the RX ring if the NAPI budget is reached.
This is caused by storing the latest rx index at the beginning of
bnx2_rx_int().  We may not process all the work up to this index
if the budget is reached and so some packets in the RX ring may rot
when we later check for more work using this stored rx index.

The fix is to not store this latest hw index and only store the
processed rx index.  We use a new function bnx2_get_hw_rx_cons()
to fetch the latest hw rx index.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a4f3832..f9eea6e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2387,18 +2387,24 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 	prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
 }
 
+static inline u16
+bnx2_get_hw_rx_cons(struct bnx2 *bp)
+{
+	u16 cons = bp->status_blk->status_rx_quick_consumer_index0;
+
+	if (unlikely((cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT))
+		cons++;
+	return cons;
+}
+
 static int
 bnx2_rx_int(struct bnx2 *bp, int budget)
 {
-	struct status_block *sblk = bp->status_blk;
 	u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
 	struct l2_fhdr *rx_hdr;
 	int rx_pkt = 0;
 
-	hw_cons = bp->hw_rx_cons = sblk->status_rx_quick_consumer_index0;
-	if ((hw_cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT) {
-		hw_cons++;
-	}
+	hw_cons = bnx2_get_hw_rx_cons(bp);
 	sw_cons = bp->rx_cons;
 	sw_prod = bp->rx_prod;
 
@@ -2515,10 +2521,7 @@ next_rx:
 
 		/* Refresh hw_cons to see if there is new work */
 		if (sw_cons == hw_cons) {
-			hw_cons = bp->hw_rx_cons =
-				sblk->status_rx_quick_consumer_index0;
-			if ((hw_cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT)
-				hw_cons++;
+			hw_cons = bnx2_get_hw_rx_cons(bp);
 			rmb();
 		}
 	}
@@ -2622,7 +2625,7 @@ bnx2_has_work(struct bnx2 *bp)
 {
 	struct status_block *sblk = bp->status_blk;
 
-	if ((sblk->status_rx_quick_consumer_index0 != bp->hw_rx_cons) ||
+	if ((bnx2_get_hw_rx_cons(bp) != bp->rx_cons) ||
 	    (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons))
 		return 1;
 
@@ -2655,7 +2658,7 @@ static int bnx2_poll_work(struct bnx2 *bp, int work_done, int budget)
 	if (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons)
 		bnx2_tx_int(bp);
 
-	if (sblk->status_rx_quick_consumer_index0 != bp->hw_rx_cons)
+	if (bnx2_get_hw_rx_cons(bp) != bp->rx_cons)
 		work_done += bnx2_rx_int(bp, budget - work_done);
 
 	return work_done;
@@ -4177,7 +4180,6 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 
 	ring_prod = prod = bp->rx_prod = 0;
 	bp->rx_cons = 0;
-	bp->hw_rx_cons = 0;
 	bp->rx_prod_bseq = 0;
 
 	for (i = 0; i < bp->rx_max_ring; i++) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1dce0d1..30ba366 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6513,7 +6513,6 @@ struct bnx2 {
 	u32			rx_prod_bseq;
 	u16			rx_prod;
 	u16			rx_cons;
-	u16			hw_rx_cons;
 
 	u32			rx_csum;
 


