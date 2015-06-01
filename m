From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 07/14] sfc: DMA the VF stats only when requested
Date: Mon, 1 Jun 2015 14:02:02 +0100
Message-ID: <556C57CA.60507@solarflare.com>
References: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:52885 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752590AbbFANCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:02:08 -0400
In-Reply-To: <556C5704.4060901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Firmware does not support a periodic DMA of vadaptor-stats
on VFs, so only update the stats buffer when stats are
requested (when running "ethtool -S" or an ip/ifconfig
command that reports stats).

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 149 +++++++++++++++++++++++++----------
 drivers/net/ethernet/sfc/mcdi_pcol.h |   4 +-
 2 files changed, 112 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 554aff4..323ca47 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1189,7 +1189,50 @@ static size_t efx_ef10_describe_stats(struct efx_nic *efx, u8 *names)
 				      mask, names);
 }
 
-static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
+static size_t efx_ef10_update_stats_common(struct efx_nic *efx, u64 *full_stats,
+					   struct rtnl_link_stats64 *core_stats)
+{
+	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	u64 *stats = nic_data->stats;
+	size_t stats_count = 0, index;
+
+	efx_ef10_get_stat_mask(efx, mask);
+
+	if (full_stats) {
+		for_each_set_bit(index, mask, EF10_STAT_COUNT) {
+			if (efx_ef10_stat_desc[index].name) {
+				*full_stats++ = stats[index];
+				++stats_count;
+			}
+		}
+	}
+
+	if (core_stats) {
+		core_stats->rx_packets = stats[EF10_STAT_port_rx_packets];
+		core_stats->tx_packets = stats[EF10_STAT_port_tx_packets];
+		core_stats->rx_bytes = stats[EF10_STAT_port_rx_bytes];
+		core_stats->tx_bytes = stats[EF10_STAT_port_tx_bytes];
+		core_stats->rx_dropped = stats[EF10_STAT_port_rx_nodesc_drops] +
+					 stats[GENERIC_STAT_rx_nodesc_trunc] +
+					 stats[GENERIC_STAT_rx_noskb_drops];
+		core_stats->multicast = stats[EF10_STAT_port_rx_multicast];
+		core_stats->rx_length_errors =
+			stats[EF10_STAT_port_rx_gtjumbo] +
+			stats[EF10_STAT_port_rx_length_error];
+		core_stats->rx_crc_errors = stats[EF10_STAT_port_rx_bad];
+		core_stats->rx_frame_errors =
+			stats[EF10_STAT_port_rx_align_error];
+		core_stats->rx_fifo_errors = stats[EF10_STAT_port_rx_overflow];
+		core_stats->rx_errors = (core_stats->rx_length_errors +
+					 core_stats->rx_crc_errors +
+					 core_stats->rx_frame_errors);
+	}
+
+	return stats_count;
+}
+
+static int efx_ef10_try_update_nic_stats_pf(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
@@ -1226,57 +1269,83 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 }
 
 
-static size_t efx_ef10_update_stats(struct efx_nic *efx, u64 *full_stats,
-				    struct rtnl_link_stats64 *core_stats)
+static size_t efx_ef10_update_stats_pf(struct efx_nic *efx, u64 *full_stats,
+				       struct rtnl_link_stats64 *core_stats)
 {
-	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	u64 *stats = nic_data->stats;
-	size_t stats_count = 0, index;
 	int retry;
 
-	efx_ef10_get_stat_mask(efx, mask);
-
 	/* If we're unlucky enough to read statistics during the DMA, wait
 	 * up to 10ms for it to finish (typically takes <500us)
 	 */
 	for (retry = 0; retry < 100; ++retry) {
-		if (efx_ef10_try_update_nic_stats(efx) == 0)
+		if (efx_ef10_try_update_nic_stats_pf(efx) == 0)
 			break;
 		udelay(100);
 	}
 
-	if (full_stats) {
-		for_each_set_bit(index, mask, EF10_STAT_COUNT) {
-			if (efx_ef10_stat_desc[index].name) {
-				*full_stats++ = stats[index];
-				++stats_count;
-			}
-		}
-	}
+	return efx_ef10_update_stats_common(efx, full_stats, core_stats);
+}
 
-	if (core_stats) {
-		core_stats->rx_packets = stats[EF10_STAT_port_rx_packets];
-		core_stats->tx_packets = stats[EF10_STAT_port_tx_packets];
-		core_stats->rx_bytes = stats[EF10_STAT_port_rx_bytes];
-		core_stats->tx_bytes = stats[EF10_STAT_port_tx_bytes];
-		core_stats->rx_dropped = stats[EF10_STAT_port_rx_nodesc_drops] +
-					 stats[GENERIC_STAT_rx_nodesc_trunc] +
-					 stats[GENERIC_STAT_rx_noskb_drops];
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
+static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
+	__le64 generation_start, generation_end;
+	u64 *stats = nic_data->stats;
+	u32 dma_len = MC_CMD_MAC_NSTATS * sizeof(u64);
+	struct efx_buffer stats_buf;
+	__le64 *dma_stats;
+	int rc;
+
+	efx_ef10_get_stat_mask(efx, mask);
+
+	rc = efx_nic_alloc_buffer(efx, &stats_buf, dma_len, GFP_ATOMIC);
+	if (rc)
+		return rc;
+
+	dma_stats = stats_buf.addr;
+	dma_stats[MC_CMD_MAC_GENERATION_END] = EFX_MC_STATS_GENERATION_INVALID;
+
+	MCDI_SET_QWORD(inbuf, MAC_STATS_IN_DMA_ADDR, stats_buf.dma_addr);
+	MCDI_POPULATE_DWORD_1(inbuf, MAC_STATS_IN_CMD,
+			      MAC_STATS_IN_DMA, true);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
+
+	spin_unlock_bh(&efx->stats_lock);
+	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf), NULL,
+			  0, NULL);
+	spin_lock_bh(&efx->stats_lock);
+	if (rc)
+		goto out;
+
+	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
+	if (generation_end == EFX_MC_STATS_GENERATION_INVALID)
+		goto out;
+	rmb();
+	efx_nic_update_stats(efx_ef10_stat_desc, EF10_STAT_COUNT, mask,
+			     stats, stats_buf.addr, false);
+	rmb();
+	generation_start = dma_stats[MC_CMD_MAC_GENERATION_START];
+	if (generation_end != generation_start) {
+		rc = -EAGAIN;
+		goto out;
 	}
 
-	return stats_count;
+	efx_update_sw_stats(efx, stats);
+out:
+	efx_nic_free_buffer(efx, &stats_buf);
+	return rc;
+}
+
+static size_t efx_ef10_update_stats_vf(struct efx_nic *efx, u64 *full_stats,
+				       struct rtnl_link_stats64 *core_stats)
+{
+	if (efx_ef10_try_update_nic_stats_vf(efx))
+		return 0;
+
+	return efx_ef10_update_stats_common(efx, full_stats, core_stats);
 }
 
 static void efx_ef10_push_irq_moderation(struct efx_channel *channel)
@@ -4121,7 +4190,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.prepare_flr = efx_ef10_prepare_flr,
 	.finish_flr = efx_port_dummy_op_void,
 	.describe_stats = efx_ef10_describe_stats,
-	.update_stats = efx_ef10_update_stats,
+	.update_stats = efx_ef10_update_stats_vf,
 	.start_stats = efx_port_dummy_op_void,
 	.pull_stats = efx_port_dummy_op_void,
 	.stop_stats = efx_port_dummy_op_void,
@@ -4223,7 +4292,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.prepare_flr = efx_ef10_prepare_flr,
 	.finish_flr = efx_port_dummy_op_void,
 	.describe_stats = efx_ef10_describe_stats,
-	.update_stats = efx_ef10_update_stats,
+	.update_stats = efx_ef10_update_stats_pf,
 	.start_stats = efx_mcdi_mac_start_stats,
 	.pull_stats = efx_mcdi_mac_pull_stats,
 	.stop_stats = efx_mcdi_mac_stop_stats,
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 0e497b3..181978d 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -2755,7 +2755,7 @@
 #define MC_CMD_0x2e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_MAC_STATS_IN msgrequest */
-#define    MC_CMD_MAC_STATS_IN_LEN 16
+#define    MC_CMD_MAC_STATS_IN_LEN 20
 /* ??? */
 #define       MC_CMD_MAC_STATS_IN_DMA_ADDR_OFST 0
 #define       MC_CMD_MAC_STATS_IN_DMA_ADDR_LEN 8
@@ -2777,6 +2777,8 @@
 #define        MC_CMD_MAC_STATS_IN_PERIOD_MS_LBN 16
 #define        MC_CMD_MAC_STATS_IN_PERIOD_MS_WIDTH 16
 #define       MC_CMD_MAC_STATS_IN_DMA_LEN_OFST 12
+/* port id so vadapter stats can be provided */
+#define       MC_CMD_MAC_STATS_IN_PORT_ID_OFST 16
 
 /* MC_CMD_MAC_STATS_OUT_DMA msgresponse */
 #define    MC_CMD_MAC_STATS_OUT_DMA_LEN 0
