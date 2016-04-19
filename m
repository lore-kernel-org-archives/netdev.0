From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 14:35:00 +0100
Message-ID: <57163404.2000507@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:47492 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752213AbcDSNfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:35:11 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improves packet rate of 1-byte UDP receives by 10%.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 9 +++++++++
 drivers/net/ethernet/sfc/efx.c        | 2 ++
 drivers/net/ethernet/sfc/net_driver.h | 3 +++
 drivers/net/ethernet/sfc/rx.c         | 7 ++++++-
 4 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 98d33d4..e348f8f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2656,6 +2656,7 @@ static int efx_ef10_ev_process(struct efx_channel *channel, int quota)
 {
 	struct efx_nic *efx = channel->efx;
 	efx_qword_t event, *p_event;
+	struct sk_buff_head rx_list;
 	unsigned int read_ptr;
 	int ev_code;
 	int tx_descs = 0;
@@ -2664,6 +2665,11 @@ static int efx_ef10_ev_process(struct efx_channel *channel, int quota)
 	if (quota <= 0)
 		return spent;
 
+	/* Prepare the batch receive list */
+	EFX_BUG_ON_PARANOID(channel->rx_list != NULL);
+	channel->rx_list = &rx_list;
+	__skb_queue_head_init(channel->rx_list);
+
 	read_ptr = channel->eventq_read_ptr;
 
 	for (;;) {
@@ -2724,6 +2730,9 @@ static int efx_ef10_ev_process(struct efx_channel *channel, int quota)
 	}
 
 out:
+	/* Receive any packets we queued up */
+	netif_receive_skb_list(channel->rx_list);
+	channel->rx_list = NULL;
 	channel->eventq_read_ptr = read_ptr;
 	return spent;
 }
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0705ec86..e004c0b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -527,6 +527,8 @@ static int efx_probe_channel(struct efx_channel *channel)
 			goto fail;
 	}
 
+	channel->rx_list = NULL;
+
 	return 0;
 
 fail:
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 38c4223..d969c85 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -418,6 +418,7 @@ enum efx_sync_events_state {
  *	__efx_rx_packet(), or zero if there is none
  * @rx_pkt_index: Ring index of first buffer for next packet to be delivered
  *	by __efx_rx_packet(), if @rx_pkt_n_frags != 0
+ * @rx_list: list of SKBs from current RX, awaiting processing
  * @rx_queue: RX queue for this channel
  * @tx_queue: TX queues for this channel
  * @sync_events_state: Current state of sync events on this channel
@@ -462,6 +463,8 @@ struct efx_channel {
 	unsigned int rx_pkt_n_frags;
 	unsigned int rx_pkt_index;
 
+	struct sk_buff_head *rx_list;
+
 	struct efx_rx_queue rx_queue;
 	struct efx_tx_queue tx_queue[EFX_TXQ_TYPES];
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8956995..025e387 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -642,7 +642,12 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 			return;
 
 	/* Pass the packet up */
-	netif_receive_skb(skb);
+	if (channel->rx_list != NULL)
+		/* Add to list, will pass up later */
+		__skb_queue_tail(channel->rx_list, skb);
+	else
+		/* No list, so pass it up now */
+		netif_receive_skb(skb);
 }
 
 /* Handle a received packet.  Second half: Touches packet payload. */
