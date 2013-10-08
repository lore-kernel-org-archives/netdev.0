From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 5/6] sfc: Add PM and RXDP drop counters to ethtool stats
Date: Tue, 8 Oct 2013 18:44:58 +0100
Message-ID: <1381254298.1530.15.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56467 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab3JHRpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:45:02 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Recognise the new Packet Memory and RX Data Path counters.

The following counters are added:
rx_pm_{trunc,discard}_bb_overflow - burst buffer overflowed.  This should not
 occur if BB correctly configured.
rx_pm_{trunc,discard}_vfifo_full - not enough space in packet memory.  May
 indicate RX performance problems.
rx_pm_{trunc,discard}_qbb - dropped by 802.1Qbb early discard mechanism.
 Since Qbb is not supported at present, this should not occur.
rx_pm_discard_mapping - 802.1p priority configured to be dropped.  This should
 not occur in normal operation.
rx_dp_q_disabled_packets - packet was to be delivered to a queue but queue is
 disabled.  May indicate misconfiguration by the driver.
rx_dp_di_dropped_packets - parser-dispatcher indicated that a packet should be
 dropped.
rx_dp_streaming_packets - packet was sent to the RXDP streaming bus, ie. a
 filter directed the packet to the MCPU.
rx_dp_emerg_{fetch,wait} - RX datapath had to wait for descriptors to be
 loaded.  Indicates performance problems but not drops.

These are only provided if the MC firmware has the
PM_AND_RXDP_COUNTERS capability.  Otherwise, mask them out.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 35 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/nic.h  | 12 ++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index c00a5d6..21f9ad6 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -444,6 +444,18 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 	EF10_DMA_STAT(rx_align_error, RX_ALIGN_ERROR_PKTS),
 	EF10_DMA_STAT(rx_length_error, RX_LENGTH_ERROR_PKTS),
 	EF10_DMA_STAT(rx_nodesc_drops, RX_NODESC_DROPS),
+	EF10_DMA_STAT(rx_pm_trunc_bb_overflow, PM_TRUNC_BB_OVERFLOW),
+	EF10_DMA_STAT(rx_pm_discard_bb_overflow, PM_DISCARD_BB_OVERFLOW),
+	EF10_DMA_STAT(rx_pm_trunc_vfifo_full, PM_TRUNC_VFIFO_FULL),
+	EF10_DMA_STAT(rx_pm_discard_vfifo_full, PM_DISCARD_VFIFO_FULL),
+	EF10_DMA_STAT(rx_pm_trunc_qbb, PM_TRUNC_QBB),
+	EF10_DMA_STAT(rx_pm_discard_qbb, PM_DISCARD_QBB),
+	EF10_DMA_STAT(rx_pm_discard_mapping, PM_DISCARD_MAPPING),
+	EF10_DMA_STAT(rx_dp_q_disabled_packets, RXDP_Q_DISABLED_PKTS),
+	EF10_DMA_STAT(rx_dp_di_dropped_packets, RXDP_DI_DROPPED_PKTS),
+	EF10_DMA_STAT(rx_dp_streaming_packets, RXDP_STREAMING_PKTS),
+	EF10_DMA_STAT(rx_dp_emerg_fetch, RXDP_EMERGENCY_FETCH_CONDITIONS),
+	EF10_DMA_STAT(rx_dp_emerg_wait, RXDP_EMERGENCY_WAIT_CONDITIONS),
 };
 
 #define HUNT_COMMON_STAT_MASK ((1ULL << EF10_STAT_tx_bytes) |		\
@@ -498,15 +510,38 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 #define HUNT_40G_EXTRA_STAT_MASK ((1ULL << EF10_STAT_rx_align_error) |	\
 				  (1ULL << EF10_STAT_rx_length_error))
 
+/* These statistics are only provided if the firmware supports the
+ * capability PM_AND_RXDP_COUNTERS.
+ */
+#define HUNT_PM_AND_RXDP_STAT_MASK (					\
+	(1ULL << EF10_STAT_rx_pm_trunc_bb_overflow) |			\
+	(1ULL << EF10_STAT_rx_pm_discard_bb_overflow) |			\
+	(1ULL << EF10_STAT_rx_pm_trunc_vfifo_full) |			\
+	(1ULL << EF10_STAT_rx_pm_discard_vfifo_full) |			\
+	(1ULL << EF10_STAT_rx_pm_trunc_qbb) |				\
+	(1ULL << EF10_STAT_rx_pm_discard_qbb) |				\
+	(1ULL << EF10_STAT_rx_pm_discard_mapping) |			\
+	(1ULL << EF10_STAT_rx_dp_q_disabled_packets) |			\
+	(1ULL << EF10_STAT_rx_dp_di_dropped_packets) |			\
+	(1ULL << EF10_STAT_rx_dp_streaming_packets) |			\
+	(1ULL << EF10_STAT_rx_dp_emerg_fetch) |				\
+	(1ULL << EF10_STAT_rx_dp_emerg_wait))
+
 static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 {
 	u64 raw_mask = HUNT_COMMON_STAT_MASK;
 	u32 port_caps = efx_mcdi_phy_get_caps(efx);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
 	if (port_caps & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
 		raw_mask |= HUNT_40G_EXTRA_STAT_MASK;
 	else
 		raw_mask |= HUNT_10G_ONLY_STAT_MASK;
+
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_LBN))
+		raw_mask |= HUNT_PM_AND_RXDP_STAT_MASK;
+
 	return raw_mask;
 }
 
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index fda29d3..890bbbe 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -386,6 +386,18 @@ enum {
 	EF10_STAT_rx_align_error,
 	EF10_STAT_rx_length_error,
 	EF10_STAT_rx_nodesc_drops,
+	EF10_STAT_rx_pm_trunc_bb_overflow,
+	EF10_STAT_rx_pm_discard_bb_overflow,
+	EF10_STAT_rx_pm_trunc_vfifo_full,
+	EF10_STAT_rx_pm_discard_vfifo_full,
+	EF10_STAT_rx_pm_trunc_qbb,
+	EF10_STAT_rx_pm_discard_qbb,
+	EF10_STAT_rx_pm_discard_mapping,
+	EF10_STAT_rx_dp_q_disabled_packets,
+	EF10_STAT_rx_dp_di_dropped_packets,
+	EF10_STAT_rx_dp_streaming_packets,
+	EF10_STAT_rx_dp_emerg_fetch,
+	EF10_STAT_rx_dp_emerg_wait,
 	EF10_STAT_COUNT
 };
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
