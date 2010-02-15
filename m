From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 4/5] b44: replace the ssb_dma API with the generic DMA API
Date: Tue, 16 Feb 2010 00:04:09 +0900
Message-ID: <1266246250-5344-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	Gary Zambrano <zambrano@broadcom.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note that dma_sync_single_for_device and dma_sync_single_for_cpu
support a partial sync.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc:  Gary Zambrano <zambrano@broadcom.com>
---
 drivers/net/b44.c |  144 ++++++++++++++++++++++++++---------------------------
 1 files changed, 70 insertions(+), 74 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 4869adb..e4b42ee 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -148,9 +148,8 @@ static inline void b44_sync_dma_desc_for_device(struct ssb_device *sdev,
 						unsigned long offset,
 						enum dma_data_direction dir)
 {
-	ssb_dma_sync_single_range_for_device(sdev, dma_base,
-					     offset & dma_desc_align_mask,
-					     dma_desc_sync_size, dir);
+	dma_sync_single_for_device(sdev->dma_dev, dma_base + offset,
+				   dma_desc_sync_size, dir);
 }
 
 static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
@@ -158,9 +157,8 @@ static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
 					     unsigned long offset,
 					     enum dma_data_direction dir)
 {
-	ssb_dma_sync_single_range_for_cpu(sdev, dma_base,
-					  offset & dma_desc_align_mask,
-					  dma_desc_sync_size, dir);
+	dma_sync_single_for_cpu(sdev->dma_dev, dma_base + offset,
+				dma_desc_sync_size, dir);
 }
 
 static inline unsigned long br32(const struct b44 *bp, unsigned long reg)
@@ -613,10 +611,10 @@ static void b44_tx(struct b44 *bp)
 
 		BUG_ON(skb == NULL);
 
-		ssb_dma_unmap_single(bp->sdev,
-				     rp->mapping,
-				     skb->len,
-				     DMA_TO_DEVICE);
+		dma_unmap_single(bp->sdev->dma_dev,
+				 rp->mapping,
+				 skb->len,
+				 DMA_TO_DEVICE);
 		rp->skb = NULL;
 		dev_kfree_skb_irq(skb);
 	}
@@ -653,29 +651,29 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mapping = ssb_dma_map_single(bp->sdev, skb->data,
-				     RX_PKT_BUF_SZ,
-				     DMA_FROM_DEVICE);
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
+				 RX_PKT_BUF_SZ,
+				 DMA_FROM_DEVICE);
 
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
-	if (ssb_dma_mapping_error(bp->sdev, mapping) ||
+	if (dma_mapping_error(bp->sdev->dma_dev, mapping) ||
 		mapping + RX_PKT_BUF_SZ > DMA_BIT_MASK(30)) {
 		/* Sigh... */
-		if (!ssb_dma_mapping_error(bp->sdev, mapping))
-			ssb_dma_unmap_single(bp->sdev, mapping,
+		if (!dma_mapping_error(bp->sdev->dma_dev, mapping))
+			dma_unmap_single(bp->sdev->dma_dev, mapping,
 					     RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
-		mapping = ssb_dma_map_single(bp->sdev, skb->data,
-					     RX_PKT_BUF_SZ,
-					     DMA_FROM_DEVICE);
-		if (ssb_dma_mapping_error(bp->sdev, mapping) ||
-			mapping + RX_PKT_BUF_SZ > DMA_BIT_MASK(30)) {
-			if (!ssb_dma_mapping_error(bp->sdev, mapping))
-				ssb_dma_unmap_single(bp->sdev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
+		mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
+					 RX_PKT_BUF_SZ,
+					 DMA_FROM_DEVICE);
+		if (dma_mapping_error(bp->sdev->dma_dev, mapping) ||
+		    mapping + RX_PKT_BUF_SZ > DMA_BIT_MASK(30)) {
+			if (!dma_mapping_error(bp->sdev->dma_dev, mapping))
+				dma_unmap_single(bp->sdev->dma_dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -750,9 +748,9 @@ static void b44_recycle_rx(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 					     dest_idx * sizeof(*dest_desc),
 					     DMA_BIDIRECTIONAL);
 
-	ssb_dma_sync_single_for_device(bp->sdev, dest_map->mapping,
-				       RX_PKT_BUF_SZ,
-				       DMA_FROM_DEVICE);
+	dma_sync_single_for_device(bp->sdev->dma_dev, dest_map->mapping,
+				   RX_PKT_BUF_SZ,
+				   DMA_FROM_DEVICE);
 }
 
 static int b44_rx(struct b44 *bp, int budget)
@@ -772,9 +770,9 @@ static int b44_rx(struct b44 *bp, int budget)
 		struct rx_header *rh;
 		u16 len;
 
-		ssb_dma_sync_single_for_cpu(bp->sdev, map,
-					    RX_PKT_BUF_SZ,
-					    DMA_FROM_DEVICE);
+		dma_sync_single_for_cpu(bp->sdev->dma_dev, map,
+					RX_PKT_BUF_SZ,
+					DMA_FROM_DEVICE);
 		rh = (struct rx_header *) skb->data;
 		len = le16_to_cpu(rh->len);
 		if ((len > (RX_PKT_BUF_SZ - RX_PKT_OFFSET)) ||
@@ -806,8 +804,8 @@ static int b44_rx(struct b44 *bp, int budget)
 			skb_size = b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
 				goto drop_it;
-			ssb_dma_unmap_single(bp->sdev, map,
-					     skb_size, DMA_FROM_DEVICE);
+			dma_unmap_single(bp->sdev->dma_dev, map,
+					 skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
 			skb_put(skb, len + RX_PKT_OFFSET);
 			skb_pull(skb, RX_PKT_OFFSET);
@@ -961,24 +959,24 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_out;
 	}
 
-	mapping = ssb_dma_map_single(bp->sdev, skb->data, len, DMA_TO_DEVICE);
-	if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(bp->sdev->dma_dev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
 		struct sk_buff *bounce_skb;
 
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
-		if (!ssb_dma_mapping_error(bp->sdev, mapping))
-			ssb_dma_unmap_single(bp->sdev, mapping, len,
+		if (!dma_mapping_error(bp->sdev->dma_dev, mapping))
+			dma_unmap_single(bp->sdev->dma_dev, mapping, len,
 					     DMA_TO_DEVICE);
 
 		bounce_skb = __netdev_alloc_skb(dev, len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
-		mapping = ssb_dma_map_single(bp->sdev, bounce_skb->data,
-					     len, DMA_TO_DEVICE);
-		if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
-			if (!ssb_dma_mapping_error(bp->sdev, mapping))
-				ssb_dma_unmap_single(bp->sdev, mapping,
+		mapping = dma_map_single(bp->sdev->dma_dev, bounce_skb->data,
+					 len, DMA_TO_DEVICE);
+		if (dma_mapping_error(bp->sdev->dma_dev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
+			if (!dma_mapping_error(bp->sdev->dma_dev, mapping))
+				dma_unmap_single(bp->sdev->dma_dev, mapping,
 						     len, DMA_TO_DEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
@@ -1077,8 +1075,8 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		ssb_dma_unmap_single(bp->sdev, rp->mapping, RX_PKT_BUF_SZ,
-				     DMA_FROM_DEVICE);
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, RX_PKT_BUF_SZ,
+				 DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1089,8 +1087,8 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		ssb_dma_unmap_single(bp->sdev, rp->mapping, rp->skb->len,
-				     DMA_TO_DEVICE);
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, rp->skb->len,
+				 DMA_TO_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
 	}
@@ -1112,14 +1110,12 @@ static void b44_init_rings(struct b44 *bp)
 	memset(bp->tx_ring, 0, B44_TX_RING_BYTES);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		ssb_dma_sync_single_for_device(bp->sdev, bp->rx_ring_dma,
-					       DMA_TABLE_BYTES,
-					       DMA_BIDIRECTIONAL);
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->rx_ring_dma,
+					   DMA_TABLE_BYTES, DMA_BIDIRECTIONAL);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		ssb_dma_sync_single_for_device(bp->sdev, bp->tx_ring_dma,
-					       DMA_TABLE_BYTES,
-					       DMA_TO_DEVICE);
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->tx_ring_dma,
+					   DMA_TABLE_BYTES, DMA_TO_DEVICE);
 
 	for (i = 0; i < bp->rx_pending; i++) {
 		if (b44_alloc_rx_skb(bp, -1, i) < 0)
@@ -1139,27 +1135,23 @@ static void b44_free_consistent(struct b44 *bp)
 	bp->tx_buffers = NULL;
 	if (bp->rx_ring) {
 		if (bp->flags & B44_FLAG_RX_RING_HACK) {
-			ssb_dma_unmap_single(bp->sdev, bp->rx_ring_dma,
-					     DMA_TABLE_BYTES,
-					     DMA_BIDIRECTIONAL);
+			dma_unmap_single(bp->sdev->dma_dev, bp->rx_ring_dma,
+					 DMA_TABLE_BYTES, DMA_BIDIRECTIONAL);
 			kfree(bp->rx_ring);
 		} else
-			ssb_dma_free_consistent(bp->sdev, DMA_TABLE_BYTES,
-						bp->rx_ring, bp->rx_ring_dma,
-						GFP_KERNEL);
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
+					  bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 		bp->flags &= ~B44_FLAG_RX_RING_HACK;
 	}
 	if (bp->tx_ring) {
 		if (bp->flags & B44_FLAG_TX_RING_HACK) {
-			ssb_dma_unmap_single(bp->sdev, bp->tx_ring_dma,
-					     DMA_TABLE_BYTES,
-					     DMA_TO_DEVICE);
+			dma_unmap_single(bp->sdev->dma_dev, bp->tx_ring_dma,
+					 DMA_TABLE_BYTES, DMA_TO_DEVICE);
 			kfree(bp->tx_ring);
 		} else
-			ssb_dma_free_consistent(bp->sdev, DMA_TABLE_BYTES,
-						bp->tx_ring, bp->tx_ring_dma,
-						GFP_KERNEL);
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
+					  bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 		bp->flags &= ~B44_FLAG_TX_RING_HACK;
 	}
@@ -1184,7 +1176,8 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		goto out_err;
 
 	size = DMA_TABLE_BYTES;
-	bp->rx_ring = ssb_dma_alloc_consistent(bp->sdev, size, &bp->rx_ring_dma, gfp);
+	bp->rx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size,
+					 &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1196,11 +1189,11 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		if (!rx_ring)
 			goto out_err;
 
-		rx_ring_dma = ssb_dma_map_single(bp->sdev, rx_ring,
-						 DMA_TABLE_BYTES,
-						 DMA_BIDIRECTIONAL);
+		rx_ring_dma = dma_map_single(bp->sdev->dma_dev, rx_ring,
+					     DMA_TABLE_BYTES,
+					     DMA_BIDIRECTIONAL);
 
-		if (ssb_dma_mapping_error(bp->sdev, rx_ring_dma) ||
+		if (dma_mapping_error(bp->sdev->dma_dev, rx_ring_dma) ||
 			rx_ring_dma + size > DMA_BIT_MASK(30)) {
 			kfree(rx_ring);
 			goto out_err;
@@ -1211,7 +1204,8 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = ssb_dma_alloc_consistent(bp->sdev, size, &bp->tx_ring_dma, gfp);
+	bp->tx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size,
+					 &bp->tx_ring_dma, gfp);
 	if (!bp->tx_ring) {
 		/* Allocation may have failed due to ssb_dma_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1223,11 +1217,11 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		if (!tx_ring)
 			goto out_err;
 
-		tx_ring_dma = ssb_dma_map_single(bp->sdev, tx_ring,
-			                    DMA_TABLE_BYTES,
-			                    DMA_TO_DEVICE);
+		tx_ring_dma = dma_map_single(bp->sdev->dma_dev, tx_ring,
+					     DMA_TABLE_BYTES,
+					     DMA_TO_DEVICE);
 
-		if (ssb_dma_mapping_error(bp->sdev, tx_ring_dma) ||
+		if (dma_mapping_error(bp->sdev->dma_dev, tx_ring_dma) ||
 			tx_ring_dma + size > DMA_BIT_MASK(30)) {
 			kfree(tx_ring);
 			goto out_err;
@@ -2183,12 +2177,14 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 			"Failed to powerup the bus\n");
 		goto err_out_free_dev;
 	}
-	err = ssb_dma_set_mask(sdev, DMA_BIT_MASK(30));
-	if (err) {
+
+	if (dma_set_mask(sdev->dma_dev, DMA_BIT_MASK(30)) ||
+	    dma_set_coherent_mask(sdev->dma_dev, DMA_BIT_MASK(30))) {
 		dev_err(sdev->dev,
 			"Required 30BIT DMA mask unsupported by the system.\n");
 		goto err_out_powerdown;
 	}
+
 	err = b44_get_invariants(bp);
 	if (err) {
 		dev_err(sdev->dev,
-- 
1.6.5
