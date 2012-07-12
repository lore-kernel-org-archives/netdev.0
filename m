From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/16] ipv6: Move bulk of redirect handling into
 rt6_redirect().
Date: Thu, 12 Jul 2012 01:11:45 -0700 (PDT)
Message-ID: <20120712.011145.869615842423163323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2GLILq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:46 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B0A085824C5
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This sets things up so that we can have the protocol error handlers
call down into the ipv6 route code for redirects just as ipv4 already
does.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    7 +----
 net/ipv6/ndisc.c        |   72 +--------------------------------------------
 net/ipv6/route.c        |   75 +++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 72 insertions(+), 82 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 58cb3fc..5cedbd7 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -133,12 +133,7 @@ extern int			rt6_route_rcv(struct net_device *dev,
 					      u8 *opt, int len,
 					      const struct in6_addr *gwaddr);
 
-extern void			rt6_redirect(const struct in6_addr *dest,
-					     const struct in6_addr *src,
-					     const struct in6_addr *saddr,
-					     struct neighbour *neigh,
-					     u8 *lladdr,
-					     int on_link);
+extern void			rt6_redirect(struct sk_buff *skb);
 
 extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 			    int oif, u32 mark);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a3189ba..b8d53e1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,8 +143,6 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-#define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
-
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
 	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
@@ -1336,16 +1334,6 @@ out:
 
 static void ndisc_redirect_rcv(struct sk_buff *skb)
 {
-	struct inet6_dev *in6_dev;
-	struct icmp6hdr *icmph;
-	const struct in6_addr *dest;
-	const struct in6_addr *target;	/* new first hop to destination */
-	struct neighbour *neigh;
-	int on_link = 0;
-	struct ndisc_options ndopts;
-	int optlen;
-	u8 *lladdr = NULL;
-
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	switch (skb->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
@@ -1362,65 +1350,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
-	optlen = skb->tail - skb->transport_header;
-	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
-
-	if (optlen < 0) {
-		ND_PRINTK(2, warn, "Redirect: packet too short\n");
-		return;
-	}
-
-	icmph = icmp6_hdr(skb);
-	target = (const struct in6_addr *) (icmph + 1);
-	dest = target + 1;
-
-	if (ipv6_addr_is_multicast(dest)) {
-		ND_PRINTK(2, warn,
-			  "Redirect: destination address is multicast\n");
-		return;
-	}
-
-	if (ipv6_addr_equal(dest, target)) {
-		on_link = 1;
-	} else if (ipv6_addr_type(target) !=
-		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
-		ND_PRINTK(2, warn,
-			  "Redirect: target address is not link-local unicast\n");
-		return;
-	}
-
-	in6_dev = __in6_dev_get(skb->dev);
-	if (!in6_dev)
-		return;
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_redirects)
-		return;
-
-	/* RFC2461 8.1:
-	 *	The IP source address of the Redirect MUST be the same as the current
-	 *	first-hop router for the specified ICMP Destination Address.
-	 */
-
-	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
-		ND_PRINTK(2, warn, "Redirect: invalid ND options\n");
-		return;
-	}
-	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
-					     skb->dev);
-		if (!lladdr) {
-			ND_PRINTK(2, warn,
-				  "Redirect: invalid link-layer address length\n");
-			return;
-		}
-	}
-
-	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
-	if (neigh) {
-		rt6_redirect(dest, &ipv6_hdr(skb)->daddr,
-			     &ipv6_hdr(skb)->saddr, neigh, lladdr,
-			     on_link);
-		neigh_release(neigh);
-	}
+	rt6_redirect(skb);
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 563f12c..73cf3f78 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1690,14 +1690,78 @@ static struct rt6_info *ip6_route_redirect(const struct in6_addr *dest,
 						   flags, __ip6_route_redirect);
 }
 
-void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
-		  const struct in6_addr *saddr,
-		  struct neighbour *neigh, u8 *lladdr, int on_link)
+void rt6_redirect(struct sk_buff *skb)
 {
-	struct rt6_info *rt, *nrt = NULL;
+	struct net *net = dev_net(skb->dev);
 	struct netevent_redirect netevent;
-	struct net *net = dev_net(neigh->dev);
+	struct rt6_info *rt, *nrt = NULL;
+	const struct in6_addr *target;
 	struct neighbour *old_neigh;
+	const struct in6_addr *dest;
+	const struct in6_addr *src;
+	const struct in6_addr *saddr;
+	struct ndisc_options ndopts;
+	struct inet6_dev *in6_dev;
+	struct neighbour *neigh;
+	struct icmp6hdr *icmph;
+	int on_link, optlen;
+	u8 *lladdr = NULL;
+
+	optlen = skb->tail - skb->transport_header;
+	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
+
+	if (optlen < 0) {
+		net_dbg_ratelimited("rt6_redirect: packet too short\n");
+		return;
+	}
+
+	icmph = icmp6_hdr(skb);
+	target = (const struct in6_addr *) (icmph + 1);
+	dest = target + 1;
+
+	if (ipv6_addr_is_multicast(dest)) {
+		net_dbg_ratelimited("rt6_redirect: destination address is multicast\n");
+		return;
+	}
+
+	if (ipv6_addr_equal(dest, target)) {
+		on_link = 1;
+	} else if (ipv6_addr_type(target) !=
+		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
+		net_dbg_ratelimited("rt6_redirect: target address is not link-local unicast\n");
+		return;
+	}
+
+	in6_dev = __in6_dev_get(skb->dev);
+	if (!in6_dev)
+		return;
+	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_redirects)
+		return;
+
+	/* RFC2461 8.1:
+	 *	The IP source address of the Redirect MUST be the same as the current
+	 *	first-hop router for the specified ICMP Destination Address.
+	 */
+
+	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
+		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
+		return;
+	}
+	if (ndopts.nd_opts_tgt_lladdr) {
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
+					     skb->dev);
+		if (!lladdr) {
+			net_dbg_ratelimited("rt6_redirect: invalid link-layer address length\n");
+			return;
+		}
+	}
+
+	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
+	if (!neigh)
+		return;
+
+	src = &ipv6_hdr(skb)->daddr;
+	saddr = &ipv6_hdr(skb)->saddr;
 
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
@@ -1756,6 +1820,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	}
 
 out:
+	neigh_release(neigh);
 	dst_release(&rt->dst);
 }
 
-- 
1.7.10.4
