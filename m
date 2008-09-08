From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 17/33] netns ct: final init_net tweaks
Date: Mon,  8 Sep 2008 07:02:55 +0400
Message-ID: <1220842990-30500-18-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:60034 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbYIHDCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:02:34 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1162882muf.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:02:33 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For now just counted separatedly, not shown.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f5447f1..c955610 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -290,12 +290,12 @@ extern unsigned int nf_conntrack_htable_size;
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
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 9d5c162..fc0a46d 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -12,6 +12,7 @@ struct netns_ct {
 	struct hlist_head	*hash;
 	struct hlist_head	*expect_hash;
 	struct hlist_head	unconfirmed;
+	struct ip_conntrack_stat *stat;
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
 #endif
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index b294083..fdc85b3 100644
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
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 52d0663..342a1f3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -56,9 +56,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 unsigned int nf_ct_log_invalid __read_mostly;
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
-DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
-EXPORT_PER_CPU_SYMBOL(nf_conntrack_stat);
-
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
 
@@ -203,7 +200,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 		hlist_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode);
 	}
 
-	NF_CT_STAT_INC(delete);
+	NF_CT_STAT_INC(nf_ct_net(ct), delete);
 	spin_unlock_bh(&nf_conntrack_lock);
 
 	if (ct->master)
@@ -230,7 +227,7 @@ static void death_by_timeout(unsigned long ul_conntrack)
 	spin_lock_bh(&nf_conntrack_lock);
 	/* Inside lock so preempt is disabled on module removal path.
 	 * Otherwise we can get spurious warnings. */
-	NF_CT_STAT_INC(delete_list);
+	NF_CT_STAT_INC(nf_ct_net(ct), delete_list);
 	clean_from_lists(ct);
 	spin_unlock_bh(&nf_conntrack_lock);
 	nf_ct_put(ct);
@@ -249,11 +246,11 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
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
 
@@ -366,7 +363,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
 	set_bit(IPS_CONFIRMED_BIT, &ct->status);
-	NF_CT_STAT_INC(insert);
+	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
 	help = nfct_help(ct);
 	if (help && help->helper)
@@ -381,7 +378,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	return NF_ACCEPT;
 
 out:
-	NF_CT_STAT_INC(insert_failed);
+	NF_CT_STAT_INC(net, insert_failed);
 	spin_unlock_bh(&nf_conntrack_lock);
 	return NF_DROP;
 }
@@ -405,11 +402,11 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
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
 
@@ -454,7 +451,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	if (del_timer(&ct->timeout)) {
 		death_by_timeout((unsigned long)ct);
 		dropped = 1;
-		NF_CT_STAT_INC_ATOMIC(early_drop);
+		NF_CT_STAT_INC_ATOMIC(net, early_drop);
 	}
 	nf_ct_put(ct);
 	return dropped;
@@ -581,7 +578,7 @@ init_conntrack(struct net *net,
 		ct->secmark = exp->master->secmark;
 #endif
 		nf_conntrack_get(&ct->master->ct_general);
-		NF_CT_STAT_INC(expect_new);
+		NF_CT_STAT_INC(net, expect_new);
 	} else {
 		struct nf_conntrack_helper *helper;
 
@@ -591,7 +588,7 @@ init_conntrack(struct net *net,
 			if (help)
 				rcu_assign_pointer(help->helper, helper);
 		}
-		NF_CT_STAT_INC(new);
+		NF_CT_STAT_INC(net, new);
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
@@ -683,7 +680,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 	/* Previously seen (loopback or untracked)?  Ignore. */
 	if (skb->nfct) {
-		NF_CT_STAT_INC_ATOMIC(ignore);
+		NF_CT_STAT_INC_ATOMIC(net, ignore);
 		return NF_ACCEPT;
 	}
 
@@ -693,8 +690,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 				   &dataoff, &protonum);
 	if (ret <= 0) {
 		pr_debug("not prepared to track yet or error occured\n");
-		NF_CT_STAT_INC_ATOMIC(error);
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, error);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
 	}
 
@@ -706,8 +703,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (l4proto->error != NULL) {
 		ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum);
 		if (ret <= 0) {
-			NF_CT_STAT_INC_ATOMIC(error);
-			NF_CT_STAT_INC_ATOMIC(invalid);
+			NF_CT_STAT_INC_ATOMIC(net, error);
+			NF_CT_STAT_INC_ATOMIC(net, invalid);
 			return -ret;
 		}
 	}
@@ -716,13 +713,13 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			       l3proto, l4proto, &set_reply, &ctinfo);
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
 
@@ -735,7 +732,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
 		nf_conntrack_put(skb->nfct);
 		skb->nfct = NULL;
-		NF_CT_STAT_INC_ATOMIC(invalid);
+		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
 	}
 
@@ -1047,6 +1044,7 @@ void nf_conntrack_cleanup(struct net *net)
 	if (net_eq(net, &init_net))
 		nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini(net);
+	free_percpu(net->ct.stat);
 	if (net_eq(net, &init_net)) {
 		nf_conntrack_helper_fini();
 		nf_conntrack_proto_fini();
@@ -1164,6 +1162,9 @@ int nf_conntrack_init(struct net *net)
 		}
 	}
 	atomic_set(&net->ct.count, 0);
+	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
+	if (!net->ct.stat)
+		goto err_stat;
 	ret = nf_conntrack_ecache_init(net);
 	if (ret < 0)
 		goto err_ecache;
@@ -1241,5 +1242,7 @@ err_free_hash:
 err_hash:
 	nf_conntrack_ecache_fini(net);
 err_ecache:
+	free_percpu(net->ct.stat);
+err_stat:
 	return -ENOMEM;
 }
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index be08c87..37a703b 100644
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
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 02eaf87..a4fdbbf 100644
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
