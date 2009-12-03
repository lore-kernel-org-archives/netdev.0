From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 5/7] net: Allow fib_rule_unregister to batch
Date: Thu,  3 Dec 2009 04:29:07 -0800
Message-ID: <1259843349-3810-5-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54602 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbZLCM31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:27 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Refactor the code so fib_rules_register always takes a template instead
of the actual fib_rules_ops structure that will be used.  This is
required for network namespace support so 2 out of the 3 callers already
do this, it allows the error handling to be made common, and it allows
fib_rules_unregister to free the template for hte caller.

Modify fib_rules_unregister to use call_rcu instead of syncrhonize_rcu
to allw multiple namespaces to be cleaned up in the same rcu grace
period.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/fib_rules.h |    3 ++-
 net/core/fib_rules.c    |   36 +++++++++++++++++++++++++++++++++---
 net/decnet/dn_rules.c   |   22 ++++++++++++----------
 net/ipv4/fib_rules.c    |   12 +++---------
 net/ipv6/fib6_rules.c   |   22 +++++++---------------
 5 files changed, 57 insertions(+), 38 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 2cd707b..c27dfe7 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -64,6 +64,7 @@ struct fib_rules_ops {
 	struct list_head	rules_list;
 	struct module		*owner;
 	struct net		*fro_net;
+	struct rcu_head		rcu;
 };
 
 #define FRA_GENERIC_POLICY \
@@ -99,7 +100,7 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 	return frh->table;
 }
 
-extern int fib_rules_register(struct fib_rules_ops *);
+extern struct fib_rules_ops *fib_rules_register(struct fib_rules_ops *, struct net *);
 extern void fib_rules_unregister(struct fib_rules_ops *);
 extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index bd30938..7e8e18f 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -72,7 +72,7 @@ static void flush_route_cache(struct fib_rules_ops *ops)
 		ops->flush_cache(ops);
 }
 
-int fib_rules_register(struct fib_rules_ops *ops)
+static int __fib_rules_register(struct fib_rules_ops *ops)
 {
 	int err = -EEXIST;
 	struct fib_rules_ops *o;
@@ -102,6 +102,28 @@ errout:
 	return err;
 }
 
+struct fib_rules_ops *
+fib_rules_register(struct fib_rules_ops *tmpl, struct net *net)
+{
+	struct fib_rules_ops *ops;
+	int err;
+
+	ops = kmemdup(tmpl, sizeof (*ops), GFP_KERNEL);
+	if (ops == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&ops->rules_list);
+	ops->fro_net = net;
+
+	err = __fib_rules_register(ops);
+	if (err) {
+		kfree(ops);
+		ops = ERR_PTR(err);
+	}
+
+	return ops;
+}
+
 EXPORT_SYMBOL_GPL(fib_rules_register);
 
 void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
@@ -115,6 +137,15 @@ void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 }
 EXPORT_SYMBOL_GPL(fib_rules_cleanup_ops);
 
+static void fib_rules_put_rcu(struct rcu_head *head)
+{
+	struct fib_rules_ops *ops = container_of(head, struct fib_rules_ops, rcu);
+	struct net *net = ops->fro_net;
+
+	release_net(net);
+	kfree(ops);
+}
+
 void fib_rules_unregister(struct fib_rules_ops *ops)
 {
 	struct net *net = ops->fro_net;
@@ -124,8 +155,7 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 	fib_rules_cleanup_ops(ops);
 	spin_unlock(&net->rules_mod_lock);
 
-	synchronize_rcu();
-	release_net(net);
+	call_rcu(&ops->rcu, fib_rules_put_rcu);
 }
 
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 72495f2..7466c54 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -33,7 +33,7 @@
 #include <net/dn_dev.h>
 #include <net/dn_route.h>
 
-static struct fib_rules_ops dn_fib_rules_ops;
+static struct fib_rules_ops *dn_fib_rules_ops;
 
 struct dn_fib_rule
 {
@@ -56,7 +56,7 @@ int dn_fib_lookup(struct flowi *flp, struct dn_fib_res *res)
 	};
 	int err;
 
-	err = fib_rules_lookup(&dn_fib_rules_ops, flp, 0, &arg);
+	err = fib_rules_lookup(dn_fib_rules_ops, flp, 0, &arg);
 	res->r = arg.rule;
 
 	return err;
@@ -217,9 +217,9 @@ static u32 dn_fib_rule_default_pref(struct fib_rules_ops *ops)
 	struct list_head *pos;
 	struct fib_rule *rule;
 
-	if (!list_empty(&dn_fib_rules_ops.rules_list)) {
-		pos = dn_fib_rules_ops.rules_list.next;
-		if (pos->next != &dn_fib_rules_ops.rules_list) {
+	if (!list_empty(&dn_fib_rules_ops->rules_list)) {
+		pos = dn_fib_rules_ops->rules_list.next;
+		if (pos->next != &dn_fib_rules_ops->rules_list) {
 			rule = list_entry(pos->next, struct fib_rule, list);
 			if (rule->pref)
 				return rule->pref - 1;
@@ -234,7 +234,7 @@ static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 	dn_rt_cache_flush(-1);
 }
 
-static struct fib_rules_ops dn_fib_rules_ops = {
+static struct fib_rules_ops dn_fib_rules_ops_template = {
 	.family		= AF_DECnet,
 	.rule_size	= sizeof(struct dn_fib_rule),
 	.addr_size	= sizeof(u16),
@@ -247,21 +247,23 @@ static struct fib_rules_ops dn_fib_rules_ops = {
 	.flush_cache	= dn_fib_rule_flush_cache,
 	.nlgroup	= RTNLGRP_DECnet_RULE,
 	.policy		= dn_fib_rule_policy,
-	.rules_list	= LIST_HEAD_INIT(dn_fib_rules_ops.rules_list),
 	.owner		= THIS_MODULE,
 	.fro_net	= &init_net,
 };
 
 void __init dn_fib_rules_init(void)
 {
-	BUG_ON(fib_default_rule_add(&dn_fib_rules_ops, 0x7fff,
+	dn_fib_rules_ops =
+		fib_rules_register(&dn_fib_rules_ops_template, &init_net);
+	BUG_ON(IS_ERR(dn_fib_rules_ops));
+	BUG_ON(fib_default_rule_add(dn_fib_rules_ops, 0x7fff,
 			            RT_TABLE_MAIN, 0));
-	fib_rules_register(&dn_fib_rules_ops);
 }
 
 void __exit dn_fib_rules_cleanup(void)
 {
-	fib_rules_unregister(&dn_fib_rules_ops);
+	fib_rules_unregister(dn_fib_rules_ops);
+	rcu_barrier();
 }
 
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 835262c..9a6d30b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -301,13 +301,9 @@ int __net_init fib4_rules_init(struct net *net)
 	int err;
 	struct fib_rules_ops *ops;
 
-	ops = kmemdup(&fib4_rules_ops_template, sizeof(*ops), GFP_KERNEL);
-	if (ops == NULL)
-		return -ENOMEM;
-	INIT_LIST_HEAD(&ops->rules_list);
-	ops->fro_net = net;
-
-	fib_rules_register(ops);
+	ops = fib_rules_register(&fib4_rules_ops_template, net);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
 
 	err = fib_default_rules_init(ops);
 	if (err < 0)
@@ -318,12 +314,10 @@ int __net_init fib4_rules_init(struct net *net)
 fail:
 	/* also cleans all rules already added */
 	fib_rules_unregister(ops);
-	kfree(ops);
 	return err;
 }
 
 void __net_exit fib4_rules_exit(struct net *net)
 {
 	fib_rules_unregister(net->ipv4.rules_ops);
-	kfree(net->ipv4.rules_ops);
 }
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 00a7a5e..1eb1c07 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -264,16 +264,14 @@ static struct fib_rules_ops fib6_rules_ops_template = {
 
 static int fib6_rules_net_init(struct net *net)
 {
+	struct fib_rules_ops *ops;
 	int err = -ENOMEM;
 
-	net->ipv6.fib6_rules_ops = kmemdup(&fib6_rules_ops_template,
-					   sizeof(*net->ipv6.fib6_rules_ops),
-					   GFP_KERNEL);
-	if (!net->ipv6.fib6_rules_ops)
-		goto out;
+	ops = fib_rules_register(&fib6_rules_ops_template, net);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+	net->ipv6.fib6_rules_ops = ops;
 
-	net->ipv6.fib6_rules_ops->fro_net = net;
-	INIT_LIST_HEAD(&net->ipv6.fib6_rules_ops->rules_list);
 
 	err = fib_default_rule_add(net->ipv6.fib6_rules_ops, 0,
 				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
@@ -283,25 +281,19 @@ static int fib6_rules_net_init(struct net *net)
 	err = fib_default_rule_add(net->ipv6.fib6_rules_ops,
 				   0x7FFE, RT6_TABLE_MAIN, 0);
 	if (err)
-		goto out_fib6_default_rule_add;
+		goto out_fib6_rules_ops;
 
-	err = fib_rules_register(net->ipv6.fib6_rules_ops);
-	if (err)
-		goto out_fib6_default_rule_add;
 out:
 	return err;
 
-out_fib6_default_rule_add:
-	fib_rules_cleanup_ops(net->ipv6.fib6_rules_ops);
 out_fib6_rules_ops:
-	kfree(net->ipv6.fib6_rules_ops);
+	fib_rules_unregister(ops);
 	goto out;
 }
 
 static void fib6_rules_net_exit(struct net *net)
 {
 	fib_rules_unregister(net->ipv6.fib6_rules_ops);
-	kfree(net->ipv6.fib6_rules_ops);
 }
 
 static struct pernet_operations fib6_rules_net_ops = {
-- 
1.6.5.2.143.g8cc62

