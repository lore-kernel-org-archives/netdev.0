From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 2/5] b43legacy: replace the ssb_dma API with the generic DMA API
Date: Tue, 16 Feb 2010 00:04:07 +0900
Message-ID: <1266246250-5344-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38256 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572Ab0BOPKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 10:10:21 -0500
In-Reply-To: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stefano Brivio <stefano.brivio@polimi.it>
Cc: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/b43legacy/dma.c |   49 ++++++++++++++++++----------------
 1 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 0a86bdf..7e94324 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -393,11 +393,11 @@ dma_addr_t map_descbuffer(struct b43legacy_dmaring *ring,
 	dma_addr_t dmaaddr;
 
 	if (tx)
-		dmaaddr = ssb_dma_map_single(ring->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					     buf, len,
 					     DMA_TO_DEVICE);
 	else
-		dmaaddr = ssb_dma_map_single(ring->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					     buf, len,
 					     DMA_FROM_DEVICE);
 
@@ -411,11 +411,11 @@ void unmap_descbuffer(struct b43legacy_dmaring *ring,
 		      int tx)
 {
 	if (tx)
-		ssb_dma_unmap_single(ring->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				     addr, len,
 				     DMA_TO_DEVICE);
 	else
-		ssb_dma_unmap_single(ring->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				     addr, len,
 				     DMA_FROM_DEVICE);
 }
@@ -427,8 +427,8 @@ void sync_descbuffer_for_cpu(struct b43legacy_dmaring *ring,
 {
 	B43legacy_WARN_ON(ring->tx);
 
-	ssb_dma_sync_single_for_cpu(ring->dev->dev,
-				    addr, len, DMA_FROM_DEVICE);
+	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
+				addr, len, DMA_FROM_DEVICE);
 }
 
 static inline
@@ -438,8 +438,8 @@ void sync_descbuffer_for_device(struct b43legacy_dmaring *ring,
 {
 	B43legacy_WARN_ON(ring->tx);
 
-	ssb_dma_sync_single_for_device(ring->dev->dev,
-				       addr, len, DMA_FROM_DEVICE);
+	dma_sync_single_for_device(ring->dev->dev->dma_dev,
+				   addr, len, DMA_FROM_DEVICE);
 }
 
 static inline
@@ -459,10 +459,10 @@ void free_descriptor_buffer(struct b43legacy_dmaring *ring,
 static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 {
 	/* GFP flags must match the flags in free_ringmemory()! */
-	ring->descbase = ssb_dma_alloc_consistent(ring->dev->dev,
-						  B43legacy_DMA_RINGMEMSIZE,
-						  &(ring->dmabase),
-						  GFP_KERNEL);
+	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
+					    B43legacy_DMA_RINGMEMSIZE,
+					    &(ring->dmabase),
+					    GFP_KERNEL);
 	if (!ring->descbase) {
 		b43legacyerr(ring->dev->wl, "DMA ringmemory allocation"
 			     " failed\n");
@@ -475,8 +475,8 @@ static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 
 static void free_ringmemory(struct b43legacy_dmaring *ring)
 {
-	ssb_dma_free_consistent(ring->dev->dev, B43legacy_DMA_RINGMEMSIZE,
-				ring->descbase, ring->dmabase, GFP_KERNEL);
+	dma_free_coherent(ring->dev->dev->dma_dev, B43legacy_DMA_RINGMEMSIZE,
+			  ring->descbase, ring->dmabase);
 }
 
 /* Reset the RX DMA channel */
@@ -588,7 +588,7 @@ static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
 					 size_t buffersize,
 					 bool dma_to_device)
 {
-	if (unlikely(ssb_dma_mapping_error(ring->dev->dev, addr)))
+	if (unlikely(dma_mapping_error(ring->dev->dev->dma_dev, addr)))
 		return 1;
 
 	switch (ring->type) {
@@ -905,7 +905,7 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = ssb_dma_map_single(dev->dev, ring->txhdr_cache,
+		dma_test = dma_map_single(dev->dev->dma_dev, ring->txhdr_cache,
 					      sizeof(struct b43legacy_txhdr_fw3),
 					      DMA_TO_DEVICE);
 
@@ -919,7 +919,7 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 			if (!ring->txhdr_cache)
 				goto err_kfree_meta;
 
-			dma_test = ssb_dma_map_single(dev->dev,
+			dma_test = dma_map_single(dev->dev->dma_dev,
 					ring->txhdr_cache,
 					sizeof(struct b43legacy_txhdr_fw3),
 					DMA_TO_DEVICE);
@@ -929,9 +929,9 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 				goto err_kfree_txhdr_cache;
 		}
 
-		ssb_dma_unmap_single(dev->dev, dma_test,
-				     sizeof(struct b43legacy_txhdr_fw3),
-				     DMA_TO_DEVICE);
+		dma_unmap_single(dev->dev->dma_dev, dma_test,
+				 sizeof(struct b43legacy_txhdr_fw3),
+				 DMA_TO_DEVICE);
 	}
 
 	ring->nr_slots = nr_slots;
@@ -1039,9 +1039,12 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
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

