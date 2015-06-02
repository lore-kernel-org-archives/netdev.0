From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 11/15] sfc: suppress vadaptor stats when EVB is
 not present
Date: Tue, 2 Jun 2015 11:40:05 +0100
Message-ID: <556D8805.1060002@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:56304 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755651AbbFBKkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:40:11 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The raw_mask array is not initialised, so it needs to be
explicitly set to zero in the 'else' branch.

If the EVB capability is not present, a port cannot have multiple
functions so the per-port MAC stats are correct and should match
the corresponding vadaptor stats, so this redundancy can be
removed from the ethtool stats output.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 12 +++++++++---
 drivers/net/ethernet/sfc/mcdi_pcol.h |  2 ++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a79a24f..03f464f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1162,13 +1162,19 @@ static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 
 static void efx_ef10_get_stat_mask(struct efx_nic *efx, unsigned long *mask)
 {
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	u64 raw_mask[2];
 
 	raw_mask[0] = efx_ef10_raw_stat_mask(efx);
 
-	/* All functions see the vadaptor stats */
-	raw_mask[0] |= ~((1ULL << EF10_STAT_rx_unicast) - 1);
-	raw_mask[1] = (1ULL << (EF10_STAT_COUNT - 63)) - 1;
+	/* Only show vadaptor stats when EVB capability is present */
+	if (nic_data->datapath_caps &
+	    (1 << MC_CMD_GET_CAPABILITIES_OUT_EVB_LBN)) {
+		raw_mask[0] |= ~((1ULL << EF10_STAT_rx_unicast) - 1);
+		raw_mask[1] = (1ULL << (EF10_STAT_COUNT - 63)) - 1;
+	} else {
+		raw_mask[1] = 0;
+	}
 
 #if BITS_PER_LONG == 64
 	mask[0] = raw_mask[0];
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 181978d..45fca9f 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -5600,6 +5600,8 @@
 #define        MC_CMD_GET_CAPABILITIES_OUT_MCAST_FILTER_CHAINING_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_LBN 27
 #define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_EVB_LBN 30
+#define        MC_CMD_GET_CAPABILITIES_OUT_EVB_WIDTH 1
 /* RxDPCPU firmware id. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_OFST 4
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_LEN 2
