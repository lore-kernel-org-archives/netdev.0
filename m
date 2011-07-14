From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/7] sfc: Fix Siena mac statistics on big
 endian platforms
Date: Thu, 14 Jul 2011 02:17:23 +0100
Message-ID: <1310606243.2756.27.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11260 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab1GNBR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:17:26 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

[bwh: Use __force in the one place it's needed]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/siena.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 442897b..5735e84 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -420,14 +420,13 @@ static void siena_remove_nic(struct efx_nic *efx)
 	efx->nic_data = NULL;
 }
 
-#define STATS_GENERATION_INVALID ((u64)(-1))
+#define STATS_GENERATION_INVALID ((__force __le64)(-1))
 
 static int siena_try_update_nic_stats(struct efx_nic *efx)
 {
-	u64 *dma_stats;
+	__le64 *dma_stats;
 	struct efx_mac_stats *mac_stats;
-	u64 generation_start;
-	u64 generation_end;
+	__le64 generation_start, generation_end;
 
 	mac_stats = &efx->mac_stats;
 	dma_stats = efx->stats_buffer.addr;
@@ -438,7 +437,7 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	rmb();
 
 #define MAC_STAT(M, D) \
-	mac_stats->M = dma_stats[MC_CMD_MAC_ ## D]
+	mac_stats->M = le64_to_cpu(dma_stats[MC_CMD_MAC_ ## D])
 
 	MAC_STAT(tx_bytes, TX_BYTES);
 	MAC_STAT(tx_bad_bytes, TX_BAD_BYTES);
@@ -508,7 +507,8 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	MAC_STAT(rx_internal_error, RX_INTERNAL_ERROR_PKTS);
 	mac_stats->rx_good_lt64 = 0;
 
-	efx->n_rx_nodesc_drop_cnt = dma_stats[MC_CMD_MAC_RX_NODESC_DROPS];
+	efx->n_rx_nodesc_drop_cnt =
+		le64_to_cpu(dma_stats[MC_CMD_MAC_RX_NODESC_DROPS]);
 
 #undef MAC_STAT
 
@@ -537,7 +537,7 @@ static void siena_update_nic_stats(struct efx_nic *efx)
 
 static void siena_start_nic_stats(struct efx_nic *efx)
 {
-	u64 *dma_stats = (u64 *)efx->stats_buffer.addr;
+	__le64 *dma_stats = efx->stats_buffer.addr;
 
 	dma_stats[MC_CMD_MAC_GENERATION_END] = STATS_GENERATION_INVALID;
 
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

