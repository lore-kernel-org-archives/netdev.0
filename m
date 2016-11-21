From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx5: Enable to query min inline for a specific vport
Date: Mon, 21 Nov 2016 15:05:59 +0200
Message-ID: <1479733561-26601-6-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46914 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932308AbcKUNHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:16 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Also move the inline capablities enum to a shared header vport.h

Signed-off-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  6 ------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 11 +++++------
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 14 ++++++++------
 include/linux/mlx5/vport.h                        | 10 ++++++++--
 4 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ebf5dbc..a2b32ed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -150,12 +150,6 @@ static inline int mlx5_max_log_rq_size(int wq_type)
 	}
 }
 
-enum {
-	MLX5E_INLINE_MODE_L2,
-	MLX5E_INLINE_MODE_VPORT_CONTEXT,
-	MLX5_INLINE_MODE_NOT_REQUIRED,
-};
-
 struct mlx5e_tx_wqe {
 	struct mlx5_wqe_ctrl_seg ctrl;
 	struct mlx5_wqe_eth_seg  eth;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 480875f..d25bc0f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -952,7 +952,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
 	sq->min_inline_mode =
-		MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5E_INLINE_MODE_VPORT_CONTEXT ?
+		MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5_CAP_INLINE_MODE_VPORT_CONTEXT ?
 		param->min_inline_mode : 0;
 
 	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
@@ -3403,14 +3403,13 @@ static void mlx5e_query_min_inline(struct mlx5_core_dev *mdev,
 				   u8 *min_inline_mode)
 {
 	switch (MLX5_CAP_ETH(mdev, wqe_inline_mode)) {
-	case MLX5E_INLINE_MODE_L2:
+	case MLX5_CAP_INLINE_MODE_L2:
 		*min_inline_mode = MLX5_INLINE_MODE_L2;
 		break;
-	case MLX5E_INLINE_MODE_VPORT_CONTEXT:
-		mlx5_query_nic_vport_min_inline(mdev,
-						min_inline_mode);
+	case MLX5_CAP_INLINE_MODE_VPORT_CONTEXT:
+		mlx5_query_nic_vport_min_inline(mdev, 0, min_inline_mode);
 		break;
-	case MLX5_INLINE_MODE_NOT_REQUIRED:
+	case MLX5_CAP_INLINE_MODE_NOT_REQUIRED:
 		*min_inline_mode = MLX5_INLINE_MODE_NONE;
 		break;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 525f17a..269e440 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -113,15 +113,17 @@ static int mlx5_modify_nic_vport_context(struct mlx5_core_dev *mdev, void *in,
 	return mlx5_cmd_exec(mdev, in, inlen, out, sizeof(out));
 }
 
-void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
-				     u8 *min_inline_mode)
+int mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				    u16 vport, u8 *min_inline)
 {
 	u32 out[MLX5_ST_SZ_DW(query_nic_vport_context_out)] = {0};
+	int err;
 
-	mlx5_query_nic_vport_context(mdev, 0, out, sizeof(out));
-
-	*min_inline_mode = MLX5_GET(query_nic_vport_context_out, out,
-				    nic_vport_context.min_wqe_inline_mode);
+	err = mlx5_query_nic_vport_context(mdev, vport, out, sizeof(out));
+	if (!err)
+		*min_inline = MLX5_GET(query_nic_vport_context_out, out,
+				       nic_vport_context.min_wqe_inline_mode);
+	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_min_inline);
 
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 451b0bd..ec35157 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -36,6 +36,12 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/device.h>
 
+enum {
+	MLX5_CAP_INLINE_MODE_L2,
+	MLX5_CAP_INLINE_MODE_VPORT_CONTEXT,
+	MLX5_CAP_INLINE_MODE_NOT_REQUIRED,
+};
+
 u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod, u16 vport);
 u8 mlx5_query_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
 				u16 vport);
@@ -43,8 +49,8 @@ int mlx5_modify_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
 				  u16 vport, u8 state);
 int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
-void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
-				     u8 *min_inline);
+int mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				    u16 vport, u8 *min_inline);
 int mlx5_modify_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 min_inline);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
-- 
2.7.4
