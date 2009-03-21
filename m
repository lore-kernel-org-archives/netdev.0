From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 36/77] pcmcia: convert fmvj18x driver to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:03 -0700
Message-ID: <20090321053715.257570605@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36610 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760935AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=fmv-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/fmvj18x_cs.c	2009-03-20 15:32:36.560777355 -0700
+++ b/drivers/net/pcmcia/fmvj18x_cs.c	2009-03-20 15:33:14.186903302 -0700
@@ -100,7 +100,6 @@ static int fjn_start_xmit(struct sk_buff
 static irqreturn_t fjn_interrupt(int irq, void *dev_id);
 static void fjn_rx(struct net_device *dev);
 static void fjn_reset(struct net_device *dev);
-static struct net_device_stats *fjn_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void fjn_tx_timeout(struct net_device *dev);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -118,7 +117,6 @@ typedef enum { MBH10302, MBH10304, TDK, 
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
     dev_node_t node;
-    struct net_device_stats stats;
     long open_time;
     uint tx_started:1;
     uint tx_queue;
@@ -263,7 +261,6 @@ static int fmvj18x_probe(struct pcmcia_d
     /* The FMVJ18x specific entries in the device structure. */
     dev->hard_start_xmit = &fjn_start_xmit;
     dev->set_config = &fjn_config;
-    dev->get_stats = &fjn_get_stats;
     dev->set_multicast_list = &set_rx_mode;
     dev->open = &fjn_open;
     dev->stop = &fjn_close;
@@ -793,7 +790,7 @@ static irqreturn_t fjn_interrupt(int dum
 	fjn_rx(dev);
     }
     if (tx_stat & F_TMT_RDY) {
-	lp->stats.tx_packets += lp->sent ;
+	dev->stats.tx_packets += lp->sent ;
         lp->sent = 0 ;
 	if (lp->tx_queue) {
 	    outb(DO_TX | lp->tx_queue, ioaddr + TX_START);
@@ -840,7 +837,7 @@ static void fjn_tx_timeout(struct net_de
 	   htons(inw(ioaddr + 6)), htons(inw(ioaddr + 8)),
 	   htons(inw(ioaddr +10)), htons(inw(ioaddr +12)),
 	   htons(inw(ioaddr +14)));
-    lp->stats.tx_errors++;
+    dev->stats.tx_errors++;
     /* ToDo: We should try to restart the adaptor... */
     local_irq_disable();
     fjn_reset(dev);
@@ -880,7 +877,7 @@ static int fjn_start_xmit(struct sk_buff
 
 	DEBUG(4, "%s: Transmitting a packet of length %lu.\n",
 	      dev->name, (unsigned long)skb->len);
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Disable both interrupts. */
 	outw(0x0000, ioaddr + TX_INTR);
@@ -1008,7 +1005,6 @@ static void fjn_reset(struct net_device 
 
 static void fjn_rx(struct net_device *dev)
 {
-    struct local_info_t *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
     int boguscount = 10;	/* 5 -> 10: by agy 19940922 */
 
@@ -1027,11 +1023,11 @@ static void fjn_rx(struct net_device *de
 	}
 #endif
 	if ((status & 0xF0) != 0x20) {	/* There was an error. */
-	    lp->stats.rx_errors++;
-	    if (status & F_LEN_ERR) lp->stats.rx_length_errors++;
-	    if (status & F_ALG_ERR) lp->stats.rx_frame_errors++;
-	    if (status & F_CRC_ERR) lp->stats.rx_crc_errors++;
-	    if (status & F_OVR_FLO) lp->stats.rx_over_errors++;
+	    dev->stats.rx_errors++;
+	    if (status & F_LEN_ERR) dev->stats.rx_length_errors++;
+	    if (status & F_ALG_ERR) dev->stats.rx_frame_errors++;
+	    if (status & F_CRC_ERR) dev->stats.rx_crc_errors++;
+	    if (status & F_OVR_FLO) dev->stats.rx_over_errors++;
 	} else {
 	    u_short pkt_len = inw(ioaddr + DATAPORT);
 	    /* Malloc up new buffer. */
@@ -1041,7 +1037,7 @@ static void fjn_rx(struct net_device *de
 		printk(KERN_NOTICE "%s: The FMV-18x claimed a very "
 		       "large packet, size %d.\n", dev->name, pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		break;
 	    }
 	    skb = dev_alloc_skb(pkt_len+2);
@@ -1049,7 +1045,7 @@ static void fjn_rx(struct net_device *de
 		printk(KERN_NOTICE "%s: Memory squeeze, dropping "
 		       "packet (len %d).\n", dev->name, pkt_len);
 		outb(F_SKP_PKT, ioaddr + RX_SKIP);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		break;
 	    }
 
@@ -1070,8 +1066,8 @@ static void fjn_rx(struct net_device *de
 #endif
 
 	    netif_rx(skb);
-	    lp->stats.rx_packets++;
-	    lp->stats.rx_bytes += pkt_len;
+	    dev->stats.rx_packets++;
+	    dev->stats.rx_bytes += pkt_len;
 	}
 	if (--boguscount <= 0)
 	    break;
@@ -1191,14 +1187,6 @@ static int fjn_close(struct net_device *
 
 /*====================================================================*/
 
-static struct net_device_stats *fjn_get_stats(struct net_device *dev)
-{
-    local_info_t *lp = netdev_priv(dev);
-    return &lp->stats;
-} /* fjn_get_stats */
-
-/*====================================================================*/
-
 /*
   Set the multicast/promiscuous mode for this adaptor.
 */

-- 

