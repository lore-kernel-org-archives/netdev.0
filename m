From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/32] netfilter: xtables: avoid percpu ruleset duplication
Date: Mon, 15 Jun 2015 23:26:09 +0200
Message-ID: <1434403589-24796-13-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We store the rule blob per (possible) cpu.  Unfortunately this means we can
waste lot of memory on big smp machines. ipt_entry structure ('rule head')
is 112 byte, so e.g. with maxcpu=64 one single rule eats
close to 8k RAM.

Since previous patch made counters percpu it appears there is nothing
left in the rule blob that needs to be percpu.

On my test system (144 possible cpus, 400k dummy rules) this
change saves close to 9 Gigabyte of RAM.

Reported-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |    4 +--
 net/ipv4/netfilter/arp_tables.c    |   50 +++++++++------------------
 net/ipv4/netfilter/ip_tables.c     |   64 +++++++++--------------------------
 net/ipv6/netfilter/ip6_tables.c    |   65 +++++++++---------------------------
 net/netfilter/x_tables.c           |   23 +++++--------
 5 files changed, 57 insertions(+), 149 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index b77ab9f..9969d79 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -224,9 +224,9 @@ struct xt_table_info {
 	unsigned int stacksize;
 	unsigned int __percpu *stackptr;
 	void ***jumpstack;
-	/* ipt_entry tables: one per CPU */
+
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
-	void *entries[1];
+	void *entries;
 };
 
 #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 0ada09a..d75c139 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -275,7 +275,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	 * pointer.
 	 */
 	smp_read_barrier_depends();
-	table_base = private->entries[smp_processor_id()];
+	table_base = private->entries;
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -711,12 +711,6 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
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
 
@@ -731,7 +725,7 @@ static void get_counters(const struct xt_table_info *t,
 		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
-		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+		xt_entry_foreach(iter, t->entries, t->size) {
 			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
@@ -785,7 +779,7 @@ static int copy_entries_to_user(unsigned int total_size,
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	/* ... then copy entire thing ... */
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
 		ret = -EFAULT;
@@ -880,10 +874,10 @@ static int compat_table_info(const struct xt_table_info *info,
 	if (!newinfo || !info)
 		return -EINVAL;
 
-	/* we dont care about newinfo->entries[] */
+	/* we dont care about newinfo->entries */
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
-	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	loc_cpu_entry = info->entries;
 	xt_compat_init_offsets(NFPROTO_ARP, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
@@ -1048,7 +1042,7 @@ static int __do_replace(struct net *net, const char *name,
 	get_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
-	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
+	loc_cpu_old_entry = oldinfo->entries;
 	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
 		cleanup_entry(iter);
 
@@ -1095,8 +1089,7 @@ static int do_replace(struct net *net, const void __user *user,
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1126,7 +1119,7 @@ static int do_replace(struct net *net, const void __user *user,
 static int do_add_counters(struct net *net, const void __user *user,
 			   unsigned int len, int compat)
 {
-	unsigned int i, curcpu;
+	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1136,7 +1129,6 @@ static int do_add_counters(struct net *net, const void __user *user,
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
-	void *loc_cpu_entry;
 	struct arpt_entry *iter;
 	unsigned int addend;
 #ifdef CONFIG_COMPAT
@@ -1192,11 +1184,9 @@ static int do_add_counters(struct net *net, const void __user *user,
 	}
 
 	i = 0;
-	/* Choose the copy that is on our node */
-	curcpu = smp_processor_id();
-	loc_cpu_entry = private->entries[curcpu];
+
 	addend = xt_write_recseq_begin();
-	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+	xt_entry_foreach(iter,  private->entries, private->size) {
 		struct xt_counters *tmp;
 
 		tmp = xt_get_this_cpu_counter(&iter->counters);
@@ -1410,7 +1400,7 @@ static int translate_compat_table(const char *name,
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
-	entry1 = newinfo->entries[raw_smp_processor_id()];
+	entry1 = newinfo->entries;
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
@@ -1470,11 +1460,6 @@ static int translate_compat_table(const char *name,
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
@@ -1533,8 +1518,7 @@ static int compat_do_replace(struct net *net, void __user *user,
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp), tmp.size) != 0) {
 		ret = -EFAULT;
 		goto free_newinfo;
@@ -1631,7 +1615,6 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	void __user *pos;
 	unsigned int size;
 	int ret = 0;
-	void *loc_cpu_entry;
 	unsigned int i = 0;
 	struct arpt_entry *iter;
 
@@ -1639,11 +1622,9 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	/* choose the copy on our node/cpu */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+	xt_entry_foreach(iter, private->entries, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
 						&size, counters, i++);
 		if (ret != 0)
@@ -1812,8 +1793,7 @@ struct xt_table *arpt_register_table(struct net *net,
 		goto out;
 	}
 
-	/* choose the copy on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(newinfo, loc_cpu_entry, repl);
@@ -1844,7 +1824,7 @@ void arpt_unregister_table(struct xt_table *table)
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
 		cleanup_entry(iter);
 	if (private->number > private->initial_entries)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d190b10..6151500 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -254,15 +254,13 @@ static void trace_packet(const struct sk_buff *skb,
 			 const struct xt_table_info *private,
 			 const struct ipt_entry *e)
 {
-	const void *table_base;
 	const struct ipt_entry *root;
 	const char *hookname, *chainname, *comment;
 	const struct ipt_entry *iter;
 	unsigned int rulenum = 0;
 	struct net *net = dev_net(in ? in : out);
 
-	table_base = private->entries[smp_processor_id()];
-	root = get_entry(table_base, private->hook_entry[hook]);
+	root = get_entry(private->entries, private->hook_entry[hook]);
 
 	hookname = chainname = hooknames[hook];
 	comment = comments[NF_IP_TRACE_COMMENT_RULE];
@@ -331,7 +329,7 @@ ipt_do_table(struct sk_buff *skb,
 	 * pointer.
 	 */
 	smp_read_barrier_depends();
-	table_base = private->entries[cpu];
+	table_base = private->entries;
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
 	stackptr   = per_cpu_ptr(private->stackptr, cpu);
 	origptr    = *stackptr;
@@ -877,12 +875,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
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
 
@@ -898,7 +890,7 @@ get_counters(const struct xt_table_info *t,
 		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
-		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+		xt_entry_foreach(iter, t->entries, t->size) {
 			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
@@ -946,17 +938,13 @@ copy_entries_to_user(unsigned int total_size,
 	struct xt_counters *counters;
 	const struct xt_table_info *private = table->private;
 	int ret = 0;
-	const void *loc_cpu_entry;
+	void *loc_cpu_entry;
 
 	counters = alloc_counters(table);
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	/* choose the copy that is on our node/cpu, ...
-	 * This choice is lazy (because current thread is
-	 * allowed to migrate to another cpu)
-	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
 		ret = -EFAULT;
 		goto free_counters;
@@ -1070,10 +1058,10 @@ static int compat_table_info(const struct xt_table_info *info,
 	if (!newinfo || !info)
 		return -EINVAL;
 
-	/* we dont care about newinfo->entries[] */
+	/* we dont care about newinfo->entries */
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
-	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	loc_cpu_entry = info->entries;
 	xt_compat_init_offsets(AF_INET, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
@@ -1194,7 +1182,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct xt_table *t;
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
-	void *loc_cpu_old_entry;
 	struct ipt_entry *iter;
 
 	ret = 0;
@@ -1237,8 +1224,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	get_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
-	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+	xt_entry_foreach(iter, oldinfo->entries, oldinfo->size)
 		cleanup_entry(iter, net);
 
 	xt_free_table_info(oldinfo);
@@ -1284,8 +1270,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1316,7 +1301,7 @@ static int
 do_add_counters(struct net *net, const void __user *user,
                 unsigned int len, int compat)
 {
-	unsigned int i, curcpu;
+	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1326,7 +1311,6 @@ do_add_counters(struct net *net, const void __user *user,
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
-	void *loc_cpu_entry;
 	struct ipt_entry *iter;
 	unsigned int addend;
 #ifdef CONFIG_COMPAT
@@ -1382,11 +1366,8 @@ do_add_counters(struct net *net, const void __user *user,
 	}
 
 	i = 0;
-	/* Choose the copy that is on our node */
-	curcpu = smp_processor_id();
-	loc_cpu_entry = private->entries[curcpu];
 	addend = xt_write_recseq_begin();
-	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+	xt_entry_foreach(iter, private->entries, private->size) {
 		struct xt_counters *tmp;
 
 		tmp = xt_get_this_cpu_counter(&iter->counters);
@@ -1739,7 +1720,7 @@ translate_compat_table(struct net *net,
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
-	entry1 = newinfo->entries[raw_smp_processor_id()];
+	entry1 = newinfo->entries;
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
@@ -1791,11 +1772,6 @@ translate_compat_table(struct net *net,
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
@@ -1842,8 +1818,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1914,7 +1889,6 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	void __user *pos;
 	unsigned int size;
 	int ret = 0;
-	const void *loc_cpu_entry;
 	unsigned int i = 0;
 	struct ipt_entry *iter;
 
@@ -1922,14 +1896,9 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	/* choose the copy that is on our node/cpu, ...
-	 * This choice is lazy (because current thread is
-	 * allowed to migrate to another cpu)
-	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+	xt_entry_foreach(iter, private->entries, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
 						&size, counters, i++);
 		if (ret != 0)
@@ -2104,8 +2073,7 @@ struct xt_table *ipt_register_table(struct net *net,
 		goto out;
 	}
 
-	/* choose the copy on our node/cpu, but dont care about preemption */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(net, newinfo, loc_cpu_entry, repl);
@@ -2136,7 +2104,7 @@ void ipt_unregister_table(struct net *net, struct xt_table *table)
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
 		cleanup_entry(iter, net);
 	if (private->number > private->initial_entries)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index a1190ee..80a7f0d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -283,15 +283,13 @@ static void trace_packet(const struct sk_buff *skb,
 			 const struct xt_table_info *private,
 			 const struct ip6t_entry *e)
 {
-	const void *table_base;
 	const struct ip6t_entry *root;
 	const char *hookname, *chainname, *comment;
 	const struct ip6t_entry *iter;
 	unsigned int rulenum = 0;
 	struct net *net = dev_net(in ? in : out);
 
-	table_base = private->entries[smp_processor_id()];
-	root = get_entry(table_base, private->hook_entry[hook]);
+	root = get_entry(private->entries, private->hook_entry[hook]);
 
 	hookname = chainname = hooknames[hook];
 	comment = comments[NF_IP6_TRACE_COMMENT_RULE];
@@ -357,7 +355,7 @@ ip6t_do_table(struct sk_buff *skb,
 	 */
 	smp_read_barrier_depends();
 	cpu        = smp_processor_id();
-	table_base = private->entries[cpu];
+	table_base = private->entries;
 	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
 	stackptr   = per_cpu_ptr(private->stackptr, cpu);
 	origptr    = *stackptr;
@@ -890,12 +888,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
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
 
@@ -911,7 +903,7 @@ get_counters(const struct xt_table_info *t,
 		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
-		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+		xt_entry_foreach(iter, t->entries, t->size) {
 			struct xt_counters *tmp;
 			u64 bcnt, pcnt;
 			unsigned int start;
@@ -959,17 +951,13 @@ copy_entries_to_user(unsigned int total_size,
 	struct xt_counters *counters;
 	const struct xt_table_info *private = table->private;
 	int ret = 0;
-	const void *loc_cpu_entry;
+	void *loc_cpu_entry;
 
 	counters = alloc_counters(table);
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	/* choose the copy that is on our node/cpu, ...
-	 * This choice is lazy (because current thread is
-	 * allowed to migrate to another cpu)
-	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
 		ret = -EFAULT;
 		goto free_counters;
@@ -1083,10 +1071,10 @@ static int compat_table_info(const struct xt_table_info *info,
 	if (!newinfo || !info)
 		return -EINVAL;
 
-	/* we dont care about newinfo->entries[] */
+	/* we dont care about newinfo->entries */
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
-	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	loc_cpu_entry = info->entries;
 	xt_compat_init_offsets(AF_INET6, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
@@ -1207,7 +1195,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct xt_table *t;
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
-	const void *loc_cpu_old_entry;
 	struct ip6t_entry *iter;
 
 	ret = 0;
@@ -1250,8 +1237,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	get_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
-	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+	xt_entry_foreach(iter, oldinfo->entries, oldinfo->size)
 		cleanup_entry(iter, net);
 
 	xt_free_table_info(oldinfo);
@@ -1297,8 +1283,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1329,7 +1314,7 @@ static int
 do_add_counters(struct net *net, const void __user *user, unsigned int len,
 		int compat)
 {
-	unsigned int i, curcpu;
+	unsigned int i;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1339,7 +1324,6 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	struct xt_table *t;
 	const struct xt_table_info *private;
 	int ret = 0;
-	const void *loc_cpu_entry;
 	struct ip6t_entry *iter;
 	unsigned int addend;
 #ifdef CONFIG_COMPAT
@@ -1395,11 +1379,8 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	}
 
 	i = 0;
-	/* Choose the copy that is on our node */
-	curcpu = smp_processor_id();
 	addend = xt_write_recseq_begin();
-	loc_cpu_entry = private->entries[curcpu];
-	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+	xt_entry_foreach(iter, private->entries, private->size) {
 		struct xt_counters *tmp;
 
 		tmp = xt_get_this_cpu_counter(&iter->counters);
@@ -1407,7 +1388,6 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 		++i;
 	}
 	xt_write_recseq_end(addend);
-
  unlock_up_free:
 	local_bh_enable();
 	xt_table_unlock(t);
@@ -1750,7 +1730,7 @@ translate_compat_table(struct net *net,
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
-	entry1 = newinfo->entries[raw_smp_processor_id()];
+	entry1 = newinfo->entries;
 	pos = entry1;
 	size = total_size;
 	xt_entry_foreach(iter0, entry0, total_size) {
@@ -1802,11 +1782,6 @@ translate_compat_table(struct net *net,
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
@@ -1853,8 +1828,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	if (!newinfo)
 		return -ENOMEM;
 
-	/* choose the copy that is on our node/cpu */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
@@ -1925,7 +1899,6 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	void __user *pos;
 	unsigned int size;
 	int ret = 0;
-	const void *loc_cpu_entry;
 	unsigned int i = 0;
 	struct ip6t_entry *iter;
 
@@ -1933,14 +1906,9 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	if (IS_ERR(counters))
 		return PTR_ERR(counters);
 
-	/* choose the copy that is on our node/cpu, ...
-	 * This choice is lazy (because current thread is
-	 * allowed to migrate to another cpu)
-	 */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+	xt_entry_foreach(iter, private->entries, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
 						&size, counters, i++);
 		if (ret != 0)
@@ -2115,8 +2083,7 @@ struct xt_table *ip6t_register_table(struct net *net,
 		goto out;
 	}
 
-	/* choose the copy on our node/cpu, but dont care about preemption */
-	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
+	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(net, newinfo, loc_cpu_entry, repl);
@@ -2146,7 +2113,7 @@ void ip6t_unregister_table(struct net *net, struct xt_table *table)
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries;
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
 		cleanup_entry(iter, net);
 	if (private->number > private->initial_entries)
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8303246..6062ce3 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -659,7 +659,6 @@ EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
 struct xt_table_info *xt_alloc_table_info(unsigned int size)
 {
 	struct xt_table_info *newinfo;
-	int cpu;
 
 	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
 	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
@@ -671,19 +670,14 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 
 	newinfo->size = size;
 
-	for_each_possible_cpu(cpu) {
-		if (size <= PAGE_SIZE)
-			newinfo->entries[cpu] = kmalloc_node(size,
-							GFP_KERNEL,
-							cpu_to_node(cpu));
-		else
-			newinfo->entries[cpu] = vmalloc_node(size,
-							cpu_to_node(cpu));
+	if (size <= PAGE_SIZE)
+		newinfo->entries = kmalloc(size, GFP_KERNEL);
+	else
+		newinfo->entries = vmalloc(size);
 
-		if (newinfo->entries[cpu] == NULL) {
-			xt_free_table_info(newinfo);
-			return NULL;
-		}
+	if (newinfo->entries == NULL) {
+		xt_free_table_info(newinfo);
+		return NULL;
 	}
 
 	return newinfo;
@@ -694,8 +688,7 @@ void xt_free_table_info(struct xt_table_info *info)
 {
 	int cpu;
 
-	for_each_possible_cpu(cpu)
-		kvfree(info->entries[cpu]);
+	kvfree(info->entries);
 
 	if (info->jumpstack != NULL) {
 		for_each_possible_cpu(cpu)
-- 
1.7.10.4

