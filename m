From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/16] ipv6: Pull main logic of rt6_redirect() into
 rt6_do_redirect().
Date: Thu, 12 Jul 2012 01:11:52 -0700 (PDT)
Message-ID: <20120712.011152.2075702285333417131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465Ab2GLILx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:53 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7D74E5824C5
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hook it into dst_ops->redirect as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   80 +++++++++++++++++++++++++++++++++---------------------
 1 file changed, 49 insertions(+), 31 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 73cf3f78..545b152 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -79,6 +79,7 @@ static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
+static void		rt6_do_redirect(struct dst_entry *dst, struct sk_buff *skb);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
@@ -174,6 +175,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.negative_advice	=	ip6_negative_advice,
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
+	.redirect		=	rt6_do_redirect,
 	.local_out		=	__ip6_local_out,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
@@ -1690,28 +1692,26 @@ static struct rt6_info *ip6_route_redirect(const struct in6_addr *dest,
 						   flags, __ip6_route_redirect);
 }
 
-void rt6_redirect(struct sk_buff *skb)
+static void rt6_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 	struct netevent_redirect netevent;
 	struct rt6_info *rt, *nrt = NULL;
 	const struct in6_addr *target;
-	struct neighbour *old_neigh;
-	const struct in6_addr *dest;
-	const struct in6_addr *src;
-	const struct in6_addr *saddr;
 	struct ndisc_options ndopts;
+	const struct in6_addr *dest;
+	struct neighbour *old_neigh;
 	struct inet6_dev *in6_dev;
 	struct neighbour *neigh;
 	struct icmp6hdr *icmph;
-	int on_link, optlen;
-	u8 *lladdr = NULL;
+	int optlen, on_link;
+	u8 *lladdr;
 
 	optlen = skb->tail - skb->transport_header;
 	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 
 	if (optlen < 0) {
-		net_dbg_ratelimited("rt6_redirect: packet too short\n");
+		net_dbg_ratelimited("rt6_do_redirect: packet too short\n");
 		return;
 	}
 
@@ -1720,15 +1720,16 @@ void rt6_redirect(struct sk_buff *skb)
 	dest = target + 1;
 
 	if (ipv6_addr_is_multicast(dest)) {
-		net_dbg_ratelimited("rt6_redirect: destination address is multicast\n");
+		net_dbg_ratelimited("rt6_do_redirect: destination address is multicast\n");
 		return;
 	}
 
+	on_link = 0;
 	if (ipv6_addr_equal(dest, target)) {
 		on_link = 1;
 	} else if (ipv6_addr_type(target) !=
 		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
-		net_dbg_ratelimited("rt6_redirect: target address is not link-local unicast\n");
+		net_dbg_ratelimited("rt6_do_redirect: target address is not link-local unicast\n");
 		return;
 	}
 
@@ -1747,6 +1748,8 @@ void rt6_redirect(struct sk_buff *skb)
 		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
 		return;
 	}
+
+	lladdr = NULL;
 	if (ndopts.nd_opts_tgt_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
 					     skb->dev);
@@ -1756,19 +1759,26 @@ void rt6_redirect(struct sk_buff *skb)
 		}
 	}
 
-	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
-	if (!neigh)
+	rt = (struct rt6_info *) dst;
+	if (rt == net->ipv6.ip6_null_entry) {
+		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
 		return;
+	}
 
-	src = &ipv6_hdr(skb)->daddr;
-	saddr = &ipv6_hdr(skb)->saddr;
+	/* Redirect received -> path was valid.
+	 * Look, redirects are sent only in response to data packets,
+	 * so that this nexthop apparently is reachable. --ANK
+	 */
+	dst_confirm(&rt->dst);
 
-	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
+	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
+	if (!neigh)
+		return;
 
-	if (rt == net->ipv6.ip6_null_entry) {
-		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
+	/* Duplicate redirect: silently ignore. */
+	old_neigh = rt->n;
+	if (neigh == old_neigh)
 		goto out;
-	}
 
 	/*
 	 *	We have finally decided to accept it.
@@ -1781,18 +1791,6 @@ void rt6_redirect(struct sk_buff *skb)
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
-	/*
-	 * Redirect received -> path was valid.
-	 * Look, redirects are sent only in response to data packets,
-	 * so that this nexthop apparently is reachable. --ANK
-	 */
-	dst_confirm(&rt->dst);
-
-	/* Duplicate redirect: silently ignore. */
-	old_neigh = rt->n;
-	if (neigh == old_neigh)
-		goto out;
-
 	nrt = ip6_rt_copy(rt, dest);
 	if (!nrt)
 		goto out;
@@ -1815,12 +1813,32 @@ void rt6_redirect(struct sk_buff *skb)
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags & RTF_CACHE) {
+		rt = (struct rt6_info *) dst_clone(&rt->dst);
 		ip6_del_rt(rt);
-		return;
 	}
 
 out:
 	neigh_release(neigh);
+}
+
+void rt6_redirect(struct sk_buff *skb)
+{
+	const struct in6_addr *target;
+	const struct in6_addr *dest;
+	const struct in6_addr *src;
+	const struct in6_addr *saddr;
+	struct icmp6hdr *icmph;
+	struct rt6_info *rt;
+
+	icmph = icmp6_hdr(skb);
+	target = (const struct in6_addr *) (icmph + 1);
+	dest = target + 1;
+
+	src = &ipv6_hdr(skb)->daddr;
+	saddr = &ipv6_hdr(skb)->saddr;
+
+	rt = ip6_route_redirect(dest, src, saddr, skb->dev);
+	rt6_do_redirect(&rt->dst, skb);
 	dst_release(&rt->dst);
 }
 
-- 
1.7.10.4
