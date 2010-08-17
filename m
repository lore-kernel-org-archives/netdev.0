From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ep93xx_eth: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 18:14:38 +0200
Message-ID: <1282061678-19590-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34347 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757784Ab0HQQOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:14:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the ep93xx_priv struct.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/ep93xx_eth.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 4a5ec94..6b37714 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -175,8 +175,6 @@ struct ep93xx_priv
 	struct net_device	*dev;
 	struct napi_struct	napi;
 
-	struct net_device_stats	stats;
-
 	struct mii_if_info	mii;
 	u8			mdc_divisor;
 };
@@ -232,8 +230,7 @@ static void ep93xx_mdio_write(struct net_device *dev, int phy_id, int reg, int d
 
 static struct net_device_stats *ep93xx_get_stats(struct net_device *dev)
 {
-	struct ep93xx_priv *ep = netdev_priv(dev);
-	return &(ep->stats);
+	return &dev->stats;
 }
 
 static int ep93xx_rx(struct net_device *dev, int processed, int budget)
@@ -267,15 +264,15 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 			pr_crit("entry mismatch %.8x %.8x\n", rstat0, rstat1);
 
 		if (!(rstat0 & RSTAT0_RWE)) {
-			ep->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rstat0 & RSTAT0_OE)
-				ep->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			if (rstat0 & RSTAT0_FE)
-				ep->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rstat0 & (RSTAT0_RUNT | RSTAT0_EDATA))
-				ep->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (rstat0 & RSTAT0_CRCE)
-				ep->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			goto err;
 		}
 
@@ -300,10 +297,10 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 
 			netif_receive_skb(skb);
 
-			ep->stats.rx_packets++;
-			ep->stats.rx_bytes += length;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += length;
 		} else {
-			ep->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 
 err:
@@ -359,7 +356,7 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	int entry;
 
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
-		ep->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -415,17 +412,17 @@ static void ep93xx_tx_complete(struct net_device *dev)
 		if (tstat0 & TSTAT0_TXWE) {
 			int length = ep->descs->tdesc[entry].tdesc1 & 0xfff;
 
-			ep->stats.tx_packets++;
-			ep->stats.tx_bytes += length;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += length;
 		} else {
-			ep->stats.tx_errors++;
+			dev->stats.tx_errors++;
 		}
 
 		if (tstat0 & TSTAT0_OW)
-			ep->stats.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 		if (tstat0 & TSTAT0_TXU)
-			ep->stats.tx_fifo_errors++;
-		ep->stats.collisions += (tstat0 >> 16) & 0x1f;
+			dev->stats.tx_fifo_errors++;
+		dev->stats.collisions += (tstat0 >> 16) & 0x1f;
 
 		ep->tx_clean_pointer = (entry + 1) & (TX_QUEUE_ENTRIES - 1);
 		if (ep->tx_pending == TX_QUEUE_ENTRIES)
-- 
1.7.0.4

