From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/13] nfp: add XDP support in the driver
Date: Thu,  3 Nov 2016 13:58:56 +0000
Message-ID: <1478181538-20778-12-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36282 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757648AbcKCN72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:28 -0400
Received: by mail-wm0-f45.google.com with SMTP id p190so335327875wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:27 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add XDP support.  Separate stack's and XDP's TX rings logically.
Add functions for handling XDP_TX and cleanup of XDP's TX rings.
For XDP allocate all RX buffers as separate pages and map them
with DMA_BIDIRECTIONAL.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  17 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 474 +++++++++++++++++----
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  37 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  22 +-
 4 files changed, 449 insertions(+), 101 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 486e7c6453bc..abc9e56e93b8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -171,7 +171,10 @@ struct nfp_net_tx_desc {
  *		on the head's buffer). Equal to skb->len for non-TSO packets.
  */
 struct nfp_net_tx_buf {
-	struct sk_buff *skb;
+	union {
+		struct sk_buff *skb;
+		void *frag;
+	};
 	dma_addr_t dma_addr;
 	short int fidx;
 	u16 pkt_cnt;
@@ -341,6 +344,7 @@ struct nfp_net_rx_ring {
  * @napi:           NAPI structure for this ring vec
  * @tx_ring:        Pointer to TX ring
  * @rx_ring:        Pointer to RX ring
+ * @xdp_ring:	    Pointer to an extra TX ring for XDP
  * @irq_idx:        Index into MSI-X table
  * @rx_sync:	    Seqlock for atomic updates of RX stats
  * @rx_pkts:        Number of received packets
@@ -384,6 +388,8 @@ struct nfp_net_r_vector {
 	u64 hw_csum_rx_inner_ok;
 	u64 hw_csum_rx_error;
 
+	struct nfp_net_tx_ring *xdp_ring;
+
 	struct u64_stats_sync tx_sync;
 	u64 tx_pkts;
 	u64 tx_bytes;
@@ -432,6 +438,7 @@ struct nfp_stat_pair {
  * @ctrl:               Local copy of the control register/word.
  * @fl_bufsz:           Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
+ * @xdp_prog:		Installed XDP program
  * @cpp:                Pointer to the CPP handle
  * @nfp_dev_cpp:        Pointer to the NFP Device handle
  * @ctrl_area:          Pointer to the CPP area for the control BAR
@@ -451,6 +458,7 @@ struct nfp_stat_pair {
  * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
  * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
  * @num_tx_rings:       Currently configured number of TX rings
+ * @num_stack_tx_rings:	Number of TX rings used by the stack (not XDP)
  * @num_rx_rings:       Currently configured number of RX rings
  * @txd_cnt:            Size of the TX ring in number of descriptors
  * @rxd_cnt:            Size of the RX ring in number of descriptors
@@ -500,6 +508,8 @@ struct nfp_net {
 
 	u32 rx_offset;
 
+	struct bpf_prog *xdp_prog;
+
 	struct nfp_net_tx_ring *tx_rings;
 	struct nfp_net_rx_ring *rx_rings;
 
@@ -532,6 +542,7 @@ struct nfp_net {
 	unsigned int max_rx_rings;
 
 	unsigned int num_tx_rings;
+	unsigned int num_stack_tx_rings;
 	unsigned int num_rx_rings;
 
 	int stride_tx;
@@ -779,8 +790,8 @@ struct nfp_net *
 int nfp_net_irqs_alloc(struct nfp_net *nn);
 void nfp_net_irqs_disable(struct nfp_net *nn);
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_ring_set *rx,
-		      struct nfp_net_ring_set *tx);
+nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
 
 #ifdef CONFIG_NFP_NET_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2ab63661a6fd..fa43dbcecc4f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -41,6 +41,7 @@
  *          Chris Telfer <chris.telfer@netronome.com>
  */
 
+#include <linux/bpf.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -490,6 +491,7 @@ static void nfp_net_irqs_assign(struct net_device *netdev)
 
 	nn->num_rx_rings = min(nn->num_r_vecs, nn->num_rx_rings);
 	nn->num_tx_rings = min(nn->num_r_vecs, nn->num_tx_rings);
+	nn->num_stack_tx_rings = nn->num_tx_rings;
 
 	nn->lsc_handler = nfp_net_irq_lsc;
 	nn->exn_handler = nfp_net_irq_exn;
@@ -713,6 +715,13 @@ static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	u64_stats_update_end(&r_vec->tx_sync);
 }
 
+static void nfp_net_tx_xmit_more_flush(struct nfp_net_tx_ring *tx_ring)
+{
+	wmb();
+	nfp_qcp_wr_ptr_add(tx_ring->qcp_q, tx_ring->wr_ptr_add);
+	tx_ring->wr_ptr_add = 0;
+}
+
 /**
  * nfp_net_tx() - Main transmit entry point
  * @skb:    SKB to transmit
@@ -827,12 +836,8 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 		nfp_net_tx_ring_stop(nd_q, tx_ring);
 
 	tx_ring->wr_ptr_add += nr_frags + 1;
-	if (!skb->xmit_more || netif_xmit_stopped(nd_q)) {
-		/* force memory write before we let HW know */
-		wmb();
-		nfp_qcp_wr_ptr_add(tx_ring->qcp_q, tx_ring->wr_ptr_add);
-		tx_ring->wr_ptr_add = 0;
-	}
+	if (!skb->xmit_more || netif_xmit_stopped(nd_q))
+		nfp_net_tx_xmit_more_flush(tx_ring);
 
 	skb_tx_timestamp(skb);
 
@@ -954,6 +959,56 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
 }
 
+static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	u32 done_pkts = 0, done_bytes = 0;
+	int idx, todo;
+	u32 qcp_rd_p;
+
+	/* Work out how many descriptors have been transmitted */
+	qcp_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
+
+	if (qcp_rd_p == tx_ring->qcp_rd_p)
+		return;
+
+	if (qcp_rd_p > tx_ring->qcp_rd_p)
+		todo = qcp_rd_p - tx_ring->qcp_rd_p;
+	else
+		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
+
+	while (todo--) {
+		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
+		tx_ring->rd_p++;
+
+		if (!tx_ring->txbufs[idx].frag)
+			continue;
+
+		nfp_net_dma_unmap_rx(nn, tx_ring->txbufs[idx].dma_addr,
+				     nn->fl_bufsz, DMA_BIDIRECTIONAL);
+		__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
+
+		done_pkts++;
+		done_bytes += tx_ring->txbufs[idx].real_len;
+
+		tx_ring->txbufs[idx].dma_addr = 0;
+		tx_ring->txbufs[idx].frag = NULL;
+		tx_ring->txbufs[idx].fidx = -2;
+	}
+
+	tx_ring->qcp_rd_p = qcp_rd_p;
+
+	u64_stats_update_begin(&r_vec->tx_sync);
+	r_vec->tx_bytes += done_bytes;
+	r_vec->tx_pkts += done_pkts;
+	u64_stats_update_end(&r_vec->tx_sync);
+
+	WARN_ONCE(tx_ring->wr_p - tx_ring->rd_p > tx_ring->cnt,
+		  "TX ring corruption rd_p=%u wr_p=%u cnt=%u\n",
+		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+}
+
 /**
  * nfp_net_tx_ring_reset() - Free any untransmitted buffers and reset pointers
  * @nn:		NFP Net device
@@ -964,39 +1019,47 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 static void
 nfp_net_tx_ring_reset(struct nfp_net *nn, struct nfp_net_tx_ring *tx_ring)
 {
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	const struct skb_frag_struct *frag;
-	struct netdev_queue *nd_q;
 	struct pci_dev *pdev = nn->pdev;
+	struct netdev_queue *nd_q;
 
 	while (tx_ring->rd_p != tx_ring->wr_p) {
-		int nr_frags, fidx, idx;
-		struct sk_buff *skb;
+		struct nfp_net_tx_buf *tx_buf;
+		int idx;
 
 		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
-		skb = tx_ring->txbufs[idx].skb;
-		nr_frags = skb_shinfo(skb)->nr_frags;
-		fidx = tx_ring->txbufs[idx].fidx;
+		tx_buf = &tx_ring->txbufs[idx];
 
-		if (fidx == -1) {
-			/* unmap head */
-			dma_unmap_single(&pdev->dev,
-					 tx_ring->txbufs[idx].dma_addr,
-					 skb_headlen(skb), DMA_TO_DEVICE);
+		if (tx_ring == r_vec->xdp_ring) {
+			nfp_net_dma_unmap_rx(nn, tx_buf->dma_addr,
+					     nn->fl_bufsz, DMA_BIDIRECTIONAL);
+			__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 		} else {
-			/* unmap fragment */
-			frag = &skb_shinfo(skb)->frags[fidx];
-			dma_unmap_page(&pdev->dev,
-				       tx_ring->txbufs[idx].dma_addr,
-				       skb_frag_size(frag), DMA_TO_DEVICE);
-		}
+			struct sk_buff *skb = tx_ring->txbufs[idx].skb;
+			int nr_frags = skb_shinfo(skb)->nr_frags;
+
+			if (tx_buf->fidx == -1) {
+				/* unmap head */
+				dma_unmap_single(&pdev->dev, tx_buf->dma_addr,
+						 skb_headlen(skb),
+						 DMA_TO_DEVICE);
+			} else {
+				/* unmap fragment */
+				frag = &skb_shinfo(skb)->frags[tx_buf->fidx];
+				dma_unmap_page(&pdev->dev, tx_buf->dma_addr,
+					       skb_frag_size(frag),
+					       DMA_TO_DEVICE);
+			}
 
-		/* check for last gather fragment */
-		if (fidx == nr_frags - 1)
-			dev_kfree_skb_any(skb);
+			/* check for last gather fragment */
+			if (tx_buf->fidx == nr_frags - 1)
+				dev_kfree_skb_any(skb);
+		}
 
-		tx_ring->txbufs[idx].dma_addr = 0;
-		tx_ring->txbufs[idx].skb = NULL;
-		tx_ring->txbufs[idx].fidx = -2;
+		tx_buf->dma_addr = 0;
+		tx_buf->skb = NULL;
+		tx_buf->fidx = -2;
 
 		tx_ring->qcp_rd_p++;
 		tx_ring->rd_p++;
@@ -1008,6 +1071,9 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 	tx_ring->qcp_rd_p = 0;
 	tx_ring->wr_ptr_add = 0;
 
+	if (tx_ring == r_vec->xdp_ring)
+		return;
+
 	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
 	netdev_tx_reset_queue(nd_q);
 }
@@ -1017,7 +1083,7 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int i;
 
-	for (i = 0; i < nn->num_tx_rings; i++) {
+	for (i = 0; i < nn->netdev->real_num_tx_queues; i++) {
 		if (!netif_tx_queue_stopped(netdev_get_tx_queue(netdev, i)))
 			continue;
 		nn_warn(nn, "TX timeout on ring: %d\n", i);
@@ -1045,11 +1111,21 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 	return fl_bufsz;
 }
 
+static void
+nfp_net_free_frag(void *frag, bool xdp)
+{
+	if (!xdp)
+		skb_free_frag(frag);
+	else
+		__free_page(virt_to_page(frag));
+}
+
 /**
  * nfp_net_rx_alloc_one() - Allocate and map page frag for RX
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
  * @fl_bufsz:	size of freelist buffers
+ * @xdp:	Whether XDP is enabled
  *
  * This function will allcate a new page frag, map it for DMA.
  *
@@ -1057,20 +1133,26 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
  */
 static void *
 nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
-		     unsigned int fl_bufsz)
+		     unsigned int fl_bufsz, bool xdp)
 {
 	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
+	int direction;
 	void *frag;
 
-	frag = netdev_alloc_frag(fl_bufsz);
+	if (!xdp)
+		frag = netdev_alloc_frag(fl_bufsz);
+	else
+		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
 	if (!frag) {
 		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
 		return NULL;
 	}
 
-	*dma_addr = nfp_net_dma_map_rx(nn, frag, fl_bufsz, DMA_FROM_DEVICE);
+	direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+
+	*dma_addr = nfp_net_dma_map_rx(nn, frag, fl_bufsz, direction);
 	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
-		skb_free_frag(frag);
+		nfp_net_free_frag(frag, xdp);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
@@ -1078,19 +1160,23 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 	return frag;
 }
 
-static void *nfp_net_napi_alloc_one(struct nfp_net *nn, dma_addr_t *dma_addr)
+static void *
+nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
 {
 	void *frag;
 
-	frag = napi_alloc_frag(nn->fl_bufsz);
+	if (!nn->xdp_prog)
+		frag = napi_alloc_frag(nn->fl_bufsz);
+	else
+		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
 	if (!frag) {
 		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
 		return NULL;
 	}
 
-	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, DMA_FROM_DEVICE);
+	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, direction);
 	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
-		skb_free_frag(frag);
+		nfp_net_free_frag(frag, nn->xdp_prog);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
@@ -1161,14 +1247,17 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
  * @nn:		NFP Net device
  * @rx_ring:	RX ring to remove buffers from
+ * @xdp:	Whether XDP is enabled
  *
  * Assumes that the device is stopped and buffers are in [0, ring->cnt - 1)
  * entries.  After device is disabled nfp_net_rx_ring_reset() must be called
  * to restore required ring geometry.
  */
 static void
-nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
+nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
+			  bool xdp)
 {
+	int direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
@@ -1180,8 +1269,8 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 			continue;
 
 		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[i].dma_addr,
-				     rx_ring->bufsz, DMA_FROM_DEVICE);
-		skb_free_frag(rx_ring->rxbufs[i].frag);
+				     rx_ring->bufsz, direction);
+		nfp_net_free_frag(rx_ring->rxbufs[i].frag, xdp);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].frag = NULL;
 	}
@@ -1191,9 +1280,11 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_bufs_alloc() - Fill RX ring with buffers (don't give to FW)
  * @nn:		NFP Net device
  * @rx_ring:	RX ring to remove buffers from
+ * @xdp:	Whether XDP is enabled
  */
 static int
-nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
+nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
+			   bool xdp)
 {
 	struct nfp_net_rx_buf *rxbufs;
 	unsigned int i;
@@ -1203,9 +1294,9 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].frag =
 			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
-					     rx_ring->bufsz);
+					     rx_ring->bufsz, xdp);
 		if (!rxbufs[i].frag) {
-			nfp_net_rx_ring_bufs_free(nn, rx_ring);
+			nfp_net_rx_ring_bufs_free(nn, rx_ring, xdp);
 			return -ENOMEM;
 		}
 	}
@@ -1368,6 +1459,68 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 		dev_kfree_skb_any(skb);
 }
 
+static void
+nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
+		   struct nfp_net_tx_ring *tx_ring,
+		   struct nfp_net_rx_buf *rxbuf, unsigned int pkt_off,
+		   unsigned int pkt_len)
+{
+	struct nfp_net_tx_buf *txbuf;
+	struct nfp_net_tx_desc *txd;
+	dma_addr_t new_dma_addr;
+	void *new_frag;
+	int wr_idx;
+
+	if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
+		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
+		return;
+	}
+
+	new_frag = nfp_net_napi_alloc_one(nn, DMA_BIDIRECTIONAL, &new_dma_addr);
+	if (unlikely(!new_frag)) {
+		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
+		return;
+	}
+	nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
+
+	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
+
+	/* Stash the soft descriptor of the head then initialize it */
+	txbuf = &tx_ring->txbufs[wr_idx];
+	txbuf->frag = rxbuf->frag;
+	txbuf->dma_addr = rxbuf->dma_addr;
+	txbuf->fidx = -1;
+	txbuf->pkt_cnt = 1;
+	txbuf->real_len = pkt_len;
+
+	dma_sync_single_for_device(&nn->pdev->dev, rxbuf->dma_addr + pkt_off,
+				   pkt_len, DMA_TO_DEVICE);
+
+	/* Build TX descriptor */
+	txd = &tx_ring->txds[wr_idx];
+	txd->offset_eop = PCIE_DESC_TX_EOP;
+	txd->dma_len = cpu_to_le16(pkt_len);
+	nfp_desc_set_dma_addr(txd, rxbuf->dma_addr + pkt_off);
+	txd->data_len = cpu_to_le16(pkt_len);
+
+	txd->flags = 0;
+	txd->mss = 0;
+	txd->l4_offset = 0;
+
+	tx_ring->wr_p++;
+	tx_ring->wr_ptr_add++;
+}
+
+static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
+{
+	struct xdp_buff xdp;
+
+	xdp.data = data;
+	xdp.data_end = data + len;
+
+	return BPF_PROG_RUN(prog, (void *)&xdp);
+}
+
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1383,10 +1536,20 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 {
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
+	struct nfp_net_tx_ring *tx_ring;
+	struct bpf_prog *xdp_prog;
+	unsigned int true_bufsz;
 	struct sk_buff *skb;
 	int pkts_polled = 0;
+	int rx_dma_map_dir;
 	int idx;
 
+	rcu_read_lock();
+	xdp_prog = READ_ONCE(nn->xdp_prog);
+	rx_dma_map_dir = xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	true_bufsz = xdp_prog ? PAGE_SIZE : nn->fl_bufsz;
+	tx_ring = r_vec->xdp_ring;
+
 	while (pkts_polled < budget) {
 		unsigned int meta_len, data_len, data_off, pkt_len, pkt_off;
 		struct nfp_net_rx_buf *rxbuf;
@@ -1437,19 +1600,45 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
-		skb = build_skb(rxbuf->frag, nn->fl_bufsz);
+		if (xdp_prog) {
+			int act;
+
+			dma_sync_single_for_cpu(&nn->pdev->dev,
+						rxbuf->dma_addr + pkt_off,
+						pkt_len, DMA_FROM_DEVICE);
+			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
+					      pkt_len);
+			switch (act) {
+			case XDP_PASS:
+				break;
+			case XDP_TX:
+				nfp_net_tx_xdp_buf(nn, rx_ring, tx_ring, rxbuf,
+						   pkt_off, pkt_len);
+				continue;
+			default:
+				bpf_warn_invalid_xdp_action(act);
+			case XDP_ABORTED:
+			case XDP_DROP:
+				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
+						    rxbuf->dma_addr);
+				continue;
+			}
+		}
+
+		skb = build_skb(rxbuf->frag, true_bufsz);
 		if (unlikely(!skb)) {
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
-		new_frag = nfp_net_napi_alloc_one(nn, &new_dma_addr);
+		new_frag = nfp_net_napi_alloc_one(nn, rx_dma_map_dir,
+						  &new_dma_addr);
 		if (unlikely(!new_frag)) {
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
 			continue;
 		}
 
-		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[idx].dma_addr,
-				     nn->fl_bufsz, DMA_FROM_DEVICE);
+		nfp_net_dma_unmap_rx(nn, rxbuf->dma_addr, nn->fl_bufsz,
+				     rx_dma_map_dir);
 
 		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
 
@@ -1481,6 +1670,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		napi_gro_receive(&rx_ring->r_vec->napi, skb);
 	}
 
+	if (xdp_prog && tx_ring->wr_ptr_add)
+		nfp_net_tx_xmit_more_flush(tx_ring);
+	rcu_read_unlock();
+
 	return pkts_polled;
 }
 
@@ -1499,8 +1692,11 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 
 	if (r_vec->tx_ring)
 		nfp_net_tx_complete(r_vec->tx_ring);
-	if (r_vec->rx_ring)
+	if (r_vec->rx_ring) {
 		pkts_polled = nfp_net_rx(r_vec->rx_ring, budget);
+		if (r_vec->xdp_ring)
+			nfp_net_xdp_complete(r_vec->xdp_ring);
+	}
 
 	if (pkts_polled < budget) {
 		napi_complete_done(napi, pkts_polled);
@@ -1540,10 +1736,12 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
  * nfp_net_tx_ring_alloc() - Allocate resource for a TX ring
  * @tx_ring:   TX Ring structure to allocate
  * @cnt:       Ring buffer count
+ * @is_xdp:    True if ring will be used for XDP
  *
  * Return: 0 on success, negative errno otherwise.
  */
-static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
+static int
+nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
@@ -1563,11 +1761,14 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 	if (!tx_ring->txbufs)
 		goto err_alloc;
 
-	netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask, tx_ring->idx);
+	if (!is_xdp)
+		netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask,
+				    tx_ring->idx);
 
-	nn_dbg(nn, "TxQ%02d: QCidx=%02d cnt=%d dma=%#llx host=%p\n",
+	nn_dbg(nn, "TxQ%02d: QCidx=%02d cnt=%d dma=%#llx host=%p %s\n",
 	       tx_ring->idx, tx_ring->qcidx,
-	       tx_ring->cnt, (unsigned long long)tx_ring->dma, tx_ring->txds);
+	       tx_ring->cnt, (unsigned long long)tx_ring->dma, tx_ring->txds,
+	       is_xdp ? "XDP" : "");
 
 	return 0;
 
@@ -1577,7 +1778,8 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 }
 
 static struct nfp_net_tx_ring *
-nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
+			    unsigned int num_stack_tx_rings)
 {
 	struct nfp_net_tx_ring *rings;
 	unsigned int r;
@@ -1587,9 +1789,14 @@ static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt)
 		return NULL;
 
 	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_tx_ring_init(&rings[r], &nn->r_vecs[r], r);
+		int bias = 0;
+
+		if (r >= num_stack_tx_rings)
+			bias = num_stack_tx_rings;
 
-		if (nfp_net_tx_ring_alloc(&rings[r], s->dcnt))
+		nfp_net_tx_ring_init(&rings[r], &nn->r_vecs[r - bias], r);
+
+		if (nfp_net_tx_ring_alloc(&rings[r], s->dcnt, bias))
 			goto err_free_prev;
 	}
 
@@ -1694,7 +1901,8 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
+			    bool xdp)
 {
 	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(nn, s->mtu);
 	struct nfp_net_rx_ring *rings;
@@ -1710,7 +1918,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
+		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r], xdp))
 			goto err_free_ring;
 	}
 
@@ -1718,7 +1926,7 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
+		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
 err_free_ring:
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1744,13 +1952,14 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 }
 
 static void
-nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s,
+			 bool xdp)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
 	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
+		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
 
@@ -1762,7 +1971,11 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 			    int idx)
 {
 	r_vec->rx_ring = idx < nn->num_rx_rings ? &nn->rx_rings[idx] : NULL;
-	r_vec->tx_ring = idx < nn->num_tx_rings ? &nn->tx_rings[idx] : NULL;
+	r_vec->tx_ring =
+		idx < nn->num_stack_tx_rings ? &nn->tx_rings[idx] : NULL;
+
+	r_vec->xdp_ring = idx < nn->num_tx_rings - nn->num_stack_tx_rings ?
+		&nn->tx_rings[nn->num_stack_tx_rings + idx] : NULL;
 }
 
 static int
@@ -2083,13 +2296,14 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx);
+	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx, nn->xdp_prog);
 	if (!nn->rx_rings) {
 		err = -ENOMEM;
 		goto err_cleanup_vec;
 	}
 
-	nn->tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx);
+	nn->tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx,
+						   nn->num_stack_tx_rings);
 	if (!nn->tx_rings) {
 		err = -ENOMEM;
 		goto err_free_rx_rings;
@@ -2098,7 +2312,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	for (r = 0; r < nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
 
-	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
+	err = netif_set_real_num_tx_queues(netdev, nn->num_stack_tx_rings);
 	if (err)
 		goto err_free_rings;
 
@@ -2130,7 +2344,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 err_free_rings:
 	nfp_net_tx_ring_set_free(nn, &tx);
 err_free_rx_rings:
-	nfp_net_rx_ring_set_free(nn, &rx);
+	nfp_net_rx_ring_set_free(nn, &rx, nn->xdp_prog);
 err_cleanup_vec:
 	r = nn->num_r_vecs;
 err_cleanup_vec_p:
@@ -2171,7 +2385,7 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 	unsigned int r;
 
 	for (r = 0; r < nn->num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r]);
+		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r], nn->xdp_prog);
 		nfp_net_rx_ring_free(&nn->rx_rings[r]);
 	}
 	for (r = 0; r < nn->num_tx_rings; r++)
@@ -2251,6 +2465,8 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 
 static int
 nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
+			 unsigned int *stack_tx_rings,
+			 struct bpf_prog **xdp_prog,
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
 {
@@ -2263,6 +2479,8 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
 	swap(*num_vecs, nn->num_r_vecs);
+	swap(*stack_tx_rings, nn->num_stack_tx_rings);
+	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
@@ -2277,9 +2495,9 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 			return err;
 	}
 
-	if (nn->netdev->real_num_tx_queues != nn->num_tx_rings) {
+	if (nn->netdev->real_num_tx_queues != nn->num_stack_tx_rings) {
 		err = netif_set_real_num_tx_queues(nn->netdev,
-						   nn->num_tx_rings);
+						   nn->num_stack_tx_rings);
 		if (err)
 			return err;
 	}
@@ -2287,11 +2505,30 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 	return __nfp_net_set_config_and_enable(nn);
 }
 
+static int
+nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
+		     struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
+{
+	/* XDP-enabled tests */
+	if (!xdp_prog)
+		return 0;
+	if (rx && nfp_net_calc_fl_bufsz(nn, rx->mtu) > PAGE_SIZE) {
+		nn_warn(nn, "MTU too large w/ XDP enabled\n");
+		return -EINVAL;
+	}
+	if (tx && tx->n_rings > nn->max_tx_rings) {
+		nn_warn(nn, "Insufficient number of TX rings w/ XDP enabled\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static void
-nfp_net_ring_reconfig_down(struct nfp_net *nn,
+nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 			   struct nfp_net_ring_set *rx,
 			   struct nfp_net_ring_set *tx,
-			   unsigned int num_vecs)
+			   unsigned int stack_tx_rings, unsigned int num_vecs)
 {
 	nn->netdev->mtu = rx ? rx->mtu : nn->netdev->mtu;
 	nn->fl_bufsz = nfp_net_calc_fl_bufsz(nn, nn->netdev->mtu);
@@ -2299,24 +2536,34 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 	nn->txd_cnt = tx ? tx->dcnt : nn->txd_cnt;
 	nn->num_rx_rings = rx ? rx->n_rings : nn->num_rx_rings;
 	nn->num_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
+	nn->num_stack_tx_rings = stack_tx_rings;
 	nn->num_r_vecs = num_vecs;
+	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
 
 	if (!netif_is_rxfh_configured(nn->netdev))
 		nfp_net_rss_init_itbl(nn);
 }
 
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_ring_set *rx,
-		      struct nfp_net_ring_set *tx)
+nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
-	unsigned int num_vecs, r;
+	unsigned int stack_tx_rings, num_vecs, r;
 	int err;
 
-	num_vecs = max(rx ? rx->n_rings : nn->num_rx_rings,
-		       tx ? tx->n_rings : nn->num_tx_rings);
+	stack_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
+	if (*xdp_prog)
+		stack_tx_rings -= rx ? rx->n_rings : nn->num_rx_rings;
+
+	num_vecs = max(rx ? rx->n_rings : nn->num_rx_rings, stack_tx_rings);
+
+	err = nfp_net_check_config(nn, *xdp_prog, rx, tx);
+	if (err)
+		return err;
 
 	if (!netif_running(nn->netdev)) {
-		nfp_net_ring_reconfig_down(nn, rx, tx, num_vecs);
+		nfp_net_ring_reconfig_down(nn, xdp_prog, rx, tx,
+					   stack_tx_rings, num_vecs);
 		return 0;
 	}
 
@@ -2329,13 +2576,13 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 		}
 	}
 	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, rx)) {
+		if (!nfp_net_rx_ring_set_prepare(nn, rx, *xdp_prog)) {
 			err = -ENOMEM;
 			goto err_cleanup_vecs;
 		}
 	}
 	if (tx) {
-		if (!nfp_net_tx_ring_set_prepare(nn, tx)) {
+		if (!nfp_net_tx_ring_set_prepare(nn, tx, stack_tx_rings)) {
 			err = -ENOMEM;
 			goto err_free_rx;
 		}
@@ -2345,14 +2592,16 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, &num_vecs, rx, tx);
+	err = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
+				       xdp_prog, rx, tx);
 	if (err) {
 		int err2;
 
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, &num_vecs, rx, tx);
+		err2 = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
+						xdp_prog, rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
@@ -2361,7 +2610,7 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx);
+		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
 	if (tx)
 		nfp_net_tx_ring_set_free(nn, tx);
 
@@ -2371,7 +2620,7 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 
 err_free_rx:
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx);
+		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
 err_cleanup_vecs:
 	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
@@ -2387,7 +2636,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		.dcnt = nn->rxd_cnt,
 	};
 
-	return nfp_net_ring_reconfig(nn, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, &nn->xdp_prog, &rx, NULL);
 }
 
 static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
@@ -2653,6 +2902,56 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 		nfp_net_set_vxlan_port(nn, idx, 0);
 }
 
+static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
+{
+	struct nfp_net_ring_set rx = {
+		.n_rings = nn->num_rx_rings,
+		.mtu = nn->netdev->mtu,
+		.dcnt = nn->rxd_cnt,
+	};
+	struct nfp_net_ring_set tx = {
+		.n_rings = nn->num_tx_rings,
+		.dcnt = nn->txd_cnt,
+	};
+	int err;
+
+	if (!prog && !nn->xdp_prog)
+		return 0;
+	if (prog && nn->xdp_prog) {
+		prog = xchg(&nn->xdp_prog, prog);
+		bpf_prog_put(prog);
+		return 0;
+	}
+
+	tx.n_rings += prog ? nn->num_rx_rings : -nn->num_rx_rings;
+
+	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
+	err = nfp_net_ring_reconfig(nn, &prog, &rx, &tx);
+	if (err)
+		return err;
+
+	/* @prog got swapped and is now the old one */
+	if (prog)
+		bpf_prog_put(prog);
+
+	return 0;
+}
+
+static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return nfp_net_xdp_setup(nn, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = !!nn->xdp_prog;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_open		= nfp_net_netdev_open,
 	.ndo_stop		= nfp_net_netdev_close,
@@ -2667,6 +2966,7 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 	.ndo_features_check	= nfp_net_features_check,
 	.ndo_udp_tunnel_add	= nfp_net_add_vxlan_port,
 	.ndo_udp_tunnel_del	= nfp_net_del_vxlan_port,
+	.ndo_xdp		= nfp_net_xdp,
 };
 
 /**
@@ -2929,5 +3229,9 @@ int nfp_net_netdev_init(struct net_device *netdev)
  */
 void nfp_net_netdev_clean(struct net_device *netdev)
 {
-	unregister_netdev(netdev);
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (nn->xdp_prog)
+		bpf_prog_put(nn->xdp_prog);
+	unregister_netdev(nn->netdev);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index e90df8145323..c66f3f954aa8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -114,6 +114,16 @@ static int nfp_net_debugfs_rx_q_open(struct inode *inode, struct file *f)
 	.llseek = seq_lseek
 };
 
+static int nfp_net_debugfs_tx_q_open(struct inode *inode, struct file *f);
+
+static const struct file_operations nfp_tx_q_fops = {
+	.owner = THIS_MODULE,
+	.open = nfp_net_debugfs_tx_q_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
 static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 {
 	struct nfp_net_r_vector *r_vec = file->private;
@@ -126,10 +136,13 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 
 	rtnl_lock();
 
-	if (!r_vec->nfp_net || !r_vec->tx_ring)
+	if (debugfs_real_fops(file->file) == &nfp_tx_q_fops)
+		tx_ring = r_vec->tx_ring;
+	else
+		tx_ring = r_vec->xdp_ring;
+	if (!r_vec->nfp_net || !tx_ring)
 		goto out;
 	nn = r_vec->nfp_net;
-	tx_ring = r_vec->tx_ring;
 	if (!netif_running(nn->netdev))
 		goto out;
 
@@ -148,9 +161,14 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 			   txd->vals[2], txd->vals[3]);
 
 		skb = READ_ONCE(tx_ring->txbufs[i].skb);
-		if (skb)
-			seq_printf(file, " skb->head=%p skb->data=%p",
-				   skb->head, skb->data);
+		if (skb) {
+			if (tx_ring == r_vec->tx_ring)
+				seq_printf(file, " skb->head=%p skb->data=%p",
+					   skb->head, skb->data);
+			else
+				seq_printf(file, " frag=%p", skb);
+		}
+
 		if (tx_ring->txbufs[i].dma_addr)
 			seq_printf(file, " dma_addr=%pad",
 				   &tx_ring->txbufs[i].dma_addr);
@@ -176,7 +194,7 @@ static int nfp_net_debugfs_tx_q_open(struct inode *inode, struct file *f)
 	return single_open(f, nfp_net_debugfs_tx_q_read, inode->i_private);
 }
 
-static const struct file_operations nfp_tx_q_fops = {
+static const struct file_operations nfp_xdp_q_fops = {
 	.owner = THIS_MODULE,
 	.open = nfp_net_debugfs_tx_q_open,
 	.release = single_release,
@@ -186,7 +204,7 @@ static int nfp_net_debugfs_tx_q_open(struct inode *inode, struct file *f)
 
 void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 {
-	struct dentry *queues, *tx, *rx;
+	struct dentry *queues, *tx, *rx, *xdp;
 	char int_name[16];
 	int i;
 
@@ -204,13 +222,16 @@ void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 
 	rx = debugfs_create_dir("rx", queues);
 	tx = debugfs_create_dir("tx", queues);
-	if (IS_ERR_OR_NULL(rx) || IS_ERR_OR_NULL(tx))
+	xdp = debugfs_create_dir("xdp", queues);
+	if (IS_ERR_OR_NULL(rx) || IS_ERR_OR_NULL(tx) || IS_ERR_OR_NULL(xdp))
 		return;
 
 	for (i = 0; i < min(nn->max_rx_rings, nn->max_r_vecs); i++) {
 		sprintf(int_name, "%d", i);
 		debugfs_create_file(int_name, S_IRUSR, rx,
 				    &nn->r_vecs[i], &nfp_rx_q_fops);
+		debugfs_create_file(int_name, S_IRUSR, xdp,
+				    &nn->r_vecs[i], &nfp_xdp_q_fops);
 	}
 
 	for (i = 0; i < min(nn->max_tx_rings, nn->max_r_vecs); i++) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index b87f1b73f200..1b26e9646574 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -176,7 +176,8 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	if (nn->txd_cnt != txd_cnt)
 		reconfig_tx = &tx;
 
-	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
+	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
+				     reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_ringparam(struct net_device *netdev,
@@ -639,14 +640,19 @@ static void nfp_net_get_channels(struct net_device *netdev,
 				 struct ethtool_channels *channel)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
+	unsigned int num_tx_rings;
+
+	num_tx_rings = nn->num_tx_rings;
+	if (nn->xdp_prog)
+		num_tx_rings -= nn->num_rx_rings;
 
 	channel->max_rx = min(nn->max_rx_rings, nn->max_r_vecs);
 	channel->max_tx = min(nn->max_tx_rings, nn->max_r_vecs);
 	channel->max_combined = min(channel->max_rx, channel->max_tx);
 	channel->max_other = NFP_NET_NON_Q_VECTORS;
-	channel->combined_count = min(nn->num_rx_rings, nn->num_tx_rings);
+	channel->combined_count = min(nn->num_rx_rings, num_tx_rings);
 	channel->rx_count = nn->num_rx_rings - channel->combined_count;
-	channel->tx_count = nn->num_tx_rings - channel->combined_count;
+	channel->tx_count = num_tx_rings - channel->combined_count;
 	channel->other_count = NFP_NET_NON_Q_VECTORS;
 }
 
@@ -666,10 +672,16 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 
 	if (nn->num_rx_rings != total_rx)
 		reconfig_rx = &rx;
-	if (nn->num_tx_rings != total_tx)
+	if (nn->num_stack_tx_rings != total_tx ||
+	    (nn->xdp_prog && reconfig_rx))
 		reconfig_tx = &tx;
 
-	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
+	/* nfp_net_check_config() will catch tx.n_rings > nn->max_tx_rings */
+	if (nn->xdp_prog)
+		tx.n_rings += total_rx;
+
+	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
+				     reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_channels(struct net_device *netdev,
-- 
1.9.1
