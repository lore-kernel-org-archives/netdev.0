From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 10/14] net: sunhme: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:35 +0200
Message-ID: <20170407081739.5243-11-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34512 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755464AbdDGIRu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:50 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
happy_meal, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/sun/sunhme.c | 22 +++++++++++-----------
 drivers/net/ethernet/sun/sunhme.h |  2 --
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 53ff66ef53ac..a6cc9a2d41c1 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -933,7 +933,7 @@ static void happy_meal_stop(struct happy_meal *hp, void __iomem *gregs)
 /* hp->happy_lock must be held */
 static void happy_meal_get_counters(struct happy_meal *hp, void __iomem *bregs)
 {
-	struct net_device_stats *stats = &hp->net_stats;
+	struct net_device_stats *stats = &hp->dev->stats;
 
 	stats->rx_crc_errors += hme_read32(hp, bregs + BMAC_RCRCECTR);
 	hme_write32(hp, bregs + BMAC_RCRCECTR, 0);
@@ -1947,7 +1947,7 @@ static void happy_meal_tx(struct happy_meal *hp)
 				break;
 		}
 		hp->tx_skbs[elem] = NULL;
-		hp->net_stats.tx_bytes += skb->len;
+		dev->stats.tx_bytes += skb->len;
 
 		for (frag = 0; frag <= skb_shinfo(skb)->nr_frags; frag++) {
 			dma_addr = hme_read_desc32(hp, &this->tx_addr);
@@ -1964,7 +1964,7 @@ static void happy_meal_tx(struct happy_meal *hp)
 		}
 
 		dev_kfree_skb_irq(skb);
-		hp->net_stats.tx_packets++;
+		dev->stats.tx_packets++;
 	}
 	hp->tx_old = elem;
 	TXD((">"));
@@ -2009,17 +2009,17 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 		/* Check for errors. */
 		if ((len < ETH_ZLEN) || (flags & RXFLAG_OVERFLOW)) {
 			RXD(("ERR(%08x)]", flags));
-			hp->net_stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (len < ETH_ZLEN)
-				hp->net_stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (len & (RXFLAG_OVERFLOW >> 16)) {
-				hp->net_stats.rx_over_errors++;
-				hp->net_stats.rx_fifo_errors++;
+				dev->stats.rx_over_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 
 			/* Return it to the Happy meal. */
 	drop_it:
-			hp->net_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			hme_write_rxd(hp, this,
 				      (RXFLAG_OWN|((RX_BUF_ALLOC_SIZE-RX_OFFSET)<<16)),
 				      dma_addr);
@@ -2084,8 +2084,8 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 
-		hp->net_stats.rx_packets++;
-		hp->net_stats.rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 	next:
 		elem = NEXT_RX(elem);
 		this = &rxbase[elem];
@@ -2396,7 +2396,7 @@ static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
 	happy_meal_get_counters(hp, hp->bigmacregs);
 	spin_unlock_irq(&hp->happy_lock);
 
-	return &hp->net_stats;
+	return &dev->stats;
 }
 
 static void happy_meal_set_multicast(struct net_device *dev)
diff --git a/drivers/net/ethernet/sun/sunhme.h b/drivers/net/ethernet/sun/sunhme.h
index 4a8d5b18dfd5..3af540adb3c5 100644
--- a/drivers/net/ethernet/sun/sunhme.h
+++ b/drivers/net/ethernet/sun/sunhme.h
@@ -418,8 +418,6 @@ struct happy_meal {
 
 	int rx_new, tx_new, rx_old, tx_old;
 
-	struct net_device_stats	  net_stats;      /* Statistical counters              */
-
 #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
 	u32 (*read32)(void __iomem *);
 	void (*write32)(void __iomem *, u32);
-- 
2.12.2
