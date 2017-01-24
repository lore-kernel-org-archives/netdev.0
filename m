From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/12] net/mlx5: Push min-inline mode resolution helper into the core
Date: Tue, 24 Jan 2017 22:16:49 +0200
Message-ID: <20170124201652.2920-10-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54293 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750973AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

So we can use that from the IB driver too in downstream patches.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 +-----------------
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 17 +++++++++++++++++
 include/linux/mlx5/vport.h                        |  1 +
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c819d07fbdb3..636372873e64 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3458,22 +3458,6 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE;
 }
 
-static void mlx5e_query_min_inline(struct mlx5_core_dev *mdev,
-				   u8 *min_inline_mode)
-{
-	switch (MLX5_CAP_ETH(mdev, wqe_inline_mode)) {
-	case MLX5_CAP_INLINE_MODE_L2:
-		*min_inline_mode = MLX5_INLINE_MODE_L2;
-		break;
-	case MLX5_CAP_INLINE_MODE_VPORT_CONTEXT:
-		mlx5_query_nic_vport_min_inline(mdev, 0, min_inline_mode);
-		break;
-	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
-		*min_inline_mode = MLX5_INLINE_MODE_NONE;
-		break;
-	}
-}
-
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
 {
 	int i;
@@ -3533,7 +3517,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.tx_cq_moderation.pkts =
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
 	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
-	mlx5e_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
+	mlx5_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
 	priv->params.num_tc                = 1;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 269e4401c342..b49cfc895c10 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -127,6 +127,23 @@ int mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_min_inline);
 
+void mlx5_query_min_inline(struct mlx5_core_dev *mdev,
+			   u8 *min_inline_mode)
+{
+	switch (MLX5_CAP_ETH(mdev, wqe_inline_mode)) {
+	case MLX5_CAP_INLINE_MODE_L2:
+		*min_inline_mode = MLX5_INLINE_MODE_L2;
+		break;
+	case MLX5_CAP_INLINE_MODE_VPORT_CONTEXT:
+		mlx5_query_nic_vport_min_inline(mdev, 0, min_inline_mode);
+		break;
+	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
+		*min_inline_mode = MLX5_INLINE_MODE_NONE;
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(mlx5_query_min_inline);
+
 int mlx5_modify_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 min_inline)
 {
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index ec35157ea725..656c70b65dd2 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -51,6 +51,7 @@ int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
 int mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 				    u16 vport, u8 *min_inline);
+void mlx5_query_min_inline(struct mlx5_core_dev *mdev, u8 *min_inline);
 int mlx5_modify_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 min_inline);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
-- 
2.11.0
