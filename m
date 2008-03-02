From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 09/11][NETNS][IPV6] fib6_rules - handle several network namespaces
Date: Sun, 02 Mar 2008 10:37:29 +0100
Message-ID: <20080302094230.642282606@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:45581 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbYCBJol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:41 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229ieCg150750
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:40 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229iehh512180
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:40 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229idCO021909
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:39 +0100
Content-Disposition: inline; filename=09_11-fib6-rules-per-network-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_rules_ops is moved to the network namespace structure.
All references are changed to have it relatively to it.

Each time a network namespace is created a new fib6_rules_ops is
allocated, initialized and stored into the network namespace
structure.

The common part of the fib rules is namespace aware, so it is
quite easy to retrieve the network namespace from the rules and use
it in the different callbacks.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 
 net/ipv6/fib6_rules.c    |   82 ++++++++++++++++++++++++++---------------------
 2 files changed, 47 insertions(+), 36 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -41,6 +41,7 @@ struct netns_ipv6 {
 	struct fib6_table       *fib6_main_tbl;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	struct fib6_table       *fib6_local_tbl;
+	struct fib_rules_ops    *fib6_rules_ops;
 #endif
 	struct sock		**icmp_sk;
 };
Index: net-2.6.26/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.26.orig/net/ipv6/fib6_rules.c
+++ net-2.6.26/net/ipv6/fib6_rules.c
@@ -29,8 +29,6 @@ struct fib6_rule
 	u8			tclass;
 };
 
-static struct fib_rules_ops *fib6_rules_ops;
-
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 				   int flags, pol_lookup_t lookup)
 {
@@ -38,7 +36,7 @@ struct dst_entry *fib6_rule_lookup(struc
 		.lookup_ptr = lookup,
 	};
 
-	fib_rules_lookup(fib6_rules_ops, fl, flags, &arg);
+	fib_rules_lookup(net->ipv6.fib6_rules_ops, fl, flags, &arg);
 	if (arg.rule)
 		fib_rule_put(arg.rule);
 
@@ -71,7 +69,7 @@ static int fib6_rule_action(struct fib_r
 		goto discard_pkt;
 	}
 
-	table = fib6_get_table(&init_net, rule->table);
+	table = fib6_get_table(rule->fr_net, rule->table);
 	if (table)
 		rt = lookup(table, flp, flags);
 
@@ -145,13 +143,14 @@ static int fib6_rule_configure(struct fi
 			       struct nlattr **tb)
 {
 	int err = -EINVAL;
+	struct net *net = skb->sk->sk_net;
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
 
-		if (fib6_new_table(&init_net, rule->table) == NULL) {
+		if (fib6_new_table(net, rule->table) == NULL) {
 			err = -ENOBUFS;
 			goto errout;
 		}
@@ -251,49 +250,60 @@ static struct fib_rules_ops fib6_rules_o
 	.fro_net		= &init_net,
 };
 
-static int __init fib6_default_rules_init(void)
+static int fib6_rules_net_init(struct net *net)
 {
-	int err;
+	int err = -ENOMEM;
 
-	fib6_rules_ops = kmemdup(&fib6_rules_ops_template,
-				 sizeof(*fib6_rules_ops), GFP_KERNEL);
-	if (!fib6_rules_ops)
-		return -ENOMEM;
+	net->ipv6.fib6_rules_ops = kmemdup(&fib6_rules_ops_template,
+					   sizeof(*net->ipv6.fib6_rules_ops),
+					   GFP_KERNEL);
+	if (!net->ipv6.fib6_rules_ops)
+		goto out;
 
-	INIT_LIST_HEAD(&fib6_rules_ops->rules_list);
+	net->ipv6.fib6_rules_ops->fro_net = net;
+	INIT_LIST_HEAD(&net->ipv6.fib6_rules_ops->rules_list);
 
-	err = fib_default_rule_add(fib6_rules_ops, 0,
+	err = fib_default_rule_add(net->ipv6.fib6_rules_ops, 0,
 				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
-	if (err < 0)
-		return err;
-	err = fib_default_rule_add(fib6_rules_ops, 0x7FFE, RT6_TABLE_MAIN, 0);
-	if (err < 0)
-		return err;
-	return 0;
+	if (err)
+		goto out_fib6_rules_ops;
+
+	err = fib_default_rule_add(net->ipv6.fib6_rules_ops,
+				   0x7FFE, RT6_TABLE_MAIN, 0);
+	if (err)
+		goto out_fib6_default_rule_add;
+
+	err = fib_rules_register(net->ipv6.fib6_rules_ops);
+	if (err)
+		goto out_fib6_default_rule_add;
+out:
+	return err;
+
+out_fib6_default_rule_add:
+	fib_rules_cleanup_ops(net->ipv6.fib6_rules_ops);
+out_fib6_rules_ops:
+	kfree(net->ipv6.fib6_rules_ops);
+	goto out;
 }
 
-int __init fib6_rules_init(void)
+static void fib6_rules_net_exit(struct net *net)
 {
-	int ret;
-
-	ret = fib6_default_rules_init();
-	if (ret)
-		goto out;
+	fib_rules_unregister(net->ipv6.fib6_rules_ops);
+	kfree(net->ipv6.fib6_rules_ops);
+}
 
-	ret = fib_rules_register(fib6_rules_ops);
-	if (ret)
-		goto out_default_rules_init;
-out:
-	return ret;
+static struct pernet_operations fib6_rules_net_ops = {
+	.init = fib6_rules_net_init,
+	.exit = fib6_rules_net_exit,
+};
 
-out_default_rules_init:
-	fib_rules_cleanup_ops(fib6_rules_ops);
-	kfree(fib6_rules_ops);
-	goto out;
+int __init fib6_rules_init(void)
+{
+	return register_pernet_subsys(&fib6_rules_net_ops);
 }
 
+
 void fib6_rules_cleanup(void)
 {
-	fib_rules_unregister(fib6_rules_ops);
-	kfree(fib6_rules_ops);
+	return unregister_pernet_subsys(&fib6_rules_net_ops);
 }

-- 
