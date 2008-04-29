From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c527: use netstats in net_device structure
Date: Tue, 29 Apr 2008 12:09:38 +0300
Message-ID: <4816E5D2.8010500@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000106050803060101070609"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37780 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753477AbYD2JKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 05:10:19 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jqlqo-000330-Og
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 09:10:14 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 09:10:14 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 09:10:14 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000106050803060101070609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------000106050803060101070609
Content-Type: text/x-patch;
 name="3c527_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c527_netstats.patch"

diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index fae295b..6aca0c6 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -158,7 +158,6 @@ struct mc32_local
 	int slot;
 
 	u32 base;
-	struct net_device_stats net_stats;
 	volatile struct mc32_mailbox *rx_box;
 	volatile struct mc32_mailbox *tx_box;
 	volatile struct mc32_mailbox *exec_box;
@@ -1093,24 +1092,24 @@ static void mc32_update_stats(struct net_device *dev)
 
 	u32 rx_errors=0;
 
-	rx_errors+=lp->net_stats.rx_crc_errors   +=st->rx_crc_errors;
+	rx_errors+=dev->stats.rx_crc_errors   +=st->rx_crc_errors;
 	                                           st->rx_crc_errors=0;
-	rx_errors+=lp->net_stats.rx_fifo_errors  +=st->rx_overrun_errors;
+	rx_errors+=dev->stats.rx_fifo_errors  +=st->rx_overrun_errors;
 	                                           st->rx_overrun_errors=0;
-	rx_errors+=lp->net_stats.rx_frame_errors +=st->rx_alignment_errors;
+	rx_errors+=dev->stats.rx_frame_errors +=st->rx_alignment_errors;
  	                                           st->rx_alignment_errors=0;
-	rx_errors+=lp->net_stats.rx_length_errors+=st->rx_tooshort_errors;
+	rx_errors+=dev->stats.rx_length_errors+=st->rx_tooshort_errors;
 	                                           st->rx_tooshort_errors=0;
-	rx_errors+=lp->net_stats.rx_missed_errors+=st->rx_outofresource_errors;
+	rx_errors+=dev->stats.rx_missed_errors+=st->rx_outofresource_errors;
 	                                           st->rx_outofresource_errors=0;
-        lp->net_stats.rx_errors=rx_errors;
+        dev->stats.rx_errors=rx_errors;
 
 	/* Number of packets which saw one collision */
-	lp->net_stats.collisions+=st->dataC[10];
+	dev->stats.collisions+=st->dataC[10];
 	st->dataC[10]=0;
 
 	/* Number of packets which saw 2--15 collisions */
-	lp->net_stats.collisions+=st->dataC[11];
+	dev->stats.collisions+=st->dataC[11];
 	st->dataC[11]=0;
 }
 
@@ -1178,7 +1177,7 @@ static void mc32_rx_ring(struct net_device *dev)
 				skb=dev_alloc_skb(length+2);
 
 				if(skb==NULL) {
-					lp->net_stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					goto dropped;
 				}
 
@@ -1189,8 +1188,8 @@ static void mc32_rx_ring(struct net_device *dev)
 
 			skb->protocol=eth_type_trans(skb,dev);
 			dev->last_rx = jiffies;
- 			lp->net_stats.rx_packets++;
- 			lp->net_stats.rx_bytes += length;
+ 			dev->stats.rx_packets++;
+ 			dev->stats.rx_bytes += length;
 			netif_rx(skb);
 		}
 
@@ -1253,34 +1252,34 @@ static void mc32_tx_ring(struct net_device *dev)
 			/* Not COMPLETED */
 			break;
 		}
-		lp->net_stats.tx_packets++;
+		dev->stats.tx_packets++;
 		if(!(np->status & (1<<6))) /* Not COMPLETED_OK */
 		{
-			lp->net_stats.tx_errors++;
+			dev->stats.tx_errors++;
 
 			switch(np->status&0x0F)
 			{
 				case 1:
-					lp->net_stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 					break; /* Max collisions */
 				case 2:
-					lp->net_stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 					break;
 				case 3:
-					lp->net_stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 					break;
 				case 4:
-					lp->net_stats.tx_window_errors++;
+					dev->stats.tx_window_errors++;
 					break;  /* CTS Lost */
 				case 5:
-					lp->net_stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 					break; /* Transmit timeout */
 			}
 		}
 		/* Packets are sent in order - this is
 		    basically a FIFO queue of buffers matching
 		    the card ring */
-		lp->net_stats.tx_bytes+=lp->tx_ring[t].skb->len;
+		dev->stats.tx_bytes+=lp->tx_ring[t].skb->len;
 		dev_kfree_skb_irq(lp->tx_ring[t].skb);
 		lp->tx_ring[t].skb=NULL;
 		atomic_inc(&lp->tx_count);
@@ -1367,7 +1366,7 @@ static irqreturn_t mc32_interrupt(int irq, void *dev_id)
 			case 6:
 				/* Out of RX buffers stat */
 				/* Must restart rx */
-				lp->net_stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				mc32_rx_ring(dev);
 				mc32_start_transceiver(dev);
 				break;
@@ -1489,10 +1488,8 @@ static int mc32_close(struct net_device *dev)
 
 static struct net_device_stats *mc32_get_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = netdev_priv(dev);
-
 	mc32_update_stats(dev);
-	return &lp->net_stats;
+	return &dev->stats;
 }
 
 

--------------000106050803060101070609--

