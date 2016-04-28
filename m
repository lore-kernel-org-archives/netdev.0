From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 8/9] netfilter: conntrack: use a single hashtable for all namespaces
Date: Thu, 28 Apr 2016 19:13:47 +0200
Message-ID: <1461863628-23350-9-git-send-email-fw@strlen.de>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41584 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbcD1RN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 13:13:56 -0400
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already include netns address in the hash and compare the netns pointers
during lookup, so even if namespaces have overlapping addresses entries
will be spread across the table.

Assuming 64k bucket size, this change saves 0.5 mbyte per namespace on a
64bit system.

NAT bysrc and expectation hash is still per namespace, those will
changed too soon.

Future patch will also make conntrack object slab cache global again.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 checkpatch complains about 'WARNING: line over 80 characters' but
 forcing line breaks looked even worse to me.

 include/net/netfilter/nf_conntrack_core.h          |  1 +
 include/net/netns/conntrack.h                      |  2 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |  2 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   | 10 ++-
 net/netfilter/nf_conntrack_core.c                  | 78 +++++++++++-----------
 net/netfilter/nf_conntrack_helper.c                |  6 +-
 net/netfilter/nf_conntrack_netlink.c               |  8 +--
 net/netfilter/nf_conntrack_standalone.c            | 13 ++--
 net/netfilter/nf_nat_core.c                        |  2 +-
 net/netfilter/nfnetlink_cttimeout.c                |  6 +-
 10 files changed, 60 insertions(+), 68 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 389e6da..e8ad0ad 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -82,6 +82,7 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
 
 #define CONNTRACK_LOCKS 1024
 
+extern struct hlist_nulls_head *nf_conntrack_hash;
 extern spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
 void nf_conntrack_lock(spinlock_t *lock);
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index b052785..251c435 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -93,9 +93,7 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 
-	unsigned int		htable_size;
 	struct kmem_cache	*nf_conntrack_cachep;
-	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
 	struct ct_pcpu __percpu *pcpu_lists;
 	struct ip_conntrack_stat __percpu *stat;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index e3c46e8..ae1a71a 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -360,7 +360,7 @@ static int ipv4_init_net(struct net *net)
 
 	in->ctl_table[0].data = &nf_conntrack_max;
 	in->ctl_table[1].data = &net->ct.count;
-	in->ctl_table[2].data = &net->ct.htable_size;
+	in->ctl_table[2].data = &nf_conntrack_htable_size;
 	in->ctl_table[3].data = &net->ct.sysctl_checksum;
 	in->ctl_table[4].data = &net->ct.sysctl_log_invalid;
 #endif
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 171aba1..f8fc7ab 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -31,15 +31,14 @@ struct ct_iter_state {
 
 static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
-	     st->bucket < net->ct.htable_size;
+	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
 		n = rcu_dereference(
-			hlist_nulls_first_rcu(&net->ct.hash[st->bucket]));
+			hlist_nulls_first_rcu(&nf_conntrack_hash[st->bucket]));
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -49,17 +48,16 @@ static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
 				      struct hlist_nulls_node *head)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
 	head = rcu_dereference(hlist_nulls_next_rcu(head));
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) == st->bucket)) {
-			if (++st->bucket >= net->ct.htable_size)
+			if (++st->bucket >= nf_conntrack_htable_size)
 				return NULL;
 		}
 		head = rcu_dereference(
-			hlist_nulls_first_rcu(&net->ct.hash[st->bucket]));
+			hlist_nulls_first_rcu(&nf_conntrack_hash[st->bucket]));
 	}
 	return head;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c29b929..d58b597 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -68,6 +68,9 @@ EXPORT_SYMBOL_GPL(nf_conntrack_locks);
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 
+struct hlist_nulls_head *nf_conntrack_hash __read_mostly;
+EXPORT_SYMBOL_GPL(nf_conntrack_hash);
+
 static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 static __read_mostly seqcount_t nf_conntrack_generation;
 static __read_mostly bool nf_conntrack_locks_all;
@@ -163,9 +166,9 @@ static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple,
 		      tuple->dst.protonum));
 }
 
-static u32 hash_bucket(u32 hash, const struct net *net)
+static u32 scale_hash(u32 hash)
 {
-	return reciprocal_scale(hash, net->ct.htable_size);
+	return reciprocal_scale(hash, nf_conntrack_htable_size);
 }
 
 static u32 __hash_conntrack(const struct net *net,
@@ -178,7 +181,7 @@ static u32 __hash_conntrack(const struct net *net,
 static u32 hash_conntrack(const struct net *net,
 			  const struct nf_conntrack_tuple *tuple)
 {
-	return __hash_conntrack(net, tuple, net->ct.htable_size);
+	return scale_hash(hash_conntrack_raw(tuple, net));
 }
 
 bool
@@ -477,8 +480,8 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 begin:
 	do {
 		sequence = read_seqcount_begin(&nf_conntrack_generation);
-		bucket = hash_bucket(hash, net);
-		ct_hash = net->ct.hash;
+		bucket = scale_hash(hash);
+		ct_hash = nf_conntrack_hash;
 	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[bucket], hnnode) {
@@ -542,12 +545,10 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 				       unsigned int hash,
 				       unsigned int reply_hash)
 {
-	struct net *net = nf_ct_net(ct);
-
 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-			   &net->ct.hash[hash]);
+			   &nf_conntrack_hash[hash]);
 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode,
-			   &net->ct.hash[reply_hash]);
+			   &nf_conntrack_hash[reply_hash]);
 }
 
 int
@@ -572,12 +573,12 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	} while (nf_conntrack_double_lock(net, hash, reply_hash, sequence));
 
 	/* See if there's one in the list already, including reverse */
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				    zone, net))
 			goto out;
 
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[reply_hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				    zone, net))
 			goto out;
@@ -632,7 +633,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		sequence = read_seqcount_begin(&nf_conntrack_generation);
 		/* reuse the hash saved before */
 		hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
-		hash = hash_bucket(hash, net);
+		hash = scale_hash(hash);
 		reply_hash = hash_conntrack(net,
 					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
@@ -662,12 +663,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				    zone, net))
 			goto out;
 
-	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
+	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[reply_hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				    zone, net))
 			goto out;
@@ -735,7 +736,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	do {
 		sequence = read_seqcount_begin(&nf_conntrack_generation);
 		hash = hash_conntrack(net, tuple);
-		ct_hash = net->ct.hash;
+		ct_hash = nf_conntrack_hash;
 	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
@@ -772,16 +773,16 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 	local_bh_disable();
 restart:
 	sequence = read_seqcount_begin(&nf_conntrack_generation);
-	hash = hash_bucket(_hash, net);
-	for (; i < net->ct.htable_size; i++) {
+	hash = scale_hash(_hash);
+	for (; i < nf_conntrack_htable_size; i++) {
 		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
 		nf_conntrack_lock(lockp);
 		if (read_seqcount_retry(&nf_conntrack_generation, sequence)) {
 			spin_unlock(lockp);
 			goto restart;
 		}
-		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
-					 hnnode) {
+		hlist_nulls_for_each_entry_rcu(h, n, &nf_conntrack_hash[hash],
+					       hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
 			if (!test_bit(IPS_ASSURED_BIT, &tmp->status) &&
 			    !nf_ct_is_dying(tmp) &&
@@ -792,7 +793,7 @@ restart:
 			cnt++;
 		}
 
-		hash = (hash + 1) % net->ct.htable_size;
+		hash = (hash + 1) % nf_conntrack_htable_size;
 		spin_unlock(lockp);
 
 		if (ct || cnt >= NF_CT_EVICTION_RANGE)
@@ -1375,12 +1376,12 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	int cpu;
 	spinlock_t *lockp;
 
-	for (; *bucket < net->ct.htable_size; (*bucket)++) {
+	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
 		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
 		local_bh_disable();
 		nf_conntrack_lock(lockp);
-		if (*bucket < net->ct.htable_size) {
-			hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
+		if (*bucket < nf_conntrack_htable_size) {
+			hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[*bucket], hnnode) {
 				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 					continue;
 				ct = nf_ct_tuplehash_to_ctrack(h);
@@ -1527,7 +1528,6 @@ i_see_dead_people:
 	}
 
 	list_for_each_entry(net, net_exit_list, exit_list) {
-		nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 		nf_conntrack_proto_pernet_fini(net);
 		nf_conntrack_helper_pernet_fini(net);
 		nf_conntrack_ecache_pernet_fini(net);
@@ -1598,10 +1598,10 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	 * though since that required taking the locks.
 	 */
 
-	for (i = 0; i < init_net.ct.htable_size; i++) {
-		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
-			h = hlist_nulls_entry(init_net.ct.hash[i].first,
-					struct nf_conntrack_tuple_hash, hnnode);
+	for (i = 0; i < nf_conntrack_htable_size; i++) {
+		while (!hlist_nulls_empty(&nf_conntrack_hash[i])) {
+			h = hlist_nulls_entry(nf_conntrack_hash[i].first,
+					      struct nf_conntrack_tuple_hash, hnnode);
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			hlist_nulls_del_rcu(&h->hnnode);
 			bucket = __hash_conntrack(nf_ct_net(ct),
@@ -1609,11 +1609,11 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
-	old_size = init_net.ct.htable_size;
-	old_hash = init_net.ct.hash;
+	old_size = nf_conntrack_htable_size;
+	old_hash = nf_conntrack_hash;
 
-	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
-	init_net.ct.hash = hash;
+	nf_conntrack_hash = hash;
+	nf_conntrack_htable_size = hashsize;
 
 	write_seqcount_end(&nf_conntrack_generation);
 	nf_conntrack_all_unlock();
@@ -1669,6 +1669,11 @@ int nf_conntrack_init_start(void)
 		 * entries. */
 		max_factor = 4;
 	}
+
+	nf_conntrack_hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size, 1);
+	if (!nf_conntrack_hash)
+		return -ENOMEM;
+
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
 	printk(KERN_INFO "nf_conntrack version %s (%u buckets, %d max)\n",
@@ -1747,6 +1752,7 @@ err_tstamp:
 err_acct:
 	nf_conntrack_expect_fini();
 err_expect:
+	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_htable_size);
 	return ret;
 }
 
@@ -1799,12 +1805,6 @@ int nf_conntrack_init_net(struct net *net)
 		goto err_cache;
 	}
 
-	net->ct.htable_size = nf_conntrack_htable_size;
-	net->ct.hash = nf_ct_alloc_hashtable(&net->ct.htable_size, 1);
-	if (!net->ct.hash) {
-		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
-		goto err_hash;
-	}
 	ret = nf_conntrack_expect_pernet_init(net);
 	if (ret < 0)
 		goto err_expect;
@@ -1836,8 +1836,6 @@ err_tstamp:
 err_acct:
 	nf_conntrack_expect_pernet_fini(net);
 err_expect:
-	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
-err_hash:
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 err_cache:
 	kfree(net->ct.slabname);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 498bf74..cb48e6a 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -424,10 +424,10 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 		spin_unlock_bh(&pcpu->lock);
 	}
 	local_bh_disable();
-	for (i = 0; i < net->ct.htable_size; i++) {
+	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-		if (i < net->ct.htable_size) {
-			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
+		if (i < nf_conntrack_htable_size) {
+			hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
 				unhelp(h, me);
 		}
 		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index f6bbcb2..e00f178 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -824,16 +824,16 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conn *)cb->args[1];
 
 	local_bh_disable();
-	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
+	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
 		lockp = &nf_conntrack_locks[cb->args[0] % CONNTRACK_LOCKS];
 		nf_conntrack_lock(lockp);
-		if (cb->args[0] >= net->ct.htable_size) {
+		if (cb->args[0] >= nf_conntrack_htable_size) {
 			spin_unlock(lockp);
 			goto out;
 		}
-		hlist_nulls_for_each_entry(h, n, &net->ct.hash[cb->args[0]],
-					 hnnode) {
+		hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[cb->args[0]],
+					   hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0f1a45b..f87e84e 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -54,14 +54,13 @@ struct ct_iter_state {
 
 static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
-	     st->bucket < net->ct.htable_size;
+	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n = rcu_dereference(hlist_nulls_first_rcu(&net->ct.hash[st->bucket]));
+		n = rcu_dereference(hlist_nulls_first_rcu(&nf_conntrack_hash[st->bucket]));
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -71,18 +70,17 @@ static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
 				      struct hlist_nulls_node *head)
 {
-	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
 	head = rcu_dereference(hlist_nulls_next_rcu(head));
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) == st->bucket)) {
-			if (++st->bucket >= net->ct.htable_size)
+			if (++st->bucket >= nf_conntrack_htable_size)
 				return NULL;
 		}
 		head = rcu_dereference(
 				hlist_nulls_first_rcu(
-					&net->ct.hash[st->bucket]));
+					&nf_conntrack_hash[st->bucket]));
 	}
 	return head;
 }
@@ -458,7 +456,7 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 	},
 	{
 		.procname       = "nf_conntrack_buckets",
-		.data           = &init_net.ct.htable_size,
+		.data           = &nf_conntrack_htable_size,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0444,
 		.proc_handler   = proc_dointvec,
@@ -512,7 +510,6 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		goto out_kmemdup;
 
 	table[1].data = &net->ct.count;
-	table[2].data = &net->ct.htable_size;
 	table[3].data = &net->ct.sysctl_checksum;
 	table[4].data = &net->ct.sysctl_log_invalid;
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 3d52271..d74e716 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -824,7 +824,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 static int __net_init nf_nat_net_init(struct net *net)
 {
 	/* Leave them the same for the moment. */
-	net->ct.nat_htable_size = net->ct.htable_size;
+	net->ct.nat_htable_size = nf_conntrack_htable_size;
 	net->ct.nat_bysource = nf_ct_alloc_hashtable(&net->ct.nat_htable_size, 0);
 	if (!net->ct.nat_bysource)
 		return -ENOMEM;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 2671b9d..3c84f14 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -306,10 +306,10 @@ static void ctnl_untimeout(struct net *net, struct ctnl_timeout *timeout)
 	int i;
 
 	local_bh_disable();
-	for (i = 0; i < net->ct.htable_size; i++) {
+	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-		if (i < net->ct.htable_size) {
-			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
+		if (i < nf_conntrack_htable_size) {
+			hlist_nulls_for_each_entry(h, nn, &nf_conntrack_hash[i], hnnode)
 				untimeout(h, timeout);
 		}
 		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-- 
2.7.3
