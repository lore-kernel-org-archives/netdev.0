From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/38] netfilter: conntrack: remove central spinlock nf_conntrack_lock
Date: Mon, 17 Mar 2014 13:42:44 +0100
Message-ID: <1395060178-11833-25-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59476 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933155AbaCQMnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:42 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

nf_conntrack_lock is a monolithic lock and suffers from huge contention
on current generation servers (8 or more core/threads).

Perf locking congestion is clear on base kernel:

-  72.56%  ksoftirqd/6  [kernel.kallsyms]    [k] _raw_spin_lock_bh
   - _raw_spin_lock_bh
      + 25.33% init_conntrack
      + 24.86% nf_ct_delete_from_lists
      + 24.62% __nf_conntrack_confirm
      + 24.38% destroy_conntrack
      + 0.70% tcp_packet
+   2.21%  ksoftirqd/6  [kernel.kallsyms]    [k] fib_table_lookup
+   1.15%  ksoftirqd/6  [kernel.kallsyms]    [k] __slab_free
+   0.77%  ksoftirqd/6  [kernel.kallsyms]    [k] inet_getpeer
+   0.70%  ksoftirqd/6  [nf_conntrack]       [k] nf_ct_delete
+   0.55%  ksoftirqd/6  [ip_tables]          [k] ipt_do_table

This patch change conntrack locking and provides a huge performance
improvement.  SYN-flood attack tested on a 24-core E5-2695v2(ES) with
10Gbit/s ixgbe (with tool trafgen):

 Base kernel:   810.405 new conntrack/sec
 After patch: 2.233.876 new conntrack/sec

Notice other floods attack (SYN+ACK or ACK) can easily be deflected using:
 # iptables -A INPUT -m state --state INVALID -j DROP
 # sysctl -w net/netfilter/nf_conntrack_tcp_loose=0

Use an array of hashed spinlocks to protect insertions/deletions of
conntracks into the hash table. 1024 spinlocks seem to give good
results, at minimal cost (4KB memory). Due to lockdep max depth,
1024 becomes 8 if CONFIG_LOCKDEP=y

The hash resize is a bit tricky, because we need to take all locks in
the array. A seqcount_t is used to synchronize the hash table users
with the resizing process.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    7 +-
 include/net/netns/conntrack.h             |    2 +
 net/netfilter/nf_conntrack_core.c         |  219 +++++++++++++++++++++--------
 net/netfilter/nf_conntrack_helper.c       |   12 +-
 net/netfilter/nf_conntrack_netlink.c      |   15 +-
 5 files changed, 188 insertions(+), 67 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index d12a631..cc0c188 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -77,7 +77,12 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *proto);
 
-extern spinlock_t nf_conntrack_lock ;
+#ifdef CONFIG_LOCKDEP
+# define CONNTRACK_LOCKS 8
+#else
+# define CONNTRACK_LOCKS 1024
+#endif
+extern spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
 
 extern spinlock_t nf_conntrack_expect_lock;
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index c6a8994..773cce3 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -5,6 +5,7 @@
 #include <linux/list_nulls.h>
 #include <linux/atomic.h>
 #include <linux/netfilter/nf_conntrack_tcp.h>
+#include <linux/seqlock.h>
 
 struct ctl_table_header;
 struct nf_conntrack_ecache;
@@ -90,6 +91,7 @@ struct netns_ct {
 	int			sysctl_checksum;
 
 	unsigned int		htable_size;
+	seqcount_t		generation;
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 4cdf1ad..5d1e7d1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -60,12 +60,60 @@ int (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
 				      const struct nlattr *attr) __read_mostly;
 EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
 
-DEFINE_SPINLOCK(nf_conntrack_lock);
-EXPORT_SYMBOL_GPL(nf_conntrack_lock);
+__cacheline_aligned_in_smp spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
+EXPORT_SYMBOL_GPL(nf_conntrack_locks);
 
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 
+static void nf_conntrack_double_unlock(unsigned int h1, unsigned int h2)
+{
+	h1 %= CONNTRACK_LOCKS;
+	h2 %= CONNTRACK_LOCKS;
+	spin_unlock(&nf_conntrack_locks[h1]);
+	if (h1 != h2)
+		spin_unlock(&nf_conntrack_locks[h2]);
+}
+
+/* return true if we need to recompute hashes (in case hash table was resized) */
+static bool nf_conntrack_double_lock(struct net *net, unsigned int h1,
+				     unsigned int h2, unsigned int sequence)
+{
+	h1 %= CONNTRACK_LOCKS;
+	h2 %= CONNTRACK_LOCKS;
+	if (h1 <= h2) {
+		spin_lock(&nf_conntrack_locks[h1]);
+		if (h1 != h2)
+			spin_lock_nested(&nf_conntrack_locks[h2],
+					 SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock(&nf_conntrack_locks[h2]);
+		spin_lock_nested(&nf_conntrack_locks[h1],
+				 SINGLE_DEPTH_NESTING);
+	}
+	if (read_seqcount_retry(&net->ct.generation, sequence)) {
+		nf_conntrack_double_unlock(h1, h2);
+		return true;
+	}
+	return false;
+}
+
+static void nf_conntrack_all_lock(void)
+{
+	int i;
+
+	for (i = 0; i < CONNTRACK_LOCKS; i++)
+		spin_lock_nested(&nf_conntrack_locks[i], i);
+}
+
+static void nf_conntrack_all_unlock(void)
+{
+	int i;
+
+	for (i = 0; i < CONNTRACK_LOCKS; i++)
+		spin_unlock(&nf_conntrack_locks[i]);
+}
+
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
@@ -280,15 +328,28 @@ destroy_conntrack(struct nf_conntrack *nfct)
 static void nf_ct_delete_from_lists(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
+	unsigned int hash, reply_hash;
+	u16 zone = nf_ct_zone(ct);
+	unsigned int sequence;
 
 	nf_ct_helper_destroy(ct);
-	spin_lock_bh(&nf_conntrack_lock);
-	/* Inside lock so preempt is disabled on module removal path.
-	 * Otherwise we can get spurious warnings. */
-	NF_CT_STAT_INC(net, delete_list);
+
+	local_bh_disable();
+	do {
+		sequence = read_seqcount_begin(&net->ct.generation);
+		hash = hash_conntrack(net, zone,
+				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		reply_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	} while (nf_conntrack_double_lock(net, hash, reply_hash, sequence));
+
 	clean_from_lists(ct);
+	nf_conntrack_double_unlock(hash, reply_hash);
+
 	nf_ct_add_to_dying_list(ct);
-	spin_unlock_bh(&nf_conntrack_lock);
+
+	NF_CT_STAT_INC(net, delete_list);
+	local_bh_enable();
 }
 
 static void death_by_event(unsigned long ul_conntrack)
@@ -372,8 +433,6 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
  * Warning :
  * - Caller must take a reference on returned object
  *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
- * OR
- * - Caller must lock nf_conntrack_lock before calling this function
  */
 static struct nf_conntrack_tuple_hash *
 ____nf_conntrack_find(struct net *net, u16 zone,
@@ -467,14 +526,18 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	u16 zone;
+	unsigned int sequence;
 
 	zone = nf_ct_zone(ct);
-	hash = hash_conntrack(net, zone,
-			      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	reply_hash = hash_conntrack(net, zone,
-				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
-	spin_lock_bh(&nf_conntrack_lock);
+	local_bh_disable();
+	do {
+		sequence = read_seqcount_begin(&net->ct.generation);
+		hash = hash_conntrack(net, zone,
+				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		reply_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	} while (nf_conntrack_double_lock(net, hash, reply_hash, sequence));
 
 	/* See if there's one in the list already, including reverse */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
@@ -493,14 +556,15 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	/* The caller holds a reference to this object */
 	atomic_set(&ct->ct_general.use, 2);
 	__nf_conntrack_hash_insert(ct, hash, reply_hash);
+	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert);
-	spin_unlock_bh(&nf_conntrack_lock);
-
+	local_bh_enable();
 	return 0;
 
 out:
+	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert_failed);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 	return -EEXIST;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
@@ -540,6 +604,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
 	u16 zone;
+	unsigned int sequence;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	net = nf_ct_net(ct);
@@ -552,31 +617,37 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		return NF_ACCEPT;
 
 	zone = nf_ct_zone(ct);
-	/* reuse the hash saved before */
-	hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
-	hash = hash_bucket(hash, net);
-	reply_hash = hash_conntrack(net, zone,
-				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	local_bh_disable();
+
+	do {
+		sequence = read_seqcount_begin(&net->ct.generation);
+		/* reuse the hash saved before */
+		hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
+		hash = hash_bucket(hash, net);
+		reply_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+
+	} while (nf_conntrack_double_lock(net, hash, reply_hash, sequence));
 
 	/* We're not in hash table, and we refuse to set up related
-	   connections for unconfirmed conns.  But packet copies and
-	   REJECT will give spurious warnings here. */
+	 * connections for unconfirmed conns.  But packet copies and
+	 * REJECT will give spurious warnings here.
+	 */
 	/* NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 1); */
 
 	/* No external references means no one else could have
-	   confirmed us. */
+	 * confirmed us.
+	 */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 	pr_debug("Confirming conntrack %p\n", ct);
-
-	spin_lock_bh(&nf_conntrack_lock);
-
 	/* We have to check the DYING flag inside the lock to prevent
 	   a race against nf_ct_get_next_corpse() possibly called from
 	   user context, else we insert an already 'dead' hash, blocking
 	   further use of that particular connection -JM */
 
 	if (unlikely(nf_ct_is_dying(ct))) {
-		spin_unlock_bh(&nf_conntrack_lock);
+		nf_conntrack_double_unlock(hash, reply_hash);
+		local_bh_enable();
 		return NF_ACCEPT;
 	}
 
@@ -618,8 +689,9 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 * stores are visible.
 	 */
 	__nf_conntrack_hash_insert(ct, hash, reply_hash);
+	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	help = nfct_help(ct);
 	if (help && help->helper)
@@ -630,8 +702,9 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	return NF_ACCEPT;
 
 out:
+	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert_failed);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 	return NF_DROP;
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);
@@ -674,39 +747,48 @@ EXPORT_SYMBOL_GPL(nf_conntrack_tuple_taken);
 
 /* There's a small race here where we may free a just-assured
    connection.  Too bad: we're in trouble anyway. */
-static noinline int early_drop(struct net *net, unsigned int hash)
+static noinline int early_drop(struct net *net, unsigned int _hash)
 {
 	/* Use oldest entry, which is roughly LRU */
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct = NULL, *tmp;
 	struct hlist_nulls_node *n;
-	unsigned int i, cnt = 0;
+	unsigned int i = 0, cnt = 0;
 	int dropped = 0;
+	unsigned int hash, sequence;
+	spinlock_t *lockp;
 
-	rcu_read_lock();
-	for (i = 0; i < net->ct.htable_size; i++) {
+	local_bh_disable();
+restart:
+	sequence = read_seqcount_begin(&net->ct.generation);
+	hash = hash_bucket(_hash, net);
+	for (; i < net->ct.htable_size; i++) {
+		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
+		spin_lock(lockp);
+		if (read_seqcount_retry(&net->ct.generation, sequence)) {
+			spin_unlock(lockp);
+			goto restart;
+		}
 		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
 					 hnnode) {
 			tmp = nf_ct_tuplehash_to_ctrack(h);
-			if (!test_bit(IPS_ASSURED_BIT, &tmp->status))
+			if (!test_bit(IPS_ASSURED_BIT, &tmp->status) &&
+			    !nf_ct_is_dying(tmp) &&
+			    atomic_inc_not_zero(&tmp->ct_general.use)) {
 				ct = tmp;
+				break;
+			}
 			cnt++;
 		}
 
-		if (ct != NULL) {
-			if (likely(!nf_ct_is_dying(ct) &&
-				   atomic_inc_not_zero(&ct->ct_general.use)))
-				break;
-			else
-				ct = NULL;
-		}
+		hash = (hash + 1) % net->ct.htable_size;
+		spin_unlock(lockp);
 
-		if (cnt >= NF_CT_EVICTION_RANGE)
+		if (ct || cnt >= NF_CT_EVICTION_RANGE)
 			break;
 
-		hash = (hash + 1) % net->ct.htable_size;
 	}
-	rcu_read_unlock();
+	local_bh_enable();
 
 	if (!ct)
 		return dropped;
@@ -755,7 +837,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		if (!early_drop(net, hash_bucket(hash, net))) {
+		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			net_warn_ratelimited("nf_conntrack: table full, dropping packet\n");
 			return ERR_PTR(-ENOMEM);
@@ -1304,18 +1386,24 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	struct nf_conn *ct;
 	struct hlist_nulls_node *n;
 	int cpu;
+	spinlock_t *lockp;
 
-	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < net->ct.htable_size; (*bucket)++) {
-		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
-			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
-				continue;
-			ct = nf_ct_tuplehash_to_ctrack(h);
-			if (iter(ct, data))
-				goto found;
+		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
+		local_bh_disable();
+		spin_lock(lockp);
+		if (*bucket < net->ct.htable_size) {
+			hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
+				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
+					continue;
+				ct = nf_ct_tuplehash_to_ctrack(h);
+				if (iter(ct, data))
+					goto found;
+			}
 		}
+		spin_unlock(lockp);
+		local_bh_enable();
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
 
 	for_each_possible_cpu(cpu) {
 		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
@@ -1331,7 +1419,8 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	return NULL;
 found:
 	atomic_inc(&ct->ct_general.use);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock(lockp);
+	local_bh_enable();
 	return ct;
 }
 
@@ -1532,12 +1621,16 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!hash)
 		return -ENOMEM;
 
+	local_bh_disable();
+	nf_conntrack_all_lock();
+	write_seqcount_begin(&init_net.ct.generation);
+
 	/* Lookups in the old hash might happen in parallel, which means we
 	 * might get false negatives during connection lookup. New connections
 	 * created because of a false negative won't make it into the hash
-	 * though since that required taking the lock.
+	 * though since that required taking the locks.
 	 */
-	spin_lock_bh(&nf_conntrack_lock);
+
 	for (i = 0; i < init_net.ct.htable_size; i++) {
 		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
 			h = hlist_nulls_entry(init_net.ct.hash[i].first,
@@ -1554,7 +1647,10 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 
 	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
 	init_net.ct.hash = hash;
-	spin_unlock_bh(&nf_conntrack_lock);
+
+	write_seqcount_end(&init_net.ct.generation);
+	nf_conntrack_all_unlock();
+	local_bh_enable();
 
 	nf_ct_free_hashtable(old_hash, old_size);
 	return 0;
@@ -1576,7 +1672,10 @@ EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
 int nf_conntrack_init_start(void)
 {
 	int max_factor = 8;
-	int ret, cpu;
+	int i, ret, cpu;
+
+	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
+		spin_lock_init(&nf_conntrack_locks[i]);
 
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 29bd704..5b3eae7 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -423,12 +423,16 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 			unhelp(h, me);
 		spin_unlock_bh(&pcpu->lock);
 	}
-	spin_lock_bh(&nf_conntrack_lock);
+	local_bh_disable();
 	for (i = 0; i < net->ct.htable_size; i++) {
-		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
-			unhelp(h, me);
+		spin_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		if (i < net->ct.htable_size) {
+			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
+				unhelp(h, me);
+		}
+		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 }
 
 void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index be4d1b0..8d778a9 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -764,14 +764,23 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 	int res;
+	spinlock_t *lockp;
+
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	const struct ctnetlink_dump_filter *filter = cb->data;
 #endif
 
-	spin_lock_bh(&nf_conntrack_lock);
 	last = (struct nf_conn *)cb->args[1];
+
+	local_bh_disable();
 	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
 restart:
+		lockp = &nf_conntrack_locks[cb->args[0] % CONNTRACK_LOCKS];
+		spin_lock(lockp);
+		if (cb->args[0] >= net->ct.htable_size) {
+			spin_unlock(lockp);
+			goto out;
+		}
 		hlist_nulls_for_each_entry(h, n, &net->ct.hash[cb->args[0]],
 					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
@@ -803,16 +812,18 @@ restart:
 			if (res < 0) {
 				nf_conntrack_get(&ct->ct_general);
 				cb->args[1] = (unsigned long)ct;
+				spin_unlock(lockp);
 				goto out;
 			}
 		}
+		spin_unlock(lockp);
 		if (cb->args[1]) {
 			cb->args[1] = 0;
 			goto restart;
 		}
 	}
 out:
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 	if (last)
 		nf_ct_put(last);
 
-- 
1.7.10.4
