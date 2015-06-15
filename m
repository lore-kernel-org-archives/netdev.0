From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/32] netfilter: xtables: use percpu rule counters
Date: Mon, 15 Jun 2015 23:26:08 +0200
Message-ID: <1434403589-24796-12-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The binary arp/ip/ip6tables ruleset is stored per cpu.

The only reason left as to why we need percpu duplication are the rule
counters embedded into ipt_entry et al -- since each cpu has its own copy
of the rules, all counters can be lockless.

The downside is that the more cpus are supported, the more memory is
required.  Rules are not just duplicated per online cpu but for each
possible cpu, i.e. if maxcpu is 144, then rule is duplicated 144 times,
not for the e.g. 64 cores present.

To save some memory and also improve utilization of shared caches it
would be preferable to only store the rule blob once.

So we first need to separate counters and the rule blob.

Instead of using entry->counters, allocate this percpu and store the
percpu address in entry->counters.pcnt on CONFIG_SMP.

This change makes no sense as-is; it is merely an intermediate step to
remove the percpu duplication of the rule set in a followup patch.

Suggested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Reported-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |   49 ++++++++++++++++++++++++++++++++++++
 net/ipv4/netfilter/arp_tables.c    |   32 +++++++++++++++++++----
 net/ipv4/netfilter/ip_tables.c     |   31 ++++++++++++++++++++---
 net/ipv6/netfilter/ip6_tables.c    |   31 +++++++++++++++++++----
 4 files changed, 129 insertions(+), 14 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 09f3820..b77ab9f 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -353,6 +353,55 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	return ret;
 }
 
+
+/* On SMP, ip(6)t_entry->counters.pcnt holds address of the
+ * real (percpu) counter.  On !SMP, its just the packet count,
+ * so nothing needs to be done there.
+ *
+ * xt_percpu_counter_alloc returns the address of the percpu
+ * counter, or 0 on !SMP.
+ *
+ * Hence caller must use IS_ERR_VALUE to check for error, this
+ * allows us to return 0 for single core systems without forcing
+ * callers to deal with SMP vs. NONSMP issues.
+ */
+static inline u64 xt_percpu_counter_alloc(void)
+{
+	if (nr_cpu_ids > 1) {
+		void __percpu *res = alloc_percpu(struct xt_counters);
+
+		if (res == NULL)
+			return (u64) -ENOMEM;
+
+		return (__force u64) res;
+	}
+
+	return 0;
+}
+static inline void xt_percpu_counter_free(u64 pcnt)
+{
+	if (nr_cpu_ids > 1)
+		free_percpu((void __percpu *) pcnt);
+}
+
+static inline struct xt_counters *
+xt_get_this_cpu_counter(struct xt_counters *cnt)
+{
+	if (nr_cpu_ids > 1)
+		return this_cpu_ptr((void __percpu *) cnt->pcnt);
+
+	return cnt;
+}
+
+static inline struct xt_counters *
+xt_get_per_cpu_counter(struct xt_counters *cnt, unsigned int cpu)
+{
+	if (nr_cpu_ids > 1)
+		return per_cpu_ptr((void __percpu *) cnt->pcnt, cpu);
+
+	return cnt;
+}
+
 struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
 void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a612007..0ada09a 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -289,13 +289,15 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	arp = arp_hdr(skb);
 	do {
 		const struct xt_entry_target *t;
+		struct xt_counters *counter;
 
 		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
 			e = arpt_next_entry(e);
 			continue;
 		}
 
-		ADD_COUNTER(e->counters, arp_hdr_len(skb->dev), 1);
+		counter = xt_get_this_cpu_counter(&e->counters);
+		ADD_COUNTER(*counter, arp_hdr_len(skb->dev), 1);
 
 		t = arpt_get_target_c(e);
 
@@ -521,6 +523,10 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 	if (ret)
 		return ret;
 
+	e->counters.pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(e->counters.pcnt))
+		return -ENOMEM;
+
 	t = arpt_get_target(e);
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
 					t->u.user.revision);
@@ -538,6 +544,8 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 err:
 	module_put(t->u.kernel.target->me);
 out:
+	xt_percpu_counter_free(e->counters.pcnt);
+
 	return ret;
 }
 
@@ -614,6 +622,7 @@ static inline void cleanup_entry(struct arpt_entry *e)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
+	xt_percpu_counter_free(e->counters.pcnt);
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -723,13 +732,15 @@ static void get_counters(const struct xt_table_info *t,
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
 
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
 			do {
 				start = read_seqcount_begin(s);
-				bcnt = iter->counters.bcnt;
-				pcnt = iter->counters.pcnt;
+				bcnt = tmp->bcnt;
+				pcnt = tmp->pcnt;
 			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
@@ -1186,7 +1197,10 @@ static int do_add_counters(struct net *net, const void __user *user,
 	loc_cpu_entry = private->entries[curcpu];
 	addend = xt_write_recseq_begin();
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
-		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		struct xt_counters *tmp;
+
+		tmp = xt_get_this_cpu_counter(&iter->counters);
+		ADD_COUNTER(*tmp, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
 	xt_write_recseq_end(addend);
@@ -1416,9 +1430,17 @@ static int translate_compat_table(const char *name,
 
 	i = 0;
 	xt_entry_foreach(iter1, entry1, newinfo->size) {
+		iter1->counters.pcnt = xt_percpu_counter_alloc();
+		if (IS_ERR_VALUE(iter1->counters.pcnt)) {
+			ret = -ENOMEM;
+			break;
+		}
+
 		ret = check_target(iter1, name);
-		if (ret != 0)
+		if (ret != 0) {
+			xt_percpu_counter_free(iter1->counters.pcnt);
 			break;
+		}
 		++i;
 		if (strcmp(arpt_get_target(iter1)->u.user.name,
 		    XT_ERROR_TARGET) == 0)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e7abf51..d190b10 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -345,6 +345,7 @@ ipt_do_table(struct sk_buff *skb,
 	do {
 		const struct xt_entry_target *t;
 		const struct xt_entry_match *ematch;
+		struct xt_counters *counter;
 
 		IP_NF_ASSERT(e);
 		if (!ip_packet_match(ip, indev, outdev,
@@ -361,7 +362,8 @@ ipt_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
 
-		ADD_COUNTER(e->counters, skb->len, 1);
+		counter = xt_get_this_cpu_counter(&e->counters);
+		ADD_COUNTER(*counter, skb->len, 1);
 
 		t = ipt_get_target(e);
 		IP_NF_ASSERT(t->u.kernel.target);
@@ -665,6 +667,10 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	if (ret)
 		return ret;
 
+	e->counters.pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(e->counters.pcnt))
+		return -ENOMEM;
+
 	j = 0;
 	mtpar.net	= net;
 	mtpar.table     = name;
@@ -691,6 +697,7 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	ret = check_target(e, net, name);
 	if (ret)
 		goto err;
+
 	return 0;
  err:
 	module_put(t->u.kernel.target->me);
@@ -700,6 +707,9 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 			break;
 		cleanup_match(ematch, net);
 	}
+
+	xt_percpu_counter_free(e->counters.pcnt);
+
 	return ret;
 }
 
@@ -784,6 +794,7 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
+	xt_percpu_counter_free(e->counters.pcnt);
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -888,13 +899,15 @@ get_counters(const struct xt_table_info *t,
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
 
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
 			do {
 				start = read_seqcount_begin(s);
-				bcnt = iter->counters.bcnt;
-				pcnt = iter->counters.pcnt;
+				bcnt = tmp->bcnt;
+				pcnt = tmp->pcnt;
 			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
@@ -1374,7 +1387,10 @@ do_add_counters(struct net *net, const void __user *user,
 	loc_cpu_entry = private->entries[curcpu];
 	addend = xt_write_recseq_begin();
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
-		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		struct xt_counters *tmp;
+
+		tmp = xt_get_this_cpu_counter(&iter->counters);
+		ADD_COUNTER(*tmp, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
 	xt_write_recseq_end(addend);
@@ -1608,6 +1624,10 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 	unsigned int j;
 	int ret = 0;
 
+	e->counters.pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(e->counters.pcnt))
+		return -ENOMEM;
+
 	j = 0;
 	mtpar.net	= net;
 	mtpar.table     = name;
@@ -1632,6 +1652,9 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 			break;
 		cleanup_match(ematch, net);
 	}
+
+	xt_percpu_counter_free(e->counters.pcnt);
+
 	return ret;
 }
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index cdd085f..a1190ee 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -367,6 +367,7 @@ ip6t_do_table(struct sk_buff *skb,
 	do {
 		const struct xt_entry_target *t;
 		const struct xt_entry_match *ematch;
+		struct xt_counters *counter;
 
 		IP_NF_ASSERT(e);
 		acpar.thoff = 0;
@@ -384,7 +385,8 @@ ip6t_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
 
-		ADD_COUNTER(e->counters, skb->len, 1);
+		counter = xt_get_this_cpu_counter(&e->counters);
+		ADD_COUNTER(*counter, skb->len, 1);
 
 		t = ip6t_get_target_c(e);
 		IP_NF_ASSERT(t->u.kernel.target);
@@ -679,6 +681,10 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	if (ret)
 		return ret;
 
+	e->counters.pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(e->counters.pcnt))
+		return -ENOMEM;
+
 	j = 0;
 	mtpar.net	= net;
 	mtpar.table     = name;
@@ -714,6 +720,9 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 			break;
 		cleanup_match(ematch, net);
 	}
+
+	xt_percpu_counter_free(e->counters.pcnt);
+
 	return ret;
 }
 
@@ -797,6 +806,8 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
+
+	xt_percpu_counter_free(e->counters.pcnt);
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -901,13 +912,15 @@ get_counters(const struct xt_table_info *t,
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
 
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
 			do {
 				start = read_seqcount_begin(s);
-				bcnt = iter->counters.bcnt;
-				pcnt = iter->counters.pcnt;
+				bcnt = tmp->bcnt;
+				pcnt = tmp->pcnt;
 			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
@@ -1374,7 +1387,6 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 		goto free;
 	}
 
-
 	local_bh_disable();
 	private = t->private;
 	if (private->number != num_counters) {
@@ -1388,7 +1400,10 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	addend = xt_write_recseq_begin();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
-		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		struct xt_counters *tmp;
+
+		tmp = xt_get_this_cpu_counter(&iter->counters);
+		ADD_COUNTER(*tmp, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
 	xt_write_recseq_end(addend);
@@ -1621,6 +1636,9 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
 
+	e->counters.pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(e->counters.pcnt))
+		return -ENOMEM;
 	j = 0;
 	mtpar.net	= net;
 	mtpar.table     = name;
@@ -1645,6 +1663,9 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 			break;
 		cleanup_match(ematch, net);
 	}
+
+	xt_percpu_counter_free(e->counters.pcnt);
+
 	return ret;
 }
 
-- 
1.7.10.4

