From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 40/45] yam: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:37 -0800
Message-ID: <20090109230139.693081454@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, jpr@f6fbb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42316 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755380AbZAIXSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:20 -0500
Content-Disposition: inline; filename=yam-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamradio/yam.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/yam.c	2009-01-09 12:54:25.000000000 -0800
@@ -115,10 +115,6 @@ struct yam_port {
 
 	struct net_device *dev;
 
-	/* Stats section */
-
-	struct net_device_stats stats;
-
 	int nb_rxint;
 	int nb_mdint;
 
@@ -507,7 +503,7 @@ static inline void yam_rx_flag(struct ne
 		} else {
 			if (!(skb = dev_alloc_skb(pkt_len))) {
 				printk(KERN_WARNING "%s: memory squeeze, dropping packet\n", dev->name);
-				++yp->stats.rx_dropped;
+				++dev->stats.rx_dropped;
 			} else {
 				unsigned char *cp;
 				cp = skb_put(skb, pkt_len);
@@ -515,7 +511,7 @@ static inline void yam_rx_flag(struct ne
 				memcpy(cp, yp->rx_buf, pkt_len - 1);
 				skb->protocol = ax25_type_trans(skb, dev);
 				netif_rx(skb);
-				++yp->stats.rx_packets;
+				++dev->stats.rx_packets;
 			}
 		}
 	}
@@ -677,7 +673,7 @@ static void yam_tx_byte(struct net_devic
 			yp->tx_count = 1;
 			yp->tx_state = TX_HEAD;
 		}
-		++yp->stats.tx_packets;
+		++dev->stats.tx_packets;
 		break;
 	case TX_TAIL:
 		if (--yp->tx_count <= 0) {
@@ -716,7 +712,7 @@ static irqreturn_t yam_interrupt(int irq
 			handled = 1;
 
 			if (lsr & LSR_OE)
-				++yp->stats.rx_fifo_errors;
+				++dev->stats.rx_fifo_errors;
 
 			yp->dcd = (msr & RX_DCD) ? 1 : 0;
 
@@ -778,11 +774,11 @@ static int yam_seq_show(struct seq_file 
 	seq_printf(seq, "  TxTail   %u\n", yp->txtail);
 	seq_printf(seq, "  SlotTime %u\n", yp->slot);
 	seq_printf(seq, "  Persist  %u\n", yp->pers);
-	seq_printf(seq, "  TxFrames %lu\n", yp->stats.tx_packets);
-	seq_printf(seq, "  RxFrames %lu\n", yp->stats.rx_packets);
+	seq_printf(seq, "  TxFrames %lu\n", dev->stats.tx_packets);
+	seq_printf(seq, "  RxFrames %lu\n", dev->stats.rx_packets);
 	seq_printf(seq, "  TxInt    %u\n", yp->nb_mdint);
 	seq_printf(seq, "  RxInt    %u\n", yp->nb_rxint);
-	seq_printf(seq, "  RxOver   %lu\n", yp->stats.rx_fifo_errors);
+	seq_printf(seq, "  RxOver   %lu\n", dev->stats.rx_fifo_errors);
 	seq_printf(seq, "\n");
 	return 0;
 }
@@ -812,26 +808,6 @@ static const struct file_operations yam_
 
 /* --------------------------------------------------------------------- */
 
-static struct net_device_stats *yam_get_stats(struct net_device *dev)
-{
-	struct yam_port *yp;
-
-	if (!dev)
-		return NULL;
-
-	yp = netdev_priv(dev);
-	if (yp->magic != YAM_MAGIC)
-		return NULL;
-
-	/* 
-	 * Get the current statistics.  This may be called with the
-	 * card open or closed. 
-	 */
-	return &yp->stats;
-}
-
-/* --------------------------------------------------------------------- */
-
 static int yam_open(struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
@@ -878,9 +854,9 @@ static int yam_open(struct net_device *d
 	/* Reset overruns for all ports - FPGA programming makes overruns */
 	for (i = 0; i < NR_PORTS; i++) {
 		struct net_device *dev = yam_devs[i];
-		struct yam_port *yp = netdev_priv(dev);
+
 		inb(LSR(dev->base_addr));
-		yp->stats.rx_fifo_errors = 0;
+		dev->stats.rx_fifo_errors = 0;
 	}
 
 	printk(KERN_INFO "%s at iobase 0x%lx irq %u uart %s\n", dev->name, dev->base_addr, dev->irq,


