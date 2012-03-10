From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/10] sfc: Run event/IRQ self-test asynchronously
 when interface is brought up
Date: Sat, 10 Mar 2012 00:51:55 +0000
Message-ID: <1331340715.2537.18.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51291 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755217Ab2CJAv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:51:58 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generate a test event on each event queue whenever the interface is
brought up, then after 1 second check that we have either handled a
test event or handled another IRQ for each event queue.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    6 ++++-
 drivers/net/ethernet/sfc/efx.h        |    2 +-
 drivers/net/ethernet/sfc/net_driver.h |    6 +++-
 drivers/net/ethernet/sfc/nic.c        |    4 +-
 drivers/net/ethernet/sfc/nic.h        |    2 +-
 drivers/net/ethernet/sfc/selftest.c   |   35 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/selftest.h   |    3 ++
 7 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 00e13ab..7683e53 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -25,6 +25,7 @@
 #include "net_driver.h"
 #include "efx.h"
 #include "nic.h"
+#include "selftest.h"
 
 #include "mcdi.h"
 #include "workarounds.h"
@@ -1564,8 +1565,9 @@ static void efx_start_all(struct efx_nic *efx)
  * since we're holding the rtnl_lock at this point. */
 static void efx_flush_all(struct efx_nic *efx)
 {
-	/* Make sure the hardware monitor is stopped */
+	/* Make sure the hardware monitor and event self-test are stopped */
 	cancel_delayed_work_sync(&efx->monitor_work);
+	efx_selftest_async_cancel(efx);
 	/* Stop scheduled port reconfigurations */
 	cancel_work_sync(&efx->mac_work);
 }
@@ -1825,6 +1827,7 @@ static int efx_net_open(struct net_device *net_dev)
 	efx_link_status_changed(efx);
 
 	efx_start_all(efx);
+	efx_selftest_async_start(efx);
 	return 0;
 }
 
@@ -2375,6 +2378,7 @@ static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 #endif
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
+	INIT_DELAYED_WORK(&efx->selftest_work, efx_selftest_async_work);
 	efx->pci_dev = pci_dev;
 	efx->msg_enable = debug;
 	efx->state = STATE_INIT;
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 4debfe0..be8f915 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -148,7 +148,7 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 
 static inline void efx_schedule_channel_irq(struct efx_channel *channel)
 {
-	channel->last_irq_cpu = raw_smp_processor_id();
+	channel->event_test_cpu = raw_smp_processor_id();
 	efx_schedule_channel(channel);
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0b95505..27fe85f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -325,7 +325,7 @@ enum efx_rx_alloc_method {
  * @eventq_mask: Event queue pointer mask
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
- * @last_irq_cpu: Last CPU to handle interrupt for this channel
+ * @event_test_cpu: Last CPU to handle interrupt or test event for this channel
  * @irq_count: Number of IRQs since last adaptive moderation decision
  * @irq_mod_score: IRQ moderation score
  * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
@@ -356,8 +356,8 @@ struct efx_channel {
 	unsigned int eventq_mask;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
+	int event_test_cpu;
 
-	int last_irq_cpu;
 	unsigned int irq_count;
 	unsigned int irq_mod_score;
 #ifdef CONFIG_RFS_ACCEL
@@ -678,6 +678,7 @@ struct vfdi_status;
  * @irq_status: Interrupt status buffer
  * @irq_zero_count: Number of legacy IRQs seen with queue flags == 0
  * @irq_level: IRQ level/index for IRQs not triggered by an event queue
+ * @selftest_work: Work item for asynchronous self-test
  * @mtd_list: List of MTDs attached to the NIC
  * @nic_data: Hardware dependent state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
@@ -791,6 +792,7 @@ struct efx_nic {
 	struct efx_buffer irq_status;
 	unsigned irq_zero_count;
 	unsigned irq_level;
+	struct delayed_work selftest_work;
 
 #ifdef CONFIG_SFC_MTD
 	struct list_head mtd_list;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 4c47b75..4a9a5be 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1083,7 +1083,7 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 	code = _EFX_CHANNEL_MAGIC_CODE(magic);
 
 	if (magic == EFX_CHANNEL_MAGIC_TEST(channel)) {
-		/* ignore */
+		channel->event_test_cpu = raw_smp_processor_id();
 	} else if (rx_queue && magic == EFX_CHANNEL_MAGIC_FILL(rx_queue)) {
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
@@ -1334,7 +1334,7 @@ void efx_nic_remove_eventq(struct efx_channel *channel)
 
 void efx_nic_event_test_start(struct efx_channel *channel)
 {
-	channel->last_irq_cpu = -1;
+	channel->event_test_cpu = -1;
 	smp_wmb();
 	efx_magic_event(channel, EFX_CHANNEL_MAGIC_TEST(channel));
 }
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index e0e8596..f46e2ce 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -311,7 +311,7 @@ extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
 static inline int efx_nic_event_test_irq_cpu(struct efx_channel *channel)
 {
-	return ACCESS_ONCE(channel->last_irq_cpu);
+	return ACCESS_ONCE(channel->event_test_cpu);
 }
 static inline int efx_nic_irq_test_irq_cpu(struct efx_nic *efx)
 {
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index aa4ab53..de4c006 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -702,6 +702,8 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
 	int rc_test = 0, rc_reset = 0, rc;
 
+	efx_selftest_async_cancel(efx);
+
 	/* Online (i.e. non-disruptive) testing
 	 * This checks interrupt generation, event delivery and PHY presence. */
 
@@ -794,3 +796,36 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	return rc_test;
 }
 
+void efx_selftest_async_start(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+
+	efx_for_each_channel(channel, efx)
+		efx_nic_event_test_start(channel);
+	schedule_delayed_work(&efx->selftest_work, IRQ_TIMEOUT);
+}
+
+void efx_selftest_async_cancel(struct efx_nic *efx)
+{
+	cancel_delayed_work_sync(&efx->selftest_work);
+}
+
+void efx_selftest_async_work(struct work_struct *data)
+{
+	struct efx_nic *efx = container_of(data, struct efx_nic,
+					   selftest_work.work);
+	struct efx_channel *channel;
+	int cpu;
+
+	efx_for_each_channel(channel, efx) {
+		cpu = efx_nic_event_test_irq_cpu(channel);
+		if (cpu < 0)
+			netif_err(efx, ifup, efx->net_dev,
+				  "channel %d failed to trigger an interrupt\n",
+				  channel->channel);
+		else
+			netif_dbg(efx, ifup, efx->net_dev,
+				  "channel %d triggered interrupt on CPU %d\n",
+				  channel->channel, cpu);
+	}
+}
diff --git a/drivers/net/ethernet/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
index 87abe2a..aed24b7 100644
--- a/drivers/net/ethernet/sfc/selftest.h
+++ b/drivers/net/ethernet/sfc/selftest.h
@@ -48,5 +48,8 @@ extern void efx_loopback_rx_packet(struct efx_nic *efx,
 extern int efx_selftest(struct efx_nic *efx,
 			struct efx_self_tests *tests,
 			unsigned flags);
+extern void efx_selftest_async_start(struct efx_nic *efx);
+extern void efx_selftest_async_cancel(struct efx_nic *efx);
+extern void efx_selftest_async_work(struct work_struct *data);
 
 #endif /* EFX_SELFTEST_H */
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
