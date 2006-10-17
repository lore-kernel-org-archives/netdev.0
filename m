From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 7/13] [RFC] [IPV6] Move source address selection into route
 lookup.
Date: Tue, 17 Oct 2006 03:13:17 +0300
Message-ID: <4534201D.7070002@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:274 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422968AbWJQANT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:13:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch moves the normal source address selection from
ip6_dst_lookup() into ip6_pol_route_output(), but shouldn't
change the routing or source address selection behavior in
any way.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_output.c |    6 ------
 net/ipv6/route.c      |   37 ++++++++++++++++++++++---------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6671691..0019007 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -855,12 +855,6 @@ static int ip6_dst_lookup_tail(struct so
 	if ((err = (*dst)->error))
 		goto out_err_release;

-	if (ipv6_addr_any(&fl->fl6_src)) {
-		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
-		if (err)
-			goto out_err_release;
-	}
-
 	return 0;

 out_err_release:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aa96be8..b7b8148 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -536,7 +536,7 @@ struct rt6_info *rt6_lookup(struct in6_a
 	int flags = strict ? RT6_LOOKUP_F_IFACE : 0;

 	if (saddr) {
-		memcpy(&fl.fl6_src, saddr, sizeof(*saddr));
+		ipv6_addr_copy(&fl.fl6_src, saddr);
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	}

@@ -629,13 +629,11 @@ static struct rt6_info *ip6_pol_route_in
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
-	int strict = 0;
+	int strict = flags & RT6_LOOKUP_F_IFACE;
 	int attempts = 3;
 	int err;
 	int reachable = RT6_LOOKUP_F_REACHABLE;

-	strict |= flags & RT6_LOOKUP_F_IFACE;
-
 relookup:
 	read_lock_bh(&table->tb6_lock);

@@ -726,22 +724,22 @@ static struct rt6_info *ip6_pol_route_ou
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
-	int strict = 0;
-	int attempts = 3;
-	int err;
+	int has_saddr = flags & RT6_LOOKUP_F_HAS_SADDR;
+	int strict = flags & RT6_LOOKUP_F_IFACE;
 	int reachable = RT6_LOOKUP_F_REACHABLE;
+	int attempts = 3;
+	struct in6_addr saddr;

-	strict |= flags & RT6_LOOKUP_F_IFACE;
-
+	ipv6_addr_copy(&saddr, &fl->fl6_src);
 relookup:
 	read_lock_bh(&table->tb6_lock);

 restart_2:
-	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
+	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &saddr);

 restart:
 	rt = rt6_select(&fn->leaf, fl->oif, strict | reachable);
-	BACKTRACK(&fl->fl6_src);
+	BACKTRACK(&saddr);
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
@@ -749,6 +747,13 @@ restart:
 	dst_hold(&rt->u.dst);
 	read_unlock_bh(&table->tb6_lock);

+	if (!has_saddr) {
+		/* policy rule doesn't restrict source address */
+		if (ipv6_get_saddr(&rt->u.dst, &fl->fl6_dst, &saddr))
+			goto no_saddr;
+		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
+		ipv6_addr_copy(&fl->fl6_src, &saddr);
+	}
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
 	else {
@@ -764,8 +769,7 @@ #endif

 	dst_hold(&rt->u.dst);
 	if (nrt) {
-		err = ip6_ins_rt(nrt);
-		if (!err)
+		if (!ip6_ins_rt(nrt))
 			goto out2;
 	}

@@ -778,7 +782,6 @@ #endif
 	 */
 	dst_release(&rt->u.dst);
 	goto relookup;
-
 out:
 	if (reachable) {
 		reachable = 0;
@@ -790,6 +793,10 @@ out2:
 	rt->u.dst.lastuse = jiffies;
 	rt->u.dst.__use++;
 	return rt;
+no_saddr:
+	rt = &ip6_null_entry;
+	dst_hold(&rt->u.dst);
+	goto out2;
 }

 struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
@@ -2044,7 +2051,7 @@ #endif
 		NLA_PUT_U32(skb, RTA_IIF, iif);
 	else if (dst) {
 		struct in6_addr saddr_buf;
-		if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
+		if (!ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf))
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}

-- 
1.4.2.3

