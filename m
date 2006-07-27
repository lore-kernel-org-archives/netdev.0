From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules Framework
Date: Fri, 28 Jul 2006 00:39:31 +0200
Message-ID: <20060727223931.GZ14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41684 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750869AbWG0WjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 18:39:11 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060726.230230.111423566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Derived from net/ipv6/fib_rules.c

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/include/linux/fib_rules.h
===================================================================
--- /dev/null
+++ net-2.6.git/include/linux/fib_rules.h
@@ -0,0 +1,60 @@
+#ifndef __LINUX_FIB_RULES_H
+#define __LINUX_FIB_RULES_H
+
+#include <linux/types.h>
+#include <linux/rtnetlink.h>
+
+/* rule is permanent, and cannot be deleted */
+#define FIB_RULE_PERMANENT	1
+
+struct fib_rule_hdr
+{
+	__u8		family;
+	__u8		dst_len;
+	__u8		src_len;
+	__u8		tos;
+
+	__u8		table;
+	__u8		res1;	/* reserved */
+	__u8		res2;	/* reserved */
+	__u8		action;
+
+	__u32		flags;
+};
+
+enum
+{
+	FRA_UNSPEC,
+	FRA_DST,	/* destination address */
+	FRA_SRC,	/* source address */
+	FRA_IFNAME,	/* interface name */
+	FRA_UNUSED1,
+	FRA_UNUSED2,
+	FRA_PRIORITY,	/* priority/preference */
+	FRA_UNUSED3,
+	FRA_UNUSED4,
+	FRA_UNUSED5,
+	FRA_FWMARK,	/* netfilter mark (IPv4) */
+	FRA_FLOW,	/* flow/class id */
+	__FRA_MAX
+};
+
+#define FRA_MAX (__FRA_MAX - 1)
+
+enum
+{
+	FR_ACT_UNSPEC,
+	FR_ACT_TO_TBL,		/* Pass to fixed table */
+	FR_ACT_RES1,
+	FR_ACT_RES2,
+	FR_ACT_RES3,
+	FR_ACT_RES4,
+	FR_ACT_BLACKHOLE,	/* Drop without notification */
+	FR_ACT_UNREACHABLE,	/* Drop with ENETUNREACH */
+	FR_ACT_PROHIBIT,	/* Drop with EACCES */
+	__FR_ACT_MAX,
+};
+
+#define FR_ACT_MAX (__FR_ACT_MAX - 1)
+
+#endif
Index: net-2.6.git/include/net/fib_rules.h
===================================================================
--- /dev/null
+++ net-2.6.git/include/net/fib_rules.h
@@ -0,0 +1,89 @@
+#ifndef __NET_FIB_RULES_H
+#define __NET_FIB_RULES_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/fib_rules.h>
+#include <net/flow.h>
+#include <net/netlink.h>
+
+struct fib_rule
+{
+	struct list_head	list;
+	atomic_t		refcnt;
+	int			ifindex;
+	char			ifname[IFNAMSIZ];
+	u32			pref;
+	u32			flags;
+	u32			table;
+	u8			action;
+	struct rcu_head		rcu;
+};
+
+struct fib_lookup_arg
+{
+	void			*lookup_ptr;
+	void			*result;
+	struct fib_rule		*rule;
+};
+
+struct fib_rules_ops
+{
+	int			family;
+	struct list_head	list;
+	int			rule_size;
+
+	int			(*action)(struct fib_rule *,
+					  struct flowi *, int,
+					  struct fib_lookup_arg *);
+	int			(*match)(struct fib_rule *,
+					 struct flowi *, int);
+	int			(*configure)(struct fib_rule *,
+					     struct sk_buff *,
+					     struct nlmsghdr *,
+					     struct fib_rule_hdr *,
+					     struct nlattr **);
+	int			(*compare)(struct fib_rule *,
+					   struct fib_rule_hdr *,
+					   struct nlattr **);
+	int			(*fill)(struct fib_rule *, struct sk_buff *,
+					struct nlmsghdr *,
+					struct fib_rule_hdr *);
+	u32			(*default_pref)(void);
+
+	struct nla_policy	*policy;
+	struct list_head	*rules_list;
+	struct module		*owner;
+};
+
+static inline void fib_rule_get(struct fib_rule *rule)
+{
+	atomic_inc(&rule->refcnt);
+}
+
+static inline void fib_rule_put_rcu(struct rcu_head *head)
+{
+	struct fib_rule *rule = container_of(head, struct fib_rule, rcu);
+	kfree(rule);
+}
+
+static inline void fib_rule_put(struct fib_rule *rule)
+{
+	if (atomic_dec_and_test(&rule->refcnt))
+		call_rcu(&rule->rcu, fib_rule_put_rcu);
+}
+
+extern int			fib_rules_register(struct fib_rules_ops *);
+extern int			fib_rules_unregister(struct fib_rules_ops *);
+
+extern int			fib_rules_lookup(struct fib_rules_ops *,
+						 struct flowi *, int flags,
+						 struct fib_lookup_arg *);
+
+extern int			fib_nl_newrule(struct sk_buff *,
+					       struct nlmsghdr *, void *);
+extern int			fib_nl_delrule(struct sk_buff *,
+					       struct nlmsghdr *, void *);
+extern int			fib_rules_dump(struct sk_buff *,
+					       struct netlink_callback *, int);
+#endif
Index: net-2.6.git/net/Kconfig
===================================================================
--- net-2.6.git.orig/net/Kconfig
+++ net-2.6.git/net/Kconfig
@@ -249,6 +249,9 @@ source "net/ieee80211/Kconfig"
 config WIRELESS_EXT
 	bool
 
+config FIB_RULES
+	bool
+
 endif   # if NET
 endmenu # Networking
 
Index: net-2.6.git/net/core/Makefile
===================================================================
--- net-2.6.git.orig/net/core/Makefile
+++ net-2.6.git/net/core/Makefile
@@ -17,3 +17,4 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_WIRELESS_EXT) += wireless.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
+obj-$(CONFIG_FIB_RULES) += fib_rules.o
Index: net-2.6.git/net/core/fib_rules.c
===================================================================
--- /dev/null
+++ net-2.6.git/net/core/fib_rules.c
@@ -0,0 +1,417 @@
+/*
+ * net/core/fib_rules.c		Generic Routing Rules
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License as
+ *	published by the Free Software Foundation, version 2.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <net/fib_rules.h>
+
+static LIST_HEAD(rules_ops);
+static DEFINE_SPINLOCK(rules_mod_lock);
+
+static void notify_rule_change(int event, struct fib_rule *rule,
+			       struct fib_rules_ops *ops);
+
+static struct fib_rules_ops *lookup_rules_ops(int family)
+{
+	struct fib_rules_ops *ops;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ops, &rules_ops, list) {
+		if (ops->family == family) {
+			if (!try_module_get(ops->owner))
+				ops = NULL;
+			rcu_read_unlock();
+			return ops;
+		}
+	}
+	rcu_read_unlock();
+
+	return NULL;
+}
+
+static void rules_ops_put(struct fib_rules_ops *ops)
+{
+	if (ops)
+		module_put(ops->owner);
+}
+
+int fib_rules_register(struct fib_rules_ops *ops)
+{
+	int err = -EEXIST;
+	struct fib_rules_ops *o;
+
+	if (ops->rule_size < sizeof(struct fib_rule))
+		return -EINVAL;
+
+	if (ops->match == NULL || ops->configure == NULL ||
+	    ops->compare == NULL || ops->fill == NULL ||
+	    ops->action == NULL)
+		return -EINVAL;
+
+	spin_lock_bh(&rules_mod_lock);
+	list_for_each_entry(o, &rules_ops, list)
+		if (ops->family == o->family)
+			goto errout;
+
+	list_add_tail_rcu(&ops->list, &rules_ops);
+	err = 0;
+errout:
+	spin_unlock_bh(&rules_mod_lock);
+
+	return err;
+}
+
+EXPORT_SYMBOL_GPL(fib_rules_register);
+
+static void cleanup_ops(struct fib_rules_ops *ops)
+{
+	struct fib_rule *rule, *tmp;
+
+	list_for_each_entry_safe(rule, tmp, ops->rules_list, list) {
+		list_del_rcu(&rule->list);
+		fib_rule_put(rule);
+	}
+}
+
+int fib_rules_unregister(struct fib_rules_ops *ops)
+{
+	int err = 0;
+	struct fib_rules_ops *o;
+
+	spin_lock_bh(&rules_mod_lock);
+	list_for_each_entry(o, &rules_ops, list) {
+		if (o == ops) {
+			list_del_rcu(&o->list);
+			cleanup_ops(ops);
+			goto out;
+		}
+	}
+
+	err = -ENOENT;
+out:
+	spin_unlock_bh(&rules_mod_lock);
+
+	synchronize_net();
+
+	return err;
+}
+
+EXPORT_SYMBOL_GPL(fib_rules_unregister);
+
+int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
+		     int flags, struct fib_lookup_arg *arg)
+{
+	struct fib_rule *rule;
+	int err;
+
+	rcu_read_lock();
+
+	list_for_each_entry(rule, ops->rules_list, list) {
+		if (rule->ifname[0] && (rule->ifindex != fl->iif))
+			continue;
+
+		if (!ops->match(rule, fl, flags))
+			continue;
+
+		rcu_read_unlock();
+
+		err = ops->action(rule, fl, flags, arg);
+		if (err != -EAGAIN) {
+			fib_rule_get(rule);
+			arg->rule = rule;
+			goto out;
+		}
+	}
+
+	err = -ENETUNREACH;
+out:
+	rcu_read_unlock();
+
+	return err;
+}
+
+EXPORT_SYMBOL_GPL(fib_rules_lookup);
+
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+{
+	struct fib_rule_hdr *frh = nlmsg_data(nlh);
+	struct fib_rules_ops *ops = NULL;
+	struct fib_rule *rule, *r, *last = NULL;
+	struct nlattr *tb[FRA_MAX+1];
+	int err = -EINVAL;
+
+	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
+		goto errout;
+
+	ops = lookup_rules_ops(frh->family);
+	if (ops == NULL) {
+		err = EAFNOSUPPORT;
+		goto errout;
+	}
+
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
+	if (err < 0)
+		goto errout;
+
+	if (tb[FRA_IFNAME] && nla_len(tb[FRA_IFNAME]) > IFNAMSIZ)
+		goto errout;
+
+	rule = kzalloc(ops->rule_size, GFP_KERNEL);
+	if (rule == NULL) {
+		err = -ENOMEM;
+		goto errout;
+	}
+
+	if (tb[FRA_PRIORITY])
+		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
+
+	if (tb[FRA_IFNAME]) {
+		struct net_device *dev;
+
+		rule->ifindex = -1;
+		if (nla_strlcpy(rule->ifname, tb[FRA_IFNAME],
+				IFNAMSIZ) >= IFNAMSIZ)
+			goto errout_free;
+
+		dev = __dev_get_by_name(rule->ifname);
+		if (dev)
+			rule->ifindex = dev->ifindex;
+	}
+
+	rule->action = frh->action;
+	rule->flags = frh->flags;
+	rule->table = frh->table;
+
+	if (!rule->pref && ops->default_pref)
+		rule->pref = ops->default_pref();
+
+	err = ops->configure(rule, skb, nlh, frh, tb);
+	if (err < 0)
+		goto errout_free;
+
+	list_for_each_entry(r, ops->rules_list, list) {
+		if (r->pref > rule->pref)
+			break;
+		last = r;
+	}
+
+	fib_rule_get(rule);
+
+	if (last)
+		list_add_rcu(&rule->list, &last->list);
+	else
+		list_add_rcu(&rule->list, ops->rules_list);
+
+	notify_rule_change(RTM_NEWRULE, rule, ops);
+	rules_ops_put(ops);
+	return 0;
+
+errout_free:
+	kfree(rule);
+errout:
+	rules_ops_put(ops);
+	return err;
+}
+
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+{
+	struct fib_rule_hdr *frh = nlmsg_data(nlh);
+	struct fib_rules_ops *ops = NULL;
+	struct fib_rule *rule;
+	struct nlattr *tb[FRA_MAX+1];
+	int err = -EINVAL;
+
+	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
+		goto errout;
+
+	ops = lookup_rules_ops(frh->family);
+	if (ops == NULL) {
+		err = EAFNOSUPPORT;
+		goto errout;
+	}
+
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
+	if (err < 0)
+		goto errout;
+
+	list_for_each_entry(rule, ops->rules_list, list) {
+		if (frh->action && (frh->action != rule->action))
+			continue;
+
+		if (frh->table && (frh->table != rule->table))
+			continue;
+
+		if (tb[FRA_PRIORITY] &&
+		    (rule->pref != nla_get_u32(tb[FRA_PRIORITY])))
+			continue;
+
+		if (tb[FRA_IFNAME] &&
+		    nla_strcmp(tb[FRA_IFNAME], rule->ifname))
+			continue;
+
+		if (!ops->compare(rule, frh, tb))
+			continue;
+
+		if (rule->flags & FIB_RULE_PERMANENT) {
+			err = -EPERM;
+			goto errout;
+		}
+
+		list_del_rcu(&rule->list);
+		notify_rule_change(RTM_DELRULE, rule, ops);
+		fib_rule_put(rule);
+		rules_ops_put(ops);
+		return 0;
+	}
+
+	err = -ENOENT;
+errout:
+	rules_ops_put(ops);
+	return err;
+}
+
+static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
+			    u32 pid, u32 seq, int type, int flags,
+			    struct fib_rules_ops *ops)
+{
+	struct nlmsghdr *nlh;
+	struct fib_rule_hdr *frh;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*frh), flags);
+	if (nlh == NULL)
+		return -1;
+
+	frh = nlmsg_data(nlh);
+	frh->table = rule->table;
+	frh->res1 = 0;
+	frh->res2 = 0;
+	frh->action = rule->action;
+	frh->flags = rule->flags;
+
+	if (rule->ifname[0])
+		NLA_PUT_STRING(skb, FRA_IFNAME, rule->ifname);
+
+	if (rule->pref)
+		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
+
+	if (ops->fill(rule, skb, nlh, frh) < 0)
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
+}
+
+int fib_rules_dump(struct sk_buff *skb, struct netlink_callback *cb, int family)
+{
+	int idx = 0;
+	struct fib_rule *rule;
+	struct fib_rules_ops *ops;
+
+	ops = lookup_rules_ops(family);
+	if (ops == NULL)
+		return -EAFNOSUPPORT;
+
+	rcu_read_lock();
+	list_for_each_entry(rule, ops->rules_list, list) {
+		if (idx < cb->args[0])
+			goto skip;
+
+		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).pid,
+				     cb->nlh->nlmsg_seq, RTM_NEWRULE,
+				     NLM_F_MULTI, ops) < 0)
+			break;
+skip:
+		idx++;
+	}
+	rcu_read_unlock();
+	cb->args[0] = idx;
+	rules_ops_put(ops);
+
+	return skb->len;
+}
+
+EXPORT_SYMBOL_GPL(fib_rules_dump);
+
+static void notify_rule_change(int event, struct fib_rule *rule,
+			       struct fib_rules_ops *ops)
+{
+	int size = nlmsg_total_size(sizeof(struct fib_rule_hdr) + 128);
+	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
+
+	if (skb == NULL)
+		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, ENOBUFS);
+	else if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) < 0) {
+		kfree_skb(skb);
+		netlink_set_err(rtnl, 0, RTNLGRP_IPV4_RULE, EINVAL);
+	} else
+		netlink_broadcast(rtnl, skb, 0, RTNLGRP_IPV4_RULE, GFP_KERNEL);
+}
+
+static void attach_rules(struct list_head *rules, struct net_device *dev)
+{
+	struct fib_rule *rule;
+
+	list_for_each_entry(rule, rules, list) {
+		if (rule->ifindex == -1 &&
+		    strcmp(dev->name, rule->ifname) == 0)
+			rule->ifindex = dev->ifindex;
+	}
+}
+
+static void detach_rules(struct list_head *rules, struct net_device *dev)
+{
+	struct fib_rule *rule;
+
+	list_for_each_entry(rule, rules, list)
+		if (rule->ifindex == dev->ifindex)
+			rule->ifindex = -1;
+}
+
+
+static int fib_rules_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct fib_rules_ops *ops;
+
+	ASSERT_RTNL();
+	rcu_read_lock();
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		list_for_each_entry(ops, &rules_ops, list)
+			attach_rules(ops->rules_list, dev);
+		break;
+
+	case NETDEV_UNREGISTER:
+		list_for_each_entry(ops, &rules_ops, list)
+			detach_rules(ops->rules_list, dev);
+		break;
+	}
+
+	rcu_read_unlock();
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block fib_rules_notifier = {
+	.notifier_call = fib_rules_event,
+};
+
+static int __init fib_rules_init(void)
+{
+	return register_netdevice_notifier(&fib_rules_notifier);
+}
+
+subsys_initcall(fib_rules_init);
Index: net-2.6.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.git.orig/net/core/rtnetlink.c
+++ net-2.6.git/net/core/rtnetlink.c
@@ -49,6 +49,7 @@
 #include <net/udp.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
+#include <net/fib_rules.h>
 #include <net/netlink.h>
 #ifdef CONFIG_NET_WIRELESS_RTNETLINK
 #include <linux/wireless.h>
@@ -103,7 +104,7 @@ static const int rtm_min[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWADDR)]      = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
 	[RTM_FAM(RTM_NEWROUTE)]     = NLMSG_LENGTH(sizeof(struct rtmsg)),
 	[RTM_FAM(RTM_NEWNEIGH)]     = NLMSG_LENGTH(sizeof(struct ndmsg)),
-	[RTM_FAM(RTM_NEWRULE)]      = NLMSG_LENGTH(sizeof(struct rtmsg)),
+	[RTM_FAM(RTM_NEWRULE)]      = NLMSG_LENGTH(sizeof(struct fib_rule_hdr)),
 	[RTM_FAM(RTM_NEWQDISC)]     = NLMSG_LENGTH(sizeof(struct tcmsg)),
 	[RTM_FAM(RTM_NEWTCLASS)]    = NLMSG_LENGTH(sizeof(struct tcmsg)),
 	[RTM_FAM(RTM_NEWTFILTER)]   = NLMSG_LENGTH(sizeof(struct tcmsg)),
@@ -120,7 +121,7 @@ static const int rta_max[RTM_NR_FAMILIES
 	[RTM_FAM(RTM_NEWADDR)]      = IFA_MAX,
 	[RTM_FAM(RTM_NEWROUTE)]     = RTA_MAX,
 	[RTM_FAM(RTM_NEWNEIGH)]     = NDA_MAX,
-	[RTM_FAM(RTM_NEWRULE)]      = RTA_MAX,
+	[RTM_FAM(RTM_NEWRULE)]      = FRA_MAX,
 	[RTM_FAM(RTM_NEWQDISC)]     = TCA_MAX,
 	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,
 	[RTM_FAM(RTM_NEWTFILTER)]   = TCA_MAX,
@@ -744,6 +745,10 @@ static struct rtnetlink_link link_rtnetl
 	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },
 	[RTM_DELNEIGH    - RTM_BASE] = { .doit   = neigh_delete		 },
 	[RTM_GETNEIGH    - RTM_BASE] = { .dumpit = neigh_dump_info	 },
+#ifdef CONFIG_FIB_RULES
+	[RTM_NEWRULE     - RTM_BASE] = { .doit   = fib_nl_newrule	 },
+	[RTM_DELRULE     - RTM_BASE] = { .doit   = fib_nl_delrule	 },
+#endif
 	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
 	[RTM_GETNEIGHTBL - RTM_BASE] = { .dumpit = neightbl_dump_info	 },
 	[RTM_SETNEIGHTBL - RTM_BASE] = { .doit   = neightbl_set		 },
