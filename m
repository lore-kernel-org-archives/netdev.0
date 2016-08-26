From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/3] sfc: include size-binned TX stats on sfn8542q
Date: Fri, 26 Aug 2016 15:12:41 +0100
Message-ID: <330c12fc-6c74-fbb8-3fef-fb81830c13ce@solarflare.com>
References: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:18884 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751691AbcHZOT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:19:58 -0400
In-Reply-To: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX size bins were not supported on the 7000's 40G MAC, but the 8000 series
does support them and the MCPU advertises that via a new capability bit.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 2a70b1a..d039f29 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1533,9 +1533,10 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 			       (1ULL << GENERIC_STAT_rx_nodesc_trunc) |	\
 			       (1ULL << GENERIC_STAT_rx_noskb_drops))
 
-/* These statistics are only provided by the 10G MAC.  For a 10G/40G
- * switchable port we do not expose these because they might not
- * include all the packets they should.
+/* On 7000 series NICs, these statistics are only provided by the 10G MAC.
+ * For a 10G/40G switchable port we do not expose these because they might
+ * not include all the packets they should.
+ * On 8000 series NICs these statistics are always provided.
  */
 #define HUNT_10G_ONLY_STAT_MASK ((1ULL << EF10_STAT_port_tx_control) |	\
 				 (1ULL << EF10_STAT_port_tx_lt64) |	\
@@ -1581,10 +1582,15 @@ static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 	      1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL))
 		return 0;
 
-	if (port_caps & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
+	if (port_caps & (1 << MC_CMD_PHY_CAP_40000FDX_LBN)) {
 		raw_mask |= HUNT_40G_EXTRA_STAT_MASK;
-	else
+		/* 8000 series have everything even at 40G */
+		if (nic_data->datapath_caps2 &
+		    (1 << MC_CMD_GET_CAPABILITIES_V2_OUT_MAC_STATS_40G_TX_SIZE_BINS_LBN))
+			raw_mask |= HUNT_10G_ONLY_STAT_MASK;
+	} else {
 		raw_mask |= HUNT_10G_ONLY_STAT_MASK;
+	}
 
 	if (nic_data->datapath_caps &
 	    (1 << MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_LBN))
