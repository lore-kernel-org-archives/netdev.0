From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 28/52] sfc: Cleanup RX event processing
Date: Mon, 1 Sep 2008 12:48:08 +0100
Message-ID: <20080901114807.GV7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60265 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759683AbYIALsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:10 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make efx_process_channel() and falcon_process_eventq() return the
number of packets received rather than updating the quota, consistent
with new NAPI.

Since channels and RX queues are mapped one-to-one, remove return
value from falcon_handle_rx_event() and add a warning for events
with the wrong RX queue number.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c    |   27 ++++++++++-----------------
 drivers/net/sfc/falcon.c |   30 ++++++++++++------------------
 drivers/net/sfc/falcon.h |    2 +-
 3 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 22004a6..864095e 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -160,14 +160,16 @@ static void efx_fini_channels(struct efx_nic *efx);
  */
 static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 {
-	int rxdmaqs;
-	struct efx_rx_queue *rx_queue;
+	struct efx_nic *efx = channel->efx;
+	int rx_packets;
 
-	if (unlikely(channel->efx->reset_pending != RESET_TYPE_NONE ||
+	if (unlikely(efx->reset_pending != RESET_TYPE_NONE ||
 		     !channel->enabled))
-		return rx_quota;
+		return 0;
 
-	rxdmaqs = falcon_process_eventq(channel, &rx_quota);
+	rx_packets = falcon_process_eventq(channel, rx_quota);
+	if (rx_packets == 0)
+		return 0;
 
 	/* Deliver last RX packet. */
 	if (channel->rx_pkt) {
@@ -179,16 +181,9 @@ static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 	efx_flush_lro(channel);
 	efx_rx_strategy(channel);
 
-	/* Refill descriptor rings as necessary */
-	rx_queue = &channel->efx->rx_queue[0];
-	while (rxdmaqs) {
-		if (rxdmaqs & 0x01)
-			efx_fast_push_rx_descriptors(rx_queue);
-		rx_queue++;
-		rxdmaqs >>= 1;
-	}
+	efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
 
-	return rx_quota;
+	return rx_packets;
 }
 
 /* Mark channel as finished processing
@@ -218,14 +213,12 @@ static int efx_poll(struct napi_struct *napi, int budget)
 	struct efx_channel *channel =
 		container_of(napi, struct efx_channel, napi_str);
 	struct net_device *napi_dev = channel->napi_dev;
-	int unused;
 	int rx_packets;
 
 	EFX_TRACE(channel->efx, "channel %d NAPI poll executing on CPU %d\n",
 		  channel->channel, raw_smp_processor_id());
 
-	unused = efx_process_channel(channel, budget);
-	rx_packets = (budget - unused);
+	rx_packets = efx_process_channel(channel, budget);
 
 	if (rx_packets < budget) {
 		/* There is no race here; although napi_disable() will
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 7b1c387..96cb5d0 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -952,10 +952,10 @@ static void falcon_handle_rx_bad_index(struct efx_rx_queue *rx_queue,
  * Also "is multicast" and "matches multicast filter" flags can be used to
  * discard non-matching multicast packets.
  */
-static int falcon_handle_rx_event(struct efx_channel *channel,
-				  const efx_qword_t *event)
+static void falcon_handle_rx_event(struct efx_channel *channel,
+				   const efx_qword_t *event)
 {
-	unsigned int rx_ev_q_label, rx_ev_desc_ptr, rx_ev_byte_cnt;
+	unsigned int rx_ev_desc_ptr, rx_ev_byte_cnt;
 	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned expected_ptr;
 	bool rx_ev_pkt_ok, discard = false, checksummed;
@@ -968,16 +968,14 @@ static int falcon_handle_rx_event(struct efx_channel *channel,
 	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
 	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_JUMBO_CONT));
 	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_SOP) != 1);
+	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_Q_LABEL) != channel->channel);
 
-	rx_ev_q_label = EFX_QWORD_FIELD(*event, RX_EV_Q_LABEL);
-	rx_queue = &efx->rx_queue[rx_ev_q_label];
+	rx_queue = &efx->rx_queue[channel->channel];
 
 	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, RX_EV_DESC_PTR);
 	expected_ptr = rx_queue->removed_count & FALCON_RXD_RING_MASK;
-	if (unlikely(rx_ev_desc_ptr != expected_ptr)) {
+	if (unlikely(rx_ev_desc_ptr != expected_ptr))
 		falcon_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
-		return rx_ev_q_label;
-	}
 
 	if (likely(rx_ev_pkt_ok)) {
 		/* If packet is marked as OK and packet type is TCP/IPv4 or
@@ -1003,8 +1001,6 @@ static int falcon_handle_rx_event(struct efx_channel *channel,
 	/* Handle received packet */
 	efx_rx_packet(rx_queue, rx_ev_desc_ptr, rx_ev_byte_cnt,
 		      checksummed, discard);
-
-	return rx_ev_q_label;
 }
 
 /* Global events are basically PHY events */
@@ -1109,13 +1105,12 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 	}
 }
 
-int falcon_process_eventq(struct efx_channel *channel, int *rx_quota)
+int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 {
 	unsigned int read_ptr;
 	efx_qword_t event, *p_event;
 	int ev_code;
-	int rxq;
-	int rxdmaqs = 0;
+	int rx_packets = 0;
 
 	read_ptr = channel->eventq_read_ptr;
 
@@ -1137,9 +1132,8 @@ int falcon_process_eventq(struct efx_channel *channel, int *rx_quota)
 
 		switch (ev_code) {
 		case RX_IP_EV_DECODE:
-			rxq = falcon_handle_rx_event(channel, &event);
-			rxdmaqs |= (1 << rxq);
-			(*rx_quota)--;
+			falcon_handle_rx_event(channel, &event);
+			++rx_packets;
 			break;
 		case TX_IP_EV_DECODE:
 			falcon_handle_tx_event(channel, &event);
@@ -1166,10 +1160,10 @@ int falcon_process_eventq(struct efx_channel *channel, int *rx_quota)
 		/* Increment read pointer */
 		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
 
-	} while (*rx_quota);
+	} while (rx_packets < rx_quota);
 
 	channel->eventq_read_ptr = read_ptr;
-	return rxdmaqs;
+	return rx_packets;
 }
 
 void falcon_set_int_moderation(struct efx_channel *channel)
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index a72f50e..4cf05d0 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -57,7 +57,7 @@ extern int falcon_probe_eventq(struct efx_channel *channel);
 extern int falcon_init_eventq(struct efx_channel *channel);
 extern void falcon_fini_eventq(struct efx_channel *channel);
 extern void falcon_remove_eventq(struct efx_channel *channel);
-extern int falcon_process_eventq(struct efx_channel *channel, int *rx_quota);
+extern int falcon_process_eventq(struct efx_channel *channel, int rx_quota);
 extern void falcon_eventq_read_ack(struct efx_channel *channel);
 
 /* Ports */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

