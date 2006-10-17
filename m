From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems when
 source address undefined.
Date: Tue, 17 Oct 2006 03:27:39 +0300
Message-ID: <4534237B.9090205@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:18706 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422985AbWJQA1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:27:42 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With IPv6 routing subtrees we need to take into account that the
source address is typically not specified at the time of the route
lookup.

There are two separate cases where this can happen. In the typical
case the source address hasn't been selected before the route lookup.
Skipping a source prefix policy rule because of this will lead to
inconsistent routing behavior between for example bound and unbound
sockets.

We avoid this by passing the policy rule source prefix to the lookup
and source address selection functions. For source prefix rules the
source address is selected before the route lookup, otherwise we do it
the other way around. The source address selection algorithm remains
virtually unchanged; the source prefix is just used to verify the
selected address is compatible with the rule. If the source address
doesn't match, the route lookup with the current rule is aborted and
is started again with the next rule in the policy chain.

The more uncommon case is where the unspecified address is actually
used as a valid source address. When the kernel uses the unspecified
address it doesn't touch the routing table. We need to make sure a
userland application using a raw socket can do the same. If the user
includes the IPv6 header we therefore have to bypass the source
address selection even then the source address is unspecified. In
addition, we don't insert any routing cache entry created by such a
lookup.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 include/net/addrconf.h |    4 +++-
 include/net/ip6_fib.h  |   16 +++++++++++++++-
 net/ipv6/addrconf.c    |   13 +++++++++++--
 net/ipv6/fib6_rules.c  |   16 ++--------------
 net/ipv6/ip6_fib.c     |    2 +-
 net/ipv6/ndisc.c       |    2 +-
 net/ipv6/route.c       |   41 +++++++++++++++++++++++++++++++++--------
 7 files changed, 66 insertions(+), 28 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index d075693..7066362 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -67,8 +67,10 @@ #endif
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
 						struct net_device *dev,
 						int strict);
-extern int			ipv6_get_saddr(int pref_if,
+struct rt6key;
+extern int			ipv6_get_saddr(int pref_if,
 					       struct in6_addr *daddr,
+					       struct rt6key *sconstr,
 					       struct in6_addr *saddr);
 extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
 extern int			ipv6_rcv_saddr_equal(const struct sock *sk,
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e4438de..8887b5c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -21,6 +21,7 @@ #include <linux/spinlock.h>
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/netlink.h>
+#include <net/fib_rules.h>

 struct rt6_info;

@@ -77,6 +78,18 @@ struct rt6key
 	int		plen;
 };

+struct fib6_rule
+{
+	struct fib_rule		common;
+	struct rt6key		src;
+	struct rt6key		dst;
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	u32			fwmark;
+	u32			fwmask;
+#endif
+	u8			tclass;
+};
+
 struct fib6_table;

 struct rt6_info
@@ -174,7 +187,8 @@ #define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
 #endif

 typedef struct rt6_info *(*pol_lookup_t)(struct fib6_table *,
-					 struct flowi *, int);
+					 struct flowi *, int,
+					 struct fib6_rule *);

 /*
  *	exported functions
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 09a22c8..486af76 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -904,7 +904,8 @@ static int inline ipv6_saddr_label(const
 	return 1;
 }

-int ipv6_get_saddr(int pref_if, struct in6_addr *daddr, struct in6_addr *saddr)
+int ipv6_get_saddr(int pref_if, struct in6_addr *daddr,
+		   struct rt6key *sconstr, struct in6_addr *saddr)
 {
 	struct ipv6_saddr_score hiscore;
 	struct inet6_ifaddr *ifa_result = NULL;
@@ -1151,7 +1152,15 @@ record_it:

 	if (!ifa_result)
 		return -EADDRNOTAVAIL;
-	
+#ifdef CONFIG_IPV6_SUBTREES
+	/* Don't let source address based routing interfere with the
+	   address selection, just make sure the selected address
+	   matches the routing policy constraints */
+
+	if (sconstr && sconstr->plen > 0 &&
+	    !ipv6_prefix_equal(saddr, &sconstr->addr, sconstr->plen))
+		return -EADDRNOTAVAIL;
+#endif
 	ipv6_addr_copy(saddr, &ifa_result->addr);
 	in6_ifa_put(ifa_result);
 	return 0;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index fc56a19..a5b7803 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -21,18 +21,6 @@ #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/netlink.h>

-struct fib6_rule
-{
-	struct fib_rule		common;
-	struct rt6key		src;
-	struct rt6key		dst;
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
-	u32			fwmark;
-	u32			fwmask;
-#endif
-	u8			tclass;
-};
-
 static struct fib_rules_ops fib6_rules_ops;

 static struct fib6_rule main_rule = {
@@ -98,7 +86,7 @@ static int fib6_rule_action(struct fib_r

 	table = fib6_get_table(rule->table);
 	if (table)
-		rt = lookup(table, flp, flags);
+		rt = lookup(table, flp, flags, (struct fib6_rule *) rule);

 	if (rt != &ip6_null_entry)
 		goto out;
@@ -123,7 +111,7 @@ static int fib6_rule_match(struct fib_ru
 		return 0;

 	if (r->src.plen) {
-		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
+		if (flags & RT6_LOOKUP_F_HAS_SADDR &&
 		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
 			return 0;
 	}
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 8fcae7a..c77e44b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -280,7 +280,7 @@ struct fib6_table *fib6_get_table(u32 id
 struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
 				   pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags, NULL);
 }

 static void __init fib6_tables_init(void)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3ac4e12..809132f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -449,7 +449,7 @@ static void ndisc_send_na(struct net_dev
 		src_addr = solicited_addr;
 		in6_ifa_put(ifp);
 	} else {
-		if (ipv6_get_saddr(dev->ifindex, daddr, &tmpaddr))
+		if (ipv6_get_saddr(dev->ifindex, daddr, NULL, &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7c3438e..e0bfd30 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -499,7 +499,8 @@ do { \
 } while(0)

 static struct rt6_info *ip6_pol_route_lookup(struct fib6_table *table,
-					     struct flowi *fl, int flags)
+					     struct flowi *fl, int flags,
+					     struct fib6_rule *rule)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt;
@@ -624,7 +625,8 @@ #endif
 }

 static struct rt6_info *ip6_pol_route_input(struct fib6_table *table,
-					    struct flowi *fl, int flags)
+					    struct flowi *fl, int flags,
+					    struct fib6_rule *rule)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -719,7 +721,8 @@ #endif
 }

 static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
-					     struct flowi *fl, int flags)
+					     struct flowi *fl, int flags,
+					     struct fib6_rule *rule)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -730,6 +733,16 @@ static struct rt6_info *ip6_pol_route_ou
 	struct in6_addr saddr;

 	ipv6_addr_copy(&saddr, &fl->fl6_src);
+#ifdef CONFIG_IPV6_SUBTREES
+	if (!has_saddr && rule->src.plen > 0) {
+		/* a source prefix specific policy rule has to override the
+		   normal source address selection process */
+		if (ipv6_get_saddr(fl->oif, &fl->fl6_dst, &rule->src, &saddr))
+			goto no_saddr;
+		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
+		ipv6_addr_copy(&fl->fl6_src, &saddr);
+	}
+#endif
 relookup:
 	read_lock_bh(&table->tb6_lock);

@@ -749,7 +762,7 @@ restart:
 	if (!has_saddr) {
 		int oif = rt->rt6i_dev->ifindex;
 		/* policy rule doesn't restrict source address */
-		if (ipv6_get_saddr(oif, &fl->fl6_dst, &saddr))
+		if (ipv6_get_saddr(oif, &fl->fl6_dst, NULL, &saddr))
 			goto no_saddr;
 		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
 		ipv6_addr_copy(&fl->fl6_src, &saddr);
@@ -769,7 +782,12 @@ #endif

 	dst_hold(&rt->u.dst);
 	if (nrt) {
-		if (!ip6_ins_rt(nrt))
+		/*
+		 * Kernel generated messages with an unspecifed source
+		 * address don't change the routing table; make sure user
+		 * generated messages behave the same.
+		 */
+		if (ipv6_addr_any(&rt->rt6i_src.addr) || !ip6_ins_rt(nrt))
 			goto out2;
 	}

@@ -806,7 +824,12 @@ struct dst_entry * ip6_route_output(stru
 	if (rt6_need_strict(&fl->fl6_dst))
 		flags |= RT6_LOOKUP_F_IFACE;

-	if (!ipv6_addr_any(&fl->fl6_src))
+	/*
+	 * In some rare cases (RS, DAD, etc.) the unspecified address
+	 * may be used as a source address. Such packets can only be sent
+	 * from userspace if the user passes the complete IPv6 header.
+	 */
+	if (!ipv6_addr_any(&fl->fl6_src) || (sk && inet_sk(sk)->hdrincl))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;

 	return fib6_rule_lookup(fl, flags, ip6_pol_route_output);
@@ -1304,7 +1327,8 @@ struct ip6rd_flowi {

 static struct rt6_info *__ip6_route_redirect(struct fib6_table *table,
 					     struct flowi *fl,
-					     int flags)
+					     int flags,
+					     struct fib6_rule *rule)
 {
 	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl;
 	struct rt6_info *rt;
@@ -2055,7 +2079,8 @@ #endif
 		NLA_PUT_U32(skb, RTA_IIF, iif);
 	else if (dst) {
 		struct in6_addr saddr_buf;
-		if (!ipv6_get_saddr(rt->rt6i_dev->ifindex, dst, &saddr_buf))
+		if (!ipv6_get_saddr(rt->rt6i_dev->ifindex, dst,
+				    &rt->rt6i_src, &saddr_buf))
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}

-- 
1.4.2.3

