From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 07/15] sfc: display vadaptor statistics for all
 interfaces
Date: Tue, 2 Jun 2015 11:39:06 +0100
Message-ID: <556D87CA.2020503@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:32200 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758541AbbFBKjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:39:16 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

All interfaces will display vadaptor statistics, so set all the
relevant bits in the stats bitmask. Only functions with the
LINKCTRL flag will see other stats, including (per-port) MAC stats.

The vadaptor stats are from rx_unicast to tx_overflow.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 39 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/mcdi_pcol.h | 20 ++++++++++++++++++
 drivers/net/ethernet/sfc/nic.h       | 18 +++++++++++++++++
 3 files changed, 73 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index f44a56a..3da554f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1046,6 +1046,24 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 	EF10_DMA_STAT(port_rx_dp_streaming_packets, RXDP_STREAMING_PKTS),
 	EF10_DMA_STAT(port_rx_dp_hlb_fetch, RXDP_HLB_FETCH_CONDITIONS),
 	EF10_DMA_STAT(port_rx_dp_hlb_wait, RXDP_HLB_WAIT_CONDITIONS),
+	EF10_DMA_STAT(rx_unicast, VADAPTER_RX_UNICAST_PACKETS),
+	EF10_DMA_STAT(rx_unicast_bytes, VADAPTER_RX_UNICAST_BYTES),
+	EF10_DMA_STAT(rx_multicast, VADAPTER_RX_MULTICAST_PACKETS),
+	EF10_DMA_STAT(rx_multicast_bytes, VADAPTER_RX_MULTICAST_BYTES),
+	EF10_DMA_STAT(rx_broadcast, VADAPTER_RX_BROADCAST_PACKETS),
+	EF10_DMA_STAT(rx_broadcast_bytes, VADAPTER_RX_BROADCAST_BYTES),
+	EF10_DMA_STAT(rx_bad, VADAPTER_RX_BAD_PACKETS),
+	EF10_DMA_STAT(rx_bad_bytes, VADAPTER_RX_BAD_BYTES),
+	EF10_DMA_STAT(rx_overflow, VADAPTER_RX_OVERFLOW),
+	EF10_DMA_STAT(tx_unicast, VADAPTER_TX_UNICAST_PACKETS),
+	EF10_DMA_STAT(tx_unicast_bytes, VADAPTER_TX_UNICAST_BYTES),
+	EF10_DMA_STAT(tx_multicast, VADAPTER_TX_MULTICAST_PACKETS),
+	EF10_DMA_STAT(tx_multicast_bytes, VADAPTER_TX_MULTICAST_BYTES),
+	EF10_DMA_STAT(tx_broadcast, VADAPTER_TX_BROADCAST_PACKETS),
+	EF10_DMA_STAT(tx_broadcast_bytes, VADAPTER_TX_BROADCAST_BYTES),
+	EF10_DMA_STAT(tx_bad, VADAPTER_TX_BAD_PACKETS),
+	EF10_DMA_STAT(tx_bad_bytes, VADAPTER_TX_BAD_BYTES),
+	EF10_DMA_STAT(tx_overflow, VADAPTER_TX_OVERFLOW),
 };
 
 #define HUNT_COMMON_STAT_MASK ((1ULL << EF10_STAT_port_tx_bytes) |	\
@@ -1126,6 +1144,10 @@ static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 	u32 port_caps = efx_mcdi_phy_get_caps(efx);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
+	if (!(efx->mcdi->fn_flags &
+	      1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL))
+		return 0;
+
 	if (port_caps & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
 		raw_mask |= HUNT_40G_EXTRA_STAT_MASK;
 	else
@@ -1140,13 +1162,22 @@ static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 
 static void efx_ef10_get_stat_mask(struct efx_nic *efx, unsigned long *mask)
 {
-	u64 raw_mask = efx_ef10_raw_stat_mask(efx);
+	u64 raw_mask[2];
+
+	raw_mask[0] = efx_ef10_raw_stat_mask(efx);
+
+	/* All functions see the vadaptor stats */
+	raw_mask[0] |= ~((1ULL << EF10_STAT_rx_unicast) - 1);
+	raw_mask[1] = (1ULL << (EF10_STAT_COUNT - 63)) - 1;
 
 #if BITS_PER_LONG == 64
-	mask[0] = raw_mask;
+	mask[0] = raw_mask[0];
+	mask[1] = raw_mask[1];
 #else
-	mask[0] = raw_mask & 0xffffffff;
-	mask[1] = raw_mask >> 32;
+	mask[0] = raw_mask[0] & 0xffffffff;
+	mask[1] = raw_mask[0] >> 32;
+	mask[2] = raw_mask[1] & 0xffffffff;
+	mask[3] = raw_mask[1] >> 32;
 #endif
 }
 
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 1e11bb8..0e497b3 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -2896,6 +2896,26 @@
  * descriptor fetch. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
  */
 #define          MC_CMD_MAC_RXDP_HLB_WAIT_CONDITIONS  0x48
+#define          MC_CMD_MAC_VADAPTER_RX_DMABUF_START  0x4c /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_UNICAST_PACKETS  0x4c /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_UNICAST_BYTES  0x4d /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_MULTICAST_PACKETS  0x4e /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_MULTICAST_BYTES  0x4f /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_BROADCAST_PACKETS  0x50 /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_BROADCAST_BYTES  0x51 /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_BAD_PACKETS  0x52 /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_BAD_BYTES  0x53 /* enum */
+#define          MC_CMD_MAC_VADAPTER_RX_OVERFLOW  0x54 /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_DMABUF_START  0x57 /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_UNICAST_PACKETS  0x57 /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_UNICAST_BYTES  0x58 /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_MULTICAST_PACKETS  0x59 /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_MULTICAST_BYTES  0x5a /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_BROADCAST_PACKETS  0x5b /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_BROADCAST_BYTES  0x5c /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_BAD_PACKETS  0x5d /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_BAD_BYTES  0x5e /* enum */
+#define          MC_CMD_MAC_VADAPTER_TX_OVERFLOW  0x5f /* enum */
 /* enum: Start of GMAC stats buffer space, for Siena only. */
 #define          MC_CMD_GMAC_DMABUF_START  0x40
 /* enum: End of GMAC stats buffer space, for Siena only. */
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 8b69a31..31ff908 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -460,6 +460,24 @@ enum {
 	EF10_STAT_port_rx_dp_streaming_packets,
 	EF10_STAT_port_rx_dp_hlb_fetch,
 	EF10_STAT_port_rx_dp_hlb_wait,
+	EF10_STAT_rx_unicast,
+	EF10_STAT_rx_unicast_bytes,
+	EF10_STAT_rx_multicast,
+	EF10_STAT_rx_multicast_bytes,
+	EF10_STAT_rx_broadcast,
+	EF10_STAT_rx_broadcast_bytes,
+	EF10_STAT_rx_bad,
+	EF10_STAT_rx_bad_bytes,
+	EF10_STAT_rx_overflow,
+	EF10_STAT_tx_unicast,
+	EF10_STAT_tx_unicast_bytes,
+	EF10_STAT_tx_multicast,
+	EF10_STAT_tx_multicast_bytes,
+	EF10_STAT_tx_broadcast,
+	EF10_STAT_tx_broadcast_bytes,
+	EF10_STAT_tx_bad,
+	EF10_STAT_tx_bad_bytes,
+	EF10_STAT_tx_overflow,
 	EF10_STAT_COUNT
 };
 
