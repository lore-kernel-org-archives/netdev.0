From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/11] sfc: Add PTP counters to ethtool stats
Date: Mon, 16 Dec 2013 21:34:48 +0000
Message-ID: <1387229688.1799.53.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8669 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab3LPVev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:34:51 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were implemented by Andrew Jackson and Laurence Evans but not
previously included in-tree.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |   8 ++-
 drivers/net/ethernet/sfc/nic.h     |   2 +
 drivers/net/ethernet/sfc/ptp.c     | 126 ++++++++++++++++++++++++++++++++++---
 3 files changed, 127 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index bb2af8045281..f181522688b2 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -359,7 +359,8 @@ static int efx_ethtool_get_sset_count(struct net_device *net_dev,
 	switch (string_set) {
 	case ETH_SS_STATS:
 		return efx->type->describe_stats(efx, NULL) +
-			EFX_ETHTOOL_SW_STAT_COUNT;
+			EFX_ETHTOOL_SW_STAT_COUNT +
+			efx_ptp_describe_stats(efx, NULL);
 	case ETH_SS_TEST:
 		return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
 	default:
@@ -380,6 +381,8 @@ static void efx_ethtool_get_strings(struct net_device *net_dev,
 		for (i = 0; i < EFX_ETHTOOL_SW_STAT_COUNT; i++)
 			strlcpy(strings + i * ETH_GSTRING_LEN,
 				efx_sw_stat_desc[i].name, ETH_GSTRING_LEN);
+		strings += EFX_ETHTOOL_SW_STAT_COUNT * ETH_GSTRING_LEN;
+		efx_ptp_describe_stats(efx, strings);
 		break;
 	case ETH_SS_TEST:
 		efx_ethtool_fill_self_tests(efx, NULL, strings, NULL);
@@ -429,8 +432,11 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 			break;
 		}
 	}
+	data += EFX_ETHTOOL_SW_STAT_COUNT;
 
 	spin_unlock_bh(&efx->stats_lock);
+
+	efx_ptp_update_stats(efx, data);
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 170ac6ee3ab2..a001fae1a8d7 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -566,6 +566,8 @@ int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
 			unsigned int new_mode);
 int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
+size_t efx_ptp_describe_stats(struct efx_nic *efx, u8 *strings);
+size_t efx_ptp_update_stats(struct efx_nic *efx, u64 *stats);
 void efx_time_sync_event(struct efx_channel *channel, efx_qword_t *ev);
 void __efx_rx_skb_attach_timestamp(struct efx_channel *channel,
 				   struct sk_buff *skb);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 084e2d44790f..7aa070813960 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -255,6 +255,15 @@ struct efx_ptp_timeset {
  * @nic_ts_enabled: Flag indicating if NIC generated TS events are handled
  * @txbuf: Buffer for use when transmitting (PTP) packets to MC (avoids
  *         allocations in main data path).
+ * @good_syncs: Number of successful synchronisations.
+ * @fast_syncs: Number of synchronisations requiring short delay
+ * @bad_syncs: Number of failed synchronisations.
+ * @sync_timeouts: Number of synchronisation timeouts
+ * @no_time_syncs: Number of synchronisations with no good times.
+ * @invalid_sync_windows: Number of sync windows with bad durations.
+ * @undersize_sync_windows: Number of corrected sync windows that are too small
+ * @oversize_sync_windows: Number of corrected sync windows that are too large
+ * @rx_no_timestamp: Number of packets received without a timestamp.
  * @timeset: Last set of synchronisation statistics.
  */
 struct efx_ptp_data {
@@ -300,6 +309,16 @@ struct efx_ptp_data {
 	struct workqueue_struct *pps_workwq;
 	bool nic_ts_enabled;
 	MCDI_DECLARE_BUF(txbuf, MC_CMD_PTP_IN_TRANSMIT_LENMAX);
+
+	unsigned int good_syncs;
+	unsigned int fast_syncs;
+	unsigned int bad_syncs;
+	unsigned int sync_timeouts;
+	unsigned int no_time_syncs;
+	unsigned int invalid_sync_windows;
+	unsigned int undersize_sync_windows;
+	unsigned int oversize_sync_windows;
+	unsigned int rx_no_timestamp;
 	struct efx_ptp_timeset
 	timeset[MC_CMD_PTP_OUT_SYNCHRONIZE_TIMESET_MAXNUM];
 };
@@ -312,6 +331,78 @@ static int efx_phc_settime(struct ptp_clock_info *ptp,
 static int efx_phc_enable(struct ptp_clock_info *ptp,
 			  struct ptp_clock_request *request, int on);
 
+#define PTP_SW_STAT(ext_name, field_name)				\
+	{ #ext_name, 0, offsetof(struct efx_ptp_data, field_name) }
+#define PTP_MC_STAT(ext_name, mcdi_name)				\
+	{ #ext_name, 32, MC_CMD_PTP_OUT_STATUS_STATS_ ## mcdi_name ## _OFST }
+static const struct efx_hw_stat_desc efx_ptp_stat_desc[] = {
+	PTP_SW_STAT(ptp_good_syncs, good_syncs),
+	PTP_SW_STAT(ptp_fast_syncs, fast_syncs),
+	PTP_SW_STAT(ptp_bad_syncs, bad_syncs),
+	PTP_SW_STAT(ptp_sync_timeouts, sync_timeouts),
+	PTP_SW_STAT(ptp_no_time_syncs, no_time_syncs),
+	PTP_SW_STAT(ptp_invalid_sync_windows, invalid_sync_windows),
+	PTP_SW_STAT(ptp_undersize_sync_windows, undersize_sync_windows),
+	PTP_SW_STAT(ptp_oversize_sync_windows, oversize_sync_windows),
+	PTP_SW_STAT(ptp_rx_no_timestamp, rx_no_timestamp),
+	PTP_MC_STAT(ptp_tx_timestamp_packets, TX),
+	PTP_MC_STAT(ptp_rx_timestamp_packets, RX),
+	PTP_MC_STAT(ptp_timestamp_packets, TS),
+	PTP_MC_STAT(ptp_filter_matches, FM),
+	PTP_MC_STAT(ptp_non_filter_matches, NFM),
+};
+#define PTP_STAT_COUNT ARRAY_SIZE(efx_ptp_stat_desc)
+static const unsigned long efx_ptp_stat_mask[] = {
+	[0 ... BITS_TO_LONGS(PTP_STAT_COUNT) - 1] = ~0UL,
+};
+
+size_t efx_ptp_describe_stats(struct efx_nic *efx, u8 *strings)
+{
+	if (!efx->ptp_data)
+		return 0;
+
+	return efx_nic_describe_stats(efx_ptp_stat_desc, PTP_STAT_COUNT,
+				      efx_ptp_stat_mask, strings);
+}
+
+size_t efx_ptp_update_stats(struct efx_nic *efx, u64 *stats)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_STATUS_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_PTP_OUT_STATUS_LEN);
+	size_t i;
+	int rc;
+
+	if (!efx->ptp_data)
+		return 0;
+
+	/* Copy software statistics */
+	for (i = 0; i < PTP_STAT_COUNT; i++) {
+		if (efx_ptp_stat_desc[i].dma_width)
+			continue;
+		stats[i] = *(unsigned int *)((char *)efx->ptp_data +
+					     efx_ptp_stat_desc[i].offset);
+	}
+
+	/* Fetch MC statistics.  We *must* fill in all statistics or
+	 * risk leaking kernel memory to userland, so if the MCDI
+	 * request fails we pretend we got zeroes.
+	 */
+	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_STATUS);
+	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
+	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), NULL);
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev,
+			  "MC_CMD_PTP_OP_STATUS failed (%d)\n", rc);
+		memset(outbuf, 0, sizeof(outbuf));
+	}
+	efx_nic_update_stats(efx_ptp_stat_desc, PTP_STAT_COUNT,
+			     efx_ptp_stat_mask,
+			     stats, _MCDI_PTR(outbuf, 0), false);
+
+	return PTP_STAT_COUNT;
+}
+
 /* For Siena platforms NIC time is s and ns */
 static void efx_ptp_ns_to_s_ns(s64 ns, u32 *nic_major, u32 *nic_minor)
 {
@@ -633,7 +724,8 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 	/* Read the set of results and find the last good host-MC
 	 * synchronization result. The MC times when it finishes reading the
 	 * host time so the corrected window time should be fairly constant
-	 * for a given platform.
+	 * for a given platform. Increment stats for any results that appear
+	 * to be erroneous.
 	 */
 	for (i = 0; i < number_readings; i++) {
 		s32 window, corrected;
@@ -658,9 +750,13 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 		 * interrupt or other delay occurred between reading the system
 		 * time and writing it to MC memory.
 		 */
-		if (window >= SYNCHRONISATION_GRANULARITY_NS &&
-		    corrected < MAX_SYNCHRONISATION_NS &&
-		    corrected >= ptp->min_synchronisation_ns) {
+		if (window < SYNCHRONISATION_GRANULARITY_NS) {
+			++ptp->invalid_sync_windows;
+		} else if (corrected >= MAX_SYNCHRONISATION_NS) {
+			++ptp->undersize_sync_windows;
+		} else if (corrected < ptp->min_synchronisation_ns) {
+			++ptp->oversize_sync_windows;
+		} else {
 			ngood++;
 			last_good = i;
 		}
@@ -741,6 +837,11 @@ static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 		loops++;
 	}
 
+	if (loops <= 1)
+		++ptp->fast_syncs;
+	if (!time_before(jiffies, timeout))
+		++ptp->sync_timeouts;
+
 	if (ACCESS_ONCE(*start))
 		efx_ptp_send_times(efx, &last_time);
 
@@ -749,9 +850,20 @@ static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 				 MC_CMD_PTP_IN_SYNCHRONIZE_LEN,
 				 synch_buf, sizeof(synch_buf),
 				 &response_length);
-	if (rc == 0)
+	if (rc == 0) {
 		rc = efx_ptp_process_times(efx, synch_buf, response_length,
 					   &last_time);
+		if (rc == 0)
+			++ptp->good_syncs;
+		else
+			++ptp->no_time_syncs;
+	}
+
+	/* Increment the bad syncs counter if the synchronize fails, whatever
+	 * the reason.
+	 */
+	if (rc != 0)
+		++ptp->bad_syncs;
 
 	return rc;
 }
@@ -907,9 +1019,7 @@ static void efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 			__skb_queue_tail(q, skb);
 		} else if (time_after(jiffies, match->expiry)) {
 			match->state = PTP_PACKET_STATE_TIMED_OUT;
-			if (net_ratelimit())
-				netif_warn(efx, rx_err, efx->net_dev,
-					   "PTP packet - no timestamp seen\n");
+			++ptp->rx_no_timestamp;
 			__skb_queue_tail(q, skb);
 		} else {
 			/* Replace unprocessed entry and stop */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
