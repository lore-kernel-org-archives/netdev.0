From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/10] sfc: Raise self-test timeouts
Date: Sat, 10 Mar 2012 00:50:09 +0000
Message-ID: <1331340609.2537.15.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51252 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758839Ab2CJAuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:50:12 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQ latency can be ridiculously high for various reasons, so our
current timeouts of 100 ms or 10 ms are too short.

Change the IRQ and event tests to use polling loops starting with a
delay of 1 tick and doubling that if necessary up to a maximum total
delay of approximately 1 second.

Raise the loopback packet RX timeout to 1 second.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/selftest.c |   65 ++++++++++++++++++++++++----------
 1 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index febe2a9..dc330b9 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -25,6 +25,16 @@
 #include "selftest.h"
 #include "workarounds.h"
 
+/* IRQ latency can be enormous because:
+ * - All IRQs may be disabled on a CPU for a *long* time by e.g. a
+ *   slow serial console or an old IDE driver doing error recovery
+ * - The PREEMPT_RT patches mostly deal with this, but also allow a
+ *   tasklet or normal task to be given higher priority than our IRQ
+ *   threads
+ * Try to avoid blaming the hardware for this.
+ */
+#define IRQ_TIMEOUT HZ
+
 /*
  * Loopback test packet structure
  *
@@ -77,6 +87,9 @@ struct efx_loopback_state {
 	struct efx_loopback_payload payload;
 };
 
+/* How long to wait for all the packets to arrive (in ms) */
+#define LOOPBACK_TIMEOUT_MS 1000
+
 /**************************************************************************
  *
  * MII, NVRAM and register tests
@@ -130,6 +143,7 @@ static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 static int efx_test_interrupts(struct efx_nic *efx,
 			       struct efx_self_tests *tests)
 {
+	unsigned long timeout, wait;
 	int cpu;
 
 	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
@@ -140,13 +154,18 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	smp_wmb();
 
 	efx_nic_generate_interrupt(efx);
+	timeout = jiffies + IRQ_TIMEOUT;
+	wait = 1;
 
 	/* Wait for arrival of test interrupt. */
 	netif_dbg(efx, drv, efx->net_dev, "waiting for test interrupt\n");
-	schedule_timeout_uninterruptible(HZ / 10);
-	cpu = ACCESS_ONCE(efx->last_irq_cpu);
-	if (cpu >= 0)
-		goto success;
+	do {
+		schedule_timeout_uninterruptible(wait);
+		cpu = ACCESS_ONCE(efx->last_irq_cpu);
+		if (cpu >= 0)
+			goto success;
+		wait *= 2;
+	} while (time_before(jiffies, timeout));
 
 	netif_err(efx, drv, efx->net_dev, "timed out waiting for interrupt\n");
 	return -ETIMEDOUT;
@@ -165,29 +184,37 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	struct efx_nic *efx = channel->efx;
 	unsigned int read_ptr;
 	bool napi_ran, dma_seen, int_seen;
+	unsigned long timeout, wait;
 
 	read_ptr = channel->eventq_read_ptr;
 	channel->last_irq_cpu = -1;
 	smp_wmb();
 
 	efx_nic_generate_test_event(channel);
+	timeout = jiffies + IRQ_TIMEOUT;
+	wait = 1;
 
 	/* Wait for arrival of interrupt.  NAPI processing may or may
 	 * not complete in time, but we can cope in any case.
 	 */
-	msleep(10);
-	napi_disable(&channel->napi_str);
-	if (channel->eventq_read_ptr != read_ptr) {
-		napi_ran = true;
-		dma_seen = true;
-		int_seen = true;
-	} else {
-		napi_ran = false;
-		dma_seen = efx_nic_event_present(channel);
-		int_seen = ACCESS_ONCE(channel->last_irq_cpu) >= 0;
-	}
-	napi_enable(&channel->napi_str);
-	efx_nic_eventq_read_ack(channel);
+	do {
+		schedule_timeout_uninterruptible(wait);
+
+		napi_disable(&channel->napi_str);
+		if (channel->eventq_read_ptr != read_ptr) {
+			napi_ran = true;
+			dma_seen = true;
+			int_seen = true;
+		} else {
+			napi_ran = false;
+			dma_seen = efx_nic_event_present(channel);
+			int_seen = ACCESS_ONCE(channel->last_irq_cpu) >= 0;
+		}
+		napi_enable(&channel->napi_str);
+		efx_nic_eventq_read_ack(channel);
+
+		wait *= 2;
+	} while (!(dma_seen && int_seen) && time_before(jiffies, timeout));
 
 	tests->eventq_dma[channel->channel] = dma_seen ? 1 : -1;
 	tests->eventq_int[channel->channel] = int_seen ? 1 : -1;
@@ -516,10 +543,10 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		begin_rc = efx_begin_loopback(tx_queue);
 
 		/* This will normally complete very quickly, but be
-		 * prepared to wait up to 100 ms. */
+		 * prepared to wait much longer. */
 		msleep(1);
 		if (!efx_poll_loopback(efx)) {
-			msleep(100);
+			msleep(LOOPBACK_TIMEOUT_MS);
 			efx_poll_loopback(efx);
 		}
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
