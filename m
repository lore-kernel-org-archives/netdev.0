From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 04/11] net/mlx5e: Add per priority group to PPort counters
Date: Sun, 24 Apr 2016 22:51:49 +0300
Message-ID: <1461527516-29290-5-git-send-email-saeedm@mellanox.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53311 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751170AbcDXTym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 15:54:42 -0400
In-Reply-To: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Expose counters providing information for each priority level (PCP) through
ethtool -S option and DCBNL.
This includes rx/tx bytes, frames, and pause counters.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |    6 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   51 ++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    9 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   31 ++++++++++++-
 4 files changed, 93 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index 3036f27..b2db180 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -174,8 +174,14 @@ static int mlx5e_dcbnl_ieee_getpfc(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
+	int i;
 
 	pfc->pfc_cap = mlx5_max_tc(mdev) + 1;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		pfc->requests[i]    = PPORT_PER_PRIO_GET(pstats, i, tx_pause);
+		pfc->indications[i] = PPORT_PER_PRIO_GET(pstats, i, rx_pause);
+	}
 
 	return mlx5_query_port_pfc(mdev, &pfc->pfc_en, NULL);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index f1649d5..522d584 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -165,6 +165,18 @@ static const struct {
 	},
 };
 
+static unsigned long mlx5e_query_pfc_combined(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u8 pfc_en_tx;
+	u8 pfc_en_rx;
+	int err;
+
+	err = mlx5_query_port_pfc(mdev, &pfc_en_tx, &pfc_en_rx);
+
+	return err ? 0 : pfc_en_tx | pfc_en_rx;
+}
+
 #define MLX5E_NUM_Q_CNTRS(priv) (NUM_Q_COUNTERS * (!!priv->q_counter))
 #define MLX5E_NUM_RQ_STATS(priv) \
 	(NUM_RQ_STATS * priv->params.num_channels * \
@@ -172,6 +184,7 @@ static const struct {
 #define MLX5E_NUM_SQ_STATS(priv) \
 	(NUM_SQ_STATS * priv->params.num_channels * priv->params.num_tc * \
 	 test_bit(MLX5E_STATE_OPENED, &priv->state))
+#define MLX5E_NUM_PFC_COUNTERS(priv) hweight8(mlx5e_query_pfc_combined(priv))
 
 static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 {
@@ -183,7 +196,8 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 		       MLX5E_NUM_Q_CNTRS(priv) +
 		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
 		       MLX5E_NUM_RQ_STATS(priv) +
-		       MLX5E_NUM_SQ_STATS(priv);
+		       MLX5E_NUM_SQ_STATS(priv) +
+		       MLX5E_NUM_PFC_COUNTERS(priv);
 	/* fallthrough */
 	default:
 		return -EOPNOTSUPP;
@@ -192,7 +206,8 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 
 static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 {
-	int i, j, tc, idx = 0;
+	int i, j, tc, prio, idx = 0;
+	unsigned long pfc_combined;
 
 	/* SW counters */
 	for (i = 0; i < NUM_SW_COUNTERS; i++)
@@ -220,6 +235,21 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_2819_stats_desc[i].name);
 
+	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
+			sprintf(data + (idx++) * ETH_GSTRING_LEN, "prio%d_%s",
+				prio,
+				pport_per_prio_traffic_stats_desc[i].name);
+	}
+
+	pfc_combined = mlx5e_query_pfc_combined(priv);
+	for_each_set_bit(prio, &pfc_combined, NUM_PPORT_PRIO) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
+			sprintf(data + (idx++) * ETH_GSTRING_LEN, "prio%d_%s",
+				prio, pport_per_prio_pfc_stats_desc[i].name);
+		}
+	}
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
@@ -260,7 +290,8 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int i, j, tc, idx = 0;
+	int i, j, tc, prio, idx = 0;
+	unsigned long pfc_combined;
 
 	if (!data)
 		return;
@@ -294,6 +325,20 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.RFC_2819_counters,
 						  pport_2819_stats_desc, i);
 
+	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
+			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
+						 pport_per_prio_traffic_stats_desc, i);
+	}
+
+	pfc_combined = mlx5e_query_pfc_combined(priv);
+	for_each_set_bit(prio, &pfc_combined, NUM_PPORT_PRIO) {
+		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
+			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
+							  pport_per_prio_pfc_stats_desc, i);
+		}
+	}
+
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0c53236..ef66ba6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -161,6 +161,7 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int sz = MLX5_ST_SZ_BYTES(ppcnt_reg);
+	int prio;
 	void *out;
 	u32 *in;
 
@@ -182,6 +183,14 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_RFC_2819_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
 
+	MLX5_SET(ppcnt_reg, in, grp, MLX5_PER_PRIORITY_COUNTERS_GROUP);
+	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
+		out = pstats->per_prio_counters[prio];
+		MLX5_SET(ppcnt_reg, in, prio_tc, prio);
+		mlx5_core_access_reg(mdev, in, sz, out, sz,
+				     MLX5_REG_PPCNT, 0, 0);
+	}
+
 free_out:
 	kvfree(in);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 4f3a08d..de27eea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -165,11 +165,19 @@ static const struct counter_desc vport_stats_desc[] = {
 #define PPORT_2819_GET(pstats, c) \
 	MLX5_GET64(ppcnt_reg, pstats->RFC_2819_counters, \
 		   counter_set.eth_2819_cntrs_grp_data_layout.c##_high)
+#define PPORT_PER_PRIO_OFF(c) \
+	MLX5_BYTE_OFF(ppcnt_reg, \
+		      counter_set.eth_per_prio_grp_data_layout.c##_high)
+#define PPORT_PER_PRIO_GET(pstats, prio, c) \
+	MLX5_GET64(ppcnt_reg, pstats->per_prio_counters[prio], \
+		   counter_set.eth_per_prio_grp_data_layout.c##_high)
+#define NUM_PPORT_PRIO				8
 
 struct mlx5e_pport_stats {
 	__be64 IEEE_802_3_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 RFC_2863_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 	__be64 RFC_2819_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
+	__be64 per_prio_counters[NUM_PPORT_PRIO][MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
 static const struct counter_desc pport_802_3_stats_desc[] = {
@@ -241,6 +249,21 @@ static const struct counter_desc pport_2819_stats_desc[] = {
 		PPORT_2819_OFF(ether_stats_pkts8192to10239octets) },
 };
 
+static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
+	{ "rx_octets", PPORT_PER_PRIO_OFF(rx_octets) },
+	{ "rx_frames", PPORT_PER_PRIO_OFF(rx_frames) },
+	{ "tx_octets", PPORT_PER_PRIO_OFF(tx_octets) },
+	{ "tx_frames", PPORT_PER_PRIO_OFF(tx_frames) },
+};
+
+static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
+	{ "rx_pause", PPORT_PER_PRIO_OFF(rx_pause) },
+	{ "rx_pause_duration", PPORT_PER_PRIO_OFF(rx_pause_duration) },
+	{ "tx_pause", PPORT_PER_PRIO_OFF(tx_pause) },
+	{ "tx_pause_duration", PPORT_PER_PRIO_OFF(tx_pause_duration) },
+	{ "rx_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
+};
+
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 bytes;
@@ -305,9 +328,15 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
 #define NUM_PPORT_2863_COUNTERS		ARRAY_SIZE(pport_2863_stats_desc)
 #define NUM_PPORT_2819_COUNTERS		ARRAY_SIZE(pport_2819_stats_desc)
+#define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
+	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
+#define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
+	ARRAY_SIZE(pport_per_prio_pfc_stats_desc)
 #define NUM_PPORT_COUNTERS		(NUM_PPORT_802_3_COUNTERS + \
 					 NUM_PPORT_2863_COUNTERS  + \
-					 NUM_PPORT_2819_COUNTERS)
+					 NUM_PPORT_2819_COUNTERS  + \
+					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
+					 NUM_PPORT_PRIO)
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
 
-- 
1.7.1
