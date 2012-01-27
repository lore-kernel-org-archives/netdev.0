From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 31/32] sfc: Move the end of the non-GRO RX path
 into its own function
Date: Fri, 27 Jan 2012 20:54:06 +0000
Message-ID: <1327697646.2503.39.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63893 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752835Ab2A0UyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:54:09 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |   41 +++++++++++++++++++++++------------------
 1 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 3572c34..d97c6eb 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -568,12 +568,30 @@ out:
 	channel->rx_pkt_csummed = checksummed;
 }
 
+static void efx_rx_deliver(struct efx_channel *channel,
+			   struct efx_rx_buffer *rx_buf)
+{
+	struct sk_buff *skb;
+
+	/* We now own the SKB */
+	skb = rx_buf->u.skb;
+	rx_buf->u.skb = NULL;
+
+	/* Set the SKB flags */
+	skb_checksum_none_assert(skb);
+
+	/* Pass the packet up */
+	netif_receive_skb(skb);
+
+	/* Update allocation strategy method */
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+}
+
 /* Handle a received packet.  Second half: Touches packet payload. */
 void __efx_rx_packet(struct efx_channel *channel,
 		     struct efx_rx_buffer *rx_buf, bool checksummed)
 {
 	struct efx_nic *efx = channel->efx;
-	struct sk_buff *skb;
 	u8 *eh = efx_rx_buf_eh(efx, rx_buf);
 
 	/* If we're in loopback test, then pass the packet directly to the
@@ -586,7 +604,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	}
 
 	if (!rx_buf->is_page) {
-		skb = rx_buf->u.skb;
+		struct sk_buff *skb = rx_buf->u.skb;
 
 		prefetch(skb_shinfo(skb));
 
@@ -606,23 +624,10 @@ void __efx_rx_packet(struct efx_channel *channel,
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		checksummed = false;
 
-	if (likely(checksummed || rx_buf->is_page)) {
+	if (likely(checksummed || rx_buf->is_page))
 		efx_rx_packet_gro(channel, rx_buf, eh, checksummed);
-		return;
-	}
-
-	/* We now own the SKB */
-	skb = rx_buf->u.skb;
-	rx_buf->u.skb = NULL;
-
-	/* Set the SKB flags */
-	skb_checksum_none_assert(skb);
-
-	/* Pass the packet up */
-	netif_receive_skb(skb);
-
-	/* Update allocation strategy method */
-	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+	else
+		efx_rx_deliver(channel, rx_buf);
 }
 
 void efx_rx_strategy(struct efx_channel *channel)
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
