From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/13] nfp: switch to using data path structures for reconfiguration
Date: Fri, 10 Mar 2017 10:38:34 -0800
Message-ID: <20170310183839.39568-9-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36659 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932691AbdCJSjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:31 -0500
Received: by mail-pg0-f50.google.com with SMTP id g2so24403601pge.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:30 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of passing around sets of rings and their parameters just
store all information in the data path structure.

We will no longer user xchg() on XDP programs when we swap programs
while the traffic is guaranteed not to be flowing.  This allows us
to simply assign the entire data path structures instead of copying
field by field.

The optimization to reallocate only the rings on the side (RX/TX)
which has been changed is also removed since it seems like it's not
worth the code complexity.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  10 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 260 ++++++---------------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  46 +---
 3 files changed, 89 insertions(+), 227 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 19dacc3f1269..5a92f6e41dae 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -611,12 +611,6 @@ struct nfp_net {
 	struct nfp_eth_table_port *eth_port;
 };
 
-struct nfp_net_ring_set {
-	unsigned int n_rings;
-	unsigned int dcnt;
-	void *rings;
-};
-
 /* Functions to read/write from/to a BAR
  * Performs any endian conversion necessary.
  */
@@ -813,9 +807,7 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n);
 
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
-int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
-		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
 
 #ifdef CONFIG_NFP_DEBUG
 void nfp_net_debugfs_create(void);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 6ab824a48d1d..a9359da64f80 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1740,20 +1740,20 @@ static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
 
 /**
  * nfp_net_tx_ring_alloc() - Allocate resource for a TX ring
+ * @dp:        NFP Net data path struct
  * @tx_ring:   TX Ring structure to allocate
- * @cnt:       Ring buffer count
  * @is_xdp:    True if ring will be used for XDP
  *
  * Return: 0 on success, negative errno otherwise.
  */
 static int
-nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
+nfp_net_tx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_tx_ring *tx_ring,
+		      bool is_xdp)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
-	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	int sz;
 
-	tx_ring->cnt = cnt;
+	tx_ring->cnt = dp->txd_cnt;
 
 	tx_ring->size = sizeof(*tx_ring->txds) * tx_ring->cnt;
 	tx_ring->txds = dma_zalloc_coherent(dp->dev, tx_ring->size,
@@ -1777,61 +1777,45 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 	return -ENOMEM;
 }
 
-static struct nfp_net_tx_ring *
-nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
-			    struct nfp_net_ring_set *s)
+static int nfp_net_tx_rings_prepare(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
-	struct nfp_net_tx_ring *rings;
 	unsigned int r;
 
-	rings = kcalloc(s->n_rings, sizeof(*rings), GFP_KERNEL);
-	if (!rings)
-		return NULL;
+	dp->tx_rings = kcalloc(dp->num_tx_rings, sizeof(*dp->tx_rings),
+			       GFP_KERNEL);
+	if (!dp->tx_rings)
+		return -ENOMEM;
 
-	for (r = 0; r < s->n_rings; r++) {
+	for (r = 0; r < dp->num_tx_rings; r++) {
 		int bias = 0;
 
 		if (r >= dp->num_stack_tx_rings)
 			bias = dp->num_stack_tx_rings;
 
-		nfp_net_tx_ring_init(&rings[r], &nn->r_vecs[r - bias], r);
+		nfp_net_tx_ring_init(&dp->tx_rings[r], &nn->r_vecs[r - bias],
+				     r);
 
-		if (nfp_net_tx_ring_alloc(&rings[r], s->dcnt, bias))
+		if (nfp_net_tx_ring_alloc(dp, &dp->tx_rings[r], bias))
 			goto err_free_prev;
 	}
 
-	return s->rings = rings;
+	return 0;
 
 err_free_prev:
 	while (r--)
-		nfp_net_tx_ring_free(&rings[r]);
-	kfree(rings);
-	return NULL;
-}
-
-static void
-nfp_net_tx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
-{
-	struct nfp_net_ring_set new = *s;
-
-	s->dcnt = nn->dp.txd_cnt;
-	s->rings = nn->dp.tx_rings;
-	s->n_rings = nn->dp.num_tx_rings;
-
-	nn->dp.txd_cnt = new.dcnt;
-	nn->dp.tx_rings = new.rings;
-	nn->dp.num_tx_rings = new.n_rings;
+		nfp_net_tx_ring_free(&dp->tx_rings[r]);
+	kfree(dp->tx_rings);
+	return -ENOMEM;
 }
 
-static void nfp_net_tx_ring_set_free(struct nfp_net_ring_set *s)
+static void nfp_net_tx_rings_free(struct nfp_net_dp *dp)
 {
-	struct nfp_net_tx_ring *rings = s->rings;
 	unsigned int r;
 
-	for (r = 0; r < s->n_rings; r++)
-		nfp_net_tx_ring_free(&rings[r]);
+	for (r = 0; r < dp->num_tx_rings; r++)
+		nfp_net_tx_ring_free(&dp->tx_rings[r]);
 
-	kfree(rings);
+	kfree(dp->tx_rings);
 }
 
 /**
@@ -1860,17 +1844,15 @@ static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_alloc() - Allocate resource for a RX ring
  * @dp:	      NFP Net data path struct
  * @rx_ring:  RX ring to allocate
- * @cnt:      Ring buffer count
  *
  * Return: 0 on success, negative errno otherwise.
  */
 static int
-nfp_net_rx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
-		      u32 cnt)
+nfp_net_rx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring)
 {
 	int sz;
 
-	rx_ring->cnt = cnt;
+	rx_ring->cnt = dp->rxd_cnt;
 	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
 	rx_ring->rxds = dma_zalloc_coherent(dp->dev, rx_ring->size,
 					    &rx_ring->dma, GFP_KERNEL);
@@ -1889,72 +1871,47 @@ nfp_net_rx_ring_alloc(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 	return -ENOMEM;
 }
 
-static struct nfp_net_rx_ring *
-nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
-			    struct nfp_net_ring_set *s)
+static int nfp_net_rx_rings_prepare(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
-	struct nfp_net_rx_ring *rings;
 	unsigned int r;
 
-	rings = kcalloc(s->n_rings, sizeof(*rings), GFP_KERNEL);
-	if (!rings)
-		return NULL;
+	dp->rx_rings = kcalloc(dp->num_rx_rings, sizeof(*dp->rx_rings),
+			       GFP_KERNEL);
+	if (!dp->rx_rings)
+		return -ENOMEM;
 
-	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_init(&rings[r], &nn->r_vecs[r], r);
+	for (r = 0; r < dp->num_rx_rings; r++) {
+		nfp_net_rx_ring_init(&dp->rx_rings[r], &nn->r_vecs[r], r);
 
-		if (nfp_net_rx_ring_alloc(dp, &rings[r], s->dcnt))
+		if (nfp_net_rx_ring_alloc(dp, &dp->rx_rings[r]))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(dp, &rings[r]))
+		if (nfp_net_rx_ring_bufs_alloc(dp, &dp->rx_rings[r]))
 			goto err_free_ring;
 	}
 
-	return s->rings = rings;
+	return 0;
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(dp, &rings[r]);
+		nfp_net_rx_ring_bufs_free(dp, &dp->rx_rings[r]);
 err_free_ring:
-		nfp_net_rx_ring_free(&rings[r]);
+		nfp_net_rx_ring_free(&dp->rx_rings[r]);
 	}
-	kfree(rings);
-	return NULL;
-}
-
-static void
-nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_dp *dp,
-			 struct nfp_net_ring_set *s)
-{
-	struct nfp_net_ring_set new = *s;
-	struct nfp_net_dp new_dp = *dp;
-
-	dp->fl_bufsz = nn->dp.fl_bufsz;
-	dp->mtu = nn->dp.netdev->mtu;
-	s->dcnt = nn->dp.rxd_cnt;
-	s->rings = nn->dp.rx_rings;
-	s->n_rings = nn->dp.num_rx_rings;
-
-	nn->dp.mtu = new_dp.mtu;
-	nn->dp.netdev->mtu = new_dp.mtu;
-	nn->dp.fl_bufsz = new_dp.fl_bufsz;
-	nn->dp.rxd_cnt = new.dcnt;
-	nn->dp.rx_rings = new.rings;
-	nn->dp.num_rx_rings = new.n_rings;
+	kfree(dp->rx_rings);
+	return -ENOMEM;
 }
 
-static void
-nfp_net_rx_ring_set_free(struct nfp_net_dp *dp, struct nfp_net_ring_set *s)
+static void nfp_net_rx_rings_free(struct nfp_net_dp *dp)
 {
-	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
-	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_bufs_free(dp, &rings[r]);
-		nfp_net_rx_ring_free(&rings[r]);
+	for (r = 0; r < dp->num_rx_rings; r++) {
+		nfp_net_rx_ring_bufs_free(dp, &dp->rx_rings[r]);
+		nfp_net_rx_ring_free(&dp->rx_rings[r]);
 	}
 
-	kfree(rings);
+	kfree(dp->rx_rings);
 }
 
 static void
@@ -2248,14 +2205,6 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 static int nfp_net_netdev_open(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-	struct nfp_net_ring_set rx = {
-		.n_rings = nn->dp.num_rx_rings,
-		.dcnt = nn->dp.rxd_cnt,
-	};
-	struct nfp_net_ring_set tx = {
-		.n_rings = nn->dp.num_tx_rings,
-		.dcnt = nn->dp.txd_cnt,
-	};
 	int err, r;
 
 	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE) {
@@ -2286,17 +2235,13 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->dp.rx_rings = nfp_net_rx_ring_set_prepare(nn, &nn->dp, &rx);
-	if (!nn->dp.rx_rings) {
-		err = -ENOMEM;
+	err = nfp_net_rx_rings_prepare(nn, &nn->dp);
+	if (err)
 		goto err_cleanup_vec;
-	}
 
-	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &nn->dp, &tx);
-	if (!nn->dp.tx_rings) {
-		err = -ENOMEM;
+	err = nfp_net_tx_rings_prepare(nn, &nn->dp);
+	if (err)
 		goto err_free_rx_rings;
-	}
 
 	for (r = 0; r < nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
@@ -2331,9 +2276,9 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	return 0;
 
 err_free_rings:
-	nfp_net_tx_ring_set_free(&tx);
+	nfp_net_tx_rings_free(&nn->dp);
 err_free_rx_rings:
-	nfp_net_rx_ring_set_free(&nn->dp, &rx);
+	nfp_net_rx_rings_free(&nn->dp);
 err_cleanup_vec:
 	r = nn->dp.num_r_vecs;
 err_cleanup_vec_p:
@@ -2460,31 +2405,21 @@ static void nfp_net_dp_swap(struct nfp_net *nn, struct nfp_net_dp *dp)
 	nn->dp = new_dp;
 
 	nn->dp.netdev->mtu = new_dp.mtu;
+
+	if (!netif_is_rxfh_configured(nn->dp.netdev))
+		nfp_net_rss_init_itbl(nn);
 }
 
-static int
-nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
-			 struct nfp_net_ring_set *rx,
-			 struct nfp_net_ring_set *tx)
+static int nfp_net_dp_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
 	unsigned int r;
 	int err;
 
-	if (rx)
-		nfp_net_rx_ring_set_swap(nn, dp, rx);
-	if (tx)
-		nfp_net_tx_ring_set_swap(nn, tx);
-
-	swap(dp->num_r_vecs, nn->dp.num_r_vecs);
-	swap(dp->num_stack_tx_rings, nn->dp.num_stack_tx_rings);
-	dp->xdp_prog = xchg(&nn->dp.xdp_prog, dp->xdp_prog);
+	nfp_net_dp_swap(nn, dp);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(&nn->dp, &nn->r_vecs[r], r);
 
-	if (!netif_is_rxfh_configured(nn->dp.netdev))
-		nfp_net_rss_init_itbl(nn);
-
 	err = netif_set_real_num_rx_queues(nn->dp.netdev, nn->dp.num_rx_rings);
 	if (err)
 		return err;
@@ -2519,9 +2454,7 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
 	return new;
 }
 
-static int
-nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
-		     struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
+static int nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
 	/* XDP-enabled tests */
 	if (!dp->xdp_prog)
@@ -2530,7 +2463,7 @@ nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
 		return -EINVAL;
 	}
-	if (tx && tx->n_rings > nn->max_tx_rings) {
+	if (dp->num_tx_rings > nn->max_tx_rings) {
 		nn_warn(nn, "Insufficient number of TX rings w/ XDP enabled\n");
 		return -EINVAL;
 	}
@@ -2538,44 +2471,24 @@ nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
 	return 0;
 }
 
-static void
-nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
-			   struct nfp_net_ring_set *rx,
-			   struct nfp_net_ring_set *tx)
-{
-	nfp_net_dp_swap(nn, dp);
-
-	nn->dp.rxd_cnt = rx ? rx->dcnt : nn->dp.rxd_cnt;
-	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
-	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
-	nn->dp.num_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
-
-	if (!netif_is_rxfh_configured(nn->dp.netdev))
-		nfp_net_rss_init_itbl(nn);
-}
-
-int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
-		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp)
 {
 	int r, err;
 
 	dp->fl_bufsz = nfp_net_calc_fl_bufsz(dp);
 
-	dp->num_stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
+	dp->num_stack_tx_rings = dp->num_tx_rings;
 	if (dp->xdp_prog)
-		dp->num_stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
+		dp->num_stack_tx_rings -= dp->num_rx_rings;
 
-	dp->num_r_vecs = max(rx ? rx->n_rings : dp->num_rx_rings,
-			     dp->num_stack_tx_rings);
+	dp->num_r_vecs = max(dp->num_rx_rings, dp->num_stack_tx_rings);
 
-	err = nfp_net_check_config(nn, dp, rx, tx);
+	err = nfp_net_check_config(nn, dp);
 	if (err)
 		goto exit_free_dp;
 
 	if (!netif_running(dp->netdev)) {
-		nfp_net_ring_reconfig_down(nn, dp, rx, tx);
-
+		nfp_net_dp_swap(nn, dp);
 		err = 0;
 		goto exit_free_dp;
 	}
@@ -2588,31 +2501,27 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 			goto err_cleanup_vecs;
 		}
 	}
-	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, dp, rx)) {
-			err = -ENOMEM;
-			goto err_cleanup_vecs;
-		}
-	}
-	if (tx) {
-		if (!nfp_net_tx_ring_set_prepare(nn, dp, tx)) {
-			err = -ENOMEM;
-			goto err_free_rx;
-		}
-	}
+
+	err = nfp_net_rx_rings_prepare(nn, dp);
+	if (err)
+		goto err_cleanup_vecs;
+
+	err = nfp_net_tx_rings_prepare(nn, dp);
+	if (err)
+		goto err_free_rx;
 
 	/* Stop device, swap in new rings, try to start the firmware */
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, dp, rx, tx);
+	err = nfp_net_dp_swap_enable(nn, dp);
 	if (err) {
 		int err2;
 
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, dp, rx, tx);
+		err2 = nfp_net_dp_swap_enable(nn, dp);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
@@ -2620,10 +2529,8 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	for (r = dp->num_r_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
-	if (rx)
-		nfp_net_rx_ring_set_free(dp, rx);
-	if (tx)
-		nfp_net_tx_ring_set_free(tx);
+	nfp_net_rx_rings_free(dp);
+	nfp_net_tx_rings_free(dp);
 
 	nfp_net_open_stack(nn);
 exit_free_dp:
@@ -2632,8 +2539,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	return err;
 
 err_free_rx:
-	if (rx)
-		nfp_net_rx_ring_set_free(dp, rx);
+	nfp_net_rx_rings_free(dp);
 err_cleanup_vecs:
 	for (r = dp->num_r_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
@@ -2644,10 +2550,6 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-	struct nfp_net_ring_set rx = {
-		.n_rings = nn->dp.num_rx_rings,
-		.dcnt = nn->dp.rxd_cnt,
-	};
 	struct nfp_net_dp *dp;
 
 	dp = nfp_net_clone_dp(nn);
@@ -2656,7 +2558,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 
 	dp->mtu = new_mtu;
 
-	return nfp_net_ring_reconfig(nn, dp, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, dp);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2975,14 +2877,6 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 {
 	struct bpf_prog *old_prog = nn->dp.xdp_prog;
-	struct nfp_net_ring_set rx = {
-		.n_rings = nn->dp.num_rx_rings,
-		.dcnt = nn->dp.rxd_cnt,
-	};
-	struct nfp_net_ring_set tx = {
-		.n_rings = nn->dp.num_tx_rings,
-		.dcnt = nn->dp.txd_cnt,
-	};
 	struct nfp_net_dp *dp;
 	int err;
 
@@ -3004,10 +2898,10 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 		return -ENOMEM;
 
 	dp->xdp_prog = prog;
-	tx.n_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
+	dp->num_tx_rings += prog ? nn->dp.num_rx_rings : -nn->dp.num_rx_rings;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp, &rx, &tx);
+	err = nfp_net_ring_reconfig(nn, dp);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 63c1d9ab2335..ed22a813e579 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -186,27 +186,16 @@ static void nfp_net_get_ringparam(struct net_device *netdev,
 
 static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 {
-	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
-	struct nfp_net_ring_set rx = {
-		.n_rings = nn->dp.num_rx_rings,
-		.dcnt = rxd_cnt,
-	};
-	struct nfp_net_ring_set tx = {
-		.n_rings = nn->dp.num_tx_rings,
-		.dcnt = txd_cnt,
-	};
 	struct nfp_net_dp *dp;
 
-	if (nn->dp.rxd_cnt != rxd_cnt)
-		reconfig_rx = &rx;
-	if (nn->dp.txd_cnt != txd_cnt)
-		reconfig_tx = &tx;
-
 	dp = nfp_net_clone_dp(nn);
 	if (!dp)
 		return -ENOMEM;
 
-	return nfp_net_ring_reconfig(nn, dp, reconfig_rx, reconfig_tx);
+	dp->rxd_cnt = rxd_cnt;
+	dp->txd_cnt = txd_cnt;
+
+	return nfp_net_ring_reconfig(nn, dp);
 }
 
 static int nfp_net_set_ringparam(struct net_device *netdev,
@@ -765,32 +754,19 @@ static void nfp_net_get_channels(struct net_device *netdev,
 static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 				 unsigned int total_tx)
 {
-	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
-	struct nfp_net_ring_set rx = {
-		.n_rings = total_rx,
-		.dcnt = nn->dp.rxd_cnt,
-	};
-	struct nfp_net_ring_set tx = {
-		.n_rings = total_tx,
-		.dcnt = nn->dp.txd_cnt,
-	};
 	struct nfp_net_dp *dp;
 
-	if (nn->dp.num_rx_rings != total_rx)
-		reconfig_rx = &rx;
-	if (nn->dp.num_stack_tx_rings != total_tx ||
-	    (nn->dp.xdp_prog && reconfig_rx))
-		reconfig_tx = &tx;
-
-	/* nfp_net_check_config() will catch tx.n_rings > nn->max_tx_rings */
-	if (nn->dp.xdp_prog)
-		tx.n_rings += total_rx;
-
 	dp = nfp_net_clone_dp(nn);
 	if (!dp)
 		return -ENOMEM;
 
-	return nfp_net_ring_reconfig(nn, dp, reconfig_rx, reconfig_tx);
+	dp->num_rx_rings = total_rx;
+	dp->num_tx_rings = total_tx;
+	/* nfp_net_check_config() will catch num_tx_rings > nn->max_tx_rings */
+	if (dp->xdp_prog)
+		dp->num_tx_rings += total_rx;
+
+	return nfp_net_ring_reconfig(nn, dp);
 }
 
 static int nfp_net_set_channels(struct net_device *netdev,
-- 
2.11.0
