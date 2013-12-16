From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/11] sfc: Change
 efx_nic_type::rx_push_indir_table to push hash key as well
Date: Mon, 16 Dec 2013 21:31:39 +0000
Message-ID: <1387229499.1799.45.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Andrew Rybchenko" <Andrew.Rybchenko@oktetlabs.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8582 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab3LPVbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:31:43 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

The EF10 implementation already does this, and it makes more logical
sense to group the RSS hash key and indirection table together.
Rename the operation to rx_push_rss_config.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 10 ++++----
 drivers/net/ethernet/sfc/ethtool.c    |  2 +-
 drivers/net/ethernet/sfc/falcon.c     | 26 ++++++++++++++++----
 drivers/net/ethernet/sfc/farch.c      |  5 +---
 drivers/net/ethernet/sfc/net_driver.h |  4 ++--
 drivers/net/ethernet/sfc/nic.h        |  4 ----
 drivers/net/ethernet/sfc/siena.c      | 45 +++++++++++++++++++++--------------
 7 files changed, 57 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9ec6072896c2..137c46b4b405 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -77,7 +77,7 @@ struct efx_ef10_filter_table {
 /* An arbitrary search limit for the software hash table */
 #define EFX_EF10_FILTER_SEARCH_LIMIT 200
 
-static void efx_ef10_rx_push_indir_table(struct efx_nic *efx);
+static void efx_ef10_rx_push_rss_config(struct efx_nic *efx);
 static void efx_ef10_rx_free_indir_table(struct efx_nic *efx);
 static void efx_ef10_filter_table_remove(struct efx_nic *efx);
 
@@ -679,7 +679,7 @@ static int efx_ef10_init_nic(struct efx_nic *efx)
 		nic_data->must_restore_piobufs = false;
 	}
 
-	efx_ef10_rx_push_indir_table(efx);
+	efx_ef10_rx_push_rss_config(efx);
 	return 0;
 }
 
@@ -1420,12 +1420,12 @@ static void efx_ef10_rx_free_indir_table(struct efx_nic *efx)
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 }
 
-static void efx_ef10_rx_push_indir_table(struct efx_nic *efx)
+static void efx_ef10_rx_push_rss_config(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
 
-	netif_dbg(efx, drv, efx->net_dev, "pushing RX indirection table\n");
+	netif_dbg(efx, drv, efx->net_dev, "pushing RSS config\n");
 
 	if (nic_data->rx_rss_context == EFX_EF10_RSS_CONTEXT_INVALID) {
 		rc = efx_ef10_alloc_rss_context(efx, &nic_data->rx_rss_context);
@@ -3574,7 +3574,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.tx_init = efx_ef10_tx_init,
 	.tx_remove = efx_ef10_tx_remove,
 	.tx_write = efx_ef10_tx_write,
-	.rx_push_indir_table = efx_ef10_rx_push_indir_table,
+	.rx_push_rss_config = efx_ef10_rx_push_rss_config,
 	.rx_probe = efx_ef10_rx_probe,
 	.rx_init = efx_ef10_rx_init,
 	.rx_remove = efx_ef10_rx_remove,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index fb8993806167..bb2af8045281 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1034,7 +1034,7 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	memcpy(efx->rx_indir_table, indir, sizeof(efx->rx_indir_table));
-	efx_nic_push_rx_indir_table(efx);
+	efx->type->rx_push_rss_config(efx);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 76699f4e6e04..5c6d63cfc394 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -469,6 +469,24 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 }
 /**************************************************************************
  *
+ * RSS
+ *
+ **************************************************************************
+ */
+
+static void falcon_b0_rx_push_rss_config(struct efx_nic *efx)
+{
+	efx_oword_t temp;
+
+	/* Set hash key for IPv4 */
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+
+	efx_farch_rx_push_indir_table(efx);
+}
+
+/**************************************************************************
+ *
  * EEPROM/flash
  *
  **************************************************************************
@@ -2484,9 +2502,7 @@ static int falcon_init_nic(struct efx_nic *efx)
 	falcon_init_rx_cfg(efx);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
-		/* Set hash key for IPv4 */
-		memcpy(&temp, efx->rx_hash_key, sizeof(temp));
-		efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+		falcon_b0_rx_push_rss_config(efx);
 
 		/* Set destination of both TX and RX Flush events */
 		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
@@ -2703,7 +2719,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
-	.rx_push_indir_table = efx_farch_rx_push_indir_table,
+	.rx_push_rss_config = efx_port_dummy_op_void,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
 	.rx_remove = efx_farch_rx_remove,
@@ -2798,7 +2814,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
-	.rx_push_indir_table = efx_farch_rx_push_indir_table,
+	.rx_push_rss_config = falcon_b0_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
 	.rx_remove = efx_farch_rx_remove,
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 984e85ee76f6..4c64ad7c9200 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1618,8 +1618,7 @@ void efx_farch_rx_push_indir_table(struct efx_nic *efx)
 	size_t i = 0;
 	efx_dword_t dword;
 
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
-		return;
+	BUG_ON(efx_nic_rev(efx) < EFX_REV_FALCON_B0);
 
 	BUILD_BUG_ON(ARRAY_SIZE(efx->rx_indir_table) !=
 		     FR_BZ_RX_INDIRECTION_TBL_ROWS);
@@ -1745,8 +1744,6 @@ void efx_farch_init_common(struct efx_nic *efx)
 	EFX_INVERT_OWORD(temp);
 	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
-	efx_farch_rx_push_indir_table(efx);
-
 	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
 	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
 	 */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 653b8782c956..1b3c4e5207c5 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1024,7 +1024,7 @@ struct efx_mtd_partition {
  * @tx_init: Initialise TX queue on the NIC
  * @tx_remove: Free resources for TX queue
  * @tx_write: Write TX descriptors and doorbell
- * @rx_push_indir_table: Write RSS indirection table to the NIC
+ * @rx_push_rss_config: Write RSS hash key and indirection table to the NIC
  * @rx_probe: Allocate resources for RX queue
  * @rx_init: Initialise RX queue on the NIC
  * @rx_remove: Free resources for RX queue
@@ -1141,7 +1141,7 @@ struct efx_nic_type {
 	void (*tx_init)(struct efx_tx_queue *tx_queue);
 	void (*tx_remove)(struct efx_tx_queue *tx_queue);
 	void (*tx_write)(struct efx_tx_queue *tx_queue);
-	void (*rx_push_indir_table)(struct efx_nic *efx);
+	void (*rx_push_rss_config)(struct efx_nic *efx);
 	int (*rx_probe)(struct efx_rx_queue *rx_queue);
 	void (*rx_init)(struct efx_rx_queue *rx_queue);
 	void (*rx_remove)(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 5d9e2dc121f7..c665ff6c8012 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -762,10 +762,6 @@ int falcon_reset_xaui(struct efx_nic *efx);
 void efx_farch_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw);
 void efx_farch_init_common(struct efx_nic *efx);
 void efx_ef10_handle_drain_event(struct efx_nic *efx);
-static inline void efx_nic_push_rx_indir_table(struct efx_nic *efx)
-{
-	efx->type->rx_push_indir_table(efx);
-}
 void efx_farch_rx_push_indir_table(struct efx_nic *efx);
 
 int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index f65db356fe09..23f3a6f7737a 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -321,6 +321,31 @@ fail1:
 	return rc;
 }
 
+static void siena_rx_push_rss_config(struct efx_nic *efx)
+{
+	efx_oword_t temp;
+
+	/* Set hash key for IPv4 */
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
+
+	/* Enable IPv6 RSS */
+	BUILD_BUG_ON(sizeof(efx->rx_hash_key) <
+		     2 * sizeof(temp) + FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8 ||
+		     FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN != 0);
+	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG1);
+	memcpy(&temp, efx->rx_hash_key + sizeof(temp), sizeof(temp));
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG2);
+	EFX_POPULATE_OWORD_2(temp, FRF_CZ_RX_RSS_IPV6_THASH_ENABLE, 1,
+			     FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE, 1);
+	memcpy(&temp, efx->rx_hash_key + 2 * sizeof(temp),
+	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
+	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
+
+	efx_farch_rx_push_indir_table(efx);
+}
+
 /* This call performs hardware-specific global initialisation, such as
  * defining the descriptor cache sizes and number of RSS channels.
  * It does not set up any buffers, descriptor rings or event queues.
@@ -361,23 +386,7 @@ static int siena_init_nic(struct efx_nic *efx)
 			    EFX_RX_USR_BUF_SIZE >> 5);
 	efx_writeo(efx, &temp, FR_AZ_RX_CFG);
 
-	/* Set hash key for IPv4 */
-	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
-	efx_writeo(efx, &temp, FR_BZ_RX_RSS_TKEY);
-
-	/* Enable IPv6 RSS */
-	BUILD_BUG_ON(sizeof(efx->rx_hash_key) <
-		     2 * sizeof(temp) + FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8 ||
-		     FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN != 0);
-	memcpy(&temp, efx->rx_hash_key, sizeof(temp));
-	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG1);
-	memcpy(&temp, efx->rx_hash_key + sizeof(temp), sizeof(temp));
-	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG2);
-	EFX_POPULATE_OWORD_2(temp, FRF_CZ_RX_RSS_IPV6_THASH_ENABLE, 1,
-			     FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE, 1);
-	memcpy(&temp, efx->rx_hash_key + 2 * sizeof(temp),
-	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
-	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
+	siena_rx_push_rss_config(efx);
 
 	/* Enable event logging */
 	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
@@ -940,7 +949,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.tx_init = efx_farch_tx_init,
 	.tx_remove = efx_farch_tx_remove,
 	.tx_write = efx_farch_tx_write,
-	.rx_push_indir_table = efx_farch_rx_push_indir_table,
+	.rx_push_rss_config = siena_rx_push_rss_config,
 	.rx_probe = efx_farch_rx_probe,
 	.rx_init = efx_farch_rx_init,
 	.rx_remove = efx_farch_rx_remove,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
