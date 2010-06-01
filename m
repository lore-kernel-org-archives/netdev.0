From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/12] sfc: Remove efx_rx_queue::add_lock
Date: Tue, 01 Jun 2010 22:19:39 +0100
Message-ID: <1275427179.2114.32.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50686 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757267Ab0FAVTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:19:42 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Ensure that efx_fast_push_rx_descriptors() must only run
from efx_process_channel() [NAPI], or when napi_disable()
has been executed.

Reimplement the slow fill by sending an event to the
channel, so that NAPI runs, and hanging the subsequent
fast fill off the event handler. Replace the sfc_refill
workqueue and delayed work items with a timer. We do
not need to stop this timer in efx_flush_all() because
it's safe to send the event always; receiving it will
be delayed until NAPI is restarted.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   44 +++----------------
 drivers/net/sfc/efx.h        |    4 +-
 drivers/net/sfc/net_driver.h |   10 +---
 drivers/net/sfc/nic.c        |   49 +++++++++++++++++----
 drivers/net/sfc/nic.h        |    1 +
 drivers/net/sfc/rx.c         |   95 +++++++++--------------------------------
 6 files changed, 73 insertions(+), 130 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d1a1d32..5d9ef05 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -93,13 +93,6 @@ const char *efx_reset_type_names[] = {
 
 #define EFX_MAX_MTU (9 * 1024)
 
-/* RX slow fill workqueue. If memory allocation fails in the fast path,
- * a work item is pushed onto this work queue to retry the allocation later,
- * to avoid the NIC being starved of RX buffers. Since this is a per cpu
- * workqueue, there is nothing to be gained in making it per NIC
- */
-static struct workqueue_struct *refill_workqueue;
-
 /* Reset workqueue. If any NIC has a hardware failure then a reset will be
  * queued onto this work queue. This is not a per-nic work queue, because
  * efx_reset_work() acquires the rtnl lock, so resets are naturally serialised.
@@ -516,11 +509,11 @@ static void efx_start_channel(struct efx_channel *channel)
 	channel->enabled = true;
 	smp_wmb();
 
-	napi_enable(&channel->napi_str);
-
-	/* Load up RX descriptors */
+	/* Fill the queues before enabling NAPI */
 	efx_for_each_channel_rx_queue(rx_queue, channel)
 		efx_fast_push_rx_descriptors(rx_queue);
+
+	napi_enable(&channel->napi_str);
 }
 
 /* This disables event queue processing and packet transmission.
@@ -529,8 +522,6 @@ static void efx_start_channel(struct efx_channel *channel)
  */
 static void efx_stop_channel(struct efx_channel *channel)
 {
-	struct efx_rx_queue *rx_queue;
-
 	if (!channel->enabled)
 		return;
 
@@ -538,12 +529,6 @@ static void efx_stop_channel(struct efx_channel *channel)
 
 	channel->enabled = false;
 	napi_disable(&channel->napi_str);
-
-	/* Ensure that any worker threads have exited or will be no-ops */
-	efx_for_each_channel_rx_queue(rx_queue, channel) {
-		spin_lock_bh(&rx_queue->add_lock);
-		spin_unlock_bh(&rx_queue->add_lock);
-	}
 }
 
 static void efx_fini_channels(struct efx_nic *efx)
@@ -595,9 +580,9 @@ static void efx_remove_channel(struct efx_channel *channel)
 	efx_remove_eventq(channel);
 }
 
-void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay)
+void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue)
 {
-	queue_delayed_work(refill_workqueue, &rx_queue->work, delay);
+	mod_timer(&rx_queue->slow_fill, jiffies + msecs_to_jiffies(100));
 }
 
 /**************************************************************************
@@ -1242,15 +1227,8 @@ static void efx_start_all(struct efx_nic *efx)
  * since we're holding the rtnl_lock at this point. */
 static void efx_flush_all(struct efx_nic *efx)
 {
-	struct efx_rx_queue *rx_queue;
-
 	/* Make sure the hardware monitor is stopped */
 	cancel_delayed_work_sync(&efx->monitor_work);
-
-	/* Ensure that all RX slow refills are complete. */
-	efx_for_each_rx_queue(rx_queue, efx)
-		cancel_delayed_work_sync(&rx_queue->work);
-
 	/* Stop scheduled port reconfigurations */
 	cancel_work_sync(&efx->mac_work);
 }
@@ -2064,8 +2042,8 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		rx_queue->queue = i;
 		rx_queue->channel = &efx->channel[0]; /* for safety */
 		rx_queue->buffer = NULL;
-		spin_lock_init(&rx_queue->add_lock);
-		INIT_DELAYED_WORK(&rx_queue->work, efx_rx_work);
+		setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
+			    (unsigned long)rx_queue);
 	}
 
 	efx->type = type;
@@ -2436,11 +2414,6 @@ static int __init efx_init_module(void)
 	if (rc)
 		goto err_notifier;
 
-	refill_workqueue = create_workqueue("sfc_refill");
-	if (!refill_workqueue) {
-		rc = -ENOMEM;
-		goto err_refill;
-	}
 	reset_workqueue = create_singlethread_workqueue("sfc_reset");
 	if (!reset_workqueue) {
 		rc = -ENOMEM;
@@ -2456,8 +2429,6 @@ static int __init efx_init_module(void)
  err_pci:
 	destroy_workqueue(reset_workqueue);
  err_reset:
-	destroy_workqueue(refill_workqueue);
- err_refill:
 	unregister_netdevice_notifier(&efx_netdev_notifier);
  err_notifier:
 	return rc;
@@ -2469,7 +2440,6 @@ static void __exit efx_exit_module(void)
 
 	pci_unregister_driver(&efx_pci_driver);
 	destroy_workqueue(reset_workqueue);
-	destroy_workqueue(refill_workqueue);
 	unregister_netdevice_notifier(&efx_netdev_notifier);
 
 }
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index ffd708c..e1e4488 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -47,12 +47,12 @@ extern void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 extern void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
 extern void efx_rx_strategy(struct efx_channel *channel);
 extern void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
-extern void efx_rx_work(struct work_struct *data);
+extern void efx_rx_slow_fill(unsigned long context);
 extern void __efx_rx_packet(struct efx_channel *channel,
 			    struct efx_rx_buffer *rx_buf, bool checksummed);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, bool checksummed, bool discard);
-extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
+extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 #define EFX_RXQ_SIZE 1024
 #define EFX_RXQ_MASK (EFX_RXQ_SIZE - 1)
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ee0ea01..4539803 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -18,6 +18,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/timer.h>
 #include <linux/mdio.h>
 #include <linux/list.h>
 #include <linux/pci.h>
@@ -242,10 +243,6 @@ struct efx_rx_buffer {
  * @added_count: Number of buffers added to the receive queue.
  * @notified_count: Number of buffers given to NIC (<= @added_count).
  * @removed_count: Number of buffers removed from the receive queue.
- * @add_lock: Receive queue descriptor add spin lock.
- *	This lock must be held in order to add buffers to the RX
- *	descriptor ring (rxd and buffer) and to update added_count (but
- *	not removed_count).
  * @max_fill: RX descriptor maximum fill level (<= ring size)
  * @fast_fill_trigger: RX descriptor fill level that will trigger a fast fill
  *	(<= @max_fill)
@@ -259,7 +256,7 @@ struct efx_rx_buffer {
  *	overflow was observed.  It should never be set.
  * @alloc_page_count: RX allocation strategy counter.
  * @alloc_skb_count: RX allocation strategy counter.
- * @work: Descriptor push work thread
+ * @slow_fill: Timer used to defer efx_nic_generate_fill_event().
  * @buf_page: Page for next RX buffer.
  *	We can use a single page for multiple RX buffers. This tracks
  *	the remaining space in the allocation.
@@ -277,7 +274,6 @@ struct efx_rx_queue {
 	int added_count;
 	int notified_count;
 	int removed_count;
-	spinlock_t add_lock;
 	unsigned int max_fill;
 	unsigned int fast_fill_trigger;
 	unsigned int fast_fill_limit;
@@ -285,7 +281,7 @@ struct efx_rx_queue {
 	unsigned int min_overfill;
 	unsigned int alloc_page_count;
 	unsigned int alloc_skb_count;
-	struct delayed_work work;
+	struct timer_list slow_fill;
 	unsigned int slow_fill_count;
 
 	struct page *buf_page;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index ca9cf1a..0ee6fd3 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -79,10 +79,14 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Depth of RX flush request fifo */
 #define EFX_RX_FLUSH_COUNT 4
 
-/* Magic value for efx_generate_test_event() */
-#define EFX_CHANNEL_MAGIC(_channel)			\
+/* Generated event code for efx_generate_test_event() */
+#define EFX_CHANNEL_MAGIC_TEST(_channel)	\
 	(0x00010100 + (_channel)->channel)
 
+/* Generated event code for efx_generate_fill_event() */
+#define EFX_CHANNEL_MAGIC_FILL(_channel)	\
+	(0x00010200 + (_channel)->channel)
+
 /**************************************************************************
  *
  * Solarstorm hardware access
@@ -854,6 +858,26 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 		      checksummed, discard);
 }
 
+static void
+efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
+{
+	struct efx_nic *efx = channel->efx;
+	unsigned code;
+
+	code = EFX_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
+	if (code == EFX_CHANNEL_MAGIC_TEST(channel))
+		++channel->magic_count;
+	else if (code == EFX_CHANNEL_MAGIC_FILL(channel))
+		/* The queue must be empty, so we won't receive any rx
+		 * events, so efx_process_channel() won't refill the
+		 * queue. Refill it here */
+		efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
+	else
+		EFX_LOG(efx, "channel %d received generated "
+			"event "EFX_QWORD_FMT"\n", channel->channel,
+			EFX_QWORD_VAL(*event));
+}
+
 /* Global events are basically PHY events */
 static void
 efx_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
@@ -997,13 +1021,7 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 			}
 			break;
 		case FSE_AZ_EV_CODE_DRV_GEN_EV:
-			if (EFX_QWORD_FIELD(event, FSF_AZ_DRV_GEN_EV_MAGIC)
-			    == EFX_CHANNEL_MAGIC(channel))
-				++channel->magic_count;
-
-			EFX_LOG(channel->efx, "channel %d received generated "
-				"event "EFX_QWORD_FMT"\n", channel->channel,
-				EFX_QWORD_VAL(event));
+			efx_handle_generated_event(channel, &event);
 			break;
 		case FSE_AZ_EV_CODE_GLOBAL_EV:
 			efx_handle_global_event(channel, &event);
@@ -1096,7 +1114,18 @@ void efx_nic_remove_eventq(struct efx_channel *channel)
 
 void efx_nic_generate_test_event(struct efx_channel *channel)
 {
-	unsigned int magic = EFX_CHANNEL_MAGIC(channel);
+	unsigned int magic = EFX_CHANNEL_MAGIC_TEST(channel);
+	efx_qword_t test_event;
+
+	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
+			     FSE_AZ_EV_CODE_DRV_GEN_EV,
+			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
+	efx_generate_event(channel, &test_event);
+}
+
+void efx_nic_generate_fill_event(struct efx_channel *channel)
+{
+	unsigned int magic = EFX_CHANNEL_MAGIC_FILL(channel);
 	efx_qword_t test_event;
 
 	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 186aab5..95770e1 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -191,6 +191,7 @@ extern int efx_nic_rx_xoff_thresh, efx_nic_rx_xon_thresh;
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
 extern void efx_nic_enable_interrupts(struct efx_nic *efx);
 extern void efx_nic_generate_test_event(struct efx_channel *channel);
+extern void efx_nic_generate_fill_event(struct efx_channel *channel);
 extern void efx_nic_generate_interrupt(struct efx_nic *efx);
 extern void efx_nic_disable_interrupts(struct efx_nic *efx);
 extern void efx_nic_fini_interrupt(struct efx_nic *efx);
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index e308818..bf1e55e 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -276,28 +276,25 @@ static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 /**
  * efx_fast_push_rx_descriptors - push new RX descriptors quickly
  * @rx_queue:		RX descriptor queue
- * @retry:              Recheck the fill level
  * This will aim to fill the RX descriptor queue up to
  * @rx_queue->@fast_fill_limit. If there is insufficient atomic
- * memory to do so, the caller should retry.
+ * memory to do so, a slow fill will be scheduled.
+ *
+ * The caller must provide serialisation (none is used here). In practise,
+ * this means this function must run from the NAPI handler, or be called
+ * when NAPI is disabled.
  */
-static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
-					  int retry)
+void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 {
 	struct efx_rx_buffer *rx_buf;
 	unsigned fill_level, index;
 	int i, space, rc = 0;
 
-	/* Calculate current fill level.  Do this outside the lock,
-	 * because most of the time we'll end up not wanting to do the
-	 * fill anyway.
-	 */
+	/* Calculate current fill level, and exit if we don't need to fill */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
 	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
-
-	/* Don't fill if we don't need to */
 	if (fill_level >= rx_queue->fast_fill_trigger)
-		return 0;
+		return;
 
 	/* Record minimum fill level */
 	if (unlikely(fill_level < rx_queue->min_fill)) {
@@ -305,20 +302,9 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 			rx_queue->min_fill = fill_level;
 	}
 
-	/* Acquire RX add lock.  If this lock is contended, then a fast
-	 * fill must already be in progress (e.g. in the refill
-	 * tasklet), so we don't need to do anything
-	 */
-	if (!spin_trylock_bh(&rx_queue->add_lock))
-		return -1;
-
- retry:
-	/* Recalculate current fill level now that we have the lock */
-	fill_level = (rx_queue->added_count - rx_queue->removed_count);
-	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
 	space = rx_queue->fast_fill_limit - fill_level;
 	if (space < EFX_RX_BATCH)
-		goto out_unlock;
+		return;
 
 	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filling descriptor ring from"
 		  " level %d to level %d using %s allocation\n",
@@ -330,8 +316,13 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 			index = rx_queue->added_count & EFX_RXQ_MASK;
 			rx_buf = efx_rx_buffer(rx_queue, index);
 			rc = efx_init_rx_buffer(rx_queue, rx_buf);
-			if (unlikely(rc))
+			if (unlikely(rc)) {
+				/* Ensure that we don't leave the rx queue
+				 * empty */
+				if (rx_queue->added_count == rx_queue->removed_count)
+					efx_schedule_slow_fill(rx_queue);
 				goto out;
+			}
 			++rx_queue->added_count;
 		}
 	} while ((space -= EFX_RX_BATCH) >= EFX_RX_BATCH);
@@ -343,61 +334,16 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
  out:
 	/* Send write pointer to card. */
 	efx_nic_notify_rx_desc(rx_queue);
-
-	/* If the fast fill is running inside from the refill tasklet, then
-	 * for SMP systems it may be running on a different CPU to
-	 * RX event processing, which means that the fill level may now be
-	 * out of date. */
-	if (unlikely(retry && (rc == 0)))
-		goto retry;
-
- out_unlock:
-	spin_unlock_bh(&rx_queue->add_lock);
-
-	return rc;
 }
 
-/**
- * efx_fast_push_rx_descriptors - push new RX descriptors quickly
- * @rx_queue:		RX descriptor queue
- *
- * This will aim to fill the RX descriptor queue up to
- * @rx_queue->@fast_fill_limit.  If there is insufficient memory to do so,
- * it will schedule a work item to immediately continue the fast fill
- */
-void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
-{
-	int rc;
-
-	rc = __efx_fast_push_rx_descriptors(rx_queue, 0);
-	if (unlikely(rc)) {
-		/* Schedule the work item to run immediately. The hope is
-		 * that work is immediately pending to free some memory
-		 * (e.g. an RX event or TX completion)
-		 */
-		efx_schedule_slow_fill(rx_queue, 0);
-	}
-}
-
-void efx_rx_work(struct work_struct *data)
+void efx_rx_slow_fill(unsigned long context)
 {
-	struct efx_rx_queue *rx_queue;
-	int rc;
-
-	rx_queue = container_of(data, struct efx_rx_queue, work.work);
-
-	if (unlikely(!rx_queue->channel->enabled))
-		return;
-
-	EFX_TRACE(rx_queue->efx, "RX queue %d worker thread executing on CPU "
-		  "%d\n", rx_queue->queue, raw_smp_processor_id());
+	struct efx_rx_queue *rx_queue = (struct efx_rx_queue *)context;
+	struct efx_channel *channel = rx_queue->channel;
 
+	/* Post an event to cause NAPI to run and refill the queue */
+	efx_nic_generate_fill_event(channel);
 	++rx_queue->slow_fill_count;
-	/* Push new RX descriptors, allowing at least 1 jiffy for
-	 * the kernel to free some more memory. */
-	rc = __efx_fast_push_rx_descriptors(rx_queue, 1);
-	if (rc)
-		efx_schedule_slow_fill(rx_queue, 1);
 }
 
 static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
@@ -682,6 +628,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 
 	EFX_LOG(rx_queue->efx, "shutting down RX queue %d\n", rx_queue->queue);
 
+	del_timer_sync(&rx_queue->slow_fill);
 	efx_nic_fini_rx(rx_queue);
 
 	/* Release RX buffers NB start at index 0 not current HW ptr */
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

