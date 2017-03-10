From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/13] nfp: use dp to carry number of stack tx rings and vectors
Date: Fri, 10 Mar 2017 10:38:30 -0800
Message-ID: <20170310183839.39568-5-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35557 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755050AbdCJSj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:28 -0500
Received: by mail-pg0-f52.google.com with SMTP id b129so41791294pgc.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:27 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of passing variables around use dp to store number of tx rings
for the stack and number of IRQ vectors.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 62 +++++++++++-----------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7afefb44b642..52f0e9dfd15a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1786,8 +1786,7 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 
 static struct nfp_net_tx_ring *
 nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
-			    struct nfp_net_ring_set *s,
-			    unsigned int num_stack_tx_rings)
+			    struct nfp_net_ring_set *s)
 {
 	struct nfp_net_tx_ring *rings;
 	unsigned int r;
@@ -1799,8 +1798,8 @@ nfp_net_tx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_dp *dp,
 	for (r = 0; r < s->n_rings; r++) {
 		int bias = 0;
 
-		if (r >= num_stack_tx_rings)
-			bias = num_stack_tx_rings;
+		if (r >= dp->num_stack_tx_rings)
+			bias = dp->num_stack_tx_rings;
 
 		nfp_net_tx_ring_init(&rings[r], &nn->r_vecs[r - bias], r);
 
@@ -2304,8 +2303,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_cleanup_vec;
 	}
 
-	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &nn->dp, &tx,
-						      nn->dp.num_stack_tx_rings);
+	nn->dp.tx_rings = nfp_net_tx_ring_set_prepare(nn, &nn->dp, &tx);
 	if (!nn->dp.tx_rings) {
 		err = -ENOMEM;
 		goto err_free_rx_rings;
@@ -2466,10 +2464,16 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 			ethtool_rxfh_indir_default(i, nn->dp.num_rx_rings);
 }
 
+static void nfp_net_dp_swap(struct nfp_net *nn, struct nfp_net_dp *dp)
+{
+	struct nfp_net_dp new_dp = *dp;
+
+	*dp = nn->dp;
+	nn->dp = new_dp;
+}
+
 static int
 nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
-			 unsigned int *num_vecs,
-			 unsigned int *stack_tx_rings,
 			 struct bpf_prog **xdp_prog,
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
@@ -2482,8 +2486,8 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp,
 	if (tx)
 		nfp_net_tx_ring_set_swap(nn, tx);
 
-	swap(*num_vecs, nn->dp.num_r_vecs);
-	swap(*stack_tx_rings, nn->dp.num_stack_tx_rings);
+	swap(dp->num_r_vecs, nn->dp.num_r_vecs);
+	swap(dp->num_stack_tx_rings, nn->dp.num_stack_tx_rings);
 	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
@@ -2550,17 +2554,16 @@ static void
 nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
 			   struct bpf_prog **xdp_prog,
 			   struct nfp_net_ring_set *rx,
-			   struct nfp_net_ring_set *tx,
-			   unsigned int stack_tx_rings, unsigned int num_vecs)
+			   struct nfp_net_ring_set *tx)
 {
+	nfp_net_dp_swap(nn, dp);
+
 	nn->dp.netdev->mtu = rx ? rx->mtu : nn->dp.netdev->mtu;
 	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, nn->dp.netdev->mtu);
 	nn->dp.rxd_cnt = rx ? rx->dcnt : nn->dp.rxd_cnt;
 	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
 	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
 	nn->dp.num_tx_rings = tx ? tx->n_rings : nn->dp.num_tx_rings;
-	nn->dp.num_stack_tx_rings = stack_tx_rings;
-	nn->dp.num_r_vecs = num_vecs;
 	*xdp_prog = xchg(&nn->dp.xdp_prog, *xdp_prog);
 
 	if (!netif_is_rxfh_configured(nn->dp.netdev))
@@ -2572,31 +2575,31 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 		      struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
-	unsigned int stack_tx_rings, num_vecs, r;
-	int err;
+	int r, err;
 
-	stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
+	dp->num_stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
 	if (*xdp_prog)
-		stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
+		dp->num_stack_tx_rings -= rx ? rx->n_rings : dp->num_rx_rings;
 
-	num_vecs = max(rx ? rx->n_rings : dp->num_rx_rings, stack_tx_rings);
+	dp->num_r_vecs = max(rx ? rx->n_rings : dp->num_rx_rings,
+			     dp->num_stack_tx_rings);
 
 	err = nfp_net_check_config(nn, dp, *xdp_prog, rx, tx);
 	if (err)
 		goto exit_free_dp;
 
 	if (!netif_running(dp->netdev)) {
-		nfp_net_ring_reconfig_down(nn, dp, xdp_prog, rx, tx,
-					   stack_tx_rings, num_vecs);
+		nfp_net_ring_reconfig_down(nn, dp, xdp_prog, rx, tx);
+
 		err = 0;
 		goto exit_free_dp;
 	}
 
 	/* Prepare new rings */
-	for (r = nn->dp.num_r_vecs; r < num_vecs; r++) {
+	for (r = nn->dp.num_r_vecs; r < dp->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
 		if (err) {
-			num_vecs = r;
+			dp->num_r_vecs = r;
 			goto err_cleanup_vecs;
 		}
 	}
@@ -2607,7 +2610,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 		}
 	}
 	if (tx) {
-		if (!nfp_net_tx_ring_set_prepare(nn, dp, tx, stack_tx_rings)) {
+		if (!nfp_net_tx_ring_set_prepare(nn, dp, tx)) {
 			err = -ENOMEM;
 			goto err_free_rx;
 		}
@@ -2617,22 +2620,19 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	nfp_net_close_stack(nn);
 	nfp_net_clear_config_and_disable(nn);
 
-	err = nfp_net_ring_swap_enable(nn, dp, &num_vecs, &stack_tx_rings,
-				       xdp_prog, rx, tx);
+	err = nfp_net_ring_swap_enable(nn, dp, xdp_prog, rx, tx);
 	if (err) {
 		int err2;
 
 		nfp_net_clear_config_and_disable(nn);
 
 		/* Try with old configuration and old rings */
-		err2 = nfp_net_ring_swap_enable(nn, dp, &num_vecs,
-						&stack_tx_rings,
-						xdp_prog, rx, tx);
+		err2 = nfp_net_ring_swap_enable(nn, dp, xdp_prog, rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
 	}
-	for (r = num_vecs - 1; r >= nn->dp.num_r_vecs; r--)
+	for (r = dp->num_r_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
@@ -2650,7 +2650,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 	if (rx)
 		nfp_net_rx_ring_set_free(dp, rx, *xdp_prog);
 err_cleanup_vecs:
-	for (r = num_vecs - 1; r >= nn->dp.num_r_vecs; r--)
+	for (r = dp->num_r_vecs - 1; r >= nn->dp.num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 	kfree(dp);
 	return err;
-- 
2.11.0
