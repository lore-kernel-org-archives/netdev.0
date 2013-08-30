From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: Allow event queue initialisation to fail
Date: Fri, 30 Aug 2013 04:39:58 +0100
Message-ID: <1377833998.2552.32.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34987 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab3H3DkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:40:03 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

On EF10, event queue initialisation requires an MCDI request which
may return failure.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |  111 ++++++++++++++++++++++++++-------
 drivers/net/ethernet/sfc/farch.c      |    4 +-
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 drivers/net/ethernet/sfc/nic.h        |    6 +-
 4 files changed, 95 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 69150fa..84c47d3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -189,7 +189,7 @@ MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
  *
  *************************************************************************/
 
-static void efx_soft_enable_interrupts(struct efx_nic *efx);
+static int efx_soft_enable_interrupts(struct efx_nic *efx);
 static void efx_soft_disable_interrupts(struct efx_nic *efx);
 static void efx_remove_channel(struct efx_channel *channel);
 static void efx_remove_channels(struct efx_nic *efx);
@@ -329,15 +329,21 @@ static int efx_probe_eventq(struct efx_channel *channel)
 }
 
 /* Prepare channel's event queue */
-static void efx_init_eventq(struct efx_channel *channel)
+static int efx_init_eventq(struct efx_channel *channel)
 {
+	int rc;
+
+	EFX_WARN_ON_PARANOID(channel->eventq_init);
+
 	netif_dbg(channel->efx, drv, channel->efx->net_dev,
 		  "chan %d init event queue\n", channel->channel);
 
-	channel->eventq_read_ptr = 0;
-
-	efx_nic_init_eventq(channel);
-	channel->eventq_init = true;
+	rc = efx_nic_init_eventq(channel);
+	if (rc == 0) {
+		channel->eventq_read_ptr = 0;
+		channel->eventq_init = true;
+	}
+	return rc;
 }
 
 /* Enable event queue processing and NAPI */
@@ -722,7 +728,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	struct efx_channel *other_channel[EFX_MAX_CHANNELS], *channel;
 	u32 old_rxq_entries, old_txq_entries;
 	unsigned i, next_buffer_table = 0;
-	int rc;
+	int rc, rc2;
 
 	rc = efx_check_disabled(efx);
 	if (rc)
@@ -802,9 +808,16 @@ out:
 		}
 	}
 
-	efx_soft_enable_interrupts(efx);
-	efx_start_all(efx);
-	netif_device_attach(efx->net_dev);
+	rc2 = efx_soft_enable_interrupts(efx);
+	if (rc2) {
+		rc = rc ? rc : rc2;
+		netif_err(efx, drv, efx->net_dev,
+			  "unable to restart interrupts on channel reallocation\n");
+		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+	} else {
+		efx_start_all(efx);
+		netif_device_attach(efx->net_dev);
+	}
 	return rc;
 
 rollback:
@@ -1327,9 +1340,10 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	return 0;
 }
 
-static void efx_soft_enable_interrupts(struct efx_nic *efx)
+static int efx_soft_enable_interrupts(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
+	struct efx_channel *channel, *end_channel;
+	int rc;
 
 	BUG_ON(efx->state == STATE_DISABLED);
 
@@ -1337,12 +1351,28 @@ static void efx_soft_enable_interrupts(struct efx_nic *efx)
 	smp_wmb();
 
 	efx_for_each_channel(channel, efx) {
-		if (!channel->type->keep_eventq)
-			efx_init_eventq(channel);
+		if (!channel->type->keep_eventq) {
+			rc = efx_init_eventq(channel);
+			if (rc)
+				goto fail;
+		}
 		efx_start_eventq(channel);
 	}
 
 	efx_mcdi_mode_event(efx);
+
+	return 0;
+fail:
+	end_channel = channel;
+	efx_for_each_channel(channel, efx) {
+		if (channel == end_channel)
+			break;
+		efx_stop_eventq(channel);
+		if (!channel->type->keep_eventq)
+			efx_fini_eventq(channel);
+	}
+
+	return rc;
 }
 
 static void efx_soft_disable_interrupts(struct efx_nic *efx)
@@ -1373,9 +1403,10 @@ static void efx_soft_disable_interrupts(struct efx_nic *efx)
 	efx_mcdi_flush_async(efx);
 }
 
-static void efx_enable_interrupts(struct efx_nic *efx)
+static int efx_enable_interrupts(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
+	struct efx_channel *channel, *end_channel;
+	int rc;
 
 	BUG_ON(efx->state == STATE_DISABLED);
 
@@ -1387,11 +1418,31 @@ static void efx_enable_interrupts(struct efx_nic *efx)
 	efx->type->irq_enable_master(efx);
 
 	efx_for_each_channel(channel, efx) {
+		if (channel->type->keep_eventq) {
+			rc = efx_init_eventq(channel);
+			if (rc)
+				goto fail;
+		}
+	}
+
+	rc = efx_soft_enable_interrupts(efx);
+	if (rc)
+		goto fail;
+
+	return 0;
+
+fail:
+	end_channel = channel;
+	efx_for_each_channel(channel, efx) {
+		if (channel == end_channel)
+			break;
 		if (channel->type->keep_eventq)
-			efx_init_eventq(channel);
+			efx_fini_eventq(channel);
 	}
 
-	efx_soft_enable_interrupts(efx);
+	efx->type->irq_disable_non_ev(efx);
+
+	return rc;
 }
 
 static void efx_disable_interrupts(struct efx_nic *efx)
@@ -2205,7 +2256,9 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 				  "could not restore PHY settings\n");
 	}
 
-	efx_enable_interrupts(efx);
+	rc = efx_enable_interrupts(efx);
+	if (rc)
+		goto fail;
 	efx_restore_filters(efx);
 	efx_sriov_reset(efx);
 
@@ -2649,10 +2702,14 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	rc = efx_nic_init_interrupt(efx);
 	if (rc)
 		goto fail5;
-	efx_enable_interrupts(efx);
+	rc = efx_enable_interrupts(efx);
+	if (rc)
+		goto fail6;
 
 	return 0;
 
+ fail6:
+	efx_nic_fini_interrupt(efx);
  fail5:
 	efx_fini_port(efx);
  fail4:
@@ -2780,12 +2837,15 @@ static int efx_pm_freeze(struct device *dev)
 
 static int efx_pm_thaw(struct device *dev)
 {
+	int rc;
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 
 	rtnl_lock();
 
 	if (efx->state != STATE_DISABLED) {
-		efx_enable_interrupts(efx);
+		rc = efx_enable_interrupts(efx);
+		if (rc)
+			goto fail;
 
 		mutex_lock(&efx->mac_lock);
 		efx->phy_op->reconfigure(efx);
@@ -2806,6 +2866,11 @@ static int efx_pm_thaw(struct device *dev)
 	queue_work(reset_workqueue, &efx->reset_work);
 
 	return 0;
+
+fail:
+	rtnl_unlock();
+
+	return rc;
 }
 
 static int efx_pm_poweroff(struct device *dev)
@@ -2842,8 +2907,8 @@ static int efx_pm_resume(struct device *dev)
 	rc = efx->type->init(efx);
 	if (rc)
 		return rc;
-	efx_pm_thaw(dev);
-	return 0;
+	rc = efx_pm_thaw(dev);
+	return rc;
 }
 
 static int efx_pm_suspend(struct device *dev)
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index d21483d..904af5c 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1325,7 +1325,7 @@ int efx_farch_ev_probe(struct efx_channel *channel)
 					entries * sizeof(efx_qword_t));
 }
 
-void efx_farch_ev_init(struct efx_channel *channel)
+int efx_farch_ev_init(struct efx_channel *channel)
 {
 	efx_oword_t reg;
 	struct efx_nic *efx = channel->efx;
@@ -1358,6 +1358,8 @@ void efx_farch_ev_init(struct efx_channel *channel)
 			 channel->channel);
 
 	efx->type->push_irq_moderation(channel);
+
+	return 0;
 }
 
 void efx_farch_ev_fini(struct efx_channel *channel)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index e85bed0..54900f3 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1087,7 +1087,7 @@ struct efx_nic_type {
 	void (*rx_write)(struct efx_rx_queue *rx_queue);
 	void (*rx_defer_refill)(struct efx_rx_queue *rx_queue);
 	int (*ev_probe)(struct efx_channel *channel);
-	void (*ev_init)(struct efx_channel *channel);
+	int (*ev_init)(struct efx_channel *channel);
 	void (*ev_fini)(struct efx_channel *channel);
 	void (*ev_remove)(struct efx_channel *channel);
 	int (*ev_process)(struct efx_channel *channel, int quota);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 9afbf36..686ce7a 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -503,9 +503,9 @@ static inline int efx_nic_probe_eventq(struct efx_channel *channel)
 {
 	return channel->efx->type->ev_probe(channel);
 }
-static inline void efx_nic_init_eventq(struct efx_channel *channel)
+static inline int efx_nic_init_eventq(struct efx_channel *channel)
 {
-	channel->efx->type->ev_init(channel);
+	return channel->efx->type->ev_init(channel);
 }
 static inline void efx_nic_fini_eventq(struct efx_channel *channel)
 {
@@ -539,7 +539,7 @@ extern void efx_farch_rx_remove(struct efx_rx_queue *rx_queue);
 extern void efx_farch_rx_write(struct efx_rx_queue *rx_queue);
 extern void efx_farch_rx_defer_refill(struct efx_rx_queue *rx_queue);
 extern int efx_farch_ev_probe(struct efx_channel *channel);
-extern void efx_farch_ev_init(struct efx_channel *channel);
+extern int efx_farch_ev_init(struct efx_channel *channel);
 extern void efx_farch_ev_fini(struct efx_channel *channel);
 extern void efx_farch_ev_remove(struct efx_channel *channel);
 extern int efx_farch_ev_process(struct efx_channel *channel, int quota);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
