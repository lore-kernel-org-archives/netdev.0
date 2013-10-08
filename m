From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 3/6] sfc: Refactor EF10 stat mask code to allow for more
 conditional stats
Date: Tue, 8 Oct 2013 18:44:07 +0100
Message-ID: <1381254247.1530.13.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56446 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775Ab3JHRoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:44:11 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Previously, efx_ef10_stat_mask returned a static const unsigned long[], which
meant that each possible mask had to be declared statically with
STAT_MASK_BITMAP.  Since adding a condition would double the size of the
decision tree, we now create the bitmask dynamically.

To do this, we have two functions efx_ef10_raw_stat_mask, which returns a u64,
and efx_ef10_get_stat_mask, which fills in an unsigned long * argument.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 49 +++++++++++++++++++++++------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a4fbb38..c00a5d6 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -498,44 +498,49 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
 #define HUNT_40G_EXTRA_STAT_MASK ((1ULL << EF10_STAT_rx_align_error) |	\
 				  (1ULL << EF10_STAT_rx_length_error))
 
-#if BITS_PER_LONG == 64
-#define STAT_MASK_BITMAP(bits) (bits)
-#else
-#define STAT_MASK_BITMAP(bits) (bits) & 0xffffffff, (bits) >> 32
-#endif
-
-static const unsigned long *efx_ef10_stat_mask(struct efx_nic *efx)
+static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 {
-	static const unsigned long hunt_40g_stat_mask[] = {
-		STAT_MASK_BITMAP(HUNT_COMMON_STAT_MASK |
-				 HUNT_40G_EXTRA_STAT_MASK)
-	};
-	static const unsigned long hunt_10g_only_stat_mask[] = {
-		STAT_MASK_BITMAP(HUNT_COMMON_STAT_MASK |
-				 HUNT_10G_ONLY_STAT_MASK)
-	};
+	u64 raw_mask = HUNT_COMMON_STAT_MASK;
 	u32 port_caps = efx_mcdi_phy_get_caps(efx);
 
 	if (port_caps & (1 << MC_CMD_PHY_CAP_40000FDX_LBN))
-		return hunt_40g_stat_mask;
+		raw_mask |= HUNT_40G_EXTRA_STAT_MASK;
 	else
-		return hunt_10g_only_stat_mask;
+		raw_mask |= HUNT_10G_ONLY_STAT_MASK;
+	return raw_mask;
+}
+
+static void efx_ef10_get_stat_mask(struct efx_nic *efx, unsigned long *mask)
+{
+	u64 raw_mask = efx_ef10_raw_stat_mask(efx);
+
+#if BITS_PER_LONG == 64
+	mask[0] = raw_mask;
+#else
+	mask[0] = raw_mask & 0xffffffff;
+	mask[1] = raw_mask >> 32;
+#endif
 }
 
 static size_t efx_ef10_describe_stats(struct efx_nic *efx, u8 *names)
 {
+	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
+
+	efx_ef10_get_stat_mask(efx, mask);
 	return efx_nic_describe_stats(efx_ef10_stat_desc, EF10_STAT_COUNT,
-				      efx_ef10_stat_mask(efx), names);
+				      mask, names);
 }
 
 static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	const unsigned long *stats_mask = efx_ef10_stat_mask(efx);
+	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
 	__le64 generation_start, generation_end;
 	u64 *stats = nic_data->stats;
 	__le64 *dma_stats;
 
+	efx_ef10_get_stat_mask(efx, mask);
+
 	dma_stats = efx->stats_buffer.addr;
 	nic_data = efx->nic_data;
 
@@ -543,7 +548,7 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 	if (generation_end == EFX_MC_STATS_GENERATION_INVALID)
 		return 0;
 	rmb();
-	efx_nic_update_stats(efx_ef10_stat_desc, EF10_STAT_COUNT, stats_mask,
+	efx_nic_update_stats(efx_ef10_stat_desc, EF10_STAT_COUNT, mask,
 			     stats, efx->stats_buffer.addr, false);
 	rmb();
 	generation_start = dma_stats[MC_CMD_MAC_GENERATION_START];
@@ -564,12 +569,14 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 static size_t efx_ef10_update_stats(struct efx_nic *efx, u64 *full_stats,
 				    struct rtnl_link_stats64 *core_stats)
 {
-	const unsigned long *mask = efx_ef10_stat_mask(efx);
+	DECLARE_BITMAP(mask, EF10_STAT_COUNT);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	u64 *stats = nic_data->stats;
 	size_t stats_count = 0, index;
 	int retry;
 
+	efx_ef10_get_stat_mask(efx, mask);
+
 	/* If we're unlucky enough to read statistics during the DMA, wait
 	 * up to 10ms for it to finish (typically takes <500us)
 	 */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
