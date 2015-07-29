From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5e: Remove the mlx5e_update_priv_params() function
Date: Wed, 29 Jul 2015 15:05:46 +0300
Message-ID: <1438171546-17021-9-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53810 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751905AbbG2MGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:06:30 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

It was used to update netdev priv parameters that require stopping
and re-opening the device in a generic way - it got the new
parameters and did: ndo_stop(), copy new parameters into current
parameters, ndo_open().

We chose to remove it for two reasons:
1) It requires additional instance of struct mlx5e_params on the
   stack and looking forward we expect this struct to grow.
2) Sometimes we want to do additional operations (besides
   just updating the priv parameters) while the netdev is stopped.
   For example, updating netdev->mtu @mlx5e_change_mtu() should
   be done while the netdev is stopped (done in this commit).

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 -
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 57 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 51 ++++++++-----------
 3 files changed, 60 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7b5a679..45f6dc7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -496,8 +496,6 @@ void mlx5e_del_all_vlan_rules(struct mlx5e_priv *priv);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
-int mlx5e_update_priv_params(struct mlx5e_priv *priv,
-			     struct mlx5e_params *new_params);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5e_tx_wqe *wqe, int bf_sz)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index f4a7534..b95aa33 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -264,7 +264,7 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5e_params new_params;
+	bool was_opened;
 	u16 min_rx_wqes;
 	u8 log_rq_size;
 	u8 log_sq_size;
@@ -316,11 +316,18 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 		return 0;
 
 	mutex_lock(&priv->state_lock);
-	new_params = priv->params;
-	new_params.log_rq_size = log_rq_size;
-	new_params.log_sq_size = log_sq_size;
-	new_params.min_rx_wqes = min_rx_wqes;
-	err = mlx5e_update_priv_params(priv, &new_params);
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (was_opened)
+		mlx5e_close_locked(dev);
+
+	priv->params.log_rq_size = log_rq_size;
+	priv->params.log_sq_size = log_sq_size;
+	priv->params.min_rx_wqes = min_rx_wqes;
+
+	if (was_opened)
+		err = mlx5e_open_locked(dev);
+
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -342,7 +349,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int ncv = priv->mdev->priv.eq_table.num_comp_vectors;
 	unsigned int count = ch->combined_count;
-	struct mlx5e_params new_params;
+	bool was_opened;
 	int err = 0;
 
 	if (!count) {
@@ -365,9 +372,16 @@ static int mlx5e_set_channels(struct net_device *dev,
 		return 0;
 
 	mutex_lock(&priv->state_lock);
-	new_params = priv->params;
-	new_params.num_channels = count;
-	err = mlx5e_update_priv_params(priv, &new_params);
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (was_opened)
+		mlx5e_close_locked(dev);
+
+	priv->params.num_channels = count;
+
+	if (was_opened)
+		err = mlx5e_open_locked(dev);
+
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -673,10 +687,10 @@ static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	return 0;
 }
 
-static int mlx5e_set_rxfh(struct net_device *netdev, const u32 *indir,
+static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 			  const u8 *key, const u8 hfunc)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_priv *priv = netdev_priv(dev);
 	int err = 0;
 
 	if (hfunc == ETH_RSS_HASH_NO_CHANGE)
@@ -690,8 +704,8 @@ static int mlx5e_set_rxfh(struct net_device *netdev, const u32 *indir,
 
 	priv->params.rss_hfunc = hfunc;
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
-		mlx5e_close_locked(priv->netdev);
-		err = mlx5e_open_locked(priv->netdev);
+		mlx5e_close_locked(dev);
+		err = mlx5e_open_locked(dev);
 	}
 
 	mutex_unlock(&priv->state_lock);
@@ -724,7 +738,7 @@ static int mlx5e_set_tunable(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5e_params new_params;
+	bool was_opened;
 	u32 val;
 	int err = 0;
 
@@ -737,9 +751,16 @@ static int mlx5e_set_tunable(struct net_device *dev,
 		}
 
 		mutex_lock(&priv->state_lock);
-		new_params = priv->params;
-		new_params.tx_max_inline = val;
-		err = mlx5e_update_priv_params(priv, &new_params);
+
+		was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+		if (was_opened)
+			mlx5e_close_locked(dev);
+
+		priv->params.tx_max_inline = val;
+
+		if (was_opened)
+			err = mlx5e_open_locked(dev);
+
 		mutex_unlock(&priv->state_lock);
 		break;
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8ddb2a0..bb81589 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1570,26 +1570,6 @@ static int mlx5e_close(struct net_device *netdev)
 	return err;
 }
 
-int mlx5e_update_priv_params(struct mlx5e_priv *priv,
-			     struct mlx5e_params *new_params)
-{
-	int err = 0;
-	int was_opened;
-
-	WARN_ON(!mutex_is_locked(&priv->state_lock));
-
-	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
-		mlx5e_close_locked(priv->netdev);
-
-	priv->params = *new_params;
-
-	if (was_opened)
-		err = mlx5e_open_locked(priv->netdev);
-
-	return err;
-}
-
 static struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
@@ -1639,20 +1619,22 @@ static int mlx5e_set_features(struct net_device *netdev,
 			      netdev_features_t features)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err = 0;
 	netdev_features_t changes = features ^ netdev->features;
-	struct mlx5e_params new_params;
-	bool update_params = false;
 
 	mutex_lock(&priv->state_lock);
-	new_params = priv->params;
 
 	if (changes & NETIF_F_LRO) {
-		new_params.lro_en = !!(features & NETIF_F_LRO);
-		update_params = true;
-	}
+		bool was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+
+		if (was_opened)
+			mlx5e_close_locked(priv->netdev);
 
-	if (update_params)
-		mlx5e_update_priv_params(priv, &new_params);
+		priv->params.lro_en = !!(features & NETIF_F_LRO);
+
+		if (was_opened)
+			err = mlx5e_open_locked(priv->netdev);
+	}
 
 	if (changes & NETIF_F_HW_VLAN_CTAG_FILTER) {
 		if (features & NETIF_F_HW_VLAN_CTAG_FILTER)
@@ -1670,8 +1652,9 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
+	bool was_opened;
 	int max_mtu;
-	int err;
+	int err = 0;
 
 	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 
@@ -1683,8 +1666,16 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	mutex_lock(&priv->state_lock);
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (was_opened)
+		mlx5e_close_locked(netdev);
+
 	netdev->mtu = new_mtu;
-	err = mlx5e_update_priv_params(priv, &priv->params);
+
+	if (was_opened)
+		err = mlx5e_open_locked(netdev);
+
 	mutex_unlock(&priv->state_lock);
 
 	return err;
-- 
2.4.3.413.ga5fe668
