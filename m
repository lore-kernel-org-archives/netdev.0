From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/13] nfp: pass new data path to ring reconfig
Date: Fri, 10 Mar 2017 10:38:29 -0800
Message-ID: <20170310183839.39568-4-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36647 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755419AbdCJSj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:27 -0500
Received: by mail-pg0-f47.google.com with SMTP id g2so24403016pge.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:26 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make callers of nfp_net_ring_reconfig() pass newly allocated data
path structure.  We will gradually make use of that structure
instead of passing parameters around to all the allocation functions.
This commit adds allocation and propagation of new data path struct,
no parameters are converted, yet.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   5 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 108 ++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  14 ++-
 3 files changed, 91 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 90a44fad6bd5..74f6d485351f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -812,8 +812,11 @@ void nfp_net_irqs_disable(struct pci_dev *pdev);
 void
 nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n);
+
+struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
+		      struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
 
 #ifdef CONFIG_NFP_DEBUG
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 951d511643f1..7afefb44b642 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1127,6 +1127,7 @@ nfp_net_free_frag(void *frag, bool xdp)
 
 /**
  * nfp_net_rx_alloc_one() - Allocate and map page frag for RX
+ * @dp:		NFP Net data path struct
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
  * @fl_bufsz:	size of freelist buffers
@@ -1137,10 +1138,10 @@ nfp_net_free_frag(void *frag, bool xdp)
  * Return: allocated page frag or NULL on failure.
  */
 static void *
-nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
+nfp_net_rx_alloc_one(struct nfp_net_dp *dp,
+		     struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 		     unsigned int fl_bufsz, bool xdp)
 {
-	struct nfp_net_dp *dp = &rx_ring->r_vec->nfp_net->dp;
 	int direction;
 	void *frag;
 
@@ -1299,7 +1300,7 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].frag =
-			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
+			nfp_net_rx_alloc_one(dp, rx_ring, &rxbufs[i].dma_addr,
 					     rx_ring->bufsz, xdp);
 		if (!rxbufs[i].frag) {
 			nfp_net_rx_ring_bufs_free(dp, rx_ring, xdp);
@@ -1784,7 +1785,8 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 }
 
 static struct nfp_net_tx_ring *
-nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
+nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
+			    struct nfp_net_ring_set *s,
 			    unsigned int num_stack_tx_rings)
 {
 	struct nfp_net_tx_ring *rings;
@@ -1900,10 +1902,10 @@ nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
-			    bool xdp)
+nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
+			    struct nfp_net_ring_set *s, bool xdp)
 {
-	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(&nn->dp, s->mtu);
+	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(dp, s->mtu);
 	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
@@ -1917,7 +1919,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(&nn->dp, &rings[r], xdp))
+		if (nfp_net_rx_ring_bufs_alloc(dp, &rings[r], xdp))
 			goto err_free_ring;
 	}
 
@@ -1925,7 +1927,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(&nn->dp, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(dp, &rings[r], xdp);
 err_free_ring:
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -2295,14 +2297,15 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx, nn->dp.xdp_prog);
+	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &nn->dp, &rx,
+						      nn->dp.xdp_prog);
 	if (!nn->dp.rx_rings) {
 		err = -ENOMEM;
 		goto err_cleanup_vec;
 	}
 
-	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &tx,
-						   nn->dp.num_stack_tx_rings);
+	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &nn->dp, &tx,
+						      nn->dp.num_stack_tx_rings);
 	if (!nn->dp.tx_rings) {
 		err = -ENOMEM;
 		goto err_free_rx_rings;
@@ -2464,7 +2467,8 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 }
 
 static int
-nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
+nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
+			 unsigned int *num_vecs,
 			 unsigned int *stack_tx_rings,
 			 struct bpf_prog **xdp_prog,
 			 struct nfp_net_ring_set *rx,
@@ -2502,14 +2506,35 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 	return __nfp_net_set_config_and_enable(nn);
 }
 
+struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
+{
+	struct nfp_net_dp *new;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return NULL;
+
+	*new = nn->dp;
+
+	/* Clear things which need to be recomputed */
+	new->fl_bufsz = 0;
+	new->tx_rings = NULL;
+	new->rx_rings = NULL;
+	new->num_r_vecs = 0;
+	new->num_stack_tx_rings = 0;
+
+	return new;
+}
+
 static int
-nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
+nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
+		     struct bpf_prog *xdp_prog,
 		     struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	/* XDP-enabled tests */
 	if (!xdp_prog)
 		return 0;
-	if (rx && nfp_net_calc_fl_bufsz(&nn->dp, rx->mtu) > PAGE_SIZE) {
+	if (rx && nfp_net_calc_fl_bufsz(dp, rx->mtu) > PAGE_SIZE) {
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
 		return -EINVAL;
 	}
@@ -2522,7 +2547,8 @@ nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
 }
 
 static void
-nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
+			   struct bpf_prog **xdp_prog,
 			   struct nfp_net_ring_set *rx,
 			   struct nfp_net_ring_set *tx,
 			   unsigned int stack_tx_rings, unsigned int num_vecs)
@@ -2542,26 +2568,28 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 }
 
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
+		      struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	unsigned int stack_tx_rings, num_vecs, r;
 	int err;
 
-	stack_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
+	stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
 	if (*xdp_prog)
-		stack_tx_rings -= rx ? rx->n_rings : nn->dp.num_rx_rings;
+		stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
 
-	num_vecs = max(rx ? rx->n_rings : nn->dp.num_rx_rings, stack_tx_rings);
+	num_vecs = max(rx ? rx->n_rings : dp->num_rx_rings, stack_tx_rings);
 
-	err = nfp_net_check_config(nn, *xdp_prog, rx, tx);
+	err = nfp_net_check_config(nn, dp, *xdp_prog, rx, tx);
 	if (err)
-		return err;
+		goto exit_free_dp;
 
-	if (!netif_running(nn->dp.netdev)) {
-		nfp_net_ring_reconfig_down(nn, xdp_prog, rx, tx,
+	if (!netif_running(dp->netdev)) {
+		nfp_net_ring_reconfig_down(nn, dp, xdp_prog, rx, tx,
 					   stack_tx_rings, num_vecs);
-		return 0;
+		err = 0;
+		goto exit_free_dp;
 	}
 
 	/* Prepare new rings */
@@ -2573,13 +2601,13 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		}
 	}
 	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, rx, *xdp_prog)) {
+		if (!nfp_net_rx_ring_set_prepare(nn, dp, rx, *xdp_prog)) {
 			err = -ENOMEM;
 			goto err_cleanup_vecs;
 		}
 	}
 	if (tx) {
-		if (!nfp_net_tx_ring_set_prepare(nn, tx, stack_tx_rings)) {
+		if (!nfp_net_tx_ring_set_prepare(nn, dp, tx, stack_tx_rings)) {
 			err = -ENOMEM;
 			goto err_free_rx;
 		}
@@ -2589,7 +2617,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
+	err = nfp_net_ring_swap_enable(nn, dp, &num_vecs, &stack_tx_rings,
 				       xdp_prog, rx, tx);
 	if (err) {
 		int err2;
@@ -2597,7 +2625,8 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
+		err2 = nfp_net_ring_swap_enable(nn, dp, &num_vecs,
+						&stack_tx_rings,
 						xdp_prog, rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
@@ -2607,20 +2636,23 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
-		nfp_net_rx_ring_set_free(&nn->dp, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(dp, rx, *xdp_prog);
 	if (tx)
 		nfp_net_tx_ring_set_free(tx);
 
 	nfp_net_open_stack(nn);
+exit_free_dp:
+	kfree(dp);
 
 	return err;
 
 err_free_rx:
 	if (rx)
-		nfp_net_rx_ring_set_free(&nn->dp, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(dp, rx, *xdp_prog);
 err_cleanup_vecs:
 	for (r = num_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
+	kfree(dp);
 	return err;
 }
 
@@ -2632,8 +2664,13 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		.mtu = new_mtu,
 		.dcnt = nn->dp.rxd_cnt,
 	};
+	struct nfp_net_dp *dp;
+
+	dp = nfp_net_clone_dp(nn);
+	if (!dp)
+		return -ENOMEM;
 
-	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog, &rx, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2960,6 +2997,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 		.n_rings = nn->dp.num_tx_rings,
 		.dcnt = nn->dp.txd_cnt,
 	};
+	struct nfp_net_dp *dp;
 	int err;
 
 	if (prog && prog->xdp_adjust_head) {
@@ -2975,10 +3013,14 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 		return 0;
 	}
 
+	dp = nfp_net_clone_dp(nn);
+	if (!dp)
+		return -ENOMEM;
+
 	tx.n_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, &prog, &rx, &tx);
+	err = nfp_net_ring_reconfig(nn, dp, &prog, &rx, &tx);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 969c30589f23..326ccd74a4bf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -196,13 +196,18 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 		.n_rings = nn->dp.num_tx_rings,
 		.dcnt = txd_cnt,
 	};
+	struct nfp_net_dp *dp;
 
 	if (nn->dp.rxd_cnt != rxd_cnt)
 		reconfig_rx = &rx;
 	if (nn->dp.txd_cnt != txd_cnt)
 		reconfig_tx = &tx;
 
-	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog,
+	dp = nfp_net_clone_dp(nn);
+	if (!dp)
+		return -ENOMEM;
+
+	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog,
 				     reconfig_rx, reconfig_tx);
 }
 
@@ -772,6 +777,7 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 		.n_rings = total_tx,
 		.dcnt = nn->dp.txd_cnt,
 	};
+	struct nfp_net_dp *dp;
 
 	if (nn->dp.num_rx_rings != total_rx)
 		reconfig_rx = &rx;
@@ -783,7 +789,11 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	if (nn->dp.xdp_prog)
 		tx.n_rings += total_rx;
 
-	return nfp_net_ring_reconfig(nn, &nn->dp.xdp_prog,
+	dp = nfp_net_clone_dp(nn);
+	if (!dp)
+		return -ENOMEM;
+
+	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog,
 				     reconfig_rx, reconfig_tx);
 }
 
-- 
2.11.0
