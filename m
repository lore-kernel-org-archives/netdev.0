From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/6] ipv6 - make fib6_rules_init to return an error code
Date: Thu, 06 Dec 2007 14:53:32 +0100
Message-ID: <20071206140258.610073641@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:50596 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbXLFOFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:05:16 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E5GEJ196136
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:16 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E5FAm2150546
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:15 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5Er4012602
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:15 +0100
Content-Disposition: inline; filename=fib6_rules-handle-error-at-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the fib_rules initialization finished, no return code is provided
so there is no way to know, for the caller, if the initialization has
been successful or has failed. This patch fix that.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/fib_rules.h |    1 +
 include/net/ip6_fib.h   |    2 +-
 net/core/fib_rules.c    |    5 +++--
 net/ipv6/fib6_rules.c   |   19 ++++++++++++++++---
 4 files changed, 21 insertions(+), 6 deletions(-)

Index: net-2.6.25/include/net/ip6_fib.h
===================================================================
--- net-2.6.25.orig/include/net/ip6_fib.h
+++ net-2.6.25/include/net/ip6_fib.h
@@ -226,7 +226,7 @@ extern void			fib6_gc_cleanup(void);
 
 extern int			fib6_init(void);
 
-extern void			fib6_rules_init(void);
+extern int			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
 
 #endif
Index: net-2.6.25/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.25.orig/net/ipv6/fib6_rules.c
+++ net-2.6.25/net/ipv6/fib6_rules.c
@@ -265,10 +265,23 @@ static int __init fib6_default_rules_ini
 	return 0;
 }
 
-void __init fib6_rules_init(void)
+int __init fib6_rules_init(void)
 {
-	BUG_ON(fib6_default_rules_init());
-	fib_rules_register(&fib6_rules_ops);
+	int ret;
+
+	ret = fib6_default_rules_init();
+	if (ret)
+		goto out;
+
+	ret = fib_rules_register(&fib6_rules_ops);
+	if (ret)
+		goto out_default_rules_init;
+out:
+	return ret;
+
+out_default_rules_init:
+	fib_rules_cleanup_ops(&fib6_rules_ops);
+	goto out;
 }
 
 void fib6_rules_cleanup(void)
Index: net-2.6.25/include/net/fib_rules.h
===================================================================
--- net-2.6.25.orig/include/net/fib_rules.h
+++ net-2.6.25/include/net/fib_rules.h
@@ -103,6 +103,7 @@ static inline u32 frh_get_table(struct f
 
 extern int			fib_rules_register(struct fib_rules_ops *);
 extern int			fib_rules_unregister(struct fib_rules_ops *);
+extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
 
 extern int			fib_rules_lookup(struct fib_rules_ops *,
 						 struct flowi *, int flags,
Index: net-2.6.25/net/core/fib_rules.c
===================================================================
--- net-2.6.25.orig/net/core/fib_rules.c
+++ net-2.6.25/net/core/fib_rules.c
@@ -102,7 +102,7 @@ errout:
 
 EXPORT_SYMBOL_GPL(fib_rules_register);
 
-static void cleanup_ops(struct fib_rules_ops *ops)
+void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 {
 	struct fib_rule *rule, *tmp;
 
@@ -111,6 +111,7 @@ static void cleanup_ops(struct fib_rules
 		fib_rule_put(rule);
 	}
 }
+EXPORT_SYMBOL_GPL(fib_rules_cleanup_ops);
 
 int fib_rules_unregister(struct fib_rules_ops *ops)
 {
@@ -121,7 +122,7 @@ int fib_rules_unregister(struct fib_rule
 	list_for_each_entry(o, &rules_ops, list) {
 		if (o == ops) {
 			list_del_rcu(&o->list);
-			cleanup_ops(ops);
+			fib_rules_cleanup_ops(ops);
 			goto out;
 		}
 	}

-- 
