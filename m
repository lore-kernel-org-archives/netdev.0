From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/15] net/mlx5e: Expose physical layer statistical counters to ethtool
Date: Fri, 20 Jan 2017 00:39:04 +0200
Message-ID: <20170119223908.15924-12-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59321 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751765AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Use ethtool -S to query physical layer statistical counters including:
- rx_symbol_errors_phy: Number of symbol errors that were not corrected
  by FEC correction algorithm or that FEC was not active on this interface.

- rx_corrected_bits_phy: Number of corrected bits according to active
  FEC (RS/FC).

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 10 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h   | 18 +++++++++++++++++-
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 33a399a8b5d5..dcc3e4dc1484 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -170,7 +170,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_STATS:
 		return NUM_SW_COUNTERS +
 		       MLX5E_NUM_Q_CNTRS(priv) +
-		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
+		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS(priv) +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv) +
@@ -218,6 +218,10 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_2819_stats_desc[i].format);
 
+	for (i = 0; i < NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       pport_phy_statistical_stats_desc[i].format);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
@@ -330,6 +334,10 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.RFC_2819_counters,
 						  pport_2819_stats_desc, i);
 
+	for (i = 0; i < NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv); i++)
+		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.phy_statistical_counters,
+						  pport_phy_statistical_stats_desc, i);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2129fbd1d6ca..3be87a65d750 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -268,6 +268,12 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_PHYSICAL_LAYER_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
 
+	if (MLX5_CAP_PCAM_FEATURE(mdev, ppcnt_statistical_group)) {
+		out = pstats->phy_statistical_counters;
+		MLX5_SET(ppcnt_reg, in, grp, MLX5_PHYSICAL_LAYER_STATISTICAL_GROUP);
+		mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
+	}
+
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_PER_PRIORITY_COUNTERS_GROUP);
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		out = pstats->per_prio_counters[prio];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index ba5db1dd23a9..21c43d4e4f2e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -201,6 +201,12 @@ static const struct counter_desc vport_stats_desc[] = {
 #define PPORT_2819_GET(pstats, c) \
 	MLX5_GET64(ppcnt_reg, pstats->RFC_2819_counters, \
 		   counter_set.eth_2819_cntrs_grp_data_layout.c##_high)
+#define PPORT_PHY_STATISTICAL_OFF(c) \
+	MLX5_BYTE_OFF(ppcnt_reg, \
+		      counter_set.phys_layer_statistical_cntrs.c##_high)
+#define PPORT_PHY_STATISTICAL_GET(pstats, c) \
+	MLX5_GET64(ppcnt_reg, (pstats)->phy_statistical_counters, \
+		   counter_set.phys_layer_statistical_cntrs.c##_high)
 #define PPORT_PER_PRIO_OFF(c) \
 	MLX5_BYTE_OFF(ppcnt_reg, \
 		      counter_set.eth_per_prio_grp_data_layout.c##_high)
@@ -215,6 +221,7 @@ struct mlx5e_pport_stats {
 	__be64 RFC_2819_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 per_prio_counters[NUM_PPORT_PRIO][MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 phy_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
+	__be64 phy_statistical_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
 static const struct counter_desc pport_802_3_stats_desc[] = {
@@ -260,6 +267,11 @@ static const struct counter_desc pport_2819_stats_desc[] = {
 	{ "rx_8192_to_10239_bytes_phy", PPORT_2819_OFF(ether_stats_pkts8192to10239octets) },
 };
 
+static const struct counter_desc pport_phy_statistical_stats_desc[] = {
+	{ "rx_symbol_errors_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
+	{ "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
+};
+
 static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
 	{ "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
 	{ "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
@@ -360,13 +372,17 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
 #define NUM_PPORT_2863_COUNTERS		ARRAY_SIZE(pport_2863_stats_desc)
 #define NUM_PPORT_2819_COUNTERS		ARRAY_SIZE(pport_2819_stats_desc)
+#define NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) \
+	(ARRAY_SIZE(pport_phy_statistical_stats_desc) * \
+	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group))
 #define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_pfc_stats_desc)
-#define NUM_PPORT_COUNTERS		(NUM_PPORT_802_3_COUNTERS + \
+#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_802_3_COUNTERS + \
 					 NUM_PPORT_2863_COUNTERS  + \
 					 NUM_PPORT_2819_COUNTERS  + \
+					 NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
 					 NUM_PPORT_PRIO)
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
-- 
2.11.0
