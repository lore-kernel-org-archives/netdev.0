From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 11/19] nfp: reorganize initial filling of RX rings
Date: Wed,  3 Feb 2016 11:45:17 +0000
Message-ID: <1454499925-16359-12-git-send-email-jakub.kicinski@netronome.com>
References: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38828 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbcBCLpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:47 -0500
Received: by mail-wm0-f51.google.com with SMTP id p63so66128935wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:46 -0800 (PST)
In-Reply-To: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate allocation of buffers from giving them to FW,
thanks to this it will be possible to move allocation
earlier on .ndo_open() path and reuse buffers during
runtime reconfiguration.

Similar to TX side clean up the spill of functionality
from flush to freeing the ring.  Unlike on TX side,
RX ring reset does not free buffers from the ring.
Ring reset means only that FW pointers are zeroed and
buffers on the ring must be placed in [0, cnt - 1)
positions.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 119 ++++++++++++++-------
 1 file changed, 78 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index cc8b06651f57..b640e1693377 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1021,62 +1021,100 @@ static void nfp_net_rx_give_one(struct nfp_net_rx_ring *rx_ring,
 }
 
 /**
- * nfp_net_rx_flush() - Free any buffers currently on the RX ring
- * @rx_ring:  RX ring to remove buffers from
+ * nfp_net_rx_ring_reset() - Reflect in SW state of freelist after disable
+ * @rx_ring:	RX ring structure
  *
- * Assumes that the device is stopped
+ * Warning: Do *not* call if ring buffers were never put on the FW freelist
+ *	    (i.e. device was not enabled)!
  */
-static void nfp_net_rx_flush(struct nfp_net_rx_ring *rx_ring)
+static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 {
-	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
-	struct pci_dev *pdev = nn->pdev;
-	int idx;
+	unsigned int wr_idx, last_idx;
 
-	while (rx_ring->rd_p != rx_ring->wr_p) {
-		idx = rx_ring->rd_p % rx_ring->cnt;
+	/* Move the empty entry to the end of the list */
+	wr_idx = rx_ring->wr_p % rx_ring->cnt;
+	last_idx = rx_ring->cnt - 1;
+	rx_ring->rxbufs[wr_idx].dma_addr = rx_ring->rxbufs[last_idx].dma_addr;
+	rx_ring->rxbufs[wr_idx].skb = rx_ring->rxbufs[last_idx].skb;
+	rx_ring->rxbufs[last_idx].dma_addr = 0;
+	rx_ring->rxbufs[last_idx].skb = NULL;
 
-		if (rx_ring->rxbufs[idx].skb) {
-			dma_unmap_single(&pdev->dev,
-					 rx_ring->rxbufs[idx].dma_addr,
-					 nn->fl_bufsz, DMA_FROM_DEVICE);
-			dev_kfree_skb_any(rx_ring->rxbufs[idx].skb);
-			rx_ring->rxbufs[idx].dma_addr = 0;
-			rx_ring->rxbufs[idx].skb = NULL;
-		}
+	memset(rx_ring->rxds, 0, sizeof(*rx_ring->rxds) * rx_ring->cnt);
+	rx_ring->wr_p = 0;
+	rx_ring->rd_p = 0;
+	rx_ring->wr_ptr_add = 0;
+}
 
-		memset(&rx_ring->rxds[idx], 0, sizeof(rx_ring->rxds[idx]));
+/**
+ * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
+ * @nn:		NFP Net device
+ * @rx_ring:	RX ring to remove buffers from
+ *
+ * Assumes that the device is stopped and buffers are in [0, ring->cnt - 1)
+ * entries.  After device is disabled nfp_net_rx_ring_reset() must be called
+ * to restore required ring geometry.
+ */
+static void
+nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
+{
+	struct pci_dev *pdev = nn->pdev;
+	unsigned int i;
 
-		rx_ring->rd_p++;
+	for (i = 0; i < rx_ring->cnt - 1; i++) {
+		/* NULL skb can only happen when initial filling of the ring
+		 * fails to allocate enough buffers and calls here to free
+		 * already allocated ones.
+		 */
+		if (!rx_ring->rxbufs[i].skb)
+			continue;
+
+		dma_unmap_single(&pdev->dev, rx_ring->rxbufs[i].dma_addr,
+				 nn->fl_bufsz, DMA_FROM_DEVICE);
+		dev_kfree_skb_any(rx_ring->rxbufs[i].skb);
+		rx_ring->rxbufs[i].dma_addr = 0;
+		rx_ring->rxbufs[i].skb = NULL;
 	}
 }
 
 /**
- * nfp_net_rx_fill_freelist() - Attempt filling freelist with RX buffers
- * @rx_ring: RX ring to fill
- *
- * Try to fill as many buffers as possible into freelist.  Return
- * number of buffers added.
- *
- * Return: Number of freelist buffers added.
+ * nfp_net_rx_ring_bufs_alloc() - Fill RX ring with buffers (don't give to FW)
+ * @nn:		NFP Net device
+ * @rx_ring:	RX ring to remove buffers from
  */
-static int nfp_net_rx_fill_freelist(struct nfp_net_rx_ring *rx_ring)
+static int
+nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 {
-	struct sk_buff *skb;
-	dma_addr_t dma_addr;
+	struct nfp_net_rx_buf *rxbufs;
+	unsigned int i;
+
+	rxbufs = rx_ring->rxbufs;
 
-	while (nfp_net_rx_space(rx_ring)) {
-		skb = nfp_net_rx_alloc_one(rx_ring, &dma_addr);
-		if (!skb) {
-			nfp_net_rx_flush(rx_ring);
+	for (i = 0; i < rx_ring->cnt - 1; i++) {
+		rxbufs[i].skb =
+			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr);
+		if (!rxbufs[i].skb) {
+			nfp_net_rx_ring_bufs_free(nn, rx_ring);
 			return -ENOMEM;
 		}
-		nfp_net_rx_give_one(rx_ring, skb, dma_addr);
 	}
 
 	return 0;
 }
 
 /**
+ * nfp_net_rx_ring_fill_freelist() - Give buffers from the ring to FW
+ * @rx_ring: RX ring to fill
+ */
+static void nfp_net_rx_ring_fill_freelist(struct nfp_net_rx_ring *rx_ring)
+{
+	unsigned int i;
+
+	for (i = 0; i < rx_ring->cnt - 1; i++)
+		nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[i].skb,
+				    rx_ring->rxbufs[i].dma_addr);
+}
+
+/**
  * nfp_net_rx_csum_has_errors() - group check if rxd has any csum errors
  * @flags: RX descriptor flags field in CPU byte order
  */
@@ -1429,10 +1467,6 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 				  rx_ring->rxds, rx_ring->dma);
 
 	rx_ring->cnt = 0;
-	rx_ring->wr_p = 0;
-	rx_ring->rd_p = 0;
-	rx_ring->wr_ptr_add = 0;
-
 	rx_ring->rxbufs = NULL;
 	rx_ring->rxds = NULL;
 	rx_ring->dma = 0;
@@ -1639,12 +1673,13 @@ static int nfp_net_start_vec(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
 
 	disable_irq(irq_vec);
 
-	err = nfp_net_rx_fill_freelist(r_vec->rx_ring);
+	err = nfp_net_rx_ring_bufs_alloc(r_vec->nfp_net, r_vec->rx_ring);
 	if (err) {
 		nn_err(nn, "RV%02d: couldn't allocate enough buffers\n",
 		       r_vec->irq_idx);
 		goto out;
 	}
+	nfp_net_rx_ring_fill_freelist(r_vec->rx_ring);
 
 	napi_enable(&r_vec->napi);
 out:
@@ -1793,7 +1828,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 err_disable_napi:
 	while (r--) {
 		napi_disable(&nn->r_vecs[r].napi);
-		nfp_net_rx_flush(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
 	}
 err_clear_config:
 	nfp_net_clear_config_and_disable(nn);
@@ -1849,7 +1885,8 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	/* Step 3: Free resources
 	 */
 	for (r = 0; r < nn->num_r_vecs; r++) {
-		nfp_net_rx_flush(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_reset(nn->r_vecs[r].rx_ring);
+		nfp_net_rx_ring_bufs_free(nn, nn->r_vecs[r].rx_ring);
 		nfp_net_tx_ring_reset(nn, nn->r_vecs[r].tx_ring);
 		nfp_net_rx_ring_free(nn->r_vecs[r].rx_ring);
 		nfp_net_tx_ring_free(nn->r_vecs[r].tx_ring);
-- 
1.9.1
