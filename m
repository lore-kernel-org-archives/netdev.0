From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/12] net/mlx5e: Choose best nearest LRO timeout
Date: Tue, 25 Oct 2016 18:36:29 +0300
Message-ID: <1477409795-28807-7-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40950 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933973AbcJYPiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:25 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of predicting the index of the wanted LRO timeout value from
hardware capabilities, look for the nearest LRO timeout value.

Fixes: 5c50368f3831 ('net/mlx5e: Light-weight netdev open/stop')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 19 ++++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 460363b..7a43502 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -85,6 +85,9 @@
 #define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(128)
 
 #define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
+#define MLX5E_DEFAULT_LRO_TIMEOUT                       32
+#define MLX5E_LRO_TIMEOUT_ARR_SIZE                      4
+
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC      0x10
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC_FROM_CQE 0x3
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS      0x20
@@ -221,6 +224,7 @@ struct mlx5e_params {
 	struct ieee_ets ets;
 #endif
 	bool rx_am_enabled;
+	u32 lro_timeout;
 };
 
 struct mlx5e_tstamp {
@@ -888,5 +892,6 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats);
+u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7eaf380..5c8ab3e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1971,9 +1971,7 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 	MLX5_SET(tirc, tirc, lro_max_ip_payload_size,
 		 (priv->params.lro_wqe_sz -
 		  ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
-	MLX5_SET(tirc, tirc, lro_timeout_period_usecs,
-		 MLX5_CAP_ETH(priv->mdev,
-			      lro_timer_supported_periods[2]));
+	MLX5_SET(tirc, tirc, lro_timeout_period_usecs, priv->params.lro_timeout);
 }
 
 void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv)
@@ -3401,6 +3399,18 @@ static void mlx5e_query_min_inline(struct mlx5_core_dev *mdev,
 	}
 }
 
+u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
+{
+	int i;
+
+	/* The supported periods are organized in ascending order */
+	for (i = 0; i < MLX5E_LRO_TIMEOUT_ARR_SIZE - 1; i++)
+		if (MLX5_CAP_ETH(mdev, lro_timer_supported_periods[i]) >= wanted_timeout)
+			break;
+
+	return MLX5_CAP_ETH(mdev, lro_timer_supported_periods[i]);
+}
+
 static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 					struct net_device *netdev,
 					const struct mlx5e_profile *profile,
@@ -3419,6 +3429,9 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->profile                      = profile;
 	priv->ppriv                        = ppriv;
 
+	priv->params.lro_timeout =
+		mlx5e_choose_lro_timeout(mdev, MLX5E_DEFAULT_LRO_TIMEOUT);
+
 	priv->params.log_sq_size = MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
 
 	/* set CQE compression */
-- 
2.7.4
