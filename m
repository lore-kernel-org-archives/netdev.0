From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c509: use netstats in net_device structure
Date: Tue, 29 Apr 2008 02:45:43 +0300
Message-ID: <481661A7.4040909@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002030002060201040809"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:49753 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572AbYD1Xp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 19:45:58 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jqd2h-0005u8-IU
	for netdev@vger.kernel.org; Mon, 28 Apr 2008 23:45:55 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 23:45:55 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 23:45:55 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090002030002060201040809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------090002030002060201040809
Content-Type: text/x-patch;
 name="3c509_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c509_netstats.patch"

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 54dac06..e6c545f 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -167,7 +167,6 @@ enum RxFilter {
 enum el3_cardtype { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA };
 
 struct el3_private {
-	struct net_device_stats stats;
 	spinlock_t lock;
 	/* skb send-queue */
 	int head, size;
@@ -794,7 +793,6 @@ el3_open(struct net_device *dev)
 static void
 el3_tx_timeout (struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -802,7 +800,7 @@ el3_tx_timeout (struct net_device *dev)
 		   "Tx FIFO room %d.\n",
 		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		   inw(ioaddr + TX_FREE));
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	dev->trans_start = jiffies;
 	/* Issue TX_RESET and TX_START commands. */
 	outw(TxReset, ioaddr + EL3_CMD);
@@ -820,7 +818,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netif_stop_queue (dev);
 
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	if (el3_debug > 4) {
 		printk(KERN_DEBUG "%s: el3_start_xmit(length = %u) called, status %4.4x.\n",
@@ -881,7 +879,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		int i = 4;
 
 		while (--i > 0	&&	(tx_status = inb(ioaddr + TX_STATUS)) > 0) {
-			if (tx_status & 0x38) lp->stats.tx_aborted_errors++;
+			if (tx_status & 0x38) dev->stats.tx_aborted_errors++;
 			if (tx_status & 0x30) outw(TxReset, ioaddr + EL3_CMD);
 			if (tx_status & 0x3C) outw(TxEnable, ioaddr + EL3_CMD);
 			outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
@@ -931,12 +929,11 @@ el3_interrupt(int irq, void *dev_id)
 				outw(AckIntr | RxEarly, ioaddr + EL3_CMD);
 			}
 			if (status & TxComplete) {			/* Really Tx error. */
-				struct el3_private *lp = netdev_priv(dev);
 				short tx_status;
 				int i = 4;
 
 				while (--i>0 && (tx_status = inb(ioaddr + TX_STATUS)) > 0) {
-					if (tx_status & 0x38) lp->stats.tx_aborted_errors++;
+					if (tx_status & 0x38) dev->stats.tx_aborted_errors++;
 					if (tx_status & 0x30) outw(TxReset, ioaddr + EL3_CMD);
 					if (tx_status & 0x3C) outw(TxEnable, ioaddr + EL3_CMD);
 					outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
@@ -1002,7 +999,7 @@ el3_get_stats(struct net_device *dev)
 	spin_lock_irqsave(&lp->lock, flags);
 	update_stats(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.  We change to register window 6, so this should be run
@@ -1012,7 +1009,6 @@ el3_get_stats(struct net_device *dev)
 	*/
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 5)
@@ -1021,13 +1017,13 @@ static void update_stats(struct net_device *dev)
 	outw(StatsDisable, ioaddr + EL3_CMD);
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	lp->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
-	lp->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
+	dev->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
 	/* Multiple collisions. */	   inb(ioaddr + 2);
-	lp->stats.collisions		+= inb(ioaddr + 3);
-	lp->stats.tx_window_errors	+= inb(ioaddr + 4);
-	lp->stats.rx_fifo_errors	+= inb(ioaddr + 5);
-	lp->stats.tx_packets		+= inb(ioaddr + 6);
+	dev->stats.collisions		+= inb(ioaddr + 3);
+	dev->stats.tx_window_errors	+= inb(ioaddr + 4);
+	dev->stats.rx_fifo_errors	+= inb(ioaddr + 5);
+	dev->stats.tx_packets		+= inb(ioaddr + 6);
 	/* Rx packets	*/		   inb(ioaddr + 7);
 	/* Tx deferrals */		   inb(ioaddr + 8);
 	inw(ioaddr + 10);	/* Total Rx and Tx octets. */
@@ -1042,7 +1038,6 @@ static void update_stats(struct net_device *dev)
 static int
 el3_rx(struct net_device *dev)
 {
-	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	short rx_status;
 
@@ -1054,21 +1049,21 @@ el3_rx(struct net_device *dev)
 			short error = rx_status & 0x3800;
 
 			outw(RxDiscard, ioaddr + EL3_CMD);
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			switch (error) {
-			case 0x0000:		lp->stats.rx_over_errors++; break;
-			case 0x0800:		lp->stats.rx_length_errors++; break;
-			case 0x1000:		lp->stats.rx_frame_errors++; break;
-			case 0x1800:		lp->stats.rx_length_errors++; break;
-			case 0x2000:		lp->stats.rx_frame_errors++; break;
-			case 0x2800:		lp->stats.rx_crc_errors++; break;
+			case 0x0000:		dev->stats.rx_over_errors++; break;
+			case 0x0800:		dev->stats.rx_length_errors++; break;
+			case 0x1000:		dev->stats.rx_frame_errors++; break;
+			case 0x1800:		dev->stats.rx_length_errors++; break;
+			case 0x2000:		dev->stats.rx_frame_errors++; break;
+			case 0x2800:		dev->stats.rx_crc_errors++; break;
 			}
 		} else {
 			short pkt_len = rx_status & 0x7ff;
 			struct sk_buff *skb;
 
 			skb = dev_alloc_skb(pkt_len+5);
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_bytes += pkt_len;
 			if (el3_debug > 4)
 				printk("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -1083,11 +1078,11 @@ el3_rx(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
+				dev->stats.rx_packets++;
 				continue;
 			}
 			outw(RxDiscard, ioaddr + EL3_CMD);
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			if (el3_debug)
 				printk("%s: Couldn't allocate a sk_buff of size %d.\n",
 					   dev->name, pkt_len);

--------------090002030002060201040809--

