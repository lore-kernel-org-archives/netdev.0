From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: via-rhine: add BQL support
Date: Tue, 24 Feb 2015 10:28:01 -0800
Message-ID: <1424802481.5565.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPAfteyQ-svk9zVun5gmsTUpS4tnhDb=DEo1t9U_=_5a0Kz8nA@mail.gmail.com>
	 <1424303064.4942.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPAftezaVxQhEim=kZFQJS2RX-f6a-eKnUJ=rz3ax4qLEV_Yug@mail.gmail.com>
	 <1424304456.4942.102.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPAfteyyB_4ScJYnTf47SxDRiyyAe5Rg=4vnERzbPW7jBGTAFw@mail.gmail.com>
	 <CAPAfteyiuPg2NAsggYp_mPRRAGoWAp4ut76zLhEVnkoABK7t6w@mail.gmail.com>
	 <1424312906.4942.115.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tino Reichardt <milky-kernel@mcmilk.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:41974 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbBXS2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 13:28:03 -0500
Received: by iecrd18 with SMTP id rd18so34372448iec.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 10:28:02 -0800 (PST)
In-Reply-To: <1424312906.4942.115.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tino Reichardt <milky-kernel@mcmilk.de>

Add Byte Queue Limits (BQL) support to via-rhine driver.

[edumazet] tweaked patch and changed TX_RING_SIZE from 16 to 64

Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>
Tested-by: Jamie Gloudon <jamie.gloudon@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/via/via-rhine.c |   29 +++++++++++++++++--------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 17e276651601b27c393001cdd5593cddcd828788..8fb807ea1caa84f102b709314f9a6208dc4549a9 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -70,12 +70,14 @@ static const int multicast_filter_limit = 32;
 /* Operational parameters that are set at compile time. */
 
 /* Keep the ring sizes a power of two for compile efficiency.
-   The compiler will convert <unsigned>'%'<2^N> into a bit mask.
-   Making the Tx ring too large decreases the effectiveness of channel
-   bonding and packet priority.
-   There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
-#define TX_QUEUE_LEN	10	/* Limit ring entries actually used. */
+ * The compiler will convert <unsigned>'%'<2^N> into a bit mask.
+ * Making the Tx ring too large decreases the effectiveness of channel
+ * bonding and packet priority.
+ * With BQL support, we can increase TX ring safely.
+ * There are no ill effects from too-large receive rings.
+ */
+#define TX_RING_SIZE	64
+#define TX_QUEUE_LEN	(TX_RING_SIZE - 6)	/* Limit ring entries actually used. */
 #define RX_RING_SIZE	64
 
 /* Operational parameters that usually are not changed. */
@@ -1295,6 +1297,7 @@ static void alloc_tbufs(struct net_device* dev)
 	}
 	rp->tx_ring[i-1].next_desc = cpu_to_le32(rp->tx_ring_dma);
 
+	netdev_reset_queue(dev);
 }
 
 static void free_tbufs(struct net_device* dev)
@@ -1795,6 +1798,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	else
 		rp->tx_ring[entry].tx_status = 0;
 
+	netdev_sent_queue(dev, skb->len);
 	/* lock eth irq */
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
@@ -1863,6 +1867,8 @@ static void rhine_tx(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	struct device *hwdev = dev->dev.parent;
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
+	struct sk_buff *skb;
 
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
@@ -1871,6 +1877,7 @@ static void rhine_tx(struct net_device *dev)
 			  entry, txstatus);
 		if (txstatus & DescOwn)
 			break;
+		skb = rp->tx_skbuff[entry];
 		if (txstatus & 0x8000) {
 			netif_dbg(rp, tx_done, dev,
 				  "Transmit error, Tx status %08x\n", txstatus);
@@ -1899,7 +1906,7 @@ static void rhine_tx(struct net_device *dev)
 				  (txstatus >> 3) & 0xF, txstatus & 0xF);
 
 			u64_stats_update_begin(&rp->tx_stats.syncp);
-			rp->tx_stats.bytes += rp->tx_skbuff[entry]->len;
+			rp->tx_stats.bytes += skb->len;
 			rp->tx_stats.packets++;
 			u64_stats_update_end(&rp->tx_stats.syncp);
 		}
@@ -1907,13 +1914,17 @@ static void rhine_tx(struct net_device *dev)
 		if (rp->tx_skbuff_dma[entry]) {
 			dma_unmap_single(hwdev,
 					 rp->tx_skbuff_dma[entry],
-					 rp->tx_skbuff[entry]->len,
+					 skb->len,
 					 DMA_TO_DEVICE);
 		}
-		dev_consume_skb_any(rp->tx_skbuff[entry]);
+		bytes_compl += skb->len;
+		pkts_compl++;
+		dev_consume_skb_any(skb);
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
+
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
 }
