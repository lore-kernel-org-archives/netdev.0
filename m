From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: fib: fix fib_new_table() logical issue
Date: Wed, 21 Jun 2017 22:02:24 +0800
Message-ID: <1498053744-3217-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:41217 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751042AbdFUODM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 10:03:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

when CONFIG_IP_MULTIPLE_TABLES defined,
if id == RT_TABLE_LOCAL and !net->ipv4.fib_has_custom_rules,
fib_new_table() call itself to get RT_TABLE_MAIN table,
but if RT_TABLE_MAIN table not exist at this point,
this function will become deadloop.

the solution is move RT_TABLE_MAIN table create to per-net init.
and call fib_get_table() to get RT_TABLE_MAIN table.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv4/fib_frontend.c | 12 ++----------
 net/ipv4/fib_rules.c    | 11 +++++++++++
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4e678fa..4606b4a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -87,22 +87,14 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 		return tb;
 
 	if (id == RT_TABLE_LOCAL && !net->ipv4.fib_has_custom_rules)
-		alias = fib_new_table(net, RT_TABLE_MAIN);
+		alias = fib_get_table(net, RT_TABLE_MAIN);
 
 	tb = fib_trie_table(id, alias);
 	if (!tb)
 		return NULL;
 
-	switch (id) {
-	case RT_TABLE_MAIN:
-		rcu_assign_pointer(net->ipv4.fib_main, tb);
-		break;
-	case RT_TABLE_DEFAULT:
+	if (id == RT_TABLE_DEFAULT)
 		rcu_assign_pointer(net->ipv4.fib_default, tb);
-		break;
-	default:
-		break;
-	}
 
 	h = id & (FIB_TABLE_HASHSZ - 1);
 	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 778ecf9..a9796ac 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -402,8 +402,14 @@ static int fib_default_rules_init(struct fib_rules_ops *ops)
 int __net_init fib4_rules_init(struct net *net)
 {
 	int err;
+	unsigned int h;
+	struct fib_table *main_table;
 	struct fib_rules_ops *ops;
 
+	main_table = fib_trie_table(RT_TABLE_MAIN, NULL);
+	if (!main_table)
+		return -ENOMEM;
+
 	ops = fib_rules_register(&fib4_rules_ops_template, net);
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
@@ -413,11 +419,16 @@ int __net_init fib4_rules_init(struct net *net)
 		goto fail;
 	net->ipv4.rules_ops = ops;
 	net->ipv4.fib_has_custom_rules = false;
+
+	rcu_assign_pointer(net->ipv4.fib_main, main_table);
+	h = RT_TABLE_MAIN & (FIB_TABLE_HASHSZ - 1);
+	hlist_add_head_rcu(&main_table->tb_hlist, &net->ipv4.fib_table_hash[h]);
 	return 0;
 
 fail:
 	/* also cleans all rules already added */
 	fib_rules_unregister(ops);
+	fib_free_table(main_table);
 	return err;
 }
 
-- 
2.7.4
