From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/7] sfc: Add explicit RX queue flag to channel
Date: Wed, 18 Jul 2012 19:19:13 +0100
Message-ID: <1342635553.2617.53.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51745 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751810Ab2GRSTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:19:17 -0400
In-Reply-To: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PTP channel will have its own RX queue even though it's not
a regular traffic channel.

Original work by Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    8 +++++++-
 drivers/net/ethernet/sfc/net_driver.h |    5 ++++-
 drivers/net/ethernet/sfc/rx.c         |    7 +++++--
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 70554a1..3ae6774 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1422,10 +1422,16 @@ static void efx_set_channels(struct efx_nic *efx)
 	efx->tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
 
-	/* We need to adjust the TX queue numbers if we have separate
+	/* We need to mark which channels really have RX and TX
+	 * queues, and adjust the TX queue numbers if we have separate
 	 * RX-only and TX-only channels.
 	 */
 	efx_for_each_channel(channel, efx) {
+		if (channel->channel < efx->n_rx_channels)
+			channel->rx_queue.core_index = channel->channel;
+		else
+			channel->rx_queue.core_index = -1;
+
 		efx_for_each_channel_tx_queue(tx_queue, channel)
 			tx_queue->queue -= (efx->tx_channel_offset *
 					    EFX_TXQ_TYPES);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 55be2fd..3894593 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -242,6 +242,8 @@ struct efx_rx_page_state {
 /**
  * struct efx_rx_queue - An Efx RX queue
  * @efx: The associated Efx NIC
+ * @core_index:  Index of network core RX queue.  Will be >= 0 iff this
+ *	is associated with a real RX queue.
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
  * @ptr_mask: The size of the ring minus 1.
@@ -263,6 +265,7 @@ struct efx_rx_page_state {
  */
 struct efx_rx_queue {
 	struct efx_nic *efx;
+	int core_index;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
 	unsigned int ptr_mask;
@@ -1044,7 +1047,7 @@ static inline bool efx_tx_queue_used(struct efx_tx_queue *tx_queue)
 
 static inline bool efx_channel_has_rx_queue(struct efx_channel *channel)
 {
-	return channel->channel < channel->efx->n_rx_channels;
+	return channel->rx_queue.core_index >= 0;
 }
 
 static inline struct efx_rx_queue *
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 6d1c6cf..3f598bf 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -478,7 +478,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 		skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
 				  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
 
-		skb_record_rx_queue(skb, channel->channel);
+		skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
 		gro_result = napi_gro_frags(napi);
 	} else {
@@ -570,6 +570,9 @@ static void efx_rx_deliver(struct efx_channel *channel,
 	/* Set the SKB flags */
 	skb_checksum_none_assert(skb);
 
+	/* Record the rx_queue */
+	skb_record_rx_queue(skb, channel->rx_queue.core_index);
+
 	/* Pass the packet up */
 	netif_receive_skb(skb);
 
@@ -607,7 +610,7 @@ void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 		 * at the ethernet header */
 		skb->protocol = eth_type_trans(skb, efx->net_dev);
 
-		skb_record_rx_queue(skb, channel->channel);
+		skb_record_rx_queue(skb, channel->rx_queue.core_index);
 	}
 
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
