From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/12] net/mlx5e: Reduce memory consumption on kdump kernel
Date: Tue, 24 Jan 2017 22:16:51 +0200
Message-ID: <20170124201652.2920-12-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54282 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750921AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Reduce memory consumption on kdump kernel by decreasing the number of
channels to 1 and the size of RQs and SQs to the minimal values.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h        |  7 +------
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c    |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   | 21 ++++++++++++++++++---
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d603a30ad639..8d660a018bf8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -101,6 +101,7 @@
 
 #define MLX5E_LOG_INDIR_RQT_SIZE       0x7
 #define MLX5E_INDIR_RQT_SIZE           BIT(MLX5E_LOG_INDIR_RQT_SIZE)
+#define MLX5E_MIN_NUM_CHANNELS         0x1
 #define MLX5E_MAX_NUM_CHANNELS         (MLX5E_INDIR_RQT_SIZE >> 1)
 #define MLX5E_MAX_NUM_SQS              (MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC)
 #define MLX5E_TX_CQ_POLL_BUDGET        128
@@ -847,12 +848,6 @@ static inline u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
 	return wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
 }
 
-static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
-{
-	return min_t(int, mdev->priv.eq_table.num_comp_vectors,
-		     MLX5E_MAX_NUM_CHANNELS);
-}
-
 extern const struct ethtool_ops mlx5e_ethtool_ops;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 4021863e3840..9d520f8d6d1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -552,7 +552,7 @@ static void mlx5e_get_channels(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	ch->max_combined   = mlx5e_get_max_num_channels(priv->mdev);
+	ch->max_combined   = priv->profile->max_nch(priv->mdev);
 	ch->combined_count = priv->params.num_channels;
 }
 
@@ -560,7 +560,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 			      struct ethtool_channels *ch)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int ncv = mlx5e_get_max_num_channels(priv->mdev);
+	int ncv = priv->profile->max_nch(priv->mdev);
 	unsigned int count = ch->combined_count;
 	bool arfs_enabled;
 	bool was_opened;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 636372873e64..e829143efc14 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -31,6 +31,7 @@
  */
 
 #include <net/tc_act/tc_gact.h>
+#include <linux/crash_dump.h>
 #include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
@@ -83,7 +84,9 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 	priv->params.rq_wq_type = rq_type;
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
+		priv->params.log_rq_size = is_kdump_kernel() ?
+			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE_MPW :
+			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW;
 		priv->params.mpwqe_log_stride_sz =
 			MLX5E_GET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_COMPRESS) ?
 			MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS :
@@ -92,7 +95,9 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 			priv->params.mpwqe_log_stride_sz;
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
-		priv->params.log_rq_size = MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
+		priv->params.log_rq_size = is_kdump_kernel() ?
+			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE :
+			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
 	}
 	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
 					       BIT(priv->params.log_rq_size));
@@ -1508,6 +1513,14 @@ static int mlx5e_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
+static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
+{
+	return is_kdump_kernel() ?
+		MLX5E_MIN_NUM_CHANNELS :
+		min_t(int, mdev->priv.eq_table.num_comp_vectors,
+		      MLX5E_MAX_NUM_CHANNELS);
+}
+
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
@@ -3491,7 +3504,9 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.lro_timeout =
 		mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
 
-	priv->params.log_sq_size = MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
+	priv->params.log_sq_size = is_kdump_kernel() ?
+		MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE :
+		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
 
 	/* set CQE compression */
 	priv->params.rx_cqe_compress_def = false;
-- 
2.11.0
