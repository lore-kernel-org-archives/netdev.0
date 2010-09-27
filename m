From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH -next 2/4] ip_gre: percpu stats accounting
Date: Mon, 27 Sep 2010 12:35:07 +0200
Message-ID: <1285583707.23938.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34504 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab0I0KfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:35:13 -0400
Received: by fxm3 with SMTP id 3so1676039fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:35:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.

Other seldom used fields are kept in netdev->stats structure, possibly
unsafe.

This is a preliminary work to support lockless transmit path, and
correct RX stats, that are already unsafe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |  138 +++++++++++++++++++++++++++++++-------------
 1 file changed, 99 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5d6ddcb..de39b22 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -165,6 +165,34 @@ struct ipgre_net {
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
+static struct net_device_stats *ipgre_get_stats(struct net_device *dev)
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
 /* Given src, dst and key, find appropriate for input tunnel. */
 
 static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
@@ -377,7 +405,7 @@ static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
 	else
-		sprintf(name, "gre%%d");
+		strcpy(name, "gre%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
 	if (!dev)
@@ -584,7 +612,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	if ((tunnel = ipgre_tunnel_lookup(skb->dev,
 					  iph->saddr, iph->daddr, key,
 					  gre_proto))) {
-		struct net_device_stats *stats = &tunnel->dev->stats;
+		struct pcpu_tstats *tstats;
 
 		secpath_reset(skb);
 
@@ -608,22 +636,22 @@ static int ipgre_rcv(struct sk_buff *skb)
 			/* Looped back packet, drop it! */
 			if (skb_rtable(skb)->fl.iif == 0)
 				goto drop;
-			stats->multicast++;
+			tunnel->dev->stats.multicast++;
 			skb->pkt_type = PACKET_BROADCAST;
 		}
 #endif
 
 		if (((flags&GRE_CSUM) && csum) ||
 		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
-			stats->rx_crc_errors++;
-			stats->rx_errors++;
+			tunnel->dev->stats.rx_crc_errors++;
+			tunnel->dev->stats.rx_errors++;
 			goto drop;
 		}
 		if (tunnel->parms.i_flags&GRE_SEQ) {
 			if (!(flags&GRE_SEQ) ||
 			    (tunnel->i_seqno && (s32)(seqno - tunnel->i_seqno) < 0)) {
-				stats->rx_fifo_errors++;
-				stats->rx_errors++;
+				tunnel->dev->stats.rx_fifo_errors++;
+				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
 			tunnel->i_seqno = seqno + 1;
@@ -632,8 +660,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 		/* Warning: All skb pointers will be invalidated! */
 		if (tunnel->dev->type == ARPHRD_ETHER) {
 			if (!pskb_may_pull(skb, ETH_HLEN)) {
-				stats->rx_length_errors++;
-				stats->rx_errors++;
+				tunnel->dev->stats.rx_length_errors++;
+				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
 
@@ -642,13 +670,17 @@ static int ipgre_rcv(struct sk_buff *skb)
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
-		skb_tunnel_rx(skb, tunnel->dev);
+		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		tstats->rx_packets++;
+		tstats->rx_bytes += skb->len;
+
+		__skb_tunnel_rx(skb, tunnel->dev);
 
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 
 		if (netif_rx(skb) == NET_RX_DROP)
-			stats->rx_dropped++;
+			tunnel->dev->stats.rx_dropped++;
 
 		rcu_read_unlock();
 		return 0;
@@ -665,8 +697,7 @@ drop_nolock:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	struct pcpu_tstats *tstats;
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
@@ -694,7 +725,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		/* NBMA tunnel */
 
 		if (skb_dst(skb) == NULL) {
-			stats->tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
 
@@ -740,14 +771,20 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	}
 
 	{
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = dst,
-						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
-				    .proto = IPPROTO_GRE };
+		struct flowi fl = {
+			.oif = tunnel->parms.link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = dst,
+					.saddr = tiph->saddr,
+					.tos = RT_TOS(tos)
+				}
+			},
+			.proto = IPPROTO_GRE
+		}
+;
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			stats->tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			goto tx_error;
 		}
 	}
@@ -755,7 +792,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	if (tdev == dev) {
 		ip_rt_put(rt);
-		stats->collisions++;
+		dev->stats.collisions++;
 		goto tx_error;
 	}
 
@@ -818,7 +855,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			dev->needed_headroom = max_headroom;
 		if (!new_skb) {
 			ip_rt_put(rt);
-			txq->tx_dropped++;
+			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
@@ -885,15 +922,15 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	}
 
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
@@ -913,13 +950,19 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 	/* Guess output device to choose reasonable mtu and needed_headroom */
 
 	if (iph->daddr) {
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_GRE };
+		struct flowi fl = {
+			.oif = tunnel->parms.link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = iph->daddr,
+					.saddr = iph->saddr,
+					.tos = RT_TOS(iph->tos)
+				}
+			},
+			.proto = IPPROTO_GRE
+		};
 		struct rtable *rt;
+
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
@@ -1171,13 +1214,19 @@ static int ipgre_open(struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 
 	if (ipv4_is_multicast(t->parms.iph.daddr)) {
-		struct flowi fl = { .oif = t->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = t->parms.iph.daddr,
-						.saddr = t->parms.iph.saddr,
-						.tos = RT_TOS(t->parms.iph.tos) } },
-				    .proto = IPPROTO_GRE };
+		struct flowi fl = {
+			.oif = t->parms.link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = t->parms.iph.daddr,
+					.saddr = t->parms.iph.saddr,
+					.tos = RT_TOS(t->parms.iph.tos)
+				}
+			},
+			.proto = IPPROTO_GRE
+		};
 		struct rtable *rt;
+
 		if (ip_route_output_key(dev_net(dev), &rt, &fl))
 			return -EADDRNOTAVAIL;
 		dev = rt->dst.dev;
@@ -1217,12 +1266,19 @@ static const struct net_device_ops ipgre_netdev_ops = {
 	.ndo_start_xmit		= ipgre_tunnel_xmit,
 	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
 	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
+	.ndo_get_stats		= ipgre_get_stats,
 };
 
+static void ipgre_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipgre_netdev_ops;
-	dev->destructor 	= free_netdev;
+	dev->destructor 	= ipgre_dev_free;
 
 	dev->type		= ARPHRD_IPGRE;
 	dev->needed_headroom 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
@@ -1260,6 +1316,10 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	} else
 		dev->header_ops = &ipgre_header_ops;
 
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
 	return 0;
 }
 


