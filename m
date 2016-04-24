From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 01/11] net/mlx5e: Report additional error statistics in get stats ndo
Date: Sun, 24 Apr 2016 22:51:46 +0300
Message-ID: <1461527516-29290-2-git-send-email-saeedm@mellanox.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53253 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752017AbcDXTyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 15:54:37 -0400
In-Reply-To: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Provide rtnl_link_stats64 with information regarding physical errors to be
seen in ifconfig and ip tool.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   39 +++++++++++++++++---
 1 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d485d1e..6270f8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2074,18 +2074,45 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5e_vport_stats *vstats = &priv->stats.vport;
+	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 
 	stats->rx_packets = vstats->rx_packets;
 	stats->rx_bytes   = vstats->rx_bytes;
 	stats->tx_packets = vstats->tx_packets;
 	stats->tx_bytes   = vstats->tx_bytes;
-	stats->multicast  = vstats->rx_multicast_packets +
-			    vstats->tx_multicast_packets;
-	stats->tx_errors  = vstats->tx_error_packets;
-	stats->rx_errors  = vstats->rx_error_packets;
+
+#define PPCNT_GET_802_3_CTR(fld)                            \
+	(MLX5_GET64(eth_802_3_cntrs_grp_data_layout,        \
+			pstats->IEEE_802_3_counters, fld##_high))
+
+#define PPCNT_GET_2863_CTR(fld)                             \
+	(MLX5_GET64(eth_2863_cntrs_grp_data_layout,         \
+			pstats->RFC_2863_counters, fld##_high))
+
+	stats->rx_dropped = priv->stats.qcnt.rx_out_of_buffer;
 	stats->tx_dropped = vstats->tx_queue_dropped;
-	stats->rx_crc_errors = 0;
-	stats->rx_length_errors = 0;
+
+	stats->rx_length_errors =
+		PPCNT_GET_802_3_CTR(a_in_range_length_errors) +
+		PPCNT_GET_802_3_CTR(a_out_of_range_length_field) +
+		PPCNT_GET_802_3_CTR(a_frame_too_long_errors);
+	stats->rx_crc_errors =
+		PPCNT_GET_802_3_CTR(a_frame_check_sequence_errors);
+	stats->rx_frame_errors =
+		PPCNT_GET_802_3_CTR(a_alignment_errors);
+	stats->tx_aborted_errors =
+		PPCNT_GET_2863_CTR(if_out_discards);
+	stats->tx_carrier_errors =
+		PPCNT_GET_802_3_CTR(a_symbol_error_during_carrier);
+	stats->rx_errors = stats->rx_length_errors + stats->rx_crc_errors +
+			   stats->rx_frame_errors;
+	stats->tx_errors = stats->tx_aborted_errors + stats->tx_carrier_errors;
+
+	/* vport multicast also counts packets that are dropped due to steering
+	 * or rx out of buffer
+	 */
+	stats->multicast = vstats->rx_multicast_packets;
+
 
 	return stats;
 }
-- 
1.7.1
