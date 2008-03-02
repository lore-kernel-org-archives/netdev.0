From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 08/11][NETNS][IPV6] fib6 rule - dynamic allocation of the rules struct ops
Date: Sun, 02 Mar 2008 10:37:28 +0100
Message-ID: <20080302094216.617181602@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:36192 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbYCBJoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:32 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229iVsX088658
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229iViA540786
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:31 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229iUoJ005627
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:31 GMT
Content-Disposition: inline; filename=08_11-fib6-rules-dynamic-allocation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_rules_ops structure is dynamically allocated, so that allows
to make several instances of it per network namespace.

The global static fib6_rules_ops structure is renamed to 
fib6_rules_ops_template in order to quickly memcopy it for the
structure initialization.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/fib6_rules.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

Index: net-2.6.26/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.26.orig/net/ipv6/fib6_rules.c
+++ net-2.6.26/net/ipv6/fib6_rules.c
@@ -29,7 +29,7 @@ struct fib6_rule
 	u8			tclass;
 };
 
-static struct fib_rules_ops fib6_rules_ops;
+static struct fib_rules_ops *fib6_rules_ops;
 
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 				   int flags, pol_lookup_t lookup)
@@ -38,7 +38,7 @@ struct dst_entry *fib6_rule_lookup(struc
 		.lookup_ptr = lookup,
 	};
 
-	fib_rules_lookup(&fib6_rules_ops, fl, flags, &arg);
+	fib_rules_lookup(fib6_rules_ops, fl, flags, &arg);
 	if (arg.rule)
 		fib_rule_put(arg.rule);
 
@@ -234,7 +234,7 @@ static size_t fib6_rule_nlmsg_payload(st
 	       + nla_total_size(16); /* src */
 }
 
-static struct fib_rules_ops fib6_rules_ops = {
+static struct fib_rules_ops fib6_rules_ops_template = {
 	.family			= AF_INET6,
 	.rule_size		= sizeof(struct fib6_rule),
 	.addr_size		= sizeof(struct in6_addr),
@@ -247,7 +247,6 @@ static struct fib_rules_ops fib6_rules_o
 	.nlmsg_payload		= fib6_rule_nlmsg_payload,
 	.nlgroup		= RTNLGRP_IPV6_RULE,
 	.policy			= fib6_rule_policy,
-	.rules_list		= LIST_HEAD_INIT(fib6_rules_ops.rules_list),
 	.owner			= THIS_MODULE,
 	.fro_net		= &init_net,
 };
@@ -256,11 +255,18 @@ static int __init fib6_default_rules_ini
 {
 	int err;
 
-	err = fib_default_rule_add(&fib6_rules_ops, 0,
+	fib6_rules_ops = kmemdup(&fib6_rules_ops_template,
+				 sizeof(*fib6_rules_ops), GFP_KERNEL);
+	if (!fib6_rules_ops)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&fib6_rules_ops->rules_list);
+
+	err = fib_default_rule_add(fib6_rules_ops, 0,
 				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
 	if (err < 0)
 		return err;
-	err = fib_default_rule_add(&fib6_rules_ops, 0x7FFE, RT6_TABLE_MAIN, 0);
+	err = fib_default_rule_add(fib6_rules_ops, 0x7FFE, RT6_TABLE_MAIN, 0);
 	if (err < 0)
 		return err;
 	return 0;
@@ -274,18 +280,20 @@ int __init fib6_rules_init(void)
 	if (ret)
 		goto out;
 
-	ret = fib_rules_register(&fib6_rules_ops);
+	ret = fib_rules_register(fib6_rules_ops);
 	if (ret)
 		goto out_default_rules_init;
 out:
 	return ret;
 
 out_default_rules_init:
-	fib_rules_cleanup_ops(&fib6_rules_ops);
+	fib_rules_cleanup_ops(fib6_rules_ops);
+	kfree(fib6_rules_ops);
 	goto out;
 }
 
 void fib6_rules_cleanup(void)
 {
-	fib_rules_unregister(&fib6_rules_ops);
+	fib_rules_unregister(fib6_rules_ops);
+	kfree(fib6_rules_ops);
 }

-- 
