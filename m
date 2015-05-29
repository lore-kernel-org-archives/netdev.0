From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 08/14] sfc: update netdevice statistics to use vadaptor
 stats
Date: Fri, 29 May 2015 11:02:30 +0100
Message-ID: <55683936.7010107@solarflare.com>
References: <55683895.2090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:32645 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755832AbbE2KCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:02:37 -0400
In-Reply-To: <55683895.2090408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The netdevice statistics (in /proc/net/dev) are per-function
stats so they must use the vadaptor stats. Change the use of
MAC stats to vadaptor stats, and remove any statistics that
can only be measured per-port.  All stats that are removed
will be shown as zeroes when these statistics are displayed.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 6aaec4e..1e83c18 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1224,24 +1224,25 @@ static size_t efx_ef10_update_stats_common(struct efx_nic *efx, u64 *full_stats,
 	}
 
 	if (core_stats) {
-		core_stats->rx_packets = stats[EF10_STAT_port_rx_packets];
-		core_stats->tx_packets = stats[EF10_STAT_port_tx_packets];
-		core_stats->rx_bytes = stats[EF10_STAT_port_rx_bytes];
-		core_stats->tx_bytes = stats[EF10_STAT_port_tx_bytes];
-		core_stats->rx_dropped = stats[EF10_STAT_port_rx_nodesc_drops] +
-					 stats[GENERIC_STAT_rx_nodesc_trunc] +
+		core_stats->rx_packets = stats[EF10_STAT_rx_unicast] +
+					 stats[EF10_STAT_rx_multicast] +
+					 stats[EF10_STAT_rx_broadcast];
+		core_stats->tx_packets = stats[EF10_STAT_tx_unicast] +
+					 stats[EF10_STAT_tx_multicast] +
+					 stats[EF10_STAT_tx_broadcast];
+		core_stats->rx_bytes = stats[EF10_STAT_rx_unicast_bytes] +
+				       stats[EF10_STAT_rx_multicast_bytes] +
+				       stats[EF10_STAT_rx_broadcast_bytes];
+		core_stats->tx_bytes = stats[EF10_STAT_tx_unicast_bytes] +
+				       stats[EF10_STAT_tx_multicast_bytes] +
+				       stats[EF10_STAT_tx_broadcast_bytes];
+		core_stats->rx_dropped = stats[GENERIC_STAT_rx_nodesc_trunc] +
 					 stats[GENERIC_STAT_rx_noskb_drops];
-		core_stats->multicast = stats[EF10_STAT_port_rx_multicast];
-		core_stats->rx_length_errors =
-			stats[EF10_STAT_port_rx_gtjumbo] +
-			stats[EF10_STAT_port_rx_length_error];
-		core_stats->rx_crc_errors = stats[EF10_STAT_port_rx_bad];
-		core_stats->rx_frame_errors =
-			stats[EF10_STAT_port_rx_align_error];
-		core_stats->rx_fifo_errors = stats[EF10_STAT_port_rx_overflow];
-		core_stats->rx_errors = (core_stats->rx_length_errors +
-					 core_stats->rx_crc_errors +
-					 core_stats->rx_frame_errors);
+		core_stats->multicast = stats[EF10_STAT_rx_multicast];
+		core_stats->rx_crc_errors = stats[EF10_STAT_rx_bad];
+		core_stats->rx_fifo_errors = stats[EF10_STAT_rx_overflow];
+		core_stats->rx_errors = core_stats->rx_crc_errors;
+		core_stats->tx_errors = stats[EF10_STAT_tx_bad];
 	}
 
 	return stats_count;
@@ -1324,7 +1325,7 @@ static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
 
 	MCDI_SET_QWORD(inbuf, MAC_STATS_IN_DMA_ADDR, stats_buf.dma_addr);
 	MCDI_POPULATE_DWORD_1(inbuf, MAC_STATS_IN_CMD,
-			      MAC_STATS_IN_DMA, true);
+			      MAC_STATS_IN_DMA, 1);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
 
@@ -1336,8 +1337,10 @@ static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
 		goto out;
 
 	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
-	if (generation_end == EFX_MC_STATS_GENERATION_INVALID)
+	if (generation_end == EFX_MC_STATS_GENERATION_INVALID) {
+		WARN_ON_ONCE(1);
 		goto out;
+	}
 	rmb();
 	efx_nic_update_stats(efx_ef10_stat_desc, EF10_STAT_COUNT, mask,
 			     stats, stats_buf.addr, false);
