From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next V2 2/6] net/mlx5: Configure cache line size for start and end padding
Date: Tue,  7 Feb 2017 01:38:25 +0200
Message-ID: <20170206233829.29716-3-saeedm@mellanox.com>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52050 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751164AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

There is a hardware feature that will pad the start or end of a DMA to
be cache line aligned to avoid RMWs on the last cache line. The default
cache line size setting for this feature is 64B. This change configures
the hardware to use 128B alignment on systems with 128B cache lines.

In addition we lower bound MPWRQ stride by HCA cacheline in mlx5e,
MPWRQ stride should be at least the HCA cacheline, the current default
is 64B and in case HCA_CAP.cach_line_128byte capability is set, MPWRQ RX
stride will automatically be aligned to 128B.

Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 9 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 6 ++++++
 include/linux/mlx5/mlx5_ifc.h                     | 6 ++++--
 4 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9b52c58cd528..9b23d3329847 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -70,8 +70,13 @@
 
 #define MLX5_RX_HEADROOM NET_SKB_PAD
 
-#define MLX5_MPWRQ_LOG_STRIDE_SIZE		6  /* >= 6, HW restriction */
-#define MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS	8  /* >= 6, HW restriction */
+#define MLX5_MPWRQ_MIN_LOG_STRIDE_SZ(mdev) \
+	(6 + MLX5_CAP_GEN(mdev, cache_line_128byte)) /* HW restriction */
+#define MLX5_MPWRQ_LOG_STRIDE_SZ(mdev, req) \
+	max_t(u32, MLX5_MPWRQ_MIN_LOG_STRIDE_SZ(mdev), req)
+#define MLX5_MPWRQ_DEF_LOG_STRIDE_SZ(mdev)       MLX5_MPWRQ_LOG_STRIDE_SZ(mdev, 6)
+#define MLX5_MPWRQ_CQE_CMPRS_LOG_STRIDE_SZ(mdev) MLX5_MPWRQ_LOG_STRIDE_SZ(mdev, 8)
+
 #define MLX5_MPWRQ_LOG_WQE_SZ			18
 #define MLX5_MPWRQ_WQE_PAGE_ORDER  (MLX5_MPWRQ_LOG_WQE_SZ - PAGE_SHIFT > 0 ? \
 				    MLX5_MPWRQ_LOG_WQE_SZ - PAGE_SHIFT : 0)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ab6f4d3b8063..1b7fe43ab22b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -89,8 +89,8 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
 		priv->params.mpwqe_log_stride_sz =
 			MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) ?
-			MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS :
-			MLX5_MPWRQ_LOG_STRIDE_SIZE;
+			MLX5_MPWRQ_CQE_CMPRS_LOG_STRIDE_SZ(priv->mdev) :
+			MLX5_MPWRQ_DEF_LOG_STRIDE_SZ(priv->mdev);
 		priv->params.mpwqe_log_num_strides = MLX5_MPWRQ_LOG_WQE_SZ -
 			priv->params.mpwqe_log_stride_sz;
 		break;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index f7e50ba67f94..c4242a4e8130 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -543,6 +543,12 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 
 	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
 
+	if (MLX5_CAP_GEN_MAX(dev, cache_line_128byte))
+		MLX5_SET(cmd_hca_cap,
+			 set_hca_cap,
+			 cache_line_128byte,
+			 cache_line_size() == 128 ? 1 : 0);
+
 	err = set_caps(dev, set_ctx, set_sz,
 		       MLX5_SET_HCA_CAP_OP_MOD_GENERAL_DEVICE);
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index a919dfb920ae..cc8ae860cd45 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -804,10 +804,12 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_150[0xa];
 	u8         log_max_ra_res_qp[0x6];
 
-	u8         pad_cap[0x1];
+	u8         end_pad[0x1];
 	u8         cc_query_allowed[0x1];
 	u8         cc_modify_allowed[0x1];
-	u8         reserved_at_163[0xd];
+	u8         start_pad[0x1];
+	u8         cache_line_128byte[0x1];
+	u8         reserved_at_163[0xb];
 	u8         gid_table_size[0x10];
 
 	u8         out_of_seq_cnt[0x1];
-- 
2.11.0
