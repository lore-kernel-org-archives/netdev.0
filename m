From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/1] sfc: only use vadaptor stats if firmware is capable
Date: Wed, 26 Aug 2015 16:39:03 +0100
Message-ID: <55DDDD97.90204@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:44539 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756564AbbHZPjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

Some of the stats handling code differs based on SR-IOV support,
and SRIOV support is only available if full-featured firmware is
used.
Do not use vadaptor stats if firmware mode is not set to
full-featured.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 605cc89..b1a4ea2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1282,7 +1282,12 @@ static size_t efx_ef10_update_stats_common(struct efx_nic *efx, u64 *full_stats,
 		}
 	}
 
-	if (core_stats) {
+	if (!core_stats)
+		return stats_count;
+
+	if (nic_data->datapath_caps &
+			1 << MC_CMD_GET_CAPABILITIES_OUT_EVB_LBN) {
+		/* Use vadaptor stats. */
 		core_stats->rx_packets = stats[EF10_STAT_rx_unicast] +
 					 stats[EF10_STAT_rx_multicast] +
 					 stats[EF10_STAT_rx_broadcast];
@@ -1302,6 +1307,26 @@ static size_t efx_ef10_update_stats_common(struct efx_nic *efx, u64 *full_stats,
 		core_stats->rx_fifo_errors = stats[EF10_STAT_rx_overflow];
 		core_stats->rx_errors = core_stats->rx_crc_errors;
 		core_stats->tx_errors = stats[EF10_STAT_tx_bad];
+	} else {
+		/* Use port stats. */
+		core_stats->rx_packets = stats[EF10_STAT_port_rx_packets];
+		core_stats->tx_packets = stats[EF10_STAT_port_tx_packets];
+		core_stats->rx_bytes = stats[EF10_STAT_port_rx_bytes];
+		core_stats->tx_bytes = stats[EF10_STAT_port_tx_bytes];
+		core_stats->rx_dropped = stats[EF10_STAT_port_rx_nodesc_drops] +
+					 stats[GENERIC_STAT_rx_nodesc_trunc] +
+					 stats[GENERIC_STAT_rx_noskb_drops];
+		core_stats->multicast = stats[EF10_STAT_port_rx_multicast];
+		core_stats->rx_length_errors =
+				stats[EF10_STAT_port_rx_gtjumbo] +
+				stats[EF10_STAT_port_rx_length_error];
+		core_stats->rx_crc_errors = stats[EF10_STAT_port_rx_bad];
+		core_stats->rx_frame_errors =
+				stats[EF10_STAT_port_rx_align_error];
+		core_stats->rx_fifo_errors = stats[EF10_STAT_port_rx_overflow];
+		core_stats->rx_errors = (core_stats->rx_length_errors +
+					 core_stats->rx_crc_errors +
+					 core_stats->rx_frame_errors);
 	}
 
 	return stats_count;
