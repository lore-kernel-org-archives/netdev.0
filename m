From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 09/10] net/mlx5e: Moves pflags to priv->params
Date: Sun, 27 Nov 2016 17:02:11 +0200
Message-ID: <1480258932-10302-10-git-send-email-saeedm@mellanox.com>
References: <1480258932-10302-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Shaker Daibes <shakerd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43776 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752128AbcK0PC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:02:29 -0500
In-Reply-To: <1480258932-10302-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

pflags is a configuration parameter for the netdev, naturally it belongs
to priv->params.
Also introduce MLX5E_GET_PFLAG

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         | 16 +++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  4 ++--
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9cf32d3..84ac78f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -177,14 +177,16 @@ enum mlx5e_priv_flag {
 	MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
 };
 
-#define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
-	do {                                        \
-		if (enable)                         \
-			priv->pflags |= pflag;      \
-		else                                \
-			priv->pflags &= ~pflag;     \
+#define MLX5E_SET_PFLAG(priv, pflag, enable)			\
+	do {							\
+		if (enable)					\
+			(priv)->params.pflags |= (pflag);	\
+		else						\
+			(priv)->params.pflags &= ~(pflag);	\
 	} while (0)
 
+#define MLX5E_GET_PFLAG(priv, pflag) (!!((priv)->params.pflags & (pflag)))
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
 #endif
@@ -218,6 +220,7 @@ struct mlx5e_params {
 	bool vlan_strip_disable;
 	bool rx_am_enabled;
 	u32 lro_timeout;
+	u32 pflags;
 };
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
@@ -705,7 +708,6 @@ struct mlx5e_priv {
 	struct work_struct         tx_timeout_work;
 	struct delayed_work        update_stats_work;
 
-	u32                        pflags;
 	struct mlx5_core_dev      *mdev;
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 839c4e9..d2bdccb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1488,7 +1488,7 @@ static int mlx5e_handle_pflag(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	bool enable = !!(wanted_flags & flag);
-	u32 changes = wanted_flags ^ priv->pflags;
+	u32 changes = wanted_flags ^ priv->params.pflags;
 	int err;
 
 	if (!(changes & flag))
@@ -1501,7 +1501,7 @@ static int mlx5e_handle_pflag(struct net_device *netdev,
 		return err;
 	}
 
-	MLX5E_SET_PRIV_FLAG(priv, flag, enable);
+	MLX5E_SET_PFLAG(priv, flag, enable);
 	return 0;
 }
 
@@ -1524,7 +1524,7 @@ static u32 mlx5e_get_priv_flags(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	return priv->pflags;
+	return priv->params.pflags;
 }
 
 static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 89d5c65..004940a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3488,8 +3488,8 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	/* Initialize pflags */
-	MLX5E_SET_PRIV_FLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
-			    priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
+	MLX5E_SET_PFLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
+			priv->params.rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE);
 
 	mutex_init(&priv->state_lock);
 
-- 
2.7.4
