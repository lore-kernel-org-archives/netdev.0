From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/14] net/mlx5e: Switch per prio traffic counters to use stats group API
Date: Tue, 31 Oct 2017 15:06:43 -0700
Message-ID: <20171031220647.23614-11-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56710 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932746AbdJaWIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:24 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the per prio traffic counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 13 ------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 50 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 11 -----
 3 files changed, 50 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 8515ae815cbc..b17460e14b29 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -182,7 +182,6 @@ int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 		for (i = 0; i < mlx5e_num_stats_grps; i++)
 			num_stats += mlx5e_stats_grps[i].get_num_stats(priv);
 		return num_stats +
-		       NUM_PPORT_COUNTERS(priv) +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv) +
@@ -215,12 +214,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
-		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
-			sprintf(data + (idx++) * ETH_GSTRING_LEN,
-				pport_per_prio_traffic_stats_desc[i].format, prio);
-	}
-
 	pfc_combined = mlx5e_query_pfc_combined(priv);
 	for_each_set_bit(prio, &pfc_combined, NUM_PPORT_PRIO) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
@@ -315,12 +308,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
-		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
-			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
-						 pport_per_prio_traffic_stats_desc, i);
-	}
-
 	pfc_combined = mlx5e_query_pfc_combined(priv);
 	for_each_set_bit(prio, &pfc_combined, NUM_PPORT_PRIO) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index 700362a00fd0..5d00d38f9bd0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -502,6 +502,51 @@ static int mlx5e_grp_pcie_fill_stats(struct mlx5e_priv *priv, u64 *data,
 	return idx;
 }
 
+static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
+	{ "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
+	{ "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
+	{ "tx_prio%d_bytes", PPORT_PER_PRIO_OFF(tx_octets) },
+	{ "tx_prio%d_packets", PPORT_PER_PRIO_OFF(tx_frames) },
+};
+
+#define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
+
+static int mlx5e_grp_per_prio_traffic_get_num_stats(struct mlx5e_priv *priv)
+{
+	return NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * NUM_PPORT_PRIO;
+}
+
+static int mlx5e_grp_per_prio_traffic_fill_strings(struct mlx5e_priv *priv,
+						   u8 *data,
+						   int idx)
+{
+	int i, prio;
+
+	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
+			sprintf(data + (idx++) * ETH_GSTRING_LEN,
+				pport_per_prio_traffic_stats_desc[i].format, prio);
+	}
+
+	return idx;
+}
+
+static int mlx5e_grp_per_prio_traffic_fill_stats(struct mlx5e_priv *priv,
+						 u64 *data,
+						 int idx)
+{
+	int i, prio;
+
+	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
+			data[idx++] =
+				MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
+						    pport_per_prio_traffic_stats_desc, i);
+	}
+
+	return idx;
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
@@ -548,6 +593,11 @@ const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 		.fill_strings = mlx5e_grp_pcie_fill_strings,
 		.fill_stats = mlx5e_grp_pcie_fill_stats,
 	},
+	{
+		.get_num_stats = mlx5e_grp_per_prio_traffic_get_num_stats,
+		.fill_strings = mlx5e_grp_per_prio_traffic_fill_strings,
+		.fill_stats = mlx5e_grp_per_prio_traffic_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 8afff1981b25..8b5b622306a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -135,13 +135,6 @@ struct mlx5e_pport_stats {
 	__be64 eth_ext_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
-static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
-	{ "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
-	{ "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
-	{ "tx_prio%d_bytes", PPORT_PER_PRIO_OFF(tx_octets) },
-	{ "tx_prio%d_packets", PPORT_PER_PRIO_OFF(tx_frames) },
-};
-
 static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
 	/* %s is "global" or "prio{i}" */
 	{ "rx_%s_pause", PPORT_PER_PRIO_OFF(rx_pause) },
@@ -249,12 +242,8 @@ static const struct counter_desc sq_stats_desc[] = {
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
 };
 
-#define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
-	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_pfc_stats_desc)
-#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
-					 NUM_PPORT_PRIO)
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
 
-- 
2.14.2
