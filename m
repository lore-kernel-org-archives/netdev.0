From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/14] net/mlx5e: Fail safe ethtool settings
Date: Mon, 27 Mar 2017 23:49:07 +0300
Message-ID: <20170327204910.20287-12-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44899 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752233AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new fail-safe channels switch mechanism to set new ethtool
settings:
 - ring parameters
 - coalesce parameters
 - tx copy break parameters

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 120 +++++++++++++--------
 1 file changed, 73 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index e5cee400a4d3..457a796cc248 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -457,8 +457,8 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int rq_wq_type = priv->channels.params.rq_wq_type;
+	struct mlx5e_channels new_channels = {};
 	u32 rx_pending_wqes;
-	bool was_opened;
 	u32 min_rq_size;
 	u32 max_rq_size;
 	u8 log_rq_size;
@@ -527,16 +527,22 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 
 	mutex_lock(&priv->state_lock);
 
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
-		mlx5e_close_locked(dev);
+	new_channels.params = priv->channels.params;
+	new_channels.params.log_rq_size = log_rq_size;
+	new_channels.params.log_sq_size = log_sq_size;
 
-	priv->channels.params.log_rq_size = log_rq_size;
-	priv->channels.params.log_sq_size = log_sq_size;
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		goto unlock;
+	}
 
-	if (was_opened)
-		err = mlx5e_open_locked(dev);
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto unlock;
+
+	mlx5e_switch_priv_channels(priv, &new_channels);
 
+unlock:
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -623,36 +629,13 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
-static int mlx5e_set_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *coal)
+static void
+mlx5e_set_priv_channels_coalesce(struct mlx5e_priv *priv, struct ethtool_coalesce *coal)
 {
-	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	bool restart =
-		!!coal->use_adaptive_rx_coalesce != priv->channels.params.rx_am_enabled;
-	bool was_opened;
-	int err = 0;
 	int tc;
 	int i;
 
-	if (!MLX5_CAP_GEN(mdev, cq_moderation))
-		return -EOPNOTSUPP;
-
-	mutex_lock(&priv->state_lock);
-
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened && restart) {
-		mlx5e_close_locked(netdev);
-		priv->channels.params.rx_am_enabled = !!coal->use_adaptive_rx_coalesce;
-	}
-
-	priv->channels.params.tx_cq_moderation.usec = coal->tx_coalesce_usecs;
-	priv->channels.params.tx_cq_moderation.pkts = coal->tx_max_coalesced_frames;
-	priv->channels.params.rx_cq_moderation.usec = coal->rx_coalesce_usecs;
-	priv->channels.params.rx_cq_moderation.pkts = coal->rx_max_coalesced_frames;
-
-	if (!was_opened || restart)
-		goto out;
 	for (i = 0; i < priv->channels.num; ++i) {
 		struct mlx5e_channel *c = priv->channels.c[i];
 
@@ -667,11 +650,50 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 					       coal->rx_coalesce_usecs,
 					       coal->rx_max_coalesced_frames);
 	}
+}
 
-out:
-	if (was_opened && restart)
-		err = mlx5e_open_locked(netdev);
+static int mlx5e_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_channels new_channels = {};
+	int err = 0;
+	bool reset;
 
+	if (!MLX5_CAP_GEN(mdev, cq_moderation))
+		return -EOPNOTSUPP;
+
+	mutex_lock(&priv->state_lock);
+	new_channels.params = priv->channels.params;
+
+	new_channels.params.tx_cq_moderation.usec = coal->tx_coalesce_usecs;
+	new_channels.params.tx_cq_moderation.pkts = coal->tx_max_coalesced_frames;
+	new_channels.params.rx_cq_moderation.usec = coal->rx_coalesce_usecs;
+	new_channels.params.rx_cq_moderation.pkts = coal->rx_max_coalesced_frames;
+	new_channels.params.rx_am_enabled         = !!coal->use_adaptive_rx_coalesce;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		goto out;
+	}
+	/* we are opened */
+
+	reset = !!coal->use_adaptive_rx_coalesce != priv->channels.params.rx_am_enabled;
+	if (!reset) {
+		mlx5e_set_priv_channels_coalesce(priv, coal);
+		priv->channels.params = new_channels.params;
+		goto out;
+	}
+
+	/* open fresh channels with new coal parameters */
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto out;
+
+	mlx5e_switch_priv_channels(priv, &new_channels);
+
+out:
 	mutex_unlock(&priv->state_lock);
 	return err;
 }
@@ -1119,9 +1141,11 @@ static int mlx5e_set_tunable(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	bool was_opened;
-	u32 val;
+	struct mlx5e_channels new_channels = {};
 	int err = 0;
+	u32 val;
+
+	mutex_lock(&priv->state_lock);
 
 	switch (tuna->id) {
 	case ETHTOOL_TX_COPYBREAK:
@@ -1131,24 +1155,26 @@ static int mlx5e_set_tunable(struct net_device *dev,
 			break;
 		}
 
-		mutex_lock(&priv->state_lock);
+		new_channels.params = priv->channels.params;
+		new_channels.params.tx_max_inline = val;
 
-		was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-		if (was_opened)
-			mlx5e_close_locked(dev);
-
-		priv->channels.params.tx_max_inline = val;
+		if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+			priv->channels.params = new_channels.params;
+			break;
+		}
 
-		if (was_opened)
-			err = mlx5e_open_locked(dev);
+		err = mlx5e_open_channels(priv, &new_channels);
+		if (err)
+			break;
+		mlx5e_switch_priv_channels(priv, &new_channels);
 
-		mutex_unlock(&priv->state_lock);
 		break;
 	default:
 		err = -EINVAL;
 		break;
 	}
 
+	mutex_unlock(&priv->state_lock);
 	return err;
 }
 
-- 
2.11.0
