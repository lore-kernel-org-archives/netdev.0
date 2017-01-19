From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/15] net/mlx5e: Expose PCIe statistics to ethtool
Date: Fri, 20 Jan 2017 00:39:06 +0200
Message-ID: <20170119223908.15924-14-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59327 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751220AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

This patch exposes PCIe performance counters, queried with
ethtool -S <devname>.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  9 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 23 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 22 ++++++++++++++++++++-
 3 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index dcc3e4dc1484..4021863e3840 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -171,6 +171,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 		return NUM_SW_COUNTERS +
 		       MLX5E_NUM_Q_CNTRS(priv) +
 		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS(priv) +
+		       NUM_PCIE_COUNTERS(priv) +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv) +
@@ -222,6 +223,10 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_phy_statistical_stats_desc[i].format);
 
+	for (i = 0; i < NUM_PCIE_PERF_COUNTERS(priv); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       pcie_perf_stats_desc[i].format);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
@@ -338,6 +343,10 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.phy_statistical_counters,
 						  pport_phy_statistical_stats_desc, i);
 
+	for (i = 0; i < NUM_PCIE_PERF_COUNTERS(priv); i++)
+		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
+						  pcie_perf_stats_desc, i);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3be87a65d750..9aed892cd350 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -297,12 +297,35 @@ static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
 				      &qcnt->rx_out_of_buffer);
 }
 
+static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
+{
+	struct mlx5e_pcie_stats *pcie_stats = &priv->stats.pcie;
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int sz = MLX5_ST_SZ_BYTES(mpcnt_reg);
+	void *out;
+	u32 *in;
+
+	if (!MLX5_CAP_MCAM_FEATURE(mdev, pcie_performance_group))
+		return;
+
+	in = mlx5_vzalloc(sz);
+	if (!in)
+		return;
+
+	out = pcie_stats->pcie_perf_counters;
+	MLX5_SET(mpcnt_reg, in, grp, MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP);
+	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
+
+	kvfree(in);
+}
+
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
 	mlx5e_update_q_counter(priv);
 	mlx5e_update_vport_counters(priv);
 	mlx5e_update_pport_counters(priv);
 	mlx5e_update_sw_counters(priv);
+	mlx5e_update_pcie_counters(priv);
 }
 
 void mlx5e_update_stats_work(struct work_struct *work)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 21c43d4e4f2e..53e4992d6511 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -39,7 +39,7 @@
 #define MLX5E_READ_CTR32_CPU(ptr, dsc, i) \
 	(*(u32 *)((char *)ptr + dsc[i].offset))
 #define MLX5E_READ_CTR32_BE(ptr, dsc, i) \
-	be64_to_cpu(*(__be32 *)((char *)ptr + dsc[i].offset))
+	be32_to_cpu(*(__be32 *)((char *)ptr + dsc[i].offset))
 
 #define MLX5E_DECLARE_STAT(type, fld) #fld, offsetof(type, fld)
 #define MLX5E_DECLARE_RX_STAT(type, fld) "rx%d_"#fld, offsetof(type, fld)
@@ -288,6 +288,21 @@ static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
 	{ "rx_%s_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
 };
 
+#define PCIE_PERF_OFF(c) \
+	MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_perf_cntrs_grp_data_layout.c)
+#define PCIE_PERF_GET(pcie_stats, c) \
+	MLX5_GET(mpcnt_reg, (pcie_stats)->pcie_perf_counters, \
+		 counter_set.pcie_perf_cntrs_grp_data_layout.c)
+
+struct mlx5e_pcie_stats {
+	__be64 pcie_perf_counters[MLX5_ST_SZ_QW(mpcnt_reg)];
+};
+
+static const struct counter_desc pcie_perf_stats_desc[] = {
+	{ "rx_pci_signal_integrity", PCIE_PERF_OFF(rx_errors) },
+	{ "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
+};
+
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 bytes;
@@ -375,6 +390,9 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) \
 	(ARRAY_SIZE(pport_phy_statistical_stats_desc) * \
 	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, ppcnt_statistical_group))
+#define NUM_PCIE_PERF_COUNTERS(priv) \
+	(ARRAY_SIZE(pcie_perf_stats_desc) * \
+	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_performance_group))
 #define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
@@ -385,6 +403,7 @@ static const struct counter_desc sq_stats_desc[] = {
 					 NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
 					 NUM_PPORT_PRIO)
+#define NUM_PCIE_COUNTERS(priv)		NUM_PCIE_PERF_COUNTERS(priv)
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
 
@@ -394,6 +413,7 @@ struct mlx5e_stats {
 	struct mlx5e_vport_stats vport;
 	struct mlx5e_pport_stats pport;
 	struct rtnl_link_stats64 vf_vport;
+	struct mlx5e_pcie_stats pcie;
 };
 
 static const struct counter_desc mlx5e_pme_status_desc[] = {
-- 
2.11.0
