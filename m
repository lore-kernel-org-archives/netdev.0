From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 2/3] sfc: Do not use efx_process_channel_now() in
 online self-test
Date: Wed, 13 Apr 2011 00:50:13 +0100
Message-ID: <1302652213.2880.30.camel@bwh-desktop>
References: <1302652065.2880.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12595 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163Ab1DLXuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:50:16 -0400
In-Reply-To: <1302652065.2880.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During self-tests we use efx_process_channel_now() to handle
completion and other events synchronously.  This disables interrupts
and NAPI processing for the channel in question, but it may still be
interrupted by another channel.  A single socket may receive packets
from multiple net devices or even multiple channels of the same net
device, so this can result in deadlock on a socket lock.

Receiving packets in process context will also result in incorrect
classification by the network cgroup classifier.

Therefore, we must only use efx_process_channel_now() in the offline
loopback tests (which never deliver packets up the stack) and not for
the online interrupt and event tests.

For the interrupt test, there is no reason to process events.  We
only care that an interrupt is raised.

For the event test, we want to know whether events have been received,
and there may be many events ahead of the one we inject.  Therefore
remove efx_channel::magic_count and instead test whether
efx_channel::eventq_read_ptr advances.  This is currently an event
queue index and might wrap around to exactly the same value, resulting
in a false negative.  Therefore move the masking to efx_event() and
efx_nic_eventq_read_ack() so that it cannot wrap within the time of
the test.

The event test also tries to diagnose failures by checking whether an
event was delivered without causing an interrupt.  Add and use a
helper function that only does this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    4 +++-
 drivers/net/sfc/net_driver.h |    2 --
 drivers/net/sfc/nic.c        |   22 +++++++++++++++-------
 drivers/net/sfc/nic.h        |    1 +
 drivers/net/sfc/selftest.c   |   23 ++++-------------------
 5 files changed, 23 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0dc800b..a3c2aab 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -328,7 +328,8 @@ static int efx_poll(struct napi_struct *napi, int budget)
  * processing to finish, then directly poll (and ack ) the eventq.
  * Finally reenable NAPI and interrupts.
  *
- * Since we are touching interrupts the caller should hold the suspend lock
+ * This is for use only during a loopback self-test.  It must not
+ * deliver any packets up the stack as this can result in deadlock.
  */
 void efx_process_channel_now(struct efx_channel *channel)
 {
@@ -336,6 +337,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 
 	BUG_ON(channel->channel >= efx->n_channels);
 	BUG_ON(!channel->enabled);
+	BUG_ON(!efx->loopback_selftest);
 
 	/* Disable interrupts and wait for ISRs to complete */
 	efx_nic_disable_interrupts(efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 9ffa9a6..191a311 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -330,7 +330,6 @@ enum efx_rx_alloc_method {
  * @eventq_mask: Event queue pointer mask
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
- * @magic_count: Event queue test event count
  * @irq_count: Number of IRQs since last adaptive moderation decision
  * @irq_mod_score: IRQ moderation score
  * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
@@ -360,7 +359,6 @@ struct efx_channel {
 	unsigned int eventq_mask;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
-	unsigned int magic_count;
 
 	unsigned int irq_count;
 	unsigned int irq_mod_score;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index e839661..10f1cb7 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -84,7 +84,8 @@ static inline void efx_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
 static inline efx_qword_t *efx_event(struct efx_channel *channel,
 				     unsigned int index)
 {
-	return ((efx_qword_t *) (channel->eventq.addr)) + index;
+	return ((efx_qword_t *) (channel->eventq.addr)) +
+		(index & channel->eventq_mask);
 }
 
 /* See if an event is present
@@ -673,7 +674,8 @@ void efx_nic_eventq_read_ack(struct efx_channel *channel)
 	efx_dword_t reg;
 	struct efx_nic *efx = channel->efx;
 
-	EFX_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR, channel->eventq_read_ptr);
+	EFX_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR,
+			     channel->eventq_read_ptr & channel->eventq_mask);
 	efx_writed_table(efx, &reg, efx->type->evq_rptr_tbl_base,
 			 channel->channel);
 }
@@ -908,7 +910,7 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 
 	code = EFX_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
 	if (code == EFX_CHANNEL_MAGIC_TEST(channel))
-		++channel->magic_count;
+		; /* ignore */
 	else if (code == EFX_CHANNEL_MAGIC_FILL(channel))
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
@@ -1015,8 +1017,7 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 		/* Clear this event by marking it all ones */
 		EFX_SET_QWORD(*p_event);
 
-		/* Increment read pointer */
-		read_ptr = (read_ptr + 1) & channel->eventq_mask;
+		++read_ptr;
 
 		ev_code = EFX_QWORD_FIELD(event, FSF_AZ_EV_CODE);
 
@@ -1060,6 +1061,13 @@ out:
 	return spent;
 }
 
+/* Check whether an event is present in the eventq at the current
+ * read pointer.  Only useful for self-test.
+ */
+bool efx_nic_event_present(struct efx_channel *channel)
+{
+	return efx_event_present(efx_event(channel, channel->eventq_read_ptr));
+}
 
 /* Allocate buffer table entries for event queue */
 int efx_nic_probe_eventq(struct efx_channel *channel)
@@ -1165,7 +1173,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	unsigned int read_ptr = channel->eventq_read_ptr;
-	unsigned int end_ptr = (read_ptr - 1) & channel->eventq_mask;
+	unsigned int end_ptr = read_ptr + channel->eventq_mask - 1;
 
 	do {
 		efx_qword_t *event = efx_event(channel, read_ptr);
@@ -1205,7 +1213,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 		 * it's ok to throw away every non-flush event */
 		EFX_SET_QWORD(*event);
 
-		read_ptr = (read_ptr + 1) & channel->eventq_mask;
+		++read_ptr;
 	} while (read_ptr != end_ptr);
 
 	channel->eventq_read_ptr = read_ptr;
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index d9de1b6..a42db6e 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -184,6 +184,7 @@ extern void efx_nic_fini_eventq(struct efx_channel *channel);
 extern void efx_nic_remove_eventq(struct efx_channel *channel);
 extern int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota);
 extern void efx_nic_eventq_read_ack(struct efx_channel *channel);
+extern bool efx_nic_event_present(struct efx_channel *channel);
 
 /* MAC/PHY */
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 8458084..50ad3bc 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -131,8 +131,6 @@ static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 static int efx_test_interrupts(struct efx_nic *efx,
 			       struct efx_self_tests *tests)
 {
-	struct efx_channel *channel;
-
 	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
 	tests->interrupt = -1;
 
@@ -140,15 +138,6 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	efx->last_irq_cpu = -1;
 	smp_wmb();
 
-	/* ACK each interrupting event queue. Receiving an interrupt due to
-	 * traffic before a test event is raised is considered a pass */
-	efx_for_each_channel(channel, efx) {
-		if (channel->work_pending)
-			efx_process_channel_now(channel);
-		if (efx->last_irq_cpu >= 0)
-			goto success;
-	}
-
 	efx_nic_generate_interrupt(efx);
 
 	/* Wait for arrival of test interrupt. */
@@ -173,13 +162,13 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
 {
 	struct efx_nic *efx = channel->efx;
-	unsigned int magic_count, count;
+	unsigned int read_ptr, count;
 
 	tests->eventq_dma[channel->channel] = -1;
 	tests->eventq_int[channel->channel] = -1;
 	tests->eventq_poll[channel->channel] = -1;
 
-	magic_count = channel->magic_count;
+	read_ptr = channel->eventq_read_ptr;
 	channel->efx->last_irq_cpu = -1;
 	smp_wmb();
 
@@ -190,10 +179,7 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	do {
 		schedule_timeout_uninterruptible(HZ / 100);
 
-		if (channel->work_pending)
-			efx_process_channel_now(channel);
-
-		if (channel->magic_count != magic_count)
+		if (ACCESS_ONCE(channel->eventq_read_ptr) != read_ptr)
 			goto eventq_ok;
 	} while (++count < 2);
 
@@ -211,8 +197,7 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	}
 
 	/* Check to see if event was received even if interrupt wasn't */
-	efx_process_channel_now(channel);
-	if (channel->magic_count != magic_count) {
+	if (efx_nic_event_present(channel)) {
 		netif_err(efx, drv, efx->net_dev,
 			  "channel %d event was generated, but "
 			  "failed to trigger an interrupt\n", channel->channel);
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

