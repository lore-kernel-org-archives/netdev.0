From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/19] sfc: Generate RX fill events based on RX
 queues, not channels
Date: Thu, 16 Feb 2012 00:47:42 +0000
Message-ID: <1329353262.2565.35.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27607 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751572Ab2BPAr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:47:57 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it harder to accidentally send such events to TX-only
channels.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |   17 +++++++++++------
 drivers/net/ethernet/sfc/nic.h |    2 +-
 drivers/net/ethernet/sfc/rx.c  |    3 +--
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 0a46b1c..2b33afd 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -66,8 +66,9 @@
 
 #define EFX_CHANNEL_MAGIC_TEST(_channel)				\
 	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_TEST, (_channel)->channel)
-#define EFX_CHANNEL_MAGIC_FILL(_channel)				\
-	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_FILL, (_channel)->channel)
+#define EFX_CHANNEL_MAGIC_FILL(_rx_queue)				\
+	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_FILL,			\
+			   efx_rx_queue_index(_rx_queue))
 
 /**************************************************************************
  *
@@ -912,17 +913,20 @@ static void
 efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
+	struct efx_rx_queue *rx_queue =
+		efx_channel_has_rx_queue(channel) ?
+		efx_channel_get_rx_queue(channel) : NULL;
 	unsigned magic;
 
 	magic = EFX_QWORD_FIELD(*event, FSF_AZ_DRV_GEN_EV_MAGIC);
 
 	if (magic == EFX_CHANNEL_MAGIC_TEST(channel))
 		; /* ignore */
-	else if (magic == EFX_CHANNEL_MAGIC_FILL(channel))
+	else if (rx_queue && magic == EFX_CHANNEL_MAGIC_FILL(rx_queue))
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
 		 * queue. Refill it here */
-		efx_fast_push_rx_descriptors(efx_channel_get_rx_queue(channel));
+		efx_fast_push_rx_descriptors(rx_queue);
 	else
 		netif_dbg(efx, hw, efx->net_dev, "channel %d received "
 			  "generated event "EFX_QWORD_FMT"\n",
@@ -1150,9 +1154,10 @@ void efx_nic_generate_test_event(struct efx_channel *channel)
 	efx_magic_event(channel, EFX_CHANNEL_MAGIC_TEST(channel));
 }
 
-void efx_nic_generate_fill_event(struct efx_channel *channel)
+void efx_nic_generate_fill_event(struct efx_rx_queue *rx_queue)
 {
-	efx_magic_event(channel, EFX_CHANNEL_MAGIC_FILL(channel));
+	efx_magic_event(efx_rx_queue_channel(rx_queue),
+			EFX_CHANNEL_MAGIC_FILL(rx_queue));
 }
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 4f9d18a..aeca4e8 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -195,6 +195,7 @@ extern void efx_nic_init_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_fini_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_remove_rx(struct efx_rx_queue *rx_queue);
 extern void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue);
+extern void efx_nic_generate_fill_event(struct efx_rx_queue *rx_queue);
 
 /* Event data path */
 extern int efx_nic_probe_eventq(struct efx_channel *channel);
@@ -216,7 +217,6 @@ extern void falcon_update_stats_xmac(struct efx_nic *efx);
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
 extern void efx_nic_enable_interrupts(struct efx_nic *efx);
 extern void efx_nic_generate_test_event(struct efx_channel *channel);
-extern void efx_nic_generate_fill_event(struct efx_channel *channel);
 extern void efx_nic_generate_interrupt(struct efx_nic *efx);
 extern void efx_nic_disable_interrupts(struct efx_nic *efx);
 extern void efx_nic_fini_interrupt(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 1dfda5e..76fb521 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -405,10 +405,9 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 void efx_rx_slow_fill(unsigned long context)
 {
 	struct efx_rx_queue *rx_queue = (struct efx_rx_queue *)context;
-	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 
 	/* Post an event to cause NAPI to run and refill the queue */
-	efx_nic_generate_fill_event(channel);
+	efx_nic_generate_fill_event(rx_queue);
 	++rx_queue->slow_fill_count;
 }
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
