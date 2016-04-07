From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v5 net-next 12/15] nfp: propagate list buffer size in struct rx_ring
Date: Thu,  7 Apr 2016 19:39:45 +0100
Message-ID: <1460054388-471-13-git-send-email-jakub.kicinski@netronome.com>
References: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:34042 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbcDGSkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:40:33 -0400
Received: by mail-qg0-f53.google.com with SMTP id c6so71091100qga.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:40:32 -0700 (PDT)
In-Reply-To: <1460054388-471-1-git-send-email-jakub.kicinski@netronome.com>
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
index fc005c982b7d..9ab8e3967dc9 100644
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
index ed23b9d348c3..03c60f755de0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -957,25 +957,27 @@ static inline int nfp_net_rx_space(struct nfp_net_rx_ring *rx_ring)
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
@@ -1068,7 +1070,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 			continue;
 
 		dma_unmap_single(&pdev->dev, rx_ring->rxbufs[i].dma_addr,
-				 nn->fl_bufsz, DMA_FROM_DEVICE);
+				 rx_ring->bufsz, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rx_ring->rxbufs[i].skb);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].skb = NULL;
@@ -1090,7 +1092,8 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].skb =
-			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr);
+			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
+					     rx_ring->bufsz);
 		if (!rxbufs[i].skb) {
 			nfp_net_rx_ring_bufs_free(nn, rx_ring);
 			return -ENOMEM;
@@ -1278,7 +1281,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		skb = rx_ring->rxbufs[idx].skb;
 
-		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr);
+		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
+					       nn->fl_bufsz);
 		if (!new_skb) {
 			nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[idx].skb,
 					    rx_ring->rxbufs[idx].dma_addr);
@@ -1465,10 +1469,12 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
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
@@ -1476,6 +1482,7 @@ static int nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring)
 	int sz;
 
 	rx_ring->cnt = nn->rxd_cnt;
+	rx_ring->bufsz = fl_bufsz;
 
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
 	rx_ring->rxds = dma_zalloc_coherent(&pdev->dev, rx_ring->size,
@@ -1817,7 +1824,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		if (err)
 			goto err_cleanup_vec_p;
 
-		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring);
+		err = nfp_net_rx_ring_alloc(nn->r_vecs[r].rx_ring,
+					    nn->fl_bufsz);
 		if (err)
 			goto err_free_tx_ring_p;
 
-- 
1.9.1
