From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] am79c961a: Use net_device_stats from struct net_device
Date: Mon,  9 Aug 2010 17:04:34 +0200
Message-ID: <1281366274-28796-1-git-send-email-tklauser@distanz.ch>
Cc: Russell King <linux@arm.linux.org.uk>,
	Kulikov Vasiliy <segooon@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:37645 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756765Ab0HIPEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 11:04:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so we can
use this one instead of a private copy in the dev_priv struct.

Cc: Kulikov Vasiliy <segooon@gmail.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/am79c961a.c |   35 ++++++++++++++++-------------------
 drivers/net/arm/am79c961a.h |    1 -
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 8c496fb..62f2110 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -300,8 +300,6 @@ am79c961_open(struct net_device *dev)
 	struct dev_priv *priv = netdev_priv(dev);
 	int ret;
 
-	memset (&priv->stats, 0, sizeof (priv->stats));
-
 	ret = request_irq(dev->irq, am79c961_interrupt, 0, dev->name, dev);
 	if (ret)
 		return ret;
@@ -347,8 +345,7 @@ am79c961_close(struct net_device *dev)
  */
 static struct net_device_stats *am79c961_getstats (struct net_device *dev)
 {
-	struct dev_priv *priv = netdev_priv(dev);
-	return &priv->stats;
+	return &dev->stats;
 }
 
 static void am79c961_mc_hash(char *addr, unsigned short *hash)
@@ -510,14 +507,14 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 
 		if ((status & (RMD_ERR|RMD_STP|RMD_ENP)) != (RMD_STP|RMD_ENP)) {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
-			priv->stats.rx_errors ++;
+			dev->stats.rx_errors++;
 			if (status & RMD_ERR) {
 				if (status & RMD_FRAM)
-					priv->stats.rx_frame_errors ++;
+					dev->stats.rx_frame_errors++;
 				if (status & RMD_CRC)
-					priv->stats.rx_crc_errors ++;
+					dev->stats.rx_crc_errors++;
 			} else if (status & RMD_STP)
-				priv->stats.rx_length_errors ++;
+				dev->stats.rx_length_errors++;
 			continue;
 		}
 
@@ -531,12 +528,12 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 			am_writeword(dev, hdraddr + 2, RMD_OWN);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			priv->stats.rx_bytes += len;
-			priv->stats.rx_packets ++;
+			dev->stats.rx_bytes += len;
+			dev->stats.rx_packets++;
 		} else {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
 			printk (KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
-			priv->stats.rx_dropped ++;
+			dev->stats.rx_dropped++;
 			break;
 		}
 	} while (1);
@@ -565,7 +562,7 @@ am79c961_tx(struct net_device *dev, struct dev_priv *priv)
 		if (status & TMD_ERR) {
 			u_int status2;
 
-			priv->stats.tx_errors ++;
+			dev->stats.tx_errors++;
 
 			status2 = am_readword (dev, hdraddr + 6);
 
@@ -575,18 +572,18 @@ am79c961_tx(struct net_device *dev, struct dev_priv *priv)
 			am_writeword (dev, hdraddr + 6, 0);
 
 			if (status2 & TST_RTRY)
-				priv->stats.collisions += 16;
+				dev->stats.collisions += 16;
 			if (status2 & TST_LCOL)
-				priv->stats.tx_window_errors ++;
+				dev->stats.tx_window_errors++;
 			if (status2 & TST_LCAR)
-				priv->stats.tx_carrier_errors ++;
+				dev->stats.tx_carrier_errors++;
 			if (status2 & TST_UFLO)
-				priv->stats.tx_fifo_errors ++;
+				dev->stats.tx_fifo_errors++;
 			continue;
 		}
-		priv->stats.tx_packets ++;
+		dev->stats.tx_packets++;
 		len = am_readword (dev, hdraddr + 4);
-		priv->stats.tx_bytes += -len;
+		dev->stats.tx_bytes += -len;
 	} while (priv->txtail != priv->txhead);
 
 	netif_wake_queue(dev);
@@ -616,7 +613,7 @@ am79c961_interrupt(int irq, void *dev_id)
 		}
 		if (status & CSR0_MISS) {
 			handled = 1;
-			priv->stats.rx_dropped ++;
+			dev->stats.rx_dropped++;
 		}
 		if (status & CSR0_CERR) {
 			handled = 1;
diff --git a/drivers/net/arm/am79c961a.h b/drivers/net/arm/am79c961a.h
index 483009f..fd634d3 100644
--- a/drivers/net/arm/am79c961a.h
+++ b/drivers/net/arm/am79c961a.h
@@ -130,7 +130,6 @@
 #define ISALED0_LNKST	0x8000
 
 struct dev_priv {
-    struct net_device_stats stats;
     unsigned long	rxbuffer[RX_BUFFERS];
     unsigned long	txbuffer[TX_BUFFERS];
     unsigned char	txhead;
-- 
1.7.0.4

