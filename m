From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v3] ether3: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 10:46:50 +0200
Message-ID: <1282121210-7576-1-git-send-email-tklauser@distanz.ch>
References: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
Cc: linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Carpenter <error27@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:38370 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab0HRIqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 04:46:52 -0400
In-Reply-To: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the ether1_priv struct. As the new
ndo_get_stats function would just return dev->stats we can omit it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/arm/ether3.c |   33 +++++++++++----------------------
 drivers/net/arm/ether3.h |    1 -
 2 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 1361b73..cebf2da 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -81,7 +81,6 @@ static int	ether3_open (struct net_device *dev);
 static int	ether3_sendpacket (struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t ether3_interrupt (int irq, void *dev_id);
 static int	ether3_close (struct net_device *dev);
-static struct net_device_stats *ether3_getstats (struct net_device *dev);
 static void	ether3_setmulticastlist (struct net_device *dev);
 static void	ether3_timeout(struct net_device *dev);
 
@@ -323,7 +322,7 @@ ether3_init_for_open(struct net_device *dev)
 {
 	int i;
 
-	memset(&priv(dev)->stats, 0, sizeof(struct net_device_stats));
+	memset(&dev->stats, 0, sizeof(struct net_device_stats));
 
 	/* Reset the chip */
 	ether3_outw(CFG2_RESET, REG_CONFIG2);
@@ -442,15 +441,6 @@ ether3_close(struct net_device *dev)
 }
 
 /*
- * Get the current statistics.	This may be called with the card open or
- * closed.
- */
-static struct net_device_stats *ether3_getstats(struct net_device *dev)
-{
-	return &priv(dev)->stats;
-}
-
-/*
  * Set or clear promiscuous/multicast mode filter for this adaptor.
  *
  * We don't attempt any packet filtering.  The card may have a SEEQ 8004
@@ -490,7 +480,7 @@ static void ether3_timeout(struct net_device *dev)
 	local_irq_restore(flags);
 
 	priv(dev)->regs.config2 |= CFG2_CTRLO;
-	priv(dev)->stats.tx_errors += 1;
+	dev->stats.tx_errors += 1;
 	ether3_outw(priv(dev)->regs.config2, REG_CONFIG2);
 	priv(dev)->tx_head = priv(dev)->tx_tail = 0;
 
@@ -509,7 +499,7 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 
 	if (priv(dev)->broken) {
 		dev_kfree_skb(skb);
-		priv(dev)->stats.tx_dropped ++;
+		dev->stats.tx_dropped++;
 		netif_start_queue(dev);
 		return NETDEV_TX_OK;
 	}
@@ -673,7 +663,7 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
 			} else
 				goto dropping;
 		} else {
-			struct net_device_stats *stats = &priv(dev)->stats;
+			struct net_device_stats *stats = &dev->stats;
 			ether3_outw(next_ptr >> 8, REG_RECVEND);
 			if (status & RXSTAT_OVERSIZE)	  stats->rx_over_errors ++;
 			if (status & RXSTAT_CRCERROR)	  stats->rx_crc_errors ++;
@@ -685,14 +675,14 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
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
@@ -710,7 +700,7 @@ dropping:{
 		last_warned = jiffies;
 		printk("%s: memory squeeze, dropping packet.\n", dev->name);
 	}
-	priv(dev)->stats.rx_dropped ++;
+	dev->stats.rx_dropped++;
 	goto done;
 	}
 }
@@ -743,13 +733,13 @@ static void ether3_tx(struct net_device *dev)
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
@@ -773,7 +763,6 @@ static const struct net_device_ops ether3_netdev_ops = {
 	.ndo_open		= ether3_open,
 	.ndo_stop		= ether3_close,
 	.ndo_start_xmit		= ether3_sendpacket,
-	.ndo_get_stats		= ether3_getstats,
 	.ndo_set_multicast_list	= ether3_setmulticastlist,
 	.ndo_tx_timeout		= ether3_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
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

