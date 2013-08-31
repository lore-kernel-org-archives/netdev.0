From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v3] ipv6:introduce function to find route for redirect
Date: Sat, 31 Aug 2013 13:09:33 +0800
Message-ID: <52217A8D.9010008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:28476 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752936Ab3HaFOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 01:14:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4861 says that the IP source address of the Redirect is the
same as the current first-hop router for the specified ICMP
Destination Address, so the gateway should be taken into
consideration when we find the route for redirect.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 Changes for v3:
 1.Fix the comments style problems

 net/ipv6/ah6.c     |  2 +-
 net/ipv6/esp6.c    |  2 +-
 net/ipv6/icmp.c    |  2 +-
 net/ipv6/ipcomp6.c |  2 +-
 net/ipv6/ndisc.c   |  3 ++-
 net/ipv6/route.c   | 78 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 78 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index bb02e17..73784c3 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -628,7 +628,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, 0, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index aeac0dc..d3618a7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -447,7 +447,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, 0, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 7cfc8d2..73681c2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -92,7 +92,7 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	else if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, 0, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 
 	if (!(type & ICMPV6_INFOMSG_MASK))
 		if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 7af5aee..5636a91 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -76,7 +76,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, 0, 0);
+		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..90f474b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1370,7 +1370,8 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 
 	if (!ndopts.nd_opts_rh) {
-		ip6_redirect_no_header(skb, dev_net(skb->dev), 0, 0);
+		ip6_redirect_no_header(skb, dev_net(skb->dev),
+							skb->dev->ifindex, 0);
 		return;
 	}
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8d9a93e..2e1d378 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1157,6 +1157,74 @@ void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
 
+/* Handle redirects */
+struct ip6rd_flowi {
+	struct flowi6 fl6;
+	struct in6_addr gateway;
+};
+
+static struct rt6_info *__ip6_route_redirect(struct net *net,
+					     struct fib6_table *table,
+					     struct flowi6 *fl6,
+					     int flags)
+{
+	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl6;
+	struct rt6_info *rt;
+	struct fib6_node *fn;
+
+	/* Get the "current" route for this destination and
+	 * check if the redirect has come from approriate router.
+	 *
+	 * RFC 4861 specifies that redirects should only be
+	 * accepted if they come from the nexthop to the target.
+	 * Due to the way the routes are chosen, this notion
+	 * is a bit fuzzy and one might need to check all possible
+	 * routes.
+	 */
+
+	read_lock_bh(&table->tb6_lock);
+	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
+restart:
+	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
+		if (rt6_check_expired(rt))
+			continue;
+		if (!(rt->rt6i_flags & RTF_GATEWAY))
+			continue;
+		if (fl6->flowi6_oif != rt->dst.dev->ifindex)
+			continue;
+		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
+			continue;
+		break;
+	}
+
+	if (!rt)
+		rt = net->ipv6.ip6_null_entry;
+	BACKTRACK(net, &fl6->saddr);
+out:
+	dst_hold(&rt->dst);
+
+	read_unlock_bh(&table->tb6_lock);
+
+	return rt;
+};
+
+static struct dst_entry *ip6_route_redirect(const struct flowi6 *fl6,
+					   const struct in6_addr *gateway,
+					   struct net *net)
+{
+	int flags = RT6_LOOKUP_F_HAS_SADDR;
+	struct ip6rd_flowi rdfl;
+
+	rdfl.fl6 = *fl6;
+	rdfl.gateway = *gateway;
+
+	if (rt6_need_strict(&fl6->daddr))
+		flags |= RT6_LOOKUP_F_IFACE;
+
+	return fib6_rule_lookup(net, &rdfl.fl6,
+						   flags, __ip6_route_redirect);
+}
+
 void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 {
 	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
@@ -1171,9 +1239,8 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
 
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (!dst->error)
-		rt6_do_redirect(dst, NULL, skb);
+	dst = ip6_route_redirect(&fl6, &ipv6_hdr(skb)->saddr, net);
+	rt6_do_redirect(dst, NULL, skb);
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_redirect);
@@ -1193,9 +1260,8 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	fl6.daddr = msg->dest;
 	fl6.saddr = iph->daddr;
 
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (!dst->error)
-		rt6_do_redirect(dst, NULL, skb);
+	dst = ip6_route_redirect(&fl6, &iph->saddr, net);
+	rt6_do_redirect(dst, NULL, skb);
 	dst_release(dst);
 }
 
-- 
1.8.3.1
