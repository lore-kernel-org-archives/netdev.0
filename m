From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/11] sfc: Add channel specific receive_skb
 handler and post_remove callback
Date: Wed, 19 Sep 2012 20:15:26 +0100
Message-ID: <1348082126.2636.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20154 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756946Ab2ISTP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:15:29 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stuart Hodgson <smhodgson@solarflare.com>

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
 drivers/net/ethernet/sfc/rx.c         |   13 +++++++++++--
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 342a1f3..8b79a64 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -734,6 +734,7 @@ static void efx_remove_channel(struct efx_channel *channel)
 	efx_for_each_possible_channel_tx_queue(tx_queue, channel)
 		efx_remove_tx_queue(tx_queue);
 	efx_remove_eventq(channel);
+	channel->type->post_remove(channel);
 }
 
 static void efx_remove_channels(struct efx_nic *efx)
@@ -852,6 +853,7 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue)
 
 static const struct efx_channel_type efx_default_channel_type = {
 	.pre_probe		= efx_channel_dummy_op_int,
+	.post_remove		= efx_channel_dummy_op_void,
 	.get_name		= efx_get_channel_name,
 	.copy			= efx_copy_channel,
 	.keep_eventq		= false,
@@ -862,6 +864,10 @@ int efx_channel_dummy_op_int(struct efx_channel *channel)
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
index 70755c9..f11170b 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -102,6 +102,7 @@ static inline void efx_filter_rfs_expire(struct efx_channel *channel) {}
 
 /* Channels */
 extern int efx_channel_dummy_op_int(struct efx_channel *channel);
+extern void efx_channel_dummy_op_void(struct efx_channel *channel);
 extern void efx_process_channel_now(struct efx_channel *channel);
 extern int
 efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 24a78a3..0f0926e 100644
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
index e997f83..9e0ad1b 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -575,7 +575,10 @@ static void efx_rx_deliver(struct efx_channel *channel,
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
 	/* Pass the packet up */
-	netif_receive_skb(skb);
+	if (channel->type->receive_skb)
+		channel->type->receive_skb(channel, skb);
+	else
+		netif_receive_skb(skb);
 
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
@@ -617,7 +620,8 @@ void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		rx_buf->flags &= ~EFX_RX_PKT_CSUMMED;
 
-	if (likely(rx_buf->flags & (EFX_RX_BUF_PAGE | EFX_RX_PKT_CSUMMED)))
+	if (likely(rx_buf->flags & (EFX_RX_BUF_PAGE | EFX_RX_PKT_CSUMMED)) &&
+	    !channel->type->receive_skb)
 		efx_rx_packet_gro(channel, rx_buf, eh);
 	else
 		efx_rx_deliver(channel, rx_buf);
@@ -627,6 +631,11 @@ void efx_rx_strategy(struct efx_channel *channel)
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



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
