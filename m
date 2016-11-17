From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 4/8] net/mlx5e: Add port module event counters to ethtool stats
Date: Thu, 17 Nov 2016 13:45:58 +0200
Message-ID: <1479383162-3432-5-git-send-email-saeedm@mellanox.com>
References: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57826 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941467AbcKQLqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 06:46:19 -0500
In-Reply-To: <1479383162-3432-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Add port module event counters to ethtool -S command

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 23 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 17 ++++++++++++++++
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 27ff401..b154621 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -173,7 +173,10 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
-		       MLX5E_NUM_PFC_COUNTERS(priv);
+		       MLX5E_NUM_PFC_COUNTERS(priv) +
+		       ARRAY_SIZE(mlx5e_pme_status_desc) +
+		       ARRAY_SIZE(mlx5e_pme_error_desc);
+
 	case ETH_SS_PRIV_FLAGS:
 		return ARRAY_SIZE(mlx5e_priv_flags);
 	/* fallthrough */
@@ -237,6 +240,13 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		}
 	}
 
+	/* port module event counters */
+	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_status_desc); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_status_desc[i].format);
+
+	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_error_desc); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_error_desc[i].format);
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
@@ -279,6 +289,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_priv *mlx5_priv;
 	int i, j, tc, prio, idx = 0;
 	unsigned long pfc_combined;
 
@@ -335,6 +346,16 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		}
 	}
 
+	/* port module event counters */
+	mlx5_priv =  &priv->mdev->priv;
+	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_status_desc); i++)
+		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.status_counters,
+						   mlx5e_pme_status_desc, i);
+
+	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_error_desc); i++)
+		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
+						   mlx5e_pme_error_desc, i);
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 57452fd..b817e51 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -379,4 +379,21 @@ struct mlx5e_stats {
 	struct mlx5e_pport_stats pport;
 };
 
+static const struct counter_desc mlx5e_pme_status_desc[] = {
+	{ "module_plug", 0 },
+	{ "module_unplug", 8 },
+};
+
+static const struct counter_desc mlx5e_pme_error_desc[] = {
+	{ "module_pwr_budget_exd", 0 },  /* power budget exceed */
+	{ "module_long_range", 8 },      /* long range for non MLNX cable */
+	{ "module_bus_stuck", 16 },      /* bus stuck (I2C or data shorted) */
+	{ "module_no_eeprom", 24 },      /* no eeprom/retry time out */
+	{ "module_enforce_part", 32 },   /* enforce part number list */
+	{ "module_unknown_id", 40 },     /* unknown identifier */
+	{ "module_high_temp", 48 },      /* high temperature */
+	{ "module_bad_shorted", 56 },    /* bad or shorted cable/module */
+	{ "module_unknown_status", 64 },
+};
+
 #endif /* __MLX5_EN_STATS_H__ */
-- 
2.7.4
