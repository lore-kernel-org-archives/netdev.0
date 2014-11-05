From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 2/2] ip6_tunnel: Add support for wildcard tunnel
 endpoints.
Date: Wed, 5 Nov 2014 08:03:50 +0100
Message-ID: <20141105070350.GD6390@secunet.com>
References: <20141105070248.GC6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42280 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbaKEHJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 02:09:13 -0500
Content-Disposition: inline
In-Reply-To: <20141105070248.GC6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for tunnels with local or
remote wildcard endpoints. With this we get a
NBMA tunnel mode like we have it for ipv4 and
sit tunnels.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_tunnel.c | 41 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 40 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a8f94ff..4550d08 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -183,6 +183,7 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
 	unsigned int hash = HASH(remote, local);
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+	struct in6_addr any;
 
 	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
@@ -190,6 +191,22 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
+
+	memset(&any, 0, sizeof(any));
+	hash = HASH(&any, local);
+	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
+		if (ipv6_addr_equal(local, &t->parms.laddr) &&
+		    (t->dev->flags & IFF_UP))
+			return t;
+	}
+
+	hash = HASH(remote, &any);
+	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
+		if (ipv6_addr_equal(remote, &t->parms.raddr) &&
+		    (t->dev->flags & IFF_UP))
+			return t;
+	}
+
 	t = rcu_dereference(ip6n->tnls_wc[0]);
 	if (t && (t->dev->flags & IFF_UP))
 		return t;
@@ -979,7 +996,29 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	u8 proto;
 	int err = -1;
 
-	if (!fl6->flowi6_mark)
+	/* NBMA tunnel */
+	if (ipv6_addr_any(&t->parms.raddr)) {
+		struct in6_addr *addr6;
+		struct neighbour *neigh;
+		int addr_type;
+
+		if (!skb_dst(skb))
+			goto tx_err_link_failure;
+
+		neigh = dst_neigh_lookup(skb_dst(skb),
+					 &ipv6_hdr(skb)->daddr);
+		if (!neigh)
+			goto tx_err_link_failure;
+
+		addr6 = (struct in6_addr *)&neigh->primary_key;
+		addr_type = ipv6_addr_type(addr6);
+
+		if (addr_type == IPV6_ADDR_ANY)
+			addr6 = &ipv6_hdr(skb)->daddr;
+
+		memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
+		neigh_release(neigh);
+	} else if (!fl6->flowi6_mark)
 		dst = ip6_tnl_dst_check(t);
 
 	if (!ip6_tnl_xmit_ctl(t, &fl6->saddr, &fl6->daddr))
-- 
1.9.1
