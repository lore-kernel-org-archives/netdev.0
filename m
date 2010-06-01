From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/12] sfc: Allow DRV_GEN events to be used outside of
 selftests
Date: Tue, 01 Jun 2010 22:19:09 +0100
Message-ID: <1275427149.2114.31.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50648 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab0FAVTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:19:12 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Formerly, efx_test_eventq_irq() assumed it was the only user of
driver generated events. Allow it to interoperate with other users.

We can create more than 16 channels, so align event codes with
a multiple of 256 not 16.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    4 ++--
 drivers/net/sfc/nic.c        |   17 ++++++++++-------
 drivers/net/sfc/nic.h        |    3 +--
 drivers/net/sfc/selftest.c   |   16 +++++-----------
 4 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 2e6fd89..ee0ea01 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -336,7 +336,7 @@ enum efx_rx_alloc_method {
  * @eventq: Event queue buffer
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
- * @eventq_magic: Event queue magic value for driver-generated test events
+ * @magic_count: Event queue test event count
  * @irq_count: Number of IRQs since last adaptive moderation decision
  * @irq_mod_score: IRQ moderation score
  * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
@@ -367,7 +367,7 @@ struct efx_channel {
 	struct efx_special_buffer eventq;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
-	unsigned int eventq_magic;
+	unsigned int magic_count;
 
 	unsigned int irq_count;
 	unsigned int irq_mod_score;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index ec0bb80..ca9cf1a 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -79,6 +79,10 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Depth of RX flush request fifo */
 #define EFX_RX_FLUSH_COUNT 4
 
+/* Magic value for efx_generate_test_event() */
+#define EFX_CHANNEL_MAGIC(_channel)			\
+	(0x00010100 + (_channel)->channel)
+
 /**************************************************************************
  *
  * Solarstorm hardware access
@@ -993,8 +997,10 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 			}
 			break;
 		case FSE_AZ_EV_CODE_DRV_GEN_EV:
-			channel->eventq_magic = EFX_QWORD_FIELD(
-				event, FSF_AZ_DRV_GEN_EV_MAGIC);
+			if (EFX_QWORD_FIELD(event, FSF_AZ_DRV_GEN_EV_MAGIC)
+			    == EFX_CHANNEL_MAGIC(channel))
+				++channel->magic_count;
+
 			EFX_LOG(channel->efx, "channel %d received generated "
 				"event "EFX_QWORD_FMT"\n", channel->channel,
 				EFX_QWORD_VAL(event));
@@ -1088,12 +1094,9 @@ void efx_nic_remove_eventq(struct efx_channel *channel)
 }
 

-/* Generates a test event on the event queue.  A subsequent call to
- * process_eventq() should pick up the event and place the value of
- * "magic" into channel->eventq_magic;
- */
-void efx_nic_generate_test_event(struct efx_channel *channel, unsigned int magic)
+void efx_nic_generate_test_event(struct efx_channel *channel)
 {
+	unsigned int magic = EFX_CHANNEL_MAGIC(channel);
 	efx_qword_t test_event;
 
 	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index bbc2c0c..186aab5 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -190,8 +190,7 @@ extern int efx_nic_rx_xoff_thresh, efx_nic_rx_xon_thresh;
 /* Interrupts and test events */
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
 extern void efx_nic_enable_interrupts(struct efx_nic *efx);
-extern void efx_nic_generate_test_event(struct efx_channel *channel,
-					unsigned int magic);
+extern void efx_nic_generate_test_event(struct efx_channel *channel);
 extern void efx_nic_generate_interrupt(struct efx_nic *efx);
 extern void efx_nic_disable_interrupts(struct efx_nic *efx);
 extern void efx_nic_fini_interrupt(struct efx_nic *efx);
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 52ac14a..c088740 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -161,23 +161,17 @@ static int efx_test_interrupts(struct efx_nic *efx,
 static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
 {
-	unsigned int magic, count;
-
-	/* Channel specific code, limited to 20 bits */
-	magic = (0x00010150 + channel->channel);
-	EFX_LOG(channel->efx, "channel %d testing event queue with code %x\n",
-		channel->channel, magic);
+	unsigned int magic_count, count;
 
 	tests->eventq_dma[channel->channel] = -1;
 	tests->eventq_int[channel->channel] = -1;
 	tests->eventq_poll[channel->channel] = -1;
 
-	/* Reset flag and zero magic word */
+	magic_count = channel->magic_count;
 	channel->efx->last_irq_cpu = -1;
-	channel->eventq_magic = 0;
 	smp_wmb();
 
-	efx_nic_generate_test_event(channel, magic);
+	efx_nic_generate_test_event(channel);
 
 	/* Wait for arrival of interrupt */
 	count = 0;
@@ -187,7 +181,7 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 		if (channel->work_pending)
 			efx_process_channel_now(channel);
 
-		if (channel->eventq_magic == magic)
+		if (channel->magic_count != magic_count)
 			goto eventq_ok;
 	} while (++count < 2);
 
@@ -204,7 +198,7 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 
 	/* Check to see if event was received even if interrupt wasn't */
 	efx_process_channel_now(channel);
-	if (channel->eventq_magic == magic) {
+	if (channel->magic_count != magic_count) {
 		EFX_ERR(channel->efx, "channel %d event was generated, but "
 			"failed to trigger an interrupt\n", channel->channel);
 		tests->eventq_dma[channel->channel] = 1;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

