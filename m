From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 18/19] sfc: Allocate SRAM between buffer table and
 descriptor caches at init time
Date: Thu, 16 Feb 2012 00:52:07 +0000
Message-ID: <1329353527.2565.44.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27744 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756668Ab2BPAwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:52:10 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each port has a block of 64-bit SRAM that is divided between buffer
table and descriptor cache regions at initialisation time.  Currently
we use a fixed allocation, but it needs to be changed to support
larger numbers of queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    2 ++
 drivers/net/ethernet/sfc/falcon.c     |   12 ++++++++----
 drivers/net/ethernet/sfc/net_driver.h |   13 +++++++++----
 drivers/net/ethernet/sfc/nic.c        |   23 +++++++++++++++++++----
 drivers/net/ethernet/sfc/nic.h        |    2 ++
 drivers/net/ethernet/sfc/siena.c      |   12 ++++++++++--
 6 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e943ffb..c9c306a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1420,6 +1420,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail;
 
+	efx->type->dimension_resources(efx);
+
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 9828511..3a1ca2b 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1333,6 +1333,12 @@ out:
 	return rc;
 }
 
+static void falcon_dimension_resources(struct efx_nic *efx)
+{
+	efx->rx_dc_base = 0x20000;
+	efx->tx_dc_base = 0x26000;
+}
+
 /* Probe all SPI devices on the NIC */
 static void falcon_probe_spi_devices(struct efx_nic *efx)
 {
@@ -1749,6 +1755,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
+	.dimension_resources = falcon_dimension_resources,
 	.fini = efx_port_dummy_op_void,
 	.monitor = falcon_monitor,
 	.map_reset_reason = falcon_map_reset_reason,
@@ -1783,8 +1790,6 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.max_interrupt_mode = EFX_INT_MODE_MSI,
 	.phys_addr_channels = 4,
 	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
-	.tx_dc_base = 0x130000,
-	.rx_dc_base = 0x100000,
 	.offload_features = NETIF_F_IP_CSUM,
 };
 
@@ -1792,6 +1797,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
+	.dimension_resources = falcon_dimension_resources,
 	.fini = efx_port_dummy_op_void,
 	.monitor = falcon_monitor,
 	.map_reset_reason = falcon_map_reset_reason,
@@ -1835,8 +1841,6 @@ const struct efx_nic_type falcon_b0_nic_type = {
 				   * interrupt handler only supports 32
 				   * channels */
 	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
-	.tx_dc_base = 0x130000,
-	.rx_dc_base = 0x100000,
 	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
 };
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 94b0dca..7870cef 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -658,6 +658,9 @@ struct efx_filter_state;
  *	should be allocated for this NIC
  * @rxq_entries: Size of receive queues requested by user.
  * @txq_entries: Size of transmit queues requested by user.
+ * @tx_dc_base: Base qword address in SRAM of TX queue descriptor caches
+ * @rx_dc_base: Base qword address in SRAM of RX queue descriptor caches
+ * @sram_lim_qw: Qword address limit of SRAM
  * @next_buffer_table: First available buffer table id
  * @n_channels: Number of channels in use
  * @n_rx_channels: Number of channels used for RX (= number of RX queues)
@@ -753,6 +756,9 @@ struct efx_nic {
 
 	unsigned rxq_entries;
 	unsigned txq_entries;
+	unsigned tx_dc_base;
+	unsigned rx_dc_base;
+	unsigned sram_lim_qw;
 	unsigned next_buffer_table;
 	unsigned n_channels;
 	unsigned n_rx_channels;
@@ -839,6 +845,8 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @probe: Probe the controller
  * @remove: Free resources allocated by probe()
  * @init: Initialise the controller
+ * @dimension_resources: Dimension controller resources (buffer table,
+ *	and VIs once the available interrupt resources are clear)
  * @fini: Shut down the controller
  * @monitor: Periodic function for polling link state and hardware monitor
  * @map_reset_reason: Map ethtool reset reason to a reset method
@@ -878,8 +886,6 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @phys_addr_channels: Number of channels with physically addressed
  *	descriptors
  * @timer_period_max: Maximum period of interrupt timer (in ticks)
- * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
- * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
  * @offload_features: net_device feature flags for protocol offload
  *	features implemented in hardware
  */
@@ -887,6 +893,7 @@ struct efx_nic_type {
 	int (*probe)(struct efx_nic *efx);
 	void (*remove)(struct efx_nic *efx);
 	int (*init)(struct efx_nic *efx);
+	void (*dimension_resources)(struct efx_nic *efx);
 	void (*fini)(struct efx_nic *efx);
 	void (*monitor)(struct efx_nic *efx);
 	enum reset_type (*map_reset_reason)(enum reset_type reason);
@@ -923,8 +930,6 @@ struct efx_nic_type {
 	unsigned int max_interrupt_mode;
 	unsigned int phys_addr_channels;
 	unsigned int timer_period_max;
-	unsigned int tx_dc_base;
-	unsigned int rx_dc_base;
 	netdev_features_t offload_features;
 };
 
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 2bdfb63..747cf94 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1609,6 +1609,23 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 		free_irq(efx->legacy_irq, efx);
 }
 
+void efx_nic_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw)
+{
+	unsigned vi_count, buftbl_min;
+
+	/* Account for the buffer table entries backing the datapath channels
+	 * and the descriptor caches for those channels.
+	 */
+	buftbl_min = ((efx->n_rx_channels * EFX_MAX_DMAQ_SIZE +
+		       efx->n_tx_channels * EFX_TXQ_TYPES * EFX_MAX_DMAQ_SIZE +
+		       efx->n_channels * EFX_MAX_EVQ_SIZE)
+		      * sizeof(efx_qword_t) / EFX_BUF_SIZE);
+	vi_count = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
+
+	efx->tx_dc_base = sram_lim_qw - vi_count * TX_DC_ENTRIES;
+	efx->rx_dc_base = efx->tx_dc_base - vi_count * RX_DC_ENTRIES;
+}
+
 u32 efx_nic_fpga_ver(struct efx_nic *efx)
 {
 	efx_oword_t altera_build;
@@ -1621,11 +1638,9 @@ void efx_nic_init_common(struct efx_nic *efx)
 	efx_oword_t temp;
 
 	/* Set positions of descriptor caches in SRAM. */
-	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR,
-			     efx->type->tx_dc_base / 8);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR, efx->tx_dc_base);
 	efx_writeo(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
-	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR,
-			     efx->type->rx_dc_base / 8);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR, efx->rx_dc_base);
 	efx_writeo(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
 
 	/* Set TX descriptor cache size. */
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 1f53e2c..5df7da8 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -230,6 +230,8 @@ extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
+extern void
+efx_nic_dimension_resources(struct efx_nic *efx, unsigned sram_lim_qw);
 extern void efx_nic_init_common(struct efx_nic *efx);
 extern void efx_nic_push_rx_indir_table(struct efx_nic *efx);
 
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index d3c4169..657f3fa 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -225,6 +225,15 @@ static int siena_probe_nvconfig(struct efx_nic *efx)
 	return rc;
 }
 
+static void siena_dimension_resources(struct efx_nic *efx)
+{
+	/* Each port has a small block of internal SRAM dedicated to
+	 * the buffer table and descriptor caches.  In theory we can
+	 * map both blocks to one port, but we don't.
+	 */
+	efx_nic_dimension_resources(efx, FR_CZ_BUF_FULL_TBL_ROWS / 2);
+}
+
 static int siena_probe_nic(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data;
@@ -619,6 +628,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.probe = siena_probe_nic,
 	.remove = siena_remove_nic,
 	.init = siena_init_nic,
+	.dimension_resources = siena_dimension_resources,
 	.fini = efx_port_dummy_op_void,
 	.monitor = NULL,
 	.map_reset_reason = siena_map_reset_reason,
@@ -657,8 +667,6 @@ const struct efx_nic_type siena_a0_nic_type = {
 				   * interrupt handler only supports 32
 				   * channels */
 	.timer_period_max = 1 << FRF_CZ_TC_TIMER_VAL_WIDTH,
-	.tx_dc_base = 0x88000,
-	.rx_dc_base = 0x68000,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
 };
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
