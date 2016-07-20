From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx5e: Query minimum required header copy during xmit
Date: Thu, 21 Jul 2016 01:20:02 +0300
Message-ID: <1469053202-30649-3-git-send-email-saeedm@mellanox.com>
References: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47751 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755308AbcGTWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:20:07 -0400
In-Reply-To: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Add support for query the minimum inline mode from the Firmware.
It is required for correct TX steering according to L3/L4 packet
headers.

Each send queue (SQ) has inline mode that defines the minimal required
headers that needs to be copied into the SQ WQE.
The driver asks the Firmware for the wqe_inline_mode device capability
value.  In case the device capability defined as "vport context" the
driver must check the reported min inline mode from the vport context
before creating its SQs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 24 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 18 +++++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                     | 10 +++++++---
 include/linux/mlx5/vport.h                        |  2 ++
 5 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 2c20c7b..1b495ef 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -129,6 +129,12 @@ static inline int mlx5_max_log_rq_size(int wq_type)
 	}
 }
 
+enum {
+	MLX5E_INLINE_MODE_L2,
+	MLX5E_INLINE_MODE_VPORT_CONTEXT,
+	MLX5_INLINE_MODE_NOT_REQUIRED,
+};
+
 struct mlx5e_tx_wqe {
 	struct mlx5_wqe_ctrl_seg ctrl;
 	struct mlx5_wqe_eth_seg  eth;
@@ -188,6 +194,7 @@ struct mlx5e_params {
 	bool lro_en;
 	u32 lro_wqe_sz;
 	u16 tx_max_inline;
+	u8  tx_min_inline_mode;
 	u8  rss_hfunc;
 	u8  toeplitz_hash_key[40];
 	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 611ab55..ca7b1e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -56,6 +56,7 @@ struct mlx5e_sq_param {
 	u32                        sqc[MLX5_ST_SZ_DW(sqc)];
 	struct mlx5_wq_param       wq;
 	u16                        max_inline;
+	u8                         min_inline_mode;
 	bool                       icosq;
 };
 
@@ -649,6 +650,9 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	}
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
+	sq->min_inline_mode =
+		MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5E_INLINE_MODE_VPORT_CONTEXT ?
+		param->min_inline_mode : 0;
 
 	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
 	if (err)
@@ -731,6 +735,7 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 
 	MLX5_SET(sqc,  sqc, tis_num_0, param->icosq ? 0 : priv->tisn[sq->tc]);
 	MLX5_SET(sqc,  sqc, cqn,		sq->cq.mcq.cqn);
+	MLX5_SET(sqc,  sqc, min_wqe_inline_mode, sq->min_inline_mode);
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
 	MLX5_SET(sqc,  sqc, tis_lst_sz,		param->icosq ? 0 : 1);
 	MLX5_SET(sqc,  sqc, flush_in_error_en,	1);
@@ -1343,6 +1348,7 @@ static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
 
 	param->max_inline = priv->params.tx_max_inline;
+	param->min_inline_mode = priv->params.tx_min_inline_mode;
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
@@ -2967,6 +2973,23 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 			MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE;
 }
 
+static void mlx5e_query_min_inline(struct mlx5_core_dev *mdev,
+				   u8 *min_inline_mode)
+{
+	switch (MLX5_CAP_ETH(mdev, wqe_inline_mode)) {
+	case MLX5E_INLINE_MODE_L2:
+		*min_inline_mode = MLX5_INLINE_MODE_L2;
+		break;
+	case MLX5E_INLINE_MODE_VPORT_CONTEXT:
+		mlx5_query_nic_vport_min_inline(mdev,
+						min_inline_mode);
+		break;
+	case MLX5_INLINE_MODE_NOT_REQUIRED:
+		*min_inline_mode = MLX5_INLINE_MODE_NONE;
+		break;
+	}
+}
+
 static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 					struct net_device *netdev,
 					const struct mlx5e_profile *profile,
@@ -3032,6 +3055,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.tx_cq_moderation.pkts =
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
 	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
+	mlx5e_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
 	priv->params.num_tc                = 1;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 91846df..1de71d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -135,6 +135,24 @@ static int mlx5_modify_nic_vport_context(struct mlx5_core_dev *mdev, void *in,
 	return mlx5_cmd_exec_check_status(mdev, in, inlen, out, sizeof(out));
 }
 
+void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				     u8 *min_inline_mode)
+{
+	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
+	u32 *out;
+
+	out = mlx5_vzalloc(outlen);
+	if (!out)
+		return;
+
+	mlx5_query_nic_vport_context(mdev, 0, out, outlen);
+
+	*min_inline_mode = MLX5_GET(query_nic_vport_context_out, out,
+				    nic_vport_context.min_wqe_inline_mode);
+	kvfree(out);
+}
+EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_min_inline);
+
 int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr)
 {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index d671e4e..21bc455 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -536,7 +536,8 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         self_lb_en_modifiable[0x1];
 	u8         reserved_at_9[0x2];
 	u8         max_lso_cap[0x5];
-	u8         reserved_at_10[0x4];
+	u8         reserved_at_10[0x2];
+	u8	   wqe_inline_mode[0x2];
 	u8         rss_ind_tbl_cap[0x4];
 	u8         reg_umr_sq[0x1];
 	u8         scatter_fcs[0x1];
@@ -2270,7 +2271,8 @@ struct mlx5_ifc_sqc_bits {
 	u8         cd_master[0x1];
 	u8         fre[0x1];
 	u8         flush_in_error_en[0x1];
-	u8         reserved_at_4[0x4];
+	u8         reserved_at_4[0x1];
+	u8	   min_wqe_inline_mode[0x3];
 	u8         state[0x4];
 	u8         reg_umr[0x1];
 	u8         reserved_at_d[0x13];
@@ -2367,7 +2369,9 @@ struct mlx5_ifc_rmpc_bits {
 };
 
 struct mlx5_ifc_nic_vport_context_bits {
-	u8         reserved_at_0[0x1f];
+	u8         reserved_at_0[0x5];
+	u8         min_wqe_inline_mode[0x3];
+	u8         reserved_at_8[0x17];
 	u8         roce_en[0x1];
 
 	u8         arm_change_event[0x1];
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 6c16c19..e087b7d 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -43,6 +43,8 @@ int mlx5_modify_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
 				  u16 vport, u8 state);
 int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
+void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				     u8 *min_inline);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
 				      u16 vport, u8 *addr);
 int mlx5_query_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 *mtu);
-- 
2.8.0
