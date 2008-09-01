From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 23/52] sfc: Remove efx_channel::has_interrupt
Date: Mon, 1 Sep 2008 12:47:38 +0100
Message-ID: <20080901114737.GQ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55831 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757230AbYIALrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:41 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_channel::has_interrupt is redundant with efx_channel::used_flags.

Remove efx_test_eventq() because it is now obviously unreachable.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   16 ++++----------
 drivers/net/sfc/falcon.c     |    8 +++---
 drivers/net/sfc/net_driver.h |   11 ----------
 drivers/net/sfc/selftest.c   |   44 ++---------------------------------------
 4 files changed, 12 insertions(+), 67 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 487df94..2deac7b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -259,7 +259,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	if (channel->has_interrupt && channel->irq)
+	if (channel->irq)
 		synchronize_irq(channel->irq);
 
 	/* Wait for any NAPI processing to complete */
@@ -872,10 +872,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		}
 
 		if (rc == 0) {
-			for (i = 0; i < efx->rss_queues; i++) {
-				efx->channel[i].has_interrupt = true;
+			for (i = 0; i < efx->rss_queues; i++)
 				efx->channel[i].irq = xentries[i].vector;
-			}
 		} else {
 			/* Fall back to single channel MSI */
 			efx->interrupt_mode = EFX_INT_MODE_MSI;
@@ -889,7 +887,6 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
-			efx->channel[0].has_interrupt = true;
 		} else {
 			EFX_ERR(efx, "could not enable MSI\n");
 			efx->interrupt_mode = EFX_INT_MODE_LEGACY;
@@ -899,9 +896,6 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 	/* Assume legacy interrupts */
 	if (efx->interrupt_mode == EFX_INT_MODE_LEGACY) {
 		efx->rss_queues = 1;
-		/* Every channel is interruptible */
-		for (i = 0; i < EFX_MAX_CHANNELS; i++)
-			efx->channel[i].has_interrupt = true;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
 }
@@ -911,7 +905,7 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 	struct efx_channel *channel;
 
 	/* Remove MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		channel->irq = 0;
 	pci_disable_msi(efx->pci_dev);
 	pci_disable_msix(efx->pci_dev);
@@ -1106,7 +1100,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
 			synchronize_irq(channel->irq);
 	}
@@ -1303,7 +1297,7 @@ static void efx_netpoll(struct net_device *net_dev)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		efx_schedule_channel(channel);
 }
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3017639..40dd643 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1317,7 +1317,7 @@ void falcon_enable_interrupts(struct efx_nic *efx)
 
 	/* Force processing of all the channels to get the EVQ RPTRs up to
 	   date */
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		efx_schedule_channel(channel);
 }
 
@@ -1567,7 +1567,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	}
 
 	/* Hook MSI or MSI-X interrupt */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		rc = request_irq(channel->irq, falcon_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
 				 efx->name, channel);
@@ -1580,7 +1580,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	return 0;
 
  fail2:
-	efx_for_each_channel_with_interrupt(channel, efx)
+	efx_for_each_channel(channel, efx)
 		free_irq(channel->irq, channel);
  fail1:
 	return rc;
@@ -1592,7 +1592,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	efx_oword_t reg;
 
 	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->irq)
 			free_irq(channel->irq, channel);
 	}
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 3902757..1fa134a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -329,7 +329,6 @@ enum efx_rx_alloc_method {
  * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
- * @has_interrupt: Channel has an interrupt
  * @irq_moderation: IRQ moderation value (in us)
  * @napi_dev: Net device used with NAPI
  * @napi_str: NAPI control structure
@@ -361,7 +360,6 @@ struct efx_channel {
 	int used_flags;
 	bool enabled;
 	int irq;
-	bool has_interrupt;
 	unsigned int irq_moderation;
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
@@ -834,15 +832,6 @@ struct efx_nic_type {
 			continue;					\
 		else
 
-/* Iterate over all used channels with interrupts */
-#define efx_for_each_channel_with_interrupt(_channel, _efx)		\
-	for (_channel = &_efx->channel[0];				\
-	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
-	     _channel++)						\
-		if (!(_channel->used_flags && _channel->has_interrupt))	\
-			continue;					\
-		else
-
 /* Iterate over all used TX queues */
 #define efx_for_each_tx_queue(_tx_queue, _efx)				\
 	for (_tx_queue = &_efx->tx_queue[0];				\
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index ff7b84c..2f7def6 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -111,7 +111,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 
 	/* ACK each interrupting event queue. Receiving an interrupt due to
 	 * traffic before a test event is raised is considered a pass */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->work_pending)
 			efx_process_channel_now(channel);
 		if (efx->last_irq_cpu >= 0)
@@ -136,41 +136,6 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	return 0;
 }
 
-/* Test generation and receipt of non-interrupting events */
-static int efx_test_eventq(struct efx_channel *channel,
-			   struct efx_self_tests *tests)
-{
-	unsigned int magic;
-
-	/* Channel specific code, limited to 20 bits */
-	magic = (0x00010150 + channel->channel);
-	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
-		channel->channel, magic);
-
-	tests->eventq_dma[channel->channel] = -1;
-	tests->eventq_int[channel->channel] = 1;	/* fake pass */
-	tests->eventq_poll[channel->channel] = 1;	/* fake pass */
-
-	/* Reset flag and zero magic word */
-	channel->efx->last_irq_cpu = -1;
-	channel->eventq_magic = 0;
-	smp_wmb();
-
-	falcon_generate_test_event(channel, magic);
-	udelay(1);
-
-	efx_process_channel_now(channel);
-	if (channel->eventq_magic != magic) {
-		EFX_ERR(channel->efx, "channel %d  failed to see test event\n",
-			channel->channel);
-		return -ETIMEDOUT;
-	} else {
-		tests->eventq_dma[channel->channel] = 1;
-	}
-
-	return 0;
-}
-
 /* Test generation and receipt of interrupting events */
 static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
@@ -456,7 +421,7 @@ static int efx_poll_loopback(struct efx_nic *efx)
 
 	/* NAPI polling is not enabled, so process channels
 	 * synchronously */
-	efx_for_each_channel_with_interrupt(channel, efx) {
+	efx_for_each_channel(channel, efx) {
 		if (channel->work_pending)
 			efx_process_channel_now(channel);
 	}
@@ -689,10 +654,7 @@ int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
 	if (rc)
 		return rc;
 	efx_for_each_channel(channel, efx) {
-		if (channel->has_interrupt)
-			rc = efx_test_eventq_irq(channel, tests);
-		else
-			rc = efx_test_eventq(channel, tests);
+		rc = efx_test_eventq_irq(channel, tests);
 		if (rc)
 			return rc;
 	}
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

