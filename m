From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 3/8] net/mlx5e: Lower bound MPWRQ stride by HCA cacheline
Date: Tue, 31 Jan 2017 22:58:38 +0200
Message-ID: <20170131205843.23235-4-saeedm@mellanox.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60059 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751222AbdAaVFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:39 -0500
In-Reply-To: <20170131205843.23235-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

MPWRQ stride should be at least the HCA cacheline, the current default
is 64B which will cause data integrity issues in case
HCA_CAP.cach_line_128byte capability is set.

Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 9 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 46f728de9e76..9193111ae05e 100644
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
index e829143efc14..e7a1da1ea4b7 100644
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
-- 
2.11.0
