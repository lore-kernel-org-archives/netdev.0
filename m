From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5e: Add ethtool RSS configuration options
Date: Sun, 16 Aug 2015 16:04:47 +0300
Message-ID: <1439730292-29617-4-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38379 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751313AbbHPNHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:02 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- get_rxfh_key_size
- get_rxfh_indir_size
- get/set_rxfh indirection table and RSS Toeplitz hash key
- get_rxnfc

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  7 ++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 71 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  7 ++-
 3 files changed, 74 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0b8a2703..3b659c3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -272,9 +272,10 @@ struct mlx5e_params {
 	u16 min_rx_wqes;
 	bool lro_en;
 	u32 lro_wqe_sz;
-	u8  rss_hfunc;
 	u16 tx_max_inline;
-	u8 toeplitz_hash_key[40];
+	u8  rss_hfunc;
+	u8  toeplitz_hash_key[40];
+	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
 };
 
 enum {
@@ -571,6 +572,8 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
+int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix);
+
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index b549797..9758285 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -684,11 +684,31 @@ out:
 	return err;
 }
 
+static u32 mlx5e_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	return sizeof(priv->params.toeplitz_hash_key);
+}
+
+static u32 mlx5e_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return MLX5E_INDIR_RQT_SIZE;
+}
+
 static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 			  u8 *hfunc)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	if (indir)
+		memcpy(indir, priv->params.indirection_rqt,
+		       sizeof(priv->params.indirection_rqt));
+
+	if (key)
+		memcpy(key, priv->params.toeplitz_hash_key,
+		       sizeof(priv->params.toeplitz_hash_key));
+
 	if (hfunc)
 		*hfunc = priv->params.rss_hfunc;
 
@@ -699,28 +719,60 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 			  const u8 *key, const u8 hfunc)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	bool close_open;
 	int err = 0;
 
-	if (hfunc == ETH_RSS_HASH_NO_CHANGE)
-		return 0;
-
-	if ((hfunc != ETH_RSS_HASH_XOR) &&
+	if ((hfunc != ETH_RSS_HASH_NO_CHANGE) &&
+	    (hfunc != ETH_RSS_HASH_XOR) &&
 	    (hfunc != ETH_RSS_HASH_TOP))
 		return -EINVAL;
 
 	mutex_lock(&priv->state_lock);
 
-	priv->params.rss_hfunc = hfunc;
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
-		mlx5e_close_locked(dev);
-		err = mlx5e_open_locked(dev);
+	if (indir) {
+		memcpy(priv->params.indirection_rqt, indir,
+		       sizeof(priv->params.indirection_rqt));
+		mlx5e_redirect_rqt(priv, MLX5E_INDIRECTION_RQT);
 	}
 
+	close_open = (key || (hfunc != ETH_RSS_HASH_NO_CHANGE)) &&
+		     test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (close_open)
+		mlx5e_close_locked(dev);
+
+	if (key)
+		memcpy(priv->params.toeplitz_hash_key, key,
+		       sizeof(priv->params.toeplitz_hash_key));
+
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE)
+		priv->params.rss_hfunc = hfunc;
+
+	if (close_open)
+		err = mlx5e_open_locked(priv->netdev);
+
 	mutex_unlock(&priv->state_lock);
 
 	return err;
 }
 
+static int mlx5e_get_rxnfc(struct net_device *netdev,
+			   struct ethtool_rxnfc *info, u32 *rule_locs)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err = 0;
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = priv->params.num_channels;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static int mlx5e_get_tunable(struct net_device *dev,
 			     const struct ethtool_tunable *tuna,
 			     void *data)
@@ -793,8 +845,11 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_coalesce      = mlx5e_set_coalesce,
 	.get_settings      = mlx5e_get_settings,
 	.set_settings      = mlx5e_set_settings,
+	.get_rxfh_key_size   = mlx5e_get_rxfh_key_size,
+	.get_rxfh_indir_size = mlx5e_get_rxfh_indir_size,
 	.get_rxfh          = mlx5e_get_rxfh,
 	.set_rxfh          = mlx5e_set_rxfh,
+	.get_rxnfc         = mlx5e_get_rxnfc,
 	.get_tunable       = mlx5e_get_tunable,
 	.set_tunable       = mlx5e_set_tunable,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bc36f9b..2b48ff0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1184,6 +1184,7 @@ static void mlx5e_fill_indir_rqt_rqns(struct mlx5e_priv *priv, void *rqtc)
 		if (priv->params.rss_hfunc == ETH_RSS_HASH_XOR)
 			ix = mlx5e_bits_invert(i, MLX5E_LOG_INDIR_RQT_SIZE);
 
+		ix = priv->params.indirection_rqt[ix];
 		ix = ix % priv->params.num_channels;
 		MLX5_SET(rqtc, rqtc, rq_num[i],
 			 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
@@ -1242,7 +1243,7 @@ static int mlx5e_create_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 	return err;
 }
 
-static int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
+int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 *in;
@@ -1912,6 +1913,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    int num_channels)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int i;
 
 	priv->params.log_sq_size           =
 		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
@@ -1935,6 +1937,9 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
 			    sizeof(priv->params.toeplitz_hash_key));
 
+	for (i = 0; i < MLX5E_INDIR_RQT_SIZE; i++)
+		priv->params.indirection_rqt[i] = i % num_channels;
+
 	priv->params.lro_en = false && !!MLX5_CAP_ETH(priv->mdev, lro_cap);
 	priv->params.lro_wqe_sz            =
 		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
-- 
1.8.3.1
