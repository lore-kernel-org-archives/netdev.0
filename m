From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 40/77] xir2cps: convert to internal net_device stats
Date: Fri, 20 Mar 2009 22:36:07 -0700
Message-ID: <20090321053715.571102554@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36627 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760776AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=xirc2ps-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/pcmcia/xirc2ps_cs.c	2009-03-20 21:45:49.827651601 -0700
+++ b/drivers/net/pcmcia/xirc2ps_cs.c	2009-03-20 21:55:40.069839509 -0700
@@ -335,7 +335,7 @@ typedef struct local_info_t {
 	struct net_device	*dev;
 	struct pcmcia_device	*p_dev;
     dev_node_t node;
-    struct net_device_stats stats;
+
     int card_type;
     int probe_port;
     int silicon; /* silicon revision. 0=old CE2, 1=Scipper, 4=Mohawk */
@@ -355,7 +355,6 @@ typedef struct local_info_t {
 static int do_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void xirc_tx_timeout(struct net_device *dev);
 static void xirc2ps_tx_timeout_task(struct work_struct *work);
-static struct net_device_stats *do_get_stats(struct net_device *dev);
 static void set_addresses(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static int set_card_type(struct pcmcia_device *link, const void *s);
@@ -583,7 +582,6 @@ xirc2ps_probe(struct pcmcia_device *link
     /* Fill in card specific entries */
     dev->hard_start_xmit = &do_start_xmit;
     dev->set_config = &do_config;
-    dev->get_stats = &do_get_stats;
     dev->do_ioctl = &do_ioctl;
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
     dev->set_multicast_list = &set_multicast_list;
@@ -1172,7 +1170,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	if (bytes_rcvd > maxrx_bytes && (rsr & PktRxOk)) {
 	    /* too many bytes received during this int, drop the rest of the
 	     * packets */
-	    lp->stats.rx_dropped++;
+	    dev->stats.rx_dropped++;
 	    DEBUG(2, "%s: RX drop, too much done\n", dev->name);
 	} else if (rsr & PktRxOk) {
 	    struct sk_buff *skb;
@@ -1186,7 +1184,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	    if (!skb) {
 		printk(KNOT_XIRC "low memory, packet dropped (size=%u)\n",
 		       pktlen);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	    } else { /* okay get the packet */
 		skb_reserve(skb, 2);
 		if (lp->silicon == 0 ) { /* work around a hardware bug */
@@ -1242,24 +1240,24 @@ xirc2ps_interrupt(int irq, void *dev_id)
 		}
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += pktlen;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pktlen;
 		if (!(rsr & PhyPkt))
-		    lp->stats.multicast++;
+		    dev->stats.multicast++;
 	    }
 	} else { /* bad packet */
 	    DEBUG(5, "rsr=%#02x\n", rsr);
 	}
 	if (rsr & PktTooLong) {
-	    lp->stats.rx_frame_errors++;
+	    dev->stats.rx_frame_errors++;
 	    DEBUG(3, "%s: Packet too long\n", dev->name);
 	}
 	if (rsr & CRCErr) {
-	    lp->stats.rx_crc_errors++;
+	    dev->stats.rx_crc_errors++;
 	    DEBUG(3, "%s: CRC error\n", dev->name);
 	}
 	if (rsr & AlignErr) {
-	    lp->stats.rx_fifo_errors++; /* okay ? */
+	    dev->stats.rx_fifo_errors++; /* okay ? */
 	    DEBUG(3, "%s: Alignment error\n", dev->name);
 	}
 
@@ -1270,7 +1268,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	eth_status = GetByte(XIRCREG_ESR);
     }
     if (rx_status & 0x10) { /* Receive overrun */
-	lp->stats.rx_over_errors++;
+	dev->stats.rx_over_errors++;
 	PutByte(XIRCREG_CR, ClearRxOvrun);
 	DEBUG(3, "receive overrun cleared\n");
     }
@@ -1283,11 +1281,11 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	nn = GetByte(XIRCREG0_PTR);
 	lp->last_ptr_value = nn;
 	if (nn < n) /* rollover */
-	    lp->stats.tx_packets += 256 - n;
+	    dev->stats.tx_packets += 256 - n;
 	else if (n == nn) { /* happens sometimes - don't know why */
 	    DEBUG(0, "PTR not changed?\n");
 	} else
-	    lp->stats.tx_packets += lp->last_ptr_value - n;
+	    dev->stats.tx_packets += lp->last_ptr_value - n;
 	netif_wake_queue(dev);
     }
     if (tx_status & 0x0002) {	/* Execessive collissions */
@@ -1295,7 +1293,7 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	PutByte(XIRCREG_CR, RestartTx);  /* restart transmitter process */
     }
     if (tx_status & 0x0040)
-	lp->stats.tx_aborted_errors++;
+	dev->stats.tx_aborted_errors++;
 
     /* recalculate our work chunk so that we limit the duration of this
      * ISR to about 1/10 of a second.
@@ -1353,7 +1351,7 @@ static void
 xirc_tx_timeout(struct net_device *dev)
 {
     local_info_t *lp = netdev_priv(dev);
-    lp->stats.tx_errors++;
+    dev->stats.tx_errors++;
     printk(KERN_NOTICE "%s: transmit timed out\n", dev->name);
     schedule_work(&lp->tx_timeout_task);
 }
@@ -1409,20 +1407,11 @@ do_start_xmit(struct sk_buff *skb, struc
 
     dev_kfree_skb (skb);
     dev->trans_start = jiffies;
-    lp->stats.tx_bytes += pktlen;
+    dev->stats.tx_bytes += pktlen;
     netif_start_queue(dev);
     return 0;
 }
 
-static struct net_device_stats *
-do_get_stats(struct net_device *dev)
-{
-    local_info_t *lp = netdev_priv(dev);
-
-    /*	lp->stats.rx_missed_errors = GetByte(?) */
-    return &lp->stats;
-}
-
 /****************
  * Set all addresses: This first one is the individual address,
  * the next 9 addresses are taken from the multicast list and

-- 

