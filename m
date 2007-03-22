From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND] [NET] rules: Unified rules dumping
Date: Thu, 22 Mar 2007 14:03:02 +0100
Message-ID: <20070322130302.GX521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53676 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749AbXCVNCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rediffed based on new rtnl registration patches.

Implements a unified, protocol independant rules dumping function
which is capable of both, dumping a specific protocol family or
all of them. This speeds up dumping as less lookups are required.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-22 13:23:10.000000000 +0100
+++ net-2.6.22/net/core/fib_rules.c	2007-03-22 13:24:07.000000000 +0100
@@ -363,19 +363,15 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-int fib_rules_dump(struct sk_buff *skb, struct netlink_callback *cb, int family)
+static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
+		      struct fib_rules_ops *ops)
 {
 	int idx = 0;
 	struct fib_rule *rule;
-	struct fib_rules_ops *ops;
-
-	ops = lookup_rules_ops(family);
-	if (ops == NULL)
-		return -EAFNOSUPPORT;
 
 	rcu_read_lock();
 	list_for_each_entry(rule, ops->rules_list, list) {
-		if (idx < cb->args[0])
+		if (idx < cb->args[1])
 			goto skip;
 
 		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).pid,
@@ -386,13 +382,44 @@ skip:
 		idx++;
 	}
 	rcu_read_unlock();
-	cb->args[0] = idx;
+	cb->args[1] = idx;
 	rules_ops_put(ops);
 
 	return skb->len;
 }
 
-EXPORT_SYMBOL_GPL(fib_rules_dump);
+static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct fib_rules_ops *ops;
+	int idx = 0, family;
+
+	family = rtnl_msg_family(cb->nlh);
+	if (family != AF_UNSPEC) {
+		/* Protocol specific dump request */
+		ops = lookup_rules_ops(family);
+		if (ops == NULL)
+			return -EAFNOSUPPORT;
+
+		return dump_rules(skb, cb, ops);
+	}
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ops, &rules_ops, list) {
+		if (idx < cb->args[0] || !try_module_get(ops->owner))
+			goto skip;
+
+		if (dump_rules(skb, cb, ops) < 0)
+			break;
+
+		cb->args[1] = 0;
+	skip:
+		idx++;
+	}
+	rcu_read_unlock();
+	cb->args[0] = idx;
+
+	return skb->len;
+}
 
 static void notify_rule_change(int event, struct fib_rule *rule,
 			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
@@ -473,7 +500,7 @@ static int __init fib_rules_init(void)
 {
 	rtnl_register(PF_UNSPEC, RTM_NEWRULE, fib_nl_newrule, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, rtnl_dump_all);
+	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule);
 
 	return register_netdevice_notifier(&fib_rules_notifier);
 }
Index: net-2.6.22/include/net/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/net/fib_rules.h	2007-03-22 13:23:10.000000000 +0100
+++ net-2.6.22/include/net/fib_rules.h	2007-03-22 13:24:07.000000000 +0100
@@ -97,7 +97,4 @@ extern int			fib_rules_unregister(struct
 extern int			fib_rules_lookup(struct fib_rules_ops *,
 						 struct flowi *, int flags,
 						 struct fib_lookup_arg *);
-
-extern int			fib_rules_dump(struct sk_buff *,
-					       struct netlink_callback *, int);
 #endif
Index: net-2.6.22/net/decnet/dn_rules.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_rules.c	2007-03-22 13:24:01.000000000 +0100
+++ net-2.6.22/net/decnet/dn_rules.c	2007-03-22 13:24:07.000000000 +0100
@@ -241,11 +241,6 @@ static u32 dn_fib_rule_default_pref(void
 	return 0;
 }
 
-static int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	return fib_rules_dump(skb, cb, AF_DECnet);
-}
-
 static struct fib_rules_ops dn_fib_rules_ops = {
 	.family		= AF_DECnet,
 	.rule_size	= sizeof(struct dn_fib_rule),
@@ -265,12 +260,10 @@ void __init dn_fib_rules_init(void)
 {
 	list_add_tail(&default_rule.common.list, &dn_fib_rules);
 	fib_rules_register(&dn_fib_rules_ops);
-	rtnl_register(PF_DECnet, RTM_GETRULE, NULL, dn_fib_dump_rules);
 }
 
 void __exit dn_fib_rules_cleanup(void)
 {
-	rtnl_unregister(PF_DECnet, RTM_GETRULE);
 	fib_rules_unregister(&dn_fib_rules_ops);
 }
 
Index: net-2.6.22/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/ipv4/fib_rules.c	2007-03-22 13:23:53.000000000 +0100
+++ net-2.6.22/net/ipv4/fib_rules.c	2007-03-22 13:24:20.000000000 +0100
@@ -277,11 +277,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static int fib4_rule_dump(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	return fib_rules_dump(skb, cb, AF_INET);
-}
-
 static u32 fib4_rule_default_pref(void)
 {
 	struct list_head *pos;
@@ -329,6 +324,4 @@ void __init fib4_rules_init(void)
 	list_add_tail(&default_rule.common.list, &fib4_rules);
 
 	fib_rules_register(&fib4_rules_ops);
-
-	rtnl_register(PF_INET, RTM_GETRULE, NULL, fib4_rule_dump);
 }
Index: net-2.6.22/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.22.orig/net/ipv6/fib6_rules.c	2007-03-22 13:24:02.000000000 +0100
+++ net-2.6.22/net/ipv6/fib6_rules.c	2007-03-22 13:24:07.000000000 +0100
@@ -221,11 +221,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static int fib6_rules_dump(struct sk_buff *skb, struct netlink_callback *cb)
-{
-	return fib_rules_dump(skb, cb, AF_INET6);
-}
-
 static u32 fib6_rule_default_pref(void)
 {
 	return 0x3FFF;
@@ -259,11 +254,9 @@ void __init fib6_rules_init(void)
 	list_add_tail(&main_rule.common.list, &fib6_rules);
 
 	fib_rules_register(&fib6_rules_ops);
-	__rtnl_register(PF_INET6, RTM_GETRULE, NULL, fib6_rules_dump);
 }
 
 void fib6_rules_cleanup(void)
 {
-	rtnl_unregister(PF_INET6, RTM_GETRULE);
 	fib_rules_unregister(&fib6_rules_ops);
 }
Index: net-2.6.22/include/net/rtnetlink.h
===================================================================
--- net-2.6.22.orig/include/net/rtnetlink.h	2007-03-22 13:23:10.000000000 +0100
+++ net-2.6.22/include/net/rtnetlink.h	2007-03-22 13:24:07.000000000 +0100
@@ -15,4 +15,12 @@ extern int	rtnl_unregister(int protocol,
 extern void	rtnl_unregister_all(int protocol);
 extern int	rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb);
 
+static inline int rtnl_msg_family(struct nlmsghdr *nlh)
+{
+	if (nlmsg_len(nlh) >= sizeof(struct rtgenmsg))
+		return ((struct rtgenmsg *) nlmsg_data(nlh))->rtgen_family;
+	else
+		return AF_UNSPEC;
+}
+
 #endif
