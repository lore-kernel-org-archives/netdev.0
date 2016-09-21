From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 4/8] net/mlx5e: Dynamic RQ type infrastructure
Date: Wed, 21 Sep 2016 12:19:45 +0300
Message-ID: <1474449589-27035-5-git-send-email-tariqt@mellanox.com>
References: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41599 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932911AbcIUJUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:20:40 -0400
In-Reply-To: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Add two helper functions to allow dynamic changes of RQ type.

mlx5e_set_rq_priv_params and mlx5e_set_rq_type_params will be
used on netdev creation to determine the default RQ type.

This will be needed later for downstream patches of XDP support.
When enabling XDP we will dynamically move from striding RQ to
linked list RQ type.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 92 ++++++++++++-----------
 1 file changed, 50 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8734240865e1..ff520ad27f5e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -69,6 +69,47 @@ struct mlx5e_channel_param {
 	struct mlx5e_cq_param      icosq_cq;
 };
 
+static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
+{
+	return MLX5_CAP_GEN(mdev, striding_rq) &&
+		MLX5_CAP_GEN(mdev, umr_ptr_rlky) &&
+		MLX5_CAP_ETH(mdev, reg_umr_sq);
+}
+
+static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
+{
+	priv->params.rq_wq_type = rq_type;
+	switch (priv->params.rq_wq_type) {
+	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
+		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
+		priv->params.mpwqe_log_stride_sz = priv->params.rx_cqe_compress ?
+			MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS :
+			MLX5_MPWRQ_LOG_STRIDE_SIZE;
+		priv->params.mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
+			priv->params.mpwqe_log_stride_sz;
+		break;
+	default: /* MLX5_WQ_TYPE_LINKED_LIST */
+		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
+	}
+	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
+					       BIT(priv->params.log_rq_size));
+
+	mlx5_core_info(priv->mdev,
+		       "MLX5E: StrdRq(%d) RqSz(%ld) StrdSz(%ld) RxCqeCmprss(%d)\n",
+		       priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ,
+		       BIT(priv->params.log_rq_size),
+		       BIT(priv->params.mpwqe_log_stride_sz),
+		       priv->params.rx_cqe_compress_admin);
+}
+
+static void mlx5e_set_rq_priv_params(struct mlx5e_priv *priv)
+{
+	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(priv->mdev) ?
+		    MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
+		    MLX5_WQ_TYPE_LINKED_LIST;
+	mlx5e_set_rq_type_params(priv, rq_type);
+}
+
 static void mlx5e_update_carrier(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -3038,13 +3079,6 @@ void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 		indirection_rqt[i] = i % num_channels;
 }
 
-static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
-{
-	return MLX5_CAP_GEN(mdev, striding_rq) &&
-		MLX5_CAP_GEN(mdev, umr_ptr_rlky) &&
-		MLX5_CAP_ETH(mdev, reg_umr_sq);
-}
-
 static int mlx5e_get_pci_bw(struct mlx5_core_dev *mdev, u32 *pci_bw)
 {
 	enum pcie_link_width width;
@@ -3124,11 +3158,13 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 					 MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
 					 MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 
-	priv->params.log_sq_size           =
-		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
-	priv->params.rq_wq_type = mlx5e_check_fragmented_striding_rq_cap(mdev) ?
-		MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
-		MLX5_WQ_TYPE_LINKED_LIST;
+	priv->mdev                         = mdev;
+	priv->netdev                       = netdev;
+	priv->params.num_channels          = profile->max_nch(mdev);
+	priv->profile                      = profile;
+	priv->ppriv                        = ppriv;
+
+	priv->params.log_sq_size = MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
 
 	/* set CQE compression */
 	priv->params.rx_cqe_compress_admin = false;
@@ -3141,33 +3177,11 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 		priv->params.rx_cqe_compress_admin =
 			cqe_compress_heuristic(link_speed, pci_bw);
 	}
-
 	priv->params.rx_cqe_compress = priv->params.rx_cqe_compress_admin;
 
-	switch (priv->params.rq_wq_type) {
-	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
-		priv->params.mpwqe_log_stride_sz =
-			priv->params.rx_cqe_compress ?
-			MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS :
-			MLX5_MPWRQ_LOG_STRIDE_SIZE;
-		priv->params.mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
-			priv->params.mpwqe_log_stride_sz;
+	mlx5e_set_rq_priv_params(priv);
+	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		priv->params.lro_en = true;
-		break;
-	default: /* MLX5_WQ_TYPE_LINKED_LIST */
-		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
-	}
-
-	mlx5_core_info(mdev,
-		       "MLX5E: StrdRq(%d) RqSz(%ld) StrdSz(%ld) RxCqeCmprss(%d)\n",
-		       priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ,
-		       BIT(priv->params.log_rq_size),
-		       BIT(priv->params.mpwqe_log_stride_sz),
-		       priv->params.rx_cqe_compress_admin);
-
-	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
-					    BIT(priv->params.log_rq_size));
 
 	priv->params.rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
 	mlx5e_set_rx_cq_mode_params(&priv->params, cq_period_mode);
@@ -3197,12 +3211,6 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	MLX5E_SET_PRIV_FLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
 			    priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
 
-	priv->mdev                         = mdev;
-	priv->netdev                       = netdev;
-	priv->params.num_channels          = profile->max_nch(mdev);
-	priv->profile                      = profile;
-	priv->ppriv                        = ppriv;
-
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	mlx5e_ets_init(priv);
 #endif
-- 
1.8.3.1
