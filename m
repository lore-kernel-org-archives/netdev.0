From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 05/15] net/mlx5e: Add PCIe outbound stalls counters
Date: Sun, 20 Aug 2017 16:49:06 +0300
Message-ID: <20170820134916.10222-6-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44766 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752911AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

outbound_pci_stalled_rd - The percentage of time within the last second
that the NIC had outbound non-posted read requests but could not perform
the operation due to insufficient non-posted credits.

outbound_pci_stalled_wr - The percentage of time within the
last second that the NIC had outbound posted writes requests but could
not perform the operation due to insufficient posted credits.

outbound_pci_stalled_rd_events - The number of events where
outbound_pci_stalled_rd was above the threshold.

outbound_pci_stalled_wr_events - The number of events where
outbound_pci_stalled_wr was above the threshold.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h   | 13 ++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 917fade5f5d5..07202f7322fc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -246,6 +246,10 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pcie_perf_stats_desc[i].format);
 
+	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		       pcie_perf_stall_stats_desc[i].format);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			sprintf(data + (idx++) * ETH_GSTRING_LEN,
@@ -377,6 +381,10 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
 						  pcie_perf_stats_desc, i);
 
+	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
+		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
+						  pcie_perf_stall_stats_desc, i);
+
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[prio],
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index e65517eafc58..bdddddc46170 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -305,6 +305,13 @@ static const struct counter_desc pcie_perf_stats_desc[] = {
 	{ "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
 };
 
+static const struct counter_desc pcie_perf_stall_stats_desc[] = {
+	{ "outbound_pci_stalled_rd", PCIE_PERF_OFF(outbound_stalled_reads) },
+	{ "outbound_pci_stalled_wr", PCIE_PERF_OFF(outbound_stalled_writes) },
+	{ "outbound_pci_stalled_rd_events", PCIE_PERF_OFF(outbound_stalled_reads_events) },
+	{ "outbound_pci_stalled_wr_events", PCIE_PERF_OFF(outbound_stalled_writes_events) },
+};
+
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 bytes;
@@ -397,6 +404,9 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PCIE_PERF_COUNTERS(priv) \
 	(ARRAY_SIZE(pcie_perf_stats_desc) * \
 	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_performance_group))
+#define NUM_PCIE_PERF_STALL_COUNTERS(priv) \
+	(ARRAY_SIZE(pcie_perf_stall_stats_desc) * \
+	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_outbound_stalled))
 #define NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS \
 	ARRAY_SIZE(pport_per_prio_traffic_stats_desc)
 #define NUM_PPORT_PER_PRIO_PFC_COUNTERS \
@@ -407,7 +417,8 @@ static const struct counter_desc sq_stats_desc[] = {
 					 NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
 					 NUM_PPORT_PRIO)
-#define NUM_PCIE_COUNTERS(priv)		NUM_PCIE_PERF_COUNTERS(priv)
+#define NUM_PCIE_COUNTERS(priv)		(NUM_PCIE_PERF_COUNTERS(priv) + \
+					 NUM_PCIE_PERF_STALL_COUNTERS(priv))
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
 
-- 
2.13.0
