From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/14] net/mlx5e: Split open/close channels to stages
Date: Mon, 27 Mar 2017 23:49:02 +0300
Message-ID: <20170327204910.20287-7-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44891 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752616AbdC0Uua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:30 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a foundation for safe config flow, a simple clear API such as
(Open then Activate) where the "Open" handles the heavy unsafe
creation operation and the "activate" will be fast and fail safe,
to enable the newly created channels.

For this we split the RQs/TXQ SQs and channels open/close flows to
open => activate, deactivate => close.

This will simplify the ability to have fail safe configuration changes
in downstream patches as follows:

make_new_config(new_params)
{
     old_channels = current_active_channels;
     new_channels = create_channels(new_params);
     if (!new_channels)
              return "Failed, but current channels still active :)"
     deactivate_channels(old_channels); /* Can't fail */
     activate_channels(new_channels); /* Can't fail */
     close_channels(old_channels);
     current_active_channels = new_channels;

     return "SUCCESS";
}

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   5 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 214 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   4 +-
 4 files changed, 148 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5f7cc58d900c..f1895ebe7fe5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -358,6 +358,7 @@ struct mlx5e_txqsq {
 	struct mlx5_wq_ctrl        wq_ctrl;
 	struct mlx5e_channel      *channel;
 	int                        tc;
+	int                        txq_ix;
 	u32                        rate_limit;
 } ____cacheline_aligned_in_smp;
 
@@ -732,8 +733,8 @@ struct mlx5e_profile {
 
 struct mlx5e_priv {
 	/* priv data path fields - start */
-	struct mlx5e_txqsq         **txq_to_sq_map;
-	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
+	struct mlx5e_txqsq *txq2sq[MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC];
+	int channel_tc2txq[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
 	struct bpf_prog *xdp_prog;
 	/* priv data path fields - end */
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index faa21848c9dc..5159358a242d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -269,7 +269,7 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				sprintf(data + (idx++) * ETH_GSTRING_LEN,
 					sq_stats_desc[j].format,
-					priv->channeltc_to_txq_map[i][tc]);
+					priv->channel_tc2txq[i][tc]);
 }
 
 static void mlx5e_get_strings(struct net_device *dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a98d01684247..6be7c2367d41 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -820,6 +820,8 @@ static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 		msleep(20);
 	}
 
+	netdev_warn(priv->netdev, "Failed to get min RX wqes on RQN[0x%x] wq cur_sz(%d) min_rx_wqes(%d)\n",
+		    rq->rqn, wq->cur_sz, priv->params.min_rx_wqes);
 	return -ETIMEDOUT;
 }
 
@@ -848,9 +850,6 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 			 struct mlx5e_rq_param *param,
 			 struct mlx5e_rq *rq)
 {
-	struct mlx5e_icosq *sq = &c->icosq;
-	u16 pi = sq->pc & sq->wq.sz_m1;
-	struct mlx5e_tx_wqe *nopwqe;
 	int err;
 
 	err = mlx5e_alloc_rq(c, param, rq);
@@ -861,7 +860,6 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (err)
 		goto err_free_rq;
 
-	set_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RST, MLX5_RQC_STATE_RDY);
 	if (err)
 		goto err_destroy_rq;
@@ -869,14 +867,9 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (param->am_enabled)
 		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
 
-	sq->db.ico_wqe[pi].opcode     = MLX5_OPCODE_NOP;
-	sq->db.ico_wqe[pi].num_wqebbs = 1;
-	nopwqe = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
-	mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nopwqe->ctrl);
 	return 0;
 
 err_destroy_rq:
-	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	mlx5e_destroy_rq(rq);
 err_free_rq:
 	mlx5e_free_rq(rq);
@@ -884,12 +877,28 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	return err;
 }
 
-static void mlx5e_close_rq(struct mlx5e_rq *rq)
+static void mlx5e_activate_rq(struct mlx5e_rq *rq)
+{
+	struct mlx5e_icosq *sq = &rq->channel->icosq;
+	u16 pi = sq->pc & sq->wq.sz_m1;
+	struct mlx5e_tx_wqe *nopwqe;
+
+	set_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
+	sq->db.ico_wqe[pi].opcode     = MLX5_OPCODE_NOP;
+	sq->db.ico_wqe[pi].num_wqebbs = 1;
+	nopwqe = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+	mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nopwqe->ctrl);
+}
+
+static void mlx5e_deactivate_rq(struct mlx5e_rq *rq)
 {
 	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
-	cancel_work_sync(&rq->am.work);
+}
 
+static void mlx5e_close_rq(struct mlx5e_rq *rq)
+{
+	cancel_work_sync(&rq->am.work);
 	mlx5e_destroy_rq(rq);
 	mlx5e_free_rx_descs(rq);
 	mlx5e_free_rq(rq);
@@ -1041,13 +1050,13 @@ static int mlx5e_alloc_txqsq_db(struct mlx5e_txqsq *sq, int numa)
 
 static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 			     int tc,
+			     int txq_ix,
 			     struct mlx5e_sq_param *param,
 			     struct mlx5e_txqsq *sq)
 {
 	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
 	struct mlx5e_priv *priv    = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
-	int txq_ix;
 	int err;
 
 	sq->pdev      = c->pdev;
@@ -1055,6 +1064,7 @@ static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
 	sq->tc        = tc;
+	sq->txq_ix    = txq_ix;
 	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
 	sq->max_inline      = param->max_inline;
 	sq->min_inline_mode = param->min_inline_mode;
@@ -1069,10 +1079,6 @@ static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	txq_ix = c->ix + tc * priv->channels.num;
-	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
-	priv->txq_to_sq_map[txq_ix] = sq;
-
 	sq->edge = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
 
 	return 0;
@@ -1214,16 +1220,16 @@ static int mlx5e_set_sq_maxrate(struct net_device *dev,
 
 static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 			    int tc,
+			    int txq_ix,
 			    struct mlx5e_sq_param *param,
 			    struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_create_sq_param csp = {};
 	struct mlx5e_priv *priv = c->priv;
 	u32 tx_rate;
-	int txq_ix;
 	int err;
 
-	err = mlx5e_alloc_txqsq(c, tc, param, sq);
+	err = mlx5e_alloc_txqsq(c, tc, txq_ix, param, sq);
 	if (err)
 		return err;
 
@@ -1232,18 +1238,14 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
 	csp.min_inline_mode = sq->min_inline_mode;
-	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
 	if (err)
 		goto err_free_txqsq;
 
-	txq_ix = c->ix + tc * priv->channels.num;
-	tx_rate = priv->tx_rates[txq_ix];
+	tx_rate = priv->tx_rates[sq->txq_ix];
 	if (tx_rate)
 		mlx5e_set_sq_maxrate(priv->netdev, sq, tx_rate);
 
-	netdev_tx_reset_queue(sq->txq);
-	netif_tx_start_queue(sq->txq);
 	return 0;
 
 err_free_txqsq:
@@ -1253,6 +1255,16 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	return err;
 }
 
+static void mlx5e_activate_txqsq(struct mlx5e_txqsq *sq)
+{
+	struct mlx5e_priv *priv = sq->channel->priv;
+
+	sq->txq = netdev_get_tx_queue(priv->netdev, sq->txq_ix);
+	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	netdev_tx_reset_queue(sq->txq);
+	netif_tx_start_queue(sq->txq);
+}
+
 static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 {
 	__netif_tx_lock_bh(txq);
@@ -1260,11 +1272,9 @@ static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 	__netif_tx_unlock_bh(txq);
 }
 
-static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
+static void mlx5e_deactivate_txqsq(struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_channel *c = sq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
 
 	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	/* prevent netif_tx_wake_queue */
@@ -1280,6 +1290,13 @@ static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
 		nop = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
 		mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nop->ctrl);
 	}
+}
+
+static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
+{
+	struct mlx5e_channel *c = sq->channel;
+	struct mlx5e_priv *priv = c->priv;
+	struct mlx5_core_dev *mdev = priv->mdev;
 
 	mlx5e_destroy_sq(priv, sq->sqn);
 	if (sq->rate_limit)
@@ -1578,7 +1595,9 @@ static int mlx5e_open_sqs(struct mlx5e_channel *c,
 	int tc;
 
 	for (tc = 0; tc < c->num_tc; tc++) {
-		err = mlx5e_open_txqsq(c, tc, &cparam->sq, &c->sq[tc]);
+		int txq_ix = c->ix + tc * c->priv->channels.num;
+
+		err = mlx5e_open_txqsq(c, tc, txq_ix, &cparam->sq, &c->sq[tc]);
 		if (err)
 			goto err_close_sqs;
 	}
@@ -1600,14 +1619,6 @@ static void mlx5e_close_sqs(struct mlx5e_channel *c)
 		mlx5e_close_txqsq(&c->sq[tc]);
 }
 
-static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
-{
-	int i;
-
-	for (i = 0; i < priv->profile->max_tc; i++)
-		priv->channeltc_to_txq_map[ix][i] = ix + i * priv->channels.num;
-}
-
 static int mlx5e_set_sq_maxrate(struct net_device *dev,
 				struct mlx5e_txqsq *sq, u32 rate)
 {
@@ -1658,7 +1669,7 @@ static int mlx5e_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5e_txqsq *sq = priv->txq_to_sq_map[index];
+	struct mlx5e_txqsq *sq = priv->txq2sq[index];
 	int err = 0;
 
 	if (!mlx5_rl_is_supported(mdev)) {
@@ -1722,8 +1733,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	else
 		rx_cq_profile = priv->params.rx_cq_moderation;
 
-	mlx5e_build_channeltc_to_txq_map(priv, ix);
-
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
 	err = mlx5e_open_cq(c, &cparam->icosq_cq, &c->icosq.cq, icosq_cq_moder);
@@ -1763,7 +1772,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	if (err)
 		goto err_close_xdp_sq;
 
-	netif_set_xps_queue(netdev, get_cpu_mask(c->cpu), ix);
 	*cp = c;
 
 	return 0;
@@ -1798,6 +1806,25 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	return err;
 }
 
+static void mlx5e_activate_channel(struct mlx5e_channel *c)
+{
+	int tc;
+
+	for (tc = 0; tc < c->num_tc; tc++)
+		mlx5e_activate_txqsq(&c->sq[tc]);
+	mlx5e_activate_rq(&c->rq);
+	netif_set_xps_queue(c->priv->netdev, get_cpu_mask(c->cpu), c->ix);
+}
+
+static void mlx5e_deactivate_channel(struct mlx5e_channel *c)
+{
+	int tc;
+
+	mlx5e_deactivate_rq(&c->rq);
+	for (tc = 0; tc < c->num_tc; tc++)
+		mlx5e_deactivate_txqsq(&c->sq[tc]);
+}
+
 static void mlx5e_close_channel(struct mlx5e_channel *c)
 {
 	mlx5e_close_rq(&c->rq);
@@ -1983,16 +2010,13 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv, struct mlx5e_channels *c
 	struct mlx5e_channel_param *cparam;
 	int err = -ENOMEM;
 	int i;
-	int j;
 
 	chs->num = priv->params.num_channels;
 
 	chs->c = kcalloc(chs->num, sizeof(struct mlx5e_channel *), GFP_KERNEL);
-	priv->txq_to_sq_map = kcalloc(chs->num * priv->params.num_tc,
-				      sizeof(struct mlx5e_sq *), GFP_KERNEL);
 	cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
-	if (!chs->c || !priv->txq_to_sq_map || !cparam)
-		goto err_free_txq_to_sq_map;
+	if (!chs->c || !cparam)
+		goto err_free;
 
 	mlx5e_build_channel_param(priv, cparam);
 	for (i = 0; i < chs->num; i++) {
@@ -2001,17 +2025,6 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv, struct mlx5e_channels *c
 			goto err_close_channels;
 	}
 
-	for (j = 0; j < chs->num; j++) {
-		err = mlx5e_wait_for_min_rx_wqes(&chs->c[j]->rq);
-		if (err)
-			goto err_close_channels;
-	}
-
-	/* FIXME: This is a W/A for tx timeout watch dog false alarm when
-	 * polling for inactive tx queues.
-	 */
-	netif_tx_start_all_queues(priv->netdev);
-
 	kfree(cparam);
 	return 0;
 
@@ -2019,29 +2032,50 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv, struct mlx5e_channels *c
 	for (i--; i >= 0; i--)
 		mlx5e_close_channel(chs->c[i]);
 
-err_free_txq_to_sq_map:
-	kfree(priv->txq_to_sq_map);
+err_free:
 	kfree(chs->c);
 	kfree(cparam);
 	chs->num = 0;
 	return err;
 }
 
-static void mlx5e_close_channels(struct mlx5e_priv *priv)
+static void mlx5e_activate_channels(struct mlx5e_channels *chs)
 {
-	struct mlx5e_channels *chs = &priv->channels;
 	int i;
 
-	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
-	 * polling for inactive tx queues.
-	 */
-	netif_tx_stop_all_queues(priv->netdev);
-	netif_tx_disable(priv->netdev);
+	for (i = 0; i < chs->num; i++)
+		mlx5e_activate_channel(chs->c[i]);
+}
+
+static int mlx5e_wait_channels_min_rx_wqes(struct mlx5e_channels *chs)
+{
+	int err = 0;
+	int i;
+
+	for (i = 0; i < chs->num; i++) {
+		err = mlx5e_wait_for_min_rx_wqes(&chs->c[i]->rq);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static void mlx5e_deactivate_channels(struct mlx5e_channels *chs)
+{
+	int i;
+
+	for (i = 0; i < chs->num; i++)
+		mlx5e_deactivate_channel(chs->c[i]);
+}
+
+static void mlx5e_close_channels(struct mlx5e_channels *chs)
+{
+	int i;
 
 	for (i = 0; i < chs->num; i++)
 		mlx5e_close_channel(chs->c[i]);
 
-	kfree(priv->txq_to_sq_map);
 	kfree(chs->c);
 	chs->num = 0;
 }
@@ -2476,6 +2510,43 @@ static void mlx5e_netdev_set_tcs(struct net_device *netdev)
 		netdev_set_tc_queue(netdev, tc, nch, 0);
 }
 
+static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
+{
+	struct mlx5e_channel *c;
+	struct mlx5e_txqsq *sq;
+	int i, tc;
+
+	for (i = 0; i < priv->channels.num; i++)
+		for (tc = 0; tc < priv->profile->max_tc; tc++)
+			priv->channel_tc2txq[i][tc] = i + tc * priv->channels.num;
+
+	for (i = 0; i < priv->channels.num; i++) {
+		c = priv->channels.c[i];
+		for (tc = 0; tc < c->num_tc; tc++) {
+			sq = &c->sq[tc];
+			priv->txq2sq[sq->txq_ix] = sq;
+		}
+	}
+}
+
+static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
+{
+	mlx5e_build_channels_tx_maps(priv);
+	mlx5e_activate_channels(&priv->channels);
+	netif_tx_start_all_queues(priv->netdev);
+	mlx5e_wait_channels_min_rx_wqes(&priv->channels);
+}
+
+static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
+{
+	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
+	 * polling for inactive tx queues.
+	 */
+	netif_tx_stop_all_queues(priv->netdev);
+	netif_tx_disable(priv->netdev);
+	mlx5e_deactivate_channels(&priv->channels);
+}
+
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -2492,13 +2563,11 @@ int mlx5e_open_locked(struct net_device *netdev)
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
 
 	err = mlx5e_open_channels(priv, &priv->channels);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
-			   __func__, err);
+	if (err)
 		goto err_clear_state_opened_flag;
-	}
 
 	mlx5e_refresh_tirs(priv, false);
+	mlx5e_activate_priv_channels(priv);
 	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
@@ -2514,7 +2583,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	return 0;
 
 err_close_channels:
-	mlx5e_close_channels(priv);
+	mlx5e_close_channels(&priv->channels);
 err_clear_state_opened_flag:
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 	return err;
@@ -2551,7 +2620,8 @@ int mlx5e_close_locked(struct net_device *netdev)
 	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
 	mlx5e_redirect_rqts_to_drop(priv);
-	mlx5e_close_channels(priv);
+	mlx5e_deactivate_priv_channels(priv);
+	mlx5e_close_channels(&priv->channels);
 
 	return 0;
 }
@@ -3360,7 +3430,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 	netdev_err(dev, "TX timeout detected\n");
 
 	for (i = 0; i < priv->channels.num * priv->params.num_tc; i++) {
-		struct mlx5e_txqsq *sq = priv->txq_to_sq_map[i];
+		struct mlx5e_txqsq *sq = priv->txq2sq[i];
 
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 20f71b55651e..42743b114bcf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -103,7 +103,7 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		channel_ix = reciprocal_scale(channel_ix,
 					      priv->params.num_channels);
 
-	return priv->channeltc_to_txq_map[channel_ix][up];
+	return priv->channel_tc2txq[channel_ix][up];
 }
 
 static inline int mlx5e_skb_l2_header_offset(struct sk_buff *skb)
@@ -339,7 +339,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5e_txqsq *sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
+	struct mlx5e_txqsq *sq = priv->txq2sq[skb_get_queue_mapping(skb)];
 
 	return mlx5e_sq_xmit(sq, skb);
 }
-- 
2.11.0
