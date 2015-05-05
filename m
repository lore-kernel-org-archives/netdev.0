From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 09/14] sfc: Prepare to bind the sfc driver to the
 VF.
Date: Wed, 6 May 2015 00:58:14 +0100
Message-ID: <55495916.1030809@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:29796 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932101AbbEEX63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:58:29 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added efx_nic_type structure for VF.
Mapped a different BAR for VF as it uses BAR 0 for memory.
Added functions sriov_init and sriov_fini.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 141 +++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_sriov.c |  17 ++++
 drivers/net/ethernet/sfc/ef10_sriov.h |   9 +--
 drivers/net/ethernet/sfc/efx.c        |  15 ++--
 drivers/net/ethernet/sfc/efx.h        |   2 +
 drivers/net/ethernet/sfc/falcon.c     |   2 +
 drivers/net/ethernet/sfc/net_driver.h |   2 +
 drivers/net/ethernet/sfc/nic.h        |   1 +
 drivers/net/ethernet/sfc/siena.c      |   1 +
 9 files changed, 175 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4d6d194..ae98e42 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -93,7 +93,10 @@ static int efx_ef10_get_warm_boot_count(struct efx_nic *efx)
 
 static unsigned int efx_ef10_mem_map_size(struct efx_nic *efx)
 {
-	return resource_size(&efx->pci_dev->resource[EFX_MEM_BAR]);
+	int bar;
+
+	bar = efx->type->mem_bar;
+	return resource_size(&efx->pci_dev->resource[bar]);
 }
 
 static int efx_ef10_get_pf_index(struct efx_nic *efx)
@@ -204,7 +207,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	efx->max_channels =
 		min_t(unsigned int,
 		      EFX_MAX_CHANNELS,
-		      resource_size(&efx->pci_dev->resource[EFX_MEM_BAR]) /
+		      efx_ef10_mem_map_size(efx) /
 		      (EFX_VI_PAGE_SIZE * EFX_TXQ_TYPES));
 	if (WARN_ON(efx->max_channels == 0))
 		return -EIO;
@@ -311,6 +314,23 @@ fail1:
 	return rc;
 }
 
+static int efx_ef10_probe_pf(struct efx_nic *efx)
+{
+	return efx_ef10_probe(efx);
+}
+
+#ifdef CONFIG_SFC_SRIOV
+static int efx_ef10_probe_vf(struct efx_nic *efx)
+{
+	return efx_ef10_probe(efx);
+}
+#else
+static int efx_ef10_probe_vf(struct efx_nic *efx __attribute__ ((unused)))
+{
+	return 0;
+}
+#endif
+
 static int efx_ef10_free_vis(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, 0);
@@ -1076,6 +1096,14 @@ static void efx_ef10_push_irq_moderation(struct efx_channel *channel)
 	}
 }
 
+static void efx_ef10_get_wol_vf(struct efx_nic *efx,
+				struct ethtool_wolinfo *wol) {}
+
+static int efx_ef10_set_wol_vf(struct efx_nic *efx, u32 type)
+{
+	return -EOPNOTSUPP;
+}
+
 static void efx_ef10_get_wol(struct efx_nic *efx, struct ethtool_wolinfo *wol)
 {
 	wol->supported = 0;
@@ -3534,6 +3562,9 @@ static void efx_ef10_ptp_write_host_time(struct efx_nic *efx, u32 host_time)
 	_efx_writed(efx, cpu_to_le32(host_time), ER_DZ_MC_DB_LWRD);
 }
 
+static void efx_ef10_ptp_write_host_time_vf(struct efx_nic *efx,
+					    u32 host_time) {}
+
 static int efx_ef10_rx_enable_timestamping(struct efx_channel *channel,
 					   bool temp)
 {
@@ -3611,6 +3642,12 @@ static int efx_ef10_ptp_set_ts_sync_events(struct efx_nic *efx, bool en,
 	return 0;
 }
 
+static int efx_ef10_ptp_set_ts_config_vf(struct efx_nic *efx,
+					 struct hwtstamp_config *init)
+{
+	return -EOPNOTSUPP;
+}
+
 static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 				      struct hwtstamp_config *init)
 {
@@ -3647,9 +3684,107 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 	}
 }
 
+const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
+	.mem_bar = EFX_MEM_VF_BAR,
+	.mem_map_size = efx_ef10_mem_map_size,
+	.probe = efx_ef10_probe_vf,
+	.remove = efx_ef10_remove,
+	.dimension_resources = efx_ef10_dimension_resources,
+	.init = efx_ef10_init_nic,
+	.fini = efx_port_dummy_op_void,
+	.map_reset_reason = efx_mcdi_map_reset_reason,
+	.map_reset_flags = efx_ef10_map_reset_flags,
+	.reset = efx_ef10_reset,
+	.probe_port = efx_mcdi_port_probe,
+	.remove_port = efx_mcdi_port_remove,
+	.fini_dmaq = efx_ef10_fini_dmaq,
+	.prepare_flr = efx_ef10_prepare_flr,
+	.finish_flr = efx_port_dummy_op_void,
+	.describe_stats = efx_ef10_describe_stats,
+	.update_stats = efx_ef10_update_stats,
+	.start_stats = efx_port_dummy_op_void,
+	.pull_stats = efx_port_dummy_op_void,
+	.stop_stats = efx_port_dummy_op_void,
+	.set_id_led = efx_mcdi_set_id_led,
+	.push_irq_moderation = efx_ef10_push_irq_moderation,
+	.reconfigure_mac = efx_ef10_mac_reconfigure,
+	.check_mac_fault = efx_mcdi_mac_check_fault,
+	.reconfigure_port = efx_mcdi_port_reconfigure,
+	.get_wol = efx_ef10_get_wol_vf,
+	.set_wol = efx_ef10_set_wol_vf,
+	.resume_wol = efx_port_dummy_op_void,
+	.mcdi_request = efx_ef10_mcdi_request,
+	.mcdi_poll_response = efx_ef10_mcdi_poll_response,
+	.mcdi_read_response = efx_ef10_mcdi_read_response,
+	.mcdi_poll_reboot = efx_ef10_mcdi_poll_reboot,
+	.irq_enable_master = efx_port_dummy_op_void,
+	.irq_test_generate = efx_ef10_irq_test_generate,
+	.irq_disable_non_ev = efx_port_dummy_op_void,
+	.irq_handle_msi = efx_ef10_msi_interrupt,
+	.irq_handle_legacy = efx_ef10_legacy_interrupt,
+	.tx_probe = efx_ef10_tx_probe,
+	.tx_init = efx_ef10_tx_init,
+	.tx_remove = efx_ef10_tx_remove,
+	.tx_write = efx_ef10_tx_write,
+	.rx_push_rss_config = efx_ef10_rx_push_rss_config,
+	.rx_probe = efx_ef10_rx_probe,
+	.rx_init = efx_ef10_rx_init,
+	.rx_remove = efx_ef10_rx_remove,
+	.rx_write = efx_ef10_rx_write,
+	.rx_defer_refill = efx_ef10_rx_defer_refill,
+	.ev_probe = efx_ef10_ev_probe,
+	.ev_init = efx_ef10_ev_init,
+	.ev_fini = efx_ef10_ev_fini,
+	.ev_remove = efx_ef10_ev_remove,
+	.ev_process = efx_ef10_ev_process,
+	.ev_read_ack = efx_ef10_ev_read_ack,
+	.ev_test_generate = efx_ef10_ev_test_generate,
+	.filter_table_probe = efx_ef10_filter_table_probe,
+	.filter_table_restore = efx_ef10_filter_table_restore,
+	.filter_table_remove = efx_ef10_filter_table_remove,
+	.filter_update_rx_scatter = efx_ef10_filter_update_rx_scatter,
+	.filter_insert = efx_ef10_filter_insert,
+	.filter_remove_safe = efx_ef10_filter_remove_safe,
+	.filter_get_safe = efx_ef10_filter_get_safe,
+	.filter_clear_rx = efx_ef10_filter_clear_rx,
+	.filter_count_rx_used = efx_ef10_filter_count_rx_used,
+	.filter_get_rx_id_limit = efx_ef10_filter_get_rx_id_limit,
+	.filter_get_rx_ids = efx_ef10_filter_get_rx_ids,
+#ifdef CONFIG_RFS_ACCEL
+	.filter_rfs_insert = efx_ef10_filter_rfs_insert,
+	.filter_rfs_expire_one = efx_ef10_filter_rfs_expire_one,
+#endif
+#ifdef CONFIG_SFC_MTD
+	.mtd_probe = efx_port_dummy_op_int,
+#endif
+	.ptp_write_host_time = efx_ef10_ptp_write_host_time_vf,
+	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config_vf,
+#ifdef CONFIG_SFC_SRIOV
+	.vswitching_probe = efx_port_dummy_op_int,
+	.vswitching_restore = efx_port_dummy_op_int,
+	.vswitching_remove = efx_port_dummy_op_void,
+#endif
+	.revision = EFX_REV_HUNT_A0,
+	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
+	.rx_prefix_size = ES_DZ_RX_PREFIX_SIZE,
+	.rx_hash_offset = ES_DZ_RX_PREFIX_HASH_OFST,
+	.rx_ts_offset = ES_DZ_RX_PREFIX_TSTAMP_OFST,
+	.can_rx_scatter = true,
+	.always_rx_scatter = true,
+	.max_interrupt_mode = EFX_INT_MODE_MSIX,
+	.timer_period_max = 1 << ERF_DD_EVQ_IND_TIMER_VAL_WIDTH,
+	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
+	.mcdi_max_ver = 2,
+	.max_rx_ip_filters = HUNT_FILTER_TBL_ROWS,
+	.hwtstamp_filters = 1 << HWTSTAMP_FILTER_NONE |
+			    1 << HWTSTAMP_FILTER_ALL,
+};
+
 const struct efx_nic_type efx_hunt_a0_nic_type = {
+	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = efx_ef10_mem_map_size,
-	.probe = efx_ef10_probe,
+	.probe = efx_ef10_probe_pf,
 	.remove = efx_ef10_remove,
 	.dimension_resources = efx_ef10_dimension_resources,
 	.init = efx_ef10_init_nic,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 2aba7b7..be74a70 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -46,6 +46,23 @@ int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
 		return efx_ef10_pci_sriov_enable(efx, num_vfs);
 }
 
+int efx_ef10_sriov_init(struct efx_nic *efx)
+{
+	return 0;
+}
+
+void efx_ef10_sriov_fini(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_ef10_pci_sriov_disable(efx);
+	if (rc)
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Disabling SRIOV was not successful rc=%d\n", rc);
+	else
+		netif_dbg(efx, drv, efx->net_dev, "SRIOV disabled\n");
+}
+
 static int efx_ef10_vswitch_alloc(struct efx_nic *efx, unsigned int port_id,
 				  unsigned int vswitch_type)
 {
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 676b00c..40833db 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -18,15 +18,10 @@ static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
 }
 
 int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs);
-
-static inline int efx_ef10_sriov_init(struct efx_nic *efx)
-{
-	return -EOPNOTSUPP;
-}
-
+int efx_ef10_sriov_init(struct efx_nic *efx);
 static inline void efx_ef10_sriov_mac_address_changed(struct efx_nic *efx) {}
 static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
-static inline void efx_ef10_sriov_fini(struct efx_nic *efx) {}
+void efx_ef10_sriov_fini(struct efx_nic *efx);
 static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
 
 static inline int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index f1dd34c..8b2edda 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1201,10 +1201,12 @@ static int efx_init_io(struct efx_nic *efx)
 	struct pci_dev *pci_dev = efx->pci_dev;
 	dma_addr_t dma_mask = efx->type->max_dma_mask;
 	unsigned int mem_map_size = efx->type->mem_map_size(efx);
-	int rc;
+	int rc, bar;
 
 	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
 
+	bar = efx->type->mem_bar;
+
 	rc = pci_enable_device(pci_dev);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev,
@@ -1235,8 +1237,8 @@ static int efx_init_io(struct efx_nic *efx)
 	netif_dbg(efx, probe, efx->net_dev,
 		  "using DMA mask %llx\n", (unsigned long long) dma_mask);
 
-	efx->membase_phys = pci_resource_start(efx->pci_dev, EFX_MEM_BAR);
-	rc = pci_request_region(pci_dev, EFX_MEM_BAR, "sfc");
+	efx->membase_phys = pci_resource_start(efx->pci_dev, bar);
+	rc = pci_request_region(pci_dev, bar, "sfc");
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev,
 			  "request for memory BAR failed\n");
@@ -1259,7 +1261,7 @@ static int efx_init_io(struct efx_nic *efx)
 	return 0;
 
  fail4:
-	pci_release_region(efx->pci_dev, EFX_MEM_BAR);
+	pci_release_region(efx->pci_dev, bar);
  fail3:
 	efx->membase_phys = 0;
  fail2:
@@ -1270,6 +1272,8 @@ static int efx_init_io(struct efx_nic *efx)
 
 static void efx_fini_io(struct efx_nic *efx)
 {
+	int bar;
+
 	netif_dbg(efx, drv, efx->net_dev, "shutting down I/O\n");
 
 	if (efx->membase) {
@@ -1278,7 +1282,8 @@ static void efx_fini_io(struct efx_nic *efx)
 	}
 
 	if (efx->membase_phys) {
-		pci_release_region(efx->pci_dev, EFX_MEM_BAR);
+		bar = efx->type->mem_bar;
+		pci_release_region(efx->pci_dev, bar);
 		efx->membase_phys = 0;
 	}
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index bc4e4b3..946607f 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -15,7 +15,9 @@
 #include "filter.h"
 
 /* All controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
+/* All VFs use BAR 0/1 for memory */
 #define EFX_MEM_BAR 2
+#define EFX_MEM_VF_BAR 0
 
 /* TX */
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 1570375..5a23435 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2687,6 +2687,7 @@ static int falcon_set_wol(struct efx_nic *efx, u32 type)
  */
 
 const struct efx_nic_type falcon_a1_nic_type = {
+	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = falcon_a1_mem_map_size,
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
@@ -2783,6 +2784,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 };
 
 const struct efx_nic_type falcon_b0_nic_type = {
+	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = falcon_b0_mem_map_size,
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0cb3e0e..dd7134e 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1089,6 +1089,7 @@ struct efx_mtd_partition {
 
 /**
  * struct efx_nic_type - Efx device type definition
+ * @mem_bar: Get the memory BAR
  * @mem_map_size: Get memory BAR mapped size
  * @probe: Probe the controller
  * @remove: Free resources allocated by probe()
@@ -1223,6 +1224,7 @@ struct efx_mtd_partition {
  * @hwtstamp_filters: Mask of hardware timestamp filter types supported
  */
 struct efx_nic_type {
+	unsigned int mem_bar;
 	unsigned int (*mem_map_size)(struct efx_nic *efx);
 	int (*probe)(struct efx_nic *efx);
 	void (*remove)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 3ab8840..b350c39 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -555,6 +555,7 @@ extern const struct efx_nic_type falcon_a1_nic_type;
 extern const struct efx_nic_type falcon_b0_nic_type;
 extern const struct efx_nic_type siena_a0_nic_type;
 extern const struct efx_nic_type efx_hunt_a0_nic_type;
+extern const struct efx_nic_type efx_hunt_a0_vf_nic_type;
 
 /**************************************************************************
  *
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 5c2995e..95babe2 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -912,6 +912,7 @@ fail:
  */
 
 const struct efx_nic_type siena_a0_nic_type = {
+	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = siena_mem_map_size,
 	.probe = siena_probe_nic,
 	.remove = siena_remove_nic,
