From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/6] nfp: do simple XDP TX buffer recycling
Date: Thu, 27 Apr 2017 21:06:17 -0700
Message-ID: <20170428040620.8256-4-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33993 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdD1EHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:07:00 -0400
Received: by mail-pg0-f49.google.com with SMTP id v1so8366685pgv.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:06:59 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the RX path we follow the "drop if allocation of replacement
buffer fails" rule.  With XDP we extended that to the TX action,
so if XDP prog returned TX but allocation of replacement RX buffer
failed, we will drop the packet.

To improve our XDP TX performance extend the idea of rings being
always full to XDP TX rings.  Pre-fill the XDP TX rings with RX
buffers, and when XDP prog returns TX action swap the RX buffer
with the next buffer from the TX ring.

XDP TX complete will no longer free the buffers but let them
sit on the TX ring and wait for swap with RX buffer, instead.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   2 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 140 ++++++++++++---------
 2 files changed, 85 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 8f20fdef0754..e7e9a9848746 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -201,6 +201,7 @@ struct nfp_net_tx_buf {
  * @txds:       Virtual address of TX ring in host memory
  * @dma:        DMA address of the TX ring
  * @size:       Size, in bytes, of the TX ring (needed to free)
+ * @is_xdp:	Is this a XDP TX ring?
  */
 struct nfp_net_tx_ring {
 	struct nfp_net_r_vector *r_vec;
@@ -221,6 +222,7 @@ struct nfp_net_tx_ring {
 
 	dma_addr_t dma;
 	unsigned int size;
+	bool is_xdp;
 } ____cacheline_aligned;
 
 /* RX and freelist descriptor format */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fc0652d175fc..4fbda0eb4776 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -478,15 +478,18 @@ static irqreturn_t nfp_net_irq_exn(int irq, void *data)
  * @tx_ring:  TX ring structure
  * @r_vec:    IRQ vector servicing this ring
  * @idx:      Ring index
+ * @is_xdp:   Is this an XDP TX ring?
  */
 static void
 nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring,
-		     struct nfp_net_r_vector *r_vec, unsigned int idx)
+		     struct nfp_net_r_vector *r_vec, unsigned int idx,
+		     bool is_xdp)
 {
 	struct nfp_net *nn = r_vec->nfp_net;
 
 	tx_ring->idx = idx;
 	tx_ring->r_vec = r_vec;
+	tx_ring->is_xdp = is_xdp;
 
 	tx_ring->qcidx = tx_ring->idx * nn->stride_tx;
 	tx_ring->qcp_q = nn->tx_bar + NFP_QCP_QUEUE_OFF(tx_ring->qcidx);
@@ -994,7 +997,6 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	u32 done_pkts = 0, done_bytes = 0;
 	int idx, todo;
 	u32 qcp_rd_p;
@@ -1010,22 +1012,12 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 	else
 		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
 
+	done_pkts = todo;
 	while (todo--) {
 		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
 		tx_ring->rd_p++;
 
-		if (!tx_ring->txbufs[idx].frag)
-			continue;
-
-		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[idx].dma_addr);
-		__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
-
-		done_pkts++;
 		done_bytes += tx_ring->txbufs[idx].real_len;
-
-		tx_ring->txbufs[idx].dma_addr = 0;
-		tx_ring->txbufs[idx].frag = NULL;
-		tx_ring->txbufs[idx].fidx = -2;
 	}
 
 	tx_ring->qcp_rd_p = qcp_rd_p;
@@ -1050,42 +1042,35 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 static void
 nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 {
-	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	const struct skb_frag_struct *frag;
 	struct netdev_queue *nd_q;
 
-	while (tx_ring->rd_p != tx_ring->wr_p) {
+	while (!tx_ring->is_xdp && tx_ring->rd_p != tx_ring->wr_p) {
 		struct nfp_net_tx_buf *tx_buf;
-		int idx;
+		struct sk_buff *skb;
+		int idx, nr_frags;
 
 		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
 		tx_buf = &tx_ring->txbufs[idx];
 
-		if (tx_ring == r_vec->xdp_ring) {
-			nfp_net_dma_unmap_rx(dp, tx_buf->dma_addr);
-			__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
-		} else {
-			struct sk_buff *skb = tx_ring->txbufs[idx].skb;
-			int nr_frags = skb_shinfo(skb)->nr_frags;
-
-			if (tx_buf->fidx == -1) {
-				/* unmap head */
-				dma_unmap_single(dp->dev, tx_buf->dma_addr,
-						 skb_headlen(skb),
-						 DMA_TO_DEVICE);
-			} else {
-				/* unmap fragment */
-				frag = &skb_shinfo(skb)->frags[tx_buf->fidx];
-				dma_unmap_page(dp->dev, tx_buf->dma_addr,
-					       skb_frag_size(frag),
-					       DMA_TO_DEVICE);
-			}
+		skb = tx_ring->txbufs[idx].skb;
+		nr_frags = skb_shinfo(skb)->nr_frags;
 
-			/* check for last gather fragment */
-			if (tx_buf->fidx == nr_frags - 1)
-				dev_kfree_skb_any(skb);
+		if (tx_buf->fidx == -1) {
+			/* unmap head */
+			dma_unmap_single(dp->dev, tx_buf->dma_addr,
+					 skb_headlen(skb), DMA_TO_DEVICE);
+		} else {
+			/* unmap fragment */
+			frag = &skb_shinfo(skb)->frags[tx_buf->fidx];
+			dma_unmap_page(dp->dev, tx_buf->dma_addr,
+				       skb_frag_size(frag), DMA_TO_DEVICE);
 		}
 
+		/* check for last gather fragment */
+		if (tx_buf->fidx == nr_frags - 1)
+			dev_kfree_skb_any(skb);
+
 		tx_buf->dma_addr = 0;
 		tx_buf->skb = NULL;
 		tx_buf->fidx = -2;
@@ -1100,7 +1085,7 @@ nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 	tx_ring->qcp_rd_p = 0;
 	tx_ring->wr_ptr_add = 0;
 
-	if (tx_ring == r_vec->xdp_ring)
+	if (tx_ring->is_xdp)
 		return;
 
 	nd_q = netdev_get_tx_queue(dp->netdev, tx_ring->idx);
@@ -1492,8 +1477,6 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 {
 	struct nfp_net_tx_buf *txbuf;
 	struct nfp_net_tx_desc *txd;
-	dma_addr_t new_dma_addr;
-	void *new_frag;
 	int wr_idx;
 
 	if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
@@ -1501,17 +1484,13 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		return false;
 	}
 
-	new_frag = nfp_net_napi_alloc_one(dp, &new_dma_addr);
-	if (unlikely(!new_frag)) {
-		nfp_net_rx_drop(dp, rx_ring->r_vec, rx_ring, rxbuf, NULL);
-		return false;
-	}
-	nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
-
 	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
 
 	/* Stash the soft descriptor of the head then initialize it */
 	txbuf = &tx_ring->txbufs[wr_idx];
+
+	nfp_net_rx_give_one(dp, rx_ring, txbuf->frag, txbuf->dma_addr);
+
 	txbuf->frag = rxbuf->frag;
 	txbuf->dma_addr = rxbuf->dma_addr;
 	txbuf->fidx = -1;
@@ -1796,13 +1775,11 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
  * nfp_net_tx_ring_alloc() - Allocate resource for a TX ring
  * @dp:        NFP Net data path struct
  * @tx_ring:   TX Ring structure to allocate
- * @is_xdp:    True if ring will be used for XDP
  *
  * Return: 0 on success, negative errno otherwise.
  */
 static int
-nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring,
-		      bool is_xdp)
+nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	int sz;
@@ -1820,7 +1797,7 @@ nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring,
 	if (!tx_ring->txbufs)
 		goto err_alloc;
 
-	if (!is_xdp)
+	if (!tx_ring->is_xdp)
 		netif_set_xps_queue(dp->netdev, &r_vec->affinity_mask,
 				    tx_ring->idx);
 
@@ -1831,6 +1808,45 @@ nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring,
 	return -ENOMEM;
 }
 
+static void
+nfp_net_tx_ring_bufs_free(struct nfp_net_dp *dp,
+			  struct nfp_net_tx_ring *tx_ring)
+{
+	unsigned int i;
+
+	if (!tx_ring->is_xdp)
+		return;
+
+	for (i = 0; i < tx_ring->cnt; i++) {
+		if (!tx_ring->txbufs[i].frag)
+			return;
+
+		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[i].dma_addr);
+		__free_page(virt_to_page(tx_ring->txbufs[i].frag));
+	}
+}
+
+static int
+nfp_net_tx_ring_bufs_alloc(struct nfp_net_dp *dp,
+			   struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_tx_buf *txbufs = tx_ring->txbufs;
+	unsigned int i;
+
+	if (!tx_ring->is_xdp)
+		return 0;
+
+	for (i = 0; i < tx_ring->cnt; i++) {
+		txbufs[i].frag = nfp_net_rx_alloc_one(dp, &txbufs[i].dma_addr);
+		if (!txbufs[i].frag) {
+			nfp_net_tx_ring_bufs_free(dp, tx_ring);
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
 static int nfp_net_tx_rings_prepare(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
 	unsigned int r;
@@ -1847,17 +1863,23 @@ static int nfp_net_tx_rings_prepare(struct nfp_net *nn, struct nfp_net_dp *dp)
 			bias = dp->num_stack_tx_rings;
 
 		nfp_net_tx_ring_init(&dp->tx_rings[r], &nn->r_vecs[r - bias],
-				     r);
+				     r, bias);
 
-		if (nfp_net_tx_ring_alloc(dp, &dp->tx_rings[r], bias))
+		if (nfp_net_tx_ring_alloc(dp, &dp->tx_rings[r]))
 			goto err_free_prev;
+
+		if (nfp_net_tx_ring_bufs_alloc(dp, &dp->tx_rings[r]))
+			goto err_free_ring;
 	}
 
 	return 0;
 
 err_free_prev:
-	while (r--)
+	while (r--) {
+		nfp_net_tx_ring_bufs_free(dp, &dp->tx_rings[r]);
+err_free_ring:
 		nfp_net_tx_ring_free(&dp->tx_rings[r]);
+	}
 	kfree(dp->tx_rings);
 	return -ENOMEM;
 }
@@ -1866,8 +1888,10 @@ static void nfp_net_tx_rings_free(struct nfp_net_dp *dp)
 {
 	unsigned int r;
 
-	for (r = 0; r < dp->num_tx_rings; r++)
+	for (r = 0; r < dp->num_tx_rings; r++) {
+		nfp_net_tx_ring_bufs_free(dp, &dp->tx_rings[r]);
 		nfp_net_tx_ring_free(&dp->tx_rings[r]);
+	}
 
 	kfree(dp->tx_rings);
 }
@@ -2365,8 +2389,10 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r]);
 		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
 	}
-	for (r = 0; r < nn->dp.num_tx_rings; r++)
+	for (r = 0; r < nn->dp.num_tx_rings; r++) {
+		nfp_net_tx_ring_bufs_free(&nn->dp, &nn->dp.tx_rings[r]);
 		nfp_net_tx_ring_free(&nn->dp.tx_rings[r]);
+	}
 	for (r = 0; r < nn->dp.num_r_vecs; r++)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
-- 
2.11.0
