From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/10] sfc: Encapsulate access to
 efx_{channel,nic}::last_irq_cpu in self-test
Date: Sat, 10 Mar 2012 00:51:10 +0000
Message-ID: <1331340670.2537.17.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51275 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755217Ab2CJAvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:51:13 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup in preparation for doing an event test on ifup.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c      |    8 ++++++--
 drivers/net/ethernet/sfc/nic.h      |   13 +++++++++++--
 drivers/net/ethernet/sfc/selftest.c |   14 ++++----------
 3 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 5da8af5..4c47b75 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1332,8 +1332,10 @@ void efx_nic_remove_eventq(struct efx_channel *channel)
 }
 

-void efx_nic_generate_test_event(struct efx_channel *channel)
+void efx_nic_event_test_start(struct efx_channel *channel)
 {
+	channel->last_irq_cpu = -1;
+	smp_wmb();
 	efx_magic_event(channel, EFX_CHANNEL_MAGIC_TEST(channel));
 }
 
@@ -1382,8 +1384,10 @@ void efx_nic_disable_interrupts(struct efx_nic *efx)
  * Interrupt must already have been enabled, otherwise nasty things
  * may happen.
  */
-void efx_nic_generate_interrupt(struct efx_nic *efx)
+void efx_nic_irq_test_start(struct efx_nic *efx)
 {
+	efx->last_irq_cpu = -1;
+	smp_wmb();
 	efx_nic_interrupts(efx, true, true);
 }
 
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index ac12f7f..e0e8596 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -301,14 +301,23 @@ extern void falcon_update_stats_xmac(struct efx_nic *efx);
 /* Interrupts and test events */
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
 extern void efx_nic_enable_interrupts(struct efx_nic *efx);
-extern void efx_nic_generate_test_event(struct efx_channel *channel);
-extern void efx_nic_generate_interrupt(struct efx_nic *efx);
+extern void efx_nic_event_test_start(struct efx_channel *channel);
+extern void efx_nic_irq_test_start(struct efx_nic *efx);
 extern void efx_nic_disable_interrupts(struct efx_nic *efx);
 extern void efx_nic_fini_interrupt(struct efx_nic *efx);
 extern irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx);
 extern irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id);
 extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
+static inline int efx_nic_event_test_irq_cpu(struct efx_channel *channel)
+{
+	return ACCESS_ONCE(channel->last_irq_cpu);
+}
+static inline int efx_nic_irq_test_irq_cpu(struct efx_nic *efx)
+{
+	return ACCESS_ONCE(efx->last_irq_cpu);
+}
+
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index e4b4c8a..aa4ab53 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -149,11 +149,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
 	tests->interrupt = -1;
 
-	/* Reset interrupt flag */
-	efx->last_irq_cpu = -1;
-	smp_wmb();
-
-	efx_nic_generate_interrupt(efx);
+	efx_nic_irq_test_start(efx);
 	timeout = jiffies + IRQ_TIMEOUT;
 	wait = 1;
 
@@ -161,7 +157,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	netif_dbg(efx, drv, efx->net_dev, "waiting for test interrupt\n");
 	do {
 		schedule_timeout_uninterruptible(wait);
-		cpu = ACCESS_ONCE(efx->last_irq_cpu);
+		cpu = efx_nic_irq_test_irq_cpu(efx);
 		if (cpu >= 0)
 			goto success;
 		wait *= 2;
@@ -192,9 +188,7 @@ static int efx_test_eventq_irq(struct efx_nic *efx,
 		read_ptr[channel->channel] = channel->eventq_read_ptr;
 		set_bit(channel->channel, &dma_pend);
 		set_bit(channel->channel, &int_pend);
-		channel->last_irq_cpu = -1;
-		smp_wmb();
-		efx_nic_generate_test_event(channel);
+		efx_nic_event_test_start(channel);
 	}
 
 	timeout = jiffies + IRQ_TIMEOUT;
@@ -216,7 +210,7 @@ static int efx_test_eventq_irq(struct efx_nic *efx,
 			} else {
 				if (efx_nic_event_present(channel))
 					clear_bit(channel->channel, &dma_pend);
-				if (ACCESS_ONCE(channel->last_irq_cpu) >= 0)
+				if (efx_nic_event_test_irq_cpu(channel) >= 0)
 					clear_bit(channel->channel, &int_pend);
 			}
 			napi_enable(&channel->napi_str);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
