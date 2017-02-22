From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/6] net/mlx5e: Do not reduce LRO WQE size when not using build_skb
Date: Wed, 22 Feb 2017 17:20:13 +0200
Message-ID: <20170222152016.31263-4-saeedm@mellanox.com>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57754 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933002AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

When rq_type is Striding RQ, no room of SKB_RESERVE is needed
as SKB allocation is not done via build_skb.

Fixes: e4b85508072b ("net/mlx5e: Slightly reduce hardware LRO size")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c24366868b39..0d58729b42ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -82,6 +82,7 @@ static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
 static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 {
 	priv->params.rq_wq_type = rq_type;
+	priv->params.lro_wqe_sz = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		priv->params.log_rq_size = is_kdump_kernel() ?
@@ -98,6 +99,10 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 		priv->params.log_rq_size = is_kdump_kernel() ?
 			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE :
 			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
+
+		/* Extra room needed for build_skb */
+		priv->params.lro_wqe_sz -= MLX5_RX_HEADROOM +
+			SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	}
 	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
 					       BIT(priv->params.log_rq_size));
@@ -3547,12 +3552,6 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	mlx5e_build_default_indir_rqt(mdev, priv->params.indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, profile->max_nch(mdev));
 
-	priv->params.lro_wqe_sz =
-		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ -
-		/* Extra room needed for build_skb */
-		MLX5_RX_HEADROOM -
-		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-
 	/* Initialize pflags */
 	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
 			priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
-- 
2.11.0
