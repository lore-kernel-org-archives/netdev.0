From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 10/19] nfp: cleanup tx ring flush and rename to reset
Date: Wed,  3 Feb 2016 11:45:16 +0000
Message-ID: <1454499925-16359-11-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35134 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbcBCLpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:46 -0500
Received: by mail-wm0-f50.google.com with SMTP id r129so160910940wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:45 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we never used flush without freeing the ring later
the functionality of the two operations is mixed.
Rename flush to ring reset and move there all the things
which have to be done after FW ring state is cleared.
While at it do some clean-ups.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 81 ++++++++++------------
 1 file changed, 37 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index faaa25dd5a1e..cc8b06651f57 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -868,61 +868,59 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 }
 
 /**
- * nfp_net_tx_flush() - Free any untransmitted buffers currently on the TX ring
- * @tx_ring:     TX ring structure
+ * nfp_net_tx_ring_reset() - Free any untransmitted buffers and reset pointers
+ * @nn:		NFP Net device
+ * @tx_ring:	TX ring structure
  *
  * Assumes that the device is stopped
  */
-static void nfp_net_tx_flush(struct nfp_net_tx_ring *tx_ring)
+static void
+nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 {
-	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net *nn = r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
 	const struct skb_frag_struct *frag;
 	struct netdev_queue *nd_q;
-	struct sk_buff *skb;
-	int nr_frags;
-	int fidx;
-	int idx;
+	struct pci_dev *pdev = nn->pdev;
 
 	while (tx_ring->rd_p != tx_ring->wr_p) {
-		idx = tx_ring->rd_p % tx_ring->cnt;
+		int nr_frags, fidx, idx;
+		struct sk_buff *skb;
 
+		idx = tx_ring->rd_p % tx_ring->cnt;
 		skb = tx_ring->txbufs[idx].skb;
-		if (skb) {
-			nr_frags = skb_shinfo(skb)->nr_frags;
-			fidx = tx_ring->txbufs[idx].fidx;
-
-			if (fidx == -1) {
-				/* unmap head */
-				dma_unmap_single(&pdev->dev,
-						 tx_ring->txbufs[idx].dma_addr,
-						 skb_headlen(skb),
-						 DMA_TO_DEVICE);
-			} else {
-				/* unmap fragment */
-				frag = &skb_shinfo(skb)->frags[fidx];
-				dma_unmap_page(&pdev->dev,
-					       tx_ring->txbufs[idx].dma_addr,
-					       skb_frag_size(frag),
-					       DMA_TO_DEVICE);
-			}
-
-			/* check for last gather fragment */
-			if (fidx == nr_frags - 1)
-				dev_kfree_skb_any(skb);
-
-			tx_ring->txbufs[idx].dma_addr = 0;
-			tx_ring->txbufs[idx].skb = NULL;
-			tx_ring->txbufs[idx].fidx = -2;
+		nr_frags = skb_shinfo(skb)->nr_frags;
+		fidx = tx_ring->txbufs[idx].fidx;
+
+		if (fidx == -1) {
+			/* unmap head */
+			dma_unmap_single(&pdev->dev,
+					 tx_ring->txbufs[idx].dma_addr,
+					 skb_headlen(skb), DMA_TO_DEVICE);
+		} else {
+			/* unmap fragment */
+			frag = &skb_shinfo(skb)->frags[fidx];
+			dma_unmap_page(&pdev->dev,
+				       tx_ring->txbufs[idx].dma_addr,
+				       skb_frag_size(frag), DMA_TO_DEVICE);
 		}
 
-		memset(&tx_ring->txds[idx], 0, sizeof(tx_ring->txds[idx]));
+		/* check for last gather fragment */
+		if (fidx == nr_frags - 1)
+			dev_kfree_skb_any(skb);
+
+		tx_ring->txbufs[idx].dma_addr = 0;
+		tx_ring->txbufs[idx].skb = NULL;
+		tx_ring->txbufs[idx].fidx = -2;
 
 		tx_ring->qcp_rd_p++;
 		tx_ring->rd_p++;
 	}
 
+	memset(tx_ring->txds, 0, sizeof(*tx_ring->txds) * tx_ring->cnt);
+	tx_ring->wr_p = 0;
+	tx_ring->rd_p = 0;
+	tx_ring->qcp_rd_p = 0;
+	tx_ring->wr_ptr_add = 0;
+
 	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
 	netdev_tx_reset_queue(nd_q);
 }
@@ -1360,11 +1358,6 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 				  tx_ring->txds, tx_ring->dma);
 
 	tx_ring->cnt = 0;
-	tx_ring->wr_p = 0;
-	tx_ring->rd_p = 0;
-	tx_ring->qcp_rd_p = 0;
-	tx_ring->wr_ptr_add = 0;
-
 	tx_ring->txbufs = NULL;
 	tx_ring->txds = NULL;
 	tx_ring->dma = 0;
@@ -1857,7 +1850,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	 */
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		nfp_net_rx_flush(nn->r_vecs[r].rx_ring);
-		nfp_net_tx_flush(nn->r_vecs[r].tx_ring);
+		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
-- 
1.9.1
