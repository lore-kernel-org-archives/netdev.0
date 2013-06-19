From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/11] sfc: Implement RX SKB cache to improve
 latency
Date: Wed, 19 Jun 2013 23:20:14 +0100
Message-ID: <1371680414.1956.115.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10474 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964822Ab3FSWUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:20:17 -0400
In-Reply-To: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Allocate skbs in batches, instead of just after receiving each packet.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |  4 +++
 drivers/net/ethernet/sfc/rx.c         | 49 ++++++++++++++++++++++++++++++++---
 2 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 60da43e..d8e32e0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -323,6 +323,10 @@ struct efx_rx_queue {
 	unsigned int recycle_count;
 	struct timer_list slow_fill;
 	unsigned int slow_fill_count;
+
+#define SKB_CACHE_SIZE 8
+	struct sk_buff *skb_cache[SKB_CACHE_SIZE];
+	unsigned skb_cache_next_unused;
 };
 
 /**
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 5c45118..a28f2fe 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -104,6 +104,31 @@ void efx_rx_config_page_split(struct efx_nic *efx)
 					       efx->rx_bufs_per_page);
 }
 
+static void efx_refill_skb_cache(struct efx_rx_queue *rx_queue)
+{
+	int i;
+	for (i = 0; i < SKB_CACHE_SIZE; ++i) {
+		rx_queue->skb_cache[i] =
+			netdev_alloc_skb(rx_queue->efx->net_dev,
+					 EFX_SKB_HEADERS + EFX_PAGE_SKB_ALIGN);
+	}
+	rx_queue->skb_cache_next_unused = 0;
+}
+
+static void efx_refill_skb_cache_check(struct efx_rx_queue *rx_queue)
+{
+	if (rx_queue->skb_cache_next_unused == SKB_CACHE_SIZE)
+		efx_refill_skb_cache(rx_queue);
+}
+
+static void efx_fini_skb_cache(struct efx_rx_queue *rx_queue)
+{
+	/* free unused skbs in the cache */
+	while (rx_queue->skb_cache_next_unused < SKB_CACHE_SIZE)
+		dev_kfree_skb(
+			rx_queue->skb_cache[rx_queue->skb_cache_next_unused++]);
+}
+
 /* Check the RX page recycle ring for a page that can be reused. */
 static struct page *efx_reuse_page(struct efx_rx_queue *rx_queue)
 {
@@ -454,12 +479,20 @@ static struct sk_buff *efx_rx_mk_skb(struct efx_channel *channel,
 				     u8 *eh, int hdr_len)
 {
 	struct efx_nic *efx = channel->efx;
-	struct sk_buff *skb;
+	struct efx_rx_queue *rx_queue = efx_channel_get_rx_queue(channel);
+	struct sk_buff *skb = NULL;
 
 	/* Allocate an SKB to store the headers */
-	skb = netdev_alloc_skb(efx->net_dev, hdr_len + EFX_PAGE_SKB_ALIGN);
-	if (unlikely(skb == NULL))
-		return NULL;
+	if (hdr_len <= EFX_SKB_HEADERS &&
+	    likely(rx_queue->skb_cache_next_unused < SKB_CACHE_SIZE)) {
+		skb = rx_queue->skb_cache[rx_queue->skb_cache_next_unused++];
+	}
+	if (unlikely(!skb)) {
+		skb = netdev_alloc_skb(efx->net_dev,
+				       hdr_len + EFX_PAGE_SKB_ALIGN);
+		if (unlikely(skb == NULL))
+			return NULL;
+	}
 
 	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
 
@@ -580,6 +613,9 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	efx_rx_flush_packet(channel);
 	channel->rx_pkt_n_frags = n_frags;
 	channel->rx_pkt_index = index;
+
+	/* refill skb cache if needed */
+	efx_refill_skb_cache_check(rx_queue);
 }
 
 static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
@@ -729,6 +765,9 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	/* Set up RX descriptor ring */
 	rx_queue->enabled = true;
 	efx_nic_init_rx(rx_queue);
+
+	/* fill SKB cache */
+	efx_refill_skb_cache(rx_queue);
 }
 
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
@@ -756,6 +795,8 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 		}
 	}
 
+	efx_fini_skb_cache(rx_queue);
+
 	/* Unmap and release the pages in the recycle ring. Remove the ring. */
 	for (i = 0; i <= rx_queue->page_ptr_mask; i++) {
 		struct page *page = rx_queue->page_ring[i];


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
