From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 54/77] netwave: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:21 -0700
Message-ID: <20090321053716.656878050@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36667 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761036AbZCUFsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:19 -0400
Content-Disposition: inline; filename=netwave-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wireless/netwave_cs.c	2009-03-20 21:45:41.100964205 -0700
+++ b/drivers/net/wireless/netwave_cs.c	2009-03-20 22:14:37.954403178 -0700
@@ -210,10 +210,6 @@ static int netwave_rx( struct net_device
 static irqreturn_t netwave_interrupt(int irq, void *dev_id);
 static void netwave_watchdog(struct net_device *);
 
-/* Statistics */
-static void update_stats(struct net_device *dev);
-static struct net_device_stats *netwave_get_stats(struct net_device *dev);
-
 /* Wireless extensions */
 static struct iw_statistics* netwave_get_wireless_stats(struct net_device *dev);
 
@@ -275,14 +271,9 @@ typedef struct netwave_private {
     int        lastExec;
     struct timer_list      watchdog;	/* To avoid blocking state */
     struct site_survey     nss;
-    struct net_device_stats stats;
     struct iw_statistics   iw_stats;    /* Wireless stats */
 } netwave_private;
 
-#ifdef NETWAVE_STATS
-static struct net_device_stats *netwave_get_stats(struct net_device *dev);
-#endif
-
 /*
  * The Netwave card is little-endian, so won't work for big endian
  * systems.
@@ -413,7 +404,6 @@ static int netwave_probe(struct pcmcia_d
 
     /* Netwave specific entries in the device structure */
     dev->hard_start_xmit = &netwave_start_xmit;
-    dev->get_stats  = &netwave_get_stats;
     dev->set_multicast_list = &set_multicast_list;
     /* wireless extensions */
     dev->wireless_handlers = (struct iw_handler_def *)&netwave_handler_def;
@@ -988,7 +978,7 @@ static int netwave_hw_xmit(unsigned char
 	return 1;
     }
 
-    priv->stats.tx_bytes += len;
+    dev->stats.tx_bytes += len;
 
     DEBUG(3, "Transmitting with SPCQ %x SPU %x LIF %x ISPLQ %x\n",
 	  readb(ramBase + NETWAVE_EREG_SPCQ),
@@ -1107,11 +1097,11 @@ static irqreturn_t netwave_interrupt(int
 	    rser = readb(ramBase + NETWAVE_EREG_RSER);			
 	    
 	    if (rser & 0x04) {
-		++priv->stats.rx_dropped; 
-		++priv->stats.rx_crc_errors;
+		++dev->stats.rx_dropped;
+		++dev->stats.rx_crc_errors;
 	    }
 	    if (rser & 0x02)
-		++priv->stats.rx_frame_errors;
+		++dev->stats.rx_frame_errors;
 			
 	    /* Clear the RxErr bit in RSER. RSER+4 is the
 	     * write part. Also clear the RxCRC (0x04) and 
@@ -1125,8 +1115,8 @@ static irqreturn_t netwave_interrupt(int
 	    wait_WOC(iobase);
 	    writeb(0x40, ramBase + NETWAVE_EREG_ASCC);
 
-	    /* Remember to count up priv->stats on error packets */
-	    ++priv->stats.rx_errors;
+	    /* Remember to count up dev->stats on error packets */
+	    ++dev->stats.rx_errors;
 	}
 	/* TxDN */
 	if (status & 0x20) {
@@ -1140,17 +1130,17 @@ static irqreturn_t netwave_interrupt(int
 		/* Transmitting was okay, clear bits */
 		wait_WOC(iobase);
 		writeb(0x2f, ramBase + NETWAVE_EREG_TSER + 4);
-		++priv->stats.tx_packets;
+		++dev->stats.tx_packets;
 	    }
 			
 	    if (txStatus & 0xd0) {
 		if (txStatus & 0x80) {
-		    ++priv->stats.collisions; /* Because of /proc/net/dev*/
-		    /* ++priv->stats.tx_aborted_errors; */
+		    ++dev->stats.collisions; /* Because of /proc/net/dev*/
+		    /* ++dev->stats.tx_aborted_errors; */
 		    /* printk("Collision. %ld\n", jiffies - dev->trans_start); */
 		}
 		if (txStatus & 0x40) 
-		    ++priv->stats.tx_carrier_errors;
+		    ++dev->stats.tx_carrier_errors;
 		/* 0x80 TxGU Transmit giveup - nine times and no luck
 		 * 0x40 TxNOAP No access point. Discarded packet.
 		 * 0x10 TxErr Transmit error. Always set when 
@@ -1163,7 +1153,7 @@ static irqreturn_t netwave_interrupt(int
 		/* Clear out TxGU, TxNOAP, TxErr and TxTrys */
 		wait_WOC(iobase);
 		writeb(0xdf & txStatus, ramBase+NETWAVE_EREG_TSER+4);
-		++priv->stats.tx_errors;
+		++dev->stats.tx_errors;
 	    }
 	    DEBUG(3, "New status is TSER %x ASR %x\n",
 		  readb(ramBase + NETWAVE_EREG_TSER),
@@ -1197,40 +1187,6 @@ static void netwave_watchdog(struct net_
     netif_wake_queue(dev);
 } /* netwave_watchdog */
 
-static struct net_device_stats *netwave_get_stats(struct net_device *dev) {
-    netwave_private *priv = netdev_priv(dev);
-
-    update_stats(dev);
-
-    DEBUG(2, "netwave: SPCQ %x SPU %x LIF %x ISPLQ %x MHS %x rxtx %x"
-	  " %x tx %x %x %x %x\n", 
-	  readb(priv->ramBase + NETWAVE_EREG_SPCQ),
-	  readb(priv->ramBase + NETWAVE_EREG_SPU),
-	  readb(priv->ramBase + NETWAVE_EREG_LIF),
-	  readb(priv->ramBase + NETWAVE_EREG_ISPLQ),
-	  readb(priv->ramBase + NETWAVE_EREG_MHS),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0xe),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0xf),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0x18),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0x19),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0x1a),
-	  readb(priv->ramBase + NETWAVE_EREG_EC + 0x1b));
-
-    return &priv->stats;
-}
-
-static void update_stats(struct net_device *dev) {
-    //unsigned long flags;
-/*     netwave_private *priv = netdev_priv(dev); */
-
-    //spin_lock_irqsave(&priv->spinlock, flags);
-
-/*    priv->stats.rx_packets = readb(priv->ramBase + 0x18e); 
-    priv->stats.tx_packets = readb(priv->ramBase + 0x18f); */
-
-    //spin_unlock_irqrestore(&priv->spinlock, flags);
-}
-
 static int netwave_rx(struct net_device *dev)
 {
     netwave_private *priv = netdev_priv(dev);
@@ -1274,7 +1230,7 @@ static int netwave_rx(struct net_device 
 	if (skb == NULL) {
 	    DEBUG(1, "netwave_rx: Could not allocate an sk_buff of "
 		  "length %d\n", rcvLen);
-	    ++priv->stats.rx_dropped; 
+	    ++dev->stats.rx_dropped;
 	    /* Tell the adapter to skip the packet */
 	    wait_WOC(iobase);
 	    writeb(NETWAVE_CMD_SRP, ramBase + NETWAVE_EREG_CB + 0);
@@ -1307,8 +1263,8 @@ static int netwave_rx(struct net_device 
 	/* Queue packet for network layer */
 	netif_rx(skb);
 
-	priv->stats.rx_packets++;
-	priv->stats.rx_bytes += rcvLen;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += rcvLen;
 
 	/* Got the packet, tell the adapter to skip it */
 	wait_WOC(iobase);

-- 

