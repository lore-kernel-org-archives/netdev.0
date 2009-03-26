From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/12: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()
Date: Thu, 26 Mar 2009 20:02:41 +0100 (MET)
Message-ID: <20090326190235.23365.6265.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit ea781f197d6a835cbb93a0bf88ee1696296ed8aa
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Mar 25 21:05:46 2009 +0100

    netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()
    
    Use "hlist_nulls" infrastructure we added in 2.6.29 for RCUification of UDP & TCP.
    
    This permits an easy conversion from call_rcu() based hash lists to a
    SLAB_DESTROY_BY_RCU one.
    
    Avoiding call_rcu() delay at nf_conn freeing time has numerous gains.
    
    First, it doesnt fill RCU queues (up to 10000 elements per cpu).
    This reduces OOM possibility, if queued elements are not taken into account
    This reduces latency problems when RCU queue size hits hilimit and triggers
    emergency mode.
    
    - It allows fast reuse of just freed elements, permitting better use of
    CPU cache.
    
    - We delete rcu_head from "struct nf_conn", shrinking size of this structure
    by 8 or 16 bytes.
    
    This patch only takes care of "struct nf_conn".
    call_rcu() is still used for less critical conntrack parts, that may
    be converted later if necessary.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 4dfb793..6c3f964 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -91,8 +91,7 @@ struct nf_conn_help {
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
-struct nf_conn
-{
+struct nf_conn {
 	/* Usage count in here is 1 for hash table/destruct timer, 1 per skb,
            plus 1 for any connection(s) we are `master' for */
 	struct nf_conntrack ct_general;
@@ -126,7 +125,6 @@ struct nf_conn
 #ifdef CONFIG_NET_NS
 	struct net *ct_net;
 #endif
-	struct rcu_head rcu;
 };
 
 static inline struct nf_conn *
@@ -190,9 +188,13 @@ static inline void nf_ct_put(struct nf_conn *ct)
 extern int nf_ct_l3proto_try_module_get(unsigned short l3proto);
 extern void nf_ct_l3proto_module_put(unsigned short l3proto);
 
-extern struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced);
-extern void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced,
-				 unsigned int size);
+/*
+ * Allocate a hashtable of hlist_head (if nulls == 0),
+ * or hlist_nulls_head (if nulls == 1)
+ */
+extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls);
+
+extern void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size);
 
 extern struct nf_conntrack_tuple_hash *
 __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple);
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index f2f6aa7..2628c15 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -12,6 +12,7 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <linux/list_nulls.h>
 
 /* A `tuple' is a structure containing the information to uniquely
   identify a connection.  ie. if two packets have the same tuple, they
@@ -146,9 +147,8 @@ static inline void nf_ct_dump_tuple(const struct nf_conntrack_tuple *t)
 	((enum ip_conntrack_dir)(h)->tuple.dst.dir)
 
 /* Connections have two entries in the hash table: one for each way */
-struct nf_conntrack_tuple_hash
-{
-	struct hlist_node hnode;
+struct nf_conntrack_tuple_hash {
+	struct hlist_nulls_node hnnode;
 	struct nf_conntrack_tuple tuple;
 };
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index f4498a6..9dc5840 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -2,6 +2,7 @@
 #define __NETNS_CONNTRACK_H
 
 #include <linux/list.h>
+#include <linux/list_nulls.h>
 #include <asm/atomic.h>
 
 struct ctl_table_header;
@@ -10,9 +11,9 @@ struct nf_conntrack_ecache;
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
-	struct hlist_head	*hash;
+	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
-	struct hlist_head	unconfirmed;
+	struct hlist_nulls_head	unconfirmed;
 	struct ip_conntrack_stat *stat;
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 6ba5c55..8668a3d 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -25,40 +25,42 @@ struct ct_iter_state {
 	unsigned int bucket;
 };
 
-static struct hlist_node *ct_get_first(struct seq_file *seq)
+static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
 	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
 		n = rcu_dereference(net->ct.hash[st->bucket].first);
-		if (n)
+		if (!is_a_nulls(n))
 			return n;
 	}
 	return NULL;
 }
 
-static struct hlist_node *ct_get_next(struct seq_file *seq,
-				      struct hlist_node *head)
+static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
+				      struct hlist_nulls_node *head)
 {
 	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
 	head = rcu_dereference(head->next);
-	while (head == NULL) {
-		if (++st->bucket >= nf_conntrack_htable_size)
-			return NULL;
+	while (is_a_nulls(head)) {
+		if (likely(get_nulls_value(head) == st->bucket)) {
+			if (++st->bucket >= nf_conntrack_htable_size)
+				return NULL;
+		}
 		head = rcu_dereference(net->ct.hash[st->bucket].first);
 	}
 	return head;
 }
 
-static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t pos)
+static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct hlist_node *head = ct_get_first(seq);
+	struct hlist_nulls_node *head = ct_get_first(seq);
 
 	if (head)
 		while (pos && (head = ct_get_next(seq, head)))
@@ -87,69 +89,76 @@ static void ct_seq_stop(struct seq_file *s, void *v)
 
 static int ct_seq_show(struct seq_file *s, void *v)
 {
-	const struct nf_conntrack_tuple_hash *hash = v;
-	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
+	struct nf_conntrack_tuple_hash *hash = v;
+	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
 	const struct nf_conntrack_l3proto *l3proto;
 	const struct nf_conntrack_l4proto *l4proto;
+	int ret = 0;
 
 	NF_CT_ASSERT(ct);
+	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		return 0;
+
 
 	/* we only want to print DIR_ORIGINAL */
 	if (NF_CT_DIRECTION(hash))
-		return 0;
+		goto release;
 	if (nf_ct_l3num(ct) != AF_INET)
-		return 0;
+		goto release;
 
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	NF_CT_ASSERT(l3proto);
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	NF_CT_ASSERT(l4proto);
 
+	ret = -ENOSPC;
 	if (seq_printf(s, "%-8s %u %ld ",
 		      l4proto->name, nf_ct_protonum(ct),
 		      timer_pending(&ct->timeout)
 		      ? (long)(ct->timeout.expires - jiffies)/HZ : 0) != 0)
-		return -ENOSPC;
+		goto release;
 
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
-		return -ENOSPC;
+		goto release;
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
-		return -ENOSPC;
+		goto release;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
 		if (seq_printf(s, "[UNREPLIED] "))
-			return -ENOSPC;
+			goto release;
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
-		return -ENOSPC;
+		goto release;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
 		if (seq_printf(s, "[ASSURED] "))
-			return -ENOSPC;
+			goto release;
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	if (seq_printf(s, "mark=%u ", ct->mark))
-		return -ENOSPC;
+		goto release;
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	if (seq_printf(s, "secmark=%u ", ct->secmark))
-		return -ENOSPC;
+		goto release;
 #endif
 
 	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
-		return -ENOSPC;
-
-	return 0;
+		goto release;
+	ret = 0;
+release:
+	nf_ct_put(ct);
+	return ret;
 }
 
 static const struct seq_operations ct_seq_ops = {
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index a65cf69..fe65187 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -679,7 +679,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 static int __net_init nf_nat_net_init(struct net *net)
 {
 	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size,
-						      &net->ipv4.nat_vmalloced);
+						      &net->ipv4.nat_vmalloced, 0);
 	if (!net->ipv4.nat_bysource)
 		return -ENOMEM;
 	return 0;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 54e983f..c55bbdc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -29,6 +29,7 @@
 #include <linux/netdevice.h>
 #include <linux/socket.h>
 #include <linux/mm.h>
+#include <linux/rculist_nulls.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -163,8 +164,8 @@ static void
 clean_from_lists(struct nf_conn *ct)
 {
 	pr_debug("clean_from_lists(%p)\n", ct);
-	hlist_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
-	hlist_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode);
 
 	/* Destroy all pending expectations */
 	nf_ct_remove_expectations(ct);
@@ -204,8 +205,8 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 	/* We overload first tuple to link into unconfirmed list. */
 	if (!nf_ct_is_confirmed(ct)) {
-		BUG_ON(hlist_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode));
-		hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
+		BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
+		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 	}
 
 	NF_CT_STAT_INC(net, delete);
@@ -242,18 +243,26 @@ static void death_by_timeout(unsigned long ul_conntrack)
 	nf_ct_put(ct);
 }
 
+/*
+ * Warning :
+ * - Caller must take a reference on returned object
+ *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
+ * OR
+ * - Caller must lock nf_conntrack_lock before calling this function
+ */
 struct nf_conntrack_tuple_hash *
 __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int hash = hash_conntrack(tuple);
 
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
 	 */
 	local_bh_disable();
-	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
+begin:
+	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(net, found);
 			local_bh_enable();
@@ -261,6 +270,13 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 		}
 		NF_CT_STAT_INC(net, searched);
 	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(n) != hash)
+		goto begin;
 	local_bh_enable();
 
 	return NULL;
@@ -275,11 +291,18 @@ nf_conntrack_find_get(struct net *net, const struct nf_conntrack_tuple *tuple)
 	struct nf_conn *ct;
 
 	rcu_read_lock();
+begin:
 	h = __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
+		else {
+			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
+				nf_ct_put(ct);
+				goto begin;
+			}
+		}
 	}
 	rcu_read_unlock();
 
@@ -293,9 +316,9 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 {
 	struct net *net = nf_ct_net(ct);
 
-	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 			   &net->ct.hash[hash]);
-	hlist_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode,
 			   &net->ct.hash[repl_hash]);
 }
 
@@ -318,7 +341,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
 
@@ -350,17 +373,17 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-	hlist_for_each_entry(h, n, &net->ct.hash[hash], hnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				      &h->tuple))
 			goto out;
-	hlist_for_each_entry(h, n, &net->ct.hash[repl_hash], hnode)
+	hlist_nulls_for_each_entry(h, n, &net->ct.hash[repl_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple))
 			goto out;
 
 	/* Remove from unconfirmed list */
-	hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
@@ -399,14 +422,14 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 {
 	struct net *net = nf_ct_net(ignored_conntrack);
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int hash = hash_conntrack(tuple);
 
 	/* Disable BHs the entire time since we need to disable them at
 	 * least once for the stats anyway.
 	 */
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
+	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		if (nf_ct_tuplehash_to_ctrack(h) != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple)) {
 			NF_CT_STAT_INC(net, found);
@@ -430,14 +453,14 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct = NULL, *tmp;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	unsigned int i, cnt = 0;
 	int dropped = 0;
 
 	rcu_read_lock();
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash],
-					 hnode) {
+		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
+					 hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
 			if (!test_bit(IPS_ASSURED_BIT, &tmp->status))
 				ct = tmp;
@@ -508,27 +531,19 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 #ifdef CONFIG_NET_NS
 	ct->ct_net = net;
 #endif
-	INIT_RCU_HEAD(&ct->rcu);
 
 	return ct;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 
-static void nf_conntrack_free_rcu(struct rcu_head *head)
-{
-	struct nf_conn *ct = container_of(head, struct nf_conn, rcu);
-
-	nf_ct_ext_free(ct);
-	kmem_cache_free(nf_conntrack_cachep, ct);
-}
-
 void nf_conntrack_free(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 
 	nf_ct_ext_destroy(ct);
 	atomic_dec(&net->ct.count);
-	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
+	nf_ct_ext_free(ct);
+	kmem_cache_free(nf_conntrack_cachep, ct);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
 
@@ -594,7 +609,7 @@ init_conntrack(struct net *net,
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
+	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 		       &net->ct.unconfirmed);
 
 	spin_unlock_bh(&nf_conntrack_lock);
@@ -934,17 +949,17 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 
 	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < nf_conntrack_htable_size; (*bucket)++) {
-		hlist_for_each_entry(h, n, &net->ct.hash[*bucket], hnode) {
+		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
 				goto found;
 		}
 	}
-	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode) {
+	hlist_nulls_for_each_entry(h, n, &net->ct.unconfirmed, hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (iter(ct, data))
 			set_bit(IPS_DYING_BIT, &ct->status);
@@ -992,7 +1007,7 @@ static int kill_all(struct nf_conn *i, void *data)
 	return 1;
 }
 
-void nf_ct_free_hashtable(struct hlist_head *hash, int vmalloced, unsigned int size)
+void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size)
 {
 	if (vmalloced)
 		vfree(hash);
@@ -1060,26 +1075,28 @@ void nf_conntrack_cleanup(struct net *net)
 	}
 }
 
-struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced)
+void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls)
 {
-	struct hlist_head *hash;
-	unsigned int size, i;
+	struct hlist_nulls_head *hash;
+	unsigned int nr_slots, i;
+	size_t sz;
 
 	*vmalloced = 0;
 
-	size = *sizep = roundup(*sizep, PAGE_SIZE / sizeof(struct hlist_head));
-	hash = (void*)__get_free_pages(GFP_KERNEL|__GFP_NOWARN,
-				       get_order(sizeof(struct hlist_head)
-						 * size));
+	BUILD_BUG_ON(sizeof(struct hlist_nulls_head) != sizeof(struct hlist_head));
+	nr_slots = *sizep = roundup(*sizep, PAGE_SIZE / sizeof(struct hlist_nulls_head));
+	sz = nr_slots * sizeof(struct hlist_nulls_head);
+	hash = (void *)__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
+					get_order(sz));
 	if (!hash) {
 		*vmalloced = 1;
 		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
-		hash = vmalloc(sizeof(struct hlist_head) * size);
+		hash = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	}
 
-	if (hash)
-		for (i = 0; i < size; i++)
-			INIT_HLIST_HEAD(&hash[i]);
+	if (hash && nulls)
+		for (i = 0; i < nr_slots; i++)
+			INIT_HLIST_NULLS_HEAD(&hash[i], i);
 
 	return hash;
 }
@@ -1090,7 +1107,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	int i, bucket, vmalloced, old_vmalloced;
 	unsigned int hashsize, old_size;
 	int rnd;
-	struct hlist_head *hash, *old_hash;
+	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
 
 	/* On boot, we can set this without any fancy locking. */
@@ -1101,7 +1118,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!hashsize)
 		return -EINVAL;
 
-	hash = nf_ct_alloc_hashtable(&hashsize, &vmalloced);
+	hash = nf_ct_alloc_hashtable(&hashsize, &vmalloced, 1);
 	if (!hash)
 		return -ENOMEM;
 
@@ -1116,12 +1133,12 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	 */
 	spin_lock_bh(&nf_conntrack_lock);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		while (!hlist_empty(&init_net.ct.hash[i])) {
-			h = hlist_entry(init_net.ct.hash[i].first,
-					struct nf_conntrack_tuple_hash, hnode);
-			hlist_del_rcu(&h->hnode);
+		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
+			h = hlist_nulls_entry(init_net.ct.hash[i].first,
+					struct nf_conntrack_tuple_hash, hnnode);
+			hlist_nulls_del_rcu(&h->hnnode);
 			bucket = __hash_conntrack(&h->tuple, hashsize, rnd);
-			hlist_add_head_rcu(&h->hnode, &hash[bucket]);
+			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
 	old_size = nf_conntrack_htable_size;
@@ -1172,7 +1189,7 @@ static int nf_conntrack_init_init_net(void)
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
-						0, 0, NULL);
+						0, SLAB_DESTROY_BY_RCU, NULL);
 	if (!nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
 		ret = -ENOMEM;
@@ -1202,7 +1219,7 @@ static int nf_conntrack_init_net(struct net *net)
 	int ret;
 
 	atomic_set(&net->ct.count, 0);
-	INIT_HLIST_HEAD(&net->ct.unconfirmed);
+	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, 0);
 	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
 	if (!net->ct.stat) {
 		ret = -ENOMEM;
@@ -1212,7 +1229,7 @@ static int nf_conntrack_init_net(struct net *net)
 	if (ret < 0)
 		goto err_ecache;
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
-						  &net->ct.hash_vmalloc);
+					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
 		ret = -ENOMEM;
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 357ba39..3940f99 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -604,7 +604,7 @@ int nf_conntrack_expect_init(struct net *net)
 
 	net->ct.expect_count = 0;
 	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
-						  &net->ct.expect_vmalloc);
+						  &net->ct.expect_vmalloc, 0);
 	if (net->ct.expect_hash == NULL)
 		goto err1;
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 805cfdd..30b8e90 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -159,6 +159,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
 	const struct hlist_node *n, *next;
+	const struct hlist_nulls_node *nn;
 	unsigned int i;
 
 	/* Get rid of expectations */
@@ -175,10 +176,10 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode)
+	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry(h, n, &net->ct.hash[i], hnode)
+		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 			unhelp(h, me);
 	}
 }
@@ -218,7 +219,7 @@ int nf_conntrack_helper_init(void)
 
 	nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
 	nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize,
-						  &nf_ct_helper_vmalloc);
+						  &nf_ct_helper_vmalloc, 0);
 	if (!nf_ct_helper_hash)
 		return -ENOMEM;
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1b75c9e..349bbef 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/rculist.h>
+#include <linux/rculist_nulls.h>
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/skbuff.h>
@@ -536,7 +537,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = NLMSG_DATA(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 
@@ -544,27 +545,27 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
-		hlist_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
-					 hnode) {
+		hlist_nulls_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
+					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
 			ct = nf_ct_tuplehash_to_ctrack(h);
+			if (!atomic_inc_not_zero(&ct->ct_general.use))
+				continue;
 			/* Dump entries of a given L3 protocol number.
 			 * If it is not specified, ie. l3proto == 0,
 			 * then dump everything. */
 			if (l3proto && nf_ct_l3num(ct) != l3proto)
-				continue;
+				goto releasect;
 			if (cb->args[1]) {
 				if (ct != last)
-					continue;
+					goto releasect;
 				cb->args[1] = 0;
 			}
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
 						IPCTNL_MSG_CT_NEW,
 						1, ct) < 0) {
-				if (!atomic_inc_not_zero(&ct->ct_general.use))
-					continue;
 				cb->args[1] = (unsigned long)ct;
 				goto out;
 			}
@@ -577,6 +578,8 @@ restart:
 				if (acct)
 					memset(acct, 0, sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]));
 			}
+releasect:
+		nf_ct_put(ct);
 		}
 		if (cb->args[1]) {
 			cb->args[1] = 0;
@@ -1242,13 +1245,12 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		if (err < 0)
 			goto err2;
 
-		master_h = __nf_conntrack_find(&init_net, &master);
+		master_h = nf_conntrack_find_get(&init_net, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
 			goto err2;
 		}
 		master_ct = nf_ct_tuplehash_to_ctrack(master_h);
-		nf_conntrack_get(&master_ct->ct_general);
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
 		ct->master = master_ct;
 	}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 4da54b0..1935153 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -44,40 +44,42 @@ struct ct_iter_state {
 	unsigned int bucket;
 };
 
-static struct hlist_node *ct_get_first(struct seq_file *seq)
+static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 {
 	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
-	struct hlist_node *n;
+	struct hlist_nulls_node *n;
 
 	for (st->bucket = 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
 		n = rcu_dereference(net->ct.hash[st->bucket].first);
-		if (n)
+		if (!is_a_nulls(n))
 			return n;
 	}
 	return NULL;
 }
 
-static struct hlist_node *ct_get_next(struct seq_file *seq,
-				      struct hlist_node *head)
+static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
+				      struct hlist_nulls_node *head)
 {
 	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
 	head = rcu_dereference(head->next);
-	while (head == NULL) {
-		if (++st->bucket >= nf_conntrack_htable_size)
-			return NULL;
+	while (is_a_nulls(head)) {
+		if (likely(get_nulls_value(head) == st->bucket)) {
+			if (++st->bucket >= nf_conntrack_htable_size)
+				return NULL;
+		}
 		head = rcu_dereference(net->ct.hash[st->bucket].first);
 	}
 	return head;
 }
 
-static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t pos)
+static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_t pos)
 {
-	struct hlist_node *head = ct_get_first(seq);
+	struct hlist_nulls_node *head = ct_get_first(seq);
 
 	if (head)
 		while (pos && (head = ct_get_next(seq, head)))
@@ -107,67 +109,74 @@ static void ct_seq_stop(struct seq_file *s, void *v)
 /* return 0 on success, 1 in case of error */
 static int ct_seq_show(struct seq_file *s, void *v)
 {
-	const struct nf_conntrack_tuple_hash *hash = v;
-	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
+	struct nf_conntrack_tuple_hash *hash = v;
+	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
 	const struct nf_conntrack_l3proto *l3proto;
 	const struct nf_conntrack_l4proto *l4proto;
+	int ret = 0;
 
 	NF_CT_ASSERT(ct);
+	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		return 0;
 
 	/* we only want to print DIR_ORIGINAL */
 	if (NF_CT_DIRECTION(hash))
-		return 0;
+		goto release;
 
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	NF_CT_ASSERT(l3proto);
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	NF_CT_ASSERT(l4proto);
 
+	ret = -ENOSPC;
 	if (seq_printf(s, "%-8s %u %-8s %u %ld ",
 		       l3proto->name, nf_ct_l3num(ct),
 		       l4proto->name, nf_ct_protonum(ct),
 		       timer_pending(&ct->timeout)
 		       ? (long)(ct->timeout.expires - jiffies)/HZ : 0) != 0)
-		return -ENOSPC;
+		goto release;
 
 	if (l4proto->print_conntrack && l4proto->print_conntrack(s, ct))
-		return -ENOSPC;
+		goto release;
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_ORIGINAL))
-		return -ENOSPC;
+		goto release;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
 		if (seq_printf(s, "[UNREPLIED] "))
-			return -ENOSPC;
+			goto release;
 
 	if (print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 			l3proto, l4proto))
-		return -ENOSPC;
+		goto release;
 
 	if (seq_print_acct(s, ct, IP_CT_DIR_REPLY))
-		return -ENOSPC;
+		goto release;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
 		if (seq_printf(s, "[ASSURED] "))
-			return -ENOSPC;
+			goto release;
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (seq_printf(s, "mark=%u ", ct->mark))
-		return -ENOSPC;
+		goto release;
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	if (seq_printf(s, "secmark=%u ", ct->secmark))
-		return -ENOSPC;
+		goto release;
 #endif
 
 	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
-		return -ENOSPC;
+		goto release;
 
+	ret = 0;
+release:
+	nf_ct_put(ct);
 	return 0;
 }
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 7f404cc..6809809 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -108,7 +108,7 @@ static int count_them(struct xt_connlimit_data *data,
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
 	struct xt_connlimit_conn *tmp;
-	const struct nf_conn *found_ct;
+	struct nf_conn *found_ct;
 	struct list_head *hash;
 	bool addit = true;
 	int matches = 0;
@@ -123,7 +123,7 @@ static int count_them(struct xt_connlimit_data *data,
 
 	/* check the saved connections */
 	list_for_each_entry_safe(conn, tmp, hash, list) {
-		found    = __nf_conntrack_find(&init_net, &conn->tuple);
+		found    = nf_conntrack_find_get(&init_net, &conn->tuple);
 		found_ct = NULL;
 
 		if (found != NULL)
@@ -151,6 +151,7 @@ static int count_them(struct xt_connlimit_data *data,
 			 * we do not care about connections which are
 			 * closed already -> ditch it
 			 */
+			nf_ct_put(found_ct);
 			list_del(&conn->list);
 			kfree(conn);
 			continue;
@@ -160,6 +161,7 @@ static int count_them(struct xt_connlimit_data *data,
 		    match->family))
 			/* same source network -> be counted! */
 			++matches;
+		nf_ct_put(found_ct);
 	}
 
 	rcu_read_unlock();
