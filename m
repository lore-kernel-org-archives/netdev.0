From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] ariadne: use netstats in net_device structure
Date: Tue, 06 May 2008 01:48:00 +0300
Message-ID: <481F8EA0.10400@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020405060907090208010707"
Cc: port-m68k@netbsd.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41405 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbYEEWsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 18:48:15 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt9Tf-0000Bp-Fx
	for netdev@vger.kernel.org; Mon, 05 May 2008 22:48:11 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 22:48:11 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 22:48:11 +0000
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020405060907090208010707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Haven't tried to compile it. Need ack from m68k people!

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------020405060907090208010707
Content-Type: text/x-patch;
 name="ariadne_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ariadne_netstats.patch"

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 10f3a19..6c66bd5 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -98,7 +98,6 @@ struct ariadne_private {
     volatile u_short *rx_buff[RX_RING_SIZE];
     int cur_tx, cur_rx;			/* The next free ring entry */
     int dirty_tx;			/* The ring entries to be free()ed. */
-    struct net_device_stats stats;
     char tx_full;
 };
 
@@ -384,14 +383,14 @@ static int ariadne_close(struct net_device *dev)
     netif_stop_queue(dev);
 
     lance->RAP = CSR112;	/* Missed Frame Count */
-    priv->stats.rx_missed_errors = swapw(lance->RDP);
+    dev->stats.rx_missed_errors = swapw(lance->RDP);
     lance->RAP = CSR0;		/* PCnet-ISA Controller Status */
 
     if (ariadne_debug > 1) {
 	printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 	       dev->name, lance->RDP);
 	printk(KERN_DEBUG "%s: %lu packets missed\n", dev->name,
-	       priv->stats.rx_missed_errors);
+	       dev->stats.rx_missed_errors);
     }
 
     /* We stop the LANCE here -- it occasionally polls memory if we don't. */
@@ -502,16 +501,16 @@ static irqreturn_t ariadne_interrupt(int irq, void *data)
 		if (status & TF_ERR) {
 		    /* There was an major error, log it. */
 		    int err_status = priv->tx_ring[entry]->TMD3;
-		    priv->stats.tx_errors++;
+		    dev->stats.tx_errors++;
 		    if (err_status & EF_RTRY)
-			priv->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 		    if (err_status & EF_LCAR)
-			priv->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 		    if (err_status & EF_LCOL)
-			priv->stats.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 		    if (err_status & EF_UFLO) {
 			/* Ackk!  On FIFO errors the Tx unit is turned off! */
-			priv->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			/* Remove this verbosity later! */
 			printk(KERN_ERR "%s: Tx FIFO error! Status %4.4x.\n",
 			       dev->name, csr0);
@@ -520,8 +519,8 @@ static irqreturn_t ariadne_interrupt(int irq, void *data)
 		    }
 		} else {
 		    if (status & (TF_MORE|TF_ONE))
-			priv->stats.collisions++;
-		    priv->stats.tx_packets++;
+			dev->stats.collisions++;
+		    dev->stats.tx_packets++;
 		}
 		dirty_tx++;
 	    }
@@ -547,11 +546,11 @@ static irqreturn_t ariadne_interrupt(int irq, void *data)
 	/* Log misc errors. */
 	if (csr0 & BABL) {
 	    handled = 1;
-	    priv->stats.tx_errors++;	/* Tx babble. */
+	    dev->stats.tx_errors++;	/* Tx babble. */
 	}
 	if (csr0 & MISS) {
 	    handled = 1;
-	    priv->stats.rx_errors++;	/* Missed a Rx frame. */
+	    dev->stats.rx_errors++;	/* Missed a Rx frame. */
 	}
 	if (csr0 & MERR) {
 	    handled = 1;
@@ -672,7 +671,7 @@ static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->cur_tx -= TX_RING_SIZE;
 	priv->dirty_tx -= TX_RING_SIZE;
     }
-    priv->stats.tx_bytes += len;
+    dev->stats.tx_bytes += len;
 
     /* Trigger an immediate send poll. */
     lance->RAP = CSR0;		/* PCnet-ISA Controller Status */
@@ -707,15 +706,15 @@ static int ariadne_rx(struct net_device *dev)
 		buffers, with only the last correctly noting the error. */
 	    if (status & RF_ENP)
 		/* Only count a general error at the end of a packet.*/
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	    if (status & RF_FRAM)
-		priv->stats.rx_frame_errors++;
+		dev->stats.rx_frame_errors++;
 	    if (status & RF_OFLO)
-		priv->stats.rx_over_errors++;
+		dev->stats.rx_over_errors++;
 	    if (status & RF_CRC)
-		priv->stats.rx_crc_errors++;
+		dev->stats.rx_crc_errors++;
 	    if (status & RF_BUFF)
-		priv->stats.rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 	    priv->rx_ring[entry]->RMD1 &= 0xff00|RF_STP|RF_ENP;
 	} else {
 	    /* Malloc up new buffer, compatible with net-3. */
@@ -731,7 +730,7 @@ static int ariadne_rx(struct net_device *dev)
 			break;
 
 		if (i > RX_RING_SIZE-2) {
-		    priv->stats.rx_dropped++;
+		    dev->stats.rx_dropped++;
 		    priv->rx_ring[entry]->RMD1 |= RF_OWN;
 		    priv->cur_rx++;
 		}
@@ -764,8 +763,8 @@ static int ariadne_rx(struct net_device *dev)
 
 	    netif_rx(skb);
 	    dev->last_rx = jiffies;
-	    priv->stats.rx_packets++;
-	    priv->stats.rx_bytes += pkt_len;
+	    dev->stats.rx_packets++;
+	    dev->stats.rx_bytes += pkt_len;
 	}
 
 	priv->rx_ring[entry]->RMD1 |= RF_OWN;
@@ -791,11 +790,11 @@ static struct net_device_stats *ariadne_get_stats(struct net_device *dev)
     local_irq_save(flags);
     saved_addr = lance->RAP;
     lance->RAP = CSR112;		/* Missed Frame Count */
-    priv->stats.rx_missed_errors = swapw(lance->RDP);
+    dev->stats.rx_missed_errors = swapw(lance->RDP);
     lance->RAP = saved_addr;
     local_irq_restore(flags);
 
-    return &priv->stats;
+    return &dev->stats;
 }
 
 

--------------020405060907090208010707--

