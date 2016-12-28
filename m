From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 08/12] Revert "net/mlx5e: Expose PCIe statistics to ethtool"
Date: Wed, 28 Dec 2016 14:58:38 +0200
Message-ID: <1482929922-32626-9-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32801 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751575AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

This reverts commit 9c7262399ba12825f3ca4b00a76d8d5e77c720f5.
PCIe counters were introduced in a new firmware version, as a result users
with old firmware encountered a syndrome every 200ms due to update stats
work. This feature will be re-introduced later with appropriate capabilities
infrastructure.

Fixes: 9c7262399ba1 ("net/mlx5e: Expose PCIe statistics to ethtool")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 17 ------------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 24 ----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 32 +---------------------
 3 files changed, 1 insertion(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 352462a..33a399a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -171,7 +171,6 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 		return NUM_SW_COUNTERS +
 		       MLX5E_NUM_Q_CNTRS(priv) +
 		       NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
-		       NUM_PCIE_COUNTERS +
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv) +
@@ -219,14 +218,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_2819_stats_desc[i].format);
 
-	for (i = 0; i < NUM_PCIE_PERF_COUNTERS; i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		       pcie_perf_stats_desc[i].format);
-
-	for (i = 0; i < NUM_PCIE_TAS_COUNTERS; i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		       pcie_tas_stats_desc[i].format);
-
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
@@ -339,14 +330,6 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.RFC_2819_counters,
 						  pport_2819_stats_desc, i);
 
-	for (i = 0; i < NUM_PCIE_PERF_COUNTERS; i++)
-		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
-						  pcie_perf_stats_desc, i);
-
-	for (i = 0; i < NUM_PCIE_TAS_COUNTERS; i++)
-		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_tas_counters,
-						  pcie_tas_stats_desc, i);
-
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cbfa38f..be5ef03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -291,36 +291,12 @@ static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
 				      &qcnt->rx_out_of_buffer);
 }
 
-static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
-{
-	struct mlx5e_pcie_stats *pcie_stats = &priv->stats.pcie;
-	struct mlx5_core_dev *mdev = priv->mdev;
-	int sz = MLX5_ST_SZ_BYTES(mpcnt_reg);
-	void *out;
-	u32 *in;
-
-	in = mlx5_vzalloc(sz);
-	if (!in)
-		return;
-
-	out = pcie_stats->pcie_perf_counters;
-	MLX5_SET(mpcnt_reg, in, grp, MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP);
-	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
-
-	out = pcie_stats->pcie_tas_counters;
-	MLX5_SET(mpcnt_reg, in, grp, MLX5_PCIE_TIMERS_AND_STATES_COUNTERS_GROUP);
-	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
-
-	kvfree(in);
-}
-
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
 	mlx5e_update_q_counter(priv);
 	mlx5e_update_vport_counters(priv);
 	mlx5e_update_pport_counters(priv);
 	mlx5e_update_sw_counters(priv);
-	mlx5e_update_pcie_counters(priv);
 }
 
 void mlx5e_update_stats_work(struct work_struct *work)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index f202f87..ba5db1d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -39,7 +39,7 @@
 #define MLX5E_READ_CTR32_CPU(ptr, dsc, i) \
 	(*(u32 *)((char *)ptr + dsc[i].offset))
 #define MLX5E_READ_CTR32_BE(ptr, dsc, i) \
-	be32_to_cpu(*(__be32 *)((char *)ptr + dsc[i].offset))
+	be64_to_cpu(*(__be32 *)((char *)ptr + dsc[i].offset))
 
 #define MLX5E_DECLARE_STAT(type, fld) #fld, offsetof(type, fld)
 #define MLX5E_DECLARE_RX_STAT(type, fld) "rx%d_"#fld, offsetof(type, fld)
@@ -276,32 +276,6 @@ static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
 	{ "rx_%s_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
 };
 
-#define PCIE_PERF_OFF(c) \
-	MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_perf_cntrs_grp_data_layout.c)
-#define PCIE_PERF_GET(pcie_stats, c) \
-	MLX5_GET(mpcnt_reg, pcie_stats->pcie_perf_counters, \
-		 counter_set.pcie_perf_cntrs_grp_data_layout.c)
-#define PCIE_TAS_OFF(c) \
-	MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_tas_cntrs_grp_data_layout.c)
-#define PCIE_TAS_GET(pcie_stats, c) \
-	MLX5_GET(mpcnt_reg, pcie_stats->pcie_tas_counters, \
-		 counter_set.pcie_tas_cntrs_grp_data_layout.c)
-
-struct mlx5e_pcie_stats {
-	__be64 pcie_perf_counters[MLX5_ST_SZ_QW(mpcnt_reg)];
-	__be64 pcie_tas_counters[MLX5_ST_SZ_QW(mpcnt_reg)];
-};
-
-static const struct counter_desc pcie_perf_stats_desc[] = {
-	{ "rx_pci_signal_integrity", PCIE_PERF_OFF(rx_errors) },
-	{ "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
-};
-
-static const struct counter_desc pcie_tas_stats_desc[] = {
-	{ "tx_pci_transport_nonfatal_msg", PCIE_TAS_OFF(non_fatal_err_msg_sent) },
-	{ "tx_pci_transport_fatal_msg", PCIE_TAS_OFF(fatal_err_msg_sent) },
-};
-
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 bytes;
@@ -386,8 +360,6 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
 #define NUM_PPORT_2863_COUNTERS		ARRAY_SIZE(pport_2863_stats_desc)
 #define NUM_PPORT_2819_COUNTERS		ARRAY_SIZE(pport_2819_stats_desc)
-#define NUM_PCIE_PERF_COUNTERS		ARRAY_SIZE(pcie_perf_stats_desc)
-#define NUM_PCIE_TAS_COUNTERS		ARRAY_SIZE(pcie_tas_stats_desc)
 #define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
@@ -397,7 +369,6 @@ static const struct counter_desc sq_stats_desc[] = {
 					 NUM_PPORT_2819_COUNTERS  + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
 					 NUM_PPORT_PRIO)
-#define NUM_PCIE_COUNTERS		(NUM_PCIE_PERF_COUNTERS + NUM_PCIE_TAS_COUNTERS)
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
 
@@ -406,7 +377,6 @@ struct mlx5e_stats {
 	struct mlx5e_qcounter_stats qcnt;
 	struct mlx5e_vport_stats vport;
 	struct mlx5e_pport_stats pport;
-	struct mlx5e_pcie_stats pcie;
 	struct rtnl_link_stats64 vf_vport;
 };
 
-- 
2.7.4
