From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 3/5] b43: replace the ssb_dma API with the generic DMA API
Date: Tue, 16 Feb 2010 00:04:08 +0900
Message-ID: <1266246250-5344-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Stefano Brivio <stefano.brivio@polimi.it>
Cc: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/b43/dma.c |   65 +++++++++++++++++++++-------------------
 1 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 88d1fd0..103bddc 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -332,11 +332,11 @@ static inline
 	dma_addr_t dmaaddr;
 
 	if (tx) {
-		dmaaddr = ssb_dma_map_single(ring->dev->dev,
-					     buf, len, DMA_TO_DEVICE);
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
+					 buf, len, DMA_TO_DEVICE);
 	} else {
-		dmaaddr = ssb_dma_map_single(ring->dev->dev,
-					     buf, len, DMA_FROM_DEVICE);
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
+					 buf, len, DMA_FROM_DEVICE);
 	}
 
 	return dmaaddr;
@@ -347,11 +347,11 @@ static inline
 			  dma_addr_t addr, size_t len, int tx)
 {
 	if (tx) {
-		ssb_dma_unmap_single(ring->dev->dev,
-				     addr, len, DMA_TO_DEVICE);
+		dma_unmap_single(ring->dev->dev->dma_dev,
+				 addr, len, DMA_TO_DEVICE);
 	} else {
-		ssb_dma_unmap_single(ring->dev->dev,
-				     addr, len, DMA_FROM_DEVICE);
+		dma_unmap_single(ring->dev->dev->dma_dev,
+				 addr, len, DMA_FROM_DEVICE);
 	}
 }
 
@@ -360,7 +360,7 @@ static inline
 				 dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	ssb_dma_sync_single_for_cpu(ring->dev->dev,
+	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
 				    addr, len, DMA_FROM_DEVICE);
 }
 
@@ -369,8 +369,8 @@ static inline
 				    dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	ssb_dma_sync_single_for_device(ring->dev->dev,
-				       addr, len, DMA_FROM_DEVICE);
+	dma_sync_single_for_device(ring->dev->dev->dma_dev,
+				   addr, len, DMA_FROM_DEVICE);
 }
 
 static inline
@@ -400,9 +400,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 	 */
 	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
-	ring->descbase = ssb_dma_alloc_consistent(ring->dev->dev,
-						  B43_DMA_RINGMEMSIZE,
-						  &(ring->dmabase), flags);
+	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
+					    B43_DMA_RINGMEMSIZE,
+					    &(ring->dmabase), flags);
 	if (!ring->descbase) {
 		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
 		return -ENOMEM;
@@ -419,8 +419,8 @@ static void free_ringmemory(struct b43_dmaring *ring)
 	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
 
-	ssb_dma_free_consistent(ring->dev->dev, B43_DMA_RINGMEMSIZE,
-				ring->descbase, ring->dmabase, flags);
+	dma_free_coherent(ring->dev->dev->dma_dev, B43_DMA_RINGMEMSIZE,
+			  ring->descbase, ring->dmabase);
 }
 
 /* Reset the RX DMA channel */
@@ -527,7 +527,7 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
 				  dma_addr_t addr,
 				  size_t buffersize, bool dma_to_device)
 {
-	if (unlikely(ssb_dma_mapping_error(ring->dev->dev, addr)))
+	if (unlikely(dma_mapping_error(ring->dev->dev->dma_dev, addr)))
 		return 1;
 
 	switch (ring->type) {
@@ -873,10 +873,10 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = ssb_dma_map_single(dev->dev,
-					      ring->txhdr_cache,
-					      b43_txhdr_size(dev),
-					      DMA_TO_DEVICE);
+		dma_test = dma_map_single(dev->dev->dma_dev,
+					  ring->txhdr_cache,
+					  b43_txhdr_size(dev),
+					  DMA_TO_DEVICE);
 
 		if (b43_dma_mapping_error(ring, dma_test,
 					  b43_txhdr_size(dev), 1)) {
@@ -888,10 +888,10 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			if (!ring->txhdr_cache)
 				goto err_kfree_meta;
 
-			dma_test = ssb_dma_map_single(dev->dev,
-						      ring->txhdr_cache,
-						      b43_txhdr_size(dev),
-						      DMA_TO_DEVICE);
+			dma_test = dma_map_single(dev->dev->dma_dev,
+						  ring->txhdr_cache,
+						  b43_txhdr_size(dev),
+						  DMA_TO_DEVICE);
 
 			if (b43_dma_mapping_error(ring, dma_test,
 						  b43_txhdr_size(dev), 1)) {
@@ -902,9 +902,9 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			}
 		}
 
-		ssb_dma_unmap_single(dev->dev,
-				     dma_test, b43_txhdr_size(dev),
-				     DMA_TO_DEVICE);
+		dma_unmap_single(dev->dev->dma_dev,
+				 dma_test, b43_txhdr_size(dev),
+				 DMA_TO_DEVICE);
 	}
 
 	err = alloc_ringmemory(ring);
@@ -1017,9 +1017,12 @@ static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 	/* Try to set the DMA mask. If it fails, try falling back to a
 	 * lower mask, as we can always also support a lower one. */
 	while (1) {
-		err = ssb_dma_set_mask(dev->dev, mask);
-		if (!err)
-			break;
+		err = dma_set_mask(dev->dev->dma_dev, mask);
+		if (!err) {
+			err = dma_set_coherent_mask(dev->dev->dma_dev, mask);
+			if (!err)
+				break;
+		}
 		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_BIT_MASK(32);
 			fallback = 1;
-- 
1.6.5
