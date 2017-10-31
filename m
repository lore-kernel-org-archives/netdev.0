From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/14] net/mlx5e: Switch IEEE 802.3 counters to use stats group API
Date: Tue, 31 Oct 2017 15:06:37 -0700
Message-ID: <20171031220647.23614-5-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56564 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932578AbdJaWIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:09 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the IEEE 802.3 counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  9 ----
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 57 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 28 +----------
 3 files changed, 58 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 08089f1d2c4c..65e7c0a986ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -216,11 +216,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	/* PPORT counters */
-	for (i = 0; i < NUM_PPORT_802_3_COUNTERS; i++)
-		strcpy(data + (idx++) * ETH_GSTRING_LEN,
-		       pport_802_3_stats_desc[i].format);
-
 	for (i = 0; i < NUM_PPORT_2863_COUNTERS; i++)
 		strcpy(data + (idx++) * ETH_GSTRING_LEN,
 		       pport_2863_stats_desc[i].format);
@@ -349,10 +344,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	for (i = 0; i < NUM_PPORT_802_3_COUNTERS; i++)
-		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.IEEE_802_3_counters,
-						  pport_802_3_stats_desc, i);
-
 	for (i = 0; i < NUM_PPORT_2863_COUNTERS; i++)
 		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.RFC_2863_counters,
 						  pport_2863_stats_desc, i);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index 199e34f204a6..1ce296e4c9f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -197,6 +197,58 @@ static int mlx5e_grp_vport_fill_stats(struct mlx5e_priv *priv, u64 *data,
 	return idx;
 }
 
+#define PPORT_802_3_OFF(c) \
+	MLX5_BYTE_OFF(ppcnt_reg, \
+		      counter_set.eth_802_3_cntrs_grp_data_layout.c##_high)
+static const struct counter_desc pport_802_3_stats_desc[] = {
+	{ "tx_packets_phy", PPORT_802_3_OFF(a_frames_transmitted_ok) },
+	{ "rx_packets_phy", PPORT_802_3_OFF(a_frames_received_ok) },
+	{ "rx_crc_errors_phy", PPORT_802_3_OFF(a_frame_check_sequence_errors) },
+	{ "tx_bytes_phy", PPORT_802_3_OFF(a_octets_transmitted_ok) },
+	{ "rx_bytes_phy", PPORT_802_3_OFF(a_octets_received_ok) },
+	{ "tx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_xmitted_ok) },
+	{ "tx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_xmitted_ok) },
+	{ "rx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_received_ok) },
+	{ "rx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_received_ok) },
+	{ "rx_in_range_len_errors_phy", PPORT_802_3_OFF(a_in_range_length_errors) },
+	{ "rx_out_of_range_len_phy", PPORT_802_3_OFF(a_out_of_range_length_field) },
+	{ "rx_oversize_pkts_phy", PPORT_802_3_OFF(a_frame_too_long_errors) },
+	{ "rx_symbol_err_phy", PPORT_802_3_OFF(a_symbol_error_during_carrier) },
+	{ "tx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_transmitted) },
+	{ "rx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_received) },
+	{ "rx_unsupported_op_phy", PPORT_802_3_OFF(a_unsupported_opcodes_received) },
+	{ "rx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_received) },
+	{ "tx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_transmitted) },
+};
+
+#define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
+
+static int mlx5e_grp_802_3_get_num_stats(struct mlx5e_priv *priv)
+{
+	return NUM_PPORT_802_3_COUNTERS;
+}
+
+static int mlx5e_grp_802_3_fill_strings(struct mlx5e_priv *priv, u8 *data,
+					int idx)
+{
+	int i;
+
+	for (i = 0; i < NUM_PPORT_802_3_COUNTERS; i++)
+		strcpy(data + (idx++) * ETH_GSTRING_LEN, pport_802_3_stats_desc[i].format);
+	return idx;
+}
+
+static int mlx5e_grp_802_3_fill_stats(struct mlx5e_priv *priv, u64 *data,
+				      int idx)
+{
+	int i;
+
+	for (i = 0; i < NUM_PPORT_802_3_COUNTERS; i++)
+		data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.IEEE_802_3_counters,
+						  pport_802_3_stats_desc, i);
+	return idx;
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
@@ -213,6 +265,11 @@ const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 		.fill_strings = mlx5e_grp_vport_fill_strings,
 		.fill_stats = mlx5e_grp_vport_fill_stats,
 	},
+	{
+		.get_num_stats = mlx5e_grp_802_3_get_num_stats,
+		.fill_strings = mlx5e_grp_802_3_fill_strings,
+		.fill_stats = mlx5e_grp_802_3_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 610208aed767..5a489aa8fef3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -102,9 +102,6 @@ struct mlx5e_vport_stats {
 	__be64 query_vport_out[MLX5_ST_SZ_QW(query_vport_counter_out)];
 };
 
-#define PPORT_802_3_OFF(c) \
-	MLX5_BYTE_OFF(ppcnt_reg, \
-		      counter_set.eth_802_3_cntrs_grp_data_layout.c##_high)
 #define PPORT_802_3_GET(pstats, c) \
 	MLX5_GET64(ppcnt_reg, pstats->IEEE_802_3_counters, \
 		   counter_set.eth_802_3_cntrs_grp_data_layout.c##_high)
@@ -150,27 +147,6 @@ struct mlx5e_pport_stats {
 	__be64 eth_ext_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
 };
 
-static const struct counter_desc pport_802_3_stats_desc[] = {
-	{ "tx_packets_phy", PPORT_802_3_OFF(a_frames_transmitted_ok) },
-	{ "rx_packets_phy", PPORT_802_3_OFF(a_frames_received_ok) },
-	{ "rx_crc_errors_phy", PPORT_802_3_OFF(a_frame_check_sequence_errors) },
-	{ "tx_bytes_phy", PPORT_802_3_OFF(a_octets_transmitted_ok) },
-	{ "rx_bytes_phy", PPORT_802_3_OFF(a_octets_received_ok) },
-	{ "tx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_xmitted_ok) },
-	{ "tx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_xmitted_ok) },
-	{ "rx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_received_ok) },
-	{ "rx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_received_ok) },
-	{ "rx_in_range_len_errors_phy", PPORT_802_3_OFF(a_in_range_length_errors) },
-	{ "rx_out_of_range_len_phy", PPORT_802_3_OFF(a_out_of_range_length_field) },
-	{ "rx_oversize_pkts_phy", PPORT_802_3_OFF(a_frame_too_long_errors) },
-	{ "rx_symbol_err_phy", PPORT_802_3_OFF(a_symbol_error_during_carrier) },
-	{ "tx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_transmitted) },
-	{ "rx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_received) },
-	{ "rx_unsupported_op_phy", PPORT_802_3_OFF(a_unsupported_opcodes_received) },
-	{ "rx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_received) },
-	{ "tx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_transmitted) },
-};
-
 static const struct counter_desc pport_2863_stats_desc[] = {
 	{ "rx_discards_phy", PPORT_2863_OFF(if_in_discards) },
 	{ "tx_discards_phy", PPORT_2863_OFF(if_out_discards) },
@@ -336,7 +312,6 @@ static const struct counter_desc sq_stats_desc[] = {
 	{ MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
 };
 
-#define NUM_PPORT_802_3_COUNTERS	ARRAY_SIZE(pport_802_3_stats_desc)
 #define NUM_PPORT_2863_COUNTERS		ARRAY_SIZE(pport_2863_stats_desc)
 #define NUM_PPORT_2819_COUNTERS		ARRAY_SIZE(pport_2819_stats_desc)
 #define NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) \
@@ -358,8 +333,7 @@ static const struct counter_desc sq_stats_desc[] = {
 #define NUM_PPORT_ETH_EXT_COUNTERS(priv) \
 	(ARRAY_SIZE(pport_eth_ext_stats_desc) * \
 	 MLX5_CAP_PCAM_FEATURE((priv)->mdev, rx_buffer_fullness_counters))
-#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_802_3_COUNTERS + \
-					 NUM_PPORT_2863_COUNTERS  + \
+#define NUM_PPORT_COUNTERS(priv)	(NUM_PPORT_2863_COUNTERS  + \
 					 NUM_PPORT_2819_COUNTERS  + \
 					 NUM_PPORT_PHY_STATISTICAL_COUNTERS(priv) + \
 					 NUM_PPORT_PER_PRIO_TRAFFIC_COUNTERS * \
-- 
2.14.2
