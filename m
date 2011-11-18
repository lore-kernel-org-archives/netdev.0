From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tg3: switch to build_skb() infrastructure
Date: Fri, 18 Nov 2011 17:47:01 +0100
Message-ID: <1321634821.3277.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54871 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757975Ab1KRQrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 11:47:06 -0500
Received: by fagn18 with SMTP id n18so4515218fag.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 08:47:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is very similar to bnx2x conversion, but simpler since no special
alignement is required, so goal was not to reduce skb truesize.

Using build_skb() reduces cache line misses in the driver, since we
use cache hot skb instead of cold ones. Number of in-flight sk_buff
structures is lower, they are more likely recycled in SLUB caches
while still hot.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Matt Carlson <mcarlson@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  115 +++++++++++++-------------
 drivers/net/ethernet/broadcom/tg3.h |    6 +
 2 files changed, 66 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 024ca1d..5060766 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -194,7 +194,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #if (NET_IP_ALIGN != 0)
 #define TG3_RX_OFFSET(tp)	((tp)->rx_offset)
 #else
-#define TG3_RX_OFFSET(tp)	0
+#define TG3_RX_OFFSET(tp)	(NET_SKB_PAD)
 #endif
 
 /* minimum number of free TX descriptors required to wake up TX process */
@@ -5370,15 +5370,15 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	}
 }
 
-static void tg3_rx_skb_free(struct tg3 *tp, struct ring_info *ri, u32 map_sz)
+static void tg3_rx_data_free(struct tg3 *tp, struct ring_info *ri, u32 map_sz)
 {
-	if (!ri->skb)
+	if (!ri->data)
 		return;
 
 	pci_unmap_single(tp->pdev, dma_unmap_addr(ri, mapping),
 			 map_sz, PCI_DMA_FROMDEVICE);
-	dev_kfree_skb_any(ri->skb);
-	ri->skb = NULL;
+	kfree(ri->data);
+	ri->data = NULL;
 }
 
 /* Returns size of skb allocated or < 0 on error.
@@ -5392,28 +5392,28 @@ static void tg3_rx_skb_free(struct tg3 *tp, struct ring_info *ri, u32 map_sz)
  * buffers the cpu only reads the last cacheline of the RX descriptor
  * (to fetch the error flags, vlan tag, checksum, and opaque cookie).
  */
-static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
+static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 			    u32 opaque_key, u32 dest_idx_unmasked)
 {
 	struct tg3_rx_buffer_desc *desc;
 	struct ring_info *map;
-	struct sk_buff *skb;
+	u8 *data;
 	dma_addr_t mapping;
-	int skb_size, dest_idx;
+	int skb_size, data_size, dest_idx;
 
 	switch (opaque_key) {
 	case RXD_OPAQUE_RING_STD:
 		dest_idx = dest_idx_unmasked & tp->rx_std_ring_mask;
 		desc = &tpr->rx_std[dest_idx];
 		map = &tpr->rx_std_buffers[dest_idx];
-		skb_size = tp->rx_pkt_map_sz;
+		data_size = tp->rx_pkt_map_sz;
 		break;
 
 	case RXD_OPAQUE_RING_JUMBO:
 		dest_idx = dest_idx_unmasked & tp->rx_jmb_ring_mask;
 		desc = &tpr->rx_jmb[dest_idx].std;
 		map = &tpr->rx_jmb_buffers[dest_idx];
-		skb_size = TG3_RX_JMB_MAP_SZ;
+		data_size = TG3_RX_JMB_MAP_SZ;
 		break;
 
 	default:
@@ -5426,31 +5426,33 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	 * Callers depend upon this behavior and assume that
 	 * we leave everything unchanged if we fail.
 	 */
-	skb = netdev_alloc_skb(tp->dev, skb_size + TG3_RX_OFFSET(tp));
-	if (skb == NULL)
+	skb_size = SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
+		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	data = kmalloc(skb_size, GFP_ATOMIC);
+	if (!data)
 		return -ENOMEM;
 
-	skb_reserve(skb, TG3_RX_OFFSET(tp));
-
-	mapping = pci_map_single(tp->pdev, skb->data, skb_size,
+	mapping = pci_map_single(tp->pdev,
+				 data + TG3_RX_OFFSET(tp),
+				 data_size,
 				 PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(tp->pdev, mapping)) {
-		dev_kfree_skb(skb);
+		kfree(data);
 		return -EIO;
 	}
 
-	map->skb = skb;
+	map->data = data;
 	dma_unmap_addr_set(map, mapping, mapping);
 
 	desc->addr_hi = ((u64)mapping >> 32);
 	desc->addr_lo = ((u64)mapping & 0xffffffff);
 
-	return skb_size;
+	return data_size;
 }
 
 /* We only need to move over in the address because the other
  * members of the RX descriptor are invariant.  See notes above
- * tg3_alloc_rx_skb for full details.
+ * tg3_alloc_rx_data for full details.
  */
 static void tg3_recycle_rx(struct tg3_napi *tnapi,
 			   struct tg3_rx_prodring_set *dpr,
@@ -5484,7 +5486,7 @@ static void tg3_recycle_rx(struct tg3_napi *tnapi,
 		return;
 	}
 
-	dest_map->skb = src_map->skb;
+	dest_map->data = src_map->data;
 	dma_unmap_addr_set(dest_map, mapping,
 			   dma_unmap_addr(src_map, mapping));
 	dest_desc->addr_hi = src_desc->addr_hi;
@@ -5495,7 +5497,7 @@ static void tg3_recycle_rx(struct tg3_napi *tnapi,
 	 */
 	smp_wmb();
 
-	src_map->skb = NULL;
+	src_map->data = NULL;
 }
 
 /* The RX ring scheme is composed of multiple rings which post fresh
@@ -5549,19 +5551,20 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u32 opaque_key, desc_idx, *post_ptr;
+		u8 *data;
 
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 		if (opaque_key == RXD_OPAQUE_RING_STD) {
 			ri = &tp->napi[0].prodring.rx_std_buffers[desc_idx];
 			dma_addr = dma_unmap_addr(ri, mapping);
-			skb = ri->skb;
+			data = ri->data;
 			post_ptr = &std_prod_idx;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
 			ri = &tp->napi[0].prodring.rx_jmb_buffers[desc_idx];
 			dma_addr = dma_unmap_addr(ri, mapping);
-			skb = ri->skb;
+			data = ri->data;
 			post_ptr = &jmb_prod_idx;
 		} else
 			goto next_pkt_nopost;
@@ -5579,13 +5582,14 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			goto next_pkt;
 		}
 
+		prefetch(data + TG3_RX_OFFSET(tp));
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) -
 		      ETH_FCS_LEN;
 
 		if (len > TG3_RX_COPY_THRESH(tp)) {
 			int skb_size;
 
-			skb_size = tg3_alloc_rx_skb(tp, tpr, opaque_key,
+			skb_size = tg3_alloc_rx_data(tp, tpr, opaque_key,
 						    *post_ptr);
 			if (skb_size < 0)
 				goto drop_it;
@@ -5593,35 +5597,37 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
 
-			/* Ensure that the update to the skb happens
+			skb = build_skb(data);
+			if (!skb) {
+				kfree(data);
+				goto drop_it_no_recycle;
+			}
+			skb_reserve(skb, TG3_RX_OFFSET(tp));
+			/* Ensure that the update to the data happens
 			 * after the usage of the old DMA mapping.
 			 */
 			smp_wmb();
 
-			ri->skb = NULL;
+			ri->data = NULL;
 
-			skb_put(skb, len);
 		} else {
-			struct sk_buff *copy_skb;
-
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
 
-			copy_skb = netdev_alloc_skb(tp->dev, len +
-						    TG3_RAW_IP_ALIGN);
-			if (copy_skb == NULL)
+			skb = netdev_alloc_skb(tp->dev,
+					       len + TG3_RAW_IP_ALIGN);
+			if (skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
-			skb_put(copy_skb, len);
+			skb_reserve(skb, TG3_RAW_IP_ALIGN);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
-			skb_copy_from_linear_data(skb, copy_skb->data, len);
+			memcpy(skb->data,
+			       data + TG3_RX_OFFSET(tp),
+			       len);
 			pci_dma_sync_single_for_device(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
-
-			/* We'll reuse the original ring buffer. */
-			skb = copy_skb;
 		}
 
+		skb_put(skb, len);
 		if ((tp->dev->features & NETIF_F_RXCSUM) &&
 		    (desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
 		    (((desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
@@ -5760,7 +5766,7 @@ static int tg3_rx_prodring_xfer(struct tg3 *tp,
 		di = dpr->rx_std_prod_idx;
 
 		for (i = di; i < di + cpycnt; i++) {
-			if (dpr->rx_std_buffers[i].skb) {
+			if (dpr->rx_std_buffers[i].data) {
 				cpycnt = i - di;
 				err = -ENOSPC;
 				break;
@@ -5818,7 +5824,7 @@ static int tg3_rx_prodring_xfer(struct tg3 *tp,
 		di = dpr->rx_jmb_prod_idx;
 
 		for (i = di; i < di + cpycnt; i++) {
-			if (dpr->rx_jmb_buffers[i].skb) {
+			if (dpr->rx_jmb_buffers[i].data) {
 				cpycnt = i - di;
 				err = -ENOSPC;
 				break;
@@ -7056,14 +7062,14 @@ static void tg3_rx_prodring_free(struct tg3 *tp,
 	if (tpr != &tp->napi[0].prodring) {
 		for (i = tpr->rx_std_cons_idx; i != tpr->rx_std_prod_idx;
 		     i = (i + 1) & tp->rx_std_ring_mask)
-			tg3_rx_skb_free(tp, &tpr->rx_std_buffers[i],
+			tg3_rx_data_free(tp, &tpr->rx_std_buffers[i],
 					tp->rx_pkt_map_sz);
 
 		if (tg3_flag(tp, JUMBO_CAPABLE)) {
 			for (i = tpr->rx_jmb_cons_idx;
 			     i != tpr->rx_jmb_prod_idx;
 			     i = (i + 1) & tp->rx_jmb_ring_mask) {
-				tg3_rx_skb_free(tp, &tpr->rx_jmb_buffers[i],
+				tg3_rx_data_free(tp, &tpr->rx_jmb_buffers[i],
 						TG3_RX_JMB_MAP_SZ);
 			}
 		}
@@ -7072,12 +7078,12 @@ static void tg3_rx_prodring_free(struct tg3 *tp,
 	}
 
 	for (i = 0; i <= tp->rx_std_ring_mask; i++)
-		tg3_rx_skb_free(tp, &tpr->rx_std_buffers[i],
+		tg3_rx_data_free(tp, &tpr->rx_std_buffers[i],
 				tp->rx_pkt_map_sz);
 
 	if (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS)) {
 		for (i = 0; i <= tp->rx_jmb_ring_mask; i++)
-			tg3_rx_skb_free(tp, &tpr->rx_jmb_buffers[i],
+			tg3_rx_data_free(tp, &tpr->rx_jmb_buffers[i],
 					TG3_RX_JMB_MAP_SZ);
 	}
 }
@@ -7133,7 +7139,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
+		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
 			netdev_warn(tp->dev,
 				    "Using a smaller RX standard ring. Only "
 				    "%d out of %d buffers were allocated "
@@ -7165,7 +7171,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 	}
 
 	for (i = 0; i < tp->rx_jumbo_pending; i++) {
-		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_JUMBO, i) < 0) {
+		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_JUMBO, i) < 0) {
 			netdev_warn(tp->dev,
 				    "Using a smaller RX jumbo ring. Only %d "
 				    "out of %d buffers were allocated "
@@ -11374,8 +11380,8 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 	u32 rx_start_idx, rx_idx, tx_idx, opaque_key;
 	u32 base_flags = 0, mss = 0, desc_idx, coal_now, data_off, val;
 	u32 budget;
-	struct sk_buff *skb, *rx_skb;
-	u8 *tx_data;
+	struct sk_buff *skb;
+	u8 *tx_data, *rx_data;
 	dma_addr_t map;
 	int num_pkts, tx_len, rx_len, i, err;
 	struct tg3_rx_buffer_desc *desc;
@@ -11543,11 +11549,11 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 		}
 
 		if (opaque_key == RXD_OPAQUE_RING_STD) {
-			rx_skb = tpr->rx_std_buffers[desc_idx].skb;
+			rx_data = tpr->rx_std_buffers[desc_idx].data;
 			map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx],
 					     mapping);
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
-			rx_skb = tpr->rx_jmb_buffers[desc_idx].skb;
+			rx_data = tpr->rx_jmb_buffers[desc_idx].data;
 			map = dma_unmap_addr(&tpr->rx_jmb_buffers[desc_idx],
 					     mapping);
 		} else
@@ -11556,15 +11562,16 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 		pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len,
 					    PCI_DMA_FROMDEVICE);
 
+		rx_data += TG3_RX_OFFSET(tp);
 		for (i = data_off; i < rx_len; i++, val++) {
-			if (*(rx_skb->data + i) != (u8) (val & 0xff))
+			if (*(rx_data + i) != (u8) (val & 0xff))
 				goto out;
 		}
 	}
 
 	err = 0;
 
-	/* tg3_free_rings will unmap and free the rx_skb */
+	/* tg3_free_rings will unmap and free the rx_data */
 out:
 	return err;
 }
@@ -14522,11 +14529,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tg3_flag_clear(tp, POLL_SERDES);
 
-	tp->rx_offset = NET_IP_ALIGN;
+	tp->rx_offset = NET_SKB_PAD + NET_IP_ALIGN;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    tg3_flag(tp, PCIX_MODE)) {
-		tp->rx_offset = 0;
+		tp->rx_offset = NET_SKB_PAD;
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		tp->rx_copy_thresh = ~(u16)0;
 #endif
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 94b4bd0..8e2f380 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2662,9 +2662,13 @@ struct tg3_hw_stats {
 /* 'mapping' is superfluous as the chip does not write into
  * the tx/rx post rings so we could just fetch it from there.
  * But the cache behavior is better how we are doing it now.
+ *
+ * This driver uses new build_skb() API :
+ * RX ring buffer contains pointer to kmalloc() data only,
+ * skb are built only after Hardware filled the frame.
  */
 struct ring_info {
-	struct sk_buff			*skb;
+	u8				*data;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
