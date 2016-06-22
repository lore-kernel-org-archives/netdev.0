From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 4/9] net/mlx5e: CQE based moderation
Date: Wed, 22 Jun 2016 19:33:12 +0300
Message-ID: <1466613197-28726-5-git-send-email-saeedm@mellanox.com>
References: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Gil Rockah <gilr@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39086 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751860AbcFVQeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:34:03 -0400
In-Reply-To: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In this mode the moderation timer will restart upon
new completion (CQE) generation rather than upon interrupt
generation.

The outcome is that for bursty traffic the period timer will never
expire and thus only the moderation frames counter will dictate
interrupt generation, thus the interrupt rate will be relative
to the incoming packets size.
If the burst seizes for "moderation period" time then an interrupt
will be issued immediately.

CQE based moderation is off by default and can be controlled
via ethtool set_priv_flags.

Performance tested on ConnectX4-Lx 50G.

Less packet loss in netperf UDP and TCP tests, with no bw degradation,
for both single and multi streams, with message sizes of
64, 1024, 1472 and 32768 byte.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Gil Rockah <gilr@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 20 +++++---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 54 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 54 ++++++++++++++++------
 3 files changed, 95 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 02fa4da..36f625d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -79,6 +79,7 @@
 
 #define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC      0x10
+#define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE 0x3
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS      0x20
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC      0x10
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS      0x20
@@ -145,11 +146,11 @@ struct mlx5e_umr_wqe {
 };
 
 static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
-	"nop",
+	"rx_cqe_moder",
 };
 
 enum mlx5e_priv_flag {
-	MLX5E_PFLAG_NOP = (1 << 0),
+	MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
 };
 
 #define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
@@ -165,6 +166,11 @@ enum mlx5e_priv_flag {
 #define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
 #endif
 
+struct mlx5e_cq_moder {
+	u16 usec;
+	u16 pkts;
+};
+
 struct mlx5e_params {
 	u8  log_sq_size;
 	u8  rq_wq_type;
@@ -173,12 +179,11 @@ struct mlx5e_params {
 	u8  log_rq_size;
 	u16 num_channels;
 	u8  num_tc;
+	u8  rx_cq_period_mode;
 	bool rx_cqe_compress_admin;
 	bool rx_cqe_compress;
-	u16 rx_cq_moderation_usec;
-	u16 rx_cq_moderation_pkts;
-	u16 tx_cq_moderation_usec;
-	u16 tx_cq_moderation_pkts;
+	struct mlx5e_cq_moder rx_cq_moderation;
+	struct mlx5e_cq_moder tx_cq_moderation;
 	u16 min_rx_wqes;
 	bool lro_en;
 	u32 lro_wqe_sz;
@@ -667,6 +672,9 @@ void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   int num_channels);
 int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 
+void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
+				 u8 cq_period_mode);
+
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index f8bbc2b..4f433d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -524,10 +524,10 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 	if (!MLX5_CAP_GEN(priv->mdev, cq_moderation))
 		return -ENOTSUPP;
 
-	coal->rx_coalesce_usecs       = priv->params.rx_cq_moderation_usec;
-	coal->rx_max_coalesced_frames = priv->params.rx_cq_moderation_pkts;
-	coal->tx_coalesce_usecs       = priv->params.tx_cq_moderation_usec;
-	coal->tx_max_coalesced_frames = priv->params.tx_cq_moderation_pkts;
+	coal->rx_coalesce_usecs       = priv->params.rx_cq_moderation.usec;
+	coal->rx_max_coalesced_frames = priv->params.rx_cq_moderation.pkts;
+	coal->tx_coalesce_usecs       = priv->params.tx_cq_moderation.usec;
+	coal->tx_max_coalesced_frames = priv->params.tx_cq_moderation.pkts;
 
 	return 0;
 }
@@ -545,10 +545,11 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 		return -ENOTSUPP;
 
 	mutex_lock(&priv->state_lock);
-	priv->params.tx_cq_moderation_usec = coal->tx_coalesce_usecs;
-	priv->params.tx_cq_moderation_pkts = coal->tx_max_coalesced_frames;
-	priv->params.rx_cq_moderation_usec = coal->rx_coalesce_usecs;
-	priv->params.rx_cq_moderation_pkts = coal->rx_max_coalesced_frames;
+
+	priv->params.tx_cq_moderation.usec = coal->tx_coalesce_usecs;
+	priv->params.tx_cq_moderation.pkts = coal->tx_max_coalesced_frames;
+	priv->params.rx_cq_moderation.usec = coal->rx_coalesce_usecs;
+	priv->params.rx_cq_moderation.pkts = coal->rx_max_coalesced_frames;
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		goto out;
@@ -1279,9 +1280,37 @@ static int mlx5e_get_module_eeprom(struct net_device *netdev,
 
 typedef int (*mlx5e_pflag_handler)(struct net_device *netdev, bool enable);
 
-static int set_pflag_nop(struct net_device *netdev, bool enable)
+static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 {
-	return 0;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	bool rx_mode_changed;
+	u8 rx_cq_period_mode;
+	int err = 0;
+	bool reset;
+
+	rx_cq_period_mode = enable ?
+		MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
+		MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
+	rx_mode_changed = rx_cq_period_mode != priv->params.rx_cq_period_mode;
+
+	if (rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE &&
+	    !MLX5_CAP_GEN(mdev, cq_period_start_from_cqe))
+		return -ENOTSUPP;
+
+	if (!rx_mode_changed)
+		return 0;
+
+	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (reset)
+		mlx5e_close_locked(netdev);
+
+	mlx5e_set_rx_cq_mode_params(&priv->params, rx_cq_period_mode);
+
+	if (reset)
+		err = mlx5e_open_locked(netdev);
+
+	return err;
 }
 
 static int mlx5e_handle_pflag(struct net_device *netdev,
@@ -1315,8 +1344,9 @@ static int mlx5e_set_priv_flags(struct net_device *netdev, u32 pflags)
 
 	mutex_lock(&priv->state_lock);
 
-	err = mlx5e_handle_pflag(netdev, pflags, MLX5E_PFLAG_NOP,
-				 set_pflag_nop);
+	err = mlx5e_handle_pflag(netdev, pflags,
+				 MLX5E_PFLAG_RX_CQE_BASED_MODER,
+				 set_pflag_rx_cqe_based_moder);
 
 	mutex_unlock(&priv->state_lock);
 	return err ? -EINVAL : 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e5a2cef..13e7a45 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -55,6 +55,7 @@ struct mlx5e_cq_param {
 	u32                        cqc[MLX5_ST_SZ_DW(cqc)];
 	struct mlx5_wq_param       wq;
 	u16                        eq_ix;
+	u8                         cq_period_mode;
 };
 
 struct mlx5e_channel_param {
@@ -896,6 +897,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 	mlx5_vector2eqn(mdev, param->eq_ix, &eqn, &irqn_not_used);
 
+	MLX5_SET(cqc,   cqc, cq_period_mode, param->cq_period_mode);
 	MLX5_SET(cqc,   cqc, c_eqn,         eqn);
 	MLX5_SET(cqc,   cqc, uar_page,      mcq->uar->index);
 	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.buf.page_shift -
@@ -925,8 +927,7 @@ static void mlx5e_disable_cq(struct mlx5e_cq *cq)
 static int mlx5e_open_cq(struct mlx5e_channel *c,
 			 struct mlx5e_cq_param *param,
 			 struct mlx5e_cq *cq,
-			 u16 moderation_usecs,
-			 u16 moderation_frames)
+			 struct mlx5e_cq_moder moderation)
 {
 	int err;
 	struct mlx5e_priv *priv = c->priv;
@@ -942,8 +943,8 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 
 	if (MLX5_CAP_GEN(mdev, cq_moderation))
 		mlx5_core_modify_cq_moderation(mdev, &cq->mcq,
-					       moderation_usecs,
-					       moderation_frames);
+					       moderation.usec,
+					       moderation.pkts);
 	return 0;
 
 err_destroy_cq:
@@ -972,8 +973,7 @@ static int mlx5e_open_tx_cqs(struct mlx5e_channel *c,
 
 	for (tc = 0; tc < c->num_tc; tc++) {
 		err = mlx5e_open_cq(c, &cparam->tx_cq, &c->sq[tc].cq,
-				    priv->params.tx_cq_moderation_usec,
-				    priv->params.tx_cq_moderation_pkts);
+				    priv->params.tx_cq_moderation);
 		if (err)
 			goto err_close_tx_cqs;
 	}
@@ -1110,6 +1110,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
 {
+	struct mlx5e_cq_moder icosq_cq_moder = {0, 0};
 	struct net_device *netdev = priv->netdev;
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
@@ -1133,7 +1134,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
-	err = mlx5e_open_cq(c, &cparam->icosq_cq, &c->icosq.cq, 0, 0);
+	err = mlx5e_open_cq(c, &cparam->icosq_cq, &c->icosq.cq, icosq_cq_moder);
 	if (err)
 		goto err_napi_del;
 
@@ -1142,8 +1143,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		goto err_close_icosq_cq;
 
 	err = mlx5e_open_cq(c, &cparam->rx_cq, &c->rq.cq,
-			    priv->params.rx_cq_moderation_usec,
-			    priv->params.rx_cq_moderation_pkts);
+			    priv->params.rx_cq_moderation);
 	if (err)
 		goto err_close_tx_cqs;
 
@@ -1308,6 +1308,8 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	}
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = priv->params.rx_cq_period_mode;
 }
 
 static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
@@ -1318,6 +1320,8 @@ static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
 	MLX5_SET(cqc, cqc, log_cq_size, priv->params.log_sq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 }
 
 static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
@@ -1329,6 +1333,8 @@ static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
 	MLX5_SET(cqc, cqc, log_cq_size, log_wq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 }
 
 static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
@@ -2856,6 +2862,20 @@ static bool cqe_compress_heuristic(u32 link_speed, u32 pci_bw)
 		(pci_bw < 40000) && (pci_bw < link_speed));
 }
 
+void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
+{
+	params->rx_cq_period_mode = cq_period_mode;
+
+	params->rx_cq_moderation.pkts =
+		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS;
+	params->rx_cq_moderation.usec =
+			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC;
+
+	if (cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE)
+		params->rx_cq_moderation.usec =
+			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE;
+}
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_channels)
@@ -2908,13 +2928,13 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 
 	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
 					    BIT(priv->params.log_rq_size));
-	priv->params.rx_cq_moderation_usec =
-		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC;
-	priv->params.rx_cq_moderation_pkts =
-		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS;
-	priv->params.tx_cq_moderation_usec =
+
+	mlx5e_set_rx_cq_mode_params(&priv->params,
+				    MLX5_CQ_PERIOD_MODE_START_FROM_EQE);
+
+	priv->params.tx_cq_moderation.usec =
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC;
-	priv->params.tx_cq_moderation_pkts =
+	priv->params.tx_cq_moderation.pkts =
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
 	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
 	priv->params.num_tc                = 1;
@@ -2929,6 +2949,10 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.lro_wqe_sz            =
 		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
 
+	/* Initialize pflags */
+	MLX5E_SET_PRIV_FLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
+			    priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
+
 	priv->mdev                         = mdev;
 	priv->netdev                       = netdev;
 	priv->params.num_channels          = num_channels;
-- 
2.8.0
