From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/10] sfc: Test all event queues in parallel
Date: Sat, 10 Mar 2012 00:50:36 +0000
Message-ID: <1331340636.2537.16.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51263 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754990Ab2CJAuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:50:39 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case all event queues are broken for some reason, this means it
will only take about a second to check them all, rather than up to 32
seconds.  This may also speed up testing in the successful case.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/selftest.c |  114 ++++++++++++++++++++---------------
 1 files changed, 65 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index dc330b9..e4b4c8a 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -178,69 +178,88 @@ static int efx_test_interrupts(struct efx_nic *efx,
 }
 
 /* Test generation and receipt of interrupting events */
-static int efx_test_eventq_irq(struct efx_channel *channel,
+static int efx_test_eventq_irq(struct efx_nic *efx,
 			       struct efx_self_tests *tests)
 {
-	struct efx_nic *efx = channel->efx;
-	unsigned int read_ptr;
-	bool napi_ran, dma_seen, int_seen;
+	struct efx_channel *channel;
+	unsigned int read_ptr[EFX_MAX_CHANNELS];
+	unsigned long napi_ran = 0, dma_pend = 0, int_pend = 0;
 	unsigned long timeout, wait;
 
-	read_ptr = channel->eventq_read_ptr;
-	channel->last_irq_cpu = -1;
-	smp_wmb();
+	BUILD_BUG_ON(EFX_MAX_CHANNELS > BITS_PER_LONG);
+
+	efx_for_each_channel(channel, efx) {
+		read_ptr[channel->channel] = channel->eventq_read_ptr;
+		set_bit(channel->channel, &dma_pend);
+		set_bit(channel->channel, &int_pend);
+		channel->last_irq_cpu = -1;
+		smp_wmb();
+		efx_nic_generate_test_event(channel);
+	}
 
-	efx_nic_generate_test_event(channel);
 	timeout = jiffies + IRQ_TIMEOUT;
 	wait = 1;
 
-	/* Wait for arrival of interrupt.  NAPI processing may or may
+	/* Wait for arrival of interrupts.  NAPI processing may or may
 	 * not complete in time, but we can cope in any case.
 	 */
 	do {
 		schedule_timeout_uninterruptible(wait);
 
-		napi_disable(&channel->napi_str);
-		if (channel->eventq_read_ptr != read_ptr) {
-			napi_ran = true;
-			dma_seen = true;
-			int_seen = true;
-		} else {
-			napi_ran = false;
-			dma_seen = efx_nic_event_present(channel);
-			int_seen = ACCESS_ONCE(channel->last_irq_cpu) >= 0;
+		efx_for_each_channel(channel, efx) {
+			napi_disable(&channel->napi_str);
+			if (channel->eventq_read_ptr !=
+			    read_ptr[channel->channel]) {
+				set_bit(channel->channel, &napi_ran);
+				clear_bit(channel->channel, &dma_pend);
+				clear_bit(channel->channel, &int_pend);
+			} else {
+				if (efx_nic_event_present(channel))
+					clear_bit(channel->channel, &dma_pend);
+				if (ACCESS_ONCE(channel->last_irq_cpu) >= 0)
+					clear_bit(channel->channel, &int_pend);
+			}
+			napi_enable(&channel->napi_str);
+			efx_nic_eventq_read_ack(channel);
 		}
-		napi_enable(&channel->napi_str);
-		efx_nic_eventq_read_ack(channel);
 
 		wait *= 2;
-	} while (!(dma_seen && int_seen) && time_before(jiffies, timeout));
-
-	tests->eventq_dma[channel->channel] = dma_seen ? 1 : -1;
-	tests->eventq_int[channel->channel] = int_seen ? 1 : -1;
+	} while ((dma_pend || int_pend) && time_before(jiffies, timeout));
 
-	if (dma_seen && int_seen) {
-		netif_dbg(efx, drv, efx->net_dev,
-			  "channel %d event queue passed (with%s NAPI)\n",
-			  channel->channel, napi_ran ? "" : "out");
-		return 0;
-	} else {
-		/* Report failure and whether either interrupt or DMA worked */
-		netif_err(efx, drv, efx->net_dev,
-			  "channel %d timed out waiting for event queue\n",
-			  channel->channel);
-		if (int_seen)
-			netif_err(efx, drv, efx->net_dev,
-				  "channel %d saw interrupt "
-				  "during event queue test\n",
-				  channel->channel);
-		if (dma_seen)
+	efx_for_each_channel(channel, efx) {
+		bool dma_seen = !test_bit(channel->channel, &dma_pend);
+		bool int_seen = !test_bit(channel->channel, &int_pend);
+
+		tests->eventq_dma[channel->channel] = dma_seen ? 1 : -1;
+		tests->eventq_int[channel->channel] = int_seen ? 1 : -1;
+
+		if (dma_seen && int_seen) {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "channel %d event queue passed (with%s NAPI)\n",
+				  channel->channel,
+				  test_bit(channel->channel, &napi_ran) ?
+				  "" : "out");
+		} else {
+			/* Report failure and whether either interrupt or DMA
+			 * worked
+			 */
 			netif_err(efx, drv, efx->net_dev,
-				  "channel %d event was generated, but "
-				  "failed to trigger an interrupt\n",
+				  "channel %d timed out waiting for event queue\n",
 				  channel->channel);
-		return -ETIMEDOUT;
+			if (int_seen)
+				netif_err(efx, drv, efx->net_dev,
+					  "channel %d saw interrupt "
+					  "during event queue test\n",
+					  channel->channel);
+			if (dma_seen)
+				netif_err(efx, drv, efx->net_dev,
+					  "channel %d event was generated, but "
+					  "failed to trigger an interrupt\n",
+					  channel->channel);
+		}
 	}
+
+	return (dma_pend || int_pend) ? -ETIMEDOUT : 0;
 }
 
 static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
@@ -687,7 +706,6 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
 	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
-	struct efx_channel *channel;
 	int rc_test = 0, rc_reset = 0, rc;
 
 	/* Online (i.e. non-disruptive) testing
@@ -705,11 +723,9 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	if (rc && !rc_test)
 		rc_test = rc;
 
-	efx_for_each_channel(channel, efx) {
-		rc = efx_test_eventq_irq(channel, tests);
-		if (rc && !rc_test)
-			rc_test = rc;
-	}
+	rc = efx_test_eventq_irq(efx, tests);
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	if (rc_test)
 		return rc_test;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
