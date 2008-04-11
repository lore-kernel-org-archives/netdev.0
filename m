From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] ssb: Fix usage of struct device used for DMAing
Date: Fri, 11 Apr 2008 11:59:00 +0200
Message-ID: <200804111159.01129.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes DMA on architectures where DMA is nontrivial, like PPC64.
We must use the host-device's (PCI) struct device for any DMA
operation instead of the SSB device. For this we add a new
struct device pointer to the SSB device structure that will always
point to the right device for DMAing.

Without this patch b43 and b44 drivers won't work on complex-DMA
architectures, that for example need dev->archdata for DMA operations.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

---

John, this is a bugfix for 2.6.25


Index: wireless-testing/drivers/net/wireless/b43/dma.c
===================================================================
--- wireless-testing.orig/drivers/net/wireless/b43/dma.c	2008-04-11 01:44:28.000000000 +0200
+++ wireless-testing/drivers/net/wireless/b43/dma.c	2008-04-11 01:44:59.000000000 +0200
@@ -328,10 +328,10 @@ static inline
 	dma_addr_t dmaaddr;
 
 	if (tx) {
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len, DMA_TO_DEVICE);
 	} else {
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len, DMA_FROM_DEVICE);
 	}
 
@@ -343,9 +343,10 @@ static inline
 			  dma_addr_t addr, size_t len, int tx)
 {
 	if (tx) {
-		dma_unmap_single(ring->dev->dev->dev, addr, len, DMA_TO_DEVICE);
+		dma_unmap_single(ring->dev->dev->dma_dev,
+				 addr, len, DMA_TO_DEVICE);
 	} else {
-		dma_unmap_single(ring->dev->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				 addr, len, DMA_FROM_DEVICE);
 	}
 }
@@ -355,7 +356,7 @@ static inline
 				 dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	dma_sync_single_for_cpu(ring->dev->dev->dev,
+	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
 				addr, len, DMA_FROM_DEVICE);
 }
 
@@ -364,7 +365,7 @@ static inline
 				    dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	dma_sync_single_for_device(ring->dev->dev->dev,
+	dma_sync_single_for_device(ring->dev->dev->dma_dev,
 				   addr, len, DMA_FROM_DEVICE);
 }
 
@@ -380,7 +381,7 @@ static inline
 
 static int alloc_ringmemory(struct b43_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 	gfp_t flags = GFP_KERNEL;
 
 	/* The specs call for 4K buffers for 30- and 32-bit DMA with 4K
@@ -394,7 +395,7 @@ static int alloc_ringmemory(struct b43_d
 	 */
 	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
-	ring->descbase = dma_alloc_coherent(dev, B43_DMA_RINGMEMSIZE,
+	ring->descbase = dma_alloc_coherent(dma_dev, B43_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), flags);
 	if (!ring->descbase) {
 		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
@@ -407,9 +408,9 @@ static int alloc_ringmemory(struct b43_d
 
 static void free_ringmemory(struct b43_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 
-	dma_free_coherent(dev, B43_DMA_RINGMEMSIZE,
+	dma_free_coherent(dma_dev, B43_DMA_RINGMEMSIZE,
 			  ring->descbase, ring->dmabase);
 }
 
@@ -818,7 +819,7 @@ struct b43_dmaring *b43_setup_dmaring(st
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = dma_map_single(dev->dev->dev,
+		dma_test = dma_map_single(dev->dev->dma_dev,
 					  ring->txhdr_cache,
 					  b43_txhdr_size(dev),
 					  DMA_TO_DEVICE);
@@ -833,7 +834,7 @@ struct b43_dmaring *b43_setup_dmaring(st
 			if (!ring->txhdr_cache)
 				goto err_kfree_meta;
 
-			dma_test = dma_map_single(dev->dev->dev,
+			dma_test = dma_map_single(dev->dev->dma_dev,
 						  ring->txhdr_cache,
 						  b43_txhdr_size(dev),
 						  DMA_TO_DEVICE);
@@ -847,7 +848,7 @@ struct b43_dmaring *b43_setup_dmaring(st
 			}
 		}
 
-		dma_unmap_single(dev->dev->dev,
+		dma_unmap_single(dev->dev->dma_dev,
 				 dma_test, b43_txhdr_size(dev),
 				 DMA_TO_DEVICE);
 	}
Index: wireless-testing/drivers/ssb/main.c
===================================================================
--- wireless-testing.orig/drivers/ssb/main.c	2008-04-11 01:44:28.000000000 +0200
+++ wireless-testing/drivers/ssb/main.c	2008-04-11 11:26:39.000000000 +0200
@@ -462,15 +462,18 @@ static int ssb_devices_register(struct s
 #ifdef CONFIG_SSB_PCIHOST
 			sdev->irq = bus->host_pci->irq;
 			dev->parent = &bus->host_pci->dev;
+			sdev->dma_dev = &bus->host_pci->dev;
 #endif
 			break;
 		case SSB_BUSTYPE_PCMCIA:
 #ifdef CONFIG_SSB_PCMCIAHOST
 			sdev->irq = bus->host_pcmcia->irq.AssignedIRQ;
 			dev->parent = &bus->host_pcmcia->dev;
+			sdev->dma_dev = &bus->host_pcmcia->dev;
 #endif
 			break;
 		case SSB_BUSTYPE_SSB:
+			sdev->dma_dev = dev;
 			break;
 		}
 
@@ -1164,15 +1167,14 @@ EXPORT_SYMBOL(ssb_dma_translation);
 
 int ssb_dma_set_mask(struct ssb_device *ssb_dev, u64 mask)
 {
-	struct device *dev = ssb_dev->dev;
+	struct device *dma_dev = ssb_dev->dma_dev;
 
 #ifdef CONFIG_SSB_PCIHOST
-	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI &&
-	    !dma_supported(dev, mask))
-		return -EIO;
+	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI)
+		return dma_set_mask(dma_dev, mask);
 #endif
-	dev->coherent_dma_mask = mask;
-	dev->dma_mask = &dev->coherent_dma_mask;
+	dma_dev->coherent_dma_mask = mask;
+	dma_dev->dma_mask = &dma_dev->coherent_dma_mask;
 
 	return 0;
 }
Index: wireless-testing/include/linux/ssb/ssb.h
===================================================================
--- wireless-testing.orig/include/linux/ssb/ssb.h	2008-04-11 01:44:28.000000000 +0200
+++ wireless-testing/include/linux/ssb/ssb.h	2008-04-11 01:44:59.000000000 +0200
@@ -137,6 +137,10 @@ struct ssb_device {
 	const struct ssb_bus_ops *ops;
 
 	struct device *dev;
+	/* Pointer to the device that has to be used for
+	 * any DMA related operation. */
+	struct device *dma_dev;
+
 	struct ssb_bus *bus;
 	struct ssb_device_id id;
 
Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2008-04-11 01:44:28.000000000 +0200
+++ wireless-testing/drivers/net/b44.c	2008-04-11 01:44:59.000000000 +0200
@@ -148,7 +148,7 @@ static inline void b44_sync_dma_desc_for
 						unsigned long offset,
 						enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_device(sdev->dev, dma_base,
+	dma_sync_single_range_for_device(sdev->dma_dev, dma_base,
 					 offset & dma_desc_align_mask,
 					 dma_desc_sync_size, dir);
 }
@@ -158,7 +158,7 @@ static inline void b44_sync_dma_desc_for
 					     unsigned long offset,
 					     enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_cpu(sdev->dev, dma_base,
+	dma_sync_single_range_for_cpu(sdev->dma_dev, dma_base,
 				      offset & dma_desc_align_mask,
 				      dma_desc_sync_size, dir);
 }
@@ -613,7 +613,7 @@ static void b44_tx(struct b44 *bp)
 
 		BUG_ON(skb == NULL);
 
-		dma_unmap_single(bp->sdev->dev,
+		dma_unmap_single(bp->sdev->dma_dev,
 				 rp->mapping,
 				 skb->len,
 				 DMA_TO_DEVICE);
@@ -653,7 +653,7 @@ static int b44_alloc_rx_skb(struct b44 *
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mapping = dma_map_single(bp->sdev->dev, skb->data,
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
 				 RX_PKT_BUF_SZ,
 				 DMA_FROM_DEVICE);
 
@@ -663,19 +663,19 @@ static int b44_alloc_rx_skb(struct b44 *
 		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 		/* Sigh... */
 		if (!dma_mapping_error(mapping))
-			dma_unmap_single(bp->sdev->dev, mapping,
+			dma_unmap_single(bp->sdev->dma_dev, mapping,
 					RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
-		mapping = dma_map_single(bp->sdev->dev, skb->data,
+		mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
 					 RX_PKT_BUF_SZ,
 					 DMA_FROM_DEVICE);
 		if (dma_mapping_error(mapping) ||
 			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				dma_unmap_single(bp->sdev->dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
+				dma_unmap_single(bp->sdev->dma_dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -750,7 +750,7 @@ static void b44_recycle_rx(struct b44 *b
 					     dest_idx * sizeof(dest_desc),
 					     DMA_BIDIRECTIONAL);
 
-	dma_sync_single_for_device(bp->sdev->dev, le32_to_cpu(src_desc->addr),
+	dma_sync_single_for_device(bp->sdev->dma_dev, le32_to_cpu(src_desc->addr),
 				   RX_PKT_BUF_SZ,
 				   DMA_FROM_DEVICE);
 }
@@ -772,7 +772,7 @@ static int b44_rx(struct b44 *bp, int bu
 		struct rx_header *rh;
 		u16 len;
 
-		dma_sync_single_for_cpu(bp->sdev->dev, map,
+		dma_sync_single_for_cpu(bp->sdev->dma_dev, map,
 					    RX_PKT_BUF_SZ,
 					    DMA_FROM_DEVICE);
 		rh = (struct rx_header *) skb->data;
@@ -806,7 +806,7 @@ static int b44_rx(struct b44 *bp, int bu
 			skb_size = b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
 				goto drop_it;
-			dma_unmap_single(bp->sdev->dev, map,
+			dma_unmap_single(bp->sdev->dma_dev, map,
 					 skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
                 	skb_put(skb, len + RX_PKT_OFFSET);
@@ -966,24 +966,24 @@ static int b44_start_xmit(struct sk_buff
 		goto err_out;
 	}
 
-	mapping = dma_map_single(bp->sdev->dev, skb->data, len, DMA_TO_DEVICE);
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		struct sk_buff *bounce_skb;
 
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
-			dma_unmap_single(bp->sdev->dev, mapping, len,
+			dma_unmap_single(bp->sdev->dma_dev, mapping, len,
 					DMA_TO_DEVICE);
 
 		bounce_skb = __dev_alloc_skb(len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
-		mapping = dma_map_single(bp->sdev->dev, bounce_skb->data,
+		mapping = dma_map_single(bp->sdev->dma_dev, bounce_skb->data,
 					 len, DMA_TO_DEVICE);
 		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				dma_unmap_single(bp->sdev->dev, mapping,
+				dma_unmap_single(bp->sdev->dma_dev, mapping,
 					 len, DMA_TO_DEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
@@ -1082,7 +1082,7 @@ static void b44_free_rings(struct b44 *b
 
 		if (rp->skb == NULL)
 			continue;
-		dma_unmap_single(bp->sdev->dev, rp->mapping, RX_PKT_BUF_SZ,
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, RX_PKT_BUF_SZ,
 					DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
@@ -1094,7 +1094,7 @@ static void b44_free_rings(struct b44 *b
 
 		if (rp->skb == NULL)
 			continue;
-		dma_unmap_single(bp->sdev->dev, rp->mapping, rp->skb->len,
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, rp->skb->len,
 					DMA_TO_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
@@ -1117,12 +1117,12 @@ static void b44_init_rings(struct b44 *b
 	memset(bp->tx_ring, 0, B44_TX_RING_BYTES);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		dma_sync_single_for_device(bp->sdev->dev, bp->rx_ring_dma,
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->rx_ring_dma,
 			                  DMA_TABLE_BYTES,
 			                  DMA_BIDIRECTIONAL);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		dma_sync_single_for_device(bp->sdev->dev, bp->tx_ring_dma,
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->tx_ring_dma,
 			                  DMA_TABLE_BYTES,
 			                  DMA_TO_DEVICE);
 
@@ -1144,24 +1144,24 @@ static void b44_free_consistent(struct b
 	bp->tx_buffers = NULL;
 	if (bp->rx_ring) {
 		if (bp->flags & B44_FLAG_RX_RING_HACK) {
-			dma_unmap_single(bp->sdev->dev, bp->rx_ring_dma,
+			dma_unmap_single(bp->sdev->dma_dev, bp->rx_ring_dma,
 					DMA_TABLE_BYTES,
 					DMA_BIDIRECTIONAL);
 			kfree(bp->rx_ring);
 		} else
-			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
 					    bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 		bp->flags &= ~B44_FLAG_RX_RING_HACK;
 	}
 	if (bp->tx_ring) {
 		if (bp->flags & B44_FLAG_TX_RING_HACK) {
-			dma_unmap_single(bp->sdev->dev, bp->tx_ring_dma,
+			dma_unmap_single(bp->sdev->dma_dev, bp->tx_ring_dma,
 					DMA_TABLE_BYTES,
 					DMA_TO_DEVICE);
 			kfree(bp->tx_ring);
 		} else
-			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
 					    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 		bp->flags &= ~B44_FLAG_TX_RING_HACK;
@@ -1187,7 +1187,7 @@ static int b44_alloc_consistent(struct b
 		goto out_err;
 
 	size = DMA_TABLE_BYTES;
-	bp->rx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->rx_ring_dma, gfp);
+	bp->rx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1199,7 +1199,7 @@ static int b44_alloc_consistent(struct b
 		if (!rx_ring)
 			goto out_err;
 
-		rx_ring_dma = dma_map_single(bp->sdev->dev, rx_ring,
+		rx_ring_dma = dma_map_single(bp->sdev->dma_dev, rx_ring,
 			                    DMA_TABLE_BYTES,
 			                    DMA_BIDIRECTIONAL);
 
@@ -1214,7 +1214,7 @@ static int b44_alloc_consistent(struct b
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->tx_ring_dma, gfp);
+	bp->tx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->tx_ring_dma, gfp);
 	if (!bp->tx_ring) {
 		/* Allocation may have failed due to dma_alloc_coherent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1226,7 +1226,7 @@ static int b44_alloc_consistent(struct b
 		if (!tx_ring)
 			goto out_err;
 
-		tx_ring_dma = dma_map_single(bp->sdev->dev, tx_ring,
+		tx_ring_dma = dma_map_single(bp->sdev->dma_dev, tx_ring,
 			                    DMA_TABLE_BYTES,
 			                    DMA_TO_DEVICE);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
