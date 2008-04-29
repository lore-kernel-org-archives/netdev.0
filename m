From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c589_cs: use netstats in net_device structure
Date: Wed, 30 Apr 2008 01:20:20 +0300
Message-ID: <48179F24.6090707@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070808070605010505080300"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55854 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbYD2WUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 18:20:38 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqyBd-0001hO-4Q
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 22:20:33 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:20:33 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:20:33 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070808070605010505080300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>


--------------070808070605010505080300
Content-Type: text/x-patch;
 name="3c589_cs_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c589_cs_netstats.patch"

diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 1b1abb1..549a645 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -107,7 +107,6 @@ enum RxFilter {
 struct el3_private {
 	struct pcmcia_device	*p_dev;
     dev_node_t 		node;
-    struct net_device_stats stats;
     /* For transceiver monitoring */
     struct timer_list	media;
     u16			media_status;
@@ -566,12 +565,11 @@ static int el3_open(struct net_device *dev)
 
 static void el3_tx_timeout(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     
     printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
     dump_status(dev);
-    lp->stats.tx_errors++;
+    dev->stats.tx_errors++;
     dev->trans_start = jiffies;
     /* Issue TX_RESET and TX_START commands. */
     tc589_wait_for_completion(dev, TxReset);
@@ -581,7 +579,6 @@ static void el3_tx_timeout(struct net_device *dev)
 
 static void pop_tx_status(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int i;
     
@@ -596,7 +593,7 @@ static void pop_tx_status(struct net_device *dev)
 	    DEBUG(1, "%s: transmit error: status 0x%02x\n",
 		  dev->name, tx_status);
 	    outw(TxEnable, ioaddr + EL3_CMD);
-	    lp->stats.tx_aborted_errors++;
+	    dev->stats.tx_aborted_errors++;
 	}
 	outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
     }
@@ -614,7 +611,7 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
     spin_lock_irqsave(&priv->lock, flags);    
 
-    priv->stats.tx_bytes += skb->len;
+    dev->stats.tx_bytes += skb->len;
 
     /* Put out the doubleword header... */
     outw(skb->len, ioaddr + TX_FIFO);
@@ -764,7 +761,7 @@ static void media_check(unsigned long arg)
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	errs = inb(ioaddr + 0);
 	outw(StatsEnable, ioaddr + EL3_CMD);
-	lp->stats.tx_carrier_errors += errs;
+	dev->stats.tx_carrier_errors += errs;
 	if (errs || (lp->media_status & 0x0010)) media |= 0x0010;
     }
 
@@ -814,7 +811,7 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 	update_stats(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
     }
-    return &lp->stats;
+    return &dev->stats;
 }
 
 /*
@@ -827,7 +824,6 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
 */
 static void update_stats(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
 
     DEBUG(2, "%s: updating the statistics.\n", dev->name);
@@ -835,13 +831,13 @@ static void update_stats(struct net_device *dev)
     outw(StatsDisable, ioaddr + EL3_CMD);
     /* Switch to the stats window, and read everything. */
     EL3WINDOW(6);
-    lp->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
-    lp->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
+    dev->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
+    dev->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
     /* Multiple collisions. */	   	inb(ioaddr + 2);
-    lp->stats.collisions		+= inb(ioaddr + 3);
-    lp->stats.tx_window_errors		+= inb(ioaddr + 4);
-    lp->stats.rx_fifo_errors		+= inb(ioaddr + 5);
-    lp->stats.tx_packets		+= inb(ioaddr + 6);
+    dev->stats.collisions		+= inb(ioaddr + 3);
+    dev->stats.tx_window_errors		+= inb(ioaddr + 4);
+    dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
+    dev->stats.tx_packets		+= inb(ioaddr + 6);
     /* Rx packets   */			inb(ioaddr + 7);
     /* Tx deferrals */			inb(ioaddr + 8);
     /* Rx octets */			inw(ioaddr + 10);
@@ -854,7 +850,6 @@ static void update_stats(struct net_device *dev)
 
 static int el3_rx(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int worklimit = 32;
     short rx_status;
@@ -865,14 +860,14 @@ static int el3_rx(struct net_device *dev)
 	   (--worklimit >= 0)) {
 	if (rx_status & 0x4000) { /* Error, update stats. */
 	    short error = rx_status & 0x3800;
-	    lp->stats.rx_errors++;
+	    dev->stats.rx_errors++;
 	    switch (error) {
-	    case 0x0000:	lp->stats.rx_over_errors++; break;
-	    case 0x0800:	lp->stats.rx_length_errors++; break;
-	    case 0x1000:	lp->stats.rx_frame_errors++; break;
-	    case 0x1800:	lp->stats.rx_length_errors++; break;
-	    case 0x2000:	lp->stats.rx_frame_errors++; break;
-	    case 0x2800:	lp->stats.rx_crc_errors++; break;
+	    case 0x0000:	dev->stats.rx_over_errors++; break;
+	    case 0x0800:	dev->stats.rx_length_errors++; break;
+	    case 0x1000:	dev->stats.rx_frame_errors++; break;
+	    case 0x1800:	dev->stats.rx_length_errors++; break;
+	    case 0x2000:	dev->stats.rx_frame_errors++; break;
+	    case 0x2800:	dev->stats.rx_crc_errors++; break;
 	    }
 	} else {
 	    short pkt_len = rx_status & 0x7ff;
@@ -889,12 +884,12 @@ static int el3_rx(struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
 	    } else {
 		DEBUG(1, "%s: couldn't allocate a sk_buff of"
 		      " size %d.\n", dev->name, pkt_len);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	    }
 	}
 	/* Pop the top of the Rx FIFO */
@@ -929,7 +924,7 @@ static int el3_close(struct net_device *dev)
     DEBUG(1, "%s: shutting down ethercard.\n", dev->name);
 
     if (pcmcia_dev_present(link)) {
-	/* Turn off statistics ASAP.  We update lp->stats below. */
+	/* Turn off statistics ASAP.  We update dev->stats below. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	
 	/* Disable the receiver and transmitter. */

--------------070808070605010505080300--

