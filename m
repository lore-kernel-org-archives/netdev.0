From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next] netfilter: conntrack: remove the central spinlock
Date: Wed, 08 May 2013 20:04:25 -0700
Message-ID: <1368068665.13473.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37186 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab3EIDE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 23:04:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

nf_conntrack_lock is a monolithic lock and suffers from huge contention
on current generation servers (8 or more core/threads).

Split this lock into three distinct components :

1) One array of hashed spinlocks to protect insertions/deletions of
conntracks into the hash table. 1024 spinlocks seem to give good
results, at minimal cost (4KB memory).

2) One spinlock per cpu to protect dying/unconfirmed special lists.
   (These lists are now per cpu, a bit like the untracked ct)
   Add a @cpu field to nf_conn, to make sure we hold the appropriate
   spinlock at removal time.

3) One spinlock to protect the expectations : nf_conntrack_expect_lock

The hash resize is a bit tricky, because we need to take all locks in
the array. LOCKDEP being unable to currently handle this, we use
arch_spinlock_t and make sure we don't deadlock (A conntrack has two
directions and usually needs to lock two spinlocks)

A seqcount_t is used to synchronize the hash table users with the
resizing process.

Reorder struct netns_ct so that @count changes don't slowdown users of
read only fields.

Results on a 32 threads machine, 200 concurrent instances of "netperf -t
TCP_CRR" : 

~390000 tps instead of ~300000 tps.

perf top before patch :

    51.16%  [kernel]          [k] _raw_spin_lock_bh          
     1.10%  [ip_tables]       [k] ipt_do_table               
     1.00%  [nf_conntrack]    [k] tcp_packet                 
     0.76%  [kernel]          [k] nf_iterate                 
     0.71%  [kernel]          [k] _raw_spin_lock             
     0.70%  [kernel]          [k] kmem_cache_free            
     0.67%  [kernel]          [k] tcp_ack                    
     0.62%  [kernel]          [k] tcp_transmit_skb           
     0.61%  [kernel]          [k] local_bh_disable           
     0.60%  [nf_conntrack]    [k] ____nf_conntrack_find      
     0.59%  [kernel]          [k] __schedule                 
     0.57%  [kernel]          [k] __netif_receive_skb_core   
     0.55%  [kernel]          [k] tcp_v4_rcv                 
     0.50%  [kernel]          [k] local_bh_enable        

After patch :

     2.62%  [nf_conntrack]  [k] tcp_packet                 
     2.10%  [ip_tables]     [k] ipt_do_table               
     1.73%  [kernel]        [k] _raw_spin_lock             
     1.71%  [kernel]        [k] nf_iterate                 
     1.62%  [kernel]        [k] tcp_ack                    
     1.36%  [kernel]        [k] tcp_transmit_skb           
     1.28%  [kernel]        [k] __netif_receive_skb_core   
     1.28%  [nf_conntrack]  [k] __nf_conntrack_find_get    
     1.27%  [kernel]        [k] local_bh_enable            
     1.27%  [kernel]        [k] __schedule                 
     1.23%  [kernel]        [k] kmem_cache_free            
     1.22%  [kernel]        [k] local_bh_disable           
     1.15%  [kernel]        [k] tcp_v4_rcv                 
     1.06%  [nf_conntrack]  [k] nf_conntrack_in            
     1.02%  [kernel]        [k] _raw_spin_lock_bh          
     0.96%  [kernel]        [k] __inet_lookup_established  
     0.90%  [kernel]        [k] _raw_spin_lock_irqsave   


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Tom Herbert <therbert@google.com>
---
 include/net/netfilter/nf_conntrack.h      |    7 
 include/net/netfilter/nf_conntrack_core.h |    5 
 include/net/netns/conntrack.h             |   30 -
 net/netfilter/nf_conntrack_core.c         |  423 +++++++++++++-------
 net/netfilter/nf_conntrack_expect.c       |   18 
 net/netfilter/nf_conntrack_h323_main.c    |    4 
 net/netfilter/nf_conntrack_helper.c       |   37 +
 net/netfilter/nf_conntrack_netlink.c      |  128 +++---
 net/netfilter/nf_conntrack_sip.c          |    8 
 9 files changed, 427 insertions(+), 233 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 644d9c2..2311914 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -76,7 +76,8 @@ struct nf_conn {
            plus 1 for any connection(s) we are `master' for */
 	struct nf_conntrack ct_general;
 
-	spinlock_t lock;
+	spinlock_t	lock;
+	u16		cpu;
 
 	/* XXX should I move this to the tail ? - Y.K */
 	/* These are my tuples; original and reply */
@@ -176,10 +177,6 @@ extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls);
 
 extern void nf_ct_free_hashtable(void *hash, unsigned int size);
 
-extern struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple);
-
 extern int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 extern void nf_ct_delete_from_lists(struct nf_conn *ct);
 extern void nf_ct_dying_timeout(struct nf_conn *ct);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index fb2b623..51ba13e 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -84,6 +84,9 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *proto);
 
-extern spinlock_t nf_conntrack_lock ;
+#define CONNTRACK_LOCKS 1024
+extern arch_spinlock_t nf_conntrack_locks[];
+
+extern spinlock_t nf_conntrack_expect_lock ;
 
 #endif /* _NF_CONNTRACK_CORE_H */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index c9c0c53..f7db370 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -5,6 +5,7 @@
 #include <linux/list_nulls.h>
 #include <linux/atomic.h>
 #include <linux/netfilter/nf_conntrack_tcp.h>
+#include <linux/seqlock.h>
 
 struct ctl_table_header;
 struct nf_conntrack_ecache;
@@ -62,16 +63,31 @@ struct nf_ip_net {
 #endif
 };
 
+struct ct_pcpu {
+	spinlock_t		lock;
+	struct hlist_nulls_head unconfirmed;
+	struct hlist_nulls_head dying;
+};
+
 struct netns_ct {
 	atomic_t		count;
+	struct hlist_nulls_head tmpl;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header	*sysctl_header;
+	struct ctl_table_header	*acct_sysctl_header;
+	struct ctl_table_header	*tstamp_sysctl_header;
+	struct ctl_table_header	*event_sysctl_header;
+	struct ctl_table_header	*helper_sysctl_header;
+#endif
+	char			*slabname;
+
 	unsigned int		expect_count;
 	unsigned int		htable_size;
+	seqcount_t		generation;
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
-	struct hlist_nulls_head	unconfirmed;
-	struct hlist_nulls_head	dying;
-	struct hlist_nulls_head tmpl;
+	struct ct_pcpu __percpu *pcpu_lists;
 	struct ip_conntrack_stat __percpu *stat;
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
 	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
@@ -92,13 +108,5 @@ struct netns_ct {
 	struct hlist_head	*nat_bysource;
 	unsigned int		nat_htable_size;
 #endif
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header	*sysctl_header;
-	struct ctl_table_header	*acct_sysctl_header;
-	struct ctl_table_header	*tstamp_sysctl_header;
-	struct ctl_table_header	*event_sysctl_header;
-	struct ctl_table_header	*helper_sysctl_header;
-#endif
-	char			*slabname;
 };
 #endif
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0283bae..a48ec55 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -64,8 +64,57 @@ int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      unsigned int protoff);
 EXPORT_SYMBOL_GPL(nf_nat_seq_adjust_hook);
 
-DEFINE_SPINLOCK(nf_conntrack_lock);
-EXPORT_SYMBOL_GPL(nf_conntrack_lock);
+__cacheline_aligned_in_smp arch_spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
+EXPORT_SYMBOL_GPL(nf_conntrack_locks);
+
+__cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
+EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
+
+static void nf_conntrack_double_unlock(unsigned int h1, unsigned int h2)
+{
+	h1 %= CONNTRACK_LOCKS;
+	h2 %= CONNTRACK_LOCKS;
+	arch_spin_unlock(&nf_conntrack_locks[h1]);
+	if (h1 != h2)
+		arch_spin_unlock(&nf_conntrack_locks[h2]);
+}
+
+/* return true if we need to recompute hashes (in case hash table was resized) */
+static bool nf_conntrack_double_lock(struct net *net, unsigned int h1,
+				     unsigned int h2, unsigned int sequence)
+{
+	h1 %= CONNTRACK_LOCKS;
+	h2 %= CONNTRACK_LOCKS;
+	if (h1 <= h2) {
+		arch_spin_lock(&nf_conntrack_locks[h1]);
+		if (h1 != h2)
+			arch_spin_lock(&nf_conntrack_locks[h2]);
+	} else {
+		arch_spin_lock(&nf_conntrack_locks[h2]);
+		arch_spin_lock(&nf_conntrack_locks[h1]);
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
+		arch_spin_lock(&nf_conntrack_locks[i]);
+}
+
+static void nf_conntrack_all_unlock(void)
+{
+	int i;
+
+	for (i = 0; i < CONNTRACK_LOCKS; i++)
+		arch_spin_unlock(&nf_conntrack_locks[i]);
+}
 
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
@@ -196,6 +245,47 @@ clean_from_lists(struct nf_conn *ct)
 	nf_ct_remove_expectations(ct);
 }
 
+static void nf_ct_add_to_dying_list(struct nf_conn *ct)
+{
+	struct ct_pcpu *pcpu;
+
+	/* add this conntrack to the (per cpu) dying list */
+	ct->cpu = raw_smp_processor_id();
+	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
+
+	spin_lock(&pcpu->lock);
+	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
+			     &pcpu->dying);
+	spin_unlock(&pcpu->lock);
+}
+
+static void nf_ct_add_to_unconfirmed_list(struct nf_conn *ct)
+{
+	struct ct_pcpu *pcpu;
+
+	/* add this conntrack to the (per cpu) unconfirmed list */
+	ct->cpu = raw_smp_processor_id();
+	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
+
+	spin_lock(&pcpu->lock);
+	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
+			     &pcpu->unconfirmed);
+	spin_unlock(&pcpu->lock);
+}
+
+static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
+{
+	struct ct_pcpu *pcpu;
+
+	/* We overload first tuple to link into unconfirmed or dying list.*/
+	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
+
+	spin_lock(&pcpu->lock);
+	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	spin_unlock(&pcpu->lock);
+}
+
 static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
@@ -207,9 +297,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
 	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
-	/* To make sure we don't get any weird locking issues here:
-	 * destroy_conntrack() MUST NOT be called with a write lock
-	 * to nf_conntrack_lock!!! -HW */
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto && l4proto->destroy)
@@ -217,19 +304,21 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 	rcu_read_unlock();
 
-	spin_lock_bh(&nf_conntrack_lock);
-	/* Expectations will have been removed in clean_from_lists,
-	 * except TFTP can create an expectation on the first packet,
-	 * before connection is in the list, so we need to clean here,
-	 * too. */
-	nf_ct_remove_expectations(ct);
-
-	/* We overload first tuple to link into unconfirmed or dying list.*/
-	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
-	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	local_bh_disable();
+	if (nfct_help(ct)) {
+		spin_lock(&nf_conntrack_expect_lock);
+		/* Expectations will have been removed in clean_from_lists,
+		 * except TFTP can create an expectation on the first packet,
+		 * before connection is in the list, so we need to clean here,
+		 * too.
+		 */
+		nf_ct_remove_expectations(ct);
+		spin_unlock(&nf_conntrack_expect_lock);
+	}
+	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
 	NF_CT_STAT_INC(net, delete);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	if (ct->master)
 		nf_ct_put(ct->master);
@@ -241,17 +330,28 @@ destroy_conntrack(struct nf_conntrack *nfct)
 void nf_ct_delete_from_lists(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
+	unsigned int hash, repl_hash;
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
+		repl_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	} while (nf_conntrack_double_lock(net, hash, repl_hash, sequence));
+
 	clean_from_lists(ct);
-	/* add this conntrack to the dying list */
-	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-			     &net->ct.dying);
-	spin_unlock_bh(&nf_conntrack_lock);
+	nf_conntrack_double_unlock(hash, repl_hash);
+
+	nf_ct_add_to_dying_list(ct);
+
+	NF_CT_STAT_INC(net, delete_list);
+	local_bh_enable();
 }
 EXPORT_SYMBOL_GPL(nf_ct_delete_from_lists);
 
@@ -315,8 +415,6 @@ static void death_by_timeout(unsigned long ul_conntrack)
  * Warning :
  * - Caller must take a reference on returned object
  *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
- * OR
- * - Caller must lock nf_conntrack_lock before calling this function
  */
 static struct nf_conntrack_tuple_hash *
 ____nf_conntrack_find(struct net *net, u16 zone,
@@ -354,15 +452,6 @@ begin:
 	return NULL;
 }
 
-struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple)
-{
-	return ____nf_conntrack_find(net, zone, tuple,
-				     hash_conntrack_raw(tuple, zone));
-}
-EXPORT_SYMBOL_GPL(__nf_conntrack_find);
-
 /* Find a connection corresponding to a tuple. */
 static struct nf_conntrack_tuple_hash *
 __nf_conntrack_find_get(struct net *net, u16 zone,
@@ -421,14 +510,18 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	u16 zone;
+	unsigned int sequence;
 
 	zone = nf_ct_zone(ct);
-	hash = hash_conntrack(net, zone,
-			      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(net, zone,
-				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
-	spin_lock_bh(&nf_conntrack_lock);
+	local_bh_disable();
+	do {
+		sequence = read_seqcount_begin(&net->ct.generation);
+		hash = hash_conntrack(net, zone,
+				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		repl_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	} while (nf_conntrack_double_lock(net, hash, repl_hash, sequence));
 
 	/* See if there's one in the list already, including reverse */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
@@ -445,14 +538,15 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	add_timer(&ct->timeout);
 	nf_conntrack_get(&ct->ct_general);
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
+	nf_conntrack_double_unlock(hash, repl_hash);
 	NF_CT_STAT_INC(net, insert);
-	spin_unlock_bh(&nf_conntrack_lock);
-
+	local_bh_enable();
 	return 0;
 
 out:
+	nf_conntrack_double_unlock(hash, repl_hash);
 	NF_CT_STAT_INC(net, insert_failed);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 	return -EEXIST;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
@@ -470,6 +564,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
 	u16 zone;
+	unsigned int sequence;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	net = nf_ct_net(ct);
@@ -482,31 +577,37 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		return NF_ACCEPT;
 
 	zone = nf_ct_zone(ct);
-	/* reuse the hash saved before */
-	hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
-	hash = hash_bucket(hash, net);
-	repl_hash = hash_conntrack(net, zone,
-				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	local_bh_disable();
+
+	do {
+		sequence = read_seqcount_begin(&net->ct.generation);
+		/* reuse the hash saved before */
+		hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
+		hash = hash_bucket(hash, net);
+		repl_hash = hash_conntrack(net, zone,
+					   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+
+	} while (nf_conntrack_double_lock(net, hash, repl_hash, sequence));
 
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
+		nf_conntrack_double_unlock(hash, repl_hash);
+		local_bh_enable();
 		return NF_ACCEPT;
 	}
 
@@ -524,8 +625,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
-	/* Remove from unconfirmed list */
-	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
@@ -549,8 +649,9 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 * stores are visible.
 	 */
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
+	nf_conntrack_double_unlock(hash, repl_hash);
 	NF_CT_STAT_INC(net, insert);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	help = nfct_help(ct);
 	if (help && help->helper)
@@ -561,8 +662,9 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	return NF_ACCEPT;
 
 out:
+	nf_conntrack_double_unlock(hash, repl_hash);
 	NF_CT_STAT_INC(net, insert_failed);
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 	return NF_DROP;
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);
@@ -580,9 +682,6 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	u16 zone = nf_ct_zone(ignored_conntrack);
 	unsigned int hash = hash_conntrack(net, zone, tuple);
 
-	/* Disable BHs the entire time since we need to disable them at
-	 * least once for the stats anyway.
-	 */
 	rcu_read_lock_bh();
 	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
@@ -595,8 +694,8 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 		}
 		NF_CT_STAT_INC(net, searched);
 	}
-	rcu_read_unlock_bh();
 
+	rcu_read_unlock_bh();
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_tuple_taken);
@@ -605,39 +704,48 @@ EXPORT_SYMBOL_GPL(nf_conntrack_tuple_taken);
 
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
+	arch_spinlock_t *lockp;
 
-	rcu_read_lock();
-	for (i = 0; i < net->ct.htable_size; i++) {
+	local_bh_disable();
+restart:
+	sequence = read_seqcount_begin(&net->ct.generation);
+	hash = hash_bucket(_hash, net);
+	for (; i < net->ct.htable_size; i++) {
+		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
+		arch_spin_lock(lockp);
+		if (read_seqcount_retry(&net->ct.generation, sequence)) {
+			arch_spin_unlock(lockp);
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
+		arch_spin_unlock(lockp);
 
-		if (cnt >= NF_CT_EVICTION_RANGE)
+		if (ct || cnt >= NF_CT_EVICTION_RANGE)
 			break;
 
-		hash = (hash + 1) % net->ct.htable_size;
 	}
-	rcu_read_unlock();
+	local_bh_enable();
 
 	if (!ct)
 		return dropped;
@@ -689,7 +797,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		if (!early_drop(net, hash_bucket(hash, net))) {
+		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			net_warn_ratelimited("nf_conntrack: table full, dropping packet\n");
 			return ERR_PTR(-ENOMEM);
@@ -781,7 +889,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	struct nf_conn_help *help;
 	struct nf_conntrack_tuple repl_tuple;
 	struct nf_conntrack_ecache *ecache;
-	struct nf_conntrack_expect *exp;
+	struct nf_conntrack_expect *exp = NULL;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
 	struct nf_conn_timeout *timeout_ext;
 	unsigned int *timeouts;
@@ -820,39 +928,41 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 				 ecache ? ecache->expmask : 0,
 			     GFP_ATOMIC);
 
-	spin_lock_bh(&nf_conntrack_lock);
-	exp = nf_ct_find_expectation(net, zone, tuple);
-	if (exp) {
-		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
-			 ct, exp);
-		/* Welcome, Mr. Bond.  We've been expecting you... */
-		__set_bit(IPS_EXPECTED_BIT, &ct->status);
-		ct->master = exp->master;
-		if (exp->helper) {
-			help = nf_ct_helper_ext_add(ct, exp->helper,
-						    GFP_ATOMIC);
-			if (help)
-				rcu_assign_pointer(help->helper, exp->helper);
-		}
+	local_bh_disable();
+	if (net->ct.expect_count) {
+		spin_lock(&nf_conntrack_expect_lock);
+		exp = nf_ct_find_expectation(net, zone, tuple);
+		if (exp) {
+			pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
+				 ct, exp);
+			/* Welcome, Mr. Bond.  We've been expecting you... */
+			__set_bit(IPS_EXPECTED_BIT, &ct->status);
+			ct->master = exp->master;
+			if (exp->helper) {
+				help = nf_ct_helper_ext_add(ct, exp->helper,
+							    GFP_ATOMIC);
+				if (help)
+					rcu_assign_pointer(help->helper, exp->helper);
+			}
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
-		ct->mark = exp->master->mark;
+			ct->mark = exp->master->mark;
 #endif
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
-		ct->secmark = exp->master->secmark;
+			ct->secmark = exp->master->secmark;
 #endif
-		nf_conntrack_get(&ct->master->ct_general);
-		NF_CT_STAT_INC(net, expect_new);
-	} else {
+			nf_conntrack_get(&ct->master->ct_general);
+			NF_CT_STAT_INC(net, expect_new);
+		}
+		spin_unlock(&nf_conntrack_expect_lock);
+	}
+	if (!exp) {
 		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
 		NF_CT_STAT_INC(net, new);
 	}
+	nf_ct_add_to_unconfirmed_list(ct);
 
-	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-		       &net->ct.unconfirmed);
-
-	spin_unlock_bh(&nf_conntrack_lock);
+	local_bh_enable();
 
 	if (exp) {
 		if (exp->expectfn)
@@ -1218,27 +1328,42 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct hlist_nulls_node *n;
+	int cpu;
+	arch_spinlock_t *lockp;
 
-	spin_lock_bh(&nf_conntrack_lock);
 	for (; *bucket < net->ct.htable_size; (*bucket)++) {
-		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
-			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
-				continue;
+		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
+		local_bh_disable();
+		arch_spin_lock(lockp);
+		if (*bucket < net->ct.htable_size) {
+			hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
+				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
+					continue;
+				ct = nf_ct_tuplehash_to_ctrack(h);
+				if (iter(ct, data))
+					goto found;
+			}
+		}
+		arch_spin_unlock(lockp);
+		local_bh_enable();
+	}
+
+	for_each_possible_cpu(cpu) {
+		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+
+		spin_lock_bh(&pcpu->lock);
+		hlist_nulls_for_each_entry(h, n, &pcpu->unconfirmed, hnnode) {
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			if (iter(ct, data))
-				goto found;
+				set_bit(IPS_DYING_BIT, &ct->status);
 		}
+		spin_unlock_bh(&pcpu->lock);
 	}
-	hlist_nulls_for_each_entry(h, n, &net->ct.unconfirmed, hnnode) {
-		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (iter(ct, data))
-			set_bit(IPS_DYING_BIT, &ct->status);
-	}
-	spin_unlock_bh(&nf_conntrack_lock);
 	return NULL;
 found:
 	atomic_inc(&ct->ct_general.use);
-	spin_unlock_bh(&nf_conntrack_lock);
+	arch_spin_unlock(lockp);
+	local_bh_enable();
 	return ct;
 }
 
@@ -1314,14 +1439,19 @@ static void nf_ct_release_dying_list(struct net *net)
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct hlist_nulls_node *n;
+	int cpu;
 
-	spin_lock_bh(&nf_conntrack_lock);
-	hlist_nulls_for_each_entry(h, n, &net->ct.dying, hnnode) {
-		ct = nf_ct_tuplehash_to_ctrack(h);
-		/* never fails to remove them, no listeners at this point */
-		nf_ct_kill(ct);
+	for_each_possible_cpu(cpu) {
+		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+
+		spin_lock_bh(&pcpu->lock);
+		hlist_nulls_for_each_entry(h, n, &pcpu->dying, hnnode) {
+			ct = nf_ct_tuplehash_to_ctrack(h);
+			/* never fails to remove them, no listeners at this point */
+			nf_ct_kill(ct);
+		}
+		spin_unlock_bh(&pcpu->lock);
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
 }
 
 static int untrack_refs(void)
@@ -1407,6 +1537,7 @@ i_see_dead_people:
 		kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 		kfree(net->ct.slabname);
 		free_percpu(net->ct.stat);
+		free_percpu(net->ct.pcpu_lists);
 	}
 }
 
@@ -1459,12 +1590,16 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
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
@@ -1481,7 +1616,10 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 
 	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
 	init_net.ct.hash = hash;
-	spin_unlock_bh(&nf_conntrack_lock);
+
+	write_seqcount_end(&init_net.ct.generation);
+	nf_conntrack_all_unlock();
+	local_bh_enable();
 
 	nf_ct_free_hashtable(old_hash, old_size);
 	return 0;
@@ -1505,6 +1643,11 @@ int nf_conntrack_init_start(void)
 	int max_factor = 8;
 	int ret, cpu;
 
+#if 0
+	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
+		arch_spin_lock_init(&nf_conntrack_locks[i]);
+#endif
+
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
@@ -1616,37 +1759,43 @@ void nf_conntrack_init_end(void)
 
 int nf_conntrack_init_net(struct net *net)
 {
-	int ret;
+	int ret = -ENOMEM;
+	int cpu;
 
 	atomic_set(&net->ct.count, 0);
-	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, UNCONFIRMED_NULLS_VAL);
-	INIT_HLIST_NULLS_HEAD(&net->ct.dying, DYING_NULLS_VAL);
 	INIT_HLIST_NULLS_HEAD(&net->ct.tmpl, TEMPLATE_NULLS_VAL);
-	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
-	if (!net->ct.stat) {
-		ret = -ENOMEM;
+
+	net->ct.pcpu_lists = alloc_percpu(struct ct_pcpu);
+	if (!net->ct.pcpu_lists)
 		goto err_stat;
+
+	for_each_possible_cpu(cpu) {
+		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+
+		spin_lock_init(&pcpu->lock);
+		INIT_HLIST_NULLS_HEAD(&pcpu->unconfirmed, UNCONFIRMED_NULLS_VAL);
+		INIT_HLIST_NULLS_HEAD(&pcpu->dying, DYING_NULLS_VAL);
 	}
 
+	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
+	if (!net->ct.stat)
+		goto err_pcpu_lists;
+
 	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
-	if (!net->ct.slabname) {
-		ret = -ENOMEM;
+	if (!net->ct.slabname)
 		goto err_slabname;
-	}
 
 	net->ct.nf_conntrack_cachep = kmem_cache_create(net->ct.slabname,
 							sizeof(struct nf_conn), 0,
 							SLAB_DESTROY_BY_RCU, NULL);
 	if (!net->ct.nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		ret = -ENOMEM;
 		goto err_cache;
 	}
 
 	net->ct.htable_size = nf_conntrack_htable_size;
 	net->ct.hash = nf_ct_alloc_hashtable(&net->ct.htable_size, 1);
 	if (!net->ct.hash) {
-		ret = -ENOMEM;
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_hash;
 	}
@@ -1688,6 +1837,8 @@ err_cache:
 	kfree(net->ct.slabname);
 err_slabname:
 	free_percpu(net->ct.stat);
+err_pcpu_lists:
+	free_percpu(net->ct.pcpu_lists);
 err_stat:
 	return ret;
 }
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index c63b618..eacc1f7b 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -66,9 +66,9 @@ static void nf_ct_expectation_timed_out(unsigned long ul_expect)
 {
 	struct nf_conntrack_expect *exp = (void *)ul_expect;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	nf_ct_unlink_expect(exp);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_put(exp);
 }
 
@@ -217,12 +217,12 @@ static inline int expect_matches(const struct nf_conntrack_expect *a,
 /* Generally a bad idea to call this: could have matched already. */
 void nf_ct_unexpect_related(struct nf_conntrack_expect *exp)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	if (del_timer(&exp->timeout)) {
 		nf_ct_unlink_expect(exp);
 		nf_ct_expect_put(exp);
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_unexpect_related);
 
@@ -330,7 +330,7 @@ static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	setup_timer(&exp->timeout, nf_ct_expectation_timed_out,
 		    (unsigned long)exp);
 	helper = rcu_dereference_protected(master_help->helper,
-					   lockdep_is_held(&nf_conntrack_lock));
+					   lockdep_is_held(&nf_conntrack_expect_lock));
 	if (helper) {
 		exp->timeout.expires = jiffies +
 			helper->expect_policy[exp->class].timeout * HZ;
@@ -390,7 +390,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	}
 	/* Will be over limit? */
 	helper = rcu_dereference_protected(master_help->helper,
-					   lockdep_is_held(&nf_conntrack_lock));
+					   lockdep_is_held(&nf_conntrack_expect_lock));
 	if (helper) {
 		p = &helper->expect_policy[expect->class];
 		if (p->max_expected &&
@@ -417,7 +417,7 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 {
 	int ret;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	ret = __nf_ct_expect_check(expect);
 	if (ret <= 0)
 		goto out;
@@ -425,11 +425,11 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 	ret = nf_ct_expect_insert(expect);
 	if (ret < 0)
 		goto out;
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_event_report(IPEXP_NEW, expect, portid, report);
 	return ret;
 out:
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_related_report);
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index bdebd03..5b1bcdf 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1476,7 +1476,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		nf_ct_refresh(ct, skb, info->timeout * HZ);
 
 		/* Set expect timeout */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		exp = find_expect(ct, &ct->tuplehash[dir].tuple.dst.u3,
 				  info->sig_port[!dir]);
 		if (exp) {
@@ -1486,7 +1486,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 			nf_ct_dump_tuple(&exp->tuple);
 			set_expect_timeout(exp, info->timeout);
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 974a2a4..a7ad8d4 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -258,7 +258,7 @@ static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 
 	if (help && rcu_dereference_protected(
 			help->helper,
-			lockdep_is_held(&nf_conntrack_lock)
+			lockdep_is_held(&nf_conntrack_expect_lock)
 			) == me) {
 		nf_conntrack_event(IPCT_HELPER, ct);
 		RCU_INIT_POINTER(help->helper, NULL);
@@ -284,17 +284,17 @@ static LIST_HEAD(nf_ct_helper_expectfn_list);
 
 void nf_ct_helper_expectfn_register(struct nf_ct_helper_expectfn *n)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	list_add_rcu(&n->head, &nf_ct_helper_expectfn_list);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_register);
 
 void nf_ct_helper_expectfn_unregister(struct nf_ct_helper_expectfn *n)
 {
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	list_del_rcu(&n->head);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_unregister);
 
@@ -396,15 +396,17 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	const struct hlist_node *next;
 	const struct hlist_nulls_node *nn;
 	unsigned int i;
+	int cpu;
 
 	/* Get rid of expectations */
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	for (i = 0; i < nf_ct_expect_hsize; i++) {
 		hlist_for_each_entry_safe(exp, next,
 					  &net->ct.expect_hash[i], hnode) {
 			struct nf_conn_help *help = nfct_help(exp->master);
 			if ((rcu_dereference_protected(
 					help->helper,
-					lockdep_is_held(&nf_conntrack_lock)
+					lockdep_is_held(&nf_conntrack_expect_lock)
 					) == me || exp->helper == me) &&
 			    del_timer(&exp->timeout)) {
 				nf_ct_unlink_expect(exp);
@@ -412,14 +414,27 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 			}
 		}
 	}
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_nulls_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
-		unhelp(h, me);
-	for (i = 0; i < net->ct.htable_size; i++) {
-		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
+	for_each_possible_cpu(cpu) {
+		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+
+		spin_lock_bh(&pcpu->lock);
+		hlist_nulls_for_each_entry(h, nn, &pcpu->unconfirmed, hnnode)
 			unhelp(h, me);
+		spin_unlock_bh(&pcpu->lock);
+	}
+	local_bh_disable();
+	for (i = 0; i < net->ct.htable_size; i++) {
+		arch_spin_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		if (i < net->ct.htable_size) {
+			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
+				unhelp(h, me);
+		}
+		arch_spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 	}
+	local_bh_enable();
 }
 
 void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
@@ -437,10 +452,8 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	synchronize_rcu();
 
 	rtnl_lock();
-	spin_lock_bh(&nf_conntrack_lock);
 	for_each_net(net)
 		__nf_conntrack_helper_unregister(me, net);
-	spin_unlock_bh(&nf_conntrack_lock);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6d0f8a1..23aa8a3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -766,14 +766,23 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 	int res;
+	arch_spinlock_t *lockp;
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
+		arch_spin_lock(lockp);
+		if (cb->args[0] >= net->ct.htable_size) {
+			arch_spin_unlock(lockp);
+			goto out;
+		}
 		hlist_nulls_for_each_entry(h, n, &net->ct.hash[cb->args[0]],
 					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
@@ -805,16 +814,18 @@ restart:
 			if (res < 0) {
 				nf_conntrack_get(&ct->ct_general);
 				cb->args[1] = (unsigned long)ct;
+				arch_spin_unlock(lockp); 
 				goto out;
 			}
 		}
+		arch_spin_unlock(lockp); 
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
 
@@ -1145,50 +1156,65 @@ static int ctnetlink_done_list(struct netlink_callback *cb)
 }
 
 static int
-ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb,
-		    struct hlist_nulls_head *list)
+ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb, bool dying)
 {
-	struct nf_conn *ct, *last;
+	struct nf_conn *ct, *last = NULL;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 	int res;
+	int cpu;
+	struct hlist_nulls_head *list;
+	struct net *net = sock_net(skb->sk);
 
 	if (cb->args[2])
 		return 0;
 
-	spin_lock_bh(&nf_conntrack_lock);
-	last = (struct nf_conn *)cb->args[1];
-restart:
-	hlist_nulls_for_each_entry(h, n, list, hnnode) {
-		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (l3proto && nf_ct_l3num(ct) != l3proto)
+	if (cb->args[0] == nr_cpu_ids)
+		return 0;
+
+	for (cpu = cb->args[0]; cpu < nr_cpu_ids; cpu++) {
+		struct ct_pcpu *pcpu;
+
+		if (!cpu_possible(cpu))
 			continue;
-		if (cb->args[1]) {
-			if (ct != last)
+
+		pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
+		spin_lock_bh(&pcpu->lock);
+		last = (struct nf_conn *)cb->args[1];
+		list = dying ? &pcpu->dying : &pcpu->unconfirmed;
+restart:
+		hlist_nulls_for_each_entry(h, n, list, hnnode) {
+			ct = nf_ct_tuplehash_to_ctrack(h);
+			if (l3proto && nf_ct_l3num(ct) != l3proto)
 				continue;
-			cb->args[1] = 0;
-		}
-		rcu_read_lock();
-		res = ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).portid,
-					  cb->nlh->nlmsg_seq,
-					  NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
-					  ct);
-		rcu_read_unlock();
-		if (res < 0) {
-			nf_conntrack_get(&ct->ct_general);
-			cb->args[1] = (unsigned long)ct;
-			goto out;
+			if (cb->args[1]) {
+				if (ct != last)
+					continue;
+				cb->args[1] = 0;
+			}
+			rcu_read_lock();
+			res = ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).portid,
+						  cb->nlh->nlmsg_seq,
+						  NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
+						  ct);
+			rcu_read_unlock();
+			if (res < 0) {
+				nf_conntrack_get(&ct->ct_general);
+				cb->args[1] = (unsigned long)ct;
+				spin_unlock_bh(&pcpu->lock);
+				goto out;
+			}
 		}
+		if (cb->args[1]) {
+			cb->args[1] = 0;
+			goto restart;
+		} else
+			cb->args[2] = 1;
+		spin_unlock_bh(&pcpu->lock);
 	}
-	if (cb->args[1]) {
-		cb->args[1] = 0;
-		goto restart;
-	} else
-		cb->args[2] = 1;
 out:
-	spin_unlock_bh(&nf_conntrack_lock);
 	if (last)
 		nf_ct_put(last);
 
@@ -1198,9 +1224,7 @@ out:
 static int
 ctnetlink_dump_dying(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
-
-	return ctnetlink_dump_list(skb, cb, &net->ct.dying);
+	return ctnetlink_dump_list(skb, cb, true);
 }
 
 static int
@@ -1222,9 +1246,7 @@ ctnetlink_get_ct_dying(struct sock *ctnl, struct sk_buff *skb,
 static int
 ctnetlink_dump_unconfirmed(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
-
-	return ctnetlink_dump_list(skb, cb, &net->ct.unconfirmed);
+	return ctnetlink_dump_list(skb, cb, false);
 }
 
 static int
@@ -1373,14 +1395,14 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 					    nf_ct_protonum(ct));
 	if (helper == NULL) {
 #ifdef CONFIG_MODULES
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 
 		if (request_module("nfct-helper-%s", helpname) < 0) {
-			spin_lock_bh(&nf_conntrack_lock);
+			spin_lock_bh(&nf_conntrack_expect_lock);
 			return -EOPNOTSUPP;
 		}
 
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
 						    nf_ct_protonum(ct));
 		if (helper)
@@ -1818,9 +1840,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	err = -EEXIST;
 	ct = nf_ct_tuplehash_to_ctrack(h);
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		err = ctnetlink_change_conntrack(ct, cda);
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		if (err == 0) {
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
@@ -2117,9 +2139,9 @@ ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 
 	nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	ret = ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	return ret;
 }
@@ -2629,13 +2651,13 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 
 		/* after list removal, usage count == 1 */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		if (del_timer(&exp->timeout)) {
 			nf_ct_unlink_expect_report(exp, NETLINK_CB(skb).portid,
 						   nlmsg_report(nlh));
 			nf_ct_expect_put(exp);
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		/* have to put what we 'get' above.
 		 * after this line usage count == 0 */
 		nf_ct_expect_put(exp);
@@ -2644,7 +2666,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		struct nf_conn_help *m_help;
 
 		/* delete all expectations for this helper */
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
@@ -2659,10 +2681,10 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				}
 			}
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	} else {
 		/* This basically means we have to flush everything*/
-		spin_lock_bh(&nf_conntrack_lock);
+		spin_lock_bh(&nf_conntrack_expect_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
@@ -2675,7 +2697,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				}
 			}
 		}
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
 
 	return 0;
@@ -2881,11 +2903,11 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	exp = __nf_ct_expect_find(net, zone, &tuple);
 
 	if (!exp) {
-		spin_unlock_bh(&nf_conntrack_lock);
+		spin_unlock_bh(&nf_conntrack_expect_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			err = ctnetlink_create_expect(net, zone, cda,
@@ -2899,7 +2921,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	err = -EEXIST;
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL))
 		err = ctnetlink_change_expect(exp, cda);
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	return err;
 }
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index e0c4373..5564de1 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -858,7 +858,7 @@ static int refresh_signalling_expectation(struct nf_conn *ct,
 	struct hlist_node *next;
 	int found = 0;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if (exp->class != SIP_EXPECT_SIGNALLING ||
 		    !nf_inet_addr_cmp(&exp->tuple.dst.u3, addr) ||
@@ -873,7 +873,7 @@ static int refresh_signalling_expectation(struct nf_conn *ct,
 		found = 1;
 		break;
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return found;
 }
 
@@ -883,7 +883,7 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 	struct nf_conntrack_expect *exp;
 	struct hlist_node *next;
 
-	spin_lock_bh(&nf_conntrack_lock);
+	spin_lock_bh(&nf_conntrack_expect_lock);
 	hlist_for_each_entry_safe(exp, next, &help->expectations, lnode) {
 		if ((exp->class != SIP_EXPECT_SIGNALLING) ^ media)
 			continue;
@@ -894,7 +894,7 @@ static void flush_expectations(struct nf_conn *ct, bool media)
 		if (!media)
 			break;
 	}
-	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&nf_conntrack_expect_lock);
 }
 
 static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
