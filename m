From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/7] sfc: Add channel specific receive_skb handler
 and post_remove callback
Date: Wed, 18 Jul 2012 19:20:00 +0100
Message-ID: <1342635600.2617.54.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51780 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752056Ab2GRSUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:20:03 -0400
In-Reply-To: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows an extra channel to override the standard receive_skb handler
and also for extra non generic operations to be performed on remove.

Also set default rx strategy so only skbs can be delivered to the
PTP receive function.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    6 ++++++
 drivers/net/ethernet/sfc/efx.h        |    1 +
 drivers/net/ethernet/sfc/net_driver.h |    3 +++
 drivers/net/ethernet/sfc/rx.c         |   15 ++++++++++++---
 4 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3ae6774..1c53d4b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -714,6 +714,7 @@ static void efx_remove_channel(struct efx_channel *channel)
 	efx_for_each_possible_channel_tx_queue(tx_queue, channel)
 		efx_remove_tx_queue(tx_queue);
 	efx_remove_eventq(channel);
+	channel->type->post_remove(channel);
 }
 
 static void efx_remove_channels(struct efx_nic *efx)
@@ -828,6 +829,7 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue)
 
 static const struct efx_channel_type efx_default_channel_type = {
 	.pre_probe		= efx_channel_dummy_op_int,
+	.post_remove		= efx_channel_dummy_op_void,
 	.get_name		= efx_get_channel_name,
 	.copy			= efx_copy_channel,
 	.keep_eventq		= false,
@@ -838,6 +840,10 @@ int efx_channel_dummy_op_int(struct efx_channel *channel)
 	return 0;
 }
 
+void efx_channel_dummy_op_void(struct efx_channel *channel)
+{
+}
+
 /**************************************************************************
  *
  * Port handling
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index be8f915..121441f 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -96,6 +96,7 @@ static inline void efx_filter_rfs_expire(struct efx_channel *channel) {}
 
 /* Channels */
 extern int efx_channel_dummy_op_int(struct efx_channel *channel);
+extern void efx_channel_dummy_op_void(struct efx_channel *channel);
 extern void efx_process_channel_now(struct efx_channel *channel);
 extern int
 efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 3894593..9913e32 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -393,14 +393,17 @@ struct efx_channel {
  * @get_name: Generate the channel's name (used for its IRQ handler)
  * @copy: Copy the channel state prior to reallocation.  May be %NULL if
  *	reallocation is not supported.
+ * @receive_skb: Handle an skb ready to be passed to netif_receive_skb()
  * @keep_eventq: Flag for whether event queue should be kept initialised
  *	while the device is stopped
  */
 struct efx_channel_type {
 	void (*handle_no_channel)(struct efx_nic *);
 	int (*pre_probe)(struct efx_channel *);
+	void (*post_remove)(struct efx_channel *);
 	void (*get_name)(struct efx_channel *, char *buf, size_t len);
 	struct efx_channel *(*copy)(const struct efx_channel *);
+	void (*receive_skb)(struct efx_channel *, struct sk_buff *);
 	bool keep_eventq;
 };
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 3f598bf..92699a0 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -573,8 +573,11 @@ static void efx_rx_deliver(struct efx_channel *channel,
 	/* Record the rx_queue */
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
-	/* Pass the packet up */
-	netif_receive_skb(skb);
+	/* Does the channel want to handle the skb */
+	if (channel->type->receive_skb)
+		channel->type->receive_skb(channel, skb);
+	else
+		netif_receive_skb(skb);
 
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
@@ -616,7 +619,8 @@ void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		rx_buf->flags &= ~EFX_RX_PKT_CSUMMED;
 
-	if (likely(rx_buf->flags & (EFX_RX_BUF_PAGE | EFX_RX_PKT_CSUMMED)))
+	if (likely(rx_buf->flags & (EFX_RX_BUF_PAGE | EFX_RX_PKT_CSUMMED)) &&
+	    !channel->type->receive_skb)
 		efx_rx_packet_gro(channel, rx_buf, eh);
 	else
 		efx_rx_deliver(channel, rx_buf);
@@ -626,6 +630,11 @@ void efx_rx_strategy(struct efx_channel *channel)
 {
 	enum efx_rx_alloc_method method = rx_alloc_method;
 
+	if (channel->type->receive_skb) {
+		channel->rx_alloc_push_pages = false;
+		return;
+	}
+
 	/* Only makes sense to use page based allocation if GRO is enabled */
 	if (!(channel->efx->net_dev->features & NETIF_F_GRO)) {
 		method = RX_ALLOC_METHOD_SKB;
-- 
1.7.7.6
