From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/14] net/mlx5e: Switch physical statistical counters to use stats group API
Date: Tue, 31 Oct 2017 15:06:40 -0700
Message-ID: <20171031220647.23614-8-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56622 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932652AbdJaWIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:15 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the physical statistical counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  8 ----
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 45 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 14 +------
 3 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index b5a9de1150f9..547b7fa48637 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -216,10 +216,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	for (i = 0; i < NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv); i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		       pport_phy_statistical_stats_desc[i].format);
-
 	for (i = 0; i < NUM_PPORT_ETH_EXT_COUNTERS(priv); i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_eth_ext_stats_desc[i].format);
@@ -336,10 +332,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	for (i = 0; i < NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv); i++)
-		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.phy_statistical_counters,
-						  pport_phy_statistical_stats_desc, i);
-
 	for (i = 0; i < NUM_PPORT_ETH_EXT_COUNTERS(priv); i++)
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.eth_ext_counters,
 						  pport_eth_ext_stats_desc, i);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index 7cdcc60e913b..3838f109ceb1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -333,6 +333,46 @@ static int mlx5e_grp_2819_fill_stats(struct mlx5e_priv *priv, u64 *data,
 	return idx;
 }
 
+#define PPORT_PHY_STATISTICAL_OFF(c) \
+	MLX5_BYTE_OFF(ppcnt_reg, \
+		      counter_set.phys_layer_statistical_cntrs.c##_high)
+static const struct counter_desc pport_phy_statistical_stats_desc[] = {
+	{ "rx_pcs_symbol_err_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
+	{ "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
+};
+
+#define NUM_PPORT_PHY_COUNTERS		ARRAY_SIZE(pport_phy_statistical_stats_desc)
+
+static int mlx5e_grp_phy_get_num_stats(struct mlx5e_priv *priv)
+{
+	return MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group) ?
+		NUM_PPORT_PHY_COUNTERS : 0;
+}
+
+static int mlx5e_grp_phy_fill_strings(struct mlx5e_priv *priv, u8 *data,
+				      int idx)
+{
+	int i;
+
+	if (MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group))
+		for (i = 0; i < NUM_PPORT_PHY_COUNTERS; i++)
+			strcpy(data + (idx++) * ETH_GSTRING_LEN,
+			       pport_phy_statistical_stats_desc[i].format);
+	return idx;
+}
+
+static int mlx5e_grp_phy_fill_stats(struct mlx5e_priv *priv, u64 *data, int idx)
+{
+	int i;
+
+	if (MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group))
+		for (i = 0; i < NUM_PPORT_PHY_COUNTERS; i++)
+			data[idx++] =
+				MLX5E_READ_CTR64_BE(&priv->stats.pport.phy_statistical_counters,
+						    pport_phy_statistical_stats_desc, i);
+	return idx;
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
@@ -364,6 +404,11 @@ const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 		.fill_strings = mlx5e_grp_2819_fill_strings,
 		.fill_stats = mlx5e_grp_2819_fill_stats,
 	},
+	{
+		.get_num_stats = mlx5e_grp_phy_get_num_stats,
+		.fill_strings = mlx5e_grp_phy_fill_strings,
+		.fill_stats = mlx5e_grp_phy_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 168fad3ab2aa..964a1c69cb51 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -111,9 +111,6 @@ struct mlx5e_vport_stats {
 #define PPORT_2819_GET(pstats, c) \
 	MLX5_GET64(ppcnt_reg, pstats->RFC_2819_counters, \
 		   counter_set.eth_2819_cntrs_grp_data_layout.c##_high)
-#define PPORT_PHY_STATISTICAL_OFF(c) \
-	MLX5_BYTE_OFF(ppcnt_reg, \
-		      counter_set.phys_layer_statistical_cntrs.c##_high)
 #define PPORT_PHY_STATISTICAL_GET(pstats, c) \
 	MLX5_GET64(ppcnt_reg, (pstats)->phy_statistical_counters, \
 		   counter_set.phys_layer_statistical_cntrs.c##_high)
@@ -141,11 +138,6 @@ struct mlx5e_pport_stats {
 	__be64 eth_ext_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
-static const struct counter_desc pport_phy_statistical_stats_desc[] = {
-	{ "rx_pcs_symbol_err_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
-	{ "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
-};
-
 static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
 	{ "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
 	{ "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
@@ -284,9 +276,6 @@ static const struct counter_desc sq_stats_desc[] = {
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
 };
 
-#define NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) \
-	(ARRAY_SIZE(pport_phy_statistical_stats_desc) * \
-	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group))
 #define NUM_PCIE_PERF_COUNTERS(priv) \
 	(ARRAY_SIZE(pcie_perf_stats_desc) * \
 	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_performance_group))
@@ -303,8 +292,7 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_ETH_EXT_COUNTERS(priv) \
 	(ARRAY_SIZE(pport_eth_ext_stats_desc) * \
 	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, rx_buffer_fullness_counters))
-#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
-					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
+#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
 					 NUM_PPORT_PRIO + \
 					 NUM_PPORT_ETH_EXT_COUNTERS(priv))
 #define NUM_PCIE_COUNTERS(priv)		(NUM_PCIE_PERF_COUNTERS(priv) + \
-- 
2.14.2
