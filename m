From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/16] sfc: Get rid of per-NIC-type
 phys_addr_channels and mem_map_size
Date: Tue, 27 Aug 2013 21:38:41 +0100
Message-ID: <1377635921.13272.70.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62530 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab3H0Uip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:38:45 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EF10 functions don't have a fixed BAR size, and the minimum is not
large enough for all the queues we might want to allocate.  We have to
find out the BAR size at run-time, and therefore phys_addr_channels
and mem_map_size cannot be defined per-NIC-type.

Change efx_nic_type::mem_map_size to a function pointer which is
called to find the wanted memory map size (before probe).

Replace efx_nic_type::phys_addr_channels with efx_nic::max_channels,
to be initialised by the probe function.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 17 ++++++-----------
 drivers/net/ethernet/sfc/falcon.c     | 29 ++++++++++++++++++-----------
 drivers/net/ethernet/sfc/net_driver.h |  9 ++++-----
 drivers/net/ethernet/sfc/siena.c      | 14 +++++++++-----
 4 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 872b9f5..3977926 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1084,6 +1084,7 @@ static int efx_init_io(struct efx_nic *efx)
 {
 	struct pci_dev *pci_dev = efx->pci_dev;
 	dma_addr_t dma_mask = efx->type->max_dma_mask;
+	unsigned int mem_map_size = efx->type->mem_map_size(efx);
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
@@ -1136,20 +1137,18 @@ static int efx_init_io(struct efx_nic *efx)
 		rc = -EIO;
 		goto fail3;
 	}
-	efx->membase = ioremap_nocache(efx->membase_phys,
-				       efx->type->mem_map_size);
+	efx->membase = ioremap_nocache(efx->membase_phys, mem_map_size);
 	if (!efx->membase) {
 		netif_err(efx, probe, efx->net_dev,
 			  "could not map memory BAR at %llx+%x\n",
-			  (unsigned long long)efx->membase_phys,
-			  efx->type->mem_map_size);
+			  (unsigned long long)efx->membase_phys, mem_map_size);
 		rc = -ENOMEM;
 		goto fail4;
 	}
 	netif_dbg(efx, probe, efx->net_dev,
 		  "memory BAR at %llx+%x (virtual %p)\n",
-		  (unsigned long long)efx->membase_phys,
-		  efx->type->mem_map_size, efx->membase);
+		  (unsigned long long)efx->membase_phys, mem_map_size,
+		  efx->membase);
 
 	return 0;
 
@@ -1228,8 +1227,6 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
  */
 static int efx_probe_interrupts(struct efx_nic *efx)
 {
-	unsigned int max_channels =
-		min(efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
 	unsigned int extra_channels = 0;
 	unsigned int i, j;
 	int rc;
@@ -1246,7 +1243,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 		if (separate_tx_channels)
 			n_channels *= 2;
 		n_channels += extra_channels;
-		n_channels = min(n_channels, max_channels);
+		n_channels = min(n_channels, efx->max_channels);
 
 		for (i = 0; i < n_channels; i++)
 			xentries[i].entry = i;
@@ -2489,8 +2486,6 @@ static int efx_init_struct(struct efx_nic *efx,
 		efx->msi_context[i].index = i;
 	}
 
-	EFX_BUG_ON_PARANOID(efx->type->phys_addr_channels > EFX_MAX_CHANNELS);
-
 	/* Higher numbered interrupt modes are less capable! */
 	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
 				  interrupt_mode);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index e556a5d..17bd7dc 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1970,6 +1970,20 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 				       large_eeprom_type);
 }
 
+static unsigned int falcon_a1_mem_map_size(struct efx_nic *efx)
+{
+	return 0x20000;
+}
+
+static unsigned int falcon_b0_mem_map_size(struct efx_nic *efx)
+{
+	/* Map everything up to and including the RSS indirection table.
+	 * The PCI core takes care of mapping the MSI-X tables.
+	 */
+	return FR_BZ_RX_INDIRECTION_TBL +
+		FR_BZ_RX_INDIRECTION_TBL_STEP * FR_BZ_RX_INDIRECTION_TBL_ROWS;
+}
+
 static int falcon_probe_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data;
@@ -2060,6 +2074,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		goto fail5;
 	}
 
+	efx->max_channels = (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ? 4 :
+			     EFX_MAX_CHANNELS);
 	efx->timer_quantum_ns = 4968; /* 621 cycles */
 
 	/* Initialise I2C adapter */
@@ -2339,6 +2355,7 @@ static int falcon_set_wol(struct efx_nic *efx, u32 type)
  */
 
 const struct efx_nic_type falcon_a1_nic_type = {
+	.mem_map_size = falcon_a1_mem_map_size,
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
@@ -2391,7 +2408,6 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.ev_test_generate = efx_farch_ev_test_generate,
 
 	.revision = EFX_REV_FALCON_A1,
-	.mem_map_size = 0x20000,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
 	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
 	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
@@ -2401,13 +2417,13 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.rx_buffer_padding = 0x24,
 	.can_rx_scatter = false,
 	.max_interrupt_mode = EFX_INT_MODE_MSI,
-	.phys_addr_channels = 4,
 	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
 	.offload_features = NETIF_F_IP_CSUM,
 	.mcdi_max_ver = -1,
 };
 
 const struct efx_nic_type falcon_b0_nic_type = {
+	.mem_map_size = falcon_b0_mem_map_size,
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
@@ -2461,12 +2477,6 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.ev_test_generate = efx_farch_ev_test_generate,
 
 	.revision = EFX_REV_FALCON_B0,
-	/* Map everything up to and including the RSS indirection
-	 * table.  Don't map MSI-X table, MSI-X PBA since Linux
-	 * requires that they not be mapped.  */
-	.mem_map_size = (FR_BZ_RX_INDIRECTION_TBL +
-			 FR_BZ_RX_INDIRECTION_TBL_STEP *
-			 FR_BZ_RX_INDIRECTION_TBL_ROWS),
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
 	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
@@ -2477,9 +2487,6 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.rx_buffer_padding = 0,
 	.can_rx_scatter = true,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
-	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
-				   * interrupt handler only supports 32
-				   * channels */
 	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
 	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
 	.mcdi_max_ver = -1,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index e1deec4..7aa0e0f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -832,6 +832,8 @@ struct efx_nic {
 	unsigned rx_dc_base;
 	unsigned sram_lim_qw;
 	unsigned next_buffer_table;
+
+	unsigned int max_channels;
 	unsigned n_channels;
 	unsigned n_rx_channels;
 	unsigned rss_spread;
@@ -939,6 +941,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
 
 /**
  * struct efx_nic_type - Efx device type definition
+ * @mem_map_size: Get memory BAR mapped size
  * @probe: Probe the controller
  * @remove: Free resources allocated by probe()
  * @init: Initialise the controller
@@ -1012,7 +1015,6 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @ev_read_ack: Acknowledge read events on a queue, rearming its IRQ
  * @ev_test_generate: Generate a test event
  * @revision: Hardware architecture revision
- * @mem_map_size: Memory BAR mapped size
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
  * @buf_tbl_base: Buffer table base address
@@ -1024,14 +1026,13 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @can_rx_scatter: NIC is able to scatter packet to multiple buffers
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
- * @phys_addr_channels: Number of channels with physically addressed
- *	descriptors
  * @timer_period_max: Maximum period of interrupt timer (in ticks)
  * @offload_features: net_device feature flags for protocol offload
  *	features implemented in hardware
  * @mcdi_max_ver: Maximum MCDI version supported
  */
 struct efx_nic_type {
+	unsigned int (*mem_map_size)(struct efx_nic *efx);
 	int (*probe)(struct efx_nic *efx);
 	void (*remove)(struct efx_nic *efx);
 	int (*init)(struct efx_nic *efx);
@@ -1092,7 +1093,6 @@ struct efx_nic_type {
 	void (*ev_test_generate)(struct efx_channel *channel);
 
 	int revision;
-	unsigned int mem_map_size;
 	unsigned int txd_ptr_tbl_base;
 	unsigned int rxd_ptr_tbl_base;
 	unsigned int buf_tbl_base;
@@ -1103,7 +1103,6 @@ struct efx_nic_type {
 	unsigned int rx_buffer_padding;
 	bool can_rx_scatter;
 	unsigned int max_interrupt_mode;
-	unsigned int phys_addr_channels;
 	unsigned int timer_period_max;
 	netdev_features_t offload_features;
 	int mcdi_max_ver;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index fee0d2d..23e5731 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -187,6 +187,12 @@ static void siena_dimension_resources(struct efx_nic *efx)
 	efx_farch_dimension_resources(efx, FR_CZ_BUF_FULL_TBL_ROWS / 2);
 }
 
+static unsigned int siena_mem_map_size(struct efx_nic *efx)
+{
+	return FR_CZ_MC_TREG_SMEM +
+		FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS;
+}
+
 static int siena_probe_nic(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data;
@@ -207,6 +213,8 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail1;
 	}
 
+	efx->max_channels = EFX_MAX_CHANNELS;
+
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
 	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
@@ -670,6 +678,7 @@ static int siena_mcdi_poll_reboot(struct efx_nic *efx)
  */
 
 const struct efx_nic_type siena_a0_nic_type = {
+	.mem_map_size = siena_mem_map_size,
 	.probe = siena_probe_nic,
 	.remove = siena_remove_nic,
 	.init = siena_init_nic,
@@ -729,8 +738,6 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.ev_test_generate = efx_farch_ev_test_generate,
 
 	.revision = EFX_REV_SIENA_A0,
-	.mem_map_size = (FR_CZ_MC_TREG_SMEM +
-			 FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS),
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
 	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
@@ -741,9 +748,6 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.rx_buffer_padding = 0,
 	.can_rx_scatter = true,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
-	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
-				   * interrupt handler only supports 32
-				   * channels */
 	.timer_period_max = 1 << FRF_CZ_TC_TIMER_VAL_WIDTH,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			     NETIF_F_RXHASH | NETIF_F_NTUPLE),


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
