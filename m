From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip6tnl: percpu stats accounting
Date: Tue, 28 Sep 2010 15:23:34 +0200
Message-ID: <1285680214.3154.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34266 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab0I1NXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 09:23:39 -0400
Received: by fxm3 with SMTP id 3so2554355fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 06:23:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.

Other seldom used fields are kept in netdev->stats structure, possibly
unsafe.

This is a preliminary work to support lockless transmit path, and
correct RX stats, that are already unsafe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   93 +++++++++++++++++++++++++++++++++-------
 1 files changed, 77 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f6d9f68..8be3c45 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -75,7 +75,7 @@ MODULE_LICENSE("GPL");
 		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
 		    (HASH_SIZE - 1))
 
-static void ip6_tnl_dev_init(struct net_device *dev);
+static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 
 static int ip6_tnl_net_id __read_mostly;
@@ -88,6 +88,34 @@ struct ip6_tnl_net {
 	struct ip6_tnl __rcu **tnls[2];
 };
 
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct pcpu_tstats {
+	unsigned long	rx_packets;
+	unsigned long	rx_bytes;
+	unsigned long	tx_packets;
+	unsigned long	tx_bytes;
+};
+
+static struct net_device_stats *ip6_get_stats(struct net_device *dev)
+{
+	struct pcpu_tstats sum = { 0 };
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+
+		sum.rx_packets += tstats->rx_packets;
+		sum.rx_bytes   += tstats->rx_bytes;
+		sum.tx_packets += tstats->tx_packets;
+		sum.tx_bytes   += tstats->tx_bytes;
+	}
+	dev->stats.rx_packets = sum.rx_packets;
+	dev->stats.rx_bytes   = sum.rx_bytes;
+	dev->stats.tx_packets = sum.tx_packets;
+	dev->stats.tx_bytes   = sum.tx_bytes;
+	return &dev->stats;
+}
+
 /*
  * Locking : hash tables are protected by RCU and RTNL
  */
@@ -216,6 +244,12 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 	}
 }
 
+static void ip6_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
 /**
  * ip6_tnl_create() - create a new tunnel
  *   @p: tunnel parameters
@@ -254,7 +288,9 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 
 	t = netdev_priv(dev);
 	t->parms = *p;
-	ip6_tnl_dev_init(dev);
+	err = ip6_tnl_dev_init(dev);
+	if (err < 0)
+		goto failed_free;
 
 	if ((err = register_netdevice(dev)) < 0)
 		goto failed_free;
@@ -264,7 +300,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 	return t;
 
 failed_free:
-	free_netdev(dev);
+	ip6_dev_free(dev);
 failed:
 	return NULL;
 }
@@ -700,6 +736,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 					&ipv6h->daddr)) != NULL) {
+		struct pcpu_tstats *tstats;
+
 		if (t->parms.proto != ipproto && t->parms.proto != 0) {
 			rcu_read_unlock();
 			goto discard;
@@ -722,7 +760,11 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 
-		skb_tunnel_rx(skb, t->dev);
+		tstats = this_cpu_ptr(t->dev->tstats);
+		tstats->rx_packets++;
+		tstats->rx_bytes += skb->len;
+
+		__skb_tunnel_rx(skb, t->dev);
 
 		dscp_ecn_decapsulate(t, ipv6h, skb);
 
@@ -935,8 +977,10 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	err = ip6_local_out(skb);
 
 	if (net_xmit_eval(err) == 0) {
-		stats->tx_bytes += pkt_len;
-		stats->tx_packets++;
+		struct pcpu_tstats *tstats = this_cpu_ptr(t->dev->tstats);
+
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
 	} else {
 		stats->tx_errors++;
 		stats->tx_aborted_errors++;
@@ -1301,12 +1345,14 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 
 
 static const struct net_device_ops ip6_tnl_netdev_ops = {
-	.ndo_uninit = ip6_tnl_dev_uninit,
+	.ndo_uninit	= ip6_tnl_dev_uninit,
 	.ndo_start_xmit = ip6_tnl_xmit,
-	.ndo_do_ioctl = ip6_tnl_ioctl,
+	.ndo_do_ioctl	= ip6_tnl_ioctl,
 	.ndo_change_mtu = ip6_tnl_change_mtu,
+	.ndo_get_stats	= ip6_get_stats,
 };
 
+
 /**
  * ip6_tnl_dev_setup - setup virtual tunnel device
  *   @dev: virtual device associated with tunnel
@@ -1318,7 +1364,7 @@ static const struct net_device_ops ip6_tnl_netdev_ops = {
 static void ip6_tnl_dev_setup(struct net_device *dev)
 {
 	dev->netdev_ops = &ip6_tnl_netdev_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = ip6_dev_free;
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
@@ -1334,12 +1380,17 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
  *   @dev: virtual device associated with tunnel
  **/
 
-static inline void
+static inline int
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+
 	t->dev = dev;
 	strcpy(t->parms.name, dev->name);
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+	return 0;
 }
 
 /**
@@ -1347,11 +1398,15 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
  *   @dev: virtual device associated with tunnel
  **/
 
-static void ip6_tnl_dev_init(struct net_device *dev)
+static int ip6_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	ip6_tnl_dev_init_gen(dev);
+	int err = ip6_tnl_dev_init_gen(dev);
+
+	if (err)
+		return err;
 	ip6_tnl_link_config(t);
+	return 0;
 }
 
 /**
@@ -1361,16 +1416,20 @@ static void ip6_tnl_dev_init(struct net_device *dev)
  * Return: 0
  **/
 
-static void __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
+static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+	int err = ip6_tnl_dev_init_gen(dev);
+
+	if (err)
+		return err;
 
-	ip6_tnl_dev_init_gen(dev);
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
 	rcu_assign_pointer(ip6n->tnls_wc[0], t);
+	return 0;
 }
 
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
@@ -1420,7 +1479,9 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 		goto err_alloc_dev;
 	dev_net_set(ip6n->fb_tnl_dev, net);
 
-	ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
+	err = ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
+	if (err < 0)
+		goto err_register;
 
 	err = register_netdev(ip6n->fb_tnl_dev);
 	if (err < 0)
@@ -1428,7 +1489,7 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 	return 0;
 
 err_register:
-	free_netdev(ip6n->fb_tnl_dev);
+	ip6_dev_free(ip6n->fb_tnl_dev);
 err_alloc_dev:
 	return err;
 }


