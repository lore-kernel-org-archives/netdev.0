From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/14] net/mlx5e: Fail safe mtu and lro setting
Date: Mon, 27 Mar 2017 23:49:10 +0300
Message-ID: <20170327204910.20287-15-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44903 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752560AbdC0UuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:12 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new fail-safe channels switch mechanism to set new
netdev mtu and lro settings.

MTU and lro settings demand some HW configuration changes after new
channels are created and ready for action. In order to unify switch
channels routine for LRO and MTU changes, and maybe future configuration
features, we now pass to it a modify HW function pointer to be
invoked directly after old channels are de-activated and before new
channels are activated.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  8 ++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 12 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 70 ++++++++++++++--------
 3 files changed, 58 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8b93d8d02116..150fb52a0737 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -867,8 +867,14 @@ int mlx5e_close_locked(struct net_device *netdev);
 int mlx5e_open_channels(struct mlx5e_priv *priv,
 			struct mlx5e_channels *chs);
 void mlx5e_close_channels(struct mlx5e_channels *chs);
+
+/* Function pointer to be used to modify WH settings while
+ * switching channels
+ */
+typedef int (*mlx5e_fp_hw_modify)(struct mlx5e_priv *priv);
 void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
-				struct mlx5e_channels *new_chs);
+				struct mlx5e_channels *new_chs,
+				mlx5e_fp_hw_modify hw_modify);
 
 void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   u32 *indirection_rqt, int len,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index c5f49e294987..40912937d211 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -540,7 +540,7 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	if (err)
 		goto unlock;
 
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 
 unlock:
 	mutex_unlock(&priv->state_lock);
@@ -597,7 +597,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 		mlx5e_arfs_disable(priv);
 
 	/* Switch to new channels, set new parameters and close old ones */
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 
 	if (arfs_enabled) {
 		err = mlx5e_arfs_enable(priv);
@@ -691,7 +691,7 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	if (err)
 		goto out;
 
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 
 out:
 	mutex_unlock(&priv->state_lock);
@@ -1166,7 +1166,7 @@ static int mlx5e_set_tunable(struct net_device *dev,
 		err = mlx5e_open_channels(priv, &new_channels);
 		if (err)
 			break;
-		mlx5e_switch_priv_channels(priv, &new_channels);
+		mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 
 		break;
 	default:
@@ -1503,7 +1503,7 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 	if (err)
 		return err;
 
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 	return 0;
 }
 
@@ -1534,7 +1534,7 @@ int mlx5e_modify_rx_cqe_compression_locked(struct mlx5e_priv *priv, bool new_val
 	if (err)
 		return err;
 
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1e29f40d84ca..68d6c3c58ba7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2437,9 +2437,9 @@ static void mlx5e_query_mtu(struct mlx5e_priv *priv, u16 *mtu)
 	*mtu = MLX5E_HW2SW_MTU(hw_mtu);
 }
 
-static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
+static int mlx5e_set_dev_port_mtu(struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct net_device *netdev = priv->netdev;
 	u16 mtu;
 	int err;
 
@@ -2534,7 +2534,8 @@ static void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 }
 
 void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
-				struct mlx5e_channels *new_chs)
+				struct mlx5e_channels *new_chs,
+				mlx5e_fp_hw_modify hw_modify)
 {
 	struct net_device *netdev = priv->netdev;
 	int new_num_txqs;
@@ -2551,6 +2552,10 @@ void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
 
 	priv->channels = *new_chs;
 
+	/* New channels are ready to roll, modify HW settings if needed */
+	if (hw_modify)
+		hw_modify(priv);
+
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
 
@@ -2930,7 +2935,7 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 	if (err)
 		goto out;
 
-	mlx5e_switch_priv_channels(priv, &new_channels);
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
 out:
 	mutex_unlock(&priv->state_lock);
 	return err;
@@ -3049,26 +3054,31 @@ typedef int (*mlx5e_feature_handler)(struct net_device *netdev, bool enable);
 static int set_feature_lro(struct net_device *netdev, bool enable)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	bool was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	int err;
+	struct mlx5e_channels new_channels = {};
+	int err = 0;
+	bool reset;
 
 	mutex_lock(&priv->state_lock);
 
-	if (was_opened && (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
-		mlx5e_close_locked(priv->netdev);
+	reset = (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST);
+	reset = reset && test_bit(MLX5E_STATE_OPENED, &priv->state);
 
-	priv->channels.params.lro_en = enable;
-	err = mlx5e_modify_tirs_lro(priv);
-	if (err) {
-		netdev_err(netdev, "lro modify failed, %d\n", err);
-		priv->channels.params.lro_en = !enable;
+	new_channels.params = priv->channels.params;
+	new_channels.params.lro_en = enable;
+
+	if (!reset) {
+		priv->channels.params = new_channels.params;
+		err = mlx5e_modify_tirs_lro(priv);
+		goto out;
 	}
 
-	if (was_opened && (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST))
-		mlx5e_open_locked(priv->netdev);
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto out;
 
+	mlx5e_switch_priv_channels(priv, &new_channels, mlx5e_modify_tirs_lro);
+out:
 	mutex_unlock(&priv->state_lock);
-
 	return err;
 }
 
@@ -3191,7 +3201,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	bool was_opened;
+	struct mlx5e_channels new_channels = {};
+	int curr_mtu;
 	int err = 0;
 	bool reset;
 
@@ -3201,18 +3212,27 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 		(priv->channels.params.rq_wq_type !=
 		 MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ);
 
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened && reset)
-		mlx5e_close_locked(netdev);
+	reset = reset && test_bit(MLX5E_STATE_OPENED, &priv->state);
 
+	curr_mtu    = netdev->mtu;
 	netdev->mtu = new_mtu;
-	mlx5e_set_dev_port_mtu(netdev);
 
-	if (was_opened && reset)
-		err = mlx5e_open_locked(netdev);
+	if (!reset) {
+		mlx5e_set_dev_port_mtu(priv);
+		goto out;
+	}
 
-	mutex_unlock(&priv->state_lock);
+	new_channels.params = priv->channels.params;
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err) {
+		netdev->mtu = curr_mtu;
+		goto out;
+	}
+
+	mlx5e_switch_priv_channels(priv, &new_channels, mlx5e_set_dev_port_mtu);
 
+out:
+	mutex_unlock(&priv->state_lock);
 	return err;
 }
 
@@ -4169,7 +4189,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
 	netdev->max_mtu = MLX5E_HW2SW_MTU(max_mtu);
 
-	mlx5e_set_dev_port_mtu(netdev);
+	mlx5e_set_dev_port_mtu(priv);
 
 	if (profile->enable)
 		profile->enable(priv);
-- 
2.11.0
