From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH -next 3/4] ipip: percpu stats accounting
Date: Mon, 27 Sep 2010 12:35:50 +0200
Message-ID: <1285583750.23938.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36592 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab0I0Kfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:35:54 -0400
Received: by fxm3 with SMTP id 3so1676250fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:35:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.

Other seldom used fields are kept in netdev->stats structure, possibly
unsafe.

This is a preliminary work to support lockless transmit path, and
correct RX stats, that are already unsafe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c |  127 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 93 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index babd252..12b6fde 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -131,8 +131,9 @@ struct ipip_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-static void ipip_tunnel_init(struct net_device *dev);
+static int ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
+static void ipip_dev_free(struct net_device *dev);
 
 /*
  * Locking : hash tables are protected by RCU and RTNL
@@ -141,6 +142,34 @@ static void ipip_tunnel_setup(struct net_device *dev);
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
+static struct net_device_stats *ipip_get_stats(struct net_device *dev)
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
 static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 		__be32 remote, __be32 local)
 {
@@ -239,7 +268,7 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
 	else
-		sprintf(name, "tunl%%d");
+		strcpy(name, "tunl%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipip_tunnel_setup);
 	if (dev == NULL)
@@ -255,7 +284,8 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 	nt = netdev_priv(dev);
 	nt->parms = *parms;
 
-	ipip_tunnel_init(dev);
+	if (ipip_tunnel_init(dev) < 0)
+		goto failed_free;
 
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
@@ -265,7 +295,7 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 	return nt;
 
 failed_free:
-	free_netdev(dev);
+	ipip_dev_free(dev);
 	return NULL;
 }
 
@@ -359,8 +389,10 @@ static int ipip_rcv(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	rcu_read_lock();
-	if ((tunnel = ipip_tunnel_lookup(dev_net(skb->dev),
-					iph->saddr, iph->daddr)) != NULL) {
+	tunnel = ipip_tunnel_lookup(dev_net(skb->dev), iph->saddr, iph->daddr);
+	if (tunnel != NULL) {
+		struct pcpu_tstats *tstats;
+
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 			rcu_read_unlock();
 			kfree_skb(skb);
@@ -374,7 +406,11 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
-		skb_tunnel_rx(skb, tunnel->dev);
+		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		tstats->rx_packets++;
+		tstats->rx_bytes += skb->len;
+
+		__skb_tunnel_rx(skb, tunnel->dev);
 
 		ipip_ecn_decapsulate(iph, skb);
 
@@ -397,13 +433,12 @@ static int ipip_rcv(struct sk_buff *skb)
 static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	struct pcpu_tstats *tstats;
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;			/* Device to other host */
+	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
@@ -413,13 +448,13 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
 
-	if (tos&1)
+	if (tos & 1)
 		tos = old_iph->tos;
 
 	if (!dst) {
 		/* NBMA tunnel */
 		if ((rt = skb_rtable(skb)) == NULL) {
-			stats->tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
 		if ((dst = rt->rt_gateway) == 0)
@@ -427,14 +462,20 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	{
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = dst,
-						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
-				    .proto = IPPROTO_IPIP };
+		struct flowi fl = {
+			.oif = tunnel->parms.link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = dst,
+					.saddr = tiph->saddr,
+					.tos = RT_TOS(tos)
+				}
+			},
+			.proto = IPPROTO_IPIP
+		};
+
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			stats->tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
 	}
@@ -442,7 +483,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		stats->collisions++;
+		dev->stats.collisions++;
 		goto tx_error;
 	}
 
@@ -452,7 +493,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 
 		if (mtu < 68) {
-			stats->collisions++;
+			dev->stats.collisions++;
 			ip_rt_put(rt);
 			goto tx_error;
 		}
@@ -488,7 +529,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
 			ip_rt_put(rt);
-			txq->tx_dropped++;
+			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
@@ -525,14 +566,14 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		iph->ttl	=	old_iph->ttl;
 
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
@@ -547,13 +588,19 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_IPIP };
+		struct flowi fl = {
+			.oif = tunnel->parms.link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = iph->daddr,
+					.saddr = iph->saddr,
+					.tos = RT_TOS(iph->tos)
+				}
+			},
+			.proto = IPPROTO_IPIP
+		};
 		struct rtable *rt;
+
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
@@ -699,13 +746,19 @@ static const struct net_device_ops ipip_netdev_ops = {
 	.ndo_start_xmit	= ipip_tunnel_xmit,
 	.ndo_do_ioctl	= ipip_tunnel_ioctl,
 	.ndo_change_mtu	= ipip_tunnel_change_mtu,
-
+	.ndo_get_stats  = ipip_get_stats,
 };
 
+static void ipip_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
 static void ipip_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipip_netdev_ops;
-	dev->destructor		= free_netdev;
+	dev->destructor		= ipip_dev_free;
 
 	dev->type		= ARPHRD_TUNNEL;
 	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
@@ -717,7 +770,7 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 
-static void ipip_tunnel_init(struct net_device *dev)
+static int ipip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
@@ -728,6 +781,12 @@ static void ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip_tunnel_bind_dev(dev);
+
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	return 0;
 }
 
 static void __net_init ipip_fb_tunnel_init(struct net_device *dev)


