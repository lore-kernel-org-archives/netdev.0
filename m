From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 2/4] ip_gre: percpu stats accounting
Date: Mon, 27 Sep 2010 15:57:11 +0200
Message-ID: <1285595831.23938.185.camel@edumazet-laptop>
References: <1285583707.23938.93.camel@edumazet-laptop>
	 <1285594140.2263.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44777 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759415Ab0I0N5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:57:18 -0400
Received: by fxm3 with SMTP id 3so1807206fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 06:57:17 -0700 (PDT)
In-Reply-To: <1285594140.2263.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 14:29 +0100, Ben Hutchings a =C3=A9cr=
it :

> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> > index 5d6ddcb..de39b22 100644
> > --- a/net/ipv4/ip_gre.c
> > +++ b/net/ipv4/ip_gre.c
> [...]
> > @@ -377,7 +405,7 @@ static struct ip_tunnel *ipgre_tunnel_locate(st=
ruct net *net,
> >  	if (parms->name[0])
> >  		strlcpy(name, parms->name, IFNAMSIZ);
> >  	else
> > -		sprintf(name, "gre%%d");
> > +		strcpy(name, "gre%d");
> > =20
> >  	dev =3D alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
> >  	if (!dev)
> [...]
>=20
> This is a valid fix, but doesn't belong in this patch!
>=20

Sorry ? It was not a fix, but at most a cleanup ;)

Anyway I forgot the gretap case...


[PATCH 2/4 v2] ip_gre: percpu stats accounting

Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.

Other seldom used fields are kept in netdev->stats structure, possibly
unsafe.

This is a preliminary work to support lockless transmit path, and
correct RX stats, that are already unsafe.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: gretap should be handled too

 net/ipv4/ip_gre.c |  143 ++++++++++++++++++++++++++++++++------------
 1 files changed, 104 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5d6ddcb..a1b5d5e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -165,6 +165,34 @@ struct ipgre_net {
 #define for_each_ip_tunnel_rcu(start) \
 	for (t =3D rcu_dereference(start); t; t =3D rcu_dereference(t->next))
=20
+/* often modified stats are per cpu, other are shared (netdev->stats) =
*/
+struct pcpu_tstats {
+	unsigned long	rx_packets;
+	unsigned long	rx_bytes;
+	unsigned long	tx_packets;
+	unsigned long	tx_bytes;
+};
+
+static struct net_device_stats *ipgre_get_stats(struct net_device *dev=
)
+{
+	struct pcpu_tstats sum =3D { 0 };
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_tstats *tstats =3D per_cpu_ptr(dev->tstats, i);
+
+		sum.rx_packets +=3D tstats->rx_packets;
+		sum.rx_bytes   +=3D tstats->rx_bytes;
+		sum.tx_packets +=3D tstats->tx_packets;
+		sum.tx_bytes   +=3D tstats->tx_bytes;
+	}
+	dev->stats.rx_packets =3D sum.rx_packets;
+	dev->stats.rx_bytes   =3D sum.rx_bytes;
+	dev->stats.tx_packets =3D sum.tx_packets;
+	dev->stats.tx_bytes   =3D sum.tx_bytes;
+	return &dev->stats;
+}
+
 /* Given src, dst and key, find appropriate for input tunnel. */
=20
 static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
@@ -584,7 +612,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	if ((tunnel =3D ipgre_tunnel_lookup(skb->dev,
 					  iph->saddr, iph->daddr, key,
 					  gre_proto))) {
-		struct net_device_stats *stats =3D &tunnel->dev->stats;
+		struct pcpu_tstats *tstats;
=20
 		secpath_reset(skb);
=20
@@ -608,22 +636,22 @@ static int ipgre_rcv(struct sk_buff *skb)
 			/* Looped back packet, drop it! */
 			if (skb_rtable(skb)->fl.iif =3D=3D 0)
 				goto drop;
-			stats->multicast++;
+			tunnel->dev->stats.multicast++;
 			skb->pkt_type =3D PACKET_BROADCAST;
 		}
 #endif
=20
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
 			tunnel->i_seqno =3D seqno + 1;
@@ -632,8 +660,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 		/* Warning: All skb pointers will be invalidated! */
 		if (tunnel->dev->type =3D=3D ARPHRD_ETHER) {
 			if (!pskb_may_pull(skb, ETH_HLEN)) {
-				stats->rx_length_errors++;
-				stats->rx_errors++;
+				tunnel->dev->stats.rx_length_errors++;
+				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
=20
@@ -642,13 +670,17 @@ static int ipgre_rcv(struct sk_buff *skb)
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
=20
-		skb_tunnel_rx(skb, tunnel->dev);
+		tstats =3D this_cpu_ptr(tunnel->dev->tstats);
+		tstats->rx_packets++;
+		tstats->rx_bytes +=3D skb->len;
+
+		__skb_tunnel_rx(skb, tunnel->dev);
=20
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
=20
 		if (netif_rx(skb) =3D=3D NET_RX_DROP)
-			stats->rx_dropped++;
+			tunnel->dev->stats.rx_dropped++;
=20
 		rcu_read_unlock();
 		return 0;
@@ -665,8 +697,7 @@ drop_nolock:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
 {
 	struct ip_tunnel *tunnel =3D netdev_priv(dev);
-	struct net_device_stats *stats =3D &dev->stats;
-	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
+	struct pcpu_tstats *tstats;
 	struct iphdr  *old_iph =3D ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
@@ -694,7 +725,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 		/* NBMA tunnel */
=20
 		if (skb_dst(skb) =3D=3D NULL) {
-			stats->tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
=20
@@ -740,14 +771,20 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
 	}
=20
 	{
-		struct flowi fl =3D { .oif =3D tunnel->parms.link,
-				    .nl_u =3D { .ip4_u =3D
-					      { .daddr =3D dst,
-						.saddr =3D tiph->saddr,
-						.tos =3D RT_TOS(tos) } },
-				    .proto =3D IPPROTO_GRE };
+		struct flowi fl =3D {
+			.oif =3D tunnel->parms.link,
+			.nl_u =3D {
+				.ip4_u =3D {
+					.daddr =3D dst,
+					.saddr =3D tiph->saddr,
+					.tos =3D RT_TOS(tos)
+				}
+			},
+			.proto =3D IPPROTO_GRE
+		}
+;
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-			stats->tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			goto tx_error;
 		}
 	}
@@ -755,7 +792,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
=20
 	if (tdev =3D=3D dev) {
 		ip_rt_put(rt);
-		stats->collisions++;
+		dev->stats.collisions++;
 		goto tx_error;
 	}
=20
@@ -818,7 +855,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 			dev->needed_headroom =3D max_headroom;
 		if (!new_skb) {
 			ip_rt_put(rt);
-			txq->tx_dropped++;
+			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
@@ -885,15 +922,15 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
 	}
=20
 	nf_reset(skb);
-
-	IPTUNNEL_XMIT();
+	tstats =3D this_cpu_ptr(dev->tstats);
+	__IPTUNNEL_XMIT(tstats, &dev->stats);
 	return NETDEV_TX_OK;
=20
 tx_error_icmp:
 	dst_link_failure(skb);
=20
 tx_error:
-	stats->tx_errors++;
+	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -913,13 +950,19 @@ static int ipgre_tunnel_bind_dev(struct net_devic=
e *dev)
 	/* Guess output device to choose reasonable mtu and needed_headroom *=
/
=20
 	if (iph->daddr) {
-		struct flowi fl =3D { .oif =3D tunnel->parms.link,
-				    .nl_u =3D { .ip4_u =3D
-					      { .daddr =3D iph->daddr,
-						.saddr =3D iph->saddr,
-						.tos =3D RT_TOS(iph->tos) } },
-				    .proto =3D IPPROTO_GRE };
+		struct flowi fl =3D {
+			.oif =3D tunnel->parms.link,
+			.nl_u =3D {
+				.ip4_u =3D {
+					.daddr =3D iph->daddr,
+					.saddr =3D iph->saddr,
+					.tos =3D RT_TOS(iph->tos)
+				}
+			},
+			.proto =3D IPPROTO_GRE
+		};
 		struct rtable *rt;
+
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev =3D rt->dst.dev;
 			ip_rt_put(rt);
@@ -1171,13 +1214,19 @@ static int ipgre_open(struct net_device *dev)
 	struct ip_tunnel *t =3D netdev_priv(dev);
=20
 	if (ipv4_is_multicast(t->parms.iph.daddr)) {
-		struct flowi fl =3D { .oif =3D t->parms.link,
-				    .nl_u =3D { .ip4_u =3D
-					      { .daddr =3D t->parms.iph.daddr,
-						.saddr =3D t->parms.iph.saddr,
-						.tos =3D RT_TOS(t->parms.iph.tos) } },
-				    .proto =3D IPPROTO_GRE };
+		struct flowi fl =3D {
+			.oif =3D t->parms.link,
+			.nl_u =3D {
+				.ip4_u =3D {
+					.daddr =3D t->parms.iph.daddr,
+					.saddr =3D t->parms.iph.saddr,
+					.tos =3D RT_TOS(t->parms.iph.tos)
+				}
+			},
+			.proto =3D IPPROTO_GRE
+		};
 		struct rtable *rt;
+
 		if (ip_route_output_key(dev_net(dev), &rt, &fl))
 			return -EADDRNOTAVAIL;
 		dev =3D rt->dst.dev;
@@ -1217,12 +1266,19 @@ static const struct net_device_ops ipgre_netdev=
_ops =3D {
 	.ndo_start_xmit		=3D ipgre_tunnel_xmit,
 	.ndo_do_ioctl		=3D ipgre_tunnel_ioctl,
 	.ndo_change_mtu		=3D ipgre_tunnel_change_mtu,
+	.ndo_get_stats		=3D ipgre_get_stats,
 };
=20
+static void ipgre_dev_free(struct net_device *dev)
+{
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		=3D &ipgre_netdev_ops;
-	dev->destructor 	=3D free_netdev;
+	dev->destructor 	=3D ipgre_dev_free;
=20
 	dev->type		=3D ARPHRD_IPGRE;
 	dev->needed_headroom 	=3D LL_MAX_HEADER + sizeof(struct iphdr) + 4;
@@ -1260,6 +1316,10 @@ static int ipgre_tunnel_init(struct net_device *=
dev)
 	} else
 		dev->header_ops =3D &ipgre_header_ops;
=20
+	dev->tstats =3D alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
 	return 0;
 }
=20
@@ -1446,6 +1506,10 @@ static int ipgre_tap_init(struct net_device *dev=
)
=20
 	ipgre_tunnel_bind_dev(dev);
=20
+	dev->tstats =3D alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
 	return 0;
 }
=20
@@ -1456,6 +1520,7 @@ static const struct net_device_ops ipgre_tap_netd=
ev_ops =3D {
 	.ndo_set_mac_address 	=3D eth_mac_addr,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_change_mtu		=3D ipgre_tunnel_change_mtu,
+	.ndo_get_stats		=3D ipgre_get_stats,
 };
=20
 static void ipgre_tap_setup(struct net_device *dev)
@@ -1464,7 +1529,7 @@ static void ipgre_tap_setup(struct net_device *de=
v)
 	ether_setup(dev);
=20
 	dev->netdev_ops		=3D &ipgre_tap_netdev_ops;
-	dev->destructor 	=3D free_netdev;
+	dev->destructor 	=3D ipgre_dev_free;
=20
 	dev->iflink		=3D 0;
 	dev->features		|=3D NETIF_F_NETNS_LOCAL;


