From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] baycom_epp: use netstats in net_device structure
Date: Thu, 08 May 2008 00:42:35 +0300
Message-ID: <4822224B.4020706@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070800090701010003030007"
Cc: linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60835 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753742AbYEGVmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 17:42:49 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JtrPR-0003rS-Q2
	for netdev@vger.kernel.org; Wed, 07 May 2008 21:42:45 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 21:42:45 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 21:42:45 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070800090701010003030007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill baycom_get_stats function, because by default it is used
identical internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------070800090701010003030007
Content-Type: text/x-patch;
 name="baycom_epp_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="baycom_epp_netstats.patch"

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index dde9c7e..91be84c 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -203,7 +203,6 @@ struct baycom_state {
 		unsigned char buf[TXBUFFER_SIZE];
         } hdlctx;
 
-        struct net_device_stats stats;
 	unsigned int ptt_keyed;
 	struct sk_buff *skb;  /* next transmit packet  */
 
@@ -423,7 +422,7 @@ static void encode_hdlc(struct baycom_state *bc)
 	bc->hdlctx.bufptr = bc->hdlctx.buf;
 	bc->hdlctx.bufcnt = wp - bc->hdlctx.buf;
 	dev_kfree_skb(skb);
-	bc->stats.tx_packets++;
+	bc->dev->stats.tx_packets++;
 }
 
 /* ---------------------------------------------------------------------- */
@@ -547,7 +546,7 @@ static void do_rxpacket(struct net_device *dev)
 	pktlen = bc->hdlcrx.bufcnt-2+1; /* KISS kludge */
 	if (!(skb = dev_alloc_skb(pktlen))) {
 		printk("%s: memory squeeze, dropping packet\n", dev->name);
-		bc->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	cp = skb_put(skb, pktlen);
@@ -556,7 +555,7 @@ static void do_rxpacket(struct net_device *dev)
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
-	bc->stats.rx_packets++;
+	dev->stats.rx_packets++;
 }
 
 static int receive(struct net_device *dev, int cnt)
@@ -803,19 +802,6 @@ static int baycom_set_mac_address(struct net_device *dev, void *addr)
 
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
@@ -1066,10 +1052,10 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
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
@@ -1148,7 +1134,6 @@ static void baycom_probe(struct net_device *dev)
 	dev->stop = epp_close;
 	dev->do_ioctl = baycom_ioctl;
 	dev->hard_start_xmit = baycom_send_packet;
-	dev->get_stats = baycom_get_stats;
 
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;

--------------070800090701010003030007--

