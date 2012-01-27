From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 19/32] sfc: Remove dependence on NAPI polling in
 efx_test_eventq_irq()
Date: Fri, 27 Jan 2012 20:48:37 +0000
Message-ID: <1327697317.2503.26.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63696 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752836Ab2A0Usl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:48:41 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot safely assume that the NAPI handler will complete within the
20 ms that we allow for the event self-test.  The handler may be
deferred for longer than this, particularly on realtime kernels.

Instead, check whether either an event has been handled or (as in the
old failure path) whether an interrupt has been received and an event
has been delivered but not yet handled.  Use napi_disable() to
synchronize with the NAPI handler before checking, since it will
clear events before updating eventq_read_ptr.

Remove the test result chan.N.eventq.poll, since it is not an error
if the NAPI handler does not run during the test.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c  |    4 --
 drivers/net/ethernet/sfc/selftest.c |   79 ++++++++++++++++++-----------------
 drivers/net/ethernet/sfc/selftest.h |    1 -
 3 files changed, 40 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 1a7f7ba..ba90116 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -404,10 +404,6 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 			      &tests->eventq_int[channel->channel],
 			      EFX_CHANNEL_NAME(channel),
 			      "eventq.int", NULL);
-		efx_fill_test(n++, strings, data,
-			      &tests->eventq_poll[channel->channel],
-			      EFX_CHANNEL_NAME(channel),
-			      "eventq.poll", NULL);
 	}
 
 	efx_fill_test(n++, strings, data, &tests->registers,
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 7718287..0f84789 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -161,11 +161,8 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
 {
 	struct efx_nic *efx = channel->efx;
-	unsigned int read_ptr, count;
-
-	tests->eventq_dma[channel->channel] = -1;
-	tests->eventq_int[channel->channel] = -1;
-	tests->eventq_poll[channel->channel] = -1;
+	unsigned int read_ptr;
+	bool napi_ran, dma_seen, int_seen;
 
 	read_ptr = channel->eventq_read_ptr;
 	channel->efx->last_irq_cpu = -1;
@@ -173,44 +170,48 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 
 	efx_nic_generate_test_event(channel);
 
-	/* Wait for arrival of interrupt */
-	count = 0;
-	do {
-		schedule_timeout_uninterruptible(HZ / 100);
-
-		if (ACCESS_ONCE(channel->eventq_read_ptr) != read_ptr)
-			goto eventq_ok;
-	} while (++count < 2);
-
-	netif_err(efx, drv, efx->net_dev,
-		  "channel %d timed out waiting for event queue\n",
-		  channel->channel);
-
-	/* See if interrupt arrived */
-	if (channel->efx->last_irq_cpu >= 0) {
-		netif_err(efx, drv, efx->net_dev,
-			  "channel %d saw interrupt on CPU%d "
-			  "during event queue test\n", channel->channel,
-			  raw_smp_processor_id());
-		tests->eventq_int[channel->channel] = 1;
+	/* Wait for arrival of interrupt.  NAPI processing may or may
+	 * not complete in time, but we can cope in any case.
+	 */
+	msleep(10);
+	napi_disable(&channel->napi_str);
+	if (channel->eventq_read_ptr != read_ptr) {
+		napi_ran = true;
+		dma_seen = true;
+		int_seen = true;
+	} else {
+		napi_ran = false;
+		dma_seen = efx_nic_event_present(channel);
+		int_seen = efx->last_irq_cpu >= 0;
 	}
+	napi_enable(&channel->napi_str);
+	efx_nic_eventq_read_ack(channel);
+
+	tests->eventq_dma[channel->channel] = dma_seen ? 1 : -1;
+	tests->eventq_int[channel->channel] = int_seen ? 1 : -1;
 
-	/* Check to see if event was received even if interrupt wasn't */
-	if (efx_nic_event_present(channel)) {
+	if (dma_seen && int_seen) {
+		netif_dbg(efx, drv, efx->net_dev,
+			  "channel %d event queue passed (with%s NAPI)\n",
+			  channel->channel, napi_ran ? "" : "out");
+		return 0;
+	} else {
+		/* Report failure and whether either interrupt or DMA worked */
 		netif_err(efx, drv, efx->net_dev,
-			  "channel %d event was generated, but "
-			  "failed to trigger an interrupt\n", channel->channel);
-		tests->eventq_dma[channel->channel] = 1;
+			  "channel %d timed out waiting for event queue\n",
+			  channel->channel);
+		if (int_seen)
+			netif_err(efx, drv, efx->net_dev,
+				  "channel %d saw interrupt "
+				  "during event queue test\n",
+				  channel->channel);
+		if (dma_seen)
+			netif_err(efx, drv, efx->net_dev,
+				  "channel %d event was generated, but "
+				  "failed to trigger an interrupt\n",
+				  channel->channel);
+		return -ETIMEDOUT;
 	}
-
-	return -ETIMEDOUT;
- eventq_ok:
-	netif_dbg(efx, drv, efx->net_dev, "channel %d event queue passed\n",
-		  channel->channel);
-	tests->eventq_dma[channel->channel] = 1;
-	tests->eventq_int[channel->channel] = 1;
-	tests->eventq_poll[channel->channel] = 1;
-	return 0;
 }
 
 static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
diff --git a/drivers/net/ethernet/sfc/selftest.h b/drivers/net/ethernet/sfc/selftest.h
index dba5456..87abe2a 100644
--- a/drivers/net/ethernet/sfc/selftest.h
+++ b/drivers/net/ethernet/sfc/selftest.h
@@ -37,7 +37,6 @@ struct efx_self_tests {
 	int interrupt;
 	int eventq_dma[EFX_MAX_CHANNELS];
 	int eventq_int[EFX_MAX_CHANNELS];
-	int eventq_poll[EFX_MAX_CHANNELS];
 	/* offline tests */
 	int registers;
 	int phy_ext[EFX_MAX_PHY_TESTS];
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
