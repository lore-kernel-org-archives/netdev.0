From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/9][BNX2]: Move rx indexes into bnx2_napi struct.
Date: Thu, 20 Dec 2007 12:32:25 -0800
Message-ID: <1198182745.9163.31.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3533 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbXLTTro (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:47:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Move rx indexes into bnx2_napi struct.

Rx related fields used in NAPI polling are moved from the main
bnx2 struct to the bnx2_napi struct.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0300a75..ecfaad1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2276,7 +2276,7 @@ bnx2_free_rx_page(struct bnx2 *bp, u16 index)
 }
 
 static inline int
-bnx2_alloc_rx_skb(struct bnx2 *bp, u16 index)
+bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, u16 index)
 {
 	struct sk_buff *skb;
 	struct sw_bd *rx_buf = &bp->rx_buf_ring[index];
@@ -2301,7 +2301,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 index)
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
 	rxbd->rx_bd_haddr_lo = (u64) mapping & 0xffffffff;
 
-	bp->rx_prod_bseq += bp->rx_buf_use_size;
+	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
 
 	return 0;
 }
@@ -2432,14 +2432,15 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 }
 
 static void
-bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct sk_buff *skb, int count)
+bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_napi *bnapi,
+			struct sk_buff *skb, int count)
 {
 	struct sw_pg *cons_rx_pg, *prod_rx_pg;
 	struct rx_bd *cons_bd, *prod_bd;
 	dma_addr_t mapping;
 	int i;
-	u16 hw_prod = bp->rx_pg_prod, prod;
-	u16 cons = bp->rx_pg_cons;
+	u16 hw_prod = bnapi->rx_pg_prod, prod;
+	u16 cons = bnapi->rx_pg_cons;
 
 	for (i = 0; i < count; i++) {
 		prod = RX_PG_RING_IDX(hw_prod);
@@ -2476,12 +2477,12 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct sk_buff *skb, int count)
 		cons = RX_PG_RING_IDX(NEXT_RX_BD(cons));
 		hw_prod = NEXT_RX_BD(hw_prod);
 	}
-	bp->rx_pg_prod = hw_prod;
-	bp->rx_pg_cons = cons;
+	bnapi->rx_pg_prod = hw_prod;
+	bnapi->rx_pg_cons = cons;
 }
 
 static inline void
-bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
+bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 	u16 cons, u16 prod)
 {
 	struct sw_bd *cons_rx_buf, *prod_rx_buf;
@@ -2494,7 +2495,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 		pci_unmap_addr(cons_rx_buf, mapping),
 		bp->rx_offset + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
-	bp->rx_prod_bseq += bp->rx_buf_use_size;
+	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
 
 	prod_rx_buf->skb = skb;
 
@@ -2511,20 +2512,21 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 }
 
 static int
-bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
-	    unsigned int hdr_len, dma_addr_t dma_addr, u32 ring_idx)
+bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
+	    unsigned int len, unsigned int hdr_len, dma_addr_t dma_addr,
+	    u32 ring_idx)
 {
 	int err;
 	u16 prod = ring_idx & 0xffff;
 
-	err = bnx2_alloc_rx_skb(bp, prod);
+	err = bnx2_alloc_rx_skb(bp, bnapi, prod);
 	if (unlikely(err)) {
-		bnx2_reuse_rx_skb(bp, skb, (u16) (ring_idx >> 16), prod);
+		bnx2_reuse_rx_skb(bp, bnapi, skb, (u16) (ring_idx >> 16), prod);
 		if (hdr_len) {
 			unsigned int raw_len = len + 4;
 			int pages = PAGE_ALIGN(raw_len - hdr_len) >> PAGE_SHIFT;
 
-			bnx2_reuse_rx_skb_pages(bp, NULL, pages);
+			bnx2_reuse_rx_skb_pages(bp, bnapi, NULL, pages);
 		}
 		return err;
 	}
@@ -2539,8 +2541,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 	} else {
 		unsigned int i, frag_len, frag_size, pages;
 		struct sw_pg *rx_pg;
-		u16 pg_cons = bp->rx_pg_cons;
-		u16 pg_prod = bp->rx_pg_prod;
+		u16 pg_cons = bnapi->rx_pg_cons;
+		u16 pg_prod = bnapi->rx_pg_prod;
 
 		frag_size = len + 4 - hdr_len;
 		pages = PAGE_ALIGN(frag_size) >> PAGE_SHIFT;
@@ -2551,9 +2553,10 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 			if (unlikely(frag_len <= 4)) {
 				unsigned int tail = 4 - frag_len;
 
-				bp->rx_pg_cons = pg_cons;
-				bp->rx_pg_prod = pg_prod;
-				bnx2_reuse_rx_skb_pages(bp, NULL, pages - i);
+				bnapi->rx_pg_cons = pg_cons;
+				bnapi->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, bnapi, NULL,
+							pages - i);
 				skb->len -= tail;
 				if (i == 0) {
 					skb->tail -= tail;
@@ -2579,9 +2582,10 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 
 			err = bnx2_alloc_rx_page(bp, RX_PG_RING_IDX(pg_prod));
 			if (unlikely(err)) {
-				bp->rx_pg_cons = pg_cons;
-				bp->rx_pg_prod = pg_prod;
-				bnx2_reuse_rx_skb_pages(bp, skb, pages - i);
+				bnapi->rx_pg_cons = pg_cons;
+				bnapi->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, bnapi, skb,
+							pages - i);
 				return err;
 			}
 
@@ -2593,8 +2597,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 			pg_prod = NEXT_RX_BD(pg_prod);
 			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
 		}
-		bp->rx_pg_prod = pg_prod;
-		bp->rx_pg_cons = pg_cons;
+		bnapi->rx_pg_prod = pg_prod;
+		bnapi->rx_pg_cons = pg_cons;
 	}
 	return 0;
 }
@@ -2617,8 +2621,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	int rx_pkt = 0, pg_ring_used = 0;
 
 	hw_cons = bnx2_get_hw_rx_cons(bnapi);
-	sw_cons = bp->rx_cons;
-	sw_prod = bp->rx_prod;
+	sw_cons = bnapi->rx_cons;
+	sw_prod = bnapi->rx_prod;
 
 	/* Memory barrier necessary as speculative reads of the rx
 	 * buffer can be ahead of the index in the status block
@@ -2654,7 +2658,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			L2_FHDR_ERRORS_TOO_SHORT |
 			L2_FHDR_ERRORS_GIANT_FRAME)) {
 
-			bnx2_reuse_rx_skb(bp, skb, sw_ring_cons, sw_ring_prod);
+			bnx2_reuse_rx_skb(bp, bnapi, skb, sw_ring_cons,
+					  sw_ring_prod);
 			goto next_rx;
 		}
 		hdr_len = 0;
@@ -2673,7 +2678,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 			new_skb = netdev_alloc_skb(bp->dev, len + 2);
 			if (new_skb == NULL) {
-				bnx2_reuse_rx_skb(bp, skb, sw_ring_cons,
+				bnx2_reuse_rx_skb(bp, bnapi, skb, sw_ring_cons,
 						  sw_ring_prod);
 				goto next_rx;
 			}
@@ -2684,12 +2689,12 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			skb_reserve(new_skb, 2);
 			skb_put(new_skb, len);
 
-			bnx2_reuse_rx_skb(bp, skb,
+			bnx2_reuse_rx_skb(bp, bnapi, skb,
 				sw_ring_cons, sw_ring_prod);
 
 			skb = new_skb;
-		} else if (unlikely(bnx2_rx_skb(bp, skb, len, hdr_len, dma_addr,
-				    (sw_ring_cons << 16) | sw_ring_prod)))
+		} else if (unlikely(bnx2_rx_skb(bp, bnapi, skb, len, hdr_len,
+			   dma_addr, (sw_ring_cons << 16) | sw_ring_prod)))
 			goto next_rx;
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
@@ -2737,16 +2742,16 @@ next_rx:
 			rmb();
 		}
 	}
-	bp->rx_cons = sw_cons;
-	bp->rx_prod = sw_prod;
+	bnapi->rx_cons = sw_cons;
+	bnapi->rx_prod = sw_prod;
 
 	if (pg_ring_used)
 		REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX,
-			 bp->rx_pg_prod);
+			 bnapi->rx_pg_prod);
 
 	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, sw_prod);
 
-	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bp->rx_prod_bseq);
+	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bnapi->rx_prod_bseq);
 
 	mmiowb();
 
@@ -2845,7 +2850,7 @@ bnx2_has_work(struct bnx2_napi *bnapi)
 	struct bnx2 *bp = bnapi->bp;
 	struct status_block *sblk = bp->status_blk;
 
-	if ((bnx2_get_hw_rx_cons(bnapi) != bp->rx_cons) ||
+	if ((bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons) ||
 	    (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons))
 		return 1;
 
@@ -2879,7 +2884,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 	if (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons)
 		bnx2_tx_int(bp, bnapi);
 
-	if (bnx2_get_hw_rx_cons(bnapi) != bp->rx_cons)
+	if (bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons)
 		work_done += bnx2_rx_int(bp, bnapi, budget - work_done);
 
 	return work_done;
@@ -4432,12 +4437,13 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	int i;
 	u16 prod, ring_prod;
 	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
+	struct bnx2_napi *bnapi = &bp->bnx2_napi;
 
-	bp->rx_prod = 0;
-	bp->rx_cons = 0;
-	bp->rx_prod_bseq = 0;
-	bp->rx_pg_prod = 0;
-	bp->rx_pg_cons = 0;
+	bnapi->rx_prod = 0;
+	bnapi->rx_cons = 0;
+	bnapi->rx_prod_bseq = 0;
+	bnapi->rx_pg_prod = 0;
+	bnapi->rx_pg_cons = 0;
 
 	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
@@ -4473,29 +4479,30 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	val = (u64) bp->rx_desc_mapping[0] & 0xffffffff;
 	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 
-	ring_prod = prod = bp->rx_pg_prod;
+	ring_prod = prod = bnapi->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
 		if (bnx2_alloc_rx_page(bp, ring_prod) < 0)
 			break;
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_PG_RING_IDX(prod);
 	}
-	bp->rx_pg_prod = prod;
+	bnapi->rx_pg_prod = prod;
 
-	ring_prod = prod = bp->rx_prod;
+	ring_prod = prod = bnapi->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		if (bnx2_alloc_rx_skb(bp, ring_prod) < 0) {
+		if (bnx2_alloc_rx_skb(bp, bnapi, ring_prod) < 0) {
 			break;
 		}
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_RING_IDX(prod);
 	}
-	bp->rx_prod = prod;
+	bnapi->rx_prod = prod;
 
-	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX, bp->rx_pg_prod);
+	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX,
+		 bnapi->rx_pg_prod);
 	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, prod);
 
-	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bp->rx_prod_bseq);
+	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bnapi->rx_prod_bseq);
 }
 
 static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 958fdda..b75795b 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6512,6 +6512,14 @@ struct bnx2_napi {
 
 	u16			tx_cons;
 	u16			hw_tx_cons;
+
+	u32			rx_prod_bseq;
+	u16			rx_prod;
+	u16			rx_cons;
+
+	u16			rx_pg_prod;
+	u16			rx_pg_cons;
+
 };
 
 struct bnx2 {
@@ -6556,13 +6564,6 @@ struct bnx2 {
 	u32			rx_max_ring_idx;
 	u32			rx_max_pg_ring_idx;
 
-	u32			rx_prod_bseq;
-	u16			rx_prod;
-	u16			rx_cons;
-
-	u16			rx_pg_prod;
-	u16			rx_pg_cons;
-
 	u32			rx_csum;
 
 	struct sw_bd		*rx_buf_ring;


