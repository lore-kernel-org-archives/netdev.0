From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/8] bnx2: Put rx ring variables in a separate struct.
Date: Wed, 18 Jun 2008 17:25:26 -0700
Message-ID: <1213835132-5698-3-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3774 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754839AbYFSAXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:45 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for multi-ring support, rx ring variables are now put
in a separate bnx2_rx_ring_info struct.  With MSI-X, we can support
multiple rx rings.

The functions to allocate/free rx memory and to initialize rx rings
are now modified to handle multiple rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |  390 +++++++++++++++++++++++++++++++---------------------
 drivers/net/bnx2.h |   38 ++++--
 2 files changed, 259 insertions(+), 169 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 61f2b4f..4360528 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -515,6 +515,40 @@ bnx2_free_tx_mem(struct bnx2 *bp)
 	}
 }
 
+static void
+bnx2_free_rx_mem(struct bnx2 *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->num_rx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
+		int j;
+
+		for (j = 0; j < bp->rx_max_ring; j++) {
+			if (rxr->rx_desc_ring[j])
+				pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
+						    rxr->rx_desc_ring[j],
+						    rxr->rx_desc_mapping[j]);
+			rxr->rx_desc_ring[j] = NULL;
+		}
+		if (rxr->rx_buf_ring)
+			vfree(rxr->rx_buf_ring);
+		rxr->rx_buf_ring = NULL;
+
+		for (j = 0; j < bp->rx_max_pg_ring; j++) {
+			if (rxr->rx_pg_desc_ring[j])
+				pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
+						    rxr->rx_pg_desc_ring[i],
+						    rxr->rx_pg_desc_mapping[i]);
+			rxr->rx_pg_desc_ring[i] = NULL;
+		}
+		if (rxr->rx_pg_ring)
+			vfree(rxr->rx_pg_ring);
+		rxr->rx_pg_ring = NULL;
+	}
+}
+
 static int
 bnx2_alloc_tx_mem(struct bnx2 *bp)
 {
@@ -537,12 +571,62 @@ bnx2_alloc_tx_mem(struct bnx2 *bp)
 	return 0;
 }
 
+static int
+bnx2_alloc_rx_mem(struct bnx2 *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->num_rx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
+		int j;
+
+		rxr->rx_buf_ring =
+			vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
+		if (rxr->rx_buf_ring == NULL)
+			return -ENOMEM;
+
+		memset(rxr->rx_buf_ring, 0,
+		       SW_RXBD_RING_SIZE * bp->rx_max_ring);
+
+		for (j = 0; j < bp->rx_max_ring; j++) {
+			rxr->rx_desc_ring[j] =
+				pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
+						     &rxr->rx_desc_mapping[j]);
+			if (rxr->rx_desc_ring[j] == NULL)
+				return -ENOMEM;
+
+		}
+
+		if (bp->rx_pg_ring_size) {
+			rxr->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
+						  bp->rx_max_pg_ring);
+			if (rxr->rx_pg_ring == NULL)
+				return -ENOMEM;
+
+			memset(rxr->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
+			       bp->rx_max_pg_ring);
+		}
+
+		for (j = 0; j < bp->rx_max_pg_ring; j++) {
+			rxr->rx_pg_desc_ring[j] =
+				pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
+						&rxr->rx_pg_desc_mapping[j]);
+			if (rxr->rx_pg_desc_ring[j] == NULL)
+				return -ENOMEM;
+
+		}
+	}
+	return 0;
+}
+
 static void
 bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
 
 	bnx2_free_tx_mem(bp);
+	bnx2_free_rx_mem(bp);
 
 	for (i = 0; i < bp->ctx_pages; i++) {
 		if (bp->ctx_blk[i]) {
@@ -558,25 +642,6 @@ bnx2_free_mem(struct bnx2 *bp)
 		bp->status_blk = NULL;
 		bp->stats_blk = NULL;
 	}
-	for (i = 0; i < bp->rx_max_ring; i++) {
-		if (bp->rx_desc_ring[i])
-			pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
-					    bp->rx_desc_ring[i],
-					    bp->rx_desc_mapping[i]);
-		bp->rx_desc_ring[i] = NULL;
-	}
-	vfree(bp->rx_buf_ring);
-	bp->rx_buf_ring = NULL;
-	for (i = 0; i < bp->rx_max_pg_ring; i++) {
-		if (bp->rx_pg_desc_ring[i])
-			pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
-					    bp->rx_pg_desc_ring[i],
-					    bp->rx_pg_desc_mapping[i]);
-		bp->rx_pg_desc_ring[i] = NULL;
-	}
-	if (bp->rx_pg_ring)
-		vfree(bp->rx_pg_ring);
-	bp->rx_pg_ring = NULL;
 }
 
 static int
@@ -584,40 +649,6 @@ bnx2_alloc_mem(struct bnx2 *bp)
 {
 	int i, status_blk_size, err;
 
-	bp->rx_buf_ring = vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
-	if (bp->rx_buf_ring == NULL)
-		goto alloc_mem_err;
-
-	memset(bp->rx_buf_ring, 0, SW_RXBD_RING_SIZE * bp->rx_max_ring);
-
-	for (i = 0; i < bp->rx_max_ring; i++) {
-		bp->rx_desc_ring[i] =
-			pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
-					     &bp->rx_desc_mapping[i]);
-		if (bp->rx_desc_ring[i] == NULL)
-			goto alloc_mem_err;
-
-	}
-
-	if (bp->rx_pg_ring_size) {
-		bp->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
-					 bp->rx_max_pg_ring);
-		if (bp->rx_pg_ring == NULL)
-			goto alloc_mem_err;
-
-		memset(bp->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
-		       bp->rx_max_pg_ring);
-	}
-
-	for (i = 0; i < bp->rx_max_pg_ring; i++) {
-		bp->rx_pg_desc_ring[i] =
-			pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
-					     &bp->rx_pg_desc_mapping[i]);
-		if (bp->rx_pg_desc_ring[i] == NULL)
-			goto alloc_mem_err;
-
-	}
-
 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
 	if (bp->flags & BNX2_FLAG_MSIX_CAP)
@@ -663,6 +694,10 @@ bnx2_alloc_mem(struct bnx2 *bp)
 		}
 	}
 
+	err = bnx2_alloc_rx_mem(bp);
+	if (err)
+		goto alloc_mem_err;
+
 	err = bnx2_alloc_tx_mem(bp);
 	if (err)
 		goto alloc_mem_err;
@@ -1026,9 +1061,9 @@ bnx2_copper_linkup(struct bnx2 *bp)
 }
 
 static void
-bnx2_init_rx_context0(struct bnx2 *bp)
+bnx2_init_rx_context(struct bnx2 *bp, u32 cid)
 {
-	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
+	u32 val, rx_cid_addr = GET_CID_ADDR(cid);
 
 	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
 	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
@@ -1061,6 +1096,19 @@ bnx2_init_rx_context0(struct bnx2 *bp)
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
 }
 
+static void
+bnx2_init_all_rx_contexts(struct bnx2 *bp)
+{
+	int i;
+	u32 cid;
+
+	for (i = 0, cid = RX_CID; i < bp->num_rx_rings; i++, cid++) {
+		if (i == 1)
+			cid = RX_RSS_CID;
+		bnx2_init_rx_context(bp, cid);
+	}
+}
+
 static int
 bnx2_set_mac_link(struct bnx2 *bp)
 {
@@ -1126,7 +1174,7 @@ bnx2_set_mac_link(struct bnx2 *bp)
 	REG_WR(bp, BNX2_EMAC_STATUS, BNX2_EMAC_STATUS_LINK_CHANGE);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		bnx2_init_rx_context0(bp);
+		bnx2_init_all_rx_contexts(bp);
 
 	return 0;
 }
@@ -2398,12 +2446,12 @@ bnx2_set_mac_addr(struct bnx2 *bp)
 }
 
 static inline int
-bnx2_alloc_rx_page(struct bnx2 *bp, u16 index)
+bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 {
 	dma_addr_t mapping;
-	struct sw_pg *rx_pg = &bp->rx_pg_ring[index];
+	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct rx_bd *rxbd =
-		&bp->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
+		&rxr->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
 	struct page *page = alloc_page(GFP_ATOMIC);
 
 	if (!page)
@@ -2418,9 +2466,9 @@ bnx2_alloc_rx_page(struct bnx2 *bp, u16 index)
 }
 
 static void
-bnx2_free_rx_page(struct bnx2 *bp, u16 index)
+bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 {
-	struct sw_pg *rx_pg = &bp->rx_pg_ring[index];
+	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct page *page = rx_pg->page;
 
 	if (!page)
@@ -2434,12 +2482,12 @@ bnx2_free_rx_page(struct bnx2 *bp, u16 index)
 }
 
 static inline int
-bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, u16 index)
+bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 {
 	struct sk_buff *skb;
-	struct sw_bd *rx_buf = &bp->rx_buf_ring[index];
+	struct sw_bd *rx_buf = &rxr->rx_buf_ring[index];
 	dma_addr_t mapping;
-	struct rx_bd *rxbd = &bp->rx_desc_ring[RX_RING(index)][RX_IDX(index)];
+	struct rx_bd *rxbd = &rxr->rx_desc_ring[RX_RING(index)][RX_IDX(index)];
 	unsigned long align;
 
 	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
@@ -2459,7 +2507,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, u16 index)
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
 	rxbd->rx_bd_haddr_lo = (u64) mapping & 0xffffffff;
 
-	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
+	rxr->rx_prod_bseq += bp->rx_buf_use_size;
 
 	return 0;
 }
@@ -2597,23 +2645,23 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 }
 
 static void
-bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_napi *bnapi,
+bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 			struct sk_buff *skb, int count)
 {
 	struct sw_pg *cons_rx_pg, *prod_rx_pg;
 	struct rx_bd *cons_bd, *prod_bd;
 	dma_addr_t mapping;
 	int i;
-	u16 hw_prod = bnapi->rx_pg_prod, prod;
-	u16 cons = bnapi->rx_pg_cons;
+	u16 hw_prod = rxr->rx_pg_prod, prod;
+	u16 cons = rxr->rx_pg_cons;
 
 	for (i = 0; i < count; i++) {
 		prod = RX_PG_RING_IDX(hw_prod);
 
-		prod_rx_pg = &bp->rx_pg_ring[prod];
-		cons_rx_pg = &bp->rx_pg_ring[cons];
-		cons_bd = &bp->rx_pg_desc_ring[RX_RING(cons)][RX_IDX(cons)];
-		prod_bd = &bp->rx_pg_desc_ring[RX_RING(prod)][RX_IDX(prod)];
+		prod_rx_pg = &rxr->rx_pg_ring[prod];
+		cons_rx_pg = &rxr->rx_pg_ring[cons];
+		cons_bd = &rxr->rx_pg_desc_ring[RX_RING(cons)][RX_IDX(cons)];
+		prod_bd = &rxr->rx_pg_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 
 		if (i == 0 && skb) {
 			struct page *page;
@@ -2642,25 +2690,25 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_napi *bnapi,
 		cons = RX_PG_RING_IDX(NEXT_RX_BD(cons));
 		hw_prod = NEXT_RX_BD(hw_prod);
 	}
-	bnapi->rx_pg_prod = hw_prod;
-	bnapi->rx_pg_cons = cons;
+	rxr->rx_pg_prod = hw_prod;
+	rxr->rx_pg_cons = cons;
 }
 
 static inline void
-bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
-	u16 cons, u16 prod)
+bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
+		  struct sk_buff *skb, u16 cons, u16 prod)
 {
 	struct sw_bd *cons_rx_buf, *prod_rx_buf;
 	struct rx_bd *cons_bd, *prod_bd;
 
-	cons_rx_buf = &bp->rx_buf_ring[cons];
-	prod_rx_buf = &bp->rx_buf_ring[prod];
+	cons_rx_buf = &rxr->rx_buf_ring[cons];
+	prod_rx_buf = &rxr->rx_buf_ring[prod];
 
 	pci_dma_sync_single_for_device(bp->pdev,
 		pci_unmap_addr(cons_rx_buf, mapping),
 		BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
-	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
+	rxr->rx_prod_bseq += bp->rx_buf_use_size;
 
 	prod_rx_buf->skb = skb;
 
@@ -2670,28 +2718,28 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 	pci_unmap_addr_set(prod_rx_buf, mapping,
 			pci_unmap_addr(cons_rx_buf, mapping));
 
-	cons_bd = &bp->rx_desc_ring[RX_RING(cons)][RX_IDX(cons)];
-	prod_bd = &bp->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
+	cons_bd = &rxr->rx_desc_ring[RX_RING(cons)][RX_IDX(cons)];
+	prod_bd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 	prod_bd->rx_bd_haddr_hi = cons_bd->rx_bd_haddr_hi;
 	prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
 }
 
 static int
-bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
+bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 	    unsigned int len, unsigned int hdr_len, dma_addr_t dma_addr,
 	    u32 ring_idx)
 {
 	int err;
 	u16 prod = ring_idx & 0xffff;
 
-	err = bnx2_alloc_rx_skb(bp, bnapi, prod);
+	err = bnx2_alloc_rx_skb(bp, rxr, prod);
 	if (unlikely(err)) {
-		bnx2_reuse_rx_skb(bp, bnapi, skb, (u16) (ring_idx >> 16), prod);
+		bnx2_reuse_rx_skb(bp, rxr, skb, (u16) (ring_idx >> 16), prod);
 		if (hdr_len) {
 			unsigned int raw_len = len + 4;
 			int pages = PAGE_ALIGN(raw_len - hdr_len) >> PAGE_SHIFT;
 
-			bnx2_reuse_rx_skb_pages(bp, bnapi, NULL, pages);
+			bnx2_reuse_rx_skb_pages(bp, rxr, NULL, pages);
 		}
 		return err;
 	}
@@ -2706,8 +2754,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 	} else {
 		unsigned int i, frag_len, frag_size, pages;
 		struct sw_pg *rx_pg;
-		u16 pg_cons = bnapi->rx_pg_cons;
-		u16 pg_prod = bnapi->rx_pg_prod;
+		u16 pg_cons = rxr->rx_pg_cons;
+		u16 pg_prod = rxr->rx_pg_prod;
 
 		frag_size = len + 4 - hdr_len;
 		pages = PAGE_ALIGN(frag_size) >> PAGE_SHIFT;
@@ -2718,9 +2766,9 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 			if (unlikely(frag_len <= 4)) {
 				unsigned int tail = 4 - frag_len;
 
-				bnapi->rx_pg_cons = pg_cons;
-				bnapi->rx_pg_prod = pg_prod;
-				bnx2_reuse_rx_skb_pages(bp, bnapi, NULL,
+				rxr->rx_pg_cons = pg_cons;
+				rxr->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, rxr, NULL,
 							pages - i);
 				skb->len -= tail;
 				if (i == 0) {
@@ -2734,7 +2782,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 				}
 				return 0;
 			}
-			rx_pg = &bp->rx_pg_ring[pg_cons];
+			rx_pg = &rxr->rx_pg_ring[pg_cons];
 
 			pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping),
 				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
@@ -2745,11 +2793,12 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 			skb_fill_page_desc(skb, i, rx_pg->page, 0, frag_len);
 			rx_pg->page = NULL;
 
-			err = bnx2_alloc_rx_page(bp, RX_PG_RING_IDX(pg_prod));
+			err = bnx2_alloc_rx_page(bp, rxr,
+						 RX_PG_RING_IDX(pg_prod));
 			if (unlikely(err)) {
-				bnapi->rx_pg_cons = pg_cons;
-				bnapi->rx_pg_prod = pg_prod;
-				bnx2_reuse_rx_skb_pages(bp, bnapi, skb,
+				rxr->rx_pg_cons = pg_cons;
+				rxr->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, rxr, skb,
 							pages - i);
 				return err;
 			}
@@ -2762,8 +2811,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 			pg_prod = NEXT_RX_BD(pg_prod);
 			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
 		}
-		bnapi->rx_pg_prod = pg_prod;
-		bnapi->rx_pg_cons = pg_cons;
+		rxr->rx_pg_prod = pg_prod;
+		rxr->rx_pg_cons = pg_cons;
 	}
 	return 0;
 }
@@ -2771,7 +2820,12 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 static inline u16
 bnx2_get_hw_rx_cons(struct bnx2_napi *bnapi)
 {
-	u16 cons = bnapi->status_blk->status_rx_quick_consumer_index0;
+	u16 cons;
+
+	if (bnapi->int_num == 0)
+		cons = bnapi->status_blk->status_rx_quick_consumer_index0;
+	else
+		cons = bnapi->status_blk_msix->status_rx_quick_consumer_index;
 
 	if (unlikely((cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT))
 		cons++;
@@ -2781,13 +2835,14 @@ bnx2_get_hw_rx_cons(struct bnx2_napi *bnapi)
 static int
 bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 {
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
 	u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
 	struct l2_fhdr *rx_hdr;
 	int rx_pkt = 0, pg_ring_used = 0;
 
 	hw_cons = bnx2_get_hw_rx_cons(bnapi);
-	sw_cons = bnapi->rx_cons;
-	sw_prod = bnapi->rx_prod;
+	sw_cons = rxr->rx_cons;
+	sw_prod = rxr->rx_prod;
 
 	/* Memory barrier necessary as speculative reads of the rx
 	 * buffer can be ahead of the index in the status block
@@ -2803,7 +2858,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		sw_ring_cons = RX_RING_IDX(sw_cons);
 		sw_ring_prod = RX_RING_IDX(sw_prod);
 
-		rx_buf = &bp->rx_buf_ring[sw_ring_cons];
+		rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
 		skb = rx_buf->skb;
 
 		rx_buf->skb = NULL;
@@ -2824,7 +2879,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			L2_FHDR_ERRORS_TOO_SHORT |
 			L2_FHDR_ERRORS_GIANT_FRAME)) {
 
-			bnx2_reuse_rx_skb(bp, bnapi, skb, sw_ring_cons,
+			bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
 					  sw_ring_prod);
 			goto next_rx;
 		}
@@ -2844,7 +2899,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 			new_skb = netdev_alloc_skb(bp->dev, len + 2);
 			if (new_skb == NULL) {
-				bnx2_reuse_rx_skb(bp, bnapi, skb, sw_ring_cons,
+				bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
 						  sw_ring_prod);
 				goto next_rx;
 			}
@@ -2856,11 +2911,11 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			skb_reserve(new_skb, 2);
 			skb_put(new_skb, len);
 
-			bnx2_reuse_rx_skb(bp, bnapi, skb,
+			bnx2_reuse_rx_skb(bp, rxr, skb,
 				sw_ring_cons, sw_ring_prod);
 
 			skb = new_skb;
-		} else if (unlikely(bnx2_rx_skb(bp, bnapi, skb, len, hdr_len,
+		} else if (unlikely(bnx2_rx_skb(bp, rxr, skb, len, hdr_len,
 			   dma_addr, (sw_ring_cons << 16) | sw_ring_prod)))
 			goto next_rx;
 
@@ -2909,16 +2964,15 @@ next_rx:
 			rmb();
 		}
 	}
-	bnapi->rx_cons = sw_cons;
-	bnapi->rx_prod = sw_prod;
+	rxr->rx_cons = sw_cons;
+	rxr->rx_prod = sw_prod;
 
 	if (pg_ring_used)
-		REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX,
-			 bnapi->rx_pg_prod);
+		REG_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
 
-	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, sw_prod);
+	REG_WR16(bp, rxr->rx_bidx_addr, sw_prod);
 
-	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bnapi->rx_prod_bseq);
+	REG_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
 
 	mmiowb();
 
@@ -3032,9 +3086,10 @@ static inline int
 bnx2_has_work(struct bnx2_napi *bnapi)
 {
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
 	struct status_block *sblk = bnapi->status_blk;
 
-	if ((bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons) ||
+	if ((bnx2_get_hw_rx_cons(bnapi) != rxr->rx_cons) ||
 	    (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons))
 		return 1;
 
@@ -3073,6 +3128,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 			  int work_done, int budget)
 {
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
 	struct status_block *sblk = bnapi->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
@@ -3093,7 +3149,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 	if (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons)
 		bnx2_tx_int(bp, bnapi, 0);
 
-	if (bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons)
+	if (bnx2_get_hw_rx_cons(bnapi) != rxr->rx_cons)
 		work_done += bnx2_rx_int(bp, bnapi, budget - work_done);
 
 	return work_done;
@@ -4532,19 +4588,21 @@ bnx2_clear_ring_states(struct bnx2 *bp)
 {
 	struct bnx2_napi *bnapi;
 	struct bnx2_tx_ring_info *txr;
+	struct bnx2_rx_ring_info *rxr;
 	int i;
 
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		bnapi = &bp->bnx2_napi[i];
 		txr = &bnapi->tx_ring;
+		rxr = &bnapi->rx_ring;
 
 		txr->tx_cons = 0;
 		txr->hw_tx_cons = 0;
-		bnapi->rx_prod_bseq = 0;
-		bnapi->rx_prod = 0;
-		bnapi->rx_cons = 0;
-		bnapi->rx_pg_prod = 0;
-		bnapi->rx_pg_cons = 0;
+		rxr->rx_prod_bseq = 0;
+		rxr->rx_prod = 0;
+		rxr->rx_cons = 0;
+		rxr->rx_pg_prod = 0;
+		rxr->rx_pg_cons = 0;
 	}
 }
 
@@ -4635,17 +4693,25 @@ bnx2_init_rxbd_rings(struct rx_bd *rx_ring[], dma_addr_t dma[], u32 buf_size,
 }
 
 static void
-bnx2_init_rx_ring(struct bnx2 *bp)
+bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 {
 	int i;
 	u16 prod, ring_prod;
-	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	u32 cid, rx_cid_addr, val;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[ring_num];
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
+
+	if (ring_num == 0)
+		cid = RX_CID;
+	else
+		cid = RX_RSS_CID + ring_num - 1;
 
-	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
+	rx_cid_addr = GET_CID_ADDR(cid);
+
+	bnx2_init_rxbd_rings(rxr->rx_desc_ring, rxr->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
 
-	bnx2_init_rx_context0(bp);
+	bnx2_init_rx_context(bp, cid);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		val = REG_RD(bp, BNX2_MQ_MAP_L2_5);
@@ -4654,54 +4720,56 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
 	if (bp->rx_pg_ring_size) {
-		bnx2_init_rxbd_rings(bp->rx_pg_desc_ring,
-				     bp->rx_pg_desc_mapping,
+		bnx2_init_rxbd_rings(rxr->rx_pg_desc_ring,
+				     rxr->rx_pg_desc_mapping,
 				     PAGE_SIZE, bp->rx_max_pg_ring);
 		val = (bp->rx_buf_use_size << 16) | PAGE_SIZE;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, val);
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_RBDC_KEY,
 		       BNX2_L2CTX_RBDC_JUMBO_KEY);
 
-		val = (u64) bp->rx_pg_desc_mapping[0] >> 32;
+		val = (u64) rxr->rx_pg_desc_mapping[0] >> 32;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_HI, val);
 
-		val = (u64) bp->rx_pg_desc_mapping[0] & 0xffffffff;
+		val = (u64) rxr->rx_pg_desc_mapping[0] & 0xffffffff;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
 
 		if (CHIP_NUM(bp) == CHIP_NUM_5709)
 			REG_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
 	}
 
-	val = (u64) bp->rx_desc_mapping[0] >> 32;
+	val = (u64) rxr->rx_desc_mapping[0] >> 32;
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 
-	val = (u64) bp->rx_desc_mapping[0] & 0xffffffff;
+	val = (u64) rxr->rx_desc_mapping[0] & 0xffffffff;
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 
-	ring_prod = prod = bnapi->rx_pg_prod;
+	ring_prod = prod = rxr->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
-		if (bnx2_alloc_rx_page(bp, ring_prod) < 0)
+		if (bnx2_alloc_rx_page(bp, rxr, ring_prod) < 0)
 			break;
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_PG_RING_IDX(prod);
 	}
-	bnapi->rx_pg_prod = prod;
+	rxr->rx_pg_prod = prod;
 
-	ring_prod = prod = bnapi->rx_prod;
+	ring_prod = prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		if (bnx2_alloc_rx_skb(bp, bnapi, ring_prod) < 0) {
+		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod) < 0)
 			break;
-		}
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_RING_IDX(prod);
 	}
-	bnapi->rx_prod = prod;
+	rxr->rx_prod = prod;
+
+	rxr->rx_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_HOST_BDIDX;
+	rxr->rx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_HOST_BSEQ;
+	rxr->rx_pg_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_HOST_PG_BDIDX;
 
-	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX,
-		 bnapi->rx_pg_prod);
-	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, prod);
+	REG_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
+	REG_WR16(bp, rxr->rx_bidx_addr, prod);
 
-	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bnapi->rx_prod_bseq);
+	REG_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
 }
 
 static void
@@ -4719,7 +4787,8 @@ bnx2_init_all_rings(struct bnx2 *bp)
 		REG_WR(bp, BNX2_TSCH_TSS_CFG, ((bp->num_tx_rings - 1) << 24) |
 		       (TX_TSS_CID << 7));
 
-	bnx2_init_rx_ring(bp);
+	for (i = 0; i < bp->num_rx_rings; i++)
+		bnx2_init_rx_ring(bp, i);
 }
 
 static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
@@ -4828,25 +4897,33 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 {
 	int i;
 
-	if (bp->rx_buf_ring == NULL)
-		return;
+	for (i = 0; i < bp->num_rx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
+		int j;
 
-	for (i = 0; i < bp->rx_max_ring_idx; i++) {
-		struct sw_bd *rx_buf = &bp->rx_buf_ring[i];
-		struct sk_buff *skb = rx_buf->skb;
+		if (rxr->rx_buf_ring == NULL)
+			return;
 
-		if (skb == NULL)
-			continue;
+		for (j = 0; j < bp->rx_max_ring_idx; j++) {
+			struct sw_bd *rx_buf = &rxr->rx_buf_ring[j];
+			struct sk_buff *skb = rx_buf->skb;
 
-		pci_unmap_single(bp->pdev, pci_unmap_addr(rx_buf, mapping),
-			bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
+			if (skb == NULL)
+				continue;
 
-		rx_buf->skb = NULL;
+			pci_unmap_single(bp->pdev,
+					 pci_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_use_size,
+					 PCI_DMA_FROMDEVICE);
 
-		dev_kfree_skb(skb);
+			rx_buf->skb = NULL;
+
+			dev_kfree_skb(skb);
+		}
+		for (j = 0; j < bp->rx_max_pg_ring_idx; j++)
+			bnx2_free_rx_page(bp, rxr, j);
 	}
-	for (i = 0; i < bp->rx_max_pg_ring_idx; i++)
-		bnx2_free_rx_page(bp, i);
 }
 
 static void
@@ -5143,10 +5220,12 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	int ret = -ENODEV;
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0], *tx_napi;
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
 
 	tx_napi = bnapi;
 
 	txr = &tx_napi->tx_ring;
+	rxr = &bnapi->rx_ring;
 	if (loopback_mode == BNX2_MAC_LOOPBACK) {
 		bp->loopback = MAC_LOOPBACK;
 		bnx2_set_mac_loopback(bp);
@@ -5218,7 +5297,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		goto loopback_test_done;
 	}
 
-	rx_buf = &bp->rx_buf_ring[rx_start_idx];
+	rx_buf = &rxr->rx_buf_ring[rx_start_idx];
 	rx_skb = rx_buf->skb;
 
 	rx_hdr = (struct l2_fhdr *) rx_skb->data;
@@ -5631,6 +5710,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 		}
 	}
 	bp->num_tx_rings = 1;
+	bp->num_rx_rings = 1;
 }
 
 /* Called with rtnl_lock */
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index e4f0fb4..1c5ce80 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6479,6 +6479,7 @@ struct l2_fhdr {
 #define TX_CID		16
 #define TX_TSS_CID	32
 #define RX_CID		0
+#define RX_RSS_CID	4
 
 #define MB_TX_CID_ADDR	MB_GET_CID_ADDR(TX_CID)
 #define MB_RX_CID_ADDR	MB_GET_CID_ADDR(RX_CID)
@@ -6584,6 +6585,27 @@ struct bnx2_tx_ring_info {
 	dma_addr_t		tx_desc_mapping;
 };
 
+struct bnx2_rx_ring_info {
+	u32			rx_prod_bseq;
+	u16			rx_prod;
+	u16			rx_cons;
+
+	u32			rx_bidx_addr;
+	u32			rx_bseq_addr;
+	u32			rx_pg_bidx_addr;
+
+	u16			rx_pg_prod;
+	u16			rx_pg_cons;
+
+	struct sw_bd		*rx_buf_ring;
+	struct rx_bd		*rx_desc_ring[MAX_RX_RINGS];
+	struct sw_pg		*rx_pg_ring;
+	struct rx_bd		*rx_pg_desc_ring[MAX_RX_PG_RINGS];
+
+	dma_addr_t		rx_desc_mapping[MAX_RX_RINGS];
+	dma_addr_t		rx_pg_desc_mapping[MAX_RX_PG_RINGS];
+};
+
 struct bnx2_napi {
 	struct napi_struct	napi		____cacheline_aligned;
 	struct bnx2		*bp;
@@ -6592,13 +6614,7 @@ struct bnx2_napi {
 	u32 			last_status_idx;
 	u32			int_num;
 
-	u32			rx_prod_bseq;
-	u16			rx_prod;
-	u16			rx_cons;
-
-	u16			rx_pg_prod;
-	u16			rx_pg_cons;
-
+	struct bnx2_rx_ring_info	rx_ring;
 	struct bnx2_tx_ring_info	tx_ring;
 };
 
@@ -6642,11 +6658,6 @@ struct bnx2 {
 
 	u32			rx_csum;
 
-	struct sw_bd		*rx_buf_ring;
-	struct rx_bd		*rx_desc_ring[MAX_RX_RINGS];
-	struct sw_pg		*rx_pg_ring;
-	struct rx_bd		*rx_pg_desc_ring[MAX_RX_PG_RINGS];
-
 	/* TX constants */
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
@@ -6727,11 +6738,9 @@ struct bnx2 {
 
 	int			rx_max_ring;
 	int			rx_ring_size;
-	dma_addr_t		rx_desc_mapping[MAX_RX_RINGS];
 
 	int			rx_max_pg_ring;
 	int			rx_pg_ring_size;
-	dma_addr_t		rx_pg_desc_mapping[MAX_RX_PG_RINGS];
 
 	u16			tx_quick_cons_trip;
 	u16			tx_quick_cons_trip_int;
@@ -6814,6 +6823,7 @@ struct bnx2 {
 	int			irq_nvecs;
 
 	u8			num_tx_rings;
+	u8			num_rx_rings;
 };
 
 #define REG_RD(bp, offset)					\
-- 
1.5.5.GIT



