From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tunnel: eliminate recursion field
Date: Wed, 23 Sep 2009 22:28:33 +0200
Message-ID: <4ABA84F1.5000802@gmail.com>
References: <4ABA8254.9000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45337 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbZIWU2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 16:28:32 -0400
In-Reply-To: <4ABA8254.9000701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> It seems recursion field from "struct ip_tunnel" is not anymore neede=
d.
> recursion prevention is done at the upper level (in dev_queue_xmit())=
,
> since we use HARD_TX_LOCK protection for tunnels.
>=20
> This avoids a cache line ping pong on "struct ip_tunnel" : This struc=
ture
> should be now mostly read on xmit and receive paths.

Oops I forgot ipv6 tunnels, silly me, here is an updated version.

Thanks

[PATCH] tunnel: eliminate recursion field

It seems recursion field from "struct ip_tunnel" is not anymore needed.
recursion prevention is done at the upper level (in dev_queue_xmit()),
since we use HARD_TX_LOCK protection for tunnels.

This avoids a cache line ping pong on "struct ip_tunnel" : This structu=
re
should be now mostly read on xmit and receive paths.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipip.h    |    1 -
 net/ipv4/ip_gre.c     |   13 +------------
 net/ipv4/ipip.c       |    8 --------
 net/ipv6/ip6_tunnel.c |    7 -------
 net/ipv6/sit.c        |    8 --------
 5 files changed, 1 insertion(+), 36 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 5d3036f..76e3ea6 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -12,7 +12,6 @@ struct ip_tunnel
 	struct ip_tunnel	*next;
 	struct net_device	*dev;
=20
-	int			recursion;	/* Depth of hard_start_xmit recursion */
 	int			err_count;	/* Number of arrived ICMP errors */
 	unsigned long		err_time;	/* Time when the last ICMP error arrived */
=20
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d9645c9..41ada99 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -66,10 +66,7 @@
    solution, but it supposes maintaing new variable in ALL
    skb, even if no tunneling is used.
=20
-   Current solution: t->recursion lock breaks dead loops. It looks
-   like dev->tbusy flag, but I preferred new variable, because
-   the semantics is different. One day, when hard_start_xmit
-   will be multithreaded we will have to use skb->encapsulation.
+   Current solution: HARD_TX_LOCK lock breaks dead loops.
=20
=20
=20
@@ -678,11 +675,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
=20
-	if (tunnel->recursion++) {
-		stats->collisions++;
-		goto tx_error;
-	}
-
 	if (dev->type =3D=3D ARPHRD_ETHER)
 		IPCB(skb)->flags =3D 0;
=20
@@ -820,7 +812,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 			ip_rt_put(rt);
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
-			tunnel->recursion--;
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -888,7 +879,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 	nf_reset(skb);
=20
 	IPTUNNEL_XMIT();
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
=20
 tx_error_icmp:
@@ -897,7 +887,6 @@ tx_error_icmp:
 tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 }
=20
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62548cb..08ccd34 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -402,11 +402,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 	__be32 dst =3D tiph->daddr;
 	int    mtu;
=20
-	if (tunnel->recursion++) {
-		stats->collisions++;
-		goto tx_error;
-	}
-
 	if (skb->protocol !=3D htons(ETH_P_IP))
 		goto tx_error;
=20
@@ -485,7 +480,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff =
*skb, struct net_device *dev)
 			ip_rt_put(rt);
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
-			tunnel->recursion--;
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -523,7 +517,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff =
*skb, struct net_device *dev)
 	nf_reset(skb);
=20
 	IPTUNNEL_XMIT();
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
=20
 tx_error_icmp:
@@ -531,7 +524,6 @@ tx_error_icmp:
 tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 }
=20
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7d25bbe..c595bbe 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1043,11 +1043,6 @@ ip6_tnl_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
 	struct net_device_stats *stats =3D &t->dev->stats;
 	int ret;
=20
-	if (t->recursion++) {
-		stats->collisions++;
-		goto tx_err;
-	}
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		ret =3D ip4ip6_tnl_xmit(skb, dev);
@@ -1062,14 +1057,12 @@ ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
 	if (ret < 0)
 		goto tx_err;
=20
-	t->recursion--;
 	return NETDEV_TX_OK;
=20
 tx_err:
 	stats->tx_errors++;
 	stats->tx_dropped++;
 	kfree_skb(skb);
-	t->recursion--;
 	return NETDEV_TX_OK;
 }
=20
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0ae4f64..fcb5396 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -626,11 +626,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buf=
f *skb,
 	struct in6_addr *addr6;
 	int addr_type;
=20
-	if (tunnel->recursion++) {
-		stats->collisions++;
-		goto tx_error;
-	}
-
 	if (skb->protocol !=3D htons(ETH_P_IPV6))
 		goto tx_error;
=20
@@ -753,7 +748,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff=
 *skb,
 			ip_rt_put(rt);
 			stats->tx_dropped++;
 			dev_kfree_skb(skb);
-			tunnel->recursion--;
 			return NETDEV_TX_OK;
 		}
 		if (skb->sk)
@@ -794,7 +788,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff=
 *skb,
 	nf_reset(skb);
=20
 	IPTUNNEL_XMIT();
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
=20
 tx_error_icmp:
@@ -802,7 +795,6 @@ tx_error_icmp:
 tx_error:
 	stats->tx_errors++;
 	dev_kfree_skb(skb);
-	tunnel->recursion--;
 	return NETDEV_TX_OK;
 }
=20
