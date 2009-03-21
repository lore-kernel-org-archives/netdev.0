From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 42/77] smc91c92: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:09 -0700
Message-ID: <20090321053715.720030568@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36633 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760126AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=smc91c92-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/smc91c92_cs.c	2009-03-20 15:51:14.971779412 -0700
+++ b/drivers/net/pcmcia/smc91c92_cs.c	2009-03-20 16:00:43.876651664 -0700
@@ -108,7 +108,7 @@ struct smc_private {
     spinlock_t			lock;
     u_short			manfid;
     u_short			cardid;
-    struct net_device_stats	stats;
+
     dev_node_t			node;
     struct sk_buff		*saved_skb;
     int				packets_waiting;
@@ -289,7 +289,6 @@ static void smc_tx_timeout(struct net_de
 static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t smc_interrupt(int irq, void *dev_id);
 static void smc_rx(struct net_device *dev);
-static struct net_device_stats *smc_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static int s9k_config(struct net_device *dev, struct ifmap *map);
 static void smc_set_xcvr(struct net_device *dev, int if_port);
@@ -337,7 +336,6 @@ static int smc91c92_probe(struct pcmcia_
 
     /* The SMC91c92-specific entries in the device structure. */
     dev->hard_start_xmit = &smc_start_xmit;
-    dev->get_stats = &smc_get_stats;
     dev->set_config = &s9k_config;
     dev->set_multicast_list = &set_rx_mode;
     dev->open = &smc_open;
@@ -1291,7 +1289,7 @@ static void smc_hardware_send_packet(str
 	return;
     }
 
-    smc->stats.tx_bytes += skb->len;
+    dev->stats.tx_bytes += skb->len;
     /* The card should use the just-allocated buffer. */
     outw(packet_no, ioaddr + PNR_ARR);
     /* point to the beginning of the packet */
@@ -1340,7 +1338,7 @@ static void smc_tx_timeout(struct net_de
     printk(KERN_NOTICE "%s: SMC91c92 transmit timed out, "
 	   "Tx_status %2.2x status %4.4x.\n",
 	   dev->name, inw(ioaddr)&0xff, inw(ioaddr + 2));
-    smc->stats.tx_errors++;
+    dev->stats.tx_errors++;
     smc_reset(dev);
     dev->trans_start = jiffies;
     smc->saved_skb = NULL;
@@ -1362,7 +1360,7 @@ static int smc_start_xmit(struct sk_buff
 
     if (smc->saved_skb) {
 	/* THIS SHOULD NEVER HAPPEN. */
-	smc->stats.tx_aborted_errors++;
+	dev->stats.tx_aborted_errors++;
 	printk(KERN_DEBUG "%s: Internal error -- sent packet while busy.\n",
 	       dev->name);
 	return 1;
@@ -1375,7 +1373,7 @@ static int smc_start_xmit(struct sk_buff
 	printk(KERN_ERR "%s: Far too big packet error.\n", dev->name);
 	dev_kfree_skb (skb);
 	smc->saved_skb = NULL;
-	smc->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	return 0;		/* Do not re-queue this packet. */
     }
     /* A packet is now waiting. */
@@ -1433,11 +1431,11 @@ static void smc_tx_err(struct net_device
 
     tx_status = inw(ioaddr + DATA_1);
 
-    smc->stats.tx_errors++;
-    if (tx_status & TS_LOSTCAR) smc->stats.tx_carrier_errors++;
-    if (tx_status & TS_LATCOL)  smc->stats.tx_window_errors++;
+    dev->stats.tx_errors++;
+    if (tx_status & TS_LOSTCAR) dev->stats.tx_carrier_errors++;
+    if (tx_status & TS_LATCOL)  dev->stats.tx_window_errors++;
     if (tx_status & TS_16COL) {
-	smc->stats.tx_aborted_errors++;
+	dev->stats.tx_aborted_errors++;
 	smc->tx_err++;
     }
 
@@ -1474,10 +1472,10 @@ static void smc_eph_irq(struct net_devic
     /* Could be a counter roll-over warning: update stats. */
     card_stats = inw(ioaddr + COUNTER);
     /* single collisions */
-    smc->stats.collisions += card_stats & 0xF;
+    dev->stats.collisions += card_stats & 0xF;
     card_stats >>= 4;
     /* multiple collisions */
-    smc->stats.collisions += card_stats & 0xF;
+    dev->stats.collisions += card_stats & 0xF;
 #if 0 		/* These are for when linux supports these statistics */
     card_stats >>= 4;			/* deferred */
     card_stats >>= 4;			/* excess deferred */
@@ -1551,7 +1549,7 @@ static irqreturn_t smc_interrupt(int irq
 	if (status & IM_TX_EMPTY_INT) {
 	    outw(IM_TX_EMPTY_INT, ioaddr + INTERRUPT);
 	    mask &= ~IM_TX_EMPTY_INT;
-	    smc->stats.tx_packets += smc->packets_waiting;
+	    dev->stats.tx_packets += smc->packets_waiting;
 	    smc->packets_waiting = 0;
 	}
 	if (status & IM_ALLOC_INT) {
@@ -1567,8 +1565,8 @@ static irqreturn_t smc_interrupt(int irq
 	    netif_wake_queue(dev);
 	}
 	if (status & IM_RX_OVRN_INT) {
-	    smc->stats.rx_errors++;
-	    smc->stats.rx_fifo_errors++;
+	    dev->stats.rx_errors++;
+	    dev->stats.rx_fifo_errors++;
 	    if (smc->duplex)
 		smc->rx_ovrn = 1; /* need MC_RESET outside smc_interrupt */
 	    outw(IM_RX_OVRN_INT, ioaddr + INTERRUPT);
@@ -1618,7 +1616,6 @@ irq_done:
 
 static void smc_rx(struct net_device *dev)
 {
-    struct smc_private *smc = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int rx_status;
     int packet_length;	/* Caution: not frame length, rather words
@@ -1649,7 +1646,7 @@ static void smc_rx(struct net_device *de
 	
 	if (skb == NULL) {
 	    DEBUG(1, "%s: Low memory, packet dropped.\n", dev->name);
-	    smc->stats.rx_dropped++;
+	    dev->stats.rx_dropped++;
 	    outw(MC_RELEASE, ioaddr + MMU_CMD);
 	    return;
 	}
@@ -1662,18 +1659,18 @@ static void smc_rx(struct net_device *de
 	
 	netif_rx(skb);
 	dev->last_rx = jiffies;
-	smc->stats.rx_packets++;
-	smc->stats.rx_bytes += packet_length;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += packet_length;
 	if (rx_status & RS_MULTICAST)
-	    smc->stats.multicast++;
+	    dev->stats.multicast++;
     } else {
 	/* error ... */
-	smc->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	
-	if (rx_status & RS_ALGNERR)  smc->stats.rx_frame_errors++;
+	if (rx_status & RS_ALGNERR)  dev->stats.rx_frame_errors++;
 	if (rx_status & (RS_TOOSHORT | RS_TOOLONG))
-	    smc->stats.rx_length_errors++;
-	if (rx_status & RS_BADCRC)	smc->stats.rx_crc_errors++;
+	    dev->stats.rx_length_errors++;
+	if (rx_status & RS_BADCRC)	dev->stats.rx_crc_errors++;
     }
     /* Let the MMU free the memory of this packet. */
     outw(MC_RELEASE, ioaddr + MMU_CMD);
@@ -1681,15 +1678,6 @@ static void smc_rx(struct net_device *de
     return;
 }
 
-/*====================================================================*/
-
-static struct net_device_stats *smc_get_stats(struct net_device *dev)
-{
-    struct smc_private *smc = netdev_priv(dev);
-    /* Nothing to update - the 91c92 is a pretty primative chip. */
-    return &smc->stats;
-}
-
 /*======================================================================
 
     Calculate values for the hardware multicast filter hash table.

-- 

