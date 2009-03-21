From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 52/77] sbni: use internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:19 -0700
Message-ID: <20090321053716.500120634@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36663 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761032AbZCUFsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:19 -0400
Content-Disposition: inline; filename=sbni.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to use existing net_device_stats.
This driver,
      has bad style,
      	of using commas,
	   when brackets should be used...

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/sbni.c	2009-03-20 17:14:16.263027723 -0700
+++ b/drivers/net/wan/sbni.c	2009-03-20 17:22:27.542840306 -0700
@@ -68,7 +68,6 @@
 /* device private data */
 
 struct net_local {
-	struct net_device_stats	stats;
 	struct timer_list	watchdog;
 
 	spinlock_t	lock;
@@ -117,7 +116,6 @@ static int  sbni_open( struct net_device
 static int  sbni_close( struct net_device * );
 static int  sbni_start_xmit( struct sk_buff *, struct net_device * );
 static int  sbni_ioctl( struct net_device *, struct ifreq *, int );
-static struct net_device_stats  *sbni_get_stats( struct net_device * );
 static void  set_multicast_list( struct net_device * );
 
 static irqreturn_t sbni_interrupt( int, void * );
@@ -723,13 +721,11 @@ upload_data( struct net_device  *dev,  u
 			nl->wait_frameno = 0,
 			nl->inppos = 0,
 #ifdef CONFIG_SBNI_MULTILINE
-			((struct net_local *)netdev_priv(nl->master))
-				->stats.rx_errors++,
-			((struct net_local *)netdev_priv(nl->master))
-				->stats.rx_missed_errors++;
+			nl->master->stats.rx_errors++,
+			nl->master->stats.rx_missed_errors++;
 #else
-			nl->stats.rx_errors++,
-			nl->stats.rx_missed_errors++;
+		        dev->stats.rx_errors++,
+			dev->stats.rx_missed_errors++;
 #endif
 			/* now skip all frames until is_first != 0 */
 	} else
@@ -742,13 +738,11 @@ upload_data( struct net_device  *dev,  u
 		 */
 		nl->wait_frameno = 0,
 #ifdef CONFIG_SBNI_MULTILINE
-		((struct net_local *)netdev_priv(nl->master))
-			->stats.rx_errors++,
-		((struct net_local *)netdev_priv(nl->master))
-			->stats.rx_crc_errors++;
+		nl->master->stats.rx_errors++,
+		nl->master->stats.rx_crc_errors++;
 #else
-		nl->stats.rx_errors++,
-		nl->stats.rx_crc_errors++;
+		dev->stats.rx_errors++,
+		dev->stats.rx_crc_errors++;
 #endif
 
 	return  frame_ok;
@@ -756,15 +750,16 @@ upload_data( struct net_device  *dev,  u
 
 
 static inline void
-send_complete( struct net_local  *nl )
+send_complete( struct net_device *dev )
 {
+	struct net_local  *nl = netdev_priv(dev);
+
 #ifdef CONFIG_SBNI_MULTILINE
-	((struct net_local *)netdev_priv(nl->master))->stats.tx_packets++;
-	((struct net_local *)netdev_priv(nl->master))->stats.tx_bytes
-		+= nl->tx_buf_p->len;
+	nl->master->stats.tx_packets++;
+	nl->master->stats.tx_bytes += nl->tx_buf_p->len;
 #else
-	nl->stats.tx_packets++;
-	nl->stats.tx_bytes += nl->tx_buf_p->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += nl->tx_buf_p->len;
 #endif
 	dev_kfree_skb_irq( nl->tx_buf_p );
 
@@ -792,7 +787,7 @@ interpret_ack( struct net_device  *dev, 
 						   nl->maxframe,
 						   nl->tx_buf_p->len - nl->outpos);
 			else
-				send_complete( nl ),
+				send_complete( dev ),
 #ifdef CONFIG_SBNI_MULTILINE
 				netif_wake_queue( nl->master );
 #else
@@ -881,13 +876,11 @@ drop_xmit_queue( struct net_device  *dev
 		dev_kfree_skb_any( nl->tx_buf_p ),
 		nl->tx_buf_p = NULL,
 #ifdef CONFIG_SBNI_MULTILINE
-		((struct net_local *)netdev_priv(nl->master))
-			->stats.tx_errors++,
-		((struct net_local *)netdev_priv(nl->master))
-			->stats.tx_carrier_errors++;
+		nl->master->stats.tx_errors++,
+		nl->master->stats.tx_carrier_errors++;
 #else
-		nl->stats.tx_errors++,
-		nl->stats.tx_carrier_errors++;
+		dev->stats.tx_errors++,
+		dev->stats.tx_carrier_errors++;
 #endif
 
 	nl->tx_frameno	= 0;
@@ -1017,14 +1010,13 @@ indicate_pkt( struct net_device  *dev )
 #ifdef CONFIG_SBNI_MULTILINE
 	skb->protocol = eth_type_trans( skb, nl->master );
 	netif_rx( skb );
-	++((struct net_local *)netdev_priv(nl->master))->stats.rx_packets;
-	((struct net_local *)netdev_priv(nl->master))->stats.rx_bytes +=
-		nl->inppos;
+	++nl->master->stats.rx_packets;
+	nl->master->stats.rx_bytes += nl->inppos;
 #else
 	skb->protocol = eth_type_trans( skb, dev );
 	netif_rx( skb );
-	++nl->stats.rx_packets;
-	nl->stats.rx_bytes += nl->inppos;
+	++dev->stats.rx_packets;
+	dev->stats.rx_bytes += nl->inppos;
 #endif
 	nl->rx_buf_p = NULL;	/* protocol driver will clear this sk_buff */
 }
@@ -1197,7 +1189,7 @@ sbni_open( struct net_device  *dev )
 handler_attached:
 
 	spin_lock( &nl->lock );
-	memset( &nl->stats, 0, sizeof(struct net_device_stats) );
+	memset( &dev->stats, 0, sizeof(struct net_device_stats) );
 	memset( &nl->in_stats, 0, sizeof(struct sbni_in_stats) );
 
 	card_start( dev );
@@ -1413,7 +1405,7 @@ enslave( struct net_device  *dev,  struc
 
 	/* Summary statistics of MultiLine operation will be stored
 	   in master's counters */
-	memset( &snl->stats, 0, sizeof(struct net_device_stats) );
+	memset( &slave_dev->stats, 0, sizeof(struct net_device_stats) );
 	netif_stop_queue( slave_dev );
 	netif_wake_queue( dev );	/* Now we are able to transmit */
 
@@ -1464,14 +1456,6 @@ emancipate( struct net_device  *dev )
 
 #endif
 
-
-static struct net_device_stats *
-sbni_get_stats( struct net_device  *dev )
-{
-	return  &((struct net_local *)netdev_priv(dev))->stats;
-}
-
-
 static void
 set_multicast_list( struct net_device  *dev )
 {

-- 

