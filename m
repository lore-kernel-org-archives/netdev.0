From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/15] net/mlx5e: Add outbound PCI buffer overflow counter
Date: Thu, 17 Aug 2017 16:29:56 +0300
Message-ID: <20170817133003.16900-9-saeedm@mellanox.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47126 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752542AbdHQNaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:17 -0400
In-Reply-To: <20170817133003.16900-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add outbound_pci_buffer_overflow to ethtool output for monitoring the
number of packets that were dropped due to lack of PCIe buffers on
receive path from NIC port toward the host(s).

This counter is valid only in case that tx_overflow_buffer_pkt is
supported in MCAM enhanced features.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 12 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h   | 14 ++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                        |  6 ++++--
 3 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 8c013a521319..d453a11f41fe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -250,9 +250,13 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pcie_perf_stats_desc[i].format);
 
-	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
+	for (i = 0; i < NUM_PCIE_PERF_COUNTERS64(priv); i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		       pcie_perf_stall_stats_desc[i].format);
+		       pcie_perf_stats_desc64[i].format);
+
+	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
+	 strcpy(data + (idx++) * ETH_GSTRING_LEN,
+		pcie_perf_stall_stats_desc[i].format);
 
 	for (prio = 0; prio < NUM_PPORT_PRIO; prio++) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS; i++)
@@ -389,6 +393,10 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
 						  pcie_perf_stats_desc, i);
 
+	for (i = 0; i < NUM_PCIE_PERF_COUNTERS64(priv); i++)
+		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pcie.pcie_perf_counters,
+						  pcie_perf_stats_desc64, i);
+
 	for (i = 0; i < NUM_PCIE_PERF_STALL_COUNTERS(priv); i++)
 		data[idx++] = MLX5E_READ_CTR32_BE(&priv->stats.pcie.pcie_perf_counters,
 						  pcie_perf_stall_stats_desc, i);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index be49df4bedd9..40b5c73e5e26 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -307,6 +307,12 @@ static const struct counter_desc pport_eth_ext_stats_desc[] = {
 	MLX5_GET(mpcnt_reg, (pcie_stats)->pcie_perf_counters, \
 		 counter_set.pcie_perf_cntrs_grp_data_layout.c)
 
+#define PCIE_PERF_OFF64(c) \
+	MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_perf_cntrs_grp_data_layout.c##_high)
+#define PCIE_PERF_GET64(pcie_stats, c) \
+	MLX5_GET64(mpcnt_reg, (pcie_stats)->pcie_perf_counters, \
+		   counter_set.pcie_perf_cntrs_grp_data_layout.c##_high)
+
 struct mlx5e_pcie_stats {
 	__be64 pcie_perf_counters[MLX5_ST_SZ_QW(mpcnt_reg)];
 };
@@ -316,6 +322,10 @@ static const struct counter_desc pcie_perf_stats_desc[] = {
 	{ "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
 };
 
+static const struct counter_desc pcie_perf_stats_desc64[] = {
+	{ "outbound_pci_buffer_overflow", PCIE_PERF_OFF64(tx_overflow_buffer_pkt) },
+};
+
 static const struct counter_desc pcie_perf_stall_stats_desc[] = {
 	{ "outbound_pci_stalled_rd", PCIE_PERF_OFF(outbound_stalled_reads) },
 	{ "outbound_pci_stalled_wr", PCIE_PERF_OFF(outbound_stalled_writes) },
@@ -415,6 +425,9 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PCIE_PERF_COUNTERS(priv) \
 	(ARRAY_SIZE(pcie_perf_stats_desc) * \
 	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_performance_group))
+#define NUM_PCIE_PERF_COUNTERS64(priv) \
+	(ARRAY_SIZE(pcie_perf_stats_desc64) * \
+	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, tx_overflow_buffer_pkt))
 #define NUM_PCIE_PERF_STALL_COUNTERS(priv) \
 	(ARRAY_SIZE(pcie_perf_stall_stats_desc) * \
 	 MLX5_CAP_MCAM_FEATURE((priv)->mdev, pcie_outbound_stalled))
@@ -433,6 +446,7 @@ static const struct counter_desc sq_stats_desc[] = {
 					 NUM_PPORT_PRIO + \
 					 NUM_PPORT_ETH_EXT_COUNTERS(priv))
 #define NUM_PCIE_COUNTERS(priv)		(NUM_PCIE_PERF_COUNTERS(priv) + \
+					 NUM_PCIE_PERF_COUNTERS64(priv) +\
 					 NUM_PCIE_PERF_STALL_COUNTERS(priv))
 #define NUM_RQ_STATS			ARRAY_SIZE(rq_stats_desc)
 #define NUM_SQ_STATS			ARRAY_SIZE(sq_stats_desc)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index cf7ff52c594e..ae7d09b9c52f 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1864,7 +1864,9 @@ struct mlx5_ifc_pcie_perf_cntrs_grp_data_layout_bits {
 
 	u8         crc_error_tlp[0x20];
 
-	u8         reserved_at_140[0x40];
+	u8         tx_overflow_buffer_pkt_high[0x20];
+
+	u8         tx_overflow_buffer_pkt_low[0x20];
 
 	u8         outbound_stalled_reads[0x20];
 
@@ -7767,7 +7769,7 @@ struct mlx5_ifc_pcam_reg_bits {
 struct mlx5_ifc_mcam_enhanced_features_bits {
 	u8         reserved_at_0[0x7b];
 	u8         pcie_outbound_stalled[0x1];
-	u8         reserved_at_7c[0x1];
+	u8         tx_overflow_buffer_pkt[0x1];
 	u8         mtpps_enh_out_per_adj[0x1];
 	u8         mtpps_fs[0x1];
 	u8         pcie_performance_group[0x1];
-- 
2.13.0
