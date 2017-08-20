From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 07/15] net/mlx5e: Add RX buffer fullness counters
Date: Sun, 20 Aug 2017 16:49:08 +0300
Message-ID: <20170820134916.10222-8-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44763 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751885AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

rx_buffer_passed_thres_phy - The number of events where the port RX
buffer has passed a fullness threshold.

rx_buffer_full_phy - The number of events where the port RX buffer has
reached 100% fullness.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h   | 17 ++++++++++++++++-
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 07202f7322fc..8c013a521319 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -242,6 +242,10 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_phy_statistical_stats_desc[i].format);
 
+	for (i = 0; i < NUM_PPORT_ETH_EXT_COUNTERS(priv); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       pport_eth_ext_stats_desc[i].format);
+
 	for (i = 0; i < NUM_PCIE_PERF_COUNTERS(priv); i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pcie_perf_stats_desc[i].format);
@@ -377,6 +381,10 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.phy_statistical_counters,
 						  pport_phy_statistical_stats_desc, i);
 
+	for (i = 0; i < NUM_PPORT_ETH_EXT_COUNTERS(priv); i++)
+		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.eth_ext_counters,
+						  pport_eth_ext_stats_desc, i);
+
 	for (i = 0; i < NUM_PCIE_PERF_COUNTERS(priv); i++)
 		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
 						  pcie_perf_stats_desc, i);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7c512a4c6d5c..fdc2b92f020b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -288,6 +288,12 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv, bool full)
 		mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
 	}
 
+	if (MLX5_CAP_PCAM_FEATURE(mdev, rx_buffer_fullness_counters)) {
+		out = pstats->eth_ext_counters;
+		MLX5_SET(ppcnt_reg, in, grp, MLX5_ETHERNET_EXTENDED_COUNTERS_GROUP);
+		mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
+	}
+
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_PER_PRIORITY_COUNTERS_GROUP);
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		out = pstats->per_prio_counters[prio];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index bdddddc46170..be49df4bedd9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -216,6 +216,12 @@ static const struct counter_desc vport_stats_desc[] = {
 	MLX5_GET64(ppcnt_reg, pstats->per_prio_counters[prio], \
 		   counter_set.eth_per_prio_grp_data_layout.c##_high)
 #define NUM_PPORT_PRIO				8
+#define PPORT_ETH_EXT_OFF(c) \
+	MLX5_BYTE_OFF(ppcnt_reg, \
+		      counter_set.eth_extended_cntrs_grp_data_layout.c##_high)
+#define PPORT_ETH_EXT_GET(pstats, c) \
+	MLX5_GET64(ppcnt_reg, (pstats)->eth_ext_counters, \
+		   counter_set.eth_extended_cntrs_grp_data_layout.c##_high)
 
 struct mlx5e_pport_stats {
 	__be64 IEEE_802_3_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
@@ -224,6 +230,7 @@ struct mlx5e_pport_stats {
 	__be64 per_prio_counters[NUM_PPORT_PRIO][MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 phy_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 phy_statistical_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
+	__be64 eth_ext_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
 static const struct counter_desc pport_802_3_stats_desc[] = {
@@ -290,6 +297,10 @@ static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
 	{ "rx_%s_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
 };
 
+static const struct counter_desc pport_eth_ext_stats_desc[] = {
+	{ "rx_buffer_passed_thres_phy", PPORT_ETH_EXT_OFF(rx_buffer_almost_full) },
+};
+
 #define PCIE_PERF_OFF(c) \
 	MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_perf_cntrs_grp_data_layout.c)
 #define PCIE_PERF_GET(pcie_stats, c) \
@@ -411,12 +422,16 @@ static const struct counter_desc sq_stats_desc[] = {
 	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_pfc_stats_desc)
+#define NUM_PPORT_ETH_EXT_COUNTERS(priv) \
+	(ARRAY_SIZE(pport_eth_ext_stats_desc) * \
+	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, rx_buffer_fullness_counters))
 #define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_802_3_COUNTERS + \
 					 NUM_PPORT_2863_COUNTERS  + \
 					 NUM_PPORT_2819_COUNTERS  + \
 					 NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
-					 NUM_PPORT_PRIO)
+					 NUM_PPORT_PRIO + \
+					 NUM_PPORT_ETH_EXT_COUNTERS(priv))
 #define NUM_PCIE_COUNTERS(priv)		(NUM_PCIE_PERF_COUNTERS(priv) + \
 					 NUM_PCIE_PERF_STALL_COUNTERS(priv))
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
-- 
2.13.0
