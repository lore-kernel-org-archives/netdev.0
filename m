From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 04/13] net/mlx5e: Use only close NUMA node for default RSS
Date: Fri, 11 Mar 2016 15:39:45 +0200
Message-ID: <1457703594-9482-5-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33158 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932071AbcCKNkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:40:31 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Distribute default RSS table uniformely over the rings of the
close NUMA node, instead of all available channels.
This way we enforce the preference of close rings over far ones.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    3 ++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   15 +++++++++++++--
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5ef91a9..f4bf470 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -671,7 +671,8 @@ void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv);
 
 int mlx5e_open_locked(struct net_device *netdev);
 int mlx5e_close_locked(struct net_device *netdev);
-void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
+void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
+				   u32 *indirection_rqt, int len,
 				   int num_channels);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 39c1902..6f40ba4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -397,7 +397,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 		mlx5e_close_locked(dev);
 
 	priv->params.num_channels = count;
-	mlx5e_build_default_indir_rqt(priv->params.indirection_rqt,
+	mlx5e_build_default_indir_rqt(priv->mdev, priv->params.indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (was_opened)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7fbe1ba..9b58ef6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2297,11 +2297,22 @@ static void mlx5e_ets_init(struct mlx5e_priv *priv)
 }
 #endif
 
-void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
+void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
+				   u32 *indirection_rqt, int len,
 				   int num_channels)
 {
+	int node = mdev->priv.numa_node;
+	int node_num_of_cores;
 	int i;
 
+	if (node == -1)
+		node = first_online_node;
+
+	node_num_of_cores = cpumask_weight(cpumask_of_node(node));
+
+	if (node_num_of_cores)
+		num_channels = min_t(int, num_channels, node_num_of_cores);
+
 	for (i = 0; i < len; i++)
 		indirection_rqt[i] = i % num_channels;
 }
@@ -2333,7 +2344,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
 			    sizeof(priv->params.toeplitz_hash_key));
 
-	mlx5e_build_default_indir_rqt(priv->params.indirection_rqt,
+	mlx5e_build_default_indir_rqt(mdev, priv->params.indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, num_channels);
 
 	priv->params.lro_wqe_sz            =
-- 
1.7.1
