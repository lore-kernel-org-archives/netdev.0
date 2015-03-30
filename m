From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx4_en: Moderate ethtool callback to show more statistics
Date: Mon, 30 Mar 2015 17:45:26 +0300
Message-ID: <1427726726-27516-8-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50843 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753525AbbC3OqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:46:21 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

More packet statistics are now calculated and visible to the user via
ethtool:

- RX packet errors statistics.
- TX/RX drops are now calculated.
- TX multicast and broadcast statistics.
- RX/TX per priority bytes statistics.
- RX/TX no vlan packets and bytes statistics.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   30 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  132 ++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |   14 ++-
 3 files changed, 130 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 4fc7674..eba969b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -162,10 +162,32 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tx_pause", "tx_pause_duration", "tx_pause_transition",
 
 	/* packet statistics */
-	"broadcast", "rx_prio_0", "rx_prio_1", "rx_prio_2", "rx_prio_3",
-	"rx_prio_4", "rx_prio_5", "rx_prio_6", "rx_prio_7", "tx_prio_0",
-	"tx_prio_1", "tx_prio_2", "tx_prio_3", "tx_prio_4", "tx_prio_5",
-	"tx_prio_6", "tx_prio_7",
+	"rx_multicast_packets",
+	"rx_broadcast_packets",
+	"rx_jabbers",
+	"rx_in_range_length_error",
+	"rx_out_range_length_error",
+	"tx_multicast_packets",
+	"tx_broadcast_packets",
+	"rx_prio_0_packets", "rx_prio_0_bytes",
+	"rx_prio_1_packets", "rx_prio_1_bytes",
+	"rx_prio_2_packets", "rx_prio_2_bytes",
+	"rx_prio_3_packets", "rx_prio_3_bytes",
+	"rx_prio_4_packets", "rx_prio_4_bytes",
+	"rx_prio_5_packets", "rx_prio_5_bytes",
+	"rx_prio_6_packets", "rx_prio_6_bytes",
+	"rx_prio_7_packets", "rx_prio_7_bytes",
+	"rx_novlan_packets", "rx_novlan_bytes",
+	"tx_prio_0_packets", "tx_prio_0_bytes",
+	"tx_prio_1_packets", "tx_prio_1_bytes",
+	"tx_prio_2_packets", "tx_prio_2_bytes",
+	"tx_prio_3_packets", "tx_prio_3_bytes",
+	"tx_prio_4_packets", "tx_prio_4_bytes",
+	"tx_prio_5_packets", "tx_prio_5_bytes",
+	"tx_prio_6_packets", "tx_prio_6_bytes",
+	"tx_prio_7_packets", "tx_prio_7_bytes",
+	"tx_novlan_packets", "tx_novlan_bytes",
+
 };
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 821ae12..54f0e5a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -128,6 +128,25 @@ out:
 	return err;
 }
 
+/* Each counter set is located in struct mlx4_en_stat_out_mbox
+ * with a const offset between its prio components.
+ * This function runs over a counter set and sum all of it's prio components.
+ */
+static unsigned long en_stats_adder(__be64 *start, __be64 *next, int num)
+{
+	__be64 *curr = start;
+	unsigned long ret = 0;
+	int i;
+	int offset = next - start;
+
+	for (i = 0; i <= num; i++) {
+		ret += be64_to_cpu(*curr);
+		curr += offset;
+	}
+
+	return ret;
+}
+
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
@@ -184,22 +203,25 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		priv->port_stats.xmit_more         += ring->xmit_more;
 	}
 
+	/* net device stats */
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
-			   be32_to_cpu(mlx4_en_stats->RdropLength) +
 			   be32_to_cpu(mlx4_en_stats->RJBBR) +
 			   be32_to_cpu(mlx4_en_stats->RCRC) +
-			   be32_to_cpu(mlx4_en_stats->RRUNT);
-	stats->tx_errors = be32_to_cpu(mlx4_en_stats->TDROP);
-	stats->multicast = be64_to_cpu(mlx4_en_stats->MCAST_prio_0) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_1) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_2) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_3) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_4) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_5) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_6) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_prio_7) +
-			   be64_to_cpu(mlx4_en_stats->MCAST_novlan);
+			   be32_to_cpu(mlx4_en_stats->RRUNT) +
+			   be64_to_cpu(mlx4_en_stats->RInRangeLengthErr) +
+			   be64_to_cpu(mlx4_en_stats->ROutRangeLengthErr) +
+			   be32_to_cpu(mlx4_en_stats->RSHORT) +
+			   en_stats_adder(&mlx4_en_stats->RGIANT_prio_0,
+					  &mlx4_en_stats->RGIANT_prio_1,
+					  NUM_PRIORITIES);
+	stats->tx_errors = en_stats_adder(&mlx4_en_stats->TGIANT_prio_0,
+					  &mlx4_en_stats->TGIANT_prio_1,
+					  NUM_PRIORITIES);
+	stats->multicast = en_stats_adder(&mlx4_en_stats->MCAST_prio_0,
+					  &mlx4_en_stats->MCAST_prio_1,
+					  NUM_PRIORITIES);
 	stats->collisions = 0;
+	stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP);
 	stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
 	stats->rx_over_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
 	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
@@ -211,33 +233,67 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->tx_fifo_errors = 0;
 	stats->tx_heartbeat_errors = 0;
 	stats->tx_window_errors = 0;
+	stats->tx_dropped = be32_to_cpu(mlx4_en_stats->TDROP);
+
+	/* RX stats */
+	priv->pkstats.rx_multicast_packets = stats->multicast;
+	priv->pkstats.rx_broadcast_packets =
+			en_stats_adder(&mlx4_en_stats->RBCAST_prio_0,
+				       &mlx4_en_stats->RBCAST_prio_1,
+				       NUM_PRIORITIES);
+	priv->pkstats.rx_jabbers = be32_to_cpu(mlx4_en_stats->RJBBR);
+	priv->pkstats.rx_in_range_length_error =
+		be64_to_cpu(mlx4_en_stats->RInRangeLengthErr);
+	priv->pkstats.rx_out_range_length_error =
+		be64_to_cpu(mlx4_en_stats->ROutRangeLengthErr);
+
+	/* Tx stats */
+	priv->pkstats.tx_multicast_packets =
+		en_stats_adder(&mlx4_en_stats->TMCAST_prio_0,
+			       &mlx4_en_stats->TMCAST_prio_1,
+			       NUM_PRIORITIES);
+	priv->pkstats.tx_broadcast_packets =
+		en_stats_adder(&mlx4_en_stats->TBCAST_prio_0,
+			       &mlx4_en_stats->TBCAST_prio_1,
+			       NUM_PRIORITIES);
+
+	priv->pkstats.rx_prio[0][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_0);
+	priv->pkstats.rx_prio[0][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_0);
+	priv->pkstats.rx_prio[1][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_1);
+	priv->pkstats.rx_prio[1][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_1);
+	priv->pkstats.rx_prio[2][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_2);
+	priv->pkstats.rx_prio[2][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_2);
+	priv->pkstats.rx_prio[3][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_3);
+	priv->pkstats.rx_prio[3][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_3);
+	priv->pkstats.rx_prio[4][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_4);
+	priv->pkstats.rx_prio[4][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_4);
+	priv->pkstats.rx_prio[5][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_5);
+	priv->pkstats.rx_prio[5][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_5);
+	priv->pkstats.rx_prio[6][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_6);
+	priv->pkstats.rx_prio[6][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_6);
+	priv->pkstats.rx_prio[7][0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_7);
+	priv->pkstats.rx_prio[7][1] = be64_to_cpu(mlx4_en_stats->ROCT_prio_7);
+	priv->pkstats.rx_prio[8][0] = be64_to_cpu(mlx4_en_stats->RTOT_novlan);
+	priv->pkstats.rx_prio[8][1] = be64_to_cpu(mlx4_en_stats->ROCT_novlan);
+	priv->pkstats.tx_prio[0][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_0);
+	priv->pkstats.tx_prio[0][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_0);
+	priv->pkstats.tx_prio[1][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_1);
+	priv->pkstats.tx_prio[1][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_1);
+	priv->pkstats.tx_prio[2][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_2);
+	priv->pkstats.tx_prio[2][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_2);
+	priv->pkstats.tx_prio[3][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_3);
+	priv->pkstats.tx_prio[3][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_3);
+	priv->pkstats.tx_prio[4][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_4);
+	priv->pkstats.tx_prio[4][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_4);
+	priv->pkstats.tx_prio[5][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_5);
+	priv->pkstats.tx_prio[5][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_5);
+	priv->pkstats.tx_prio[6][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_6);
+	priv->pkstats.tx_prio[6][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_6);
+	priv->pkstats.tx_prio[7][0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_7);
+	priv->pkstats.tx_prio[7][1] = be64_to_cpu(mlx4_en_stats->TOCT_prio_7);
+	priv->pkstats.tx_prio[8][0] = be64_to_cpu(mlx4_en_stats->TTOT_novlan);
+	priv->pkstats.tx_prio[8][1] = be64_to_cpu(mlx4_en_stats->TOCT_novlan);
 
-	priv->pkstats.broadcast =
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_0) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_1) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_2) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_3) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_4) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_5) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_6) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_prio_7) +
-				be64_to_cpu(mlx4_en_stats->RBCAST_novlan);
-	priv->pkstats.rx_prio[0] = be64_to_cpu(mlx4_en_stats->RTOT_prio_0);
-	priv->pkstats.rx_prio[1] = be64_to_cpu(mlx4_en_stats->RTOT_prio_1);
-	priv->pkstats.rx_prio[2] = be64_to_cpu(mlx4_en_stats->RTOT_prio_2);
-	priv->pkstats.rx_prio[3] = be64_to_cpu(mlx4_en_stats->RTOT_prio_3);
-	priv->pkstats.rx_prio[4] = be64_to_cpu(mlx4_en_stats->RTOT_prio_4);
-	priv->pkstats.rx_prio[5] = be64_to_cpu(mlx4_en_stats->RTOT_prio_5);
-	priv->pkstats.rx_prio[6] = be64_to_cpu(mlx4_en_stats->RTOT_prio_6);
-	priv->pkstats.rx_prio[7] = be64_to_cpu(mlx4_en_stats->RTOT_prio_7);
-	priv->pkstats.tx_prio[0] = be64_to_cpu(mlx4_en_stats->TTOT_prio_0);
-	priv->pkstats.tx_prio[1] = be64_to_cpu(mlx4_en_stats->TTOT_prio_1);
-	priv->pkstats.tx_prio[2] = be64_to_cpu(mlx4_en_stats->TTOT_prio_2);
-	priv->pkstats.tx_prio[3] = be64_to_cpu(mlx4_en_stats->TTOT_prio_3);
-	priv->pkstats.tx_prio[4] = be64_to_cpu(mlx4_en_stats->TTOT_prio_4);
-	priv->pkstats.tx_prio[5] = be64_to_cpu(mlx4_en_stats->TTOT_prio_5);
-	priv->pkstats.tx_prio[6] = be64_to_cpu(mlx4_en_stats->TTOT_prio_6);
-	priv->pkstats.tx_prio[7] = be64_to_cpu(mlx4_en_stats->TTOT_prio_7);
 	spin_unlock_bh(&priv->stats_lock);
 
 	/* 0xffs indicates invalid value */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index e193680..0055583 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -11,10 +11,16 @@
 #define NUM_PRIORITY_STATS 2
 
 struct mlx4_en_pkt_stats {
-	unsigned long broadcast;
-	unsigned long rx_prio[8];
-	unsigned long tx_prio[8];
-#define NUM_PKT_STATS                17
+	unsigned long rx_multicast_packets;
+	unsigned long rx_broadcast_packets;
+	unsigned long rx_jabbers;
+	unsigned long rx_in_range_length_error;
+	unsigned long rx_out_range_length_error;
+	unsigned long tx_multicast_packets;
+	unsigned long tx_broadcast_packets;
+	unsigned long rx_prio[NUM_PRIORITIES][NUM_PRIORITY_STATS];
+	unsigned long tx_prio[NUM_PRIORITIES][NUM_PRIORITY_STATS];
+#define NUM_PKT_STATS		43
 };
 
 struct mlx4_en_port_stats {
-- 
1.7.1
