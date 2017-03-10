From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/13] nfp: use dp to carry xdp_prog at reconfig time
Date: Fri, 10 Mar 2017 10:38:33 -0800
Message-ID: <20170310183839.39568-8-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36656 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755427AbdCJSja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:30 -0500
Received: by mail-pg0-f48.google.com with SMTP id g2so24403487pge.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:29 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use xdp_prog member of data path struct to carry the xdp_prog to
alloc/free free functions.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 -
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 82 +++++++++-------------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  6 +-
 3 files changed, 37 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 84774c281b61..19dacc3f1269 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -815,7 +815,6 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int
 nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
-		      struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
 
 #ifdef CONFIG_NFP_DEBUG
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 862e86cb5688..6ab824a48d1d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1130,21 +1130,19 @@ nfp_net_free_frag(void *frag, bool xdp)
  * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
- * @xdp:	Whether XDP is enabled
  *
  * This function will allcate a new page frag, map it for DMA.
  *
  * Return: allocated page frag or NULL on failure.
  */
 static void *
-nfp_net_rx_alloc_one(struct nfp_net_dp *dp,
-		     struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
-		     bool xdp)
+nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
+		     dma_addr_t *dma_addr)
 {
 	int direction;
 	void *frag;
 
-	if (!xdp)
+	if (!dp->xdp_prog)
 		frag = netdev_alloc_frag(dp->fl_bufsz);
 	else
 		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
@@ -1153,11 +1151,11 @@ nfp_net_rx_alloc_one(struct nfp_net_dp *dp,
 		return NULL;
 	}
 
-	direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	direction = dp->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 
 	*dma_addr = nfp_net_dma_map_rx(dp, frag, direction);
 	if (dma_mapping_error(dp->dev, *dma_addr)) {
-		nfp_net_free_frag(frag, xdp);
+		nfp_net_free_frag(frag, dp->xdp_prog);
 		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
@@ -1253,7 +1251,6 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
  * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring to remove buffers from
- * @xdp:	Whether XDP is enabled
  *
  * Assumes that the device is stopped and buffers are in [0, ring->cnt - 1)
  * entries.  After device is disabled nfp_net_rx_ring_reset() must be called
@@ -1261,9 +1258,9 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  */
 static void
 nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
-			  struct nfp_net_rx_ring *rx_ring, bool xdp)
+			  struct nfp_net_rx_ring *rx_ring)
 {
-	int direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	int direction = dp->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
@@ -1276,7 +1273,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
 
 		nfp_net_dma_unmap_rx(dp, rx_ring->rxbufs[i].dma_addr,
 				     direction);
-		nfp_net_free_frag(rx_ring->rxbufs[i].frag, xdp);
+		nfp_net_free_frag(rx_ring->rxbufs[i].frag, dp->xdp_prog);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].frag = NULL;
 	}
@@ -1286,11 +1283,10 @@ nfp_net_rx_ring_bufs_free(struct nfp_net_dp *dp,
  * nfp_net_rx_ring_bufs_alloc() - Fill RX ring with buffers (don't give to FW)
  * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring to remove buffers from
- * @xdp:	Whether XDP is enabled
  */
 static int
 nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
-			   struct nfp_net_rx_ring *rx_ring, bool xdp)
+			   struct nfp_net_rx_ring *rx_ring)
 {
 	struct nfp_net_rx_buf *rxbufs;
 	unsigned int i;
@@ -1299,10 +1295,9 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].frag =
-			nfp_net_rx_alloc_one(dp, rx_ring, &rxbufs[i].dma_addr,
-					     xdp);
+			nfp_net_rx_alloc_one(dp, rx_ring, &rxbufs[i].dma_addr);
 		if (!rxbufs[i].frag) {
-			nfp_net_rx_ring_bufs_free(dp, rx_ring, xdp);
+			nfp_net_rx_ring_bufs_free(dp, rx_ring);
 			return -ENOMEM;
 		}
 	}
@@ -1896,7 +1891,7 @@ nfp_net_rx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 
 static struct nfp_net_rx_ring *
 nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
-			    struct nfp_net_ring_set *s, bool xdp)
+			    struct nfp_net_ring_set *s)
 {
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
@@ -1911,7 +1906,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 		if (nfp_net_rx_ring_alloc(dp, &rings[r], s->dcnt))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(dp, &rings[r], xdp))
+		if (nfp_net_rx_ring_bufs_alloc(dp, &rings[r]))
 			goto err_free_ring;
 	}
 
@@ -1919,7 +1914,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(dp, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(dp, &rings[r]);
 err_free_ring:
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1949,14 +1944,13 @@ nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_dp *dp,
 }
 
 static void
-nfp_net_rx_ring_set_free(struct nfp_net_dp *dp, struct nfp_net_ring_set *s,
-			 bool xdp)
+nfp_net_rx_ring_set_free(struct nfp_net_dp *dp, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
 	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_bufs_free(dp, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(dp, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
 
@@ -2292,8 +2286,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &nn->dp, &rx,
-						      nn->dp.xdp_prog);
+	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &nn->dp, &rx);
 	if (!nn->dp.rx_rings) {
 		err = -ENOMEM;
 		goto err_cleanup_vec;
@@ -2340,7 +2333,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 err_free_rings:
 	nfp_net_tx_ring_set_free(&tx);
 err_free_rx_rings:
-	nfp_net_rx_ring_set_free(&nn->dp, &rx, nn->dp.xdp_prog);
+	nfp_net_rx_ring_set_free(&nn->dp, &rx);
 err_cleanup_vec:
 	r = nn->dp.num_r_vecs;
 err_cleanup_vec_p:
@@ -2381,8 +2374,7 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 	unsigned int r;
 
 	for (r = 0; r < nn->dp.num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r],
-					  nn->dp.xdp_prog);
+		nfp_net_rx_ring_bufs_free(&nn->dp, &nn->dp.rx_rings[r]);
 		nfp_net_rx_ring_free(&nn->dp.rx_rings[r]);
 	}
 	for (r = 0; r < nn->dp.num_tx_rings; r++)
@@ -2472,7 +2464,6 @@ static void nfp_net_dp_swap(struct nfp_net *nn, struct nfp_net_dp *dp)
 
 static int
 nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
-			 struct bpf_prog **xdp_prog,
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
 {
@@ -2486,7 +2477,7 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
 
 	swap(dp->num_r_vecs, nn->dp.num_r_vecs);
 	swap(dp->num_stack_tx_rings, nn->dp.num_stack_tx_rings);
-	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
+	dp->xdp_prog = xchg(&nn->dp.xdp_prog, dp->xdp_prog);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
@@ -2530,11 +2521,10 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
 
 static int
 nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
-		     struct bpf_prog *xdp_prog,
 		     struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	/* XDP-enabled tests */
-	if (!xdp_prog)
+	if (!dp->xdp_prog)
 		return 0;
 	if (dp->fl_bufsz > PAGE_SIZE) {
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
@@ -2550,7 +2540,6 @@ nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
 
 static void
 nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
-			   struct bpf_prog **xdp_prog,
 			   struct nfp_net_ring_set *rx,
 			   struct nfp_net_ring_set *tx)
 {
@@ -2560,7 +2549,6 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
 	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
 	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
 	nn->dp.num_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
-	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
 
 	if (!netif_is_rxfh_configured(nn->dp.netdev))
 		nfp_net_rss_init_itbl(nn);
@@ -2568,7 +2556,6 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
 
 int
 nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
-		      struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	int r, err;
@@ -2576,18 +2563,18 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	dp->fl_bufsz = nfp_net_calc_fl_bufsz(dp);
 
 	dp->num_stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
-	if (*xdp_prog)
+	if (dp->xdp_prog)
 		dp->num_stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
 
 	dp->num_r_vecs = max(rx ? rx->n_rings : dp->num_rx_rings,
 			     dp->num_stack_tx_rings);
 
-	err = nfp_net_check_config(nn, dp, *xdp_prog, rx, tx);
+	err = nfp_net_check_config(nn, dp, rx, tx);
 	if (err)
 		goto exit_free_dp;
 
 	if (!netif_running(dp->netdev)) {
-		nfp_net_ring_reconfig_down(nn, dp, xdp_prog, rx, tx);
+		nfp_net_ring_reconfig_down(nn, dp, rx, tx);
 
 		err = 0;
 		goto exit_free_dp;
@@ -2602,7 +2589,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 		}
 	}
 	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, dp, rx, *xdp_prog)) {
+		if (!nfp_net_rx_ring_set_prepare(nn, dp, rx)) {
 			err = -ENOMEM;
 			goto err_cleanup_vecs;
 		}
@@ -2618,14 +2605,14 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, dp, xdp_prog, rx, tx);
+	err = nfp_net_ring_swap_enable(nn, dp, rx, tx);
 	if (err) {
 		int err2;
 
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, dp, xdp_prog, rx, tx);
+		err2 = nfp_net_ring_swap_enable(nn, dp, rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
@@ -2634,7 +2621,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
-		nfp_net_rx_ring_set_free(dp, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(dp, rx);
 	if (tx)
 		nfp_net_tx_ring_set_free(tx);
 
@@ -2646,7 +2633,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 
 err_free_rx:
 	if (rx)
-		nfp_net_rx_ring_set_free(dp, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(dp, rx);
 err_cleanup_vecs:
 	for (r = dp->num_r_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
@@ -2669,7 +2656,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 
 	dp->mtu = new_mtu;
 
-	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, dp, &rx, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2987,6 +2974,7 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 
 static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 {
+	struct bpf_prog *old_prog = nn->dp.xdp_prog;
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->dp.num_rx_rings,
 		.dcnt = nn->dp.rxd_cnt,
@@ -3015,16 +3003,16 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	if (!dp)
 		return -ENOMEM;
 
+	dp->xdp_prog = prog;
 	tx.n_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp, &prog, &rx, &tx);
+	err = nfp_net_ring_reconfig(nn, dp, &rx, &tx);
 	if (err)
 		return err;
 
-	/* @prog got swapped and is now the old one */
-	if (prog)
-		bpf_prog_put(prog);
+	if (old_prog)
+		bpf_prog_put(old_prog);
 
 	nfp_net_xdp_offload(nn, nn->dp.xdp_prog);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index eccb01f3659f..63c1d9ab2335 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -206,8 +206,7 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	if (!dp)
 		return -ENOMEM;
 
-	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog,
-				     reconfig_rx, reconfig_tx);
+	return nfp_net_ring_reconfig(nn, dp, reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_ringparam(struct net_device *netdev,
@@ -791,8 +790,7 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	if (!dp)
 		return -ENOMEM;
 
-	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog,
-				     reconfig_rx, reconfig_tx);
+	return nfp_net_ring_reconfig(nn, dp, reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_channels(struct net_device *netdev,
-- 
2.11.0
