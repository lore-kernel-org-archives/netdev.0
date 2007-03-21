From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 04/12] [NET] rules: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:05:57 +0100
Message-ID: <20070321000709.729911383@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44417 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752119AbXCUAmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:11 -0400
Content-Disposition: inline; filename=rtnl_reg_rules_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-20 23:53:21.000000000 +0100
+++ net-2.6.22/net/core/fib_rules.c	2007-03-21 00:52:30.000000000 +0100
@@ -152,7 +152,7 @@ out:
 
 EXPORT_SYMBOL_GPL(fib_rules_lookup);
 
-int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int nl_rule_new(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
@@ -239,7 +239,7 @@ errout:
 	return err;
 }
 
-int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int nl_rule_del(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
@@ -471,6 +471,10 @@ static struct notifier_block fib_rules_n
 
 static int __init fib_rules_init(void)
 {
+	rtnl_register(PF_UNSPEC, RTM_NEWRULE, nl_rule_new, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELRULE, nl_rule_del, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, rtnl_dump_all);
+
 	return register_netdevice_notifier(&fib_rules_notifier);
 }
 
Index: net-2.6.22/include/net/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/net/fib_rules.h	2007-03-20 23:53:21.000000000 +0100
+++ net-2.6.22/include/net/fib_rules.h	2007-03-21 00:52:30.000000000 +0100
@@ -5,7 +5,7 @@
 #include <linux/netdevice.h>
 #include <linux/fib_rules.h>
 #include <net/flow.h>
-#include <net/netlink.h>
+#include <net/rtnetlink.h>
 
 struct fib_rule
 {
@@ -98,10 +98,6 @@ extern int			fib_rules_lookup(struct fib
 						 struct flowi *, int flags,
 						 struct fib_lookup_arg *);
 
-extern int			fib_nl_newrule(struct sk_buff *,
-					       struct nlmsghdr *, void *);
-extern int			fib_nl_delrule(struct sk_buff *,
-					       struct nlmsghdr *, void *);
 extern int			fib_rules_dump(struct sk_buff *,
 					       struct netlink_callback *, int);
 #endif
Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 00:52:29.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 00:52:30.000000000 +0100
@@ -962,11 +962,6 @@ static struct rtnetlink_link link_rtnetl
 {
 	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
-#ifdef CONFIG_FIB_RULES
-	[RTM_NEWRULE     - RTM_BASE] = { .doit   = fib_nl_newrule	 },
-	[RTM_DELRULE     - RTM_BASE] = { .doit   = fib_nl_delrule	 },
-#endif
-	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 };
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)

--

