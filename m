From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/12] sfc: Move Falcon NIC operations to efx_nic_type
Date: Sun, 29 Nov 2009 13:42:31 +0000
Message-ID: <1259502151.3709.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29103 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbZK2Nm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 08:42:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is preparation for adding differing implementations for new NICs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   44 +++++++++++++----------
 drivers/net/sfc/ethtool.c    |    2 +-
 drivers/net/sfc/falcon.c     |   79 ++++++++++++++++++++++++++---------------
 drivers/net/sfc/falcon.h     |   12 ------
 drivers/net/sfc/net_driver.h |   29 +++++++++++++++
 drivers/net/sfc/selftest.c   |    2 +-
 6 files changed, 105 insertions(+), 63 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f5e8111..73ab246 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -274,14 +274,14 @@ static int efx_poll(struct napi_struct *napi, int budget)
 				     irq_adapt_low_thresh)) {
 				if (channel->irq_moderation > 1) {
 					channel->irq_moderation -= 1;
-					falcon_set_int_moderation(channel);
+					efx->type->push_irq_moderation(channel);
 				}
 			} else if (unlikely(channel->irq_mod_score >
 					    irq_adapt_high_thresh)) {
 				if (channel->irq_moderation <
 				    efx->irq_rx_moderation) {
 					channel->irq_moderation += 1;
-					falcon_set_int_moderation(channel);
+					efx->type->push_irq_moderation(channel);
 				}
 			}
 			channel->irq_count = 0;
@@ -637,7 +637,7 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 		netif_addr_unlock_bh(efx->net_dev);
 	}
 
-	falcon_stop_nic_stats(efx);
+	efx->type->stop_stats(efx);
 	falcon_deconfigure_mac_wrapper(efx);
 
 	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
@@ -652,7 +652,7 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 
 	efx->mac_op->reconfigure(efx);
 
-	falcon_start_nic_stats(efx);
+	efx->type->start_stats(efx);
 
 	/* Inform kernel of loss/gain of carrier */
 	efx_link_status_changed(efx);
@@ -684,7 +684,7 @@ static void efx_mac_work(struct work_struct *data)
 
 	mutex_lock(&efx->mac_lock);
 	if (efx->port_enabled) {
-		falcon_push_multicast_hash(efx);
+		efx->type->push_multicast_hash(efx);
 		efx->mac_op->reconfigure(efx);
 	}
 	mutex_unlock(&efx->mac_lock);
@@ -696,8 +696,8 @@ static int efx_probe_port(struct efx_nic *efx)
 
 	EFX_LOG(efx, "create port\n");
 
-	/* Connect up MAC/PHY operations table and read MAC address */
-	rc = falcon_probe_port(efx);
+	/* Connect up MAC/PHY operations table */
+	rc = efx->type->probe_port(efx);
 	if (rc)
 		goto err;
 
@@ -765,7 +765,7 @@ static void efx_start_port(struct efx_nic *efx)
 
 	/* efx_mac_work() might have been scheduled after efx_stop_port(),
 	 * and then cancelled by efx_flush_all() */
-	falcon_push_multicast_hash(efx);
+	efx->type->push_multicast_hash(efx);
 	efx->mac_op->reconfigure(efx);
 
 	mutex_unlock(&efx->mac_lock);
@@ -805,7 +805,7 @@ static void efx_remove_port(struct efx_nic *efx)
 {
 	EFX_LOG(efx, "destroying port\n");
 
-	falcon_remove_port(efx);
+	efx->type->remove_port(efx);
 }
 
 /**************************************************************************
@@ -1042,7 +1042,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 	EFX_LOG(efx, "creating NIC\n");
 
 	/* Carry out hardware-type specific initialisation */
-	rc = falcon_probe_nic(efx);
+	rc = efx->type->probe(efx);
 	if (rc)
 		return rc;
 
@@ -1063,7 +1063,7 @@ static void efx_remove_nic(struct efx_nic *efx)
 	EFX_LOG(efx, "destroying NIC\n");
 
 	efx_remove_interrupts(efx);
-	falcon_remove_nic(efx);
+	efx->type->remove(efx);
 }
 
 /**************************************************************************
@@ -1145,12 +1145,12 @@ static void efx_start_all(struct efx_nic *efx)
 
 	falcon_enable_interrupts(efx);
 
-	/* Start hardware monitor if we're in RUNNING */
-	if (efx->state == STATE_RUNNING)
+	/* Start the hardware monitor (if there is one) if we're in RUNNING */
+	if (efx->state == STATE_RUNNING && efx->type->monitor != NULL)
 		queue_delayed_work(efx->workqueue, &efx->monitor_work,
 				   efx_monitor_interval);
 
-	falcon_start_nic_stats(efx);
+	efx->type->start_stats(efx);
 }
 
 /* Flush all delayed work. Should only be called when no more delayed work
@@ -1186,7 +1186,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	if (!efx->port_enabled)
 		return;
 
-	falcon_stop_nic_stats(efx);
+	efx->type->stop_stats(efx);
 
 	/* Disable interrupts and wait for ISR to complete */
 	falcon_disable_interrupts(efx);
@@ -1284,6 +1284,7 @@ static void efx_monitor(struct work_struct *data)
 
 	EFX_TRACE(efx, "hardware monitor executing on CPU %d\n",
 		  raw_smp_processor_id());
+	BUG_ON(efx->type->monitor == NULL);
 
 	/* If the mac_lock is already held then it is likely a port
 	 * reconfiguration is already in place, which will likely do
@@ -1292,7 +1293,7 @@ static void efx_monitor(struct work_struct *data)
 		goto out_requeue;
 	if (!efx->port_enabled)
 		goto out_unlock;
-	falcon_monitor(efx);
+	efx->type->monitor(efx);
 
 out_unlock:
 	mutex_unlock(&efx->mac_lock);
@@ -1430,7 +1431,7 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	struct net_device_stats *stats = &net_dev->stats;
 
 	spin_lock_bh(&efx->stats_lock);
-	falcon_update_nic_stats(efx);
+	efx->type->update_stats(efx);
 	spin_unlock_bh(&efx->stats_lock);
 
 	stats->rx_packets = mac_stats->rx_packets;
@@ -1695,6 +1696,7 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method,
 	efx_fini_channels(efx);
 	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
 		efx->phy_op->fini(efx);
+	efx->type->fini(efx);
 }
 
 /* This function will always ensure that the locks acquired in
@@ -1709,7 +1711,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method,
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	rc = falcon_init_nic(efx);
+	rc = efx->type->init(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise NIC\n");
 		ok = false;
@@ -1769,7 +1771,7 @@ static int efx_reset(struct efx_nic *efx)
 
 	efx_reset_down(efx, method, &ecmd);
 
-	rc = falcon_reset_hw(efx, method);
+	rc = efx->type->reset(efx, method);
 	if (rc) {
 		EFX_ERR(efx, "failed to reset hardware\n");
 		goto out_disable;
@@ -2005,6 +2007,7 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	falcon_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
+	efx->type->fini(efx);
 	efx_fini_napi(efx);
 	efx_remove_all(efx);
 }
@@ -2064,7 +2067,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
 
-	rc = falcon_init_nic(efx);
+	rc = efx->type->init(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise NIC\n");
 		goto fail3;
@@ -2088,6 +2091,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
  fail4:
+	efx->type->fini(efx);
  fail3:
 	efx_fini_napi(efx);
  fail2:
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index d3da360..49e0aed 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -649,7 +649,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 
 	efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive);
 	efx_for_each_channel(channel, efx)
-		falcon_set_int_moderation(channel);
+		efx->type->push_irq_moderation(channel);
 
 	return 0;
 }
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 040f553..f6d1021 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1041,7 +1041,7 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 	return rx_packets;
 }
 
-void falcon_set_int_moderation(struct efx_channel *channel)
+static void falcon_push_irq_moderation(struct efx_channel *channel)
 {
 	efx_dword_t timer_cmd;
 	struct efx_nic *efx = channel->efx;
@@ -1098,7 +1098,7 @@ void falcon_init_eventq(struct efx_channel *channel)
 	efx_writeo_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
 
-	falcon_set_int_moderation(channel);
+	falcon_push_irq_moderation(channel);
 }
 
 void falcon_fini_eventq(struct efx_channel *channel)
@@ -1212,7 +1212,8 @@ int falcon_flush_queues(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	int i, tx_pending, rx_pending;
 
-	falcon_prepare_flush(efx);
+	/* If necessary prepare the hardware for flushing */
+	efx->type->prepare_flush(efx);
 
 	/* Flush all tx queues in parallel */
 	efx_for_each_tx_queue(tx_queue, efx)
@@ -1825,6 +1826,16 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
  **************************************************************************
  */
 
+static void falcon_push_multicast_hash(struct efx_nic *efx)
+{
+	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	efx_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
+	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
+}
+
 static int falcon_reset_macs(struct efx_nic *efx)
 {
 	efx_oword_t reg;
@@ -2240,7 +2251,7 @@ out:
 }
 
 /* This call is responsible for hooking in the MAC and PHY operations */
-int falcon_probe_port(struct efx_nic *efx)
+static int falcon_probe_port(struct efx_nic *efx)
 {
 	int rc;
 
@@ -2299,31 +2310,13 @@ int falcon_probe_port(struct efx_nic *efx)
 	return 0;
 }
 
-void falcon_remove_port(struct efx_nic *efx)
+static void falcon_remove_port(struct efx_nic *efx)
 {
 	falcon_free_buffer(efx, &efx->stats_buffer);
 }
 
 /**************************************************************************
  *
- * Multicast filtering
- *
- **************************************************************************
- */
-
-void falcon_push_multicast_hash(struct efx_nic *efx)
-{
-	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-
-	efx_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
-	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
-}
-
-
-/**************************************************************************
- *
  * Falcon test code
  *
  **************************************************************************/
@@ -2503,7 +2496,7 @@ fail:
 
 /* Resets NIC to known state.  This routine must be called in process
  * context and is allowed to sleep. */
-int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
+static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t glb_ctl_reg_ker;
@@ -2592,7 +2585,7 @@ fail5:
 	return rc;
 }
 
-void falcon_monitor(struct efx_nic *efx)
+static void falcon_monitor(struct efx_nic *efx)
 {
 	bool link_changed;
 	int rc;
@@ -2850,7 +2843,7 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 				       large_eeprom_type);
 }
 
-int falcon_probe_nic(struct efx_nic *efx)
+static int falcon_probe_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data;
 	struct falcon_board *board;
@@ -3006,7 +2999,7 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
  * defining the descriptor cache sizes and number of RSS channels.
  * It does not set up any buffers, descriptor rings or event queues.
  */
-int falcon_init_nic(struct efx_nic *efx)
+static int falcon_init_nic(struct efx_nic *efx)
 {
 	efx_oword_t temp;
 	int rc;
@@ -3139,7 +3132,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	return 0;
 }
 
-void falcon_remove_nic(struct efx_nic *efx)
+static void falcon_remove_nic(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	struct falcon_board *board = falcon_board(efx);
@@ -3168,7 +3161,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 	efx->nic_data = NULL;
 }
 
-void falcon_update_nic_stats(struct efx_nic *efx)
+static void falcon_update_nic_stats(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t cnt;
@@ -3232,6 +3225,20 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
  */
 
 struct efx_nic_type falcon_a1_nic_type = {
+	.probe = falcon_probe_nic,
+	.remove = falcon_remove_nic,
+	.init = falcon_init_nic,
+	.fini = efx_port_dummy_op_void,
+	.monitor = falcon_monitor,
+	.reset = falcon_reset_hw,
+	.probe_port = falcon_probe_port,
+	.remove_port = falcon_remove_port,
+	.prepare_flush = falcon_prepare_flush,
+	.update_stats = falcon_update_nic_stats,
+	.start_stats = falcon_start_nic_stats,
+	.stop_stats = falcon_stop_nic_stats,
+	.push_irq_moderation = falcon_push_irq_moderation,
+	.push_multicast_hash = falcon_push_multicast_hash,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_A1,
@@ -3250,6 +3257,20 @@ struct efx_nic_type falcon_a1_nic_type = {
 };
 
 struct efx_nic_type falcon_b0_nic_type = {
+	.probe = falcon_probe_nic,
+	.remove = falcon_remove_nic,
+	.init = falcon_init_nic,
+	.fini = efx_port_dummy_op_void,
+	.monitor = falcon_monitor,
+	.reset = falcon_reset_hw,
+	.probe_port = falcon_probe_port,
+	.remove_port = falcon_remove_port,
+	.prepare_flush = falcon_prepare_flush,
+	.update_stats = falcon_update_nic_stats,
+	.start_stats = falcon_start_nic_stats,
+	.stop_stats = falcon_stop_nic_stats,
+	.push_irq_moderation = falcon_push_irq_moderation,
+	.push_multicast_hash = falcon_push_multicast_hash,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 81196a0..3fe6484 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -129,10 +129,6 @@ extern void falcon_remove_eventq(struct efx_channel *channel);
 extern int falcon_process_eventq(struct efx_channel *channel, int rx_quota);
 extern void falcon_eventq_read_ack(struct efx_channel *channel);
 
-/* Ports */
-extern int falcon_probe_port(struct efx_nic *efx);
-extern void falcon_remove_port(struct efx_nic *efx);
-
 /* MAC/PHY */
 extern int falcon_switch_mac(struct efx_nic *efx);
 extern bool falcon_xaui_link_ok(struct efx_nic *efx);
@@ -146,23 +142,15 @@ extern void falcon_enable_interrupts(struct efx_nic *efx);
 extern void falcon_generate_test_event(struct efx_channel *channel,
 				       unsigned int magic);
 extern void falcon_generate_interrupt(struct efx_nic *efx);
-extern void falcon_set_int_moderation(struct efx_channel *channel);
 extern void falcon_disable_interrupts(struct efx_nic *efx);
 extern void falcon_fini_interrupt(struct efx_nic *efx);
 
 #define FALCON_IRQ_MOD_RESOLUTION 5
 
 /* Global Resources */
-extern int falcon_probe_nic(struct efx_nic *efx);
-extern int falcon_init_nic(struct efx_nic *efx);
 extern int falcon_flush_queues(struct efx_nic *efx);
-extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
-extern void falcon_monitor(struct efx_nic *efx);
-extern void falcon_remove_nic(struct efx_nic *efx);
-extern void falcon_update_nic_stats(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
-extern void falcon_push_multicast_hash(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
 
 /* Tests */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index fddf8f5..32806f9 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -843,6 +843,21 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 
 /**
  * struct efx_nic_type - Efx device type definition
+ * @probe: Probe the controller
+ * @remove: Free resources allocated by probe()
+ * @init: Initialise the controller
+ * @fini: Shut down the controller
+ * @monitor: Periodic function for polling link state and hardware monitor
+ * @reset: Reset the controller hardware and possibly the PHY.  This will
+ *	be called while the controller is uninitialised.
+ * @probe_port: Probe the MAC and PHY
+ * @remove_port: Free resources allocated by probe_port()
+ * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ * @update_stats: Update statistics not provided by event handling
+ * @start_stats: Start the regular fetching of statistics
+ * @stop_stats: Stop the regular fetching of statistics
+ * @push_irq_moderation: Apply interrupt moderation value
+ * @push_multicast_hash: Apply multicast hash table
  * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -861,6 +876,20 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
  */
 struct efx_nic_type {
+	int (*probe)(struct efx_nic *efx);
+	void (*remove)(struct efx_nic *efx);
+	int (*init)(struct efx_nic *efx);
+	void (*fini)(struct efx_nic *efx);
+	void (*monitor)(struct efx_nic *efx);
+	int (*reset)(struct efx_nic *efx, enum reset_type method);
+	int (*probe_port)(struct efx_nic *efx);
+	void (*remove_port)(struct efx_nic *efx);
+	void (*prepare_flush)(struct efx_nic *efx);
+	void (*update_stats)(struct efx_nic *efx);
+	void (*start_stats)(struct efx_nic *efx);
+	void (*stop_stats)(struct efx_nic *efx);
+	void (*push_irq_moderation)(struct efx_channel *channel);
+	void (*push_multicast_hash)(struct efx_nic *efx);
 	struct efx_mac_operations *default_mac_ops;
 
 	int revision;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 74e84af..15d4d9c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -719,7 +719,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 		rc_test = rc;
 
 	/* reset the chip to recover from the register test */
-	rc_reset = falcon_reset_hw(efx, reset_method);
+	rc_reset = efx->type->reset(efx, reset_method);
 
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

