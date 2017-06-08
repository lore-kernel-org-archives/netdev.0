From: <netanel@amazon.com>
Subject: [PATCH net-next 08/13] net: ena: separate skb allocation to dedicated function
Date: Fri, 9 Jun 2017 01:01:20 +0300
Message-ID: <1496959285-8632-9-git-send-email-netanel@amazon.com>
References: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:13255 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdFHWCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:02:31 -0400
In-Reply-To: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 44 +++++++++++++++++-----------
 1 file changed, 27 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 424b4d7..7dee448 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -825,6 +825,28 @@ static int ena_clean_tx_irq(struct ena_ring *tx_ring, u32 budget)
 	return tx_pkts;
 }
 
+static struct sk_buff *ena_alloc_skb(struct ena_ring *rx_ring, bool frags)
+{
+	struct sk_buff *skb;
+
+	if (frags)
+		skb = napi_get_frags(rx_ring->napi);
+	else
+		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+						rx_ring->rx_copybreak);
+
+	if (unlikely(!skb)) {
+		u64_stats_update_begin(&rx_ring->syncp);
+		rx_ring->rx_stats.skb_alloc_fail++;
+		u64_stats_update_end(&rx_ring->syncp);
+		netif_dbg(rx_ring->adapter, rx_err, rx_ring->netdev,
+			  "Failed to allocate skb. frags: %d\n", frags);
+		return NULL;
+	}
+
+	return skb;
+}
+
 static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
 				  struct ena_com_rx_buf_info *ena_bufs,
 				  u32 descs,
@@ -854,16 +876,9 @@ static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
 	prefetch(va + NET_IP_ALIGN);
 
 	if (len <= rx_ring->rx_copybreak) {
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						rx_ring->rx_copybreak);
-		if (unlikely(!skb)) {
-			u64_stats_update_begin(&rx_ring->syncp);
-			rx_ring->rx_stats.skb_alloc_fail++;
-			u64_stats_update_end(&rx_ring->syncp);
-			netif_err(rx_ring->adapter, rx_err, rx_ring->netdev,
-				  "Failed to allocate skb\n");
+		skb = ena_alloc_skb(rx_ring, false);
+		if (unlikely(!skb))
 			return NULL;
-		}
 
 		netif_dbg(rx_ring->adapter, rx_status, rx_ring->netdev,
 			  "rx allocated small packet. len %d. data_len %d\n",
@@ -882,20 +897,15 @@ static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
 
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+		rx_ring->free_rx_ids[*next_to_clean] = req_id;
 		*next_to_clean = ENA_RX_RING_IDX_ADD(*next_to_clean, descs,
 						     rx_ring->ring_size);
 		return skb;
 	}
 
-	skb = napi_get_frags(rx_ring->napi);
-	if (unlikely(!skb)) {
-		netif_dbg(rx_ring->adapter, rx_status, rx_ring->netdev,
-			  "Failed allocating skb\n");
-		u64_stats_update_begin(&rx_ring->syncp);
-		rx_ring->rx_stats.skb_alloc_fail++;
-		u64_stats_update_end(&rx_ring->syncp);
+	skb = ena_alloc_skb(rx_ring, true);
+	if (unlikely(!skb))
 		return NULL;
-	}
 
 	do {
 		dma_unmap_page(rx_ring->dev,
-- 
2.7.4
