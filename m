From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/4] sfc: Fix reading of inserted hash
Date: Fri, 25 Jun 2010 18:05:33 +0100
Message-ID: <1277485533.2094.14.camel@achroite.uk.solarflarecom.com>
References: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20303 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab0FYRFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:05:36 -0400
In-Reply-To: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hash appears immediately before the packet data, not at the
beginning of the buffer. This means we can easily use negative offsets
from the start of packet data, so adjust the data and length at the
top of __efx_rx_packet() instead of wherever we consume the hash.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c       |   11 ++++++-----
 drivers/net/sfc/selftest.c |    3 ---
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 0fb9835..799c461 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -104,9 +104,9 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 static inline u32 efx_rx_buf_hash(struct efx_rx_buffer *buf)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) || NET_IP_ALIGN % 4 == 0
-	return __le32_to_cpup((const __le32 *)buf->data);
+	return __le32_to_cpup((const __le32 *)(buf->data - 4));
 #else
-	const u8 *data = (const u8 *)buf->data;
+	const u8 *data = (const u8 *)(buf->data - 4);
 	return ((u32)data[0]       |
 		(u32)data[1] << 8  |
 		(u32)data[2] << 16 |
@@ -469,8 +469,6 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 
 		if (efx->net_dev->features & NETIF_F_RXHASH)
 			skb->rxhash = efx_rx_buf_hash(rx_buf);
-		rx_buf->data += efx->type->rx_buffer_hash_size;
-		rx_buf->len -= efx->type->rx_buffer_hash_size;
 
 		skb_shinfo(skb)->frags[0].page = page;
 		skb_shinfo(skb)->frags[0].page_offset =
@@ -577,6 +575,9 @@ void __efx_rx_packet(struct efx_channel *channel,
 	struct efx_nic *efx = channel->efx;
 	struct sk_buff *skb;
 
+	rx_buf->data += efx->type->rx_buffer_hash_size;
+	rx_buf->len -= efx->type->rx_buffer_hash_size;
+
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
 	 */
@@ -589,11 +590,11 @@ void __efx_rx_packet(struct efx_channel *channel,
 	if (rx_buf->skb) {
 		prefetch(skb_shinfo(rx_buf->skb));
 
+		skb_reserve(rx_buf->skb, efx->type->rx_buffer_hash_size);
 		skb_put(rx_buf->skb, rx_buf->len);
 
 		if (efx->net_dev->features & NETIF_F_RXHASH)
 			rx_buf->skb->rxhash = efx_rx_buf_hash(rx_buf);
-		skb_pull(rx_buf->skb, efx->type->rx_buffer_hash_size);
 
 		/* Move past the ethernet header. rx_buf->data still points
 		 * at the ethernet header */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0399be2..85f015f 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -258,9 +258,6 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 
 	payload = &state->payload;
 
-	buf_ptr += efx->type->rx_buffer_hash_size;
-	pkt_len -= efx->type->rx_buffer_hash_size;
-
 	received = (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr = payload->ip.saddr;
 	if (state->offload_csum)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

