From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 4/5] [IPV6]: Policy Routing Rules
Date: Fri, 28 Jul 2006 00:40:12 +0200
Message-ID: <20060727224012.GA14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221850.124450582@postel.suug.ch> <20060726.163343.29813028.davem@davemloft.net> <20060726.164028.13029784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45268 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751067AbWG0Wjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 18:39:51 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060726.164028.13029784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds support for policy routing rules including a new
local table for routes with a local destination.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/ipv6/fib6_rules.c
===================================================================
--- /dev/null
+++ net-2.6.git/net/ipv6/fib6_rules.c
@@ -0,0 +1,255 @@
+/*
+ * net/ipv6/fib6_rules.c	IPv6 Routing Policy Rules
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License as
+ *	published by the Free Software Foundation, version 2.
+ *
+ * Authors
+ *	Ville Nuorvala		<vnuorval@tcs.hut.fi>
+ *	Thomas Graf		<tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/netdevice.h>
+
+#include <net/fib_rules.h>
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/netlink.h>
+
+struct fib6_rule
+{
+	struct fib_rule		common;
+	struct rt6key		src;
+	struct rt6key		dst;
+	u8			tclass;
+};
+
+static struct fib_rules_ops fib6_rules_ops;
+
+static struct fib6_rule main_rule = {
+	.common = {
+		.refcnt =	ATOMIC_INIT(2),
+		.pref =		0x7FFE,
+		.action =	FR_ACT_TO_TBL,
+		.table =	RT6_TABLE_MAIN,
+	},
+};
+
+static struct fib6_rule local_rule = {
+	.common = {
+		.refcnt =	ATOMIC_INIT(2),
+		.pref =		0,
+		.action =	FR_ACT_TO_TBL,
+		.table =	RT6_TABLE_LOCAL,
+		.flags =	FIB_RULE_PERMANENT,
+	},
+};
+
+static LIST_HEAD(fib6_rules);
+
+struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
+				   pol_lookup_t lookup)
+{
+	struct fib_lookup_arg arg = {
+		.lookup_ptr = lookup,
+	};
+
+	fib_rules_lookup(&fib6_rules_ops, fl, flags, &arg);
+	if (arg.rule)
+		fib_rule_put(arg.rule);
+
+	return (struct dst_entry *) arg.result;
+}
+
+int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
+		     int flags, struct fib_lookup_arg *arg)
+{
+	struct rt6_info *rt = NULL;
+	struct fib6_table *table;
+	pol_lookup_t lookup = arg->lookup_ptr;
+
+	switch (rule->action) {
+	case FR_ACT_TO_TBL:
+		break;
+	case FR_ACT_UNREACHABLE:
+		rt = &ip6_null_entry;
+		goto discard_pkt;
+	default:
+	case FR_ACT_BLACKHOLE:
+		rt = &ip6_blk_hole_entry;
+		goto discard_pkt;
+	case FR_ACT_PROHIBIT:
+		rt = &ip6_prohibit_entry;
+		goto discard_pkt;
+	}
+
+	table = fib6_get_table(rule->table);
+	if (table)
+		rt = lookup(table, flp, flags);
+
+	if (rt != &ip6_null_entry)
+		goto out;
+
+	dst_release(&rt->u.dst);
+discard_pkt:
+	dst_hold(&rt->u.dst);
+out:
+	arg->result = rt;
+	return rt == NULL ? -EAGAIN : 0;
+}
+
+
+static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
+{
+	struct fib6_rule *r = (struct fib6_rule *) rule;
+
+	if (!ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
+		return 0;
+
+#ifdef CONFIG_IPV6_SUBTREES
+	if ((flags & RT6_F_HAS_SADDR) &&
+	    !ipv6_prefix_equal(&fl->fl6_src, &r->r_src.addr, r->r_src.plen))
+		return 0;
+#endif
+
+	return 1;
+}
+
+static struct nla_policy fib6_rule_policy[RTA_MAX+1] __read_mostly = {
+	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },
+	[FRA_DST]	= { .minlen = sizeof(struct in6_addr) },
+};
+
+static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
+			       struct nlmsghdr *nlh, struct fib_rule_hdr *frh,
+			       struct nlattr **tb)
+{
+	int err = -EINVAL;
+	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
+
+	if (frh->src_len > 128 || frh->dst_len > 128 ||
+	    (frh->tos & ~IPV6_FLOWINFO_MASK))
+		goto errout;
+
+#ifndef CONFIG_IPV6_SUBTREES
+	if (frh->src_len > 0)
+		goto errout;
+#endif
+
+	if (rule->action == FR_ACT_TO_TBL) {
+		if (rule->table == RT6_TABLE_UNSPEC)
+			goto errout;
+
+		if (fib6_new_table(rule->table) == NULL) {
+			err = -ENOBUFS;
+			goto errout;
+		}
+	}
+
+	if (tb[FRA_SRC])
+		nla_memcpy(&rule6->src.addr, tb[FRA_SRC],
+			   sizeof(struct in6_addr));
+
+	if (tb[FRA_DST])
+		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
+			   sizeof(struct in6_addr));
+
+	rule6->src.plen = frh->src_len;
+	rule6->dst.plen = frh->dst_len;
+	rule6->tclass = frh->tos;
+
+	err = 0;
+errout:
+	return err;
+}
+
+static int fib6_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
+			     struct nlattr **tb)
+{
+	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
+
+	if (frh->src_len && (rule6->src.plen != frh->src_len))
+		return 0;
+
+	if (frh->dst_len && (rule6->dst.plen != frh->dst_len))
+		return 0;
+
+	if (frh->tos && (rule6->tclass != frh->tos))
+		return 0;
+
+	if (tb[FRA_SRC] &&
+	    nla_memcmp(tb[FRA_SRC], &rule6->src.addr, sizeof(struct in6_addr)))
+		return 0;
+
+	if (tb[FRA_DST] &&
+	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
+		return 0;
+
+	return 1;
+}
+
+static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
+			  struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
+{
+	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
+
+	frh->family = AF_INET6;
+	frh->dst_len = rule6->dst.plen;
+	frh->src_len = rule6->src.plen;
+	frh->tos = rule6->tclass;
+
+	if (rule6->dst.plen)
+		NLA_PUT(skb, FRA_DST, sizeof(struct in6_addr),
+			&rule6->dst.addr);
+
+	if (rule6->src.plen)
+		NLA_PUT(skb, FRA_SRC, sizeof(struct in6_addr),
+			&rule6->src.addr);
+
+	return 0;
+
+nla_put_failure:
+	return -ENOBUFS;
+}
+
+int fib6_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return fib_rules_dump(skb, cb, AF_INET6);
+}
+
+static u32 fib6_rule_default_pref(void)
+{
+	return 0x3FFF;
+}
+
+static struct fib_rules_ops fib6_rules_ops = {
+	.family			= AF_INET6,
+	.rule_size		= sizeof(struct fib6_rule),
+	.action			= fib6_rule_action,
+	.match			= fib6_rule_match,
+	.configure		= fib6_rule_configure,
+	.compare		= fib6_rule_compare,
+	.fill			= fib6_rule_fill,
+	.default_pref		= fib6_rule_default_pref,
+	.policy			= fib6_rule_policy,
+	.rules_list		= &fib6_rules,
+	.owner			= THIS_MODULE,
+};
+
+void __init fib6_rules_init(void)
+{
+	list_add_tail(&local_rule.common.list, &fib6_rules);
+	list_add_tail(&main_rule.common.list, &fib6_rules);
+
+	fib_rules_register(&fib6_rules_ops);
+}
+
+void fib6_rules_cleanup(void)
+{
+	fib_rules_unregister(&fib6_rules_ops);
+}
+
Index: net-2.6.git/net/ipv6/Kconfig
===================================================================
--- net-2.6.git.orig/net/ipv6/Kconfig
+++ net-2.6.git/net/ipv6/Kconfig
@@ -138,6 +138,7 @@ config IPV6_TUNNEL
 config IPV6_MULTIPLE_TABLES
 	bool "IPv6: Multiple Routing Tables"
 	depends on IPV6 && EXPERIMENTAL
+	select FIB_RULES
 	---help---
 	  Support multiple routing tables.
 
Index: net-2.6.git/net/ipv6/Makefile
===================================================================
--- net-2.6.git.orig/net/ipv6/Makefile
+++ net-2.6.git/net/ipv6/Makefile
@@ -13,6 +13,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_ou
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
+ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
Index: net-2.6.git/include/net/ip6_fib.h
===================================================================
--- net-2.6.git.orig/include/net/ip6_fib.h
+++ net-2.6.git/include/net/ip6_fib.h
@@ -155,16 +155,17 @@ struct fib6_table {
 
 #define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
 #define RT6_TABLE_MAIN		RT_TABLE_MAIN
-#define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
 #define RT6_TABLE_DFLT		RT6_TABLE_MAIN
 #define RT6_TABLE_INFO		RT6_TABLE_MAIN
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB6_TABLE_MIN		1
 #define FIB6_TABLE_MAX		RT_TABLE_MAX
+#define RT6_TABLE_LOCAL		RT_TABLE_LOCAL
 #else
 #define FIB6_TABLE_MIN		RT_TABLE_MAIN
 #define FIB6_TABLE_MAX		FIB6_TABLE_MIN
+#define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
 #endif
 
 #define RT6_F_STRICT		1
@@ -219,5 +220,11 @@ extern void			fib6_run_gc(unsigned long 
 extern void			fib6_gc_cleanup(void);
 
 extern void			fib6_init(void);
+
+extern void			fib6_rules_init(void);
+extern void			fib6_rules_cleanup(void);
+extern int			fib6_rules_dump(struct sk_buff *,
+						struct netlink_callback *);
+
 #endif
 #endif
Index: net-2.6.git/net/ipv6/route.c
===================================================================
--- net-2.6.git.orig/net/ipv6/route.c
+++ net-2.6.git/net/ipv6/route.c
@@ -139,6 +139,50 @@ struct rt6_info ip6_null_entry = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+
+struct rt6_info ip6_prohibit_entry = {
+	.u = {
+		.dst = {
+			.__refcnt	= ATOMIC_INIT(1),
+			.__use		= 1,
+			.dev		= &loopback_dev,
+			.obsolete	= -1,
+			.error		= -EACCES,
+			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
+			.input		= ip6_pkt_discard,
+			.output		= ip6_pkt_discard_out,
+			.ops		= &ip6_dst_ops,
+			.path		= (struct dst_entry*)&ip6_prohibit_entry,
+		}
+	},
+	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_metric	= ~(u32) 0,
+	.rt6i_ref	= ATOMIC_INIT(1),
+};
+
+struct rt6_info ip6_blk_hole_entry = {
+	.u = {
+		.dst = {
+			.__refcnt	= ATOMIC_INIT(1),
+			.__use		= 1,
+			.dev		= &loopback_dev,
+			.obsolete	= -1,
+			.error		= -EINVAL,
+			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
+			.input		= ip6_pkt_discard,
+			.output		= ip6_pkt_discard_out,
+			.ops		= &ip6_dst_ops,
+			.path		= (struct dst_entry*)&ip6_blk_hole_entry,
+		}
+	},
+	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_metric	= ~(u32) 0,
+	.rt6i_ref	= ATOMIC_INIT(1),
+};
+
+#endif
+
 /* allocate dst with ip6_dst_ops */
 static __inline__ struct rt6_info *ip6_dst_alloc(void)
 {
@@ -2398,10 +2442,16 @@ void __init ip6_route_init(void)
 #ifdef CONFIG_XFRM
 	xfrm6_init();
 #endif
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	fib6_rules_init();
+#endif
 }
 
 void ip6_route_cleanup(void)
 {
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	fib6_rules_cleanup();
+#endif
 #ifdef CONFIG_PROC_FS
 	proc_net_remove("ipv6_route");
 	proc_net_remove("rt6_stats");
Index: net-2.6.git/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.git.orig/net/ipv6/ip6_fib.c
+++ net-2.6.git/net/ipv6/ip6_fib.c
@@ -159,6 +159,15 @@ static struct fib6_table fib6_main_tbl =
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
+static struct fib6_table fib6_local_tbl = {
+	.tb6_id		= RT6_TABLE_LOCAL,
+	.tb6_lock	= RW_LOCK_UNLOCKED,
+	.tb6_root 	= {
+		.leaf		= &ip6_null_entry,
+		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
+	},
+};
+
 #define FIB_TABLE_HASHSZ 256
 static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
 
@@ -228,20 +237,10 @@ struct fib6_table *fib6_get_table(u32 id
 	return NULL;
 }
 
-struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
-				   pol_lookup_t lookup)
-{
-	/*
-	 * TODO: Add rule lookup
-	 */
-	struct fib6_table *table = fib6_get_table(RT6_TABLE_MAIN);
-
-	return (struct dst_entry *) lookup(table, fl, flags);
-}
-
 static void __init fib6_tables_init(void)
 {
 	fib6_link_table(&fib6_main_tbl);
+	fib6_link_table(&fib6_local_tbl);
 }
 
 #else
Index: net-2.6.git/include/net/ip6_route.h
===================================================================
--- net-2.6.git.orig/include/net/ip6_route.h
+++ net-2.6.git/include/net/ip6_route.h
@@ -41,6 +41,11 @@ struct pol_chain {
 
 extern struct rt6_info	ip6_null_entry;
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+extern struct rt6_info	ip6_prohibit_entry;
+extern struct rt6_info	ip6_blk_hole_entry;
+#endif
+
 extern int ip6_rt_gc_interval;
 
 extern void			ip6_route_input(struct sk_buff *skb);
Index: net-2.6.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.git.orig/net/ipv6/addrconf.c
+++ net-2.6.git/net/ipv6/addrconf.c
@@ -3370,6 +3370,7 @@ static struct rtnetlink_link inet6_rtnet
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
 				      .dumpit	= inet6_dump_fib, },
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit   = fib6_rules_dump,   },
 };
 
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
