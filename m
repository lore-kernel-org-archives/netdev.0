From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 06/30] appletalk: convert LTPC to use internal net_device_stats
Date: Thu, 26 Mar 2009 18:11:20 -0700
Message-ID: <20090327011255.384630098@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43164 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034AbZC0BY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:24:28 -0400
Content-Disposition: inline; filename=ltpc-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/appletalk/ltpc.c	2009-03-22 23:12:01.097262013 -0700
+++ b/drivers/net/appletalk/ltpc.c	2009-03-26 17:04:02.272615862 -0700
@@ -261,7 +261,6 @@ static unsigned char *ltdmacbuf;
 
 struct ltpc_private
 {
-	struct net_device_stats stats;
 	struct atalk_addr my_addr;
 };
 
@@ -699,7 +698,6 @@ static int do_read(struct net_device *de
 static struct timer_list ltpc_timer;
 
 static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *ltpc_get_stats(struct net_device *dev);
 
 static int read_30 ( struct net_device *dev)
 {
@@ -726,8 +724,6 @@ static int sendup_buffer (struct net_dev
 	int dnode, snode, llaptype, len; 
 	int sklen;
 	struct sk_buff *skb;
-	struct ltpc_private *ltpc_priv = netdev_priv(dev);
-	struct net_device_stats *stats = &ltpc_priv->stats;
 	struct lt_rcvlap *ltc = (struct lt_rcvlap *) ltdmacbuf;
 
 	if (ltc->command != LT_RCVLAP) {
@@ -779,8 +775,8 @@ static int sendup_buffer (struct net_dev
 
 	skb_reset_transport_header(skb);
 
-	stats->rx_packets++;
-	stats->rx_bytes+=skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	/* toss it onwards */
 	netif_rx(skb);
@@ -904,10 +900,6 @@ static int ltpc_xmit(struct sk_buff *skb
 	/* in kernel 1.3.xx, on entry skb->data points to ddp header,
 	 * and skb->len is the length of the ddp data + ddp header
 	 */
-
-	struct ltpc_private *ltpc_priv = netdev_priv(dev);
-	struct net_device_stats *stats = &ltpc_priv->stats;
-
 	int i;
 	struct lt_sendlap cbuf;
 	unsigned char *hdr;
@@ -936,20 +928,13 @@ static int ltpc_xmit(struct sk_buff *skb
 		printk("\n");
 	}
 
-	stats->tx_packets++;
-	stats->tx_bytes+=skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	dev_kfree_skb(skb);
 	return 0;
 }
 
-static struct net_device_stats *ltpc_get_stats(struct net_device *dev)
-{
-	struct ltpc_private *ltpc_priv = netdev_priv(dev);
-	struct net_device_stats *stats = &ltpc_priv->stats;
-	return stats;
-}
-
 /* initialization stuff */
   
 static int __init ltpc_probe_dma(int base, int dma)
@@ -1135,7 +1120,6 @@ struct net_device * __init ltpc_probe(vo
 
 	/* Fill in the fields of the device structure with ethernet-generic values. */
 	dev->hard_start_xmit = ltpc_xmit;
-	dev->get_stats = ltpc_get_stats;
 
 	/* add the ltpc-specific things */
 	dev->do_ioctl = &ltpc_ioctl;


