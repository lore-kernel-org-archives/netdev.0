From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/8][BNX2]: Add fast path code to handle RX pages.
Date: Wed, 12 Dec 2007 11:00:00 -0800
Message-ID: <1197486000.16386.31.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2402 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbXLLSP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:15:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add fast path code to handle RX pages.

Add function to reuse a page in case of allocation or other errors.
Add code to construct the completed SKB with the additional data in
the pages.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 38e8e31..6c0fc8a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2411,6 +2411,55 @@ bnx2_tx_int(struct bnx2 *bp)
 	}
 }
 
+static void
+bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct sk_buff *skb, int count)
+{
+	struct sw_pg *cons_rx_pg, *prod_rx_pg;
+	struct rx_bd *cons_bd, *prod_bd;
+	dma_addr_t mapping;
+	int i;
+	u16 hw_prod = bp->rx_pg_prod, prod;
+	u16 cons = bp->rx_pg_cons;
+
+	for (i = 0; i < count; i++) {
+		prod = RX_PG_RING_IDX(hw_prod);
+
+		prod_rx_pg = &bp->rx_pg_ring[prod];
+		cons_rx_pg = &bp->rx_pg_ring[cons];
+		cons_bd = &bp->rx_pg_desc_ring[RX_RING(cons)][RX_IDX(cons)];
+		prod_bd = &bp->rx_pg_desc_ring[RX_RING(prod)][RX_IDX(prod)];
+
+		if (i == 0 && skb) {
+			struct page *page;
+			struct skb_shared_info *shinfo;
+
+			shinfo = skb_shinfo(skb);
+			shinfo->nr_frags--;
+			page = shinfo->frags[shinfo->nr_frags].page;
+			shinfo->frags[shinfo->nr_frags].page = NULL;
+			mapping = pci_map_page(bp->pdev, page, 0, PAGE_SIZE,
+					       PCI_DMA_FROMDEVICE);
+			cons_rx_pg->page = page;
+			pci_unmap_addr_set(cons_rx_pg, mapping, mapping);
+			dev_kfree_skb(skb);
+		}
+		if (prod != cons) {
+			prod_rx_pg->page = cons_rx_pg->page;
+			cons_rx_pg->page = NULL;
+			pci_unmap_addr_set(prod_rx_pg, mapping,
+				pci_unmap_addr(cons_rx_pg, mapping));
+
+			prod_bd->rx_bd_haddr_hi = cons_bd->rx_bd_haddr_hi;
+			prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
+
+		}
+		cons = RX_PG_RING_IDX(NEXT_RX_BD(cons));
+		hw_prod = NEXT_RX_BD(hw_prod);
+	}
+	bp->rx_pg_prod = hw_prod;
+	bp->rx_pg_cons = cons;
+}
+
 static inline void
 bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 	u16 cons, u16 prod)
@@ -2443,7 +2492,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 
 static int
 bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
-	    dma_addr_t dma_addr, u32 ring_idx)
+	    unsigned int hdr_len, dma_addr_t dma_addr, u32 ring_idx)
 {
 	int err;
 	u16 prod = ring_idx & 0xffff;
@@ -2451,6 +2500,12 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 	err = bnx2_alloc_rx_skb(bp, prod);
 	if (unlikely(err)) {
 		bnx2_reuse_rx_skb(bp, skb, (u16) (ring_idx >> 16), prod);
+		if (hdr_len) {
+			unsigned int raw_len = len + 4;
+			int pages = PAGE_ALIGN(raw_len - hdr_len) >> PAGE_SHIFT;
+
+			bnx2_reuse_rx_skb_pages(bp, NULL, pages);
+		}
 		return err;
 	}
 
@@ -2458,7 +2513,69 @@ bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
 	pci_unmap_single(bp->pdev, dma_addr, bp->rx_buf_use_size,
 			 PCI_DMA_FROMDEVICE);
 
-	skb_put(skb, len);
+	if (hdr_len == 0) {
+		skb_put(skb, len);
+		return 0;
+	} else {
+		unsigned int i, frag_len, frag_size, pages;
+		struct sw_pg *rx_pg;
+		u16 pg_cons = bp->rx_pg_cons;
+		u16 pg_prod = bp->rx_pg_prod;
+
+		frag_size = len + 4 - hdr_len;
+		pages = PAGE_ALIGN(frag_size) >> PAGE_SHIFT;
+		skb_put(skb, hdr_len);
+
+		for (i = 0; i < pages; i++) {
+			frag_len = min(frag_size, (unsigned int) PAGE_SIZE);
+			if (unlikely(frag_len <= 4)) {
+				unsigned int tail = 4 - frag_len;
+
+				bp->rx_pg_cons = pg_cons;
+				bp->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, NULL, pages - i);
+				skb->len -= tail;
+				if (i == 0) {
+					skb->tail -= tail;
+				} else {
+					skb_frag_t *frag =
+						&skb_shinfo(skb)->frags[i - 1];
+					frag->size -= tail;
+					skb->data_len -= tail;
+					skb->truesize -= tail;
+				}
+				return 0;
+			}
+			rx_pg = &bp->rx_pg_ring[pg_cons];
+
+			pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping),
+				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+
+			if (i == pages - 1)
+				frag_len -= 4;
+
+			skb_fill_page_desc(skb, i, rx_pg->page, 0, frag_len);
+			rx_pg->page = NULL;
+
+			err = bnx2_alloc_rx_page(bp, RX_PG_RING_IDX(pg_prod));
+			if (unlikely(err)) {
+				bp->rx_pg_cons = pg_cons;
+				bp->rx_pg_prod = pg_prod;
+				bnx2_reuse_rx_skb_pages(bp, skb, pages - i);
+				return err;
+			}
+
+			frag_size -= frag_len;
+			skb->data_len += frag_len;
+			skb->truesize += frag_len;
+			skb->len += frag_len;
+
+			pg_prod = NEXT_RX_BD(pg_prod);
+			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
+		}
+		bp->rx_pg_prod = pg_prod;
+		bp->rx_pg_cons = pg_cons;
+	}
 	return 0;
 }
 
@@ -2477,7 +2594,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 {
 	u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
 	struct l2_fhdr *rx_hdr;
-	int rx_pkt = 0;
+	int rx_pkt = 0, pg_ring_used = 0;
 
 	hw_cons = bnx2_get_hw_rx_cons(bp);
 	sw_cons = bp->rx_cons;
@@ -2488,7 +2605,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 	 */
 	rmb();
 	while (sw_cons != hw_cons) {
-		unsigned int len;
+		unsigned int len, hdr_len;
 		u32 status;
 		struct sw_bd *rx_buf;
 		struct sk_buff *skb;
@@ -2508,7 +2625,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 			bp->rx_offset + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 		rx_hdr = (struct l2_fhdr *) skb->data;
-		len = rx_hdr->l2_fhdr_pkt_len - 4;
+		len = rx_hdr->l2_fhdr_pkt_len;
 
 		if ((status = rx_hdr->l2_fhdr_status) &
 			(L2_FHDR_ERRORS_BAD_CRC |
@@ -2520,6 +2637,16 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 			bnx2_reuse_rx_skb(bp, skb, sw_ring_cons, sw_ring_prod);
 			goto next_rx;
 		}
+		hdr_len = 0;
+		if (status & L2_FHDR_STATUS_SPLIT) {
+			hdr_len = rx_hdr->l2_fhdr_ip_xsum;
+			pg_ring_used = 1;
+		} else if (len > bp->rx_jumbo_thresh) {
+			hdr_len = bp->rx_jumbo_thresh;
+			pg_ring_used = 1;
+		}
+
+		len -= 4;
 
 		if (len <= bp->rx_copy_thresh) {
 			struct sk_buff *new_skb;
@@ -2541,7 +2668,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 				sw_ring_cons, sw_ring_prod);
 
 			skb = new_skb;
-		} else if (unlikely(bnx2_rx_skb(bp, skb, len, dma_addr,
+		} else if (unlikely(bnx2_rx_skb(bp, skb, len, hdr_len, dma_addr,
 				    (sw_ring_cons << 16) | sw_ring_prod)))
 			goto next_rx;
 
@@ -2593,6 +2720,10 @@ next_rx:
 	bp->rx_cons = sw_cons;
 	bp->rx_prod = sw_prod;
 
+	if (pg_ring_used)
+		REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX,
+			 bp->rx_pg_prod);
+
 	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, sw_prod);
 
 	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bp->rx_prod_bseq);
@@ -4375,6 +4506,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment */
 	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
+	bp->rx_jumbo_thresh = rx_size - bp->rx_offset;
 	bp->rx_ring_size = size;
 	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
 	bp->rx_max_ring_idx = (bp->rx_max_ring * RX_DESC_CNT) - 1;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 93c2436..1f244fa 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -259,6 +259,7 @@ struct l2_fhdr {
 		#define L2_FHDR_STATUS_TCP_SEGMENT	(1<<14)
 		#define L2_FHDR_STATUS_UDP_DATAGRAM	(1<<15)
 
+		#define L2_FHDR_STATUS_SPLIT		(1<<16)
 		#define L2_FHDR_ERRORS_BAD_CRC		(1<<17)
 		#define L2_FHDR_ERRORS_PHY_DECODE	(1<<18)
 		#define L2_FHDR_ERRORS_ALIGNMENT	(1<<19)
@@ -6537,6 +6538,7 @@ struct bnx2 {
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_buf_size;		/* with alignment */
 	u32			rx_copy_thresh;
+	u32			rx_jumbo_thresh;
 	u32			rx_max_ring_idx;
 	u32			rx_max_pg_ring_idx;
 


