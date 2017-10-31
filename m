From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/14] net/mlx5e: Switch Q counters to use the stats group API
Date: Tue, 31 Oct 2017 15:06:35 -0700
Message-ID: <20171031220647.23614-3-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56522 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753802AbdJaWIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:05 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the Q counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 10 ------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 36 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  5 ---
 3 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index dfc440d7278d..35ba40af2a73 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -166,7 +166,6 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 	return err ? false : rx_pause | tx_pause;
 }
 
-#define MLX5E_NUM_Q_CNTRS(priv) (NUM_Q_COUNTERS * (!!priv->q_counter))
 #define MLX5E_NUM_RQ_STATS(priv) (NUM_RQ_STATS * (priv)->channels.num)
 #define MLX5E_NUM_SQ_STATS(priv) \
 	(NUM_SQ_STATS * (priv)->channels.num * (priv)->channels.params.num_tc)
@@ -183,7 +182,6 @@ int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 		for (i = 0; i < mlx5e_num_stats_grps; i++)
 			num_stats += mlx5e_stats_grps[i].get_num_stats(priv);
 		return num_stats +
-		       MLX5E_NUM_Q_CNTRS(priv) +
 		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS(priv) +
 		       NUM_PCIE_COUNTERS(priv) +
 		       MLX5E_NUM_RQ_STATS(priv) +
@@ -218,10 +216,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	/* Q counters */
-	for (i = 0; i < MLX5E_NUM_Q_CNTRS(priv); i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN, q_stats_desc[i].format);
-
 	/* VPORT counters */
 	for (i = 0; i < NUM_VPORT_COUNTERS; i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
@@ -360,10 +354,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	for (i = 0; i < MLX5E_NUM_Q_CNTRS(priv); i++)
-		data[idx++] = MLX5E_READ_CTR32_CPU(&priv->stats.qcnt,
-						   q_stats_desc, i);
-
 	for (i = 0; i < NUM_VPORT_COUNTERS; i++)
 		data[idx++] = MLX5E_READ_CTR64_BE(priv->stats.vport.query_vport_out,
 						  vport_stats_desc, i);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index 25a1a6d8aa9d..64b344720a31 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -96,12 +96,46 @@ static int mlx5e_grp_sw_fill_stats(struct mlx5e_priv *priv, u64 *data, int idx)
 	return idx;
 }
 
+static const struct counter_desc q_stats_desc[] = {
+	{ MLX5E_DECLARE_STAT(struct mlx5e_qcounter_stats, rx_out_of_buffer) },
+};
+
+#define NUM_Q_COUNTERS			ARRAY_SIZE(q_stats_desc)
+
+static int mlx5e_grp_q_get_num_stats(struct mlx5e_priv *priv)
+{
+	return priv->q_counter ? NUM_Q_COUNTERS : 0;
+}
+
+static int mlx5e_grp_q_fill_strings(struct mlx5e_priv *priv, u8 *data, int idx)
+{
+	int i;
+
+	for (i = 0; i < NUM_Q_COUNTERS && priv->q_counter; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, q_stats_desc[i].format);
+	return idx;
+}
+
+static int mlx5e_grp_q_fill_stats(struct mlx5e_priv *priv, u64 *data, int idx)
+{
+	int i;
+
+	for (i = 0; i < NUM_Q_COUNTERS && priv->q_counter; i++)
+		data[idx++] = MLX5E_READ_CTR32_CPU(&priv->stats.qcnt, q_stats_desc, i);
+	return idx;
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
 		.fill_strings = mlx5e_grp_sw_fill_strings,
 		.fill_stats = mlx5e_grp_sw_fill_stats,
-	}
+	},
+	{
+		.get_num_stats = mlx5e_grp_q_get_num_stats,
+		.fill_strings = mlx5e_grp_q_fill_strings,
+		.fill_stats = mlx5e_grp_q_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 6d2d8abf1929..b82ecb1fa353 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -95,10 +95,6 @@ struct mlx5e_qcounter_stats {
 	u32 rx_out_of_buffer;
 };
 
-static const struct counter_desc q_stats_desc[] = {
-	{ MLX5E_DECLARE_STAT(struct mlx5e_qcounter_stats, rx_out_of_buffer) },
-};
-
 #define VPORT_COUNTER_OFF(c) MLX5_BYTE_OFF(query_vport_counter_out, c)
 #define VPORT_COUNTER_GET(vstats, c) MLX5_GET64(query_vport_counter_out, \
 						vstats->query_vport_out, c)
@@ -384,7 +380,6 @@ static const struct counter_desc sq_stats_desc[] = {
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
 };
 
-#define NUM_Q_COUNTERS			ARRAY_SIZE(q_stats_desc)
 #define NUM_VPORT_COUNTERS		ARRAY_SIZE(vport_stats_desc)
 #define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
 #define NUM_PPORT_2863_COUNTERS		ARRAY_SIZE(pport_2863_stats_desc)
-- 
2.14.2
