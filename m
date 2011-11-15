From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2: switch to build_skb() infrastructure
Date: Tue, 15 Nov 2011 18:30:05 +0100
Message-ID: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33297 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756825Ab1KORaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 12:30:09 -0500
Received: by wyh15 with SMTP id 15so7315837wyh.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 09:30:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is very similar to bnx2x conversion, but bnx2 only requires 16bytes
alignement at start of the received frame to store its l2_fhdr, so goal
was not to reduce skb truesize (in fact it should not change after this
patch)

Using build_skb() reduces cache line misses in the driver, since we
use cache hot skb instead of cold ones. Number of in-flight sk_buff
structures is lower, they are more likely recycled in SLUB caches
while still hot.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Michael Chan <mchan@broadcom.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---
Tested with SLUB/SLAB/SLOB on my dev machine
 drivers/net/ethernet/broadcom/bnx2.c |  137 ++++++++++++-------------
 drivers/net/ethernet/broadcom/bnx2.h |   17 ++-
 2 files changed, 85 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 32d1f92..8556077 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2734,31 +2734,27 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 }
 
 static inline int
-bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gfp_t gfp)
+bnx2_alloc_rx_data(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gfp_t gfp)
 {
-	struct sk_buff *skb;
+	u8 *data;
 	struct sw_bd *rx_buf = &rxr->rx_buf_ring[index];
 	dma_addr_t mapping;
 	struct rx_bd *rxbd = &rxr->rx_desc_ring[RX_RING(index)][RX_IDX(index)];
-	unsigned long align;
 
-	skb = __netdev_alloc_skb(bp->dev, bp->rx_buf_size, gfp);
-	if (skb == NULL) {
+	data = kmalloc(bp->rx_buf_size, gfp);
+	if (!data)
 		return -ENOMEM;
-	}
 
-	if (unlikely((align = (unsigned long) skb->data & (BNX2_RX_ALIGN - 1))))
-		skb_reserve(skb, BNX2_RX_ALIGN - align);
-
-	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_use_size,
+	mapping = dma_map_single(&bp->pdev->dev,
+				 get_l2_fhdr(data),
+				 bp->rx_buf_use_size,
 				 PCI_DMA_FROMDEVICE);
 	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
-		dev_kfree_skb(skb);
+		kfree(data);
 		return -EIO;
 	}
 
-	rx_buf->skb = skb;
-	rx_buf->desc = (struct l2_fhdr *) skb->data;
+	rx_buf->data = data;
 	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
@@ -2965,8 +2961,8 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 }
 
 static inline void
-bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
-		  struct sk_buff *skb, u16 cons, u16 prod)
+bnx2_reuse_rx_data(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
+		   u8 *data, u16 cons, u16 prod)
 {
 	struct sw_bd *cons_rx_buf, *prod_rx_buf;
 	struct rx_bd *cons_bd, *prod_bd;
@@ -2980,8 +2976,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 
 	rxr->rx_prod_bseq += bp->rx_buf_use_size;
 
-	prod_rx_buf->skb = skb;
-	prod_rx_buf->desc = (struct l2_fhdr *) skb->data;
+	prod_rx_buf->data = data;
 
 	if (cons == prod)
 		return;
@@ -2995,33 +2990,39 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 	prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
 }
 
-static int
-bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
+static struct sk_buff *
+bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u8 *data,
 	    unsigned int len, unsigned int hdr_len, dma_addr_t dma_addr,
 	    u32 ring_idx)
 {
 	int err;
 	u16 prod = ring_idx & 0xffff;
+	struct sk_buff *skb;
 
-	err = bnx2_alloc_rx_skb(bp, rxr, prod, GFP_ATOMIC);
+	err = bnx2_alloc_rx_data(bp, rxr, prod, GFP_ATOMIC);
 	if (unlikely(err)) {
-		bnx2_reuse_rx_skb(bp, rxr, skb, (u16) (ring_idx >> 16), prod);
+		bnx2_reuse_rx_data(bp, rxr, data, (u16) (ring_idx >> 16), prod);
+error:
 		if (hdr_len) {
 			unsigned int raw_len = len + 4;
 			int pages = PAGE_ALIGN(raw_len - hdr_len) >> PAGE_SHIFT;
 
 			bnx2_reuse_rx_skb_pages(bp, rxr, NULL, pages);
 		}
-		return err;
+		return NULL;
 	}
 
-	skb_reserve(skb, BNX2_RX_OFFSET);
 	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
 			 PCI_DMA_FROMDEVICE);
-
+	skb = build_skb(data);
+	if (!skb) {
+		kfree(data);
+		goto error;
+	}
+	skb_reserve(skb, ((u8 *)get_l2_fhdr(data) - data) + BNX2_RX_OFFSET);
 	if (hdr_len == 0) {
 		skb_put(skb, len);
-		return 0;
+		return skb;
 	} else {
 		unsigned int i, frag_len, frag_size, pages;
 		struct sw_pg *rx_pg;
@@ -3052,7 +3053,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 					skb_frag_size_sub(frag, tail);
 					skb->data_len -= tail;
 				}
-				return 0;
+				return skb;
 			}
 			rx_pg = &rxr->rx_pg_ring[pg_cons];
 
@@ -3074,7 +3075,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 				rxr->rx_pg_prod = pg_prod;
 				bnx2_reuse_rx_skb_pages(bp, rxr, skb,
 							pages - i);
-				return err;
+				return NULL;
 			}
 
 			dma_unmap_page(&bp->pdev->dev, mapping_old,
@@ -3091,7 +3092,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 		rxr->rx_pg_prod = pg_prod;
 		rxr->rx_pg_cons = pg_cons;
 	}
-	return 0;
+	return skb;
 }
 
 static inline u16
@@ -3130,19 +3131,17 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		struct sw_bd *rx_buf, *next_rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
+		u8 *data;
 
 		sw_ring_cons = RX_RING_IDX(sw_cons);
 		sw_ring_prod = RX_RING_IDX(sw_prod);
 
 		rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
-		skb = rx_buf->skb;
-		prefetchw(skb);
+		data = rx_buf->data;
+		rx_buf->data = NULL;
 
-		next_rx_buf =
-			&rxr->rx_buf_ring[RX_RING_IDX(NEXT_RX_BD(sw_cons))];
-		prefetch(next_rx_buf->desc);
-
-		rx_buf->skb = NULL;
+		rx_hdr = get_l2_fhdr(data);
+		prefetch(rx_hdr);
 
 		dma_addr = dma_unmap_addr(rx_buf, mapping);
 
@@ -3150,7 +3149,10 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
 			PCI_DMA_FROMDEVICE);
 
-		rx_hdr = rx_buf->desc;
+		next_rx_buf =
+			&rxr->rx_buf_ring[RX_RING_IDX(NEXT_RX_BD(sw_cons))];
+		prefetch(get_l2_fhdr(next_rx_buf->data));
+
 		len = rx_hdr->l2_fhdr_pkt_len;
 		status = rx_hdr->l2_fhdr_status;
 
@@ -3169,7 +3171,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 				       L2_FHDR_ERRORS_TOO_SHORT |
 				       L2_FHDR_ERRORS_GIANT_FRAME))) {
 
-			bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
+			bnx2_reuse_rx_data(bp, rxr, data, sw_ring_cons,
 					  sw_ring_prod);
 			if (pg_ring_used) {
 				int pages;
@@ -3184,30 +3186,29 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		len -= 4;
 
 		if (len <= bp->rx_copy_thresh) {
-			struct sk_buff *new_skb;
-
-			new_skb = netdev_alloc_skb(bp->dev, len + 6);
-			if (new_skb == NULL) {
-				bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
+			skb = netdev_alloc_skb(bp->dev, len + 6);
+			if (skb == NULL) {
+				bnx2_reuse_rx_data(bp, rxr, data, sw_ring_cons,
 						  sw_ring_prod);
 				goto next_rx;
 			}
 
 			/* aligned copy */
-			skb_copy_from_linear_data_offset(skb,
-							 BNX2_RX_OFFSET - 6,
-				      new_skb->data, len + 6);
-			skb_reserve(new_skb, 6);
-			skb_put(new_skb, len);
+			memcpy(skb->data,
+			       (u8 *)rx_hdr + BNX2_RX_OFFSET - 6,
+			       len + 6);
+			skb_reserve(skb, 6);
+			skb_put(skb, len);
 
-			bnx2_reuse_rx_skb(bp, rxr, skb,
+			bnx2_reuse_rx_data(bp, rxr, data,
 				sw_ring_cons, sw_ring_prod);
 
-			skb = new_skb;
-		} else if (unlikely(bnx2_rx_skb(bp, rxr, skb, len, hdr_len,
-			   dma_addr, (sw_ring_cons << 16) | sw_ring_prod)))
-			goto next_rx;
-
+		} else {
+			skb = bnx2_rx_skb(bp, rxr, data, len, hdr_len, dma_addr,
+					  (sw_ring_cons << 16) | sw_ring_prod);
+			if (!skb)
+				goto next_rx;
+		}
 		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
 		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG))
 			__vlan_hwaccel_put_tag(skb, rx_hdr->l2_fhdr_vlan_tag);
@@ -5234,7 +5235,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	ring_prod = prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod, GFP_KERNEL) < 0) {
+		if (bnx2_alloc_rx_data(bp, rxr, ring_prod, GFP_KERNEL) < 0) {
 			netdev_warn(bp->dev, "init'ed rx ring %d with %d/%d skbs only\n",
 				    ring_num, i, bp->rx_ring_size);
 			break;
@@ -5329,7 +5330,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	rx_size = bp->dev->mtu + ETH_HLEN + BNX2_RX_OFFSET + 8;
 
 	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
-		sizeof(struct skb_shared_info);
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	bp->rx_copy_thresh = BNX2_RX_COPY_THRESH;
 	bp->rx_pg_ring_size = 0;
@@ -5351,8 +5352,9 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	}
 
 	bp->rx_buf_use_size = rx_size;
-	/* hw alignment */
-	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
+	/* hw alignment + build_skb() overhead*/
+	bp->rx_buf_size = SKB_DATA_ALIGN(bp->rx_buf_use_size + BNX2_RX_ALIGN) +
+		NET_SKB_PAD + SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	bp->rx_jumbo_thresh = rx_size - BNX2_RX_OFFSET;
 	bp->rx_ring_size = size;
 	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
@@ -5418,9 +5420,9 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 
 		for (j = 0; j < bp->rx_max_ring_idx; j++) {
 			struct sw_bd *rx_buf = &rxr->rx_buf_ring[j];
-			struct sk_buff *skb = rx_buf->skb;
+			u8 *data = rx_buf->data;
 
-			if (skb == NULL)
+			if (data == NULL)
 				continue;
 
 			dma_unmap_single(&bp->pdev->dev,
@@ -5428,9 +5430,9 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 					 bp->rx_buf_use_size,
 					 PCI_DMA_FROMDEVICE);
 
-			rx_buf->skb = NULL;
+			rx_buf->data = NULL;
 
-			dev_kfree_skb(skb);
+			kfree(data);
 		}
 		for (j = 0; j < bp->rx_max_pg_ring_idx; j++)
 			bnx2_free_rx_page(bp, rxr, j);
@@ -5736,7 +5738,8 @@ static int
 bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 {
 	unsigned int pkt_size, num_pkts, i;
-	struct sk_buff *skb, *rx_skb;
+	struct sk_buff *skb;
+	u8 *data;
 	unsigned char *packet;
 	u16 rx_start_idx, rx_idx;
 	dma_addr_t map;
@@ -5828,14 +5831,14 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	}
 
 	rx_buf = &rxr->rx_buf_ring[rx_start_idx];
-	rx_skb = rx_buf->skb;
+	data = rx_buf->data;
 
-	rx_hdr = rx_buf->desc;
-	skb_reserve(rx_skb, BNX2_RX_OFFSET);
+	rx_hdr = get_l2_fhdr(data);
+	data = (u8 *)rx_hdr + BNX2_RX_OFFSET;
 
 	dma_sync_single_for_cpu(&bp->pdev->dev,
 		dma_unmap_addr(rx_buf, mapping),
-		bp->rx_buf_size, PCI_DMA_FROMDEVICE);
+		bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
 
 	if (rx_hdr->l2_fhdr_status &
 		(L2_FHDR_ERRORS_BAD_CRC |
@@ -5852,7 +5855,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	}
 
 	for (i = 14; i < pkt_size; i++) {
-		if (*(rx_skb->data + i) != (unsigned char) (i & 0xff)) {
+		if (*(data + i) != (unsigned char) (i & 0xff)) {
 			goto loopback_test_done;
 		}
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 99d31a7..1db2d51 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6563,12 +6563,25 @@ struct l2_fhdr {
 #define MB_TX_CID_ADDR	MB_GET_CID_ADDR(TX_CID)
 #define MB_RX_CID_ADDR	MB_GET_CID_ADDR(RX_CID)
 
+/*
+ * This driver uses new build_skb() API :
+ * RX ring buffer contains pointer to kmalloc() data only,
+ * skb are built only after Hardware filled the frame.
+ */
 struct sw_bd {
-	struct sk_buff		*skb;
-	struct l2_fhdr		*desc;
+	u8			*data;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
+/* Its faster to compute this from data than storing it in sw_bd
+ * (less cache misses)
+ */
+static inline struct l2_fhdr *get_l2_fhdr(u8 *data)
+{
+	return (struct l2_fhdr *)(PTR_ALIGN(data, BNX2_RX_ALIGN) + NET_SKB_PAD);
+}
+
+
 struct sw_pg {
 	struct page		*page;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
