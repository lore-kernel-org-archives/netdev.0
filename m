From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/14] net/mlx5e: Introduce mlx5e_channels
Date: Mon, 27 Mar 2017 23:48:59 +0300
Message-ID: <20170327204910.20287-4-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44888 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752260AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have a dedicated "channels" handler that will serve as channels
(RQs/SQs/etc..) holder to help with separating channels/parameters
operations, for the downstream fail-safe configuration flow, where we will
create a new instance of mlx5e_channels with the new requested parameters
and switch to the new channels on the fly.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  9 ++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 27 +++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 86 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 14 ++--
 4 files changed, 71 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index bace9233dc1f..b00c6688ddcf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -560,6 +560,11 @@ struct mlx5e_channel {
 	int                        cpu;
 };
 
+struct mlx5e_channels {
+	struct mlx5e_channel **c;
+	unsigned int           num;
+};
+
 enum mlx5e_traffic_types {
 	MLX5E_TT_IPV4_TCP,
 	MLX5E_TT_IPV6_TCP,
@@ -736,7 +741,7 @@ struct mlx5e_priv {
 	struct mutex               state_lock; /* Protects Interface state */
 	struct mlx5e_rq            drop_rq;
 
-	struct mlx5e_channel     **channel;
+	struct mlx5e_channels      channels;
 	u32                        tisn[MLX5E_MAX_NUM_TC];
 	struct mlx5e_rqt           indir_rqt;
 	struct mlx5e_tir           indir_tir[MLX5E_NUM_INDIR_TIRS];
@@ -836,7 +841,7 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
-int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd);
+int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd);
 
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz, int ix);
 void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index a004a5a1a4c2..2e54a6564d86 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -152,12 +152,9 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 }
 
 #define MLX5E_NUM_Q_CNTRS(priv) (NUM_Q_COUNTERS * (!!priv->q_counter))
-#define MLX5E_NUM_RQ_STATS(priv) \
-	(NUM_RQ_STATS * priv->params.num_channels * \
-	 test_bit(MLX5E_STATE_OPENED, &priv->state))
+#define MLX5E_NUM_RQ_STATS(priv) (NUM_RQ_STATS * (priv)->channels.num)
 #define MLX5E_NUM_SQ_STATS(priv) \
-	(NUM_SQ_STATS * priv->params.num_channels * priv->params.num_tc * \
-	 test_bit(MLX5E_STATE_OPENED, &priv->state))
+	(NUM_SQ_STATS * (priv)->channels.num * (priv)->params.num_tc)
 #define MLX5E_NUM_PFC_COUNTERS(priv) \
 	((mlx5e_query_global_pause_combined(priv) + hweight8(mlx5e_query_pfc_combined(priv))) * \
 	  NUM_PPORT_PER_PRIO_PFC_COUNTERS)
@@ -262,13 +259,13 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		return;
 
 	/* per channel counters */
-	for (i = 0; i < priv->params.num_channels; i++)
+	for (i = 0; i < priv->channels.num; i++)
 		for (j = 0; j < NUM_RQ_STATS; j++)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
 				rq_stats_desc[j].format, i);
 
 	for (tc = 0; tc < priv->params.num_tc; tc++)
-		for (i = 0; i < priv->params.num_channels; i++)
+		for (i = 0; i < priv->channels.num; i++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				sprintf(data + (idx++) * ETH_GSTRING_LEN,
 					sq_stats_desc[j].format,
@@ -303,6 +300,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_channels *channels;
 	struct mlx5_priv *mlx5_priv;
 	int i, j, tc, prio, idx = 0;
 	unsigned long pfc_combined;
@@ -313,6 +311,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_update_stats(priv);
+	channels = &priv->channels;
 	mutex_unlock(&priv->state_lock);
 
 	for (i = 0; i < NUM_SW_COUNTERS; i++)
@@ -382,16 +381,16 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		return;
 
 	/* per channel counters */
-	for (i = 0; i < priv->params.num_channels; i++)
+	for (i = 0; i < channels->num; i++)
 		for (j = 0; j < NUM_RQ_STATS; j++)
 			data[idx++] =
-			       MLX5E_READ_CTR64_CPU(&priv->channel[i]->rq.stats,
+			       MLX5E_READ_CTR64_CPU(&channels->c[i]->rq.stats,
 						    rq_stats_desc, j);
 
 	for (tc = 0; tc < priv->params.num_tc; tc++)
-		for (i = 0; i < priv->params.num_channels; i++)
+		for (i = 0; i < channels->num; i++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
-				data[idx++] = MLX5E_READ_CTR64_CPU(&priv->channel[i]->sq[tc].stats,
+				data[idx++] = MLX5E_READ_CTR64_CPU(&channels->c[i]->sq[tc].stats,
 								   sq_stats_desc, j);
 }
 
@@ -628,7 +627,6 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5e_channel *c;
 	bool restart =
 		!!coal->use_adaptive_rx_coalesce != priv->params.rx_am_enabled;
 	bool was_opened;
@@ -654,9 +652,8 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 
 	if (!was_opened || restart)
 		goto out;
-
-	for (i = 0; i < priv->params.num_channels; ++i) {
-		c = priv->channel[i];
+	for (i = 0; i < priv->channels.num; ++i) {
+		struct mlx5e_channel *c = priv->channels.c[i];
 
 		for (tc = 0; tc < c->num_tc; tc++) {
 			mlx5_core_modify_cq_moderation(mdev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f0eff5e30729..920e72ae992e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -180,8 +180,10 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 	int i, j;
 
 	memset(s, 0, sizeof(*s));
-	for (i = 0; i < priv->params.num_channels; i++) {
-		rq_stats = &priv->channel[i]->rq.stats;
+	for (i = 0; i < priv->channels.num; i++) {
+		struct mlx5e_channel *c = priv->channels.c[i];
+
+		rq_stats = &c->rq.stats;
 
 		s->rx_packets	+= rq_stats->packets;
 		s->rx_bytes	+= rq_stats->bytes;
@@ -204,7 +206,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_cache_busy  += rq_stats->cache_busy;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
-			sq_stats = &priv->channel[i]->sq[j].stats;
+			sq_stats = &c->sq[j].stats;
 
 			s->tx_packets		+= sq_stats->packets;
 			s->tx_bytes		+= sq_stats->bytes;
@@ -1067,7 +1069,7 @@ static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	txq_ix = c->ix + tc * priv->params.num_channels;
+	txq_ix = c->ix + tc * priv->channels.num;
 	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
 	priv->txq_to_sq_map[txq_ix] = sq;
 
@@ -1235,7 +1237,7 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	if (err)
 		goto err_free_txqsq;
 
-	txq_ix = c->ix + tc * priv->params.num_channels;
+	txq_ix = c->ix + tc * priv->channels.num;
 	tx_rate = priv->tx_rates[txq_ix];
 	if (tx_rate)
 		mlx5e_set_sq_maxrate(priv->netdev, sq, tx_rate);
@@ -1603,8 +1605,7 @@ static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
 	int i;
 
 	for (i = 0; i < priv->profile->max_tc; i++)
-		priv->channeltc_to_txq_map[ix][i] =
-			ix + i * priv->params.num_channels;
+		priv->channeltc_to_txq_map[ix][i] = ix + i * priv->channels.num;
 }
 
 static int mlx5e_set_sq_maxrate(struct net_device *dev,
@@ -1977,35 +1978,31 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_chan
 	mlx5e_build_ico_cq_param(priv, &cparam->icosq_cq, icosq_log_wq_sz);
 }
 
-static int mlx5e_open_channels(struct mlx5e_priv *priv)
+static int mlx5e_open_channels(struct mlx5e_priv *priv, struct mlx5e_channels *chs)
 {
 	struct mlx5e_channel_param *cparam;
-	int nch = priv->params.num_channels;
 	int err = -ENOMEM;
 	int i;
 	int j;
 
-	priv->channel = kcalloc(nch, sizeof(struct mlx5e_channel *),
-				GFP_KERNEL);
+	chs->num = priv->params.num_channels;
 
-	priv->txq_to_sq_map = kcalloc(nch * priv->params.num_tc,
+	chs->c = kcalloc(chs->num, sizeof(struct mlx5e_channel *), GFP_KERNEL);
+	priv->txq_to_sq_map = kcalloc(chs->num * priv->params.num_tc,
 				      sizeof(struct mlx5e_sq *), GFP_KERNEL);
-
 	cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
-
-	if (!priv->channel || !priv->txq_to_sq_map || !cparam)
+	if (!chs->c || !priv->txq_to_sq_map || !cparam)
 		goto err_free_txq_to_sq_map;
 
 	mlx5e_build_channel_param(priv, cparam);
-
-	for (i = 0; i < nch; i++) {
-		err = mlx5e_open_channel(priv, i, cparam, &priv->channel[i]);
+	for (i = 0; i < chs->num; i++) {
+		err = mlx5e_open_channel(priv, i, cparam, &chs->c[i]);
 		if (err)
 			goto err_close_channels;
 	}
 
-	for (j = 0; j < nch; j++) {
-		err = mlx5e_wait_for_min_rx_wqes(&priv->channel[j]->rq);
+	for (j = 0; j < chs->num; j++) {
+		err = mlx5e_wait_for_min_rx_wqes(&chs->c[j]->rq);
 		if (err)
 			goto err_close_channels;
 	}
@@ -2020,18 +2017,19 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
 
 err_close_channels:
 	for (i--; i >= 0; i--)
-		mlx5e_close_channel(priv->channel[i]);
+		mlx5e_close_channel(chs->c[i]);
 
 err_free_txq_to_sq_map:
 	kfree(priv->txq_to_sq_map);
-	kfree(priv->channel);
+	kfree(chs->c);
 	kfree(cparam);
-
+	chs->num = 0;
 	return err;
 }
 
 static void mlx5e_close_channels(struct mlx5e_priv *priv)
 {
+	struct mlx5e_channels *chs = &priv->channels;
 	int i;
 
 	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
@@ -2040,11 +2038,12 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 	netif_tx_stop_all_queues(priv->netdev);
 	netif_tx_disable(priv->netdev);
 
-	for (i = 0; i < priv->params.num_channels; i++)
-		mlx5e_close_channel(priv->channel[i]);
+	for (i = 0; i < chs->num; i++)
+		mlx5e_close_channel(chs->c[i]);
 
 	kfree(priv->txq_to_sq_map);
-	kfree(priv->channel);
+	kfree(chs->c);
+	chs->num = 0;
 }
 
 static int mlx5e_rx_hash_fn(int hfunc)
@@ -2078,7 +2077,7 @@ static void mlx5e_fill_indir_rqt_rqns(struct mlx5e_priv *priv, void *rqtc)
 
 		ix = priv->params.indirection_rqt[ix];
 		rqn = test_bit(MLX5E_STATE_OPENED, &priv->state) ?
-				priv->channel[ix]->rq.rqn :
+				priv->channels.c[ix]->rq.rqn :
 				priv->drop_rq.rqn;
 		MLX5_SET(rqtc, rqtc, rq_num[i], rqn);
 	}
@@ -2088,7 +2087,7 @@ static void mlx5e_fill_direct_rqt_rqn(struct mlx5e_priv *priv, void *rqtc,
 				      int ix)
 {
 	u32 rqn = test_bit(MLX5E_STATE_OPENED, &priv->state) ?
-			priv->channel[ix]->rq.rqn :
+			priv->channels.c[ix]->rq.rqn :
 			priv->drop_rq.rqn;
 
 	MLX5_SET(rqtc, rqtc, rq_num[0], rqn);
@@ -2461,7 +2460,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
 
-	err = mlx5e_open_channels(priv);
+	err = mlx5e_open_channels(priv, &priv->channels);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
 			   __func__, err);
@@ -2815,16 +2814,13 @@ void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv)
 		mlx5e_destroy_tir(priv->mdev, &priv->direct_tir[i]);
 }
 
-int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd)
+int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 {
 	int err = 0;
 	int i;
 
-	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
-		return 0;
-
-	for (i = 0; i < priv->params.num_channels; i++) {
-		err = mlx5e_modify_rq_vsd(&priv->channel[i]->rq, vsd);
+	for (i = 0; i < chs->num; i++) {
+		err = mlx5e_modify_rq_vsd(&chs->c[i]->rq, vsd);
 		if (err)
 			return err;
 	}
@@ -3029,15 +3025,19 @@ static int set_feature_rx_all(struct net_device *netdev, bool enable)
 static int set_feature_rx_vlan(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int err;
+	int err = 0;
 
 	mutex_lock(&priv->state_lock);
 
 	priv->params.vlan_strip_disable = !enable;
-	err = mlx5e_modify_rqs_vsd(priv, !enable);
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		goto unlock;
+
+	err = mlx5e_modify_channels_vsd(&priv->channels, !enable);
 	if (err)
 		priv->params.vlan_strip_disable = enable;
 
+unlock:
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -3334,7 +3334,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 
 	netdev_err(dev, "TX timeout detected\n");
 
-	for (i = 0; i < priv->params.num_channels * priv->params.num_tc; i++) {
+	for (i = 0; i < priv->channels.num * priv->params.num_tc; i++) {
 		struct mlx5e_txqsq *sq = priv->txq_to_sq_map[i];
 
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
@@ -3401,8 +3401,8 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	/* exchanging programs w/o reset, we update ref counts on behalf
 	 * of the channels RQs here.
 	 */
-	for (i = 0; i < priv->params.num_channels; i++) {
-		struct mlx5e_channel *c = priv->channel[i];
+	for (i = 0; i < priv->channels.num; i++) {
+		struct mlx5e_channel *c = priv->channels.c[i];
 
 		clear_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
 		napi_synchronize(&c->napi);
@@ -3451,10 +3451,12 @@ static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 static void mlx5e_netpoll(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_channels *chs = &priv->channels;
+
 	int i;
 
-	for (i = 0; i < priv->params.num_channels; i++)
-		napi_schedule(&priv->channel[i]->napi);
+	for (i = 0; i < chs->num; i++)
+		napi_schedule(&chs->c[i]->napi);
 }
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index f621373bd7a5..0515b7f7d11f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -102,14 +102,16 @@ static void mlx5e_rep_update_sw_counters(struct mlx5e_priv *priv)
 	int i, j;
 
 	memset(s, 0, sizeof(*s));
-	for (i = 0; i < priv->params.num_channels; i++) {
-		rq_stats = &priv->channel[i]->rq.stats;
+	for (i = 0; i < priv->channels.num; i++) {
+		struct mlx5e_channel *c = priv->channels.c[i];
+
+		rq_stats = &c->rq.stats;
 
 		s->rx_packets	+= rq_stats->packets;
 		s->rx_bytes	+= rq_stats->bytes;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
-			sq_stats = &priv->channel[i]->sq[j].stats;
+			sq_stats = &c->sq[j].stats;
 
 			s->tx_packets		+= sq_stats->packets;
 			s->tx_bytes		+= sq_stats->bytes;
@@ -190,12 +192,12 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 	int n, tc, err, num_sqs = 0;
 	u16 *sqs;
 
-	sqs = kcalloc(priv->params.num_channels * priv->params.num_tc, sizeof(u16), GFP_KERNEL);
+	sqs = kcalloc(priv->channels.num * priv->params.num_tc, sizeof(u16), GFP_KERNEL);
 	if (!sqs)
 		return -ENOMEM;
 
-	for (n = 0; n < priv->params.num_channels; n++) {
-		c = priv->channel[n];
+	for (n = 0; n < priv->channels.num; n++) {
+		c = priv->channels.c[n];
 		for (tc = 0; tc < c->num_tc; tc++)
 			sqs[num_sqs++] = c->sq[tc].sqn;
 	}
-- 
2.11.0
