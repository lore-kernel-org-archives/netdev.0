From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/42] appletalk: convert ipddp to net_device_ops
Date: Tue, 06 Jan 2009 16:33:18 -0800
Message-ID: <20090107003345.633563939@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58972 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754348AbZAGAw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:52:57 -0500
Content-Disposition: inline; filename=atalk-ipddp.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use internal element in network device for stats as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/appletalk/ipddp.c	2009-01-03 20:46:13.188014787 -0800
+++ b/drivers/net/appletalk/ipddp.c	2009-01-03 20:49:05.822763901 -0800
@@ -48,12 +48,18 @@ static int ipddp_mode = IPDDP_DECAP;
 
 /* Index to functions, as function prototypes. */
 static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *ipddp_get_stats(struct net_device *dev);
 static int ipddp_create(struct ipddp_route *new_rt);
 static int ipddp_delete(struct ipddp_route *rt);
 static struct ipddp_route* ipddp_find_route(struct ipddp_route *rt);
 static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
+static const struct net_device_ops ipddp_netdev_ops = {
+	.ndo_start_xmit		= ipddp_xmit,
+	.ndo_do_ioctl   	= ipddp_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static struct net_device * __init ipddp_init(void)
 {
@@ -61,7 +67,7 @@ static struct net_device * __init ipddp_
 	struct net_device *dev;
 	int err;
 
-	dev = alloc_etherdev(sizeof(struct net_device_stats));
+	dev = alloc_etherdev(0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -71,9 +77,7 @@ static struct net_device * __init ipddp_
                 printk(version);
 
 	/* Initalize the device structure. */
-        dev->hard_start_xmit = ipddp_xmit;
-        dev->get_stats      = ipddp_get_stats;
-        dev->do_ioctl       = ipddp_ioctl;
+	dev->netdev_ops = &ipddp_netdev_ops;
 
         dev->type = ARPHRD_IPDDP;       	/* IP over DDP tunnel */
         dev->mtu = 585;
@@ -103,13 +107,6 @@ static struct net_device * __init ipddp_
         return dev;
 }
 
-/*
- * Get the current statistics. This may be called with the card open or closed.
- */
-static struct net_device_stats *ipddp_get_stats(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
 
 /*
  * Transmit LLAP/ELAP frame using aarp_send_ddp.
@@ -170,8 +167,8 @@ static int ipddp_xmit(struct sk_buff *sk
 
         skb->protocol = htons(ETH_P_ATALK);     /* Protocol has changed */
 
-	((struct net_device_stats *) netdev_priv(dev))->tx_packets++;
-	((struct net_device_stats *) netdev_priv(dev))->tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
         if(aarp_send_ddp(rt->dev, skb, &rt->at, NULL) < 0)
                 dev_kfree_skb(skb);

-- 

