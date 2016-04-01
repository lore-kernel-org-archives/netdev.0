From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 06/15] nfp: cleanup tx ring flush and rename to reset
Date: Fri,  1 Apr 2016 22:06:42 +0100
Message-ID: <1459544811-24879-7-git-send-email-jakub.kicinski@netronome.com>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37415 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbcDAVHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:07 -0400
Received: by mail-wm0-f46.google.com with SMTP id p65so5354671wmp.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:06 -0700 (PDT)
In-Reply-To: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
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
index 8f7e2e044811..9a027a3cfe02 100644
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
@@ -1363,11 +1361,6 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
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
@@ -1860,7 +1853,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
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
