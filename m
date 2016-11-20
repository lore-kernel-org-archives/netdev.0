From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 12/18] net/ena: refactor skb allocation
Date: Sun, 20 Nov 2016 10:45:41 +0200
Message-ID: <1479631547-29354-13-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To increase readability, refactor skb allocation to dedicated function
This change does not impact the performance since the compiler optimize
the code and elimitate the if condition.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 46 ++++++++++++++++------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 3bc8f43..b478c61 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -787,6 +787,28 @@ static int ena_clean_tx_irq(struct ena_ring *tx_ring, u32 budget)
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
+		netif_err(rx_ring->adapter, rx_err, rx_ring->netdev,
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
@@ -795,8 +817,7 @@ static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
 	struct sk_buff *skb;
 	struct ena_rx_buffer *rx_info =
 		&rx_ring->rx_buffer_info[*next_to_clean];
-	u32 len;
-	u32 buf = 0;
+	u32 len, buf = 0;
 	void *va;
 
 	len = ena_bufs[0].len;
@@ -815,16 +836,9 @@ static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
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
@@ -848,15 +862,9 @@ static struct sk_buff *ena_rx_skb(struct ena_ring *rx_ring,
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
1.9.1
