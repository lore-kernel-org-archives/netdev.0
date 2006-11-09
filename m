From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/6] [NET] rules: Add support to invert selectors
Date: Thu, 09 Nov 2006 12:27:41 +0100
Message-ID: <20061109113246.170519079@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:10192 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965559AbWKILeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:34:02 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=rules_invert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces a new flag FIB_RULE_INVERT causing rules to apply
if the specified selector doesn't match.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/linux/fib_rules.h
===================================================================
--- net-2.6.20.orig/include/linux/fib_rules.h	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/include/linux/fib_rules.h	2006-11-08 23:34:13.000000000 +0100
@@ -6,6 +6,7 @@
 
 /* rule is permanent, and cannot be deleted */
 #define FIB_RULE_PERMANENT	1
+#define FIB_RULE_INVERT		2
 
 struct fib_rule_hdr
 {
Index: net-2.6.20/net/core/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/core/fib_rules.c	2006-11-08 23:32:35.000000000 +0100
+++ net-2.6.20/net/core/fib_rules.c	2006-11-08 23:34:51.000000000 +0100
@@ -107,6 +107,22 @@
 
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
+static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
+			  struct flowi *fl, int flags)
+{
+	int ret = 0;
+
+	if (rule->ifindex && (rule->ifindex != fl->iif))
+		goto out;
+
+	if ((rule->mark ^ fl->mark) & rule->mark_mask)
+		goto out;
+
+	ret = ops->match(rule, fl, flags);
+out:
+	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
+}
+
 int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
 		     int flags, struct fib_lookup_arg *arg)
 {
@@ -116,13 +132,7 @@
 	rcu_read_lock();
 
 	list_for_each_entry_rcu(rule, ops->rules_list, list) {
-		if (rule->ifindex && (rule->ifindex != fl->iif))
-			continue;
-
-		if ((rule->mark ^ fl->mark) & rule->mark_mask)
-			continue;
-
-		if (!ops->match(rule, fl, flags))
+		if (!fib_rule_match(rule, ops, fl, flags))
 			continue;
 
 		err = ops->action(rule, fl, flags, arg);

--

