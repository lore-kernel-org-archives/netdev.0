From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Thu, 04 Feb 2010 18:04:34 +0100
Message-ID: <4B6AFE22.20304@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050707080904050506020803"
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49412 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552Ab0BDREi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 12:04:38 -0500
In-Reply-To: <4B6AF36A.3050402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050707080904050506020803
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Jon Masters correctly points out that conntrack hash sizes
>> (nf_conntrack_htable_size) are global (not per-netns) and
>> modifiable at runtime via /sys/module/nf_conntrack/hashsize .
>>
>> Steps to reproduce:
>> 	clone(CLONE_NEWNET)
>> 	[grow /sys/module/nf_conntrack/hashsize]
>> 	exit()
>>
>> At netns exit we are going to scan random memory for conntracks to be killed.
>>
>> Apparently there is a code which deals with hashtable resize for
>> init_net (and it was there befode netns conntrack code), so prohibit
>> hashsize modification if there is more than one netns exists.
>>
>> To change hashtable sizes, you need to reload module.
>>
>> Expectation hashtable size was simply glued to a variable with no code
>> to rehash expectations, so it was a bug to allow writing to it.
>> Make "expect_hashsize" readonly.
>>
>> This is temporarily until we figure out what to do.
> 
> How about alternatively moving nf_conntrack_hsize into the
> per-namespace struct? It doesn't look more complicated or
> intrusive and would allow to still change the init_net
> hashsize. Also seems less hackish :)

How about this (so far untested) patch? The htable_size is moved into
the per-namespace struct and initialized from the current (global)
value of nf_conntrack_htable_size. Changes through sysfs are still
permitted, but only affect the init namespace and newly created ones.

Additionally I removed reinitializing the hash random value when
changing the hash size since that also requires to rehash in all
namespaces.

--------------050707080904050506020803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index aed23b6..63d4498 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -11,6 +11,7 @@ struct nf_conntrack_ecache;
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
+	unsigned int		htable_size;
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2eb3814..9a4b8b7 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -40,6 +40,7 @@ struct netns_ipv4 {
 	struct xt_table		*iptable_security;
 	struct xt_table		*nat_table;
 	struct hlist_head	*nat_bysource;
+	unsigned int		nat_htable_size;
 	int			nat_vmalloced;
 #endif
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index d171b12..d1ea38a 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -210,7 +210,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 	},
 	{
 		.procname	= "ip_conntrack_buckets",
-		.data		= &nf_conntrack_htable_size,
+		.data		= &init_net.ct.htable_size,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 8668a3d..2fb7b76 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -32,7 +32,7 @@ static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
-	     st->bucket < nf_conntrack_htable_size;
+	     st->bucket < net->ct.htable_size;
 	     st->bucket++) {
 		n = rcu_dereference(net->ct.hash[st->bucket].first);
 		if (!is_a_nulls(n))
@@ -50,7 +50,7 @@ static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
 	head = rcu_dereference(head->next);
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) == st->bucket)) {
-			if (++st->bucket >= nf_conntrack_htable_size)
+			if (++st->bucket >= net->ct.htable_size)
 				return NULL;
 		}
 		head = rcu_dereference(net->ct.hash[st->bucket].first);
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index fe1a644..5cff943 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -35,9 +35,6 @@ static DEFINE_SPINLOCK(nf_nat_lock);
 
 static struct nf_conntrack_l3proto *l3proto __read_mostly;
 
-/* Calculated at init based on memory size */
-static unsigned int nf_nat_htable_size __read_mostly;
-
 #define MAX_IP_NAT_PROTO 256
 static const struct nf_nat_protocol *nf_nat_protos[MAX_IP_NAT_PROTO]
 						__read_mostly;
@@ -72,7 +69,7 @@ EXPORT_SYMBOL_GPL(nf_nat_proto_put);
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
-hash_by_src(const struct nf_conntrack_tuple *tuple)
+hash_by_src(const struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	unsigned int hash;
 
@@ -80,7 +77,7 @@ hash_by_src(const struct nf_conntrack_tuple *tuple)
 	hash = jhash_3words((__force u32)tuple->src.u3.ip,
 			    (__force u32)tuple->src.u.all,
 			    tuple->dst.protonum, 0);
-	return ((u64)hash * nf_nat_htable_size) >> 32;
+	return ((u64)hash * net->ipv4.nat_htable_size) >> 32;
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -147,7 +144,7 @@ find_appropriate_src(struct net *net,
 		     struct nf_conntrack_tuple *result,
 		     const struct nf_nat_range *range)
 {
-	unsigned int h = hash_by_src(tuple);
+	unsigned int h = hash_by_src(net, tuple);
 	const struct nf_conn_nat *nat;
 	const struct nf_conn *ct;
 	const struct hlist_node *n;
@@ -330,7 +327,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 	if (have_to_hash) {
 		unsigned int srchash;
 
-		srchash = hash_by_src(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		srchash = hash_by_src(net, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 		spin_lock_bh(&nf_nat_lock);
 		/* nf_conntrack_alter_reply might re-allocate exntension aera */
 		nat = nfct_nat(ct);
@@ -679,8 +676,11 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 
 static int __net_init nf_nat_net_init(struct net *net)
 {
-	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size,
-						      &net->ipv4.nat_vmalloced, 0);
+	/* Leave them the same for the moment. */
+	net->ipv4.nat_htable_size = net->ct.htable_size;
+
+	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&net->ipv4.nat_htable_size,
+						       &net->ipv4.nat_vmalloced, 0);
 	if (!net->ipv4.nat_bysource)
 		return -ENOMEM;
 	return 0;
@@ -703,7 +703,7 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 	nf_ct_iterate_cleanup(net, &clean_nat, NULL);
 	synchronize_rcu();
 	nf_ct_free_hashtable(net->ipv4.nat_bysource, net->ipv4.nat_vmalloced,
-			     nf_nat_htable_size);
+			     net->ipv4.nat_htable_size);
 }
 
 static struct pernet_operations nf_nat_net_ops = {
@@ -724,9 +724,6 @@ static int __init nf_nat_init(void)
 		return ret;
 	}
 
-	/* Leave them the same for the moment. */
-	nf_nat_htable_size = nf_conntrack_htable_size;
-
 	ret = register_pernet_subsys(&nf_nat_net_ops);
 	if (ret < 0)
 		goto cleanup_extend;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 9de4bd4..ef1c856 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -84,9 +84,10 @@ static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
 	return ((u64)h * size) >> 32;
 }
 
-static inline u_int32_t hash_conntrack(const struct nf_conntrack_tuple *tuple)
+static inline u_int32_t hash_conntrack(const struct net *net,
+				       const struct nf_conntrack_tuple *tuple)
 {
-	return __hash_conntrack(tuple, nf_conntrack_htable_size,
+	return __hash_conntrack(tuple, net->ct.htable_size,
 				nf_conntrack_hash_rnd);
 }
 
@@ -294,7 +295,7 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(tuple);
+	unsigned int hash = hash_conntrack(net, tuple);
 
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
@@ -364,10 +365,11 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 
 void nf_conntrack_hash_insert(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	unsigned int hash, repl_hash;
 
-	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	hash = hash_conntrack(net, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	repl_hash = hash_conntrack(net, &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 }
@@ -395,8 +397,8 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return NF_ACCEPT;
 
-	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	hash = hash_conntrack(net, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	repl_hash = hash_conntrack(net, &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	/* We're not in hash table, and we refuse to set up related
 	   connections for unconfirmed conns.  But packet copies and
@@ -466,7 +468,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	struct net *net = nf_ct_net(ignored_conntrack);
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(tuple);
+	unsigned int hash = hash_conntrack(net, tuple);
 
 	/* Disable BHs the entire time since we need to disable them at
 	 * least once for the stats anyway.
@@ -501,7 +503,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	int dropped = 0;
 
 	rcu_read_lock();
-	for (i = 0; i < nf_conntrack_htable_size; i++) {
+	for (i = 0; i < net->ct.htable_size; i++) {
 		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
 					 hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
@@ -521,7 +523,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 		if (cnt >= NF_CT_EVICTION_RANGE)
 			break;
 
-		hash = (hash + 1) % nf_conntrack_htable_size;
+		hash = (hash + 1) % net->ct.htable_size;
 	}
 	rcu_read_unlock();
 
@@ -555,7 +557,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		unsigned int hash = hash_conntrack(orig);
+		unsigned int hash = hash_conntrack(net, orig);
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
@@ -1012,7 +1014,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	struct hlist_nulls_node *n;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
+	for (; *bucket < net->ct.htable_size; (*bucket)++) {
 		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
@@ -1130,7 +1132,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
-			     nf_conntrack_htable_size);
+			     net->ct.htable_size);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
@@ -1190,7 +1192,6 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 {
 	int i, bucket, vmalloced, old_vmalloced;
 	unsigned int hashsize, old_size;
-	int rnd;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
 
@@ -1206,33 +1207,29 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!hash)
 		return -ENOMEM;
 
-	/* We have to rehahs for the new table anyway, so we also can
-	 * use a newrandom seed */
-	get_random_bytes(&rnd, sizeof(rnd));
-
 	/* Lookups in the old hash might happen in parallel, which means we
 	 * might get false negatives during connection lookup. New connections
 	 * created because of a false negative won't make it into the hash
 	 * though since that required taking the lock.
 	 */
 	spin_lock_bh(&nf_conntrack_lock);
-	for (i = 0; i < nf_conntrack_htable_size; i++) {
+	for (i = 0; i < init_net.ct.htable_size; i++) {
 		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
 			h = hlist_nulls_entry(init_net.ct.hash[i].first,
 					struct nf_conntrack_tuple_hash, hnnode);
 			hlist_nulls_del_rcu(&h->hnnode);
-			bucket = __hash_conntrack(&h->tuple, hashsize, rnd);
+			bucket = __hash_conntrack(&h->tuple, hashsize,
+						  nf_conntrack_hash_rnd);
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
-	old_size = nf_conntrack_htable_size;
+	old_size = init_net.ct.htable_size;
 	old_vmalloced = init_net.ct.hash_vmalloc;
 	old_hash = init_net.ct.hash;
 
-	nf_conntrack_htable_size = hashsize;
+	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
 	init_net.ct.hash_vmalloc = vmalloced;
 	init_net.ct.hash = hash;
-	nf_conntrack_hash_rnd = rnd;
 	spin_unlock_bh(&nf_conntrack_lock);
 
 	nf_ct_free_hashtable(old_hash, old_vmalloced, old_size);
@@ -1328,7 +1325,9 @@ static int nf_conntrack_init_net(struct net *net)
 		ret = -ENOMEM;
 		goto err_cache;
 	}
-	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
+
+	net->ct.htable_size = nf_conntrack_htable_size;
+	net->ct.hash = nf_ct_alloc_hashtable(&net->ct.htable_size,
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
 		ret = -ENOMEM;
@@ -1353,7 +1352,7 @@ err_acct:
 	nf_conntrack_expect_fini(net);
 err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
-			     nf_conntrack_htable_size);
+			     net->ct.htable_size);
 err_hash:
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 err_cache:
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index fdf5d2a..1e751b1 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -577,7 +577,7 @@ int nf_conntrack_expect_init(struct net *net)
 
 	if (net_eq(net, &init_net)) {
 		if (!nf_ct_expect_hsize) {
-			nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
+			nf_ct_expect_hsize = net->ct.htable_size / 256;
 			if (!nf_ct_expect_hsize)
 				nf_ct_expect_hsize = 1;
 		}
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 65c2a7b..4b1a56b 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -192,7 +192,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	/* Get rid of expecteds, set helpers to NULL. */
 	hlist_nulls_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
-	for (i = 0; i < nf_conntrack_htable_size; i++) {
+	for (i = 0; i < net->ct.htable_size; i++) {
 		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 			unhelp(h, me);
 	}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 42f21c0..0ffe689 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -594,7 +594,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rcu_read_lock();
 	last = (struct nf_conn *)cb->args[1];
-	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
+	for (; cb->args[0] < init_net.ct.htable_size; cb->args[0]++) {
 restart:
 		hlist_nulls_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
 					 hnnode) {
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 028aba6..e310f15 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -51,7 +51,7 @@ static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
-	     st->bucket < nf_conntrack_htable_size;
+	     st->bucket < net->ct.htable_size;
 	     st->bucket++) {
 		n = rcu_dereference(net->ct.hash[st->bucket].first);
 		if (!is_a_nulls(n))
@@ -69,7 +69,7 @@ static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
 	head = rcu_dereference(head->next);
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) == st->bucket)) {
-			if (++st->bucket >= nf_conntrack_htable_size)
+			if (++st->bucket >= net->ct.htable_size)
 				return NULL;
 		}
 		head = rcu_dereference(net->ct.hash[st->bucket].first);
@@ -355,7 +355,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	},
 	{
 		.procname       = "nf_conntrack_buckets",
-		.data           = &nf_conntrack_htable_size,
+		.data           = &init_net.ct.htable_size,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0444,
 		.proc_handler   = proc_dointvec,
@@ -421,6 +421,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		goto out_kmemdup;
 
 	table[1].data = &net->ct.count;
+	table[2].data = &net->ct.htable_size;
 	table[3].data = &net->ct.sysctl_checksum;
 	table[4].data = &net->ct.sysctl_log_invalid;
 

--------------050707080904050506020803--
