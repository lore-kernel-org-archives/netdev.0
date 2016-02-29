From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 4/7] net/mlx5e: Fix ethtool RX hash func configuration change
Date: Mon, 29 Feb 2016 21:17:12 +0200
Message-ID: <1456773435-16607-5-git-send-email-saeedm@mellanox.com>
References: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53158 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752034AbcB2TSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 14:18:34 -0500
In-Reply-To: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

We should modify TIRs explicitly to apply the new RSS configuration.
The light ndo close/open calls do not "refresh" them.

Fixes: 2d75b2bc8a8c ('net/mlx5e: Add ethtool RSS configuration options')
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    3 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   34 ++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   27 +++++++++------
 include/linux/mlx5/mlx5_ifc.h                      |    4 ++-
 4 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 614a602..976bddb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -447,6 +447,8 @@ enum mlx5e_traffic_types {
 	MLX5E_NUM_TT,
 };
 
+#define IS_HASHING_TT(tt) (tt != MLX5E_TT_ANY)
+
 enum mlx5e_rqt_ix {
 	MLX5E_INDIRECTION_RQT,
 	MLX5E_SINGLE_RQ_RQT,
@@ -613,6 +615,7 @@ void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix);
+void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 65624ac..64af1b0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -703,18 +703,36 @@ static int mlx5e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 	return 0;
 }
 
+static void mlx5e_modify_tirs_hash(struct mlx5e_priv *priv, void *in, int inlen)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	void *tirc = MLX5_ADDR_OF(modify_tir_in, in, ctx);
+	int i;
+
+	MLX5_SET(modify_tir_in, in, bitmask.hash, 1);
+	mlx5e_build_tir_ctx_hash(tirc, priv);
+
+	for (i = 0; i < MLX5E_NUM_TT; i++)
+		if (IS_HASHING_TT(i))
+			mlx5_core_modify_tir(mdev, priv->tirn[i], in, inlen);
+}
+
 static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 			  const u8 *key, const u8 hfunc)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	bool close_open;
-	int err = 0;
+	int inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
+	void *in;
 
 	if ((hfunc != ETH_RSS_HASH_NO_CHANGE) &&
 	    (hfunc != ETH_RSS_HASH_XOR) &&
 	    (hfunc != ETH_RSS_HASH_TOP))
 		return -EINVAL;
 
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
 	mutex_lock(&priv->state_lock);
 
 	if (indir) {
@@ -723,11 +741,6 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 		mlx5e_redirect_rqt(priv, MLX5E_INDIRECTION_RQT);
 	}
 
-	close_open = (key || (hfunc != ETH_RSS_HASH_NO_CHANGE)) &&
-		     test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (close_open)
-		mlx5e_close_locked(dev);
-
 	if (key)
 		memcpy(priv->params.toeplitz_hash_key, key,
 		       sizeof(priv->params.toeplitz_hash_key));
@@ -735,12 +748,13 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE)
 		priv->params.rss_hfunc = hfunc;
 
-	if (close_open)
-		err = mlx5e_open_locked(priv->netdev);
+	mlx5e_modify_tirs_hash(priv, in, inlen);
 
 	mutex_unlock(&priv->state_lock);
 
-	return err;
+	kvfree(in);
+
+	return 0;
 }
 
 static int mlx5e_get_rxnfc(struct net_device *netdev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 137b05e..34b1049 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1317,6 +1317,21 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 			      lro_timer_supported_periods[2]));
 }
 
+void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv)
+{
+	MLX5_SET(tirc, tirc, rx_hash_fn,
+		 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
+	if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
+		void *rss_key = MLX5_ADDR_OF(tirc, tirc,
+					     rx_hash_toeplitz_key);
+		size_t len = MLX5_FLD_SZ_BYTES(tirc,
+					       rx_hash_toeplitz_key);
+
+		MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
+		memcpy(rss_key, priv->params.toeplitz_hash_key, len);
+	}
+}
+
 static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1677,17 +1692,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 	default:
 		MLX5_SET(tirc, tirc, indirect_table,
 			 priv->rqtn[MLX5E_INDIRECTION_RQT]);
-		MLX5_SET(tirc, tirc, rx_hash_fn,
-			 mlx5e_rx_hash_fn(priv->params.rss_hfunc));
-		if (priv->params.rss_hfunc == ETH_RSS_HASH_TOP) {
-			void *rss_key = MLX5_ADDR_OF(tirc, tirc,
-						     rx_hash_toeplitz_key);
-			size_t len = MLX5_FLD_SZ_BYTES(tirc,
-						       rx_hash_toeplitz_key);
-
-			MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
-			memcpy(rss_key, priv->params.toeplitz_hash_key, len);
-		}
+		mlx5e_build_tir_ctx_hash(tirc, priv);
 		break;
 	}
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 51f1e54..58eef02 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4245,7 +4245,9 @@ struct mlx5_ifc_modify_tir_bitmask_bits {
 
 	u8         reserved_at_20[0x1b];
 	u8         self_lb_en[0x1];
-	u8         reserved_at_3c[0x3];
+	u8         reserved_at_3c[0x1];
+	u8         hash[0x1];
+	u8         reserved_at_3e[0x1];
 	u8         lro[0x1];
 };
 
-- 
1.7.1
