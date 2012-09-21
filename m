From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v4 1/1] ipv6: add support of ECMP
Date: Fri, 21 Sep 2012 11:59:05 +0200
Message-ID: <1348221545-14747-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20120920.171525.2005584636029506440.davem@davemloft.net>
 <1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: bernat@luffy.cx, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54267 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932972Ab2IUJ6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 05:58:01 -0400
In-Reply-To: <1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the support of equal cost multipath for IPv6.

The patch is based on a previous work from
Luc Saillard <luc.saillard@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/networking/ip-sysctl.txt |   8 ++
 include/net/ip6_fib.h                  |  13 ++
 include/net/netns/ipv6.h               |   3 +
 net/ipv6/Kconfig                       |  10 ++
 net/ipv6/ip6_fib.c                     |  73 +++++++++++
 net/ipv6/route.c                       | 222 ++++++++++++++++++++++++++++++++-
 6 files changed, 325 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c7fc107..018bf8b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1330,6 +1330,14 @@ ratelimit - INTEGER
 	otherwise the minimal space between responses in milliseconds.
 	Default: 1000
 
+route/*:
+multipath_algorithm - INTEGER
+	Define the method to select route between each possible path.
+	0 for hash/flow method (recommanded by RFC4311)
+	1 for round robin method
+	2 for random method
+	Default: 0
+
 
 IPv6 Update by:
 Pekka Savola <pekkas@netcore.fi>
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index cd64cf3..37e502a 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -47,6 +47,10 @@ struct fib6_config {
 	unsigned long	fc_expires;
 	struct nlattr	*fc_mx;
 	int		fc_mx_len;
+#ifdef CONFIG_IPV6_MULTIPATH
+	struct nlattr	*fc_mp;
+	int		fc_mp_len;
+#endif
 
 	struct nl_info	fc_nlinfo;
 };
@@ -98,6 +102,15 @@ struct rt6_info {
 	struct fib6_node		*rt6i_node;
 
 	struct in6_addr			rt6i_gateway;
+#ifdef CONFIG_IPV6_MULTIPATH
+	/*
+	 * siblings is a list of rt6_info that have the the same metric/weight,
+	 * destination, but not the same gateway. nsiblings is just a cache
+	 * to speed up lookup.
+	 */
+	unsigned int			rt6i_nsiblings;
+	struct list_head		rt6i_siblings;
+#endif
 
 	atomic_t			rt6i_ref;
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 214cb0a..820d4a6 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -26,6 +26,9 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_gc_elasticity;
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
+#ifdef CONFIG_IPV6_MULTIPATH
+	int ip6_rt_multipath_algo;
+#endif
 	int icmpv6_time;
 };
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 4f7fe72..c43fdf7 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -266,4 +266,14 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_MULTIPATH
+	bool "IPv6: equal cost multipath for IPv6 routing"
+	depends on IPV6
+	default y
+	---help---
+	  Enable this option to support ECMP for IPv6.
+
+	  Three algorithms for route selection are available: hash of packet
+	  header (recommanded by RFC4311), round robin and random.
+
 endif # IPV6
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 13690d6..3541e44 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -672,6 +672,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			    iter->rt6i_idev == rt->rt6i_idev &&
 			    ipv6_addr_equal(&iter->rt6i_gateway,
 					    &rt->rt6i_gateway)) {
+#ifdef CONFIG_IPV6_MULTIPATH
+				if (rt->rt6i_nsiblings)
+					rt->rt6i_nsiblings = 0;
+#endif
 				if (!(iter->rt6i_flags & RTF_EXPIRES))
 					return -EEXIST;
 				if (!(rt->rt6i_flags & RTF_EXPIRES))
@@ -680,6 +684,23 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					rt6_set_expires(iter, rt->dst.expires);
 				return -EEXIST;
 			}
+#ifdef CONFIG_IPV6_MULTIPATH
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
+#endif
 		}
 
 		if (iter->rt6i_metric > rt->rt6i_metric)
@@ -692,6 +713,43 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	if (ins == &fn->leaf)
 		fn->rr_ptr = NULL;
 
+#ifdef CONFIG_IPV6_MULTIPATH
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
+		 * siblings. We can check if all the counter are equal.
+		 */
+		rt6i_nsiblings = 0;
+		list_for_each_entry_safe(sibling, temp_sibling,
+					 &rt->rt6i_siblings,
+					 rt6i_siblings) {
+			sibling->rt6i_nsiblings++;
+			if (unlikely(sibling->rt6i_nsiblings !=
+				     rt->rt6i_nsiblings)) {
+				pr_err("Wrong number of siblings for route %p (%d)\n",
+				       sibling, sibling->rt6i_nsiblings);
+			}
+			rt6i_nsiblings++;
+		}
+		if (unlikely(rt6i_nsiblings != rt->rt6i_nsiblings)) {
+			pr_err("Wrong number of siblings for route %p. I have %d routes, but count %d siblings\n",
+			       rt, rt6i_nsiblings, rt->rt6i_nsiblings);
+		}
+	}
+#endif
 	/*
 	 *	insert node
 	 */
@@ -1197,6 +1255,21 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	if (fn->rr_ptr == rt)
 		fn->rr_ptr = NULL;
 
+#ifdef CONFIG_IPV6_MULTIPATH
+	/* Remove this entry from other siblings */
+	if (rt->rt6i_nsiblings) {
+		struct rt6_info *sibling, *next_sibling;
+
+		/* For each siblings, decrement the counter of siblings */
+		list_for_each_entry_safe(sibling, next_sibling,
+					 &rt->rt6i_siblings, rt6i_siblings) {
+			sibling->rt6i_nsiblings--;
+		}
+		rt->rt6i_nsiblings = 0;
+		list_del_init(&rt->rt6i_siblings);
+	}
+#endif
+
 	/* Adjust walkers */
 	read_lock(&fib6_walker_lock);
 	FOR_WALKERS(w) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0607ee3..bfad74f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -57,6 +57,9 @@
 #include <net/xfrm.h>
 #include <net/netevent.h>
 #include <net/netlink.h>
+#ifdef CONFIG_IPV6_MULTIPATH
+#include <net/nexthop.h>
+#endif
 
 #include <asm/uaccess.h>
 
@@ -288,6 +291,10 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
+#ifdef CONFIG_IPV6_MULTIPATH
+		INIT_LIST_HEAD(&rt->rt6i_siblings);
+		rt->rt6i_nsiblings = 0;
+#endif
 	}
 	return rt;
 }
@@ -384,6 +391,121 @@ static bool rt6_need_strict(const struct in6_addr *daddr)
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
 }
 
+#ifdef CONFIG_IPV6_MULTIPATH
+/*
+ *	Multipath route selection.
+ */
+
+/*
+ * Pseudo random candidate function
+ */
+static int rt6_info_hash_randomfn(unsigned int candidate_count)
+{
+	return random32() % candidate_count;
+}
+
+/*
+ * Fake Round Robin candidate function
+ * If we want real RR, we need to add a counter in each route
+ */
+static int rt6_info_hash_falserr(unsigned int candidate_count)
+{
+	static unsigned int seed;
+	seed++;
+	return seed % candidate_count;
+}
+
+/*
+ * Pseudo random candidate using the src port, and other information
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
+/*
+ * This function return an index used to select (at random, round robin, ...)
+ * a route between any siblings.
+ *
+ * Note: fl6 can be NULL
+ */
+static unsigned int rt6_info_hashfn(struct net *net,
+				    const struct rt6_info *rt,
+				    const struct flowi6 *fl6)
+{
+	int candidate_count = rt->rt6i_nsiblings + 1;
+
+	switch (net->ipv6.sysctl.ip6_rt_multipath_algo) {
+	case 0:
+		if (fl6 == NULL)
+			return 0;
+		return rt6_info_hash_nhsfn(candidate_count, fl6);
+	case 1:
+		return rt6_info_hash_falserr(candidate_count);
+	case 2:
+		return rt6_info_hash_randomfn(candidate_count);
+	}
+
+	return 0;
+}
+
+static struct rt6_info *rt6_multipath_select(struct net *net,
+					     struct rt6_info *match,
+					     struct flowi6 *fl6)
+{
+	struct rt6_info *sibling, *next_sibling;
+	int route_choosen;
+
+	route_choosen = rt6_info_hashfn(net, match, fl6);
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
+#endif /* CONFIG_IPV6_MULTIPATH */
+
 /*
  *	Route lookup. Any table->tb6_lock is implied.
  */
@@ -701,6 +823,10 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
+#ifdef CONFIG_IPV6_MULTIPATH
+	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
+		rt = rt6_multipath_select(net, rt, fl6);
+#endif
 	BACKTRACK(net, &fl6->saddr);
 out:
 	dst_use(&rt->dst, jiffies);
@@ -862,7 +988,10 @@ restart_2:
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
-
+#ifdef CONFIG_IPV6_MULTIPATH
+	if (rt->rt6i_nsiblings && oif == 0)
+		rt = rt6_multipath_select(net, rt, fl6);
+#endif
 	BACKTRACK(net, &fl6->saddr);
 	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
@@ -2243,6 +2372,9 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_IIF]		= { .type = NLA_U32 },
 	[RTA_PRIORITY]          = { .type = NLA_U32 },
 	[RTA_METRICS]           = { .type = NLA_NESTED },
+#ifdef CONFIG_IPV6_MULTIPATH
+	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
+#endif
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2320,11 +2452,69 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tb[RTA_TABLE])
 		cfg->fc_table = nla_get_u32(tb[RTA_TABLE]);
 
+#ifdef CONFIG_IPV6_MULTIPATH
+	if (tb[RTA_MULTIPATH]) {
+		cfg->fc_mp = nla_data(tb[RTA_MULTIPATH]);
+		cfg->fc_mp_len = nla_len(tb[RTA_MULTIPATH]);
+	}
+#endif
+
 	err = 0;
 errout:
 	return err;
 }
 
+#ifdef CONFIG_IPV6_MULTIPATH
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
+#endif /* CONFIG_IPV6_MULTIPATH */
+
 static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib6_config cfg;
@@ -2334,7 +2524,12 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	if (err < 0)
 		return err;
 
-	return ip6_route_del(&cfg);
+#ifdef CONFIG_IPV6_MULTIPATH
+	if (cfg.fc_mp)
+		return ip6_route_multipath(&cfg, 0);
+	else
+#endif
+		return ip6_route_del(&cfg);
 }
 
 static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
@@ -2346,7 +2541,12 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	if (err < 0)
 		return err;
 
-	return ip6_route_add(&cfg);
+#ifdef CONFIG_IPV6_MULTIPATH
+	if (cfg.fc_mp)
+		return ip6_route_multipath(&cfg, 1);
+	else
+#endif
+		return ip6_route_add(&cfg);
 }
 
 static inline size_t rt6_nlmsg_size(void)
@@ -2844,6 +3044,15 @@ ctl_table ipv6_route_table_template[] = {
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_ms_jiffies,
 	},
+#ifdef CONFIG_IPV6_MULTIPATH
+	{
+		.procname	=	"multipath_algorithm",
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_multipath_algo,
+		.maxlen		=	sizeof(int),
+		.mode		=	0644,
+		.proc_handler	=	proc_dointvec,
+	},
+#endif
 	{ }
 };
 
@@ -2867,6 +3076,9 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 		table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
 		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
+#ifdef CONFIG_IPV6_MULTIPATH
+		table[10].data = &net->ipv6.sysctl.ip6_rt_multipath_algo;
+#endif
 	}
 
 	return table;
@@ -2926,7 +3138,9 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.sysctl.ip6_rt_gc_elasticity = 9;
 	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
-
+#ifdef CONFIG_IPV6_MULTIPATH
+	net->ipv6.sysctl.ip6_rt_multipath_algo = 0;
+#endif
 	net->ipv6.ip6_rt_gc_expire = 30*HZ;
 
 	ret = 0;
-- 
1.7.12
