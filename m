From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 5/7] net/mlx5e: Correctly handle RSS indirection table when changing number of channels
Date: Mon, 29 Feb 2016 21:17:13 +0200
Message-ID: <1456773435-16607-6-git-send-email-saeedm@mellanox.com>
References: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53136 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753874AbcB2TSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 14:18:18 -0500
In-Reply-To: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Upon changing num_channels, reset the RSS indirection table to
match the new value.

Fixes: 2d75b2bc8a8c ('net/mlx5e: Add ethtool RSS configuration options')
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    2 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   15 +++++++++++----
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 976bddb..d0a57d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -619,6 +619,8 @@ void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
+void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
+				   int num_channels);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5e_tx_wqe *wqe, int bf_sz)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 64af1b0..5abeb00 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -385,6 +385,8 @@ static int mlx5e_set_channels(struct net_device *dev,
 		mlx5e_close_locked(dev);
 
 	priv->params.num_channels = count;
+	mlx5e_build_default_indir_rqt(priv->params.indirection_rqt,
+				      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (was_opened)
 		err = mlx5e_open_locked(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 34b1049..02689ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1199,7 +1199,6 @@ static void mlx5e_fill_indir_rqt_rqns(struct mlx5e_priv *priv, void *rqtc)
 			ix = mlx5e_bits_invert(i, MLX5E_LOG_INDIR_RQT_SIZE);
 
 		ix = priv->params.indirection_rqt[ix];
-		ix = ix % priv->params.num_channels;
 		MLX5_SET(rqtc, rqtc, rq_num[i],
 			 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
 			 priv->channel[ix]->rq.rqn :
@@ -2101,12 +2100,20 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
 }
 
+void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
+				   int num_channels)
+{
+	int i;
+
+	for (i = 0; i < len; i++)
+		indirection_rqt[i] = i % num_channels;
+}
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_channels)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int i;
 
 	priv->params.log_sq_size           =
 		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
@@ -2130,8 +2137,8 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
 			    sizeof(priv->params.toeplitz_hash_key));
 
-	for (i = 0; i < MLX5E_INDIR_RQT_SIZE; i++)
-		priv->params.indirection_rqt[i] = i % num_channels;
+	mlx5e_build_default_indir_rqt(priv->params.indirection_rqt,
+				      MLX5E_INDIR_RQT_SIZE, num_channels);
 
 	priv->params.lro_wqe_sz            =
 		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
-- 
1.7.1
