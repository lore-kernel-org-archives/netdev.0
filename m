From: nicolas.dichtel@6wind.com
Subject: [PATCH net-next v8 1/1] ipv6: add support of equal cost multipath (ECMP)
Date: Mon, 22 Oct 2012 15:42:09 +0200
Message-ID: <1350913329-4044-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20121021.204146.1395047796384194358.davem@davemloft.net>
 <1350913329-4044-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:59595 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab2JVNdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 09:33:55 -0400
In-Reply-To: <1350913329-4044-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Each nexthop is added like a single route in the routing table. All routes
that have the same metric/weight and destination but not the same gateway
are considering as ECMP routes. They are linked together, through a list called
rt6i_siblings.

ECMP routes can be added in one shot, with RTA_MULTIPATH attribute or one after
the other (in both case, the flag NLM_F_EXCL should not be set).

The patch is based on a previous work from
Luc Saillard <luc.saillard@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_fib.h |  10 ++++
 net/ipv6/ip6_fib.c    |  57 +++++++++++++++++++++
 net/ipv6/route.c      | 136 ++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 200 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 8a2a203..20210d7 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -47,6 +47,8 @@ struct fib6_config {
 	unsigned long	fc_expires;
 	struct nlattr	*fc_mx;
 	int		fc_mx_len;
+	int		fc_mp_len;
+	struct nlattr	*fc_mp;
 
 	struct nl_info	fc_nlinfo;
 };
@@ -99,6 +101,14 @@ struct rt6_info {
 
 	struct in6_addr			rt6i_gateway;
 
+	/* Multipath routes:
+	 * siblings is a list of rt6_info that have the the same metric/weight,
+	 * destination, but not the same gateway. nsiblings is just a cache
+	 * to speed up lookup.
+	 */
+	struct list_head		rt6i_siblings;
+	unsigned int			rt6i_nsiblings;
+
 	atomic_t			rt6i_ref;
 
 	/* These are in a separate cache line. */
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 24995a9..710cafd 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -672,6 +672,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			    iter->rt6i_idev == rt->rt6i_idev &&
 			    ipv6_addr_equal(&iter->rt6i_gateway,
 					    &rt->rt6i_gateway)) {
+				if (rt->rt6i_nsiblings)
+					rt->rt6i_nsiblings = 0;
 				if (!(iter->rt6i_flags & RTF_EXPIRES))
 					return -EEXIST;
 				if (!(rt->rt6i_flags & RTF_EXPIRES))
@@ -680,6 +682,21 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					rt6_set_expires(iter, rt->dst.expires);
 				return -EEXIST;
 			}
+			/* If we have the same destination and the same metric,
+			 * but not the same gateway, then the route we try to
+			 * add is sibling to this route, increment our counter
+			 * of siblings, and later we will add our route to the
+			 * list.
+			 * Only static routes (which don't have flag
+			 * RTF_EXPIRES) are used for ECMPv6.
+			 *
+			 * To avoid long list, we only had siblings if the
+			 * route have a gateway.
+			 */
+			if (rt->rt6i_flags & RTF_GATEWAY &&
+			    !(rt->rt6i_flags & RTF_EXPIRES) &&
+			    !(iter->rt6i_flags & RTF_EXPIRES))
+				rt->rt6i_nsiblings++;
 		}
 
 		if (iter->rt6i_metric > rt->rt6i_metric)
@@ -692,6 +709,35 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	if (ins == &fn->leaf)
 		fn->rr_ptr = NULL;
 
+	/* Link this route to others same route. */
+	if (rt->rt6i_nsiblings) {
+		unsigned int rt6i_nsiblings;
+		struct rt6_info *sibling, *temp_sibling;
+
+		/* Find the first route that have the same metric */
+		sibling = fn->leaf;
+		while (sibling) {
+			if (sibling->rt6i_metric == rt->rt6i_metric) {
+				list_add_tail(&rt->rt6i_siblings,
+					      &sibling->rt6i_siblings);
+				break;
+			}
+			sibling = sibling->dst.rt6_next;
+		}
+		/* For each sibling in the list, increment the counter of
+		 * siblings. BUG() if counters does not match, list of siblings
+		 * is broken!
+		 */
+		rt6i_nsiblings = 0;
+		list_for_each_entry_safe(sibling, temp_sibling,
+					 &rt->rt6i_siblings, rt6i_siblings) {
+			sibling->rt6i_nsiblings++;
+			BUG_ON(sibling->rt6i_nsiblings != rt->rt6i_nsiblings);
+			rt6i_nsiblings++;
+		}
+		BUG_ON(rt6i_nsiblings != rt->rt6i_nsiblings);
+	}
+
 	/*
 	 *	insert node
 	 */
@@ -1193,6 +1239,17 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	if (fn->rr_ptr == rt)
 		fn->rr_ptr = NULL;
 
+	/* Remove this entry from other siblings */
+	if (rt->rt6i_nsiblings) {
+		struct rt6_info *sibling, *next_sibling;
+
+		list_for_each_entry_safe(sibling, next_sibling,
+					 &rt->rt6i_siblings, rt6i_siblings)
+			sibling->rt6i_nsiblings--;
+		rt->rt6i_nsiblings = 0;
+		list_del_init(&rt->rt6i_siblings);
+	}
+
 	/* Adjust walkers */
 	read_lock(&fib6_walker_lock);
 	FOR_WALKERS(w) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7c7e963..126da56 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -57,6 +57,7 @@
 #include <net/xfrm.h>
 #include <net/netevent.h>
 #include <net/netlink.h>
+#include <net/nexthop.h>
 
 #include <asm/uaccess.h>
 
@@ -289,6 +290,8 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 		rt->rt6i_genid = rt_genid(net);
+		INIT_LIST_HEAD(&rt->rt6i_siblings);
+		rt->rt6i_nsiblings = 0;
 	}
 	return rt;
 }
@@ -385,6 +388,69 @@ static bool rt6_need_strict(const struct in6_addr *daddr)
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
 }
 
+/* Multipath route selection:
+ *   Hash based function using packet header and flowlabel.
+ * Adapted from fib_info_hashfn()
+ */
+static int rt6_info_hash_nhsfn(unsigned int candidate_count,
+			       const struct flowi6 *fl6)
+{
+	unsigned int val = fl6->flowi6_proto;
+
+	val ^= fl6->daddr.s6_addr32[0];
+	val ^= fl6->daddr.s6_addr32[1];
+	val ^= fl6->daddr.s6_addr32[2];
+	val ^= fl6->daddr.s6_addr32[3];
+
+	val ^= fl6->saddr.s6_addr32[0];
+	val ^= fl6->saddr.s6_addr32[1];
+	val ^= fl6->saddr.s6_addr32[2];
+	val ^= fl6->saddr.s6_addr32[3];
+
+	/* Work only if this not encapsulated */
+	switch (fl6->flowi6_proto) {
+	case IPPROTO_UDP:
+	case IPPROTO_TCP:
+	case IPPROTO_SCTP:
+		val ^= fl6->fl6_sport;
+		val ^= fl6->fl6_dport;
+		break;
+
+	case IPPROTO_ICMPV6:
+		val ^= fl6->fl6_icmp_type;
+		val ^= fl6->fl6_icmp_code;
+		break;
+	}
+	/* RFC6438 recommands to use flowlabel */
+	val ^= fl6->flowlabel;
+
+	/* Perhaps, we need to tune, this function? */
+	val = val ^ (val >> 7) ^ (val >> 12);
+	return val % candidate_count;
+}
+
+static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
+					     struct flowi6 *fl6)
+{
+	struct rt6_info *sibling, *next_sibling;
+	int route_choosen;
+
+	route_choosen = rt6_info_hash_nhsfn(match->rt6i_nsiblings + 1, fl6);
+	/* Don't change the route, if route_choosen == 0
+	 * (siblings does not include ourself)
+	 */
+	if (route_choosen)
+		list_for_each_entry_safe(sibling, next_sibling,
+				&match->rt6i_siblings, rt6i_siblings) {
+			route_choosen--;
+			if (route_choosen == 0) {
+				match = sibling;
+				break;
+			}
+		}
+	return match;
+}
+
 /*
  *	Route lookup. Any table->tb6_lock is implied.
  */
@@ -702,6 +768,8 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
+	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
+		rt = rt6_multipath_select(rt, fl6);
 	BACKTRACK(net, &fl6->saddr);
 out:
 	dst_use(&rt->dst, jiffies);
@@ -863,7 +931,8 @@ restart_2:
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
-
+	if (rt->rt6i_nsiblings && oif == 0)
+		rt = rt6_multipath_select(rt, fl6);
 	BACKTRACK(net, &fl6->saddr);
 	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
@@ -2249,6 +2318,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_IIF]		= { .type = NLA_U32 },
 	[RTA_PRIORITY]          = { .type = NLA_U32 },
 	[RTA_METRICS]           = { .type = NLA_NESTED },
+	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2326,11 +2396,65 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tb[RTA_TABLE])
 		cfg->fc_table = nla_get_u32(tb[RTA_TABLE]);
 
+	if (tb[RTA_MULTIPATH]) {
+		cfg->fc_mp = nla_data(tb[RTA_MULTIPATH]);
+		cfg->fc_mp_len = nla_len(tb[RTA_MULTIPATH]);
+	}
+
 	err = 0;
 errout:
 	return err;
 }
 
+static int ip6_route_multipath(struct fib6_config *cfg, int add)
+{
+	struct fib6_config r_cfg;
+	struct rtnexthop *rtnh;
+	int remaining;
+	int attrlen;
+	int err = 0, last_err = 0;
+
+beginning:
+	rtnh = (struct rtnexthop *)cfg->fc_mp;
+	remaining = cfg->fc_mp_len;
+
+	/* Parse a Multipath Entry */
+	while (rtnh_ok(rtnh, remaining)) {
+		memcpy(&r_cfg, cfg, sizeof(*cfg));
+		if (rtnh->rtnh_ifindex)
+			r_cfg.fc_ifindex = rtnh->rtnh_ifindex;
+
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen > 0) {
+			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
+
+			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
+			if (nla) {
+				nla_memcpy(&r_cfg.fc_gateway, nla, 16);
+				r_cfg.fc_flags |= RTF_GATEWAY;
+			}
+		}
+		err = add ? ip6_route_add(&r_cfg) : ip6_route_del(&r_cfg);
+		if (err) {
+			last_err = err;
+			/* If we are trying to remove a route, do not stop the
+			 * loop when ip6_route_del() fails (because next hop is
+			 * already gone), we should try to remove all next hops.
+			 */
+			if (add) {
+				/* If add fails, we should try to delete all
+				 * next hops that have been already added.
+				 */
+				add = 0;
+				goto beginning;
+			}
+		}
+		rtnh = rtnh_next(rtnh, &remaining);
+	}
+
+	return last_err;
+}
+
 static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib6_config cfg;
@@ -2340,7 +2464,10 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	if (err < 0)
 		return err;
 
-	return ip6_route_del(&cfg);
+	if (cfg.fc_mp)
+		return ip6_route_multipath(&cfg, 0);
+	else
+		return ip6_route_del(&cfg);
 }
 
 static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
@@ -2352,7 +2479,10 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	if (err < 0)
 		return err;
 
-	return ip6_route_add(&cfg);
+	if (cfg.fc_mp)
+		return ip6_route_multipath(&cfg, 1);
+	else
+		return ip6_route_add(&cfg);
 }
 
 static inline size_t rt6_nlmsg_size(void)
-- 
1.7.12
