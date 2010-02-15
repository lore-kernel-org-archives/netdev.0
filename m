From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 19:09:07 +0900
Message-ID: <20100215190835F.fujita.tomonori@lab.ntt.co.jp>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
	<4B78EE6A.3010207@lwfinger.net>
	<20100215162426V.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, mb@bu3sch.de,
	davem@davemloft.net, stefano.brivio@polimi.it,
	akpm@linux-foundation.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:46768 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab0BOKJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 05:09:49 -0500
In-Reply-To: <20100215162426V.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Feb 2010 16:25:14 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Mon, 15 Feb 2010 00:49:14 -0600
> Larry Finger <Larry.Finger@lwfinger.net> wrote:
> 
> > On 02/14/2010 11:21 PM, FUJITA Tomonori wrote:
> > > This patch is against -mm since it depends on the DMA API changes in
> > > -mm.
> > 
> > Are the patches that implement these DMA API changes available for testing? I
> > don't keep an -mm tree.
> 
> All the patches are in -mm and I've just uploaded the patches against
> 2.6.33-rc8:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git pending
> 
> The ssb patch depends on the latest eight patches in the tree:
> 
> http://marc.info/?l=linux-kernel&m=126596737604808&w=2

This patch replaces the rest of the ssb_dma_* API in b43legacy with
the DMA API (it depends on the previous ssb patch).

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] b43legacy: replace the ssb_dma_* API with the DMA API

Replaces all the ssb_dma_* API with the DMA API.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/wireless/b43legacy/dma.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index e7c0812..df85d93 100644
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
@@ -1039,7 +1039,7 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 	/* Try to set the DMA mask. If it fails, try falling back to a
 	 * lower mask, as we can always also support a lower one. */
 	while (1) {
-		err = ssb_dma_set_mask(dev->dev, mask);
+		err = dma_set_mask(dev->dev->dma_dev, mask);
 		if (!err)
 			break;
 		if (mask == DMA_BIT_MASK(64)) {
-- 
1.6.5

