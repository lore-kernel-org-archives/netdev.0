From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 14:06:01 -0700 (PDT)
Message-ID: <20120726.140601.1137230112117936793.davem@davemloft.net>
References: <1343324633.2626.11801.camel@edumazet-glaptop>
	<1343324896.2626.11808.camel@edumazet-glaptop>
	<CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab2GZVGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:06:03 -0400
In-Reply-To: <CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 26 Jul 2012 11:26:26 -0700

> The previous results were with a slight modifications to your earlier
> patch.  With this patch applied I am seeing 10.4Mpps with 8 queues,
> reaching a maximum of 11.6Mpps with 9 queues.

For fun you might want to see what this patch does for your tests,
it should cut the number of fib_table_lookup() calls roughly in half.

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index b64a19c..fc7eade 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -204,9 +204,7 @@ static inline struct fib_table *fib_get_table(struct net *net, u32 id)
 {
 	struct hlist_head *ptr;
 
-	ptr = id == RT_TABLE_LOCAL ?
-		&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX] :
-		&net->ipv4.fib_table_hash[TABLE_MAIN_INDEX];
+	ptr = &net->ipv4.fib_table_hash[TABLE_MAIN_INDEX];
 	return hlist_entry(ptr->first, struct fib_table, tb_hlist);
 }
 
@@ -220,10 +218,6 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 {
 	struct fib_table *table;
 
-	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
-		return 0;
-
 	table = fib_get_table(net, RT_TABLE_MAIN);
 	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
 		return 0;
@@ -245,10 +239,6 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 {
 	if (!net->ipv4.fib_has_custom_rules) {
 		res->tclassid = 0;
-		if (net->ipv4.fib_local &&
-		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
-				      FIB_LOOKUP_NOREF))
-			return 0;
 		if (net->ipv4.fib_main &&
 		    !fib_table_lookup(net->ipv4.fib_main, flp, res,
 				      FIB_LOOKUP_NOREF))
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 44bf82e..bdc0231 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -160,7 +160,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		/* Fallback to FIB local table so that communication
 		 * over loopback subnets work.
 		 */
-		local = fib_get_table(net, RT_TABLE_LOCAL);
+		local = fib_get_table(net, RT_TABLE_MAIN);
 		if (local &&
 		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
 		    res.type == RTN_LOCAL)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c1fde53..ddfe398 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -52,16 +52,10 @@ static int __net_init fib4_rules_init(struct net *net)
 {
 	struct fib_table *local_table, *main_table;
 
-	local_table = fib_trie_table(RT_TABLE_LOCAL);
-	if (local_table == NULL)
-		return -ENOMEM;
-
 	main_table  = fib_trie_table(RT_TABLE_MAIN);
 	if (main_table == NULL)
 		goto fail;
 
-	hlist_add_head_rcu(&local_table->tb_hlist,
-				&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX]);
 	hlist_add_head_rcu(&main_table->tb_hlist,
 				&net->ipv4.fib_table_hash[TABLE_MAIN_INDEX]);
 	return 0;
@@ -169,7 +163,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	if (ipv4_is_multicast(addr))
 		return RTN_MULTICAST;
 
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	local_table = fib_get_table(net, RT_TABLE_MAIN);
 	if (local_table) {
 		ret = RTN_UNICAST;
 		rcu_read_lock();
@@ -712,11 +706,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		},
 	};
 
-	if (type == RTN_UNICAST)
-		tb = fib_new_table(net, RT_TABLE_MAIN);
-	else
-		tb = fib_new_table(net, RT_TABLE_LOCAL);
-
+	tb = fib_new_table(net, RT_TABLE_MAIN);
 	if (tb == NULL)
 		return;
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index a83d74e..65135dd 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -284,9 +284,6 @@ static int fib_default_rules_init(struct fib_rules_ops *ops)
 {
 	int err;
 
-	err = fib_default_rule_add(ops, 0, RT_TABLE_LOCAL, 0);
-	if (err < 0)
-		return err;
 	err = fib_default_rule_add(ops, 0x7FFE, RT_TABLE_MAIN, 0);
 	if (err < 0)
 		return err;
