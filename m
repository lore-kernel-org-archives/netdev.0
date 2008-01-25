From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 08/11][NETNS][IPV6] fib6_rules - dynamically allocate the fib rules ops
Date: Fri, 25 Jan 2008 17:50:16 +0100
Message-ID: <20080125170818.796719655@localhost.localdomain>
References: <20080125165008.317745745@localhost.localdomain>
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:10846 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462AbYAYRLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 12:11:40 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PHBdYh100988
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:39 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PHBd6S4874438
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:39 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PHBZgZ015413
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:36 GMT
Content-Disposition: inline; filename=fib6-rules-dynamic-allocation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_rules_ops structure is dynamically allocated, so that allows
to make several instances of it per network namespace.

The global static fib6_rules_ops structure is renamed to 
fib6_rules_ops_template in order to quickly memcopy it for the
structure initialization.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/fib6_rules.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

Index: net-2.6.25/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.25.orig/net/ipv6/fib6_rules.c
+++ net-2.6.25/net/ipv6/fib6_rules.c
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
