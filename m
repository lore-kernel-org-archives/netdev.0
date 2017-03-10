From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/13] nfp: use dp to carry fl_bufsz at reconfig time
Date: Fri, 10 Mar 2017 10:38:31 -0800
Message-ID: <20170310183839.39568-6-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33545 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755137AbdCJSj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:28 -0500
Received: by mail-pg0-f52.google.com with SMTP id 25so41794201pgy.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:27 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use fl_bufsz member of data path struct to carry desired size of
free list entries.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 --
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 56 +++++++++++-----------
 2 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 74f6d485351f..ab5865b955dd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -316,8 +316,6 @@ struct nfp_net_rx_buf {
  * @rxds:       Virtual address of FL/RX ring in host memory
  * @dma:        DMA address of the FL/RX ring
  * @size:       Size, in bytes, of the FL/RX ring (needed to free)
- * @bufsz:	Buffer allocation size for convenience of management routines
- *		(NOTE: this is in second cache line, do not use on fast path!)
  */
 struct nfp_net_rx_ring {
 	struct nfp_net_r_vector *r_vec;
@@ -339,7 +337,6 @@ struct nfp_net_rx_ring {
 
 	dma_addr_t dma;
 	unsigned int size;
-	unsigned int bufsz;
 } ____cacheline_aligned;
 
 /**
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 52f0e9dfd15a..92d4c2991a85 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -86,19 +86,19 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 }
 
 static dma_addr_t
-nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag, unsigned int bufsz,
-		   int direction)
+nfp_net_dma_map_rx(struct nfp_net_dp *dp, void *frag, int direction)
 {
 	return dma_map_single(dp->dev, frag + NFP_NET_RX_BUF_HEADROOM,
-			      bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
+			      dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA,
+			      direction);
 }
 
 static void
 nfp_net_dma_unmap_rx(struct nfp_net_dp *dp, dma_addr_t dma_addr,
-		     unsigned int bufsz, int direction)
+		     int direction)
 {
 	dma_unmap_single(dp->dev, dma_addr,
-			 bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
+			 dp->fl_bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
 }
 
 /* Firmware reconfig
@@ -992,7 +992,7 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 			continue;
 
 		nfp_net_dma_unmap_rx(dp, tx_ring->txbufs[idx].dma_addr,
-				     dp->fl_bufsz, DMA_BIDIRECTIONAL);
+				     DMA_BIDIRECTIONAL);
 		__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 
 		done_pkts++;
@@ -1038,7 +1038,7 @@ nfp_net_tx_ring_reset(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring)
 
 		if (tx_ring == r_vec->xdp_ring) {
 			nfp_net_dma_unmap_rx(dp, tx_buf->dma_addr,
-					     dp->fl_bufsz, DMA_BIDIRECTIONAL);
+					     DMA_BIDIRECTIONAL);
 			__free_page(virt_to_page(tx_ring->txbufs[idx].frag));
 		} else {
 			struct sk_buff *skb = tx_ring->txbufs[idx].skb;
@@ -1130,7 +1130,6 @@ nfp_net_free_frag(void *frag, bool xdp)
  * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
- * @fl_bufsz:	size of freelist buffers
  * @xdp:	Whether XDP is enabled
  *
  * This function will allcate a new page frag, map it for DMA.
@@ -1140,13 +1139,13 @@ nfp_net_free_frag(void *frag, bool xdp)
 static void *
 nfp_net_rx_alloc_one(struct nfp_net_dp *dp,
 		     struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
-		     unsigned int fl_bufsz, bool xdp)
+		     bool xdp)
 {
 	int direction;
 	void *frag;
 
 	if (!xdp)
-		frag = netdev_alloc_frag(fl_bufsz);
+		frag = netdev_alloc_frag(dp->fl_bufsz);
 	else
 		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
 	if (!frag) {
@@ -1156,7 +1155,7 @@ nfp_net_rx_alloc_one(struct nfp_net_dp *dp,
 
 	direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 
-	*dma_addr = nfp_net_dma_map_rx(dp, frag, fl_bufsz, direction);
+	*dma_addr = nfp_net_dma_map_rx(dp, frag, direction);
 	if (dma_mapping_error(dp->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, xdp);
 		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
@@ -1181,7 +1180,7 @@ nfp_net_napi_alloc_one(struct nfp_net_dp *dp, int direction,
 		return NULL;
 	}
 
-	*dma_addr = nfp_net_dma_map_rx(dp, frag, dp->fl_bufsz, direction);
+	*dma_addr = nfp_net_dma_map_rx(dp, frag, direction);
 	if (dma_mapping_error(dp->dev, *dma_addr)) {
 		nfp_net_free_frag(frag, dp->xdp_prog);
 		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
@@ -1276,7 +1275,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
 			continue;
 
 		nfp_net_dma_unmap_rx(dp, rx_ring->rxbufs[i].dma_addr,
-				     rx_ring->bufsz, direction);
+				     direction);
 		nfp_net_free_frag(rx_ring->rxbufs[i].frag, xdp);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].frag = NULL;
@@ -1301,7 +1300,7 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].frag =
 			nfp_net_rx_alloc_one(dp, rx_ring, &rxbufs[i].dma_addr,
-					     rx_ring->bufsz, xdp);
+					     xdp);
 		if (!rxbufs[i].frag) {
 			nfp_net_rx_ring_bufs_free(dp, rx_ring, xdp);
 			return -ENOMEM;
@@ -1652,8 +1651,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			continue;
 		}
 
-		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr, dp->fl_bufsz,
-				     rx_dma_map_dir);
+		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr, rx_dma_map_dir);
 
 		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
 
@@ -1865,23 +1863,19 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
 
 /**
  * nfp_net_rx_ring_alloc() - Allocate resource for a RX ring
+ * @dp:	      NFP Net data path struct
  * @rx_ring:  RX ring to allocate
- * @fl_bufsz: Size of buffers to allocate
  * @cnt:      Ring buffer count
  *
  * Return: 0 on success, negative errno otherwise.
  */
 static int
-nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
+nfp_net_rx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		      u32 cnt)
 {
-	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
-	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	int sz;
 
 	rx_ring->cnt = cnt;
-	rx_ring->bufsz = fl_bufsz;
-
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
 	rx_ring->rxds = dma_zalloc_coherent(dp->dev, rx_ring->size,
 					    &rx_ring->dma, GFP_KERNEL);
@@ -1904,7 +1898,6 @@ static struct nfp_net_rx_ring *
 nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 			    struct nfp_net_ring_set *s, bool xdp)
 {
-	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(dp, s->mtu);
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
@@ -1915,7 +1908,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 	for (r = 0; r < s->n_rings; r++) {
 		nfp_net_rx_ring_init(&rings[r], &nn->r_vecs[r], r);
 
-		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
+		if (nfp_net_rx_ring_alloc(dp, &rings[r], s->dcnt))
 			goto err_free_prev;
 
 		if (nfp_net_rx_ring_bufs_alloc(dp, &rings[r], xdp))
@@ -1935,17 +1928,20 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 }
 
 static void
-nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
+nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_dp *dp,
+			 struct nfp_net_ring_set *s)
 {
 	struct nfp_net_ring_set new = *s;
+	struct nfp_net_dp new_dp = *dp;
 
+	dp->fl_bufsz = nn->dp.fl_bufsz;
 	s->mtu = nn->dp.netdev->mtu;
 	s->dcnt = nn->dp.rxd_cnt;
 	s->rings = nn->dp.rx_rings;
 	s->n_rings = nn->dp.num_rx_rings;
 
 	nn->dp.netdev->mtu = new.mtu;
-	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, new.mtu);
+	nn->dp.fl_bufsz = new_dp.fl_bufsz;
 	nn->dp.rxd_cnt = new.dcnt;
 	nn->dp.rx_rings = new.rings;
 	nn->dp.num_rx_rings = new.n_rings;
@@ -2482,7 +2478,7 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
 	int err;
 
 	if (rx)
-		nfp_net_rx_ring_set_swap(nn, rx);
+		nfp_net_rx_ring_set_swap(nn, dp, rx);
 	if (tx)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
@@ -2538,7 +2534,7 @@ nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
 	/* XDP-enabled tests */
 	if (!xdp_prog)
 		return 0;
-	if (rx && nfp_net_calc_fl_bufsz(dp, rx->mtu) > PAGE_SIZE) {
+	if (dp->fl_bufsz > PAGE_SIZE) {
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
 		return -EINVAL;
 	}
@@ -2559,7 +2555,6 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
 	nfp_net_dp_swap(nn, dp);
 
 	nn->dp.netdev->mtu = rx ? rx->mtu : nn->dp.netdev->mtu;
-	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, nn->dp.netdev->mtu);
 	nn->dp.rxd_cnt = rx ? rx->dcnt : nn->dp.rxd_cnt;
 	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
 	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
@@ -2577,6 +2572,9 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 {
 	int r, err;
 
+	dp->fl_bufsz = nfp_net_calc_fl_bufsz(dp,
+					     rx ? rx->mtu : nn->dp.netdev->mtu);
+
 	dp->num_stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
 	if (*xdp_prog)
 		dp->num_stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
-- 
2.11.0
