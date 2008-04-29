From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c574_cs: use netstats in net_device structure
Date: Wed, 30 Apr 2008 01:08:26 +0300
Message-ID: <48179C5A.4000502@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080001000608030809080802"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:56441 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199AbYD2WIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 18:08:42 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jqy05-0001ER-1Q
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 22:08:37 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:08:37 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:08:37 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080001000608030809080802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------080001000608030809080802
Content-Type: text/x-patch;
 name="3c574_cs_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c574_cs_netstats.patch"

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 3b78a38..7112fd5 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -208,7 +208,6 @@ enum Window4 {		/* Window 4: Xcvr/media bits. */
 struct el3_private {
 	struct pcmcia_device	*p_dev;
 	dev_node_t node;
-	struct net_device_stats stats;
 	u16 advertising, partner;		/* NWay media advertisement */
 	unsigned char phys;			/* MII device address */
 	unsigned int autoselect:1, default_media:3;	/* Read from the EEPROM/Wn3_Config. */
@@ -741,12 +740,11 @@ static int el3_open(struct net_device *dev)
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	
 	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
 	dump_status(dev);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	dev->trans_start = jiffies;
 	/* Issue TX_RESET and TX_START commands. */
 	tc574_wait_for_completion(dev, TxReset);
@@ -756,7 +754,6 @@ static void el3_tx_timeout(struct net_device *dev)
 
 static void pop_tx_status(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	int i;
     
@@ -772,7 +769,7 @@ static void pop_tx_status(struct net_device *dev)
 			DEBUG(1, "%s: transmit error: status 0x%02x\n",
 				  dev->name, tx_status);
 			outw(TxEnable, ioaddr + EL3_CMD);
-			lp->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 		}
 		outb(0x00, ioaddr + TxStatus); /* Pop the status stack. */
 	}
@@ -987,7 +984,7 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 		update_stats(dev);
 		spin_unlock_irqrestore(&lp->window_lock, flags);
 	}
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.
@@ -996,7 +993,6 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
  */
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
@@ -1008,15 +1004,15 @@ static void update_stats(struct net_device *dev)
 	/* Unlike the 3c509 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	lp->stats.tx_carrier_errors 		+= inb(ioaddr + 0);
-	lp->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
+	dev->stats.tx_carrier_errors 		+= inb(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
 	/* Multiple collisions. */	   	inb(ioaddr + 2);
-	lp->stats.collisions			+= inb(ioaddr + 3);
-	lp->stats.tx_window_errors		+= inb(ioaddr + 4);
-	lp->stats.rx_fifo_errors		+= inb(ioaddr + 5);
-	lp->stats.tx_packets			+= inb(ioaddr + 6);
+	dev->stats.collisions			+= inb(ioaddr + 3);
+	dev->stats.tx_window_errors		+= inb(ioaddr + 4);
+	dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
+	dev->stats.tx_packets			+= inb(ioaddr + 6);
 	up		 			 = inb(ioaddr + 9);
-	lp->stats.tx_packets			+= (up&0x30) << 4;
+	dev->stats.tx_packets			+= (up&0x30) << 4;
 	/* Rx packets   */			   inb(ioaddr + 7);
 	/* Tx deferrals */			   inb(ioaddr + 8);
 	rx		 			 = inw(ioaddr + 10);
@@ -1026,14 +1022,13 @@ static void update_stats(struct net_device *dev)
 	/* BadSSD */				   inb(ioaddr + 12);
 	up					 = inb(ioaddr + 13);
 
-	lp->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
+	dev->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
 
 	EL3WINDOW(1);
 }
 
 static int el3_rx(struct net_device *dev, int worklimit)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
 	short rx_status;
 	
@@ -1043,14 +1038,14 @@ static int el3_rx(struct net_device *dev, int worklimit)
 		   (--worklimit >= 0)) {
 		if (rx_status & 0x4000) { /* Error, update stats. */
 			short error = rx_status & 0x3800;
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			switch (error) {
-			case 0x0000:	lp->stats.rx_over_errors++; break;
-			case 0x0800:	lp->stats.rx_length_errors++; break;
-			case 0x1000:	lp->stats.rx_frame_errors++; break;
-			case 0x1800:	lp->stats.rx_length_errors++; break;
-			case 0x2000:	lp->stats.rx_frame_errors++; break;
-			case 0x2800:	lp->stats.rx_crc_errors++; break;
+			case 0x0000:	dev->stats.rx_over_errors++; break;
+			case 0x0800:	dev->stats.rx_length_errors++; break;
+			case 0x1000:	dev->stats.rx_frame_errors++; break;
+			case 0x1800:	dev->stats.rx_length_errors++; break;
+			case 0x2000:	dev->stats.rx_frame_errors++; break;
+			case 0x2800:	dev->stats.rx_crc_errors++; break;
 			}
 		} else {
 			short pkt_len = rx_status & 0x7ff;
@@ -1067,12 +1062,12 @@ static int el3_rx(struct net_device *dev, int worklimit)
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			} else {
 				DEBUG(1, "%s: couldn't allocate a sk_buff of"
 					  " size %d.\n", dev->name, pkt_len);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		}
 		tc574_wait_for_completion(dev, RxDiscard);

--------------080001000608030809080802--

