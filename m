From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ether3: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 18:15:33 +0200
Message-ID: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
Cc: linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34380 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757856Ab0HQQPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:15:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the ether1_priv struct.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/ether3.c |   20 ++++++++++----------
 drivers/net/arm/ether3.h |    1 -
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 1361b73..9fc411e 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -447,7 +447,7 @@ ether3_close(struct net_device *dev)
  */
 static struct net_device_stats *ether3_getstats(struct net_device *dev)
 {
-	return &priv(dev)->stats;
+	return &dev->stats;
 }
 
 /*
@@ -490,7 +490,7 @@ static void ether3_timeout(struct net_device *dev)
 	local_irq_restore(flags);
 
 	priv(dev)->regs.config2 |= CFG2_CTRLO;
-	priv(dev)->stats.tx_errors += 1;
+	dev->stats.tx_errors += 1;
 	ether3_outw(priv(dev)->regs.config2, REG_CONFIG2);
 	priv(dev)->tx_head = priv(dev)->tx_tail = 0;
 
@@ -509,7 +509,7 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 
 	if (priv(dev)->broken) {
 		dev_kfree_skb(skb);
-		priv(dev)->stats.tx_dropped ++;
+		dev->stats.tx_dropped++;
 		netif_start_queue(dev);
 		return NETDEV_TX_OK;
 	}
@@ -685,14 +685,14 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
 	while (-- maxcnt);
 
 done:
-	priv(dev)->stats.rx_packets += received;
+	dev->stats.rx_packets += received;
 	priv(dev)->rx_head = next_ptr;
 	/*
 	 * If rx went off line, then that means that the buffer may be full.  We
 	 * have dropped at least one packet.
 	 */
 	if (!(ether3_inw(REG_STATUS) & STAT_RXON)) {
-		priv(dev)->stats.rx_dropped ++;
+		dev->stats.rx_dropped++;
     		ether3_outw(next_ptr, REG_RECVPTR);
 		ether3_outw(priv(dev)->regs.command | CMD_RXON, REG_COMMAND);
 	}
@@ -710,7 +710,7 @@ dropping:{
 		last_warned = jiffies;
 		printk("%s: memory squeeze, dropping packet.\n", dev->name);
 	}
-	priv(dev)->stats.rx_dropped ++;
+	dev->stats.rx_dropped++;
 	goto done;
 	}
 }
@@ -743,13 +743,13 @@ static void ether3_tx(struct net_device *dev)
 		 * Update errors
 		 */
 		if (!(status & (TXSTAT_BABBLED | TXSTAT_16COLLISIONS)))
-			priv(dev)->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		else {
-			priv(dev)->stats.tx_errors ++;
+			dev->stats.tx_errors++;
 			if (status & TXSTAT_16COLLISIONS)
-				priv(dev)->stats.collisions += 16;
+				dev->stats.collisions += 16;
 			if (status & TXSTAT_BABBLED)
-				priv(dev)->stats.tx_fifo_errors ++;
+				dev->stats.tx_fifo_errors++;
 		}
 
 		tx_tail = (tx_tail + 1) & 15;
diff --git a/drivers/net/arm/ether3.h b/drivers/net/arm/ether3.h
index 1921a3a..2db63b0 100644
--- a/drivers/net/arm/ether3.h
+++ b/drivers/net/arm/ether3.h
@@ -164,7 +164,6 @@ struct dev_priv {
     unsigned char tx_head;		/* buffer nr to insert next packet	 */
     unsigned char tx_tail;		/* buffer nr of transmitting packet	 */
     unsigned int rx_head;		/* address to fetch next packet from	 */
-    struct net_device_stats stats;
     struct timer_list timer;
     int broken;				/* 0 = ok, 1 = something went wrong	 */
 };
-- 
1.7.0.4

