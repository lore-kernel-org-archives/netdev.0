From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/14] net/mlx5e: Isolate open_channels from priv->params
Date: Mon, 27 Mar 2017 23:49:03 +0300
Message-ID: <20170327204910.20287-8-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44890 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752238AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to have a clean separation between channels resources creation
flows and current active mlx5e netdev parameters, make sure each
resource creation function do not access priv->params, and only works
with on a new fresh set of parameters.

For this we add "new" mlx5e_params field to mlx5e_channels structure
and use it down the road to mlx5e_open_{cq,rq,sq} and so on.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  22 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 119 +++---
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 448 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  61 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   7 +-
 8 files changed, 328 insertions(+), 341 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f1895ebe7fe5..007f91f54fda 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -182,15 +182,15 @@ enum mlx5e_priv_flag {
 	MLX5E_PFLAG_RX_CQE_COMPRESS = (1 << 1),
 };
 
-#define MLX5E_SET_PFLAG(priv, pflag, enable)			\
+#define MLX5E_SET_PFLAG(params, pflag, enable)			\
 	do {							\
 		if (enable)					\
-			(priv)->params.pflags |= (pflag);	\
+			(params)->pflags |= (pflag);		\
 		else						\
-			(priv)->params.pflags &= ~(pflag);	\
+			(params)->pflags &= ~(pflag);		\
 	} while (0)
 
-#define MLX5E_GET_PFLAG(priv, pflag) (!!((priv)->params.pflags & (pflag)))
+#define MLX5E_GET_PFLAG(params, pflag) (!!((params)->pflags & (pflag)))
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
@@ -213,7 +213,6 @@ struct mlx5e_params {
 	bool rx_cqe_compress_def;
 	struct mlx5e_cq_moder rx_cq_moderation;
 	struct mlx5e_cq_moder tx_cq_moderation;
-	u16 min_rx_wqes;
 	bool lro_en;
 	u32 lro_wqe_sz;
 	u16 tx_max_inline;
@@ -225,6 +224,7 @@ struct mlx5e_params {
 	bool rx_am_enabled;
 	u32 lro_timeout;
 	u32 pflags;
+	struct bpf_prog *xdp_prog;
 };
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
@@ -357,7 +357,6 @@ struct mlx5e_txqsq {
 	/* control path */
 	struct mlx5_wq_ctrl        wq_ctrl;
 	struct mlx5e_channel      *channel;
-	int                        tc;
 	int                        txq_ix;
 	u32                        rate_limit;
 } ____cacheline_aligned_in_smp;
@@ -564,6 +563,7 @@ struct mlx5e_channel {
 struct mlx5e_channels {
 	struct mlx5e_channel **c;
 	unsigned int           num;
+	struct mlx5e_params    params;
 };
 
 enum mlx5e_traffic_types {
@@ -735,7 +735,6 @@ struct mlx5e_priv {
 	/* priv data path fields - start */
 	struct mlx5e_txqsq *txq2sq[MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC];
 	int channel_tc2txq[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
-	struct bpf_prog *xdp_prog;
 	/* priv data path fields - end */
 
 	unsigned long              state;
@@ -752,7 +751,6 @@ struct mlx5e_priv {
 	struct mlx5e_flow_steering fs;
 	struct mlx5e_vxlan_db      vxlan;
 
-	struct mlx5e_params        params;
 	struct workqueue_struct    *wq;
 	struct work_struct         update_carrier_work;
 	struct work_struct         set_rx_mode_work;
@@ -857,8 +855,9 @@ struct mlx5e_redirect_rqt_param {
 
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz,
 		       struct mlx5e_redirect_rqt_param rrp);
-void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
-				    enum mlx5e_traffic_types tt);
+void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_params *params,
+				    enum mlx5e_traffic_types tt,
+				    void *tirc);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
@@ -869,7 +868,8 @@ int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 
 void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 				 u8 cq_period_mode);
-void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type);
+void mlx5e_set_rq_type_params(struct mlx5_core_dev *mdev,
+			      struct mlx5e_params *params, u8 rq_type);
 
 static inline
 struct mlx5e_tx_wqe *mlx5e_post_nop(struct mlx5_wq_cyc *wq, u32 sqn, u16 *pc)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 37e66eef6fb5..485c23b59f93 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -111,7 +111,7 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		/* Reset CQE compression to Admin default */
-		mlx5e_modify_rx_cqe_compression_locked(priv, priv->params.rx_cqe_compress_def);
+		mlx5e_modify_rx_cqe_compression_locked(priv, priv->channels.params.rx_cqe_compress_def);
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 5159358a242d..b2cd0ef7921e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -154,7 +154,7 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 #define MLX5E_NUM_Q_CNTRS(priv) (NUM_Q_COUNTERS * (!!priv->q_counter))
 #define MLX5E_NUM_RQ_STATS(priv) (NUM_RQ_STATS * (priv)->channels.num)
 #define MLX5E_NUM_SQ_STATS(priv) \
-	(NUM_SQ_STATS * (priv)->channels.num * (priv)->params.num_tc)
+	(NUM_SQ_STATS * (priv)->channels.num * (priv)->channels.params.num_tc)
 #define MLX5E_NUM_PFC_COUNTERS(priv) \
 	((mlx5e_query_global_pause_combined(priv) + hweight8(mlx5e_query_pfc_combined(priv))) * \
 	  NUM_PPORT_PER_PRIO_PFC_COUNTERS)
@@ -264,7 +264,7 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
 				rq_stats_desc[j].format, i);
 
-	for (tc = 0; tc < priv->params.num_tc; tc++)
+	for (tc = 0; tc < priv->channels.params.num_tc; tc++)
 		for (i = 0; i < priv->channels.num; i++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				sprintf(data + (idx++) * ETH_GSTRING_LEN,
@@ -387,7 +387,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 			       MLX5E_READ_CTR64_CPU(&channels->c[i]->rq.stats,
 						    rq_stats_desc, j);
 
-	for (tc = 0; tc < priv->params.num_tc; tc++)
+	for (tc = 0; tc < priv->channels.params.num_tc; tc++)
 		for (i = 0; i < channels->num; i++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				data[idx++] = MLX5E_READ_CTR64_CPU(&channels->c[i]->sq[tc].stats,
@@ -405,8 +405,8 @@ static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
 	if (rq_wq_type != MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		return num_wqe;
 
-	stride_size = 1 << priv->params.mpwqe_log_stride_sz;
-	num_strides = 1 << priv->params.mpwqe_log_num_strides;
+	stride_size = 1 << priv->channels.params.mpwqe_log_stride_sz;
+	num_strides = 1 << priv->channels.params.mpwqe_log_num_strides;
 	wqe_size = stride_size * num_strides;
 
 	packets_per_wqe = wqe_size /
@@ -426,8 +426,8 @@ static u32 mlx5e_packets_to_rx_wqes(struct mlx5e_priv *priv, int rq_wq_type,
 	if (rq_wq_type != MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		return num_packets;
 
-	stride_size = 1 << priv->params.mpwqe_log_stride_sz;
-	num_strides = 1 << priv->params.mpwqe_log_num_strides;
+	stride_size = 1 << priv->channels.params.mpwqe_log_stride_sz;
+	num_strides = 1 << priv->channels.params.mpwqe_log_num_strides;
 	wqe_size = stride_size * num_strides;
 
 	num_packets = (1 << order_base_2(num_packets));
@@ -442,26 +442,25 @@ static void mlx5e_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int rq_wq_type = priv->params.rq_wq_type;
+	int rq_wq_type = priv->channels.params.rq_wq_type;
 
 	param->rx_max_pending = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
 							 1 << mlx5_max_log_rq_size(rq_wq_type));
 	param->tx_max_pending = 1 << MLX5E_PARAMS_MAXIMUM_LOG_SQ_SIZE;
 	param->rx_pending = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
-						     1 << priv->params.log_rq_size);
-	param->tx_pending     = 1 << priv->params.log_sq_size;
+						     1 << priv->channels.params.log_rq_size);
+	param->tx_pending     = 1 << priv->channels.params.log_sq_size;
 }
 
 static int mlx5e_set_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	bool was_opened;
-	int rq_wq_type = priv->params.rq_wq_type;
+	int rq_wq_type = priv->channels.params.rq_wq_type;
 	u32 rx_pending_wqes;
+	bool was_opened;
 	u32 min_rq_size;
 	u32 max_rq_size;
-	u16 min_rx_wqes;
 	u8 log_rq_size;
 	u8 log_sq_size;
 	u32 num_mtts;
@@ -499,7 +498,7 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	}
 
 	num_mtts = MLX5E_REQUIRED_MTTS(rx_pending_wqes);
-	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
+	if (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
 	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
 		netdev_info(dev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
 			    __func__, param->rx_pending);
@@ -521,11 +520,9 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 
 	log_rq_size = order_base_2(rx_pending_wqes);
 	log_sq_size = order_base_2(param->tx_pending);
-	min_rx_wqes = mlx5_min_rx_wqes(rq_wq_type, rx_pending_wqes);
 
-	if (log_rq_size == priv->params.log_rq_size &&
-	    log_sq_size == priv->params.log_sq_size &&
-	    min_rx_wqes == priv->params.min_rx_wqes)
+	if (log_rq_size == priv->channels.params.log_rq_size &&
+	    log_sq_size == priv->channels.params.log_sq_size)
 		return 0;
 
 	mutex_lock(&priv->state_lock);
@@ -534,9 +531,8 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	if (was_opened)
 		mlx5e_close_locked(dev);
 
-	priv->params.log_rq_size = log_rq_size;
-	priv->params.log_sq_size = log_sq_size;
-	priv->params.min_rx_wqes = min_rx_wqes;
+	priv->channels.params.log_rq_size = log_rq_size;
+	priv->channels.params.log_sq_size = log_sq_size;
 
 	if (was_opened)
 		err = mlx5e_open_locked(dev);
@@ -552,7 +548,7 @@ static void mlx5e_get_channels(struct net_device *dev,
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	ch->max_combined   = priv->profile->max_nch(priv->mdev);
-	ch->combined_count = priv->params.num_channels;
+	ch->combined_count = priv->channels.params.num_channels;
 }
 
 static int mlx5e_set_channels(struct net_device *dev,
@@ -570,7 +566,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (priv->params.num_channels == count)
+	if (priv->channels.params.num_channels == count)
 		return 0;
 
 	mutex_lock(&priv->state_lock);
@@ -583,8 +579,8 @@ static int mlx5e_set_channels(struct net_device *dev,
 	if (arfs_enabled)
 		mlx5e_arfs_disable(priv);
 
-	priv->params.num_channels = count;
-	mlx5e_build_default_indir_rqt(priv->mdev, priv->params.indirection_rqt,
+	priv->channels.params.num_channels = count;
+	mlx5e_build_default_indir_rqt(priv->mdev, priv->channels.params.indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (was_opened)
@@ -613,11 +609,11 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 	if (!MLX5_CAP_GEN(priv->mdev, cq_moderation))
 		return -EOPNOTSUPP;
 
-	coal->rx_coalesce_usecs       = priv->params.rx_cq_moderation.usec;
-	coal->rx_max_coalesced_frames = priv->params.rx_cq_moderation.pkts;
-	coal->tx_coalesce_usecs       = priv->params.tx_cq_moderation.usec;
-	coal->tx_max_coalesced_frames = priv->params.tx_cq_moderation.pkts;
-	coal->use_adaptive_rx_coalesce = priv->params.rx_am_enabled;
+	coal->rx_coalesce_usecs       = priv->channels.params.rx_cq_moderation.usec;
+	coal->rx_max_coalesced_frames = priv->channels.params.rx_cq_moderation.pkts;
+	coal->tx_coalesce_usecs       = priv->channels.params.tx_cq_moderation.usec;
+	coal->tx_max_coalesced_frames = priv->channels.params.tx_cq_moderation.pkts;
+	coal->use_adaptive_rx_coalesce = priv->channels.params.rx_am_enabled;
 
 	return 0;
 }
@@ -628,7 +624,7 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	bool restart =
-		!!coal->use_adaptive_rx_coalesce != priv->params.rx_am_enabled;
+		!!coal->use_adaptive_rx_coalesce != priv->channels.params.rx_am_enabled;
 	bool was_opened;
 	int err = 0;
 	int tc;
@@ -642,13 +638,13 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened && restart) {
 		mlx5e_close_locked(netdev);
-		priv->params.rx_am_enabled = !!coal->use_adaptive_rx_coalesce;
+		priv->channels.params.rx_am_enabled = !!coal->use_adaptive_rx_coalesce;
 	}
 
-	priv->params.tx_cq_moderation.usec = coal->tx_coalesce_usecs;
-	priv->params.tx_cq_moderation.pkts = coal->tx_max_coalesced_frames;
-	priv->params.rx_cq_moderation.usec = coal->rx_coalesce_usecs;
-	priv->params.rx_cq_moderation.pkts = coal->rx_max_coalesced_frames;
+	priv->channels.params.tx_cq_moderation.usec = coal->tx_coalesce_usecs;
+	priv->channels.params.tx_cq_moderation.pkts = coal->tx_max_coalesced_frames;
+	priv->channels.params.rx_cq_moderation.usec = coal->rx_coalesce_usecs;
+	priv->channels.params.rx_cq_moderation.pkts = coal->rx_max_coalesced_frames;
 
 	if (!was_opened || restart)
 		goto out;
@@ -965,7 +961,7 @@ static u32 mlx5e_get_rxfh_key_size(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	return sizeof(priv->params.toeplitz_hash_key);
+	return sizeof(priv->channels.params.toeplitz_hash_key);
 }
 
 static u32 mlx5e_get_rxfh_indir_size(struct net_device *netdev)
@@ -979,15 +975,15 @@ static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
 	if (indir)
-		memcpy(indir, priv->params.indirection_rqt,
-		       sizeof(priv->params.indirection_rqt));
+		memcpy(indir, priv->channels.params.indirection_rqt,
+		       sizeof(priv->channels.params.indirection_rqt));
 
 	if (key)
-		memcpy(key, priv->params.toeplitz_hash_key,
-		       sizeof(priv->params.toeplitz_hash_key));
+		memcpy(key, priv->channels.params.toeplitz_hash_key,
+		       sizeof(priv->channels.params.toeplitz_hash_key));
 
 	if (hfunc)
-		*hfunc = priv->params.rss_hfunc;
+		*hfunc = priv->channels.params.rss_hfunc;
 
 	return 0;
 }
@@ -1003,7 +999,7 @@ static void mlx5e_modify_tirs_hash(struct mlx5e_priv *priv, void *in, int inlen)
 
 	for (tt = 0; tt < MLX5E_NUM_INDIR_TIRS; tt++) {
 		memset(tirc, 0, ctxlen);
-		mlx5e_build_indir_tir_ctx_hash(priv, tirc, tt);
+		mlx5e_build_indir_tir_ctx_hash(&priv->channels.params, tt, tirc);
 		mlx5_core_modify_tir(mdev, priv->indir_tir[tt].tirn, in, inlen);
 	}
 }
@@ -1028,20 +1024,20 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 	mutex_lock(&priv->state_lock);
 
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE &&
-	    hfunc != priv->params.rss_hfunc) {
-		priv->params.rss_hfunc = hfunc;
+	    hfunc != priv->channels.params.rss_hfunc) {
+		priv->channels.params.rss_hfunc = hfunc;
 		hash_changed = true;
 	}
 
 	if (indir) {
-		memcpy(priv->params.indirection_rqt, indir,
-		       sizeof(priv->params.indirection_rqt));
+		memcpy(priv->channels.params.indirection_rqt, indir,
+		       sizeof(priv->channels.params.indirection_rqt));
 
 		if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
 			u32 rqtn = priv->indir_rqt.rqtn;
 			struct mlx5e_redirect_rqt_param rrp = {
 				.is_rss = true,
-				.rss.hfunc = priv->params.rss_hfunc,
+				.rss.hfunc = priv->channels.params.rss_hfunc,
 				.rss.channels  = &priv->channels
 			};
 
@@ -1050,10 +1046,10 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 	}
 
 	if (key) {
-		memcpy(priv->params.toeplitz_hash_key, key,
-		       sizeof(priv->params.toeplitz_hash_key));
+		memcpy(priv->channels.params.toeplitz_hash_key, key,
+		       sizeof(priv->channels.params.toeplitz_hash_key));
 		hash_changed = hash_changed ||
-			       priv->params.rss_hfunc == ETH_RSS_HASH_TOP;
+			       priv->channels.params.rss_hfunc == ETH_RSS_HASH_TOP;
 	}
 
 	if (hash_changed)
@@ -1074,7 +1070,7 @@ static int mlx5e_get_rxnfc(struct net_device *netdev,
 
 	switch (info->cmd) {
 	case ETHTOOL_GRXRINGS:
-		info->data = priv->params.num_channels;
+		info->data = priv->channels.params.num_channels;
 		break;
 	case ETHTOOL_GRXCLSRLCNT:
 		info->rule_cnt = priv->fs.ethtool.tot_num_rules;
@@ -1102,7 +1098,7 @@ static int mlx5e_get_tunable(struct net_device *dev,
 
 	switch (tuna->id) {
 	case ETHTOOL_TX_COPYBREAK:
-		*(u32 *)data = priv->params.tx_max_inline;
+		*(u32 *)data = priv->channels.params.tx_max_inline;
 		break;
 	default:
 		err = -EINVAL;
@@ -1136,7 +1132,7 @@ static int mlx5e_set_tunable(struct net_device *dev,
 		if (was_opened)
 			mlx5e_close_locked(dev);
 
-		priv->params.tx_max_inline = val;
+		priv->channels.params.tx_max_inline = val;
 
 		if (was_opened)
 			err = mlx5e_open_locked(dev);
@@ -1455,7 +1451,7 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 	rx_cq_period_mode = enable ?
 		MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
 		MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
-	rx_mode_changed = rx_cq_period_mode != priv->params.rx_cq_period_mode;
+	rx_mode_changed = rx_cq_period_mode != priv->channels.params.rx_cq_period_mode;
 
 	if (rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE &&
 	    !MLX5_CAP_GEN(mdev, cq_period_start_from_cqe))
@@ -1468,7 +1464,7 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 	if (reset)
 		mlx5e_close_locked(netdev);
 
-	mlx5e_set_rx_cq_mode_params(&priv->params, rx_cq_period_mode);
+	mlx5e_set_rx_cq_mode_params(&priv->channels.params, rx_cq_period_mode);
 
 	if (reset)
 		err = mlx5e_open_locked(netdev);
@@ -1491,8 +1487,9 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 	}
 
 	mlx5e_modify_rx_cqe_compression_locked(priv, enable);
-	priv->params.rx_cqe_compress_def = enable;
-	mlx5e_set_rq_type_params(priv, priv->params.rq_wq_type);
+	priv->channels.params.rx_cqe_compress_def = enable;
+	mlx5e_set_rq_type_params(priv->mdev, &priv->channels.params,
+				 priv->channels.params.rq_wq_type);
 
 	return 0;
 }
@@ -1504,7 +1501,7 @@ static int mlx5e_handle_pflag(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	bool enable = !!(wanted_flags & flag);
-	u32 changes = wanted_flags ^ priv->params.pflags;
+	u32 changes = wanted_flags ^ priv->channels.params.pflags;
 	int err;
 
 	if (!(changes & flag))
@@ -1517,7 +1514,7 @@ static int mlx5e_handle_pflag(struct net_device *netdev,
 		return err;
 	}
 
-	MLX5E_SET_PFLAG(priv, flag, enable);
+	MLX5E_SET_PFLAG(&priv->channels.params, flag, enable);
 	return 0;
 }
 
@@ -1546,7 +1543,7 @@ static u32 mlx5e_get_priv_flags(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	return priv->params.pflags;
+	return priv->channels.params.pflags;
 }
 
 static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d55fff0ba388..e73c97fea55c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -390,7 +390,7 @@ static int validate_flow(struct mlx5e_priv *priv,
 	if (fs->location >= MAX_NUM_OF_ETHTOOL_RULES)
 		return -EINVAL;
 
-	if (fs->ring_cookie >= priv->params.num_channels &&
+	if (fs->ring_cookie >= priv->channels.params.num_channels &&
 	    fs->ring_cookie != RX_CLS_FLOW_DISC)
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6be7c2367d41..cf8df1d3275e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -44,14 +44,11 @@
 struct mlx5e_rq_param {
 	u32			rqc[MLX5_ST_SZ_DW(rqc)];
 	struct mlx5_wq_param	wq;
-	bool			am_enabled;
 };
 
 struct mlx5e_sq_param {
 	u32                        sqc[MLX5_ST_SZ_DW(sqc)];
 	struct mlx5_wq_param       wq;
-	u16                        max_inline;
-	u8                         min_inline_mode;
 };
 
 struct mlx5e_cq_param {
@@ -78,49 +75,47 @@ static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
 		MLX5_CAP_ETH(mdev, reg_umr_sq);
 }
 
-void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
+void mlx5e_set_rq_type_params(struct mlx5_core_dev *mdev,
+			      struct mlx5e_params *params, u8 rq_type)
 {
-	priv->params.rq_wq_type = rq_type;
-	priv->params.lro_wqe_sz = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
-	switch (priv->params.rq_wq_type) {
+	params->rq_wq_type = rq_type;
+	params->lro_wqe_sz = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+	switch (params->rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		priv->params.log_rq_size = is_kdump_kernel() ?
+		params->log_rq_size = is_kdump_kernel() ?
 			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE_MPW :
 			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
-		priv->params.mpwqe_log_stride_sz =
-			MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) ?
-			MLX5_MPWRQ_CQE_CMPRS_LOG_STRIDE_SZ(priv->mdev) :
-			MLX5_MPWRQ_DEF_LOG_STRIDE_SZ(priv->mdev);
-		priv->params.mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
-			priv->params.mpwqe_log_stride_sz;
+		params->mpwqe_log_stride_sz =
+			MLX5E_GET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS) ?
+			MLX5_MPWRQ_CQE_CMPRS_LOG_STRIDE_SZ(mdev) :
+			MLX5_MPWRQ_DEF_LOG_STRIDE_SZ(mdev);
+		params->mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
+			params->mpwqe_log_stride_sz;
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
-		priv->params.log_rq_size = is_kdump_kernel() ?
+		params->log_rq_size = is_kdump_kernel() ?
 			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE :
 			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
 
 		/* Extra room needed for build_skb */
-		priv->params.lro_wqe_sz -= MLX5_RX_HEADROOM +
+		params->lro_wqe_sz -= MLX5_RX_HEADROOM +
 			SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	}
-	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
-					       BIT(priv->params.log_rq_size));
 
-	mlx5_core_info(priv->mdev,
-		       "MLX5E: StrdRq(%d) RqSz(%ld) StrdSz(%ld) RxCqeCmprss(%d)\n",
-		       priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ,
-		       BIT(priv->params.log_rq_size),
-		       BIT(priv->params.mpwqe_log_stride_sz),
-		       MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS));
+	mlx5_core_info(mdev, "MLX5E: StrdRq(%d) RqSz(%ld) StrdSz(%ld) RxCqeCmprss(%d)\n",
+		       params->rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ,
+		       BIT(params->log_rq_size),
+		       BIT(params->mpwqe_log_stride_sz),
+		       MLX5E_GET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS));
 }
 
-static void mlx5e_set_rq_priv_params(struct mlx5e_priv *priv)
+static void mlx5e_set_rq_params(struct mlx5_core_dev *mdev, struct mlx5e_params *params)
 {
-	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(priv->mdev) &&
-		    !priv->xdp_prog ?
+	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(mdev) &&
+		    !params->xdp_prog ?
 		    MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
 		    MLX5_WQ_TYPE_LINKED_LIST;
-	mlx5e_set_rq_type_params(priv, rq_type);
+	mlx5e_set_rq_type_params(mdev, params, rq_type);
 }
 
 static void mlx5e_update_carrier(struct mlx5e_priv *priv)
@@ -205,7 +200,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_cache_empty += rq_stats->cache_empty;
 		s->rx_cache_busy  += rq_stats->cache_busy;
 
-		for (j = 0; j < priv->params.num_tc; j++) {
+		for (j = 0; j < priv->channels.params.num_tc; j++) {
 			sq_stats = &c->sq[j].stats;
 
 			s->tx_packets		+= sq_stats->packets;
@@ -537,18 +532,19 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv,
 static int mlx5e_create_rq_umr_mkey(struct mlx5e_rq *rq)
 {
 	struct mlx5e_priv *priv = rq->priv;
-	u64 num_mtts = MLX5E_REQUIRED_MTTS(BIT(priv->params.log_rq_size));
+	u64 num_mtts = MLX5E_REQUIRED_MTTS(mlx5_wq_ll_get_size(&rq->wq));
 
 	return mlx5e_create_umr_mkey(priv, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
 }
 
 static int mlx5e_alloc_rq(struct mlx5e_channel *c,
-			  struct mlx5e_rq_param *param,
+			  struct mlx5e_params *params,
+			  struct mlx5e_rq_param *rqp,
 			  struct mlx5e_rq *rq)
 {
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
-	void *rqc = param->rqc;
+	void *rqc = rqp->rqc;
 	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
 	u32 byte_count;
 	u32 frag_sz;
@@ -557,9 +553,9 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	int err;
 	int i;
 
-	param->wq.db_numa_node = cpu_to_node(c->cpu);
+	rqp->wq.db_numa_node = cpu_to_node(c->cpu);
 
-	err = mlx5_wq_ll_create(mdev, &param->wq, rqc_wq, &rq->wq,
+	err = mlx5_wq_ll_create(mdev, &rqp->wq, rqc_wq, &rq->wq,
 				&rq->wq_ctrl);
 	if (err)
 		return err;
@@ -568,7 +564,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 
 	wq_sz = mlx5_wq_ll_get_size(&rq->wq);
 
-	rq->wq_type = priv->params.rq_wq_type;
+	rq->wq_type = params->rq_wq_type;
 	rq->pdev    = c->pdev;
 	rq->netdev  = c->netdev;
 	rq->tstamp  = &priv->tstamp;
@@ -576,7 +572,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
 
-	rq->xdp_prog = priv->xdp_prog ? bpf_prog_inc(priv->xdp_prog) : NULL;
+	rq->xdp_prog = params->xdp_prog ? bpf_prog_inc(params->xdp_prog) : NULL;
 	if (IS_ERR(rq->xdp_prog)) {
 		err = PTR_ERR(rq->xdp_prog);
 		rq->xdp_prog = NULL;
@@ -591,7 +587,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		rq->rx_headroom = MLX5_RX_HEADROOM;
 	}
 
-	switch (priv->params.rq_wq_type) {
+	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		if (mlx5e_is_vf_vport_rep(priv)) {
 			err = -EINVAL;
@@ -602,8 +598,8 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
-		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
-		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
+		rq->mpwqe_stride_sz = BIT(params->mpwqe_log_stride_sz);
+		rq->mpwqe_num_strides = BIT(params->mpwqe_log_num_strides);
 
 		rq->buff.wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
 		byte_count = rq->buff.wqe_sz;
@@ -633,8 +629,8 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
 
-		rq->buff.wqe_sz = (priv->params.lro_en) ?
-				priv->params.lro_wqe_sz :
+		rq->buff.wqe_sz = params->lro_en  ?
+				params->lro_wqe_sz :
 				MLX5E_SW2HW_MTU(priv->netdev->mtu);
 		byte_count = rq->buff.wqe_sz;
 
@@ -659,8 +655,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	}
 
 	INIT_WORK(&rq->am.work, mlx5e_rx_am_work);
-	rq->am.mode = priv->params.rx_cq_period_mode;
-
+	rq->am.mode = params->rx_cq_period_mode;
 	rq->page_cache.head = 0;
 	rq->page_cache.tail = 0;
 
@@ -702,7 +697,8 @@ static void mlx5e_free_rq(struct mlx5e_rq *rq)
 	mlx5_wq_destroy(&rq->wq_ctrl);
 }
 
-static int mlx5e_create_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
+static int mlx5e_create_rq(struct mlx5e_rq *rq,
+			   struct mlx5e_rq_param *param)
 {
 	struct mlx5e_priv *priv = rq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -726,7 +722,6 @@ static int mlx5e_create_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 
 	MLX5_SET(rqc,  rqc, cqn,		rq->cq.mcq.cqn);
 	MLX5_SET(rqc,  rqc, state,		MLX5_RQC_STATE_RST);
-	MLX5_SET(rqc,  rqc, vsd, priv->params.vlan_strip_disable);
 	MLX5_SET(wq,   wq,  log_wq_pg_sz,	rq->wq_ctrl.buf.page_shift -
 						MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq,  dbr_addr,		rq->wq_ctrl.db.dma);
@@ -812,16 +807,17 @@ static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 	struct mlx5e_channel *c = rq->channel;
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_wq_ll *wq = &rq->wq;
+	u16 min_wqes = mlx5_min_rx_wqes(rq->wq_type, mlx5_wq_ll_get_size(wq));
 
 	while (time_before(jiffies, exp_time)) {
-		if (wq->cur_sz >= priv->params.min_rx_wqes)
+		if (wq->cur_sz >= min_wqes)
 			return 0;
 
 		msleep(20);
 	}
 
 	netdev_warn(priv->netdev, "Failed to get min RX wqes on RQN[0x%x] wq cur_sz(%d) min_rx_wqes(%d)\n",
-		    rq->rqn, wq->cur_sz, priv->params.min_rx_wqes);
+		    rq->rqn, wq->cur_sz, min_wqes);
 	return -ETIMEDOUT;
 }
 
@@ -847,12 +843,13 @@ static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
 }
 
 static int mlx5e_open_rq(struct mlx5e_channel *c,
+			 struct mlx5e_params *params,
 			 struct mlx5e_rq_param *param,
 			 struct mlx5e_rq *rq)
 {
 	int err;
 
-	err = mlx5e_alloc_rq(c, param, rq);
+	err = mlx5e_alloc_rq(c, params, param, rq);
 	if (err)
 		return err;
 
@@ -864,7 +861,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_rq;
 
-	if (param->am_enabled)
+	if (params->rx_am_enabled)
 		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
 
 	return 0;
@@ -924,6 +921,7 @@ static int mlx5e_alloc_xdpsq_db(struct mlx5e_xdpsq *sq, int numa)
 }
 
 static int mlx5e_alloc_xdpsq(struct mlx5e_channel *c,
+			     struct mlx5e_params *params,
 			     struct mlx5e_sq_param *param,
 			     struct mlx5e_xdpsq *sq)
 {
@@ -936,7 +934,7 @@ static int mlx5e_alloc_xdpsq(struct mlx5e_channel *c,
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
 	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
-	sq->min_inline_mode = param->min_inline_mode;
+	sq->min_inline_mode = params->tx_min_inline_mode;
 
 	param->wq.db_numa_node = cpu_to_node(c->cpu);
 	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq, &sq->wq_ctrl);
@@ -980,7 +978,6 @@ static int mlx5e_alloc_icosq_db(struct mlx5e_icosq *sq, int numa)
 }
 
 static int mlx5e_alloc_icosq(struct mlx5e_channel *c,
-			     int tc,
 			     struct mlx5e_sq_param *param,
 			     struct mlx5e_icosq *sq)
 {
@@ -1049,8 +1046,8 @@ static int mlx5e_alloc_txqsq_db(struct mlx5e_txqsq *sq, int numa)
 }
 
 static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
-			     int tc,
 			     int txq_ix,
+			     struct mlx5e_params *params,
 			     struct mlx5e_sq_param *param,
 			     struct mlx5e_txqsq *sq)
 {
@@ -1063,11 +1060,10 @@ static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 	sq->tstamp    = &priv->tstamp;
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
-	sq->tc        = tc;
 	sq->txq_ix    = txq_ix;
 	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
-	sq->max_inline      = param->max_inline;
-	sq->min_inline_mode = param->min_inline_mode;
+	sq->max_inline      = params->tx_max_inline;
+	sq->min_inline_mode = params->tx_min_inline_mode;
 
 	param->wq.db_numa_node = cpu_to_node(c->cpu);
 	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq, &sq->wq_ctrl);
@@ -1221,6 +1217,7 @@ static int mlx5e_set_sq_maxrate(struct net_device *dev,
 static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 			    int tc,
 			    int txq_ix,
+			    struct mlx5e_params *params,
 			    struct mlx5e_sq_param *param,
 			    struct mlx5e_txqsq *sq)
 {
@@ -1229,11 +1226,11 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	u32 tx_rate;
 	int err;
 
-	err = mlx5e_alloc_txqsq(c, tc, txq_ix, param, sq);
+	err = mlx5e_alloc_txqsq(c, txq_ix, params, param, sq);
 	if (err)
 		return err;
 
-	csp.tisn            = priv->tisn[sq->tc];
+	csp.tisn            = priv->tisn[tc];
 	csp.tis_lst_sz      = 1;
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
@@ -1306,20 +1303,20 @@ static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
 }
 
 static int mlx5e_open_icosq(struct mlx5e_channel *c,
-			    int tc,
+			    struct mlx5e_params *params,
 			    struct mlx5e_sq_param *param,
 			    struct mlx5e_icosq *sq)
 {
 	struct mlx5e_create_sq_param csp = {};
 	int err;
 
-	err = mlx5e_alloc_icosq(c, tc, param, sq);
+	err = mlx5e_alloc_icosq(c, param, sq);
 	if (err)
 		return err;
 
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
-	csp.min_inline_mode = param->min_inline_mode;
+	csp.min_inline_mode = params->tx_min_inline_mode;
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
 	if (err)
@@ -1346,6 +1343,7 @@ static void mlx5e_close_icosq(struct mlx5e_icosq *sq)
 }
 
 static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
+			    struct mlx5e_params *params,
 			    struct mlx5e_sq_param *param,
 			    struct mlx5e_xdpsq *sq)
 {
@@ -1356,7 +1354,7 @@ static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
 	int err;
 	int i;
 
-	err = mlx5e_alloc_xdpsq(c, param, sq);
+	err = mlx5e_alloc_xdpsq(c, params, param, sq);
 	if (err)
 		return err;
 
@@ -1518,9 +1516,9 @@ static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
 }
 
 static int mlx5e_open_cq(struct mlx5e_channel *c,
+			 struct mlx5e_cq_moder moder,
 			 struct mlx5e_cq_param *param,
-			 struct mlx5e_cq *cq,
-			 struct mlx5e_cq_moder moderation)
+			 struct mlx5e_cq *cq)
 {
 	int err;
 	struct mlx5e_priv *priv = c->priv;
@@ -1535,9 +1533,7 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 		goto err_free_cq;
 
 	if (MLX5_CAP_GEN(mdev, cq_moderation))
-		mlx5_core_modify_cq_moderation(mdev, &cq->mcq,
-					       moderation.usec,
-					       moderation.pkts);
+		mlx5_core_modify_cq_moderation(mdev, &cq->mcq, moder.usec, moder.pkts);
 	return 0;
 
 err_free_cq:
@@ -1558,15 +1554,15 @@ static int mlx5e_get_cpu(struct mlx5e_priv *priv, int ix)
 }
 
 static int mlx5e_open_tx_cqs(struct mlx5e_channel *c,
+			     struct mlx5e_params *params,
 			     struct mlx5e_channel_param *cparam)
 {
-	struct mlx5e_priv *priv = c->priv;
 	int err;
 	int tc;
 
 	for (tc = 0; tc < c->num_tc; tc++) {
-		err = mlx5e_open_cq(c, &cparam->tx_cq, &c->sq[tc].cq,
-				    priv->params.tx_cq_moderation);
+		err = mlx5e_open_cq(c, params->tx_cq_moderation,
+				    &cparam->tx_cq, &c->sq[tc].cq);
 		if (err)
 			goto err_close_tx_cqs;
 	}
@@ -1589,15 +1585,16 @@ static void mlx5e_close_tx_cqs(struct mlx5e_channel *c)
 }
 
 static int mlx5e_open_sqs(struct mlx5e_channel *c,
+			  struct mlx5e_params *params,
 			  struct mlx5e_channel_param *cparam)
 {
 	int err;
 	int tc;
 
-	for (tc = 0; tc < c->num_tc; tc++) {
-		int txq_ix = c->ix + tc * c->priv->channels.num;
+	for (tc = 0; tc < params->num_tc; tc++) {
+		int txq_ix = c->ix + tc * params->num_channels;
 
-		err = mlx5e_open_txqsq(c, tc, txq_ix, &cparam->sq, &c->sq[tc]);
+		err = mlx5e_open_txqsq(c, tc, txq_ix, params, &cparam->sq, &c->sq[tc]);
 		if (err)
 			goto err_close_sqs;
 	}
@@ -1705,12 +1702,12 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 }
 
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
+			      struct mlx5e_params *params,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
 {
-	struct mlx5e_cq_moder icosq_cq_moder = {0, 0};
+	struct mlx5e_cq_moder icocq_moder = {0, 0};
 	struct net_device *netdev = priv->netdev;
-	struct mlx5e_cq_moder rx_cq_profile;
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
 	int err;
@@ -1725,50 +1722,44 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->pdev     = &priv->mdev->pdev->dev;
 	c->netdev   = priv->netdev;
 	c->mkey_be  = cpu_to_be32(priv->mdev->mlx5e_res.mkey.key);
-	c->num_tc   = priv->params.num_tc;
-	c->xdp      = !!priv->xdp_prog;
-
-	if (priv->params.rx_am_enabled)
-		rx_cq_profile = mlx5e_am_get_def_profile(priv->params.rx_cq_period_mode);
-	else
-		rx_cq_profile = priv->params.rx_cq_moderation;
+	c->num_tc   = params->num_tc;
+	c->xdp      = !!params->xdp_prog;
 
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
-	err = mlx5e_open_cq(c, &cparam->icosq_cq, &c->icosq.cq, icosq_cq_moder);
+	err = mlx5e_open_cq(c, icocq_moder, &cparam->icosq_cq, &c->icosq.cq);
 	if (err)
 		goto err_napi_del;
 
-	err = mlx5e_open_tx_cqs(c, cparam);
+	err = mlx5e_open_tx_cqs(c, params, cparam);
 	if (err)
 		goto err_close_icosq_cq;
 
-	err = mlx5e_open_cq(c, &cparam->rx_cq, &c->rq.cq,
-			    rx_cq_profile);
+	err = mlx5e_open_cq(c, params->rx_cq_moderation, &cparam->rx_cq, &c->rq.cq);
 	if (err)
 		goto err_close_tx_cqs;
 
 	/* XDP SQ CQ params are same as normal TXQ sq CQ params */
-	err = c->xdp ? mlx5e_open_cq(c, &cparam->tx_cq, &c->rq.xdpsq.cq,
-				     priv->params.tx_cq_moderation) : 0;
+	err = c->xdp ? mlx5e_open_cq(c, params->tx_cq_moderation,
+				     &cparam->tx_cq, &c->rq.xdpsq.cq) : 0;
 	if (err)
 		goto err_close_rx_cq;
 
 	napi_enable(&c->napi);
 
-	err = mlx5e_open_icosq(c, 0, &cparam->icosq, &c->icosq);
+	err = mlx5e_open_icosq(c, params, &cparam->icosq, &c->icosq);
 	if (err)
 		goto err_disable_napi;
 
-	err = mlx5e_open_sqs(c, cparam);
+	err = mlx5e_open_sqs(c, params, cparam);
 	if (err)
 		goto err_close_icosq;
 
-	err = c->xdp ? mlx5e_open_xdpsq(c, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
+	err = c->xdp ? mlx5e_open_xdpsq(c, params, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
 	if (err)
 		goto err_close_sqs;
 
-	err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
+	err = mlx5e_open_rq(c, params, &cparam->rq, &c->rq);
 	if (err)
 		goto err_close_xdp_sq;
 
@@ -1844,17 +1835,16 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 }
 
 static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
+				 struct mlx5e_params *params,
 				 struct mlx5e_rq_param *param)
 {
 	void *rqc = param->rqc;
 	void *wq = MLX5_ADDR_OF(rqc, rqc, wq);
 
-	switch (priv->params.rq_wq_type) {
+	switch (params->rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		MLX5_SET(wq, wq, log_wqe_num_of_strides,
-			 priv->params.mpwqe_log_num_strides - 9);
-		MLX5_SET(wq, wq, log_wqe_stride_size,
-			 priv->params.mpwqe_log_stride_sz - 6);
+		MLX5_SET(wq, wq, log_wqe_num_of_strides, params->mpwqe_log_num_strides - 9);
+		MLX5_SET(wq, wq, log_wqe_stride_size, params->mpwqe_log_stride_sz - 6);
 		MLX5_SET(wq, wq, wq_type, MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ);
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
@@ -1863,14 +1853,13 @@ static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
 
 	MLX5_SET(wq, wq, end_padding_mode, MLX5_WQ_END_PAD_MODE_ALIGN);
 	MLX5_SET(wq, wq, log_wq_stride,    ilog2(sizeof(struct mlx5e_rx_wqe)));
-	MLX5_SET(wq, wq, log_wq_sz,        priv->params.log_rq_size);
+	MLX5_SET(wq, wq, log_wq_sz,        params->log_rq_size);
 	MLX5_SET(wq, wq, pd,               priv->mdev->mlx5e_res.pdn);
 	MLX5_SET(rqc, rqc, counter_set_id, priv->q_counter);
+	MLX5_SET(rqc, rqc, vsd,            params->vlan_strip_disable);
 
 	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
 	param->wq.linear = 1;
-
-	param->am_enabled = priv->params.rx_am_enabled;
 }
 
 static void mlx5e_build_drop_rq_param(struct mlx5e_rq_param *param)
@@ -1895,16 +1884,14 @@ static void mlx5e_build_sq_param_common(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
+				 struct mlx5e_params *params,
 				 struct mlx5e_sq_param *param)
 {
 	void *sqc = param->sqc;
 	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
 
 	mlx5e_build_sq_param_common(priv, param);
-	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
-
-	param->max_inline = priv->params.tx_max_inline;
-	param->min_inline_mode = priv->params.tx_min_inline_mode;
+	MLX5_SET(wq, wq, log_wq_sz, params->log_sq_size);
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
@@ -1916,37 +1903,40 @@ static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
+				    struct mlx5e_params *params,
 				    struct mlx5e_cq_param *param)
 {
 	void *cqc = param->cqc;
 	u8 log_cq_size;
 
-	switch (priv->params.rq_wq_type) {
+	switch (params->rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		log_cq_size = priv->params.log_rq_size +
-			priv->params.mpwqe_log_num_strides;
+		log_cq_size = params->log_rq_size + params->mpwqe_log_num_strides;
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
-		log_cq_size = priv->params.log_rq_size;
+		log_cq_size = params->log_rq_size;
 	}
 
 	MLX5_SET(cqc, cqc, log_cq_size, log_cq_size);
-	if (MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS)) {
+	if (MLX5E_GET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS)) {
 		MLX5_SET(cqc, cqc, mini_cqe_res_format, MLX5_CQE_FORMAT_CSUM);
 		MLX5_SET(cqc, cqc, cqe_comp_en, 1);
 	}
 
 	mlx5e_build_common_cq_param(priv, param);
 
-	param->cq_period_mode = priv->params.rx_cq_period_mode;
+	if (params->rx_am_enabled)
+		params->rx_cq_moderation =
+			mlx5e_am_get_def_profile(params->rx_cq_period_mode);
 }
 
 static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
+				    struct mlx5e_params *params,
 				    struct mlx5e_cq_param *param)
 {
 	void *cqc = param->cqc;
 
-	MLX5_SET(cqc, cqc, log_cq_size, priv->params.log_sq_size);
+	MLX5_SET(cqc, cqc, log_cq_size, params->log_sq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
 
@@ -1954,8 +1944,8 @@ static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
-				     struct mlx5e_cq_param *param,
-				     u8 log_wq_size)
+				     u8 log_wq_size,
+				     struct mlx5e_cq_param *param)
 {
 	void *cqc = param->cqc;
 
@@ -1967,8 +1957,8 @@ static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
-				    struct mlx5e_sq_param *param,
-				    u8 log_wq_size)
+				    u8 log_wq_size,
+				    struct mlx5e_sq_param *param)
 {
 	void *sqc = param->sqc;
 	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
@@ -1980,47 +1970,48 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_build_xdpsq_param(struct mlx5e_priv *priv,
+				    struct mlx5e_params *params,
 				    struct mlx5e_sq_param *param)
 {
 	void *sqc = param->sqc;
 	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
 
 	mlx5e_build_sq_param_common(priv, param);
-	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
-
-	param->max_inline = priv->params.tx_max_inline;
-	param->min_inline_mode = priv->params.tx_min_inline_mode;
+	MLX5_SET(wq, wq, log_wq_sz, params->log_sq_size);
 }
 
-static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_channel_param *cparam)
+static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
+				      struct mlx5e_params *params,
+				      struct mlx5e_channel_param *cparam)
 {
 	u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
 
-	mlx5e_build_rq_param(priv, &cparam->rq);
-	mlx5e_build_sq_param(priv, &cparam->sq);
-	mlx5e_build_xdpsq_param(priv, &cparam->xdp_sq);
-	mlx5e_build_icosq_param(priv, &cparam->icosq, icosq_log_wq_sz);
-	mlx5e_build_rx_cq_param(priv, &cparam->rx_cq);
-	mlx5e_build_tx_cq_param(priv, &cparam->tx_cq);
-	mlx5e_build_ico_cq_param(priv, &cparam->icosq_cq, icosq_log_wq_sz);
+	mlx5e_build_rq_param(priv, params, &cparam->rq);
+	mlx5e_build_sq_param(priv, params, &cparam->sq);
+	mlx5e_build_xdpsq_param(priv, params, &cparam->xdp_sq);
+	mlx5e_build_icosq_param(priv, icosq_log_wq_sz, &cparam->icosq);
+	mlx5e_build_rx_cq_param(priv, params, &cparam->rx_cq);
+	mlx5e_build_tx_cq_param(priv, params, &cparam->tx_cq);
+	mlx5e_build_ico_cq_param(priv, icosq_log_wq_sz, &cparam->icosq_cq);
 }
 
-static int mlx5e_open_channels(struct mlx5e_priv *priv, struct mlx5e_channels *chs)
+static int mlx5e_open_channels(struct mlx5e_priv *priv,
+			       struct mlx5e_channels *chs)
 {
 	struct mlx5e_channel_param *cparam;
 	int err = -ENOMEM;
 	int i;
 
-	chs->num = priv->params.num_channels;
+	chs->num = chs->params.num_channels;
 
 	chs->c = kcalloc(chs->num, sizeof(struct mlx5e_channel *), GFP_KERNEL);
 	cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
 	if (!chs->c || !cparam)
 		goto err_free;
 
-	mlx5e_build_channel_param(priv, cparam);
+	mlx5e_build_channel_param(priv, &chs->params, cparam);
 	for (i = 0; i < chs->num; i++) {
-		err = mlx5e_open_channel(priv, i, cparam, &chs->c[i]);
+		err = mlx5e_open_channel(priv, i, &chs->params, cparam, &chs->c[i]);
 		if (err)
 			goto err_close_channels;
 	}
@@ -2178,7 +2169,7 @@ static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, int sz,
 			if (rrp.rss.hfunc == ETH_RSS_HASH_XOR)
 				ix = mlx5e_bits_invert(i, ilog2(sz));
 
-			ix = priv->params.indirection_rqt[ix];
+			ix = priv->channels.params.indirection_rqt[ix];
 			rqn = rrp.rss.channels->c[ix]->rq.rqn;
 		} else {
 			rqn = rrp.rqn;
@@ -2257,7 +2248,7 @@ static void mlx5e_redirect_rqts_to_channels(struct mlx5e_priv *priv,
 	struct mlx5e_redirect_rqt_param rrp = {
 		.is_rss        = true,
 		.rss.channels  = chs,
-		.rss.hfunc     = priv->params.rss_hfunc
+		.rss.hfunc     = chs->params.rss_hfunc
 	};
 
 	mlx5e_redirect_rqts(priv, rrp);
@@ -2273,9 +2264,9 @@ static void mlx5e_redirect_rqts_to_drop(struct mlx5e_priv *priv)
 	mlx5e_redirect_rqts(priv, drop_rrp);
 }
 
-static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
+static void mlx5e_build_tir_ctx_lro(struct mlx5e_params *params, void *tirc)
 {
-	if (!priv->params.lro_en)
+	if (!params->lro_en)
 		return;
 
 #define ROUGH_MAX_L2_L3_HDR_SZ 256
@@ -2284,13 +2275,13 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 		 MLX5_TIRC_LRO_ENABLE_MASK_IPV4_LRO |
 		 MLX5_TIRC_LRO_ENABLE_MASK_IPV6_LRO);
 	MLX5_SET(tirc, tirc, lro_max_ip_payload_size,
-		 (priv->params.lro_wqe_sz -
-		  ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
-	MLX5_SET(tirc, tirc, lro_timeout_period_usecs, priv->params.lro_timeout);
+		 (params->lro_wqe_sz - ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
+	MLX5_SET(tirc, tirc, lro_timeout_period_usecs, params->lro_timeout);
 }
 
-void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
-				    enum mlx5e_traffic_types tt)
+void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_params *params,
+				    enum mlx5e_traffic_types tt,
+				    void *tirc)
 {
 	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
 
@@ -2306,16 +2297,15 @@ void mlx5e_build_indir_tir_ctx_hash(struct mlx5e_priv *priv, void *tirc,
 				 MLX5_HASH_FIELD_SEL_DST_IP   |\
 				 MLX5_HASH_FIELD_SEL_IPSEC_SPI)
 
-	MLX5_SET(tirc, tirc, rx_hash_fn,
-		 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
-	if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
+	MLX5_SET(tirc, tirc, rx_hash_fn, mlx5e_rx_hash_fn(params->rss_hfunc));
+	if (params->rss_hfunc == ETH_RSS_HASH_TOP) {
 		void *rss_key = MLX5_ADDR_OF(tirc, tirc,
 					     rx_hash_toeplitz_key);
 		size_t len = MLX5_FLD_SZ_BYTES(tirc,
 					       rx_hash_toeplitz_key);
 
 		MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
-		memcpy(rss_key, priv->params.toeplitz_hash_key, len);
+		memcpy(rss_key, params->toeplitz_hash_key, len);
 	}
 
 	switch (tt) {
@@ -2420,7 +2410,7 @@ static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 	MLX5_SET(modify_tir_in, in, bitmask.lro, 1);
 	tirc = MLX5_ADDR_OF(modify_tir_in, in, ctx);
 
-	mlx5e_build_tir_ctx_lro(tirc, priv);
+	mlx5e_build_tir_ctx_lro(&priv->channels.params, tirc);
 
 	for (tt = 0; tt < MLX5E_NUM_INDIR_TIRS; tt++) {
 		err = mlx5_core_modify_tir(mdev, priv->indir_tir[tt].tirn, in,
@@ -2492,8 +2482,8 @@ static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 static void mlx5e_netdev_set_tcs(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int nch = priv->params.num_channels;
-	int ntc = priv->params.num_tc;
+	int nch = priv->channels.params.num_channels;
+	int ntc = priv->channels.params.num_tc;
 	int tc;
 
 	netdev_reset_tc(netdev);
@@ -2558,9 +2548,9 @@ int mlx5e_open_locked(struct net_device *netdev)
 
 	mlx5e_netdev_set_tcs(netdev);
 
-	num_txqs = priv->params.num_channels * priv->params.num_tc;
+	num_txqs = priv->channels.params.num_channels * priv->channels.params.num_tc;
 	netif_set_real_num_tx_queues(netdev, num_txqs);
-	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
+	netif_set_real_num_rx_queues(netdev, priv->channels.params.num_channels);
 
 	err = mlx5e_open_channels(priv, &priv->channels);
 	if (err)
@@ -2792,24 +2782,24 @@ void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv)
 		mlx5e_destroy_tis(priv, tc);
 }
 
-static void mlx5e_build_indir_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
-				      enum mlx5e_traffic_types tt)
+static void mlx5e_build_indir_tir_ctx(struct mlx5e_priv *priv,
+				      enum mlx5e_traffic_types tt,
+				      u32 *tirc)
 {
 	MLX5_SET(tirc, tirc, transport_domain, priv->mdev->mlx5e_res.td.tdn);
 
-	mlx5e_build_tir_ctx_lro(tirc, priv);
+	mlx5e_build_tir_ctx_lro(&priv->channels.params, tirc);
 
 	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
 	MLX5_SET(tirc, tirc, indirect_table, priv->indir_rqt.rqtn);
-	mlx5e_build_indir_tir_ctx_hash(priv, tirc, tt);
+	mlx5e_build_indir_tir_ctx_hash(&priv->channels.params, tt, tirc);
 }
 
-static void mlx5e_build_direct_tir_ctx(struct mlx5e_priv *priv, u32 *tirc,
-				       u32 rqtn)
+static void mlx5e_build_direct_tir_ctx(struct mlx5e_priv *priv, u32 rqtn, u32 *tirc)
 {
 	MLX5_SET(tirc, tirc, transport_domain, priv->mdev->mlx5e_res.td.tdn);
 
-	mlx5e_build_tir_ctx_lro(tirc, priv);
+	mlx5e_build_tir_ctx_lro(&priv->channels.params, tirc);
 
 	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
 	MLX5_SET(tirc, tirc, indirect_table, rqtn);
@@ -2834,7 +2824,7 @@ static int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv)
 		memset(in, 0, inlen);
 		tir = &priv->indir_tir[tt];
 		tirc = MLX5_ADDR_OF(create_tir_in, in, ctx);
-		mlx5e_build_indir_tir_ctx(priv, tirc, tt);
+		mlx5e_build_indir_tir_ctx(priv, tt, tirc);
 		err = mlx5e_create_tir(priv->mdev, tir, in, inlen);
 		if (err)
 			goto err_destroy_tirs;
@@ -2872,8 +2862,7 @@ int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
 		memset(in, 0, inlen);
 		tir = &priv->direct_tir[ix];
 		tirc = MLX5_ADDR_OF(create_tir_in, in, ctx);
-		mlx5e_build_direct_tir_ctx(priv, tirc,
-					   priv->direct_tir[ix].rqt.rqtn);
+		mlx5e_build_direct_tir_ctx(priv, priv->direct_tir[ix].rqt.rqtn, tirc);
 		err = mlx5e_create_tir(priv->mdev, tir, in, inlen);
 		if (err)
 			goto err_destroy_ch_tirs;
@@ -2938,7 +2927,7 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 	if (was_opened)
 		mlx5e_close_locked(priv->netdev);
 
-	priv->params.num_tc = tc ? tc : 1;
+	priv->channels.params.num_tc = tc ? tc : 1;
 
 	if (was_opened)
 		err = mlx5e_open_locked(priv->netdev);
@@ -3066,17 +3055,17 @@ static int set_feature_lro(struct net_device *netdev, bool enable)
 
 	mutex_lock(&priv->state_lock);
 
-	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
+	if (was_opened && (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
 		mlx5e_close_locked(priv->netdev);
 
-	priv->params.lro_en = enable;
+	priv->channels.params.lro_en = enable;
 	err = mlx5e_modify_tirs_lro(priv);
 	if (err) {
 		netdev_err(netdev, "lro modify failed, %d\n", err);
-		priv->params.lro_en = !enable;
+		priv->channels.params.lro_en = !enable;
 	}
 
-	if (was_opened && (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
+	if (was_opened && (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
 		mlx5e_open_locked(priv->netdev);
 
 	mutex_unlock(&priv->state_lock);
@@ -3124,13 +3113,13 @@ static int set_feature_rx_vlan(struct net_device *netdev, bool enable)
 
 	mutex_lock(&priv->state_lock);
 
-	priv->params.vlan_strip_disable = !enable;
+	priv->channels.params.vlan_strip_disable = !enable;
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		goto unlock;
 
 	err = mlx5e_modify_channels_vsd(&priv->channels, !enable);
 	if (err)
-		priv->params.vlan_strip_disable = enable;
+		priv->channels.params.vlan_strip_disable = enable;
 
 unlock:
 	mutex_unlock(&priv->state_lock);
@@ -3209,8 +3198,8 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 
 	mutex_lock(&priv->state_lock);
 
-	reset = !priv->params.lro_en &&
-		(priv->params.rq_wq_type !=
+	reset = !priv->channels.params.lro_en &&
+		(priv->channels.params.rq_wq_type !=
 		 MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ);
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
@@ -3429,7 +3418,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 
 	netdev_err(dev, "TX timeout detected\n");
 
-	for (i = 0; i < priv->channels.num * priv->params.num_tc; i++) {
+	for (i = 0; i < priv->channels.num * priv->channels.params.num_tc; i++) {
 		struct mlx5e_txqsq *sq = priv->txq2sq[i];
 
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
@@ -3462,7 +3451,7 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	/* no need for full reset when exchanging programs */
-	reset = (!priv->xdp_prog || !prog);
+	reset = (!priv->channels.params.xdp_prog || !prog);
 
 	if (was_opened && reset)
 		mlx5e_close_locked(netdev);
@@ -3470,7 +3459,7 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 		/* num_channels is invariant here, so we can take the
 		 * batched reference right upfront.
 		 */
-		prog = bpf_prog_add(prog, priv->params.num_channels);
+		prog = bpf_prog_add(prog, priv->channels.num);
 		if (IS_ERR(prog)) {
 			err = PTR_ERR(prog);
 			goto unlock;
@@ -3480,12 +3469,12 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	/* exchange programs, extra prog reference we got from caller
 	 * as long as we don't fail from this point onwards.
 	 */
-	old_prog = xchg(&priv->xdp_prog, prog);
+	old_prog = xchg(&priv->channels.params.xdp_prog, prog);
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
 	if (reset) /* change RQ type according to priv->xdp_prog */
-		mlx5e_set_rq_priv_params(priv);
+		mlx5e_set_rq_params(priv->mdev, &priv->channels.params);
 
 	if (was_opened && reset)
 		mlx5e_open_locked(netdev);
@@ -3523,7 +3512,7 @@ static bool mlx5e_xdp_attached(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	return !!priv->xdp_prog;
+	return !!priv->channels.params.xdp_prog;
 }
 
 static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -3720,6 +3709,9 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 	if (cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE)
 		params->rx_cq_moderation.usec =
 			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE;
+
+	MLX5E_SET_PFLAG(params, MLX5E_PFLAG_RX_CQE_BASED_MODER,
+			params->rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
 }
 
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
@@ -3734,75 +3726,79 @@ u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
 	return MLX5_CAP_ETH(mdev, lro_timer_supported_periods[i]);
 }
 
-static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
-					struct net_device *netdev,
-					const struct mlx5e_profile *profile,
-					void *ppriv)
+static void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
+				   struct mlx5e_params *params,
+				   u16 max_channels)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	u8 cq_period_mode = 0;
 	u32 link_speed = 0;
 	u32 pci_bw = 0;
-	u8 cq_period_mode = MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
-					 MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
-					 MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 
-	priv->mdev                         = mdev;
-	priv->netdev                       = netdev;
-	priv->params.num_channels          = profile->max_nch(mdev);
-	priv->profile                      = profile;
-	priv->ppriv                        = ppriv;
+	params->num_channels = max_channels;
+	params->num_tc       = 1;
 
-	priv->params.lro_timeout =
-		mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
-
-	priv->params.log_sq_size = is_kdump_kernel() ?
+	/* SQ */
+	params->log_sq_size = is_kdump_kernel() ?
 		MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE :
 		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
 
 	/* set CQE compression */
-	priv->params.rx_cqe_compress_def = false;
+	params->rx_cqe_compress_def = false;
 	if (MLX5_CAP_GEN(mdev, cqe_compression) &&
-	    MLX5_CAP_GEN(mdev, vport_group_manager)) {
+	     MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		mlx5e_get_max_linkspeed(mdev, &link_speed);
 		mlx5e_get_pci_bw(mdev, &pci_bw);
 		mlx5_core_dbg(mdev, "Max link speed = %d, PCI BW = %d\n",
-			      link_speed, pci_bw);
-		priv->params.rx_cqe_compress_def =
-			cqe_compress_heuristic(link_speed, pci_bw);
+			       link_speed, pci_bw);
+		params->rx_cqe_compress_def = cqe_compress_heuristic(link_speed, pci_bw);
 	}
-
-	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS,
-			priv->params.rx_cqe_compress_def);
-
-	mlx5e_set_rq_priv_params(priv);
-	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
-		priv->params.lro_en = true;
-
-	priv->params.rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
-	mlx5e_set_rx_cq_mode_params(&priv->params, cq_period_mode);
-
-	priv->params.tx_cq_moderation.usec =
-		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC;
-	priv->params.tx_cq_moderation.pkts =
-		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
-	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
-	mlx5_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
-	if (priv->params.tx_min_inline_mode == MLX5_INLINE_MODE_NONE &&
+	MLX5E_SET_PFLAG(params, MLX5E_PFLAG_RX_CQE_COMPRESS, params->rx_cqe_compress_def);
+
+	/* RQ */
+	mlx5e_set_rq_params(mdev, params);
+
+	/* HW LRO */
+	if (params->rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
+		params->lro_en = true;
+	params->lro_timeout = mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
+
+	/* CQ moderation params */
+	cq_period_mode = MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
+			MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
+			MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
+	params->rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
+	mlx5e_set_rx_cq_mode_params(params, cq_period_mode);
+
+	params->tx_cq_moderation.usec = MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC;
+	params->tx_cq_moderation.pkts = MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
+
+	/* TX inline */
+	params->tx_max_inline = mlx5e_get_max_inline_cap(mdev);
+	mlx5_query_min_inline(mdev, &params->tx_min_inline_mode);
+	if (params->tx_min_inline_mode == MLX5_INLINE_MODE_NONE &&
 	    !MLX5_CAP_ETH(mdev, wqe_vlan_insert))
-		priv->params.tx_min_inline_mode = MLX5_INLINE_MODE_L2;
+		params->tx_min_inline_mode = MLX5_INLINE_MODE_L2;
 
-	priv->params.num_tc                = 1;
-	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
+	/* RSS */
+	params->rss_hfunc = ETH_RSS_HASH_XOR;
+	netdev_rss_key_fill(params->toeplitz_hash_key, sizeof(params->toeplitz_hash_key));
+	mlx5e_build_default_indir_rqt(mdev, params->indirection_rqt,
+				      MLX5E_INDIR_RQT_SIZE, max_channels);
+}
 
-	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
-			    sizeof(priv->params.toeplitz_hash_key));
+static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
+					struct net_device *netdev,
+					const struct mlx5e_profile *profile,
+					void *ppriv)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	mlx5e_build_default_indir_rqt(mdev, priv->params.indirection_rqt,
-				      MLX5E_INDIR_RQT_SIZE, profile->max_nch(mdev));
+	priv->mdev        = mdev;
+	priv->netdev      = netdev;
+	priv->profile     = profile;
+	priv->ppriv       = ppriv;
 
-	/* Initialize pflags */
-	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
-			priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
+	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 
 	mutex_init(&priv->state_lock);
 
@@ -3888,7 +3884,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 		netdev->hw_features |= NETIF_F_RXALL;
 
 	netdev->features          = netdev->hw_features;
-	if (!priv->params.lro_en)
+	if (!priv->channels.params.lro_en)
 		netdev->features  &= ~NETIF_F_LRO;
 
 	if (fcs_enabled)
@@ -3953,8 +3949,8 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 {
 	mlx5e_vxlan_cleanup(priv);
 
-	if (priv->xdp_prog)
-		bpf_prog_put(priv->xdp_prog);
+	if (priv->channels.params.xdp_prog)
+		bpf_prog_put(priv->channels.params.xdp_prog);
 }
 
 static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 0515b7f7d11f..d277c1979b2a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -110,7 +110,7 @@ static void mlx5e_rep_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_packets	+= rq_stats->packets;
 		s->rx_bytes	+= rq_stats->bytes;
 
-		for (j = 0; j < priv->params.num_tc; j++) {
+		for (j = 0; j < priv->channels.params.num_tc; j++) {
 			sq_stats = &c->sq[j].stats;
 
 			s->tx_packets		+= sq_stats->packets;
@@ -192,7 +192,7 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 	int n, tc, err, num_sqs = 0;
 	u16 *sqs;
 
-	sqs = kcalloc(priv->channels.num * priv->params.num_tc, sizeof(u16), GFP_KERNEL);
+	sqs = kcalloc(priv->channels.num * priv->channels.params.num_tc, sizeof(u16), GFP_KERNEL);
 	if (!sqs)
 		return -ENOMEM;
 
@@ -399,42 +399,23 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
 
-static void mlx5e_build_rep_netdev_priv(struct mlx5_core_dev *mdev,
-					struct net_device *netdev,
-					const struct mlx5e_profile *profile,
-					void *ppriv)
+static void mlx5e_build_rep_params(struct mlx5_core_dev *mdev,
+				   struct mlx5e_params *params)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	u8 cq_period_mode = MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
 					 MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
 					 MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 
-	priv->params.log_sq_size           =
-		MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
-	priv->params.rq_wq_type = MLX5_WQ_TYPE_LINKED_LIST;
-	priv->params.log_rq_size = MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE;
-
-	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
-					    BIT(priv->params.log_rq_size));
-
-	priv->params.rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
-	mlx5e_set_rx_cq_mode_params(&priv->params, cq_period_mode);
-
-	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
-	priv->params.num_tc                = 1;
-
-	priv->params.lro_wqe_sz            =
-		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
-
-	priv->mdev                         = mdev;
-	priv->netdev                       = netdev;
-	priv->params.num_channels          = profile->max_nch(mdev);
-	priv->profile                      = profile;
-	priv->ppriv                        = ppriv;
+	params->log_sq_size = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
+	params->rq_wq_type  = MLX5_WQ_TYPE_LINKED_LIST;
+	params->log_rq_size = MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE;
 
-	mutex_init(&priv->state_lock);
+	params->rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
+	mlx5e_set_rx_cq_mode_params(params, cq_period_mode);
 
-	INIT_DELAYED_WORK(&priv->update_stats_work, mlx5e_update_stats_work);
+	params->tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
+	params->num_tc                = 1;
+	params->lro_wqe_sz            = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
 }
 
 static void mlx5e_build_rep_netdev(struct net_device *netdev)
@@ -460,7 +441,19 @@ static void mlx5e_init_rep(struct mlx5_core_dev *mdev,
 			   const struct mlx5e_profile *profile,
 			   void *ppriv)
 {
-	mlx5e_build_rep_netdev_priv(mdev, netdev, profile, ppriv);
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	priv->mdev                         = mdev;
+	priv->netdev                       = netdev;
+	priv->profile                      = profile;
+	priv->ppriv                        = ppriv;
+
+	mutex_init(&priv->state_lock);
+
+	INIT_DELAYED_WORK(&priv->update_stats_work, mlx5e_update_stats_work);
+
+	priv->channels.params.num_channels = profile->max_nch(mdev);
+	mlx5e_build_rep_params(mdev, &priv->channels.params);
 	mlx5e_build_rep_netdev(netdev);
 }
 
@@ -505,7 +498,7 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_direct_rqts:
-	for (i = 0; i < priv->params.num_channels; i++)
+	for (i = 0; i < priv->channels.params.num_channels; i++)
 		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
 	return err;
 }
@@ -518,7 +511,7 @@ static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 	mlx5e_tc_cleanup(priv);
 	mlx5_del_flow_rules(rep->vport_rx_rule);
 	mlx5e_destroy_direct_tirs(priv);
-	for (i = 0; i < priv->params.num_channels; i++)
+	for (i = 0; i < priv->channels.params.num_channels; i++)
 		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 3ecbe8c2d5e3..0a40c42e1335 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -163,19 +163,19 @@ void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val)
 	if (!MLX5_CAP_GEN(priv->mdev, cqe_compression))
 		return;
 
-	if (MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) == val)
+	if (MLX5E_GET_PFLAG(&priv->channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS) == val)
 		return;
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
 		mlx5e_close_locked(priv->netdev);
 
-	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
-	mlx5e_set_rq_type_params(priv, priv->params.rq_wq_type);
+	MLX5E_SET_PFLAG(&priv->channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
+	mlx5e_set_rq_type_params(priv->mdev, &priv->channels.params,
+				 priv->channels.params.rq_wq_type);
 
 	if (was_opened)
 		mlx5e_open_locked(priv->netdev);
-
 }
 
 #define RQ_PAGE_SIZE(rq) ((1 << rq->buff.page_order) << PAGE_SHIFT)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 42743b114bcf..5bbc313e70c5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -88,6 +88,7 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int channel_ix = fallback(dev, skb);
+	u16 num_channels;
 	int up = 0;
 
 	if (!netdev_get_num_tc(dev))
@@ -99,9 +100,9 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 	/* channel_ix can be larger than num_channels since
 	 * dev->num_real_tx_queues = num_channels * num_tc
 	 */
-	if (channel_ix >= priv->params.num_channels)
-		channel_ix = reciprocal_scale(channel_ix,
-					      priv->params.num_channels);
+	num_channels = priv->channels.params.num_channels;
+	if (channel_ix >= num_channels)
+		channel_ix = reciprocal_scale(channel_ix, num_channels);
 
 	return priv->channel_tc2txq[channel_ix][up];
 }
-- 
2.11.0
