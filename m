From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/16] sfc: Make initial fill of RX descriptors
 synchronous
Date: Thu, 12 Dec 2013 23:00:36 +0000
Message-ID: <1386889236.1516.342.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43724 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3LLXAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:00:40 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c  | 2 +-
 drivers/net/ethernet/sfc/efx.c   | 6 ++++--
 drivers/net/ethernet/sfc/efx.h   | 2 +-
 drivers/net/ethernet/sfc/farch.c | 2 +-
 drivers/net/ethernet/sfc/rx.c    | 9 +++++----
 5 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 2f77359607d2..e9c546bdbdfe 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1907,7 +1907,7 @@ static void efx_ef10_handle_driver_generated_event(struct efx_channel *channel,
 		 * events, so efx_process_channel() won't refill the
 		 * queue. Refill it here
 		 */
-		efx_fast_push_rx_descriptors(&channel->rx_queue);
+		efx_fast_push_rx_descriptors(&channel->rx_queue, true);
 		break;
 	default:
 		netif_err(efx, hw, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 869418164364..5e2454d07137 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -253,7 +253,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 			efx_channel_get_rx_queue(channel);
 
 		efx_rx_flush_packet(channel);
-		efx_fast_push_rx_descriptors(rx_queue);
+		efx_fast_push_rx_descriptors(rx_queue, true);
 	}
 
 	return spent;
@@ -646,7 +646,9 @@ static void efx_start_datapath(struct efx_nic *efx)
 		efx_for_each_channel_rx_queue(rx_queue, channel) {
 			efx_init_rx_queue(rx_queue);
 			atomic_inc(&efx->active_queues);
-			efx_nic_generate_fill_event(rx_queue);
+			efx_stop_eventq(channel);
+			efx_fast_push_rx_descriptors(rx_queue, false);
+			efx_start_eventq(channel);
 		}
 
 		WARN_ON(channel->rx_pkt_n_frags);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index b8235ee5d7d7..a653786fbbe7 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -37,7 +37,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
-void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
+void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic);
 void efx_rx_slow_fill(unsigned long context);
 void __efx_rx_packet(struct efx_channel *channel);
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index c0907d884d75..984e85ee76f6 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1147,7 +1147,7 @@ static void efx_farch_handle_generated_event(struct efx_channel *channel,
 		/* The queue must be empty, so we won't receive any rx
 		 * events, so efx_process_channel() won't refill the
 		 * queue. Refill it here */
-		efx_fast_push_rx_descriptors(rx_queue);
+		efx_fast_push_rx_descriptors(rx_queue, true);
 	} else if (rx_queue && magic == EFX_CHANNEL_MAGIC_RX_DRAIN(rx_queue)) {
 		efx_farch_handle_drain_event(channel);
 	} else if (code == _EFX_CHANNEL_MAGIC_TX_DRAIN) {
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 42488df1f4ec..8671bc199a9d 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -149,7 +149,7 @@ static struct page *efx_reuse_page(struct efx_rx_queue *rx_queue)
  * 0 on success. If a single page can be used for multiple buffers,
  * then the page will either be inserted fully, or not at all.
  */
-static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
+static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
@@ -163,7 +163,8 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue)
 	do {
 		page = efx_reuse_page(rx_queue);
 		if (page == NULL) {
-			page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
+			page = alloc_pages(__GFP_COLD | __GFP_COMP |
+					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
 					   efx->rx_buffer_order);
 			if (unlikely(page == NULL))
 				return -ENOMEM;
@@ -321,7 +322,7 @@ static void efx_discard_rx_packet(struct efx_channel *channel,
  * this means this function must run from the NAPI handler, or be called
  * when NAPI is disabled.
  */
-void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
+void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned int fill_level, batch_size;
@@ -354,7 +355,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 

 	do {
-		rc = efx_init_rx_buffers(rx_queue);
+		rc = efx_init_rx_buffers(rx_queue, atomic);
 		if (unlikely(rc)) {
 			/* Ensure that we don't leave the rx queue empty */
 			if (rx_queue->added_count == rx_queue->removed_count)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
