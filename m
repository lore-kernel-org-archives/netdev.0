From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH -next 4/4] sit: percpu stats accounting
Date: Mon, 27 Sep 2010 12:38:18 +0200
Message-ID: <1285583898.23938.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46567 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab0I0KiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:38:24 -0400
Received: by fxm3 with SMTP id 3so1676977fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.

Other seldom used fields are kept in netdev->stats structure, possibly
unsafe.

This is a preliminary work to support lockless transmit path, and
correct RX stats, that are already unsafe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   82 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 64 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8a03998..011ecf5 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -63,8 +63,9 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
-static void ipip6_tunnel_init(struct net_device *dev);
+static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
+static void ipip6_dev_free(struct net_device *dev);
 
 static int sit_net_id __read_mostly;
 struct sit_net {
@@ -84,6 +85,33 @@ struct sit_net {
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct pcpu_tstats {
+	unsigned long	rx_packets;
+	unsigned long	rx_bytes;
+	unsigned long	tx_packets;
+	unsigned long	tx_bytes;
+};
+
+static struct net_device_stats *ipip6_get_stats(struct net_device *dev)
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
 /*
  * Must be invoked with rcu_read_lock
  */
@@ -214,7 +242,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
 	else
-		sprintf(name, "sit%%d");
+		strcpy(name, "sit%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipip6_tunnel_setup);
 	if (dev == NULL)
@@ -230,7 +258,8 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	nt = netdev_priv(dev);
 
 	nt->parms = *parms;
-	ipip6_tunnel_init(dev);
+	if (ipip6_tunnel_init(dev) < 0)
+		goto failed_free;
 	ipip6_tunnel_clone_6rd(dev, sitn);
 
 	if (parms->i_flags & SIT_ISATAP)
@@ -245,7 +274,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	return nt;
 
 failed_free:
-	free_netdev(dev);
+	ipip6_dev_free(dev);
 failed:
 	return NULL;
 }
@@ -546,6 +575,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
+		struct pcpu_tstats *tstats;
+
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
@@ -561,7 +592,11 @@ static int ipip6_rcv(struct sk_buff *skb)
 			return 0;
 		}
 
-		skb_tunnel_rx(skb, tunnel->dev);
+		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		tstats->rx_packets++;
+		tstats->rx_bytes += skb->len;
+
+		__skb_tunnel_rx(skb, tunnel->dev);
 
 		ipip6_ecn_decapsulate(iph, skb);
 
@@ -626,14 +661,13 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				     struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	struct pcpu_tstats *tstats;
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;			/* Device to other host */
+	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
@@ -704,20 +738,20 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			stats->tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
 	}
 	if (rt->rt_type != RTN_UNICAST) {
 		ip_rt_put(rt);
-		stats->tx_carrier_errors++;
+		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
 	tdev = rt->dst.dev;
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		stats->collisions++;
+		dev->stats.collisions++;
 		goto tx_error;
 	}
 
@@ -725,7 +759,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 
 		if (mtu < 68) {
-			stats->collisions++;
+			dev->stats.collisions++;
 			ip_rt_put(rt);
 			goto tx_error;
 		}
@@ -764,7 +798,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
-			txq->tx_dropped++;
+			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
@@ -800,14 +834,14 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		iph->ttl	=	iph6->hop_limit;
 
 	nf_reset(skb);
-
-	IPTUNNEL_XMIT();
+	tstats = this_cpu_ptr(dev->tstats);
+	__IPTUNNEL_XMIT(tstats, &dev->stats);
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
-	stats->tx_errors++;
+	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -1084,12 +1118,19 @@ static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
+	.ndo_get_stats	= ipip6_get_stats,
 };
 
+static void ipip6_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipip6_netdev_ops;
-	dev->destructor 	= free_netdev;
+	dev->destructor 	= ipip6_dev_free;
 
 	dev->type		= ARPHRD_SIT;
 	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
@@ -1101,7 +1142,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static void ipip6_tunnel_init(struct net_device *dev)
+static int ipip6_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
@@ -1112,6 +1153,11 @@ static void ipip6_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip6_tunnel_bind_dev(dev);
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	return 0;
 }
 
 static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)


