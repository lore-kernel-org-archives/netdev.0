From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/17] sfc: Break NAPI processing after one ring-full of TX
 completions
Date: Wed, 28 Apr 2010 20:29:42 +0100
Message-ID: <1272482982.2549.28.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12575 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0D1T3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:29:45 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently TX completions do not count towards the NAPI budget.  This
means a continuous stream of TX completions can cause the polling
function to loop indefinitely with scheduling disabled.  To avoid
this, follow the common practice of reporting the budget spent after
processing one ring-full of TX completions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   18 +++++++++---------
 drivers/net/sfc/nic.c |   39 ++++++++++++++++++++++++---------------
 2 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 1ad61b7..5e3f944 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -225,17 +225,17 @@ static void efx_fini_channels(struct efx_nic *efx);
  * never be concurrently called more than once on the same channel,
  * though different channels may be being processed concurrently.
  */
-static int efx_process_channel(struct efx_channel *channel, int rx_quota)
+static int efx_process_channel(struct efx_channel *channel, int budget)
 {
 	struct efx_nic *efx = channel->efx;
-	int rx_packets;
+	int spent;
 
 	if (unlikely(efx->reset_pending != RESET_TYPE_NONE ||
 		     !channel->enabled))
 		return 0;
 
-	rx_packets = efx_nic_process_eventq(channel, rx_quota);
-	if (rx_packets == 0)
+	spent = efx_nic_process_eventq(channel, budget);
+	if (spent == 0)
 		return 0;
 
 	/* Deliver last RX packet. */
@@ -249,7 +249,7 @@ static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 
 	efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
 
-	return rx_packets;
+	return spent;
 }
 
 /* Mark channel as finished processing
@@ -278,14 +278,14 @@ static int efx_poll(struct napi_struct *napi, int budget)
 {
 	struct efx_channel *channel =
 		container_of(napi, struct efx_channel, napi_str);
-	int rx_packets;
+	int spent;
 
 	EFX_TRACE(channel->efx, "channel %d NAPI poll executing on CPU %d\n",
 		  channel->channel, raw_smp_processor_id());
 
-	rx_packets = efx_process_channel(channel, budget);
+	spent = efx_process_channel(channel, budget);
 
-	if (rx_packets < budget) {
+	if (spent < budget) {
 		struct efx_nic *efx = channel->efx;
 
 		if (channel->used_flags & EFX_USED_BY_RX &&
@@ -318,7 +318,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		efx_channel_processed(channel);
 	}
 
-	return rx_packets;
+	return spent;
 }
 
 /* Process the eventq of the specified channel immediately on this CPU
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 4105f90..f3226bb 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -654,22 +654,23 @@ void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
  * The NIC batches TX completion events; the message we receive is of
  * the form "complete all TX events up to this index".
  */
-static void
+static int
 efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	unsigned int tx_ev_desc_ptr;
 	unsigned int tx_ev_q_label;
 	struct efx_tx_queue *tx_queue;
 	struct efx_nic *efx = channel->efx;
+	int tx_packets = 0;
 
 	if (likely(EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_COMP))) {
 		/* Transmit completion */
 		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_DESC_PTR);
 		tx_ev_q_label = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
-		channel->irq_mod_score +=
-			(tx_ev_desc_ptr - tx_queue->read_count) &
-			EFX_TXQ_MASK;
+		tx_packets = ((tx_ev_desc_ptr - tx_queue->read_count) &
+			      EFX_TXQ_MASK);
+		channel->irq_mod_score += tx_packets;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
@@ -689,6 +690,8 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 			EFX_QWORD_FMT"\n", channel->channel,
 			EFX_QWORD_VAL(*event));
 	}
+
+	return tx_packets;
 }
 
 /* Detect errors included in the rx_evt_pkt_ok bit. */
@@ -947,16 +950,17 @@ efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 	}
 }
 
-int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota)
+int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 {
 	unsigned int read_ptr;
 	efx_qword_t event, *p_event;
 	int ev_code;
-	int rx_packets = 0;
+	int tx_packets = 0;
+	int spent = 0;
 
 	read_ptr = channel->eventq_read_ptr;
 
-	do {
+	for (;;) {
 		p_event = efx_event(channel, read_ptr);
 		event = *p_event;
 
@@ -970,15 +974,23 @@ int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota)
 		/* Clear this event by marking it all ones */
 		EFX_SET_QWORD(*p_event);
 
+		/* Increment read pointer */
+		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
+
 		ev_code = EFX_QWORD_FIELD(event, FSF_AZ_EV_CODE);
 
 		switch (ev_code) {
 		case FSE_AZ_EV_CODE_RX_EV:
 			efx_handle_rx_event(channel, &event);
-			++rx_packets;
+			if (++spent == budget)
+				goto out;
 			break;
 		case FSE_AZ_EV_CODE_TX_EV:
-			efx_handle_tx_event(channel, &event);
+			tx_packets += efx_handle_tx_event(channel, &event);
+			if (tx_packets >= EFX_TXQ_SIZE) {
+				spent = budget;
+				goto out;
+			}
 			break;
 		case FSE_AZ_EV_CODE_DRV_GEN_EV:
 			channel->eventq_magic = EFX_QWORD_FIELD(
@@ -1001,14 +1013,11 @@ int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota)
 				" (data " EFX_QWORD_FMT ")\n", channel->channel,
 				ev_code, EFX_QWORD_VAL(event));
 		}
+	}
 
-		/* Increment read pointer */
-		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
-
-	} while (rx_packets < rx_quota);
-
+out:
 	channel->eventq_read_ptr = read_ptr;
-	return rx_packets;
+	return spent;
 }
 

-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

