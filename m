From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/9][BNX2]: Add support for a new tx ring.
Date: Thu, 20 Dec 2007 12:33:00 -0800
Message-ID: <1198182780.9163.33.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1154 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbXLTTsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:48:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add support for a new tx ring.

To separate TX IRQs into a different MSIX vector, we need to
support a new tx ring.  The original tx ring will still be used
when not using MSIX.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 196d053..a4ed6ca 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2378,7 +2378,10 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 {
 	u16 cons;
 
-	cons = bnapi->status_blk->status_tx_quick_consumer_index0;
+	if (bnapi->int_num == 0)
+		cons = bnapi->status_blk->status_tx_quick_consumer_index0;
+	else
+		cons = bnapi->status_blk_msix->status_tx_quick_consumer_index;
 
 	if (unlikely((cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT))
 		cons++;
@@ -2389,7 +2392,6 @@ static void
 bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
 	u16 hw_cons, sw_cons, sw_ring_cons;
-	int tx_free_bd = 0;
 
 	hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	sw_cons = bnapi->tx_cons;
@@ -2439,8 +2441,6 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 
 		sw_cons = NEXT_TX_BD(sw_cons);
 
-		tx_free_bd += last + 1;
-
 		dev_kfree_skb(skb);
 
 		hw_cons = bnx2_get_hw_tx_cons(bnapi);
@@ -4369,6 +4369,24 @@ bnx2_init_chip(struct bnx2 *bp)
 		      BNX2_HC_CONFIG_COLLECT_STATS;
 	}
 
+	if (bp->flags & USING_MSIX_FLAG) {
+		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
+		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
+
+		REG_WR(bp, BNX2_HC_SB_CONFIG_1,
+			BNX2_HC_SB_CONFIG_1_TX_TMR_MODE |
+			BNX2_HC_SB_CONFIG_1_ONE_SHOT);
+
+		REG_WR(bp, BNX2_HC_TX_QUICK_CONS_TRIP_1,
+			(bp->tx_quick_cons_trip_int << 16) |
+			 bp->tx_quick_cons_trip);
+
+		REG_WR(bp, BNX2_HC_TX_TICKS_1,
+			(bp->tx_ticks_int << 16) | bp->tx_ticks);
+
+		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
+	}
+
 	if (bp->flags & ONE_SHOT_MSI_FLAG)
 		val |= BNX2_HC_CONFIG_ONE_SHOT;
 
@@ -4401,6 +4419,25 @@ bnx2_init_chip(struct bnx2 *bp)
 }
 
 static void
+bnx2_clear_ring_states(struct bnx2 *bp)
+{
+	struct bnx2_napi *bnapi;
+	int i;
+
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
+		bnapi = &bp->bnx2_napi[i];
+
+		bnapi->tx_cons = 0;
+		bnapi->hw_tx_cons = 0;
+		bnapi->rx_prod_bseq = 0;
+		bnapi->rx_prod = 0;
+		bnapi->rx_cons = 0;
+		bnapi->rx_pg_prod = 0;
+		bnapi->rx_pg_cons = 0;
+	}
+}
+
+static void
 bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
 {
 	u32 val, offset0, offset1, offset2, offset3;
@@ -4433,8 +4470,17 @@ static void
 bnx2_init_tx_ring(struct bnx2 *bp)
 {
 	struct tx_bd *txbd;
-	u32 cid;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	u32 cid = TX_CID;
+	struct bnx2_napi *bnapi;
+
+	bp->tx_vec = 0;
+	if (bp->flags & USING_MSIX_FLAG) {
+		cid = TX_TSS_CID;
+		bp->tx_vec = BNX2_TX_VEC;
+		REG_WR(bp, BNX2_TSCH_TSS_CFG, BNX2_TX_INT_NUM |
+		       (TX_TSS_CID << 7));
+	}
+	bnapi = &bp->bnx2_napi[bp->tx_vec];
 
 	bp->tx_wake_thresh = bp->tx_ring_size / 2;
 
@@ -4444,11 +4490,8 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 	txbd->tx_bd_haddr_lo = (u64) bp->tx_desc_mapping & 0xffffffff;
 
 	bp->tx_prod = 0;
-	bnapi->tx_cons = 0;
-	bnapi->hw_tx_cons = 0;
 	bp->tx_prod_bseq = 0;
 
-	cid = TX_CID;
 	bp->tx_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BIDX;
 	bp->tx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BSEQ;
 
@@ -4487,12 +4530,6 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
-	bnapi->rx_prod = 0;
-	bnapi->rx_cons = 0;
-	bnapi->rx_prod_bseq = 0;
-	bnapi->rx_pg_prod = 0;
-	bnapi->rx_pg_cons = 0;
-
 	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
 
@@ -4694,6 +4731,7 @@ bnx2_reset_nic(struct bnx2 *bp, u32 reset_code)
 	if ((rc = bnx2_init_chip(bp)) != 0)
 		return rc;
 
+	bnx2_clear_ring_states(bp);
 	bnx2_init_tx_ring(bp);
 	bnx2_init_rx_ring(bp);
 	return 0;
@@ -4965,7 +5003,11 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	struct sw_bd *rx_buf;
 	struct l2_fhdr *rx_hdr;
 	int ret = -ENODEV;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0], *tx_napi;
+
+	tx_napi = bnapi;
+	if (bp->flags & USING_MSIX_FLAG)
+		tx_napi = &bp->bnx2_napi[BNX2_TX_VEC];
 
 	if (loopback_mode == BNX2_MAC_LOOPBACK) {
 		bp->loopback = MAC_LOOPBACK;
@@ -5030,7 +5072,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
 	dev_kfree_skb(skb);
 
-	if (bnx2_get_hw_tx_cons(bnapi) != bp->tx_prod)
+	if (bnx2_get_hw_tx_cons(tx_napi) != bp->tx_prod)
 		goto loopback_test_done;
 
 	rx_idx = bnx2_get_hw_rx_cons(bnapi);
@@ -5324,7 +5366,7 @@ bnx2_request_irq(struct bnx2 *bp)
 	
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		irq = &bp->irq_tbl[i];
-		rc = request_irq(irq->vector, irq->handler, flags, dev->name,
+		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
 				 dev);
 		if (rc)
 			break;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index d71ceb6..68fb590 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6529,6 +6529,9 @@ struct flash_spec {
 
 #define BNX2_MAX_MSIX_HW_VEC	9
 #define BNX2_MAX_MSIX_VEC	1
+#define BNX2_BASE_VEC		0
+#define BNX2_TX_VEC		1
+#define BNX2_TX_INT_NUM	(BNX2_TX_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT)
 
 struct bnx2_irq {
 	irq_handler_t	handler;
@@ -6541,6 +6544,7 @@ struct bnx2_napi {
 	struct napi_struct	napi		____cacheline_aligned;
 	struct bnx2		*bp;
 	struct status_block	*status_blk;
+	struct status_block_msix	*status_blk_msix;
 	u32 			last_status_idx;
 	u32			int_num;
 
@@ -6583,6 +6587,7 @@ struct bnx2 {
 
 	u32		tx_prod_bseq __attribute__((aligned(L1_CACHE_BYTES)));
 	u16		tx_prod;
+	u8		tx_vec;
 	u32		tx_bidx_addr;
 	u32		tx_bseq_addr;
 


