From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/16] sfc: Remove more left-overs from Falcon GMAC
 support
Date: Wed, 28 Aug 2013 16:17:51 +0100
Message-ID: <1377703071.2264.25.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17149 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab3H1PRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:17:54 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only ever used the XMAC (10G link speed) in production.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |  2 --
 drivers/net/ethernet/sfc/falcon.c  | 17 ++++++-----------
 drivers/net/ethernet/sfc/nic.h     |  5 -----
 3 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 58ae28b..55c3826 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -205,8 +205,6 @@ static int efx_ethtool_get_settings(struct net_device *net_dev,
 	efx->phy_op->get_settings(efx, ecmd);
 	mutex_unlock(&efx->mac_lock);
 
-	/* GMAC does not support 1000Mbps HD */
-	ecmd->supported &= ~SUPPORTED_1000baseT_Half;
 	/* Both MACs support pause frames (bidirectional and respond-only) */
 	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 3c99b6c..76a9e0d 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -131,8 +131,8 @@
 #define XgDmaDone_offset 0xD4
 #define XgDmaDone_WIDTH 32
 
-#define FALCON_STATS_NOT_DONE 0x00000000
-#define FALCON_STATS_DONE 0xffffffff
+#define FALCON_XMAC_STATS_DMA_FLAG(efx)				\
+	(*(u32 *)((efx)->stats_buffer.addr + XgDmaDone_offset))
 
 #define FALCON_STAT_OFFSET(falcon_stat) EFX_VAL(falcon_stat, offset)
 #define FALCON_STAT_WIDTH(falcon_stat) EFX_VAL(falcon_stat, WIDTH)
@@ -1398,10 +1398,7 @@ static void falcon_stats_request(struct efx_nic *efx)
 	WARN_ON(nic_data->stats_pending);
 	WARN_ON(nic_data->stats_disable_count);
 
-	if (nic_data->stats_dma_done == NULL)
-		return;	/* no mac selected */
-
-	*nic_data->stats_dma_done = FALCON_STATS_NOT_DONE;
+	FALCON_XMAC_STATS_DMA_FLAG(efx) = 0;
 	nic_data->stats_pending = true;
 	wmb(); /* ensure done flag is clear */
 
@@ -1423,7 +1420,7 @@ static void falcon_stats_complete(struct efx_nic *efx)
 		return;
 
 	nic_data->stats_pending = false;
-	if (*nic_data->stats_dma_done == FALCON_STATS_DONE) {
+	if (FALCON_XMAC_STATS_DMA_FLAG(efx)) {
 		rmb(); /* read the done flag before the stats */
 		falcon_update_stats_xmac(efx);
 	} else {
@@ -1706,7 +1703,6 @@ static int falcon_probe_port(struct efx_nic *efx)
 		  (u64)efx->stats_buffer.dma_addr,
 		  efx->stats_buffer.addr,
 		  (u64)virt_to_phys(efx->stats_buffer.addr));
-	nic_data->stats_dma_done = efx->stats_buffer.addr + XgDmaDone_offset;
 
 	return 0;
 }
@@ -2554,8 +2550,7 @@ static void falcon_update_nic_stats(struct efx_nic *efx)
 	efx->n_rx_nodesc_drop_cnt +=
 		EFX_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
 
-	if (nic_data->stats_pending &&
-	    *nic_data->stats_dma_done == FALCON_STATS_DONE) {
+	if (nic_data->stats_pending && FALCON_XMAC_STATS_DMA_FLAG(efx)) {
 		nic_data->stats_pending = false;
 		rmb(); /* read the done flag before the stats */
 		falcon_update_stats_xmac(efx);
@@ -2588,7 +2583,7 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
 	/* Wait enough time for the most recent transfer to
 	 * complete. */
 	for (i = 0; i < 4 && nic_data->stats_pending; i++) {
-		if (*nic_data->stats_dma_done == FALCON_STATS_DONE)
+		if (FALCON_XMAC_STATS_DMA_FLAG(efx))
 			break;
 		msleep(1);
 	}
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 2b84aeb..c3e0f1f 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -117,9 +117,6 @@ enum {
 	 (1 << LOOPBACK_XGXS) |			\
 	 (1 << LOOPBACK_XAUI))
 
-#define FALCON_GMAC_LOOPBACKS			\
-	(1 << LOOPBACK_GMAC)
-
 /* Alignment of PCIe DMA boundaries (4KB) */
 #define EFX_PAGE_SIZE	4096
 /* Size and alignment of buffer table entries (same) */
@@ -201,7 +198,6 @@ static inline bool falcon_spi_present(const struct falcon_spi_device *spi)
  * @stats_disable_count: Nest count for disabling statistics fetches
  * @stats_pending: Is there a pending DMA of MAC statistics.
  * @stats_timer: A timer for regularly fetching MAC statistics.
- * @stats_dma_done: Pointer to the flag which indicates DMA completion.
  * @spi_flash: SPI flash device
  * @spi_eeprom: SPI EEPROM device
  * @spi_lock: SPI bus lock
@@ -214,7 +210,6 @@ struct falcon_nic_data {
 	unsigned int stats_disable_count;
 	bool stats_pending;
 	struct timer_list stats_timer;
-	u32 *stats_dma_done;
 	struct falcon_spi_device spi_flash;
 	struct falcon_spi_device spi_eeprom;
 	struct mutex spi_lock;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
