From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 17/17] net/mlx5e: Distribute RSS table among all RX rings
Date: Sun,  3 Sep 2017 07:21:17 +0300
Message-ID: <20170903042117.28923-18-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60128 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750904AbdICEWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:16 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In default, uniformly distribute the RSS indirection table entries
among all RX rings, rather than restricting this only to the rings
on the close NUMA node. irqbalancer would anyway dynamically override
the default affinities set to the RX rings.
This gives better multi-stream performance and CPU util.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 15 ++-------------
 3 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1388a1e2f835..8b7d83bcc11a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -925,8 +925,7 @@ void mlx5e_switch_priv_channels(struct mlx5e_priv *priv,
 void mlx5e_activate_priv_channels(struct mlx5e_priv *priv);
 void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv);
 
-void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
-				   u32 *indirection_rqt, int len,
+void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
 				   int num_channels);
 int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 6127e0d2f310..d12e9fc0d76b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -663,8 +663,7 @@ int mlx5e_ethtool_set_channels(struct mlx5e_priv *priv,
 	new_channels.params = priv->channels.params;
 	new_channels.params.num_channels = count;
 	if (!netif_is_rxfh_configured(priv->netdev))
-		mlx5e_build_default_indir_rqt(priv->mdev,
-					      new_channels.params.indirection_rqt,
+		mlx5e_build_default_indir_rqt(new_channels.params.indirection_rqt,
 					      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 20f34131d4e5..77068609a153 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3833,22 +3833,11 @@ u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
 	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
 }
 
-void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
-				   u32 *indirection_rqt, int len,
+void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
 				   int num_channels)
 {
-	int node = mdev->priv.numa_node;
-	int node_num_of_cores;
 	int i;
 
-	if (node == -1)
-		node = first_online_node;
-
-	node_num_of_cores = cpumask_weight(cpumask_of_node(node));
-
-	if (node_num_of_cores)
-		num_channels = min_t(int, num_channels, node_num_of_cores);
-
 	for (i = 0; i < len; i++)
 		indirection_rqt[i] = i % num_channels;
 }
@@ -3987,7 +3976,7 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	/* RSS */
 	params->rss_hfunc = ETH_RSS_HASH_XOR;
 	netdev_rss_key_fill(params->toeplitz_hash_key, sizeof(params->toeplitz_hash_key));
-	mlx5e_build_default_indir_rqt(mdev, params->indirection_rqt,
+	mlx5e_build_default_indir_rqt(params->indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, max_channels);
 }
 
-- 
2.13.0
