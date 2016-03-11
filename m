From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/13] net/mlx5e: Change RX moderation period to be based on CQE
Date: Fri, 11 Mar 2016 15:39:50 +0200
Message-ID: <1457703594-9482-10-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33179 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753208AbcCKNkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:40:35 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In this mode the moderation timer will restart upon completion
generation rather than upon interrupt generation.
The outcome is that for bursty traffic the period timer will never
expire and thus only the moderation frames counter will dictate
interrupt generation, thus the interrupt rate will be relative
to the incoming packets size.
If the burst seizes for "moderation period" time then an interrupt
will be issued immediately.

Performance tested on ConnectX4-Lx 50G.

Less packet loss in netperf and pktgen tests, with no bw degradation.

For example:
pktgen single flow, 16 sender threads, 8K (64B) packets bursts each:
we see improvment from 30% packet loss to 17%.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   14 ++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                     |    9 +++++++--
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 930d52a..77bf54c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -77,6 +77,7 @@
 
 #define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC      0x10
+#define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE 0x3
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS      0x20
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC      0x10
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS      0x20
@@ -388,6 +389,7 @@ struct mlx5e_params {
 	u8  log_rq_size;
 	u16 num_channels;
 	u8  num_tc;
+	u8  rx_cq_period_mode;
 	u16 rx_cq_moderation_usec;
 	u16 rx_cq_moderation_pkts;
 	u16 tx_cq_moderation_usec;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index aa1bd54..784962c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -55,6 +55,7 @@ struct mlx5e_cq_param {
 	u32                        cqc[MLX5_ST_SZ_DW(cqc)];
 	struct mlx5_wq_param       wq;
 	u16                        eq_ix;
+	u8                         cq_period_mode;
 };
 
 struct mlx5e_channel_param {
@@ -903,6 +904,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 	mlx5_vector2eqn(mdev, param->eq_ix, &eqn, &irqn_not_used);
 
+	MLX5_SET(cqc,   cqc, cq_period_mode, param->cq_period_mode);
 	MLX5_SET(cqc,   cqc, c_eqn,         eqn);
 	MLX5_SET(cqc,   cqc, uar_page,      mcq->uar->index);
 	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.buf.page_shift -
@@ -1226,6 +1228,8 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	MLX5_SET(cqc, cqc, log_cq_size, log_cq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = priv->params.rx_cq_period_mode;
 }
 
 static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
@@ -1236,6 +1240,8 @@ static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
 	MLX5_SET(cqc, cqc, log_cq_size, priv->params.log_sq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 }
 
 static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
@@ -1247,6 +1253,8 @@ static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
 	MLX5_SET(cqc, cqc, log_cq_size, log_wq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
+
+	param->cq_period_mode = MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 }
 
 static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
@@ -2492,7 +2500,13 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 
 	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
 					    BIT(priv->params.log_rq_size));
+	priv->params.rx_cq_period_mode =
+		MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
+		MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
+		MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
 	priv->params.rx_cq_moderation_usec =
+		MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
+		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE :
 		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC;
 	priv->params.rx_cq_moderation_pkts =
 		MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS;
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index d39dd31..37cc13a 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -779,7 +779,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         block_lb_mc[0x1];
 	u8         reserved_at_228[0x1];
 	u8         scqe_break_moderation[0x1];
-	u8         reserved_at_22a[0x1];
+	u8         cq_period_start_from_cqe[0x1];
 	u8         cd[0x1];
 	u8         reserved_at_22c[0x1];
 	u8         apm[0x1];
@@ -2547,6 +2547,11 @@ enum {
 	MLX5_CQC_ST_FIRED                                 = 0xa,
 };
 
+enum {
+	MLX5_CQ_PERIOD_MODE_START_FROM_EQE = 0x0,
+	MLX5_CQ_PERIOD_MODE_START_FROM_CQE = 0x1,
+};
+
 struct mlx5_ifc_cqc_bits {
 	u8         status[0x4];
 	u8         reserved_at_4[0x4];
@@ -2555,7 +2560,7 @@ struct mlx5_ifc_cqc_bits {
 	u8         reserved_at_c[0x1];
 	u8         scqe_break_moderation_en[0x1];
 	u8         oi[0x1];
-	u8         reserved_at_f[0x2];
+	u8         cq_period_mode[0x2];
 	u8         cqe_zip_en[0x1];
 	u8         mini_cqe_res_format[0x2];
 	u8         st[0x4];
-- 
1.7.1
