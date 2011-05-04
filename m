From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] ipv4: Kill rt->rt_{src, dst} usage in IP GRE tunnels.
Date: Wed, 04 May 2011 13:19:41 -0700 (PDT)
Message-ID: <20110504.131941.245391789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab1EDUUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1B5FE24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First, make callers pass on-stack flowi4 to ip_route_output_gre()
so they can get at the fully resolved flow key.

Next, use that in ipgre_tunnel_xmit() to avoid the need to use
rt->rt_{dst,src}.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |   19 +++++++++----------
 net/ipv4/ip_gre.c   |   37 +++++++++++++++++++++----------------
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 8c02c87..9f8070b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -152,19 +152,18 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 	return ip_route_output_flow(net, fl4, sk);
 }
 
-static inline struct rtable *ip_route_output_gre(struct net *net,
+static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4 *fl4,
 						 __be32 daddr, __be32 saddr,
 						 __be32 gre_key, __u8 tos, int oif)
 {
-	struct flowi4 fl4 = {
-		.flowi4_oif = oif,
-		.daddr = daddr,
-		.saddr = saddr,
-		.flowi4_tos = tos,
-		.flowi4_proto = IPPROTO_GRE,
-		.fl4_gre_key = gre_key,
-	};
-	return ip_route_output_key(net, &fl4);
+	memset(fl4, 0, sizeof(*fl4));
+	fl4->flowi4_oif = oif;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_proto = IPPROTO_GRE;
+	fl4->fl4_gre_key = gre_key;
+	return ip_route_output_key(net, fl4);
 }
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 24efd35..10e9b5a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -699,6 +699,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	struct pcpu_tstats *tstats;
 	const struct iphdr  *old_iph = ip_hdr(skb);
 	const struct iphdr  *tiph;
+	struct flowi4 fl4;
 	u8     tos;
 	__be16 df;
 	struct rtable *rt;     			/* Route to the other host */
@@ -769,7 +770,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
 	}
 
-	rt = ip_route_output_gre(dev_net(dev), dst, tiph->saddr,
+	rt = ip_route_output_gre(dev_net(dev), &fl4, dst, tiph->saddr,
 				 tunnel->parms.o_key, RT_TOS(tos),
 				 tunnel->parms.link);
 	if (IS_ERR(rt)) {
@@ -873,8 +874,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_GRE;
 	iph->tos		=	ipgre_ecn_encapsulate(tos, old_iph, skb);
-	iph->daddr		=	rt->rt_dst;
-	iph->saddr		=	rt->rt_src;
+	iph->daddr		=	fl4.daddr;
+	iph->saddr		=	fl4.saddr;
 
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
@@ -938,12 +939,14 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 	/* Guess output device to choose reasonable mtu and needed_headroom */
 
 	if (iph->daddr) {
-		struct rtable *rt = ip_route_output_gre(dev_net(dev),
-							iph->daddr, iph->saddr,
-							tunnel->parms.o_key,
-							RT_TOS(iph->tos),
-							tunnel->parms.link);
-
+		struct flowi4 fl4;
+		struct rtable *rt;
+
+		rt = ip_route_output_gre(dev_net(dev), &fl4,
+					 iph->daddr, iph->saddr,
+					 tunnel->parms.o_key,
+					 RT_TOS(iph->tos),
+					 tunnel->parms.link);
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
@@ -1196,13 +1199,15 @@ static int ipgre_open(struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 
 	if (ipv4_is_multicast(t->parms.iph.daddr)) {
-		struct rtable *rt = ip_route_output_gre(dev_net(dev),
-							t->parms.iph.daddr,
-							t->parms.iph.saddr,
-							t->parms.o_key,
-							RT_TOS(t->parms.iph.tos),
-							t->parms.link);
-
+		struct flowi4 fl4;
+		struct rtable *rt;
+
+		rt = ip_route_output_gre(dev_net(dev), &fl4,
+					 t->parms.iph.daddr,
+					 t->parms.iph.saddr,
+					 t->parms.o_key,
+					 RT_TOS(t->parms.iph.tos),
+					 t->parms.link);
 		if (IS_ERR(rt))
 			return -EADDRNOTAVAIL;
 		dev = rt->dst.dev;
-- 
1.7.4.5

