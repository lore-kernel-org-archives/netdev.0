From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/16] ipv6: Use icmpv6_notify() to propagate redirect,
 instead of rt6_redirect().
Date: Thu, 12 Jul 2012 01:12:20 -0700 (PDT)
Message-ID: <20120712.011220.1572444012633788899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932904Ab2GLIMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:12:21 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C82475824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:12:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And delete rt6_redirect(), since it is no longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    2 -
 include/net/ipv6.h      |    2 +
 net/ipv6/icmp.c         |    2 +-
 net/ipv6/ndisc.c        |    2 +-
 net/ipv6/route.c        |  107 -----------------------------------------------
 5 files changed, 4 insertions(+), 111 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 6939405..b6b6f7d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -133,8 +133,6 @@ extern int			rt6_route_rcv(struct net_device *dev,
 					      u8 *opt, int len,
 					      const struct in6_addr *gwaddr);
 
-extern void			rt6_redirect(struct sk_buff *skb);
-
 extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 			    int oif, u32 mark);
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d4261d4..f695f39 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -251,6 +251,8 @@ static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 		atomic_dec(&fl->users);
 }
 
+extern void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info);
+
 extern int 			ip6_ra_control(struct sock *sk, int sel);
 
 extern int			ipv6_parse_hopopts(struct sk_buff *skb);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a113f7d..24d69db 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -598,7 +598,7 @@ out:
 	icmpv6_xmit_unlock(sk);
 }
 
-static void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
+void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 {
 	const struct inet6_protocol *ipprot;
 	int inner_offset;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b8d53e1..ff36194 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1350,7 +1350,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
-	rt6_redirect(skb);
+	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f52cf83..7296af1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1633,92 +1633,6 @@ static int ip6_route_del(struct fib6_config *cfg)
 	return err;
 }
 
-/*
- *	Handle redirects
- */
-struct ip6rd_flowi {
-	struct flowi6 fl6;
-	struct in6_addr gateway;
-};
-
-static struct rt6_info *__ip6_route_redirect(struct net *net,
-					     struct fib6_table *table,
-					     struct flowi6 *fl6,
-					     int flags)
-{
-	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl6;
-	struct rt6_info *rt;
-	struct fib6_node *fn;
-
-	/*
-	 * Get the "current" route for this destination and
-	 * check if the redirect has come from approriate router.
-	 *
-	 * RFC 2461 specifies that redirects should only be
-	 * accepted if they come from the nexthop to the target.
-	 * Due to the way the routes are chosen, this notion
-	 * is a bit fuzzy and one might need to check all possible
-	 * routes.
-	 */
-
-	read_lock_bh(&table->tb6_lock);
-	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
-restart:
-	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
-		/*
-		 * Current route is on-link; redirect is always invalid.
-		 *
-		 * Seems, previous statement is not true. It could
-		 * be node, which looks for us as on-link (f.e. proxy ndisc)
-		 * But then router serving it might decide, that we should
-		 * know truth 8)8) --ANK (980726).
-		 */
-		if (rt6_check_expired(rt))
-			continue;
-		if (!(rt->rt6i_flags & RTF_GATEWAY))
-			continue;
-		if (fl6->flowi6_oif != rt->dst.dev->ifindex)
-			continue;
-		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
-			continue;
-		break;
-	}
-
-	if (!rt)
-		rt = net->ipv6.ip6_null_entry;
-	BACKTRACK(net, &fl6->saddr);
-out:
-	dst_hold(&rt->dst);
-
-	read_unlock_bh(&table->tb6_lock);
-
-	return rt;
-};
-
-static struct rt6_info *ip6_route_redirect(const struct in6_addr *dest,
-					   const struct in6_addr *src,
-					   const struct in6_addr *gateway,
-					   struct net_device *dev)
-{
-	int flags = RT6_LOOKUP_F_HAS_SADDR;
-	struct net *net = dev_net(dev);
-	struct ip6rd_flowi rdfl = {
-		.fl6 = {
-			.flowi6_oif = dev->ifindex,
-			.daddr = *dest,
-			.saddr = *src,
-		},
-	};
-
-	rdfl.gateway = *gateway;
-
-	if (rt6_need_strict(dest))
-		flags |= RT6_LOOKUP_F_IFACE;
-
-	return (struct rt6_info *)fib6_rule_lookup(net, &rdfl.fl6,
-						   flags, __ip6_route_redirect);
-}
-
 static void rt6_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
@@ -1848,27 +1762,6 @@ out:
 	neigh_release(neigh);
 }
 
-void rt6_redirect(struct sk_buff *skb)
-{
-	const struct in6_addr *target;
-	const struct in6_addr *dest;
-	const struct in6_addr *src;
-	const struct in6_addr *saddr;
-	struct icmp6hdr *icmph;
-	struct rt6_info *rt;
-
-	icmph = icmp6_hdr(skb);
-	target = (const struct in6_addr *) (icmph + 1);
-	dest = target + 1;
-
-	src = &ipv6_hdr(skb)->daddr;
-	saddr = &ipv6_hdr(skb)->saddr;
-
-	rt = ip6_route_redirect(dest, src, saddr, skb->dev);
-	rt6_do_redirect(&rt->dst, skb);
-	dst_release(&rt->dst);
-}
-
 /*
  *	Misc support functions
  */
-- 
1.7.10.4
