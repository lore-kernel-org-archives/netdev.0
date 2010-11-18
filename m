From: Changli Gao <xiaosuo@gmail.com>
Subject: [RFC PATCH] netfilter: remove the duplicate tables
Date: Thu, 18 Nov 2010 22:39:54 +0800
Message-ID: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35839 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757982Ab0KROk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 09:40:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As only xt_counters are private to each CPU, we don't need to maintain
a whole individual table for each CPU.

In the kernel space, we use the memory of ipt_entry.counters to save a
pointer to a percpu xt_counters. When iptables runs, it only update the
counters on its own CPU.

On non SMP platforms, no change is made.

Only the code of iptables is converted. Thanks for reviews.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/netfilter/x_tables.h |   47 ++++++++++++++++--
 net/ipv4/netfilter/ip_tables.c     |   94 ++++++++++++++-----------------------
 net/netfilter/x_tables.c           |   33 ++++--------
 3 files changed, 90 insertions(+), 84 deletions(-)
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 742bec0..593fe04 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -103,7 +103,6 @@ struct _xt_align {
 /* Error verdict. */
 #define XT_ERROR_TARGET "ERROR"
 
-#define SET_COUNTER(c,b,p) do { (c).bcnt = (b); (c).pcnt = (p); } while(0)
 #define ADD_COUNTER(c,b,p) do { (c).bcnt += (b); (c).pcnt += (p); } while(0)
 
 struct xt_counters {
@@ -404,13 +403,9 @@ struct xt_table_info {
 	unsigned int stacksize;
 	unsigned int __percpu *stackptr;
 	void ***jumpstack;
-	/* ipt_entry tables: one per CPU */
-	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
-	void *entries[1];
+	void *entries;
 };
 
-#define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
-			  + nr_cpu_ids * sizeof(char *))
 extern int xt_register_target(struct xt_target *target);
 extern void xt_unregister_target(struct xt_target *target);
 extern int xt_register_targets(struct xt_target *target, unsigned int n);
@@ -550,6 +545,46 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 extern struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
 extern void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
 
+#ifdef CONFIG_SMP
+#define xt_counters_kern(c) (*(struct xt_counters __percpu **)(c))
+#endif
+
+static inline int xt_counters_kern_init(struct xt_counters *c)
+{
+#ifdef CONFIG_SMP
+	xt_counters_kern(c) = alloc_percpu(struct xt_counters);
+	if (xt_counters_kern(c) == NULL)
+		return -ENOMEM;
+#endif
+	return 0;
+}
+
+static inline void xt_counters_kern_destroy(struct xt_counters *c)
+{
+#ifdef CONFIG_SMP
+	free_percpu(xt_counters_kern(c));
+#endif
+}
+
+static inline struct xt_counters *xt_counters_kern_cpu(struct xt_counters *c,
+						       int cpu)
+{
+#ifdef CONFIG_SMP
+	return per_cpu_ptr(xt_counters_kern(c), cpu);
+#else
+	return c;
+#endif
+}
+
+static inline struct xt_counters *xt_counters_kern_this(struct xt_counters *c)
+{
+#ifdef CONFIG_SMP
+	return this_cpu_ptr(xt_counters_kern(c));
+#else
+	return c;
+#endif
+}
+
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a846d63..6a94ce0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -270,7 +270,7 @@ static void trace_packet(const struct sk_buff *skb,
 	const struct ipt_entry *iter;
 	unsigned int rulenum = 0;
 
-	table_base = private->entries[smp_processor_id()];
+	table_base = private->entries;
 	root = get_entry(table_base, private->hook_entry[hook]);
 
 	hookname = chainname = hooknames[hook];
@@ -334,7 +334,7 @@ ipt_do_table(struct sk_buff *skb,
 	xt_info_rdlock_bh();
 	private = table->private;
 	cpu        = smp_processor_id();
-	table_base = private->entries[cpu];
+	table_base = private->entries;
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
 	stackptr   = per_cpu_ptr(private->stackptr, cpu);
 	origptr    = *stackptr;
@@ -364,7 +364,7 @@ ipt_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
 
-		ADD_COUNTER(e->counters, skb->len, 1);
+		ADD_COUNTER(*xt_counters_kern_this(&e->counters), skb->len, 1);
 
 		t = ipt_get_target(e);
 		IP_NF_ASSERT(t->u.kernel.target);
@@ -785,6 +785,7 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
 	par.family   = NFPROTO_IPV4;
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
+	xt_counters_kern_destroy(&e->counters);
 	module_put(par.target->me);
 }
 
@@ -868,12 +869,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		return ret;
 	}
 
-	/* And one copy for every other CPU */
-	for_each_possible_cpu(i) {
-		if (newinfo->entries[i] && newinfo->entries[i] != entry0)
-			memcpy(newinfo->entries[i], entry0, newinfo->size);
-	}
-
 	return ret;
 }
 
@@ -884,42 +879,21 @@ get_counters(const struct xt_table_info *t,
 	struct ipt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu = get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU.
-	 *
-	 * Bottom half has to be disabled to prevent deadlock
-	 * if new softirq were to run and call ipt_do_table
-	 */
-	local_bh_disable();
-	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
-		SET_COUNTER(counters[i], iter->counters.bcnt,
-			    iter->counters.pcnt);
-		++i;
-	}
-	local_bh_enable();
-	/* Processing counters from other cpus, we can let bottom half enabled,
-	 * (preemption is disabled)
-	 */
+	struct xt_counters *counter;
 
+	memset(counters, 0, sizeof(struct xt_counters) * t->number);
 	for_each_possible_cpu(cpu) {
-		if (cpu == curcpu)
-			continue;
 		i = 0;
 		local_bh_disable();
 		xt_info_wrlock(cpu);
-		xt_entry_foreach(iter, t->entries[cpu], t->size) {
-			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				    iter->counters.pcnt);
+		xt_entry_foreach(iter, t->entries, t->size) {
+			counter = xt_counters_kern_cpu(&iter->counters, cpu);
+			ADD_COUNTER(counters[i], counter->bcnt, counter->pcnt);
 			++i; /* macro does multi eval of i */
 		}
 		xt_info_wrunlock(cpu);
 		local_bh_enable();
 	}
-	put_cpu();
 }
 
 static struct xt_counters *alloc_counters(const struct xt_table *table)
@@ -962,7 +936,7 @@ copy_entries_to_user(unsigned int total_size,
 	 * This choice is lazy (because current thread is
 	 * allowed to migrate to another cpu)
 	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
 		ret = -EFAULT;
 		goto free_counters;
@@ -1076,10 +1050,10 @@ static int compat_table_info(const struct xt_table_info *info,
 	if (!newinfo || !info)
 		return -EINVAL;
 
-	/* we dont care about newinfo->entries[] */
+	/* we dont care about newinfo->entries */
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
-	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	loc_cpu_entry = info->entries;
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
@@ -1199,9 +1173,14 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct xt_table *t;
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
-	void *loc_cpu_old_entry;
 	struct ipt_entry *iter;
 
+	xt_entry_foreach(iter, newinfo->entries, newinfo->size) {
+		ret = xt_counters_kern_init(&iter->counters);
+		if (ret < 0)
+			return ret;
+	}
+
 	ret = 0;
 	counters = vmalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
@@ -1242,8 +1221,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	get_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
-	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+	xt_entry_foreach(iter, oldinfo->entries, oldinfo->size)
 		cleanup_entry(iter, net);
 
 	xt_free_table_info(oldinfo);
@@ -1283,8 +1261,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1325,7 +1302,6 @@ do_add_counters(struct net *net, const void __user *user,
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
-	void *loc_cpu_entry;
 	struct ipt_entry *iter;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
@@ -1382,10 +1358,10 @@ do_add_counters(struct net *net, const void __user *user,
 	i = 0;
 	/* Choose the copy that is on our node */
 	curcpu = smp_processor_id();
-	loc_cpu_entry = private->entries[curcpu];
 	xt_info_wrlock(curcpu);
-	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
-		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+	xt_entry_foreach(iter, private->entries, private->size) {
+		ADD_COUNTER(*xt_counters_kern_this(&iter->counters),
+			    paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
 	xt_info_wrunlock(curcpu);
@@ -1728,7 +1704,7 @@ translate_compat_table(struct net *net,
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
-	entry1 = newinfo->entries[raw_smp_processor_id()];
+	entry1 = newinfo->entries;
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
@@ -1780,11 +1756,6 @@ translate_compat_table(struct net *net,
 		return ret;
 	}
 
-	/* And one copy for every other CPU */
-	for_each_possible_cpu(i)
-		if (newinfo->entries[i] && newinfo->entries[i] != entry1)
-			memcpy(newinfo->entries[i], entry1, newinfo->size);
-
 	*pinfo = newinfo;
 	*pentry0 = entry1;
 	xt_free_table_info(info);
@@ -1828,7 +1799,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		return -ENOMEM;
 
 	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1911,7 +1882,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	 * This choice is lazy (because current thread is
 	 * allowed to migrate to another cpu)
 	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	pos = userptr;
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
@@ -2081,6 +2052,7 @@ struct xt_table *ipt_register_table(struct net *net,
 	struct xt_table_info bootstrap = {0};
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
+	struct ipt_entry *iter;
 
 	newinfo = xt_alloc_table_info(repl->size);
 	if (!newinfo) {
@@ -2089,13 +2061,19 @@ struct xt_table *ipt_register_table(struct net *net,
 	}
 
 	/* choose the copy on our node/cpu, but dont care about preemption */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(net, newinfo, loc_cpu_entry, repl);
 	if (ret != 0)
 		goto out_free;
 
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size) {
+		ret = xt_counters_kern_init(&iter->counters);
+		if (ret < 0)
+			goto out_free;
+	}
+
 	new_table = xt_register_table(net, table, &bootstrap, newinfo);
 	if (IS_ERR(new_table)) {
 		ret = PTR_ERR(new_table);
@@ -2105,6 +2083,8 @@ struct xt_table *ipt_register_table(struct net *net,
 	return new_table;
 
 out_free:
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		xt_counters_kern_destroy(&iter->counters);
 	xt_free_table_info(newinfo);
 out:
 	return ERR_PTR(ret);
@@ -2120,7 +2100,7 @@ void ipt_unregister_table(struct net *net, struct xt_table *table)
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
 		cleanup_entry(iter, net);
 	if (private->number > private->initial_entries)
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8046350..8053cbe 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -639,31 +639,24 @@ EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
 struct xt_table_info *xt_alloc_table_info(unsigned int size)
 {
 	struct xt_table_info *newinfo;
-	int cpu;
 
 	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
 	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
 		return NULL;
 
-	newinfo = kzalloc(XT_TABLE_INFO_SZ, GFP_KERNEL);
+	newinfo = kzalloc(sizeof(*newinfo), GFP_KERNEL);
 	if (!newinfo)
 		return NULL;
 
 	newinfo->size = size;
 
-	for_each_possible_cpu(cpu) {
-		if (size <= PAGE_SIZE)
-			newinfo->entries[cpu] = kmalloc_node(size,
-							GFP_KERNEL,
-							cpu_to_node(cpu));
-		else
-			newinfo->entries[cpu] = vmalloc_node(size,
-							cpu_to_node(cpu));
-
-		if (newinfo->entries[cpu] == NULL) {
-			xt_free_table_info(newinfo);
-			return NULL;
-		}
+	if (size <= PAGE_SIZE)
+		newinfo->entries = kmalloc(size, GFP_KERNEL);
+	else
+		newinfo->entries = vmalloc(size);
+	if (newinfo->entries == NULL) {
+		xt_free_table_info(newinfo);
+		return NULL;
 	}
 
 	return newinfo;
@@ -674,12 +667,10 @@ void xt_free_table_info(struct xt_table_info *info)
 {
 	int cpu;
 
-	for_each_possible_cpu(cpu) {
-		if (info->size <= PAGE_SIZE)
-			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
-	}
+	if (info->size <= PAGE_SIZE)
+		kfree(info->entries);
+	else
+		vfree(info->entries);
 
 	if (info->jumpstack != NULL) {
 		if (sizeof(void *) * info->stacksize > PAGE_SIZE) {
