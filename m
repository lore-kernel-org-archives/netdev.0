From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/14] net/mlx5e: Fail safe cqe compressing/moderation mode setting
Date: Mon, 27 Mar 2017 23:49:08 +0300
Message-ID: <20170327204910.20287-13-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44900 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752601AbdC0UuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:25 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new fail-safe channels switch mechanism to set new
CQE compressing and CQE moderation mode settings.

We also move RX CQE compression modify function out of en_rx file  to
a more appropriate place.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  8 +++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 53 ++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 22 ---------
 4 files changed, 51 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 2f259dfbf844..8b93d8d02116 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -833,7 +833,7 @@ void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
 			     struct ptp_clock_event *event);
 int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr);
 int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr);
-void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val);
+int mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 485c23b59f93..e706a87fc8b2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -90,6 +90,7 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct hwtstamp_config config;
+	int err;
 
 	if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
 		return -EOPNOTSUPP;
@@ -129,7 +130,12 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		/* Disable CQE compression */
 		netdev_warn(dev, "Disabling cqe compression");
-		mlx5e_modify_rx_cqe_compression_locked(priv, false);
+		err = mlx5e_modify_rx_cqe_compression_locked(priv, false);
+		if (err) {
+			netdev_err(dev, "Failed disabling cqe compression err=%d\n", err);
+			mutex_unlock(&priv->state_lock);
+			return err;
+		}
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 457a796cc248..c5f49e294987 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1474,10 +1474,10 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_channels new_channels = {};
 	bool rx_mode_changed;
 	u8 rx_cq_period_mode;
 	int err = 0;
-	bool reset;
 
 	rx_cq_period_mode = enable ?
 		MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
@@ -1491,16 +1491,51 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 	if (!rx_mode_changed)
 		return 0;
 
-	reset = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (reset)
-		mlx5e_close_locked(netdev);
+	new_channels.params = priv->channels.params;
+	mlx5e_set_rx_cq_mode_params(&new_channels.params, rx_cq_period_mode);
 
-	mlx5e_set_rx_cq_mode_params(&priv->channels.params, rx_cq_period_mode);
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		return 0;
+	}
+
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		return err;
 
-	if (reset)
-		err = mlx5e_open_locked(netdev);
+	mlx5e_switch_priv_channels(priv, &new_channels);
+	return 0;
+}
 
-	return err;
+int mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool new_val)
+{
+	bool curr_val = MLX5E_GET_PFLAG(&priv->channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS);
+	struct mlx5e_channels new_channels = {};
+	int err = 0;
+
+	if (!MLX5_CAP_GEN(priv->mdev, cqe_compression))
+		return new_val ? -EOPNOTSUPP : 0;
+
+	if (curr_val == new_val)
+		return 0;
+
+	new_channels.params = priv->channels.params;
+	MLX5E_SET_PFLAG(&new_channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS, new_val);
+
+	mlx5e_set_rq_type_params(priv->mdev, &new_channels.params,
+				 new_channels.params.rq_wq_type);
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		return 0;
+	}
+
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		return err;
+
+	mlx5e_switch_priv_channels(priv, &new_channels);
+	return 0;
 }
 
 static int set_pflag_rx_cqe_compress(struct net_device *netdev,
@@ -1519,8 +1554,6 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 
 	mlx5e_modify_rx_cqe_compression_locked(priv, enable);
 	priv->channels.params.rx_cqe_compress_def = enable;
-	mlx5e_set_rq_type_params(priv->mdev, &priv->channels.params,
-				 priv->channels.params.rq_wq_type);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0a40c42e1335..1a9532b31635 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -156,28 +156,6 @@ static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
 	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem) - 1;
 }
 
-void mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool val)
-{
-	bool was_opened;
-
-	if (!MLX5_CAP_GEN(priv->mdev, cqe_compression))
-		return;
-
-	if (MLX5E_GET_PFLAG(&priv->channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS) == val)
-		return;
-
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
-		mlx5e_close_locked(priv->netdev);
-
-	MLX5E_SET_PFLAG(&priv->channels.params, MLX5E_PFLAG_RX_CQE_COMPRESS, val);
-	mlx5e_set_rq_type_params(priv->mdev, &priv->channels.params,
-				 priv->channels.params.rq_wq_type);
-
-	if (was_opened)
-		mlx5e_open_locked(priv->netdev);
-}
-
 #define RQ_PAGE_SIZE(rq) ((1 << rq->buff.page_order) << PAGE_SHIFT)
 
 static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
-- 
2.11.0
