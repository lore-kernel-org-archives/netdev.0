From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Sun, 01 Jul 2012 05:15:56 -0700 (PDT)
Message-ID: <20120701.051556.541026724350825709.davem@davemloft.net>
References: <20120701.050243.908285695895815999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273Ab2GAMP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 08:15:57 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CBA3258378B
	for <netdev@vger.kernel.org>; Sun,  1 Jul 2012 05:15:58 -0700 (PDT)
In-Reply-To: <20120701.050243.908285695895815999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 01 Jul 2012 05:02:43 -0700 (PDT)

> On a SPARC T3-1:
> 
> 1) Output route lookup: ~2800 cycles
> 2) Input route lookups: ~3000 cycles (rpfilter=0)
>                         ~4300 cycles (rpfilter=1)

Out of curiosity I got rid of the local table and made all routes
go into the main table and those numbers above become:

1) Output route lookup: ~2500 cycles
2) Input route lookups: ~2800 cycles (rpfilter=0)
                        ~4100 cycles (rpfilter=1)

====================
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3dc7c96..5a103a9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -186,9 +186,7 @@ static inline struct fib_table *fib_get_table(struct net *net, u32 id)
 {
 	struct hlist_head *ptr;
 
-	ptr = id == RT_TABLE_LOCAL ?
-		&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX] :
-		&net->ipv4.fib_table_hash[TABLE_MAIN_INDEX];
+	ptr = &net->ipv4.fib_table_hash[TABLE_MAIN_INDEX];
 	return hlist_entry(ptr->first, struct fib_table, tb_hlist);
 }
 
@@ -202,10 +200,6 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 {
 	struct fib_table *table;
 
-	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
-		return 0;
-
 	table = fib_get_table(net, RT_TABLE_MAIN);
 	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
 		return 0;
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
index a658fb4..0056542 100644
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
@@ -155,7 +149,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	res.r = NULL;
 #endif
 
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	local_table = fib_get_table(net, RT_TABLE_MAIN);
 	if (local_table) {
 		ret = RTN_UNICAST;
 		rcu_read_lock();
@@ -702,11 +696,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
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
index b23fd95..41a53b0 100644
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
