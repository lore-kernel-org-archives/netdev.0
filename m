From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/13] sfc: Really disable flow control while
 flushing
Date: Sat, 1 Dec 2012 04:41:57 +0000
Message-ID: <1354336917.2640.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55613 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab2LAEmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:42:00 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Receiving pause frames can block TX queue flushes.  Earlier changes
work around this by reconfiguring the MAC during flushes for VFs, but
during flushes for the PF we would only change the fc_disable counter.
Unless the MAC is reconfigured for some other reason during the flush
(which I would not expect to happen) this had no effect at all.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c      |    2 ++
 drivers/net/ethernet/sfc/net_driver.h  |    2 ++
 drivers/net/ethernet/sfc/nic.c         |    3 +--
 drivers/net/ethernet/sfc/nic.h         |    2 ++
 drivers/net/ethernet/sfc/siena.c       |   15 ++++++++++++++-
 drivers/net/ethernet/sfc/siena_sriov.c |    6 ++----
 6 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 12b573a..49bcd19 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1792,6 +1792,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
@@ -1834,6 +1835,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 2487f58..1014556 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -907,6 +907,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @remove_port: Free resources allocated by probe_port()
  * @handle_global_event: Handle a "global" event (may be %NULL)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ * @finish_flush: Clean up after flushing the DMA queues
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
@@ -954,6 +955,7 @@ struct efx_nic_type {
 	void (*remove_port)(struct efx_nic *efx);
 	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
 	void (*prepare_flush)(struct efx_nic *efx);
+	void (*finish_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index aab7cac..e10b7ec 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -680,7 +680,6 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
-	efx->fc_disable++;
 	efx->type->prepare_flush(efx);
 
 	efx_for_each_channel(channel, efx) {
@@ -742,7 +741,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		atomic_set(&efx->rxq_flush_outstanding, 0);
 	}
 
-	efx->fc_disable--;
+	efx->type->finish_flush(efx);
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 7a9647a..1b00033 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -344,6 +344,8 @@ static inline int efx_nic_irq_test_irq_cpu(struct efx_nic *efx)
 
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
+extern void siena_prepare_flush(struct efx_nic *efx);
+extern void siena_finish_flush(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 84b41bf..3553d77 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -127,6 +127,18 @@ static void siena_remove_port(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
+void siena_prepare_flush(struct efx_nic *efx)
+{
+	if (efx->fc_disable++ == 0)
+		efx_mcdi_set_mac(efx);
+}
+
+void siena_finish_flush(struct efx_nic *efx)
+{
+	if (--efx->fc_disable == 0)
+		efx_mcdi_set_mac(efx);
+}
+
 static const struct efx_nic_register_test siena_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
@@ -659,7 +671,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.reset = siena_reset_hw,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
-	.prepare_flush = efx_port_dummy_op_void,
+	.prepare_flush = siena_prepare_flush,
+	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
 	.start_stats = siena_start_nic_stats,
 	.stop_stats = siena_stop_nic_stats,
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index d49b53d..6e62a018 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -695,8 +695,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 		return VFDI_RC_ENOMEM;
 
 	rtnl_lock();
-	if (efx->fc_disable++ == 0)
-		efx_mcdi_set_mac(efx);
+	siena_prepare_flush(efx);
 	rtnl_unlock();
 
 	/* Flush all the initialized queues */
@@ -733,8 +732,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 	}
 
 	rtnl_lock();
-	if (--efx->fc_disable == 0)
-		efx_mcdi_set_mac(efx);
+	siena_finish_flush(efx);
 	rtnl_unlock();
 
 	/* Irrespective of success/failure, fini the queues */
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
