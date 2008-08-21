From: adobriyan@gmail.com
Subject: [PATCH 23/38] netns ct: per-netns statistics
Date: Fri, 22 Aug 2008 02:05:37 +0400
Message-ID: <20080821220537.GW31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h                  |    8 +--
 include/net/netns/conntrack.h                         |    1 
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 -
 net/netfilter/nf_conntrack_core.c                     |   47 +++++++++---------
 net/netfilter/nf_conntrack_expect.c                   |    4 -
 net/netfilter/nf_conntrack_standalone.c               |    5 -
 6 files changed, 36 insertions(+), 33 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -285,12 +285,12 @@ extern unsigned int nf_conntrack_htable_size;
 extern int nf_conntrack_checksum;
 extern int nf_conntrack_max;
 
-DECLARE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
-#define NF_CT_STAT_INC(count) (__get_cpu_var(nf_conntrack_stat).count++)
-#define NF_CT_STAT_INC_ATOMIC(count)			\
+#define NF_CT_STAT_INC(net, count)	\
+	(per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++)
+#define NF_CT_STAT_INC_ATOMIC(net, count)		\
 do {							\
 	local_bh_disable();				\
-	__get_cpu_var(nf_conntrack_stat).count++;	\
+	per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++;	\
 	local_bh_enable();				\
 } while (0)
 
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -17,6 +17,7 @@ struct netns_ct {
 	struct hlist_head	unconfirmed;
 	/* Fake conntrack entry for untracked connections */
 	struct nf_conn		untracked;
+	struct ip_conntrack_stat *stat;
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -294,7 +294,7 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
-		return &per_cpu(nf_conntrack_stat, cpu);
+		return per_cpu_ptr(init_net.ct.stat, cpu);
 	}
 
 	return NULL;
@@ -308,7 +308,7 @@ static void *ct_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
-		return &per_cpu(nf_conntrack_stat, cpu);
+		return per_cpu_ptr(init_net.ct.stat, cpu);
 	}
 
 	return NULL;
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -53,9 +53,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 unsigned int nf_ct_log_invalid __read_mostly;
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
-DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
-EXPORT_PER_CPU_SYMBOL(nf_conntrack_stat);
-
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
 
@@ -200,7 +197,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 		hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
 	}
 
-	NF_CT_STAT_INC(delete);
+	NF_CT_STAT_INC(nf_ct_net(ct), delete);
 	spin_unlock_bh(&nf_conntrack_lock);
 
 	if (ct->master)
@@ -227,7 +224,7 @@ static void death_by_timeout(unsigned long ul_conntrack)
 	spin_lock_bh(&nf_conntrack_lock);
 	/* Inside lock so preempt is disabled on module removal path.
 	 * Otherwise we can get spurious warnings. */
-	NF_CT_STAT_INC(delete_list);
+	NF_CT_STAT_INC(nf_ct_net(ct), delete_list);
 	clean_from_lists(ct);
 	spin_unlock_bh(&nf_conntrack_lock);
 	nf_ct_put(ct);
@@ -246,11 +243,11 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 	local_bh_disable();
 	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
-			NF_CT_STAT_INC(found);
+			NF_CT_STAT_INC(net, found);
 			local_bh_enable();
 			return h;
 		}
-		NF_CT_STAT_INC(searched);
+		NF_CT_STAT_INC(net, searched);
 	}
 	local_bh_enable();
 
@@ -363,7 +360,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
 	set_bit(IPS_CONFIRMED_BIT, &ct->status);
-	NF_CT_STAT_INC(insert);
+	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
 	help = nfct_help(ct);
 	if (help && help->helper)
@@ -378,7 +375,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	return NF_ACCEPT;
 
 out:
-	NF_CT_STAT_INC(insert_failed);
+	NF_CT_STAT_INC(net, insert_failed);
 	spin_unlock_bh(&nf_conntrack_lock);
 	return NF_DROP;
 }
@@ -402,11 +399,11 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	hlist_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnode) {
 		if (nf_ct_tuplehash_to_ctrack(h) != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple)) {
-			NF_CT_STAT_INC(found);
+			NF_CT_STAT_INC(net, found);
 			rcu_read_unlock_bh();
 			return 1;
 		}
-		NF_CT_STAT_INC(searched);
+		NF_CT_STAT_INC(net, searched);
 	}
 	rcu_read_unlock_bh();
 
@@ -451,7 +448,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	if (del_timer(&ct->timeout)) {
 		death_by_timeout((unsigned long)ct);
 		dropped = 1;
-		NF_CT_STAT_INC_ATOMIC(early_drop);
+		NF_CT_STAT_INC_ATOMIC(net, early_drop);
 	}
 	nf_ct_put(ct);
 	return dropped;
@@ -578,7 +575,7 @@ init_conntrack(struct net *net,
 		ct->secmark = exp->master->secmark;
 #endif
 		nf_conntrack_get(&ct->master->ct_general);
-		NF_CT_STAT_INC(expect_new);
+		NF_CT_STAT_INC(net, expect_new);
 	} else {
 		struct nf_conntrack_helper *helper;
 
@@ -588,7 +585,7 @@ init_conntrack(struct net *net,
 			if (help)
 				rcu_assign_pointer(help->helper, helper);
 		}
-		NF_CT_STAT_INC(new);
+		NF_CT_STAT_INC(net, new);
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
@@ -677,7 +674,7 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 
 	/* Previously seen (loopback or untracked)?  Ignore. */
 	if (skb->nfct) {
-		NF_CT_STAT_INC_ATOMIC(ignore);
+		NF_CT_STAT_INC_ATOMIC(net, ignore);
 		return NF_ACCEPT;
 	}
 
@@ -687,8 +684,8 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 				   &dataoff, &protonum);
 	if (ret <= 0) {
 		pr_debug("not prepared to track yet or error occured\n");
-		NF_CT_STAT_INC_ATOMIC(error);
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, error);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
 	}
 
@@ -699,8 +696,8 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL &&
 	    (ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
-		NF_CT_STAT_INC_ATOMIC(error);
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, error);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
 	}
 
@@ -708,13 +705,13 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 			       &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return NF_ACCEPT;
 	}
 
 	if (IS_ERR(ct)) {
 		/* Too stressed to deal. */
-		NF_CT_STAT_INC_ATOMIC(drop);
+		NF_CT_STAT_INC_ATOMIC(net, drop);
 		return NF_DROP;
 	}
 
@@ -727,7 +724,7 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
 		nf_conntrack_put(skb->nfct);
 		skb->nfct = NULL;
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
 	}
 
@@ -1039,6 +1036,7 @@ void nf_conntrack_cleanup(struct net *net)
 	if (net_eq(net, &init_net))
 		nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini(net);
+	free_percpu(net->ct.stat);
 	if (net_eq(net, &init_net)) {
 		nf_conntrack_helper_fini();
 		nf_conntrack_proto_fini();
@@ -1156,6 +1154,9 @@ int nf_conntrack_init(struct net *net)
 		}
 	}
 	atomic_set(&net->ct.count, 0);
+	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
+	if (!net->ct.stat)
+		goto err_stat;
 	ret = nf_conntrack_ecache_init(net);
 	if (ret < 0)
 		goto err_ecache;
@@ -1233,5 +1234,7 @@ err_free_hash:
 err_hash:
 	nf_conntrack_ecache_fini(net);
 err_ecache:
+	free_percpu(net->ct.stat);
+err_stat:
 	return -ENOMEM;
 }
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -53,7 +53,7 @@ void nf_ct_unlink_expect(struct nf_conntrack_expect *exp)
 	master_help->expecting[exp->class]--;
 	nf_ct_expect_put(exp);
 
-	NF_CT_STAT_INC(expect_delete);
+	NF_CT_STAT_INC(net, expect_delete);
 }
 EXPORT_SYMBOL_GPL(nf_ct_unlink_expect);
 
@@ -326,7 +326,7 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	add_timer(&exp->timeout);
 
 	atomic_inc(&exp->use);
-	NF_CT_STAT_INC(expect_create);
+	NF_CT_STAT_INC(net, expect_create);
 }
 
 /* Race with expectations being used means we could have none to find; OK. */
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -203,7 +203,7 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
-		return &per_cpu(nf_conntrack_stat, cpu);
+		return per_cpu_ptr(init_net.ct.stat, cpu);
 	}
 
 	return NULL;
@@ -217,7 +217,7 @@ static void *ct_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
-		return &per_cpu(nf_conntrack_stat, cpu);
+		return per_cpu_ptr(init_net.ct.stat, cpu);
 	}
 
 	return NULL;
-- 
1.5.6.3


