From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Tue, 27 Mar 2007 15:38:45 +0200
Message-ID: <20070327133845.GM521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, muli@il.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56036 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbXC0NiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:38:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The results of FIB rules lookups are cached in the routing cache
except for IPv6 as no such cache exists. So far, it was the
responsibility of the user to flush the cache after modifying any
rules. This lead to many false bug reports due to misunderstanding
of this concept.

This patch automatically flushes the route cache after inserting
or deleting a rule.

Thanks to Muli Ben-Yehuda <muli@il.ibm.com> for catching a bug
in the previous patch.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/net/fib_rules.h	2007-03-27 13:54:52.000000000 +0200
+++ net-2.6.22/include/net/fib_rules.h	2007-03-27 14:16:24.000000000 +0200
@@ -59,6 +59,10 @@ struct fib_rules_ops
 	u32			(*default_pref)(void);
 	size_t			(*nlmsg_payload)(struct fib_rule *);
 
+	/* Called after modifications to the rules set, must flush
+	 * the route cache if one exists. */
+	void			(*flush_cache)(void);
+
 	int			nlgroup;
 	struct nla_policy	*policy;
 	struct list_head	*rules_list;
Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-27 13:53:29.000000000 +0200
+++ net-2.6.22/net/core/fib_rules.c	2007-03-27 15:36:05.000000000 +0200
@@ -44,6 +44,12 @@ static void rules_ops_put(struct fib_rul
 		module_put(ops->owner);
 }
 
+static void flush_route_cache(struct fib_rules_ops *ops)
+{
+	if (ops->flush_cache)
+		ops->flush_cache();
+}
+
 int fib_rules_register(struct fib_rules_ops *ops)
 {
 	int err = -EEXIST;
@@ -314,6 +320,7 @@ static int fib_nl_newrule(struct sk_buff
 		list_add_rcu(&rule->list, ops->rules_list);
 
 	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).pid);
+	flush_route_cache(ops);
 	rules_ops_put(ops);
 	return 0;
 
@@ -404,6 +411,7 @@ static int fib_nl_delrule(struct sk_buff
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).pid);
 		fib_rule_put(rule);
+		flush_route_cache(ops);
 		rules_ops_put(ops);
 		return 0;
 	}
Index: net-2.6.22/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/ipv4/fib_rules.c	2007-03-27 13:54:57.000000000 +0200
+++ net-2.6.22/net/ipv4/fib_rules.c	2007-03-27 15:35:43.000000000 +0200
@@ -298,6 +298,11 @@ static size_t fib4_rule_nlmsg_payload(st
 	       + nla_total_size(4); /* flow */
 }
 
+static void fib4_rule_flush_cache(void)
+{
+	rt_cache_flush(0);
+}
+
 static struct fib_rules_ops fib4_rules_ops = {
 	.family		= AF_INET,
 	.rule_size	= sizeof(struct fib4_rule),
@@ -309,6 +314,7 @@ static struct fib_rules_ops fib4_rules_o
 	.fill		= fib4_rule_fill,
 	.default_pref	= fib4_rule_default_pref,
 	.nlmsg_payload	= fib4_rule_nlmsg_payload,
+	.flush_cache	= fib4_rule_flush_cache,
 	.nlgroup	= RTNLGRP_IPV4_RULE,
 	.policy		= fib4_rule_policy,
 	.rules_list	= &fib4_rules,
Index: net-2.6.22/net/decnet/dn_rules.c
===================================================================
--- net-2.6.22.orig/net/decnet/dn_rules.c	2007-03-27 14:00:56.000000000 +0200
+++ net-2.6.22/net/decnet/dn_rules.c	2007-03-27 15:35:43.000000000 +0200
@@ -31,6 +31,7 @@
 #include <net/dn_fib.h>
 #include <net/dn_neigh.h>
 #include <net/dn_dev.h>
+#include <net/dn_route.h>
 
 static struct fib_rules_ops dn_fib_rules_ops;
 
@@ -239,6 +240,11 @@ static u32 dn_fib_rule_default_pref(void
 	return 0;
 }
 
+static void dn_fib_rule_flush_cache(void)
+{
+	dn_rt_cache_flush(0);
+}
+
 static struct fib_rules_ops dn_fib_rules_ops = {
 	.family		= AF_DECnet,
 	.rule_size	= sizeof(struct dn_fib_rule),
@@ -249,6 +255,7 @@ static struct fib_rules_ops dn_fib_rules
 	.compare	= dn_fib_rule_compare,
 	.fill		= dn_fib_rule_fill,
 	.default_pref	= dn_fib_rule_default_pref,
+	.flush_cache	= dn_fib_rule_flush_cache,
 	.nlgroup	= RTNLGRP_DECnet_RULE,
 	.policy		= dn_fib_rule_policy,
 	.rules_list	= &dn_fib_rules,
