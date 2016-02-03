From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 16/19] nfp: propagate list buffer size in struct rx_ring
Date: Wed,  3 Feb 2016 11:45:22 +0000
Message-ID: <1454499925-16359-17-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37338 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466AbcBCLpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:52 -0500
Received: by mail-wm0-f46.google.com with SMTP id l66so66153119wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:51 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free list buffer size needs to be propagated to few functions
as a parameter and added to struct nfp_net_rx_ring since soon
some of the functions will be reused to manage rings with
buffers of size different than nn->fl_bufsz.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 +++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 24 ++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 0a87571a7d9c..1e08c9cf3ee0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -298,6 +298,8 @@ struct nfp_net_rx_buf {
  * @rxds:       Virtual address of FL/RX ring in host memory
  * @dma:        DMA address of the FL/RX ring
  * @size:       Size, in bytes, of the FL/RX ring (needed to free)
+ * @bufsz:	Buffer allocation size for convenience of management routines
+ *		(NOTE: this is in second cache line, do not use on fast path!)
  */
 struct nfp_net_rx_ring {
 	struct nfp_net_r_vector *r_vec;
@@ -319,6 +321,7 @@ struct nfp_net_rx_ring {
 
 	dma_addr_t dma;
 	unsigned int size;
+	unsigned int bufsz;
 } ____cacheline_aligned;
 
 /**
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 15d695cd8c44..fd226d2e8606 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -958,25 +958,27 @@ static inline int nfp_net_rx_space(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_alloc_one() - Allocate and map skb for RX
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
+ * @fl_bufsz:	size of freelist buffers
  *
  * This function will allcate a new skb, map it for DMA.
  *
  * Return: allocated skb or NULL on failure.
  */
 static struct sk_buff *
-nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr)
+nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
+		     unsigned int fl_bufsz)
 {
 	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
 	struct sk_buff *skb;
 
-	skb = netdev_alloc_skb(nn->netdev, nn->fl_bufsz);
+	skb = netdev_alloc_skb(nn->netdev, fl_bufsz);
 	if (!skb) {
 		nn_warn_ratelimit(nn, "Failed to alloc receive SKB\n");
 		return NULL;
 	}
 
 	*dma_addr = dma_map_single(&nn->pdev->dev, skb->data,
-				  nn->fl_bufsz, DMA_FROM_DEVICE);
+				   fl_bufsz, DMA_FROM_DEVICE);
 	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
 		dev_kfree_skb_any(skb);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
@@ -1069,7 +1071,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 			continue;
 
 		dma_unmap_single(&pdev->dev, rx_ring->rxbufs[i].dma_addr,
-				 nn->fl_bufsz, DMA_FROM_DEVICE);
+				 rx_ring->bufsz, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rx_ring->rxbufs[i].skb);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].skb = NULL;
@@ -1091,7 +1093,8 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].skb =
-			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr);
+			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
+					     rx_ring->bufsz);
 		if (!rxbufs[i].skb) {
 			nfp_net_rx_ring_bufs_free(nn, rx_ring);
 			return -ENOMEM;
@@ -1279,7 +1282,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		skb = rx_ring->rxbufs[idx].skb;
 
-		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr);
+		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
+					       nn->fl_bufsz);
 		if (!new_skb) {
 			nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[idx].skb,
 					    rx_ring->rxbufs[idx].dma_addr);
@@ -1463,10 +1467,12 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 /**
  * nfp_net_rx_ring_alloc() - Allocate resource for a RX ring
  * @rx_ring:  RX ring to allocate
+ * @fl_bufsz: Size of buffers to allocate
  *
  * Return: 0 on success, negative errno otherwise.
  */
-static int nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring)
+static int
+nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
@@ -1474,6 +1480,7 @@ static int nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring)
 	int sz;
 
 	rx_ring->cnt = nn->rxd_cnt;
+	rx_ring->bufsz = fl_bufsz;
 
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
 	rx_ring->rxds = dma_zalloc_coherent(&pdev->dev, rx_ring->size,
@@ -1810,7 +1817,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		if (err)
 			goto err_cleanup_vec_p;
 
-		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring);
+		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring,
+					    nn->fl_bufsz);
 		if (err)
 			goto err_free_tx_ring_p;
 
-- 
1.9.1
