From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 32/45] baycom: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:29 -0800
Message-ID: <20090109230139.075685318@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42256 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbZAIXSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:06 -0500
Content-Disposition: inline; filename=baycom-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/baycom_epp.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/baycom_epp.c	2009-01-09 10:22:45.000000000 -0800
@@ -203,7 +203,6 @@ struct baycom_state {
 		unsigned char buf[TXBUFFER_SIZE];
         } hdlctx;
 
-        struct net_device_stats stats;
 	unsigned int ptt_keyed;
 	struct sk_buff *skb;  /* next transmit packet  */
 
@@ -423,7 +422,7 @@ static void encode_hdlc(struct baycom_st
 	bc->hdlctx.bufptr = bc->hdlctx.buf;
 	bc->hdlctx.bufcnt = wp - bc->hdlctx.buf;
 	dev_kfree_skb(skb);
-	bc->stats.tx_packets++;
+	bc->dev->stats.tx_packets++;
 }
 
 /* ---------------------------------------------------------------------- */
@@ -547,7 +546,7 @@ static void do_rxpacket(struct net_devic
 	pktlen = bc->hdlcrx.bufcnt-2+1; /* KISS kludge */
 	if (!(skb = dev_alloc_skb(pktlen))) {
 		printk("%s: memory squeeze, dropping packet\n", dev->name);
-		bc->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	cp = skb_put(skb, pktlen);
@@ -555,7 +554,7 @@ static void do_rxpacket(struct net_devic
 	memcpy(cp, bc->hdlcrx.buf, pktlen - 1);
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
-	bc->stats.rx_packets++;
+	dev->stats.rx_packets++;
 }
 
 static int receive(struct net_device *dev, int cnt)
@@ -802,19 +801,6 @@ static int baycom_set_mac_address(struct
 
 /* --------------------------------------------------------------------- */
 
-static struct net_device_stats *baycom_get_stats(struct net_device *dev)
-{
-	struct baycom_state *bc = netdev_priv(dev);
-
-	/* 
-	 * Get the current statistics.  This may be called with the
-	 * card open or closed. 
-	 */
-	return &bc->stats;
-}
-
-/* --------------------------------------------------------------------- */
-
 static void epp_wakeup(void *handle)
 {
         struct net_device *dev = (struct net_device *)handle;
@@ -1065,10 +1051,10 @@ static int baycom_ioctl(struct net_devic
 		hi.data.cs.ptt = !!(bc->stat & EPP_PTTBIT);
 		hi.data.cs.dcd = !(bc->stat & EPP_DCDBIT);
 		hi.data.cs.ptt_keyed = bc->ptt_keyed;
-		hi.data.cs.tx_packets = bc->stats.tx_packets;
-		hi.data.cs.tx_errors = bc->stats.tx_errors;
-		hi.data.cs.rx_packets = bc->stats.rx_packets;
-		hi.data.cs.rx_errors = bc->stats.rx_errors;
+		hi.data.cs.tx_packets = dev->stats.tx_packets;
+		hi.data.cs.tx_errors = dev->stats.tx_errors;
+		hi.data.cs.rx_packets = dev->stats.rx_packets;
+		hi.data.cs.rx_errors = dev->stats.rx_errors;
 		break;		
 
 	case HDLCDRVCTL_OLDGETSTAT:
@@ -1147,7 +1133,6 @@ static void baycom_probe(struct net_devi
 	dev->stop = epp_close;
 	dev->do_ioctl = baycom_ioctl;
 	dev->hard_start_xmit = baycom_send_packet;
-	dev->get_stats = baycom_get_stats;
 
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;


