From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 02/30] uml: convert network device to internal network device stats
Date: Thu, 26 Mar 2009 18:11:16 -0700
Message-ID: <20090327011255.097375153@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, jdike@addtoit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39792 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbZC0BVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:21:49 -0400
Content-Disposition: inline; filename=uml-netstats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the UML network device to use internal network device stats.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/arch/um/drivers/net_kern.c	2009-03-21 12:36:49.000000000 -0700
+++ b/arch/um/drivers/net_kern.c	2009-03-26 17:04:05.123352757 -0700
@@ -86,7 +86,7 @@ static int uml_net_rx(struct net_device 
 		drop_skb->dev = dev;
 		/* Read a packet into drop_skb and don't do anything with it. */
 		(*lp->read)(lp->fd, drop_skb, lp);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return 0;
 	}
 
@@ -99,8 +99,8 @@ static int uml_net_rx(struct net_device 
 		skb_trim(skb, pkt_len);
 		skb->protocol = (*lp->protocol)(skb);
 
-		lp->stats.rx_bytes += skb->len;
-		lp->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
 		netif_rx(skb);
 		return pkt_len;
 	}
@@ -224,8 +224,8 @@ static int uml_net_start_xmit(struct sk_
 	len = (*lp->write)(lp->fd, skb, lp);
 
 	if (len == skb->len) {
-		lp->stats.tx_packets++;
-		lp->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
 		dev->trans_start = jiffies;
 		netif_start_queue(dev);
 
@@ -234,7 +234,7 @@ static int uml_net_start_xmit(struct sk_
 	}
 	else if (len == 0) {
 		netif_start_queue(dev);
-		lp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 	}
 	else {
 		netif_start_queue(dev);
@@ -248,12 +248,6 @@ static int uml_net_start_xmit(struct sk_
 	return 0;
 }
 
-static struct net_device_stats *uml_net_get_stats(struct net_device *dev)
-{
-	struct uml_net_private *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
 static void uml_net_set_multicast_list(struct net_device *dev)
 {
 	return;
@@ -476,7 +470,6 @@ static void eth_configure(int n, void *i
 	dev->open = uml_net_open;
 	dev->hard_start_xmit = uml_net_start_xmit;
 	dev->stop = uml_net_close;
-	dev->get_stats = uml_net_get_stats;
 	dev->set_multicast_list = uml_net_set_multicast_list;
 	dev->tx_timeout = uml_net_tx_timeout;
 	dev->set_mac_address = uml_net_set_mac;
--- a/arch/um/include/shared/net_kern.h	2009-03-21 12:36:49.000000000 -0700
+++ b/arch/um/include/shared/net_kern.h	2009-03-22 21:13:26.136674285 -0700
@@ -26,7 +26,7 @@ struct uml_net_private {
 	spinlock_t lock;
 	struct net_device *dev;
 	struct timer_list tl;
-	struct net_device_stats stats;
+
 	struct work_struct work;
 	int fd;
 	unsigned char mac[ETH_ALEN];


