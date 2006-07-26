From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] [IPV4]: Use Protocol Independant Policy Routing Rules Framework
Date: Thu, 27 Jul 2006 00:00:05 +0200
Message-ID: <20060726221850.460778279@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch>
Cc: vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:26294 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751801AbWGZWUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 18:20:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip4_fib_rules
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/include/net/ip_fib.h
===================================================================
--- net-2.6.git.orig/include/net/ip_fib.h
+++ net-2.6.git/include/net/ip_fib.h
@@ -18,6 +18,7 @@
 
 #include <net/flow.h>
 #include <linux/seq_file.h>
+#include <net/fib_rules.h>
 
 /* WARNING: The ordering of these elements must match ordering
  *          of RTA_* rtnetlink attribute numbers.
@@ -203,9 +204,8 @@ static inline void fib_select_default(co
 #define ip_fib_main_table (fib_tables[RT_TABLE_MAIN])
 
 extern struct fib_table * fib_tables[RT_TABLE_MAX+1];
-extern int fib_lookup(const struct flowi *flp, struct fib_result *res);
+extern int fib_lookup(struct flowi *flp, struct fib_result *res);
 extern struct fib_table *__fib_new_table(int id);
-extern void fib_rule_put(struct fib_rule *r);
 
 static inline struct fib_table *fib_get_table(int id)
 {
@@ -251,15 +251,15 @@ extern u32  __fib_res_prefsrc(struct fib
 extern struct fib_table *fib_hash_init(int id);
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-/* Exported by fib_rules.c */
+extern int fib4_rules_dump(struct sk_buff *skb, struct netlink_callback *cb);
+
+extern void __init fib4_rules_init(void);
+extern void __exit fib4_rules_cleanup(void);
 
-extern int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet_rtm_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
-extern int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb);
 #ifdef CONFIG_NET_CLS_ROUTE
 extern u32 fib_rules_tclass(struct fib_result *res);
 #endif
-extern void fib_rules_init(void);
+
 #endif
 
 static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
Index: net-2.6.git/net/ipv4/Kconfig
===================================================================
--- net-2.6.git.orig/net/ipv4/Kconfig
+++ net-2.6.git/net/ipv4/Kconfig
@@ -88,6 +88,7 @@ config IP_FIB_HASH
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
 	depends on IP_ADVANCED_ROUTER
+	select FIB_RULES
 	---help---
 	  Normally, a router decides what to do with a received packet based
 	  solely on the packet's final destination address. If you say Y here,
Index: net-2.6.git/net/ipv4/devinet.c
===================================================================
--- net-2.6.git.orig/net/ipv4/devinet.c
+++ net-2.6.git/net/ipv4/devinet.c
@@ -1153,9 +1153,7 @@ static struct rtnetlink_link inet_rtnetl
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet_rtm_getroute,
 				      .dumpit	= inet_dump_fib,	},
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	[RTM_NEWRULE  - RTM_BASE] = { .doit	= inet_rtm_newrule,	},
-	[RTM_DELRULE  - RTM_BASE] = { .doit	= inet_rtm_delrule,	},
-	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= inet_dump_rules,	},
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= fib4_rules_dump,	},
 #endif
 };
 
Index: net-2.6.git/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.git.orig/net/ipv4/fib_rules.c
+++ net-2.6.git/net/ipv4/fib_rules.c
@@ -5,9 +5,8 @@
  *
  *		IPv4 Forwarding Information Base: policy rules.
  *
- * Version:	$Id: fib_rules.c,v 1.17 2001/10/31 21:55:54 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ * 		Thomas Graf <tgraf@suug.ch>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -19,129 +18,154 @@
  *		Marc Boucher	:	routing by fwmark
  */
 
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/string.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/errno.h>
-#include <linux/in.h>
-#include <linux/inet.h>
-#include <linux/inetdevice.h>
 #include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/proc_fs.h>
-#include <linux/skbuff.h>
 #include <linux/netlink.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/rcupdate.h>
-
 #include <net/ip.h>
-#include <net/protocol.h>
 #include <net/route.h>
 #include <net/tcp.h>
-#include <net/sock.h>
 #include <net/ip_fib.h>
+#include <net/fib_rules.h>
 
-#define FRprintk(a...)
+static struct fib_rules_ops fib4_rules_ops;
 
-struct fib_rule
+struct fib4_rule
 {
-	struct hlist_node hlist;
-	atomic_t	r_clntref;
-	u32		r_preference;
-	unsigned char	r_table;
-	unsigned char	r_action;
-	unsigned char	r_dst_len;
-	unsigned char	r_src_len;
-	u32		r_src;
-	u32		r_srcmask;
-	u32		r_dst;
-	u32		r_dstmask;
-	u32		r_srcmap;
-	u8		r_flags;
-	u8		r_tos;
+	struct fib_rule		common;
+	u8			dst_len;
+	u8			src_len;
+	u8			tos;
+	u32			src;
+	u32			srcmask;
+	u32			dst;
+	u32			dstmask;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	u32		r_fwmark;
+	u32			fwmark;
 #endif
-	int		r_ifindex;
 #ifdef CONFIG_NET_CLS_ROUTE
-	__u32		r_tclassid;
+	u32			tclassid;
 #endif
-	char		r_ifname[IFNAMSIZ];
-	int		r_dead;
-	struct		rcu_head rcu;
 };
 
-static struct fib_rule default_rule = {
-	.r_clntref =	ATOMIC_INIT(2),
-	.r_preference =	0x7FFF,
-	.r_table =	RT_TABLE_DEFAULT,
-	.r_action =	RTN_UNICAST,
+static struct fib4_rule default_rule = {
+	.common = {
+		.refcnt =	ATOMIC_INIT(2),
+		.pref =		0x7FFF,
+		.table =	RT_TABLE_DEFAULT,
+		.action =	FR_ACT_TO_TBL,
+	},
 };
 
-static struct fib_rule main_rule = {
-	.r_clntref =	ATOMIC_INIT(2),
-	.r_preference =	0x7FFE,
-	.r_table =	RT_TABLE_MAIN,
-	.r_action =	RTN_UNICAST,
+static struct fib4_rule main_rule = {
+	.common = {
+		.refcnt =	ATOMIC_INIT(2),
+		.pref =		0x7FFE,
+		.table =	RT_TABLE_MAIN,
+		.action =	FR_ACT_TO_TBL,
+	},
 };
 
-static struct fib_rule local_rule = {
-	.r_clntref =	ATOMIC_INIT(2),
-	.r_table =	RT_TABLE_LOCAL,
-	.r_action =	RTN_UNICAST,
+static struct fib4_rule local_rule = {
+	.common = {
+		.refcnt =	ATOMIC_INIT(2),
+		.table =	RT_TABLE_LOCAL,
+		.action =	FR_ACT_TO_TBL,
+		.flags =	FIB_RULE_PERMANENT,
+	},
 };
 
-static struct hlist_head fib_rules;
+static LIST_HEAD(fib4_rules);
+
+#ifdef CONFIG_NET_CLS_ROUTE
+u32 fib_rules_tclass(struct fib_result *res)
+{
+	return res->r ? ((struct fib4_rule *) res->r)->tclassid : 0;
+}
+#endif
 
-/* writer func called from netlink -- rtnl_sem hold*/
+int fib_lookup(struct flowi *flp, struct fib_result *res)
+{
+	struct fib_lookup_arg arg = {
+		.result = res,
+	};
+	int err;
 
-static void rtmsg_rule(int, struct fib_rule *);
+	err = fib_rules_lookup(&fib4_rules_ops, flp, 0, &arg);
+	res->r = arg.rule;
 
-int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+	return err;
+}
+
+int fib4_rule_action(struct fib_rule *rule, struct flowi *flp, int flags,
+		     struct fib_lookup_arg *arg)
 {
-	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct fib_rule *r;
-	struct hlist_node *node;
-	int err = -ESRCH;
-
-	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-		if ((!rta[RTA_SRC-1] || memcmp(RTA_DATA(rta[RTA_SRC-1]), &r->r_src, 4) == 0) &&
-		    rtm->rtm_src_len == r->r_src_len &&
-		    rtm->rtm_dst_len == r->r_dst_len &&
-		    (!rta[RTA_DST-1] || memcmp(RTA_DATA(rta[RTA_DST-1]), &r->r_dst, 4) == 0) &&
-		    rtm->rtm_tos == r->r_tos &&
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		    (!rta[RTA_PROTOINFO-1] || memcmp(RTA_DATA(rta[RTA_PROTOINFO-1]), &r->r_fwmark, 4) == 0) &&
-#endif
-		    (!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
-		    (!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
-		    (!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
-		    (!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
-			err = -EPERM;
-			if (r == &local_rule)
-				break;
-
-			hlist_del_rcu(&r->hlist);
-			r->r_dead = 1;
-			rtmsg_rule(RTM_DELRULE, r);
-			fib_rule_put(r);
-			err = 0;
-			break;
-		}
+	int err = -EAGAIN;
+	struct fib_table *tbl;
+
+	switch (rule->action) {
+	case FR_ACT_TO_TBL:
+		break;
+
+	case FR_ACT_UNREACHABLE:
+		err = -ENETUNREACH;
+		goto errout;
+
+	case FR_ACT_PROHIBIT:
+		err = -EACCES;
+		goto errout;
+
+	case FR_ACT_BLACKHOLE:
+	default:
+		err = -EINVAL;
+		goto errout;
 	}
+
+	if ((tbl = fib_get_table(rule->table)) == NULL)
+		goto errout;
+
+	err = tbl->tb_lookup(tbl, flp, (struct fib_result *) arg->result);
+	if (err > 0)
+		err = -EAGAIN;
+errout:
 	return err;
 }
 
-/* Allocate new unique table id */
+
+void fib_select_default(const struct flowi *flp, struct fib_result *res)
+{
+	if (res->r && res->r->action == FR_ACT_TO_TBL &&
+	    FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK) {
+		struct fib_table *tb;
+		if ((tb = fib_get_table(res->r->table)) != NULL)
+			tb->tb_select_default(tb, flp, res);
+	}
+}
+
+static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
+{
+	struct fib4_rule *r = (struct fib4_rule *) rule;
+	u32 daddr = fl->fl4_dst;
+	u32 saddr = fl->fl4_src;
+
+	if (((saddr ^ r->src) & r->srcmask) ||
+	    ((daddr ^ r->dst) & r->dstmask))
+		return 0;
+
+	if (r->tos && (r->tos != fl->fl4_tos))
+		return 0;
+
+#ifdef CONFIG_IP_ROUTE_FWMARK
+	if (r->fwmark && (r->fwmark != fl->fl4_fwmark))
+		return 0;
+#endif
+
+	return 1;
+}
 
 static struct fib_table *fib_empty_table(void)
 {
@@ -153,330 +177,177 @@ static struct fib_table *fib_empty_table
 	return NULL;
 }
 
-static inline void fib_rule_put_rcu(struct rcu_head *head)
-{
-	struct fib_rule *r = container_of(head, struct fib_rule, rcu);
-	kfree(r);
-}
-
-void fib_rule_put(struct fib_rule *r)
-{
-	if (atomic_dec_and_test(&r->r_clntref)) {
-		if (r->r_dead)
-			call_rcu(&r->rcu, fib_rule_put_rcu);
-		else
-			printk("Freeing alive rule %p\n", r);
-	}
-}
+static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
+	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	[FRA_SRC]	= { .type = NLA_U32 },
+	[FRA_DST]	= { .type = NLA_U32 },
+	[FRA_FWMARK]	= { .type = NLA_U32 },
+	[FRA_FLOW]	= { .type = NLA_U32 },
+};
 
-/* writer func called from netlink -- rtnl_sem hold*/
+static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
+			       struct nlmsghdr *nlh, struct fib_rule_hdr *frh,
+			       struct nlattr **tb)
+{
+	int err = -EINVAL;
+	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
+
+	if (frh->src_len > 32 || frh->dst_len > 32 ||
+	    (frh->tos & ~IPTOS_TOS_MASK))
+		goto errout;
+
+	if (rule->table == RT_TABLE_UNSPEC) {
+		if (rule->action == FR_ACT_TO_TBL) {
+			struct fib_table *table;
+
+			table = fib_empty_table();
+			if (table == NULL) {
+				err = -ENOBUFS;
+				goto errout;
+			}
 
-int inet_rtm_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
-{
-	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct fib_rule *r, *new_r, *last = NULL;
-	struct hlist_node *node = NULL;
-	unsigned char table_id;
-
-	if (rtm->rtm_src_len > 32 || rtm->rtm_dst_len > 32 ||
-	    (rtm->rtm_tos & ~IPTOS_TOS_MASK))
-		return -EINVAL;
-
-	if (rta[RTA_IIF-1] && RTA_PAYLOAD(rta[RTA_IIF-1]) > IFNAMSIZ)
-		return -EINVAL;
-
-	table_id = rtm->rtm_table;
-	if (table_id == RT_TABLE_UNSPEC) {
-		struct fib_table *table;
-		if (rtm->rtm_type == RTN_UNICAST) {
-			if ((table = fib_empty_table()) == NULL)
-				return -ENOBUFS;
-			table_id = table->tb_id;
+			rule->table = table->tb_id;
 		}
 	}
 
-	new_r = kmalloc(sizeof(*new_r), GFP_KERNEL);
-	if (!new_r)
-		return -ENOMEM;
-	memset(new_r, 0, sizeof(*new_r));
-
-	if (rta[RTA_SRC-1])
-		memcpy(&new_r->r_src, RTA_DATA(rta[RTA_SRC-1]), 4);
-	if (rta[RTA_DST-1])
-		memcpy(&new_r->r_dst, RTA_DATA(rta[RTA_DST-1]), 4);
-	if (rta[RTA_GATEWAY-1])
-		memcpy(&new_r->r_srcmap, RTA_DATA(rta[RTA_GATEWAY-1]), 4);
-	new_r->r_src_len = rtm->rtm_src_len;
-	new_r->r_dst_len = rtm->rtm_dst_len;
-	new_r->r_srcmask = inet_make_mask(rtm->rtm_src_len);
-	new_r->r_dstmask = inet_make_mask(rtm->rtm_dst_len);
-	new_r->r_tos = rtm->rtm_tos;
+	if (tb[FRA_SRC])
+		rule4->src = nla_get_u32(tb[FRA_SRC]);
+
+	if (tb[FRA_DST])
+		rule4->dst = nla_get_u32(tb[FRA_DST]);
+
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	if (rta[RTA_PROTOINFO-1])
-		memcpy(&new_r->r_fwmark, RTA_DATA(rta[RTA_PROTOINFO-1]), 4);
+	if (tb[FRA_FWMARK])
+		rule4->fwmark = nla_get_u32(tb[FRA_FWMARK]);
 #endif
-	new_r->r_action = rtm->rtm_type;
-	new_r->r_flags = rtm->rtm_flags;
-	if (rta[RTA_PRIORITY-1])
-		memcpy(&new_r->r_preference, RTA_DATA(rta[RTA_PRIORITY-1]), 4);
-	new_r->r_table = table_id;
-	if (rta[RTA_IIF-1]) {
-		struct net_device *dev;
-		rtattr_strlcpy(new_r->r_ifname, rta[RTA_IIF-1], IFNAMSIZ);
-		new_r->r_ifindex = -1;
-		dev = __dev_get_by_name(new_r->r_ifname);
-		if (dev)
-			new_r->r_ifindex = dev->ifindex;
-	}
+
 #ifdef CONFIG_NET_CLS_ROUTE
-	if (rta[RTA_FLOW-1])
-		memcpy(&new_r->r_tclassid, RTA_DATA(rta[RTA_FLOW-1]), 4);
+	if (tb[FRA_FLOW])
+		rule4->tclassid = nla_get_u32(tb[FRA_FLOW]);
 #endif
-	r = container_of(fib_rules.first, struct fib_rule, hlist);
-
-	if (!new_r->r_preference) {
-		if (r && r->hlist.next != NULL) {
-			r = container_of(r->hlist.next, struct fib_rule, hlist);
-			if (r->r_preference)
-				new_r->r_preference = r->r_preference - 1;
-		}
-	}
-
-	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-		if (r->r_preference > new_r->r_preference)
-			break;
-		last = r;
-	}
-	atomic_inc(&new_r->r_clntref);
 
-	if (last)
-		hlist_add_after_rcu(&last->hlist, &new_r->hlist);
-	else
-		hlist_add_before_rcu(&new_r->hlist, &r->hlist);
+	rule4->src_len = frh->src_len;
+	rule4->srcmask = inet_make_mask(rule4->src_len);
+	rule4->dst_len = frh->dst_len;
+	rule4->dstmask = inet_make_mask(rule4->dst_len);
+	rule4->tos = frh->tos;
 
-	rtmsg_rule(RTM_NEWRULE, new_r);
-	return 0;
+	err = 0;
+errout:
+	return err;
 }
 
-#ifdef CONFIG_NET_CLS_ROUTE
-u32 fib_rules_tclass(struct fib_result *res)
+static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
+			     struct nlattr **tb)
 {
-	if (res->r)
-		return res->r->r_tclassid;
-	return 0;
-}
-#endif
+	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
-/* callers should hold rtnl semaphore */
+	if (frh->src_len && (rule4->src_len != frh->src_len))
+		return 0;
 
-static void fib_rules_detach(struct net_device *dev)
-{
-	struct hlist_node *node;
-	struct fib_rule *r;
+	if (frh->dst_len && (rule4->dst_len != frh->dst_len))
+		return 0;
 
-	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-		if (r->r_ifindex == dev->ifindex)
-			r->r_ifindex = -1;
+	if (frh->tos && (rule4->tos != frh->tos))
+		return 0;
 
-	}
-}
-
-/* callers should hold rtnl semaphore */
-
-static void fib_rules_attach(struct net_device *dev)
-{
-	struct hlist_node *node;
-	struct fib_rule *r;
-
-	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-		if (r->r_ifindex == -1 && strcmp(dev->name, r->r_ifname) == 0)
-			r->r_ifindex = dev->ifindex;
-	}
-}
-
-int fib_lookup(const struct flowi *flp, struct fib_result *res)
-{
-	int err;
-	struct fib_rule *r, *policy;
-	struct fib_table *tb;
-	struct hlist_node *node;
-
-	u32 daddr = flp->fl4_dst;
-	u32 saddr = flp->fl4_src;
-
-FRprintk("Lookup: %u.%u.%u.%u <- %u.%u.%u.%u ",
-	NIPQUAD(flp->fl4_dst), NIPQUAD(flp->fl4_src));
-
-	rcu_read_lock();
-
-	hlist_for_each_entry_rcu(r, node, &fib_rules, hlist) {
-		if (((saddr^r->r_src) & r->r_srcmask) ||
-		    ((daddr^r->r_dst) & r->r_dstmask) ||
-		    (r->r_tos && r->r_tos != flp->fl4_tos) ||
 #ifdef CONFIG_IP_ROUTE_FWMARK
-		    (r->r_fwmark && r->r_fwmark != flp->fl4_fwmark) ||
+	if (tb[FRA_FWMARK] && (rule4->fwmark != nla_get_u32(tb[FRA_FWMARK])))
+		return 0;
 #endif
-		    (r->r_ifindex && r->r_ifindex != flp->iif))
-			continue;
-
-FRprintk("tb %d r %d ", r->r_table, r->r_action);
-		switch (r->r_action) {
-		case RTN_UNICAST:
-			policy = r;
-			break;
-		case RTN_UNREACHABLE:
-			rcu_read_unlock();
-			return -ENETUNREACH;
-		default:
-		case RTN_BLACKHOLE:
-			rcu_read_unlock();
-			return -EINVAL;
-		case RTN_PROHIBIT:
-			rcu_read_unlock();
-			return -EACCES;
-		}
 
-		if ((tb = fib_get_table(r->r_table)) == NULL)
-			continue;
-		err = tb->tb_lookup(tb, flp, res);
-		if (err == 0) {
-			res->r = policy;
-			if (policy)
-				atomic_inc(&policy->r_clntref);
-			rcu_read_unlock();
-			return 0;
-		}
-		if (err < 0 && err != -EAGAIN) {
-			rcu_read_unlock();
-			return err;
-		}
-	}
-FRprintk("FAILURE\n");
-	rcu_read_unlock();
-	return -ENETUNREACH;
-}
+#ifdef CONFIG_NET_CLS_ROUTE
+	if (tb[FRA_FLOW] && (rule4->tclassid != nla_get_u32(tb[FRA_FLOW])))
+		return 0;
+#endif
 
-void fib_select_default(const struct flowi *flp, struct fib_result *res)
-{
-	if (res->r && res->r->r_action == RTN_UNICAST &&
-	    FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK) {
-		struct fib_table *tb;
-		if ((tb = fib_get_table(res->r->r_table)) != NULL)
-			tb->tb_select_default(tb, flp, res);
-	}
-}
+	if (tb[FRA_SRC] && (rule4->src != nla_get_u32(tb[FRA_SRC])))
+		return 0;
 
-static int fib_rules_event(struct notifier_block *this, unsigned long event, void *ptr)
-{
-	struct net_device *dev = ptr;
+	if (tb[FRA_DST] && (rule4->dst != nla_get_u32(tb[FRA_DST])))
+		return 0;
 
-	if (event == NETDEV_UNREGISTER)
-		fib_rules_detach(dev);
-	else if (event == NETDEV_REGISTER)
-		fib_rules_attach(dev);
-	return NOTIFY_DONE;
+	return 1;
 }
 
+static int fib4_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
+			  struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
+{
+	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
-static struct notifier_block fib_rules_notifier = {
-	.notifier_call =fib_rules_event,
-};
+	frh->family = AF_INET;
+	frh->dst_len = rule4->dst_len;
+	frh->src_len = rule4->src_len;
+	frh->tos = rule4->tos;
 
-static __inline__ int inet_fill_rule(struct sk_buff *skb,
-				     struct fib_rule *r,
-				     u32 pid, u32 seq, int event,
-				     unsigned int flags)
-{
-	struct rtmsg *rtm;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
-
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*rtm), flags);
-	rtm = NLMSG_DATA(nlh);
-	rtm->rtm_family = AF_INET;
-	rtm->rtm_dst_len = r->r_dst_len;
-	rtm->rtm_src_len = r->r_src_len;
-	rtm->rtm_tos = r->r_tos;
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	if (r->r_fwmark)
-		RTA_PUT(skb, RTA_PROTOINFO, 4, &r->r_fwmark);
+	if (rule4->fwmark)
+		NLA_PUT_U32(skb, FRA_FWMARK, rule4->fwmark);
 #endif
-	rtm->rtm_table = r->r_table;
-	rtm->rtm_protocol = 0;
-	rtm->rtm_scope = 0;
-	rtm->rtm_type = r->r_action;
-	rtm->rtm_flags = r->r_flags;
-
-	if (r->r_dst_len)
-		RTA_PUT(skb, RTA_DST, 4, &r->r_dst);
-	if (r->r_src_len)
-		RTA_PUT(skb, RTA_SRC, 4, &r->r_src);
-	if (r->r_ifname[0])
-		RTA_PUT(skb, RTA_IIF, IFNAMSIZ, &r->r_ifname);
-	if (r->r_preference)
-		RTA_PUT(skb, RTA_PRIORITY, 4, &r->r_preference);
-	if (r->r_srcmap)
-		RTA_PUT(skb, RTA_GATEWAY, 4, &r->r_srcmap);
+
+	if (rule4->dst_len)
+		NLA_PUT_U32(skb, FRA_DST, rule4->dst);
+
+	if (rule4->src_len)
+		NLA_PUT_U32(skb, FRA_SRC, rule4->src);
+
 #ifdef CONFIG_NET_CLS_ROUTE
-	if (r->r_tclassid)
-		RTA_PUT(skb, RTA_FLOW, 4, &r->r_tclassid);
+	if (rule4->tclassid)
+		NLA_PUT_U32(skb, FRA_FLOW, rule4->tclassid);
 #endif
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
+	return 0;
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+nla_put_failure:
+	return -ENOBUFS;
 }
 
-/* callers should hold rtnl semaphore */
+int fib4_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return fib_rules_dump(skb, cb, AF_INET);
+}
 
-static void rtmsg_rule(int event, struct fib_rule *r)
+static u32 fib4_rule_default_pref(void)
 {
-	int size = NLMSG_SPACE(sizeof(struct rtmsg) + 128);
-	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
+	struct list_head *pos;
+	struct fib_rule *rule;
 
-	if (!skb)
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, ENOBUFS);
-	else if (inet_fill_rule(skb, r, 0, 0, event, 0) < 0) {
-		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, EINVAL);
-	} else {
-		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_RULE, GFP_KERNEL);
+	if (!list_empty(&fib4_rules)) {
+		pos = fib4_rules.next;
+		if (pos->next != &fib4_rules) {
+			rule = list_entry(pos->next, struct fib_rule, list);
+			if (rule->pref)
+				return rule->pref - 1;
+		}
 	}
+
+	return 0;
 }
 
-int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
+static struct fib_rules_ops fib4_rules_ops = {
+	.family		= AF_INET,
+	.rule_size	= sizeof(struct fib4_rule),
+	.action		= fib4_rule_action,
+	.match		= fib4_rule_match,
+	.configure	= fib4_rule_configure,
+	.compare	= fib4_rule_compare,
+	.fill		= fib4_rule_fill,
+	.default_pref	= fib4_rule_default_pref,
+	.policy		= fib4_rule_policy,
+	.rules_list	= &fib4_rules,
+	.owner		= THIS_MODULE,
+};
+
+void __init fib4_rules_init(void)
 {
-	int idx = 0;
-	int s_idx = cb->args[0];
-	struct fib_rule *r;
-	struct hlist_node *node;
-
-	rcu_read_lock();
-	hlist_for_each_entry(r, node, &fib_rules, hlist) {
-		if (idx < s_idx)
-			goto next;
-		if (inet_fill_rule(skb, r, NETLINK_CB(cb->skb).pid,
-				   cb->nlh->nlmsg_seq,
-				   RTM_NEWRULE, NLM_F_MULTI) < 0)
-			break;
-next:
-		idx++;
-	}
-	rcu_read_unlock();
-	cb->args[0] = idx;
+	list_add_tail(&local_rule.common.list, &fib4_rules);
+	list_add_tail(&main_rule.common.list, &fib4_rules);
+	list_add_tail(&default_rule.common.list, &fib4_rules);
 
-	return skb->len;
+	fib_rules_register(&fib4_rules_ops);
 }
 
-void __init fib_rules_init(void)
+void __exit fib4_rules_cleanup(void)
 {
-	INIT_HLIST_HEAD(&fib_rules);
-	hlist_add_head(&local_rule.hlist, &fib_rules);
-	hlist_add_after(&local_rule.hlist, &main_rule.hlist);
-	hlist_add_after(&main_rule.hlist, &default_rule.hlist);
-	register_netdevice_notifier(&fib_rules_notifier);
+	fib_rules_unregister(&fib4_rules_ops);
 }
Index: net-2.6.git/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.git.orig/net/ipv4/fib_frontend.c
+++ net-2.6.git/net/ipv4/fib_frontend.c
@@ -656,7 +656,7 @@ void __init ip_fib_init(void)
 	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
 	ip_fib_main_table  = fib_hash_init(RT_TABLE_MAIN);
 #else
-	fib_rules_init();
+	fib4_rules_init();
 #endif
 
 	register_netdevice_notifier(&fib_netdev_notifier);

