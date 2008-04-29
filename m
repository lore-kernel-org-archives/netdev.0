From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c515: use netstats in net_device structure
Date: Tue, 29 Apr 2008 03:07:31 +0300
Message-ID: <481666C3.5090408@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020803010101070109080702"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54004 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935082AbYD2AHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 20:07:54 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqdNq-0006kd-Hh
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 00:07:46 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 00:07:46 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 00:07:46 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020803010101070109080702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------020803010101070109080702
Content-Type: text/x-patch;
 name="3c515_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c515_netstats.patch"

diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 6ab84b6..105a8c7 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -310,7 +310,6 @@ struct corkscrew_private {
 	struct sk_buff *tx_skbuff[TX_RING_SIZE];
 	unsigned int cur_rx, cur_tx;	/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;/* The ring entries to be free()ed. */
-	struct net_device_stats stats;
 	struct sk_buff *tx_skb;	/* Packet being eaten by bus master ctrl.  */
 	struct timer_list timer;	/* Media selection timer. */
 	int capabilities	;	/* Adapter capabilities word. */
@@ -983,8 +982,8 @@ static void corkscrew_timeout(struct net_device *dev)
 			break;
 	outw(TxEnable, ioaddr + EL3_CMD);
 	dev->trans_start = jiffies;
-	vp->stats.tx_errors++;
-	vp->stats.tx_dropped++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
 }
 
@@ -1050,7 +1049,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 	}
 	/* Put out the doubleword header... */
 	outl(skb->len, ioaddr + TX_FIFO);
-	vp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 #ifdef VORTEX_BUS_MASTER
 	if (vp->bus_master) {
 		/* Set the bus-master controller to transfer the packet. */
@@ -1094,9 +1093,9 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 					printk("%s: Tx error, status %2.2x.\n",
 						dev->name, tx_status);
 				if (tx_status & 0x04)
-					vp->stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 				if (tx_status & 0x38)
-					vp->stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 				if (tx_status & 0x30) {
 					int j;
 					outw(TxReset, ioaddr + EL3_CMD);
@@ -1257,7 +1256,6 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 
 static int corkscrew_rx(struct net_device *dev)
 {
-	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -1271,17 +1269,17 @@ static int corkscrew_rx(struct net_device *dev)
 			if (corkscrew_debug > 2)
 				printk(" Rx error: status %2.2x.\n",
 				       rx_error);
-			vp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rx_error & 0x01)
-				vp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			if (rx_error & 0x02)
-				vp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (rx_error & 0x04)
-				vp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rx_error & 0x08)
-				vp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (rx_error & 0x10)
-				vp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			short pkt_len = rx_status & 0x1fff;
@@ -1301,8 +1299,8 @@ static int corkscrew_rx(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				vp->stats.rx_packets++;
-				vp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 				/* Wait a limited time to go to next packet. */
 				for (i = 200; i >= 0; i--)
 					if (! (inw(ioaddr + EL3_STATUS) & CmdInProgress))
@@ -1312,7 +1310,7 @@ static int corkscrew_rx(struct net_device *dev)
 				printk("%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, pkt_len);
 		}
 		outw(RxDiscard, ioaddr + EL3_CMD);
-		vp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		/* Wait a limited time to skip this packet. */
 		for (i = 200; i >= 0; i--)
 			if (!(inw(ioaddr + EL3_STATUS) & CmdInProgress))
@@ -1337,23 +1335,23 @@ static int boomerang_rx(struct net_device *dev)
 			if (corkscrew_debug > 2)
 				printk(" Rx error: status %2.2x.\n",
 				       rx_error);
-			vp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rx_error & 0x01)
-				vp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			if (rx_error & 0x02)
-				vp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (rx_error & 0x04)
-				vp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rx_error & 0x08)
-				vp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (rx_error & 0x10)
-				vp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			short pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			vp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_bytes += pkt_len;
 			if (corkscrew_debug > 4)
 				printk("Receiving packet size %d status %4.4x.\n",
 				     pkt_len, rx_status);
@@ -1388,7 +1386,7 @@ static int boomerang_rx(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			vp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
 	}
@@ -1475,7 +1473,7 @@ static struct net_device_stats *corkscrew_get_stats(struct net_device *dev)
 		update_stats(dev->base_addr, dev);
 		spin_unlock_irqrestore(&vp->lock, flags);
 	}
-	return &vp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.
@@ -1487,19 +1485,17 @@ static struct net_device_stats *corkscrew_get_stats(struct net_device *dev)
 	*/
 static void update_stats(int ioaddr, struct net_device *dev)
 {
-	struct corkscrew_private *vp = netdev_priv(dev);
-
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	vp->stats.tx_carrier_errors += inb(ioaddr + 0);
-	vp->stats.tx_heartbeat_errors += inb(ioaddr + 1);
+	dev->stats.tx_carrier_errors += inb(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors += inb(ioaddr + 1);
 	/* Multiple collisions. */ inb(ioaddr + 2);
-	vp->stats.collisions += inb(ioaddr + 3);
-	vp->stats.tx_window_errors += inb(ioaddr + 4);
-	vp->stats.rx_fifo_errors += inb(ioaddr + 5);
-	vp->stats.tx_packets += inb(ioaddr + 6);
-	vp->stats.tx_packets += (inb(ioaddr + 9) & 0x30) << 4;
+	dev->stats.collisions += inb(ioaddr + 3);
+	dev->stats.tx_window_errors += inb(ioaddr + 4);
+	dev->stats.rx_fifo_errors += inb(ioaddr + 5);
+	dev->stats.tx_packets += inb(ioaddr + 6);
+	dev->stats.tx_packets += (inb(ioaddr + 9) & 0x30) << 4;
 						/* Rx packets   */ inb(ioaddr + 7);
 						/* Must read to clear */
 	/* Tx deferrals */ inb(ioaddr + 8);

--------------020803010101070109080702--

