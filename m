From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 6/8] mlx5: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:15 -0800
Message-ID: <20170221193417.3641224-7-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55718 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754084AbdBUTe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:29 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJWinU029734
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:29 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rut5r07a-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:29 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 c2b15a34f86c11e681c10002c99331b0-d21f2a00 for <netdev@vger.kernel.org>;        Tue,
 21 Feb 2017 11:34:28 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 108 ++++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  12 +--
 3 files changed, 36 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 95ca03c..0255423 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -381,7 +381,6 @@ struct mlx5e_rq {
 	u16                    rx_headroom;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
-	struct bpf_prog       *xdp_prog;
 
 	/* control */
 	struct mlx5_wq_ctrl    wq_ctrl;
@@ -695,7 +694,7 @@ struct mlx5e_priv {
 	/* priv data path fields - start */
 	struct mlx5e_sq            **txq_to_sq_map;
 	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
-	struct bpf_prog *xdp_prog;
+	bool			   xdp_enabled;
 	/* priv data path fields - end */
 
 	unsigned long              state;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3cce628..07decbf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -36,6 +36,7 @@
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
 #include <linux/bpf.h>
+#include <net/xdp.h>
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
@@ -113,7 +114,7 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 static void mlx5e_set_rq_priv_params(struct mlx5e_priv *priv)
 {
 	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(priv->mdev) &&
-		    !priv->xdp_prog ?
+		    !priv->xdp_enabled ?
 		    MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
 		    MLX5_WQ_TYPE_LINKED_LIST;
 	mlx5e_set_rq_type_params(priv, rq_type);
@@ -568,14 +569,12 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
 
-	rq->xdp_prog = priv->xdp_prog ? bpf_prog_inc(priv->xdp_prog) : NULL;
-	if (IS_ERR(rq->xdp_prog)) {
-		err = PTR_ERR(rq->xdp_prog);
-		rq->xdp_prog = NULL;
-		goto err_rq_wq_destroy;
-	}
-
-	if (rq->xdp_prog) {
+	if (priv->xdp_enabled) {
+		/* Note XDP is checked whether it is enabled for the device. If
+		 * XDP programs are set per ring as opposed to setting program
+		 * across the device this could be adjusted to account for
+		 * that.
+		 */
 		rq->buff.map_dir = DMA_BIDIRECTIONAL;
 		rq->rx_headroom = XDP_PACKET_HEADROOM;
 	} else {
@@ -662,8 +661,6 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	mlx5_core_destroy_mkey(mdev, &rq->umr_mkey);
 
 err_rq_wq_destroy:
-	if (rq->xdp_prog)
-		bpf_prog_put(rq->xdp_prog);
 	mlx5_wq_destroy(&rq->wq_ctrl);
 
 	return err;
@@ -673,9 +670,6 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 {
 	int i;
 
-	if (rq->xdp_prog)
-		bpf_prog_put(rq->xdp_prog);
-
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		mlx5e_rq_free_mpwqe_info(rq);
@@ -1547,7 +1541,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->netdev   = priv->netdev;
 	c->mkey_be  = cpu_to_be32(priv->mdev->mlx5e_res.mkey.key);
 	c->num_tc   = priv->params.num_tc;
-	c->xdp      = !!priv->xdp_prog;
+	c->xdp      = priv->xdp_enabled;
 
 	if (priv->params.rx_am_enabled)
 		rx_cq_profile = mlx5e_am_get_def_profile(priv->params.rx_cq_period_mode);
@@ -3196,96 +3190,55 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 		schedule_work(&priv->tx_timeout_work);
 }
 
-static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
+static int mlx5e_xdp_init(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct bpf_prog *old_prog;
 	int err = 0;
-	bool reset, was_opened;
-	int i;
+	bool was_opened;
 
 	mutex_lock(&priv->state_lock);
 
-	if ((netdev->features & NETIF_F_LRO) && prog) {
+	if (priv->xdp_enabled == enable)
+		goto unlock;
+
+	if ((netdev->features & NETIF_F_LRO) && enable) {
 		netdev_warn(netdev, "can't set XDP while LRO is on, disable LRO first\n");
 		err = -EINVAL;
 		goto unlock;
 	}
 
+	/* Committing new XDP state */
+	priv->xdp_enabled = enable;
+
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	/* no need for full reset when exchanging programs */
-	reset = (!priv->xdp_prog || !prog);
 
-	if (was_opened && reset)
+	if (was_opened)
 		mlx5e_close_locked(netdev);
-	if (was_opened && !reset) {
-		/* num_channels is invariant here, so we can take the
-		 * batched reference right upfront.
-		 */
-		prog = bpf_prog_add(prog, priv->params.num_channels);
-		if (IS_ERR(prog)) {
-			err = PTR_ERR(prog);
-			goto unlock;
-		}
-	}
-
-	/* exchange programs, extra prog reference we got from caller
-	 * as long as we don't fail from this point onwards.
-	 */
-	old_prog = xchg(&priv->xdp_prog, prog);
-	if (old_prog)
-		bpf_prog_put(old_prog);
 
-	if (reset) /* change RQ type according to priv->xdp_prog */
-		mlx5e_set_rq_priv_params(priv);
+	mlx5e_set_rq_priv_params(priv);
 
-	if (was_opened && reset)
+	if (was_opened)
 		mlx5e_open_locked(netdev);
 
-	if (!test_bit(MLX5E_STATE_OPENED, &priv->state) || reset)
-		goto unlock;
-
-	/* exchanging programs w/o reset, we update ref counts on behalf
-	 * of the channels RQs here.
-	 */
-	for (i = 0; i < priv->params.num_channels; i++) {
-		struct mlx5e_channel *c = priv->channel[i];
-
-		clear_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
-		napi_synchronize(&c->napi);
-		/* prevent mlx5e_poll_rx_cq from accessing rq->xdp_prog */
-
-		old_prog = xchg(&c->rq.xdp_prog, prog);
-
-		set_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
-		/* napi_schedule in case we have missed anything */
-		set_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
-		napi_schedule(&c->napi);
-
-		if (old_prog)
-			bpf_prog_put(old_prog);
-	}
-
 unlock:
 	mutex_unlock(&priv->state_lock);
 	return err;
 }
 
-static bool mlx5e_xdp_attached(struct net_device *dev)
+static int mlx5_xdp_check_bpf(struct net_device *dev, struct bpf_prog *prog)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
-
-	return !!priv->xdp_prog;
+	return 0;
 }
 
 static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return mlx5e_xdp_set(dev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx5e_xdp_attached(dev);
-		return 0;
+	case XDP_MODE_ON:
+		return mlx5e_xdp_init(dev, true);
+	case XDP_MODE_OFF:
+		return mlx5e_xdp_init(dev, false);
+	case XDP_CHECK_BPF_PROG:
+		return mlx5_xdp_check_bpf(dev, xdp->prog);
 	default:
 		return -EINVAL;
 	}
@@ -3706,9 +3659,6 @@ static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 {
 	mlx5e_vxlan_cleanup(priv);
-
-	if (priv->xdp_prog)
-		bpf_prog_put(priv->xdp_prog);
 }
 
 static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index b039b87..50ab4b9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -721,18 +721,18 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 				   struct mlx5e_dma_info *di,
 				   void *va, u16 *rx_headroom, u32 *len)
 {
-	const struct bpf_prog *prog = READ_ONCE(rq->xdp_prog);
 	struct xdp_buff xdp;
+	struct xdp_hook *last_hook;
 	u32 act;
 
-	if (!prog)
+	if (!xdp_hook_run_needed_check(rq->netdev, rq->cq.napi))
 		return false;
 
 	xdp.data = va + *rx_headroom;
 	xdp.data_end = xdp.data + *len;
 	xdp.data_hard_start = va;
 
-	act = bpf_prog_run_xdp(prog, &xdp);
+	act = xdp_hook_run_ret_last(rq->cq.napi, &xdp, &last_hook);
 	switch (act) {
 	case XDP_PASS:
 		*rx_headroom = xdp.data - xdp.data_hard_start;
@@ -740,12 +740,12 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 		return false;
 	case XDP_TX:
 		if (unlikely(!mlx5e_xmit_xdp_frame(rq, di, &xdp)))
-			trace_xdp_exception(rq->netdev, prog, act);
+			trace_xdp_hook_exception(rq->netdev, last_hook, act);
 		return true;
 	default:
-		bpf_warn_invalid_xdp_action(act);
+		xdp_warn_invalid_action(act);
 	case XDP_ABORTED:
-		trace_xdp_exception(rq->netdev, prog, act);
+		trace_xdp_hook_exception(rq->netdev, last_hook, act);
 	case XDP_DROP:
 		rq->stats.xdp_drop++;
 		mlx5e_page_release(rq, di, true);
-- 
2.9.3
