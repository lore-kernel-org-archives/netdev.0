From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 10/10] net/mlx5e: Add CQE compression user control
Date: Sun, 27 Nov 2016 17:02:12 +0200
Message-ID: <1480258932-10302-11-git-send-email-saeedm@mellanox.com>
References: <1480258932-10302-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Shaker Daibes <shakerd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43785 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752332AbcK0PC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:02:29 -0500
In-Reply-To: <1480258932-10302-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

The user can now override the automatic driver decision using the
rx_cqe_compress flag, which is the preference for CQE compression.
The flag is initialized with the automatic driver decision.

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  5 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  3 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 39 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 13 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  4 +--
 5 files changed, 51 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 84ac78f..442dbc3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -171,10 +171,12 @@ extern const char mlx5e_self_tests[][ETH_GSTRING_LEN];
 
 static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
 	"rx_cqe_moder",
+	"rx_cqe_compress",
 };
 
 enum mlx5e_priv_flag {
 	MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
+	MLX5E_PFLAG_RX_CQE_COMPRESS = (1 << 1),
 };
 
 #define MLX5E_SET_PFLAG(priv, pflag, enable)			\
@@ -205,8 +207,7 @@ struct mlx5e_params {
 	u16 num_channels;
 	u8  num_tc;
 	u8  rx_cq_period_mode;
-	bool rx_cqe_compress_admin;
-	bool rx_cqe_compress;
+	bool rx_cqe_compress_def;
 	struct mlx5e_cq_moder rx_cq_moderation;
 	struct mlx5e_cq_moder tx_cq_moderation;
 	u16 min_rx_wqes;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 13dc388..2cd8e56 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -94,7 +94,7 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		/* Reset CQE compression to Admin default */
-		mlx5e_modify_rx_cqe_compression(priv, priv->params.rx_cqe_compress_admin);
+		mlx5e_modify_rx_cqe_compression(priv, priv->params.rx_cqe_compress_def);
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
@@ -111,6 +111,7 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		/* Disable CQE compression */
+		netdev_warn(dev, "Disabling cqe compression");
 		mlx5e_modify_rx_cqe_compression(priv, false);
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index d2bdccb..aa963d7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1481,6 +1481,35 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 	return err;
 }
 
+static int set_pflag_rx_cqe_compress(struct net_device *netdev,
+				     bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err = 0;
+	bool reset;
+
+	if (!MLX5_CAP_GEN(mdev, cqe_compression))
+		return -ENOTSUPP;
+
+	if (enable && priv->tstamp.hwtstamp_config.rx_filter != HWTSTAMP_FILTER_NONE) {
+		netdev_err(netdev, "Can't enable cqe compression while timestamping is enabled.\n");
+		return -EINVAL;
+	}
+
+	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
+
+	if (reset)
+		mlx5e_close_locked(netdev);
+
+	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, enable);
+	priv->params.rx_cqe_compress_def = enable;
+
+	if (reset)
+		err = mlx5e_open_locked(netdev);
+	return err;
+}
+
 static int mlx5e_handle_pflag(struct net_device *netdev,
 			      u32 wanted_flags,
 			      enum mlx5e_priv_flag flag,
@@ -1511,13 +1540,19 @@ static int mlx5e_set_priv_flags(struct net_device *netdev, u32 pflags)
 	int err;
 
 	mutex_lock(&priv->state_lock);
-
 	err = mlx5e_handle_pflag(netdev, pflags,
 				 MLX5E_PFLAG_RX_CQE_BASED_MODER,
 				 set_pflag_rx_cqe_based_moder);
+	if (err)
+		goto out;
 
+	err = mlx5e_handle_pflag(netdev, pflags,
+				 MLX5E_PFLAG_RX_CQE_COMPRESS,
+				 set_pflag_rx_cqe_compress);
+
+out:
 	mutex_unlock(&priv->state_lock);
-	return err ? -EINVAL : 0;
+	return err;
 }
 
 static u32 mlx5e_get_priv_flags(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 004940a..6b492ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -84,7 +84,8 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
-		priv->params.mpwqe_log_stride_sz = priv->params.rx_cqe_compress ?
+		priv->params.mpwqe_log_stride_sz =
+			MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) ?
 			MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS :
 			MLX5_MPWRQ_LOG_STRIDE_SIZE;
 		priv->params.mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
@@ -101,7 +102,7 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 		       priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ,
 		       BIT(priv->params.log_rq_size),
 		       BIT(priv->params.mpwqe_log_stride_sz),
-		       priv->params.rx_cqe_compress_admin);
+		       MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS));
 }
 
 static void mlx5e_set_rq_priv_params(struct mlx5e_priv *priv)
@@ -1664,7 +1665,7 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	}
 
 	MLX5_SET(cqc, cqc, log_cq_size, log_cq_size);
-	if (priv->params.rx_cqe_compress) {
+	if (MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS)) {
 		MLX5_SET(cqc, cqc, mini_cqe_res_format, MLX5_CQE_FORMAT_CSUM);
 		MLX5_SET(cqc, cqc, cqe_comp_en, 1);
 	}
@@ -3447,17 +3448,16 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.log_sq_size = MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
 
 	/* set CQE compression */
-	priv->params.rx_cqe_compress_admin = false;
+	priv->params.rx_cqe_compress_def = false;
 	if (MLX5_CAP_GEN(mdev, cqe_compression) &&
 	    MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		mlx5e_get_max_linkspeed(mdev, &link_speed);
 		mlx5e_get_pci_bw(mdev, &pci_bw);
 		mlx5_core_dbg(mdev, "Max link speed = %d, PCI BW = %d\n",
 			      link_speed, pci_bw);
-		priv->params.rx_cqe_compress_admin =
+		priv->params.rx_cqe_compress_def =
 			cqe_compress_heuristic(link_speed, pci_bw);
 	}
-	priv->params.rx_cqe_compress = priv->params.rx_cqe_compress_admin;
 
 	mlx5e_set_rq_priv_params(priv);
 	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
@@ -3490,6 +3490,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	/* Initialize pflags */
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
 			priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
+	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, priv->params.rx_cqe_compress_def);
 
 	mutex_init(&priv->state_lock);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index c6de6fb..b036710 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -164,14 +164,14 @@ void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
 
 	mutex_lock(&priv->state_lock);
 
-	if (priv->params.rx_cqe_compress == val)
+	if (MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) == val)
 		goto unlock;
 
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	if (was_opened)
 		mlx5e_close_locked(priv->netdev);
 
-	priv->params.rx_cqe_compress = val;
+	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
 
 	if (was_opened)
 		mlx5e_open_locked(priv->netdev);
-- 
2.7.4
