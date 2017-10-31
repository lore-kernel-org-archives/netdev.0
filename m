From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/14] net/mlx5e: Switch pme counters to use stats group API
Date: Tue, 31 Oct 2017 15:06:45 -0700
Message-ID: <20171031220647.23614-13-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56762 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932578AbdJaWIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:34 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the pme counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 20 --------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 54 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 10 ----
 3 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 6680b24bf1c7..6de948819034 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -151,8 +151,6 @@ int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 		return num_stats +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
-		       ARRAY_SIZE(mlx5e_pme_status_desc) +
-		       ARRAY_SIZE(mlx5e_pme_error_desc) +
 		       mlx5e_ipsec_get_count(priv);
 
 	case ETH_SS_PRIV_FLAGS:
@@ -179,13 +177,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	/* port module event counters */
-	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_status_desc); i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_status_desc[i].format);
-
-	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_error_desc); i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_error_desc[i].format);
-
 	/* IPSec counters */
 	idx += mlx5e_ipsec_get_strings(priv, data + idx * ETH_GSTRING_LEN);
 
@@ -239,7 +230,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 				     struct ethtool_stats *stats, u64 *data)
 {
 	struct mlx5e_channels *channels;
-	struct mlx5_priv *mlx5_priv;
 	int i, j, tc, idx = 0;
 
 	if (!data)
@@ -254,16 +244,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	/* port module event counters */
-	mlx5_priv =  &priv->mdev->priv;
-	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_status_desc); i++)
-		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.status_counters,
-						   mlx5e_pme_status_desc, i);
-
-	for (i = 0; i < ARRAY_SIZE(mlx5e_pme_error_desc); i++)
-		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
-						   mlx5e_pme_error_desc, i);
-
 	/* IPSec counters */
 	idx += mlx5e_ipsec_get_stats(priv, data + idx);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index c9f3be940934..b120957ea940 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -653,6 +653,55 @@ static int mlx5e_grp_per_prio_pfc_fill_stats(struct mlx5e_priv *priv,
 	return idx;
 }
 
+static const struct counter_desc mlx5e_pme_status_desc[] = {
+	{ "module_unplug", 8 },
+};
+
+static const struct counter_desc mlx5e_pme_error_desc[] = {
+	{ "module_bus_stuck", 16 },       /* bus stuck (I2C or data shorted) */
+	{ "module_high_temp", 48 },       /* high temperature */
+	{ "module_bad_shorted", 56 },    /* bad or shorted cable/module */
+};
+
+#define NUM_PME_STATUS_STATS		ARRAY_SIZE(mlx5e_pme_status_desc)
+#define NUM_PME_ERR_STATS		ARRAY_SIZE(mlx5e_pme_error_desc)
+
+static int mlx5e_grp_pme_get_num_stats(struct mlx5e_priv *priv)
+{
+	return NUM_PME_STATUS_STATS + NUM_PME_ERR_STATS;
+}
+
+static int mlx5e_grp_pme_fill_strings(struct mlx5e_priv *priv, u8 *data,
+				      int idx)
+{
+	int i;
+
+	for (i = 0; i < NUM_PME_STATUS_STATS; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_status_desc[i].format);
+
+	for (i = 0; i < NUM_PME_ERR_STATS; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, mlx5e_pme_error_desc[i].format);
+
+	return idx;
+}
+
+static int mlx5e_grp_pme_fill_stats(struct mlx5e_priv *priv, u64 *data,
+				    int idx)
+{
+	struct mlx5_priv *mlx5_priv = &priv->mdev->priv;
+	int i;
+
+	for (i = 0; i < NUM_PME_STATUS_STATS; i++)
+		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.status_counters,
+						   mlx5e_pme_status_desc, i);
+
+	for (i = 0; i < NUM_PME_ERR_STATS; i++)
+		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
+						   mlx5e_pme_error_desc, i);
+
+	return idx;
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
@@ -709,6 +758,11 @@ const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 		.fill_strings = mlx5e_grp_per_prio_pfc_fill_strings,
 		.fill_stats = mlx5e_grp_per_prio_pfc_fill_stats,
 	},
+	{
+		.get_num_stats = mlx5e_grp_pme_get_num_stats,
+		.fill_strings = mlx5e_grp_pme_fill_strings,
+		.fill_stats = mlx5e_grp_pme_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 8e92cd80c638..800d72a22d91 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -252,14 +252,4 @@ struct mlx5e_stats_grp {
 extern const struct mlx5e_stats_grp mlx5e_stats_grps[];
 extern const int mlx5e_num_stats_grps;
 
-static const struct counter_desc mlx5e_pme_status_desc[] = {
-	{ "module_unplug", 8 },
-};
-
-static const struct counter_desc mlx5e_pme_error_desc[] = {
-	{ "module_bus_stuck", 16 },       /* bus stuck (I2C or data shorted) */
-	{ "module_high_temp", 48 },       /* high temperature */
-	{ "module_bad_shorted", 56 },    /* bad or shorted cable/module */
-};
-
 #endif /* __MLX5_EN_STATS_H__ */
-- 
2.14.2
