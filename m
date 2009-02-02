From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Mon, 2 Feb 2009 15:33:57 -0800
Message-ID: <20090202153357.3ac6edfa@extreme>
References: <20090130215700.965611970@vyatta.com>
	<20090130215729.416851870@vyatta.com>
	<498594B6.6000905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46649 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbZBBXeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 18:34:00 -0500
In-Reply-To: <498594B6.6000905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an alternative to earlier RCU/seqcount_t version of counters.
The counters operate as usual without locking, but when counters are rotated
around the CPU's entries.  RCU is used in two ways, first to handle the
counter rotation, second for replace.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netfilter/x_tables.h |   10 +++-
 net/ipv4/netfilter/arp_tables.c    |   73 +++++++++++++++++++++++++++---------
 net/ipv4/netfilter/ip_tables.c     |   68 ++++++++++++++++++++++++---------
 net/ipv6/netfilter/ip6_tables.c    |   75 ++++++++++++++++++++++++++-----------
 net/netfilter/x_tables.c           |   43 +++++++++++++++------
 5 files changed, 197 insertions(+), 72 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-02-02 15:06:39.893751845 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-02-02 15:28:10.022574005 -0800
@@ -353,7 +353,7 @@ struct xt_table
 	unsigned int valid_hooks;
 
 	/* Lock for the curtain */
-	rwlock_t lock;
+	struct mutex lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -383,9 +383,15 @@ struct xt_table_info
 	unsigned int hook_entry[NF_INET_NUMHOOKS];
 	unsigned int underflow[NF_INET_NUMHOOKS];
 
+	/* For the dustman... */
+	union {
+		struct rcu_head rcu;
+		struct work_struct work;
+	};
+
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
-	char *entries[1];
+	void *entries[1];
 };
 
 #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
--- a/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:06:29.684249364 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:14:13.256499021 -0800
@@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -892,45 +894,73 @@ set_entry_to_counter(const struct ipt_en
 	return 0;
 }
 
+static inline int
+set_counter_to_entry(struct ipt_entry *e,
+		     const struct ipt_counters total[],
+		     unsigned int *i)
+{
+	SET_COUNTER(e->counters, total[*i].bcnt, total[*i].pcnt);
+
+	(*i)++;
+	return 0;
+}
+
+
 static void
-get_counters(const struct xt_table_info *t,
+get_counters(struct xt_table_info *t,
 	     struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
+	struct ipt_entry *e;
 
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
-	 */
+	preempt_disable();
 	curcpu = raw_smp_processor_id();
-
+	e = t->entries[curcpu];
 	i = 0;
-	IPT_ENTRY_ITERATE(t->entries[curcpu],
+	IPT_ENTRY_ITERATE(e,
 			  t->size,
 			  set_entry_to_counter,
 			  counters,
 			  &i);
 
 	for_each_possible_cpu(cpu) {
+		void *p;
+
 		if (cpu == curcpu)
 			continue;
+
+		/* Swizzle the values and wait */
+		e->counters = ((struct xt_counters) { 0, 0 });
+		p = t->entries[cpu];
+		rcu_assign_pointer(t->entries[cpu], e);
+		synchronize_net();
+		e = p;
+
 		i = 0;
-		IPT_ENTRY_ITERATE(t->entries[cpu],
+		IPT_ENTRY_ITERATE(e,
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
 	}
+	i = 0;
+	t->entries[curcpu] = e;
+	IPT_ENTRY_ITERATE(e,
+			  t->size,
+			  set_counter_to_entry,
+			  counters,
+			  &i);
+
+	preempt_enable();
 }
 
 static struct xt_counters * alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -942,9 +972,9 @@ static struct xt_counters * alloc_counte
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	mutex_lock(&table->lock);
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	mutex_unlock(&table->lock);
 
 	return counters;
 }
@@ -1393,13 +1423,14 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
+	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
+	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
@@ -1408,8 +1439,9 @@ do_add_counters(struct net *net, void __
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
+	preempt_enable();
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	mutex_unlock(&t->lock);
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-02-02 15:06:29.708249745 -0800
+++ b/net/netfilter/x_tables.c	2009-02-02 15:30:33.718573969 -0800
@@ -611,18 +611,36 @@ struct xt_table_info *xt_alloc_table_inf
 }
 EXPORT_SYMBOL(xt_alloc_table_info);
 
-void xt_free_table_info(struct xt_table_info *info)
+/* callback to do free for vmalloc'd case */
+static void xt_free_table_info_work(struct work_struct *arg)
 {
 	int cpu;
+	struct xt_table_info *info = container_of(arg, struct xt_table_info, work);
 
-	for_each_possible_cpu(cpu) {
-		if (info->size <= PAGE_SIZE)
-			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
-	}
+	for_each_possible_cpu(cpu)
+		vfree(info->entries[cpu]);
 	kfree(info);
 }
+
+static void xt_free_table_info_rcu(struct rcu_head *arg)
+{
+	struct xt_table_info *info = container_of(arg, struct xt_table_info, rcu);
+ 	if (info->size <= PAGE_SIZE) {
+		unsigned int cpu;
+ 		for_each_possible_cpu(cpu)
+ 			kfree(info->entries[cpu]);
+ 		kfree(info);
+ 	} else {
+ 		/* can't safely call vfree in current context */
+ 		INIT_WORK(&info->work, xt_free_table_info_work);
+ 		schedule_work(&info->work);
+  	}
+}
+
+void xt_free_table_info(struct xt_table_info *info)
+{
+ 	call_rcu(&info->rcu, xt_free_table_info_rcu);
+}
 EXPORT_SYMBOL(xt_free_table_info);
 
 /* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
@@ -671,20 +689,20 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *oldinfo, *private;
 
 	/* Do the substitution. */
-	write_lock_bh(&table->lock);
+	mutex_lock(&table->lock);
 	private = table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		write_unlock_bh(&table->lock);
+		mutex_unlock(&table->lock);
 		*error = -EAGAIN;
 		return NULL;
 	}
 	oldinfo = private;
-	table->private = newinfo;
+	rcu_assign_pointer(table->private, newinfo);
 	newinfo->initial_entries = oldinfo->initial_entries;
-	write_unlock_bh(&table->lock);
+	mutex_unlock(&table->lock);
 
 	return oldinfo;
 }
@@ -719,7 +737,8 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	mutex_init(&table->lock);
+
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 
--- a/net/ipv4/netfilter/arp_tables.c	2009-02-02 15:06:29.696250564 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-02-02 15:14:45.969206521 -0800
@@ -237,9 +237,10 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	read_lock_bh(&table->lock);
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
@@ -311,7 +312,8 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-	read_unlock_bh(&table->lock);
+
+	rcu_read_unlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -681,44 +683,77 @@ static inline int set_entry_to_counter(c
 	return 0;
 }
 
-static void get_counters(const struct xt_table_info *t,
-			 struct xt_counters counters[])
+
+static inline int
+set_counter_to_entry(struct arpt_entry *e,
+		     const struct xt_counters total[],
+		     unsigned int *i)
+{
+	SET_COUNTER(e->counters, total[*i].bcnt, total[*i].pcnt);
+
+ 	(*i)++;
+ 	return 0;
+}
+
+
+static void
+get_counters(struct xt_table_info *t,
+	     struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
+	struct arpt_entry *e;
 
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
-	 */
+	preempt_disable();
 	curcpu = raw_smp_processor_id();
 
 	i = 0;
-	ARPT_ENTRY_ITERATE(t->entries[curcpu],
+ 	e = t->entries[curcpu];
+	ARPT_ENTRY_ITERATE(e,
 			   t->size,
 			   set_entry_to_counter,
 			   counters,
 			   &i);
 
 	for_each_possible_cpu(cpu) {
+		void *p;
+
 		if (cpu == curcpu)
 			continue;
+
+		/* Swizzle the values and wait */
+		e->counters.bcnt = 0;
+		e->counters.pcnt = 0;
+		p = t->entries[cpu];
+		rcu_assign_pointer(t->entries[cpu], e);
+		synchronize_net();
+		e = p;
+
 		i = 0;
-		ARPT_ENTRY_ITERATE(t->entries[cpu],
+		ARPT_ENTRY_ITERATE(e,
 				   t->size,
 				   add_entry_to_counter,
 				   counters,
 				   &i);
 	}
+
+	i = 0;
+	t->entries[curcpu] = e;
+	ARPT_ENTRY_ITERATE(e,
+			  t->size,
+			  set_counter_to_entry,
+			  counters,
+			  &i);
+
+	preempt_enable();
 }
 
 static inline struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -731,9 +766,9 @@ static inline struct xt_counters *alloc_
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	mutex_lock(&table->lock);
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	mutex_unlock(&table->lock);
 
 	return counters;
 }
@@ -1148,13 +1183,14 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
+	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
+	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
 	loc_cpu_entry = private->entries[smp_processor_id()];
@@ -1164,7 +1200,8 @@ static int do_add_counters(struct net *n
 			   paddc,
 			   &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	mutex_unlock(&t->lock);
+
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-02-02 15:06:29.724250485 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-02-02 15:15:05.352498160 -0800
@@ -373,10 +373,12 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -474,7 +476,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -921,45 +923,72 @@ set_entry_to_counter(const struct ip6t_e
 	return 0;
 }
 
+static inline int
+set_counter_to_entry(struct ip6t_entry *e,
+		     const struct ip6t_counters total[],
+		     unsigned int *i)
+{
+	SET_COUNTER(e->counters, total[*i].bcnt, total[*i].pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static void
-get_counters(const struct xt_table_info *t,
+get_counters(struct xt_table_info *t,
 	     struct xt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
+	struct ip6t_entry *e;
 
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
-	 */
+	preempt_disable();
 	curcpu = raw_smp_processor_id();
-
+	e = t->entries[curcpu];
 	i = 0;
-	IP6T_ENTRY_ITERATE(t->entries[curcpu],
-			   t->size,
-			   set_entry_to_counter,
-			   counters,
-			   &i);
+	IP6T_ENTRY_ITERATE(e,
+			  t->size,
+			  set_entry_to_counter,
+			  counters,
+			  &i);
 
 	for_each_possible_cpu(cpu) {
+		void *p;
+
 		if (cpu == curcpu)
 			continue;
+
+		/* Swizzle the values and wait */
+		e->counters = ((struct xt_counters) { 0, 0 });
+		p = t->entries[cpu];
+		rcu_assign_pointer(t->entries[cpu], e);
+		synchronize_net();
+		e = p;
+
 		i = 0;
-		IP6T_ENTRY_ITERATE(t->entries[cpu],
+		IP6T_ENTRY_ITERATE(e,
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
 	}
+	i = 0;
+	t->entries[curcpu] = e;
+	IP6T_ENTRY_ITERATE(e,
+			  t->size,
+			  set_counter_to_entry,
+			  counters,
+			  &i);
+
+	preempt_enable();
 }
 
 static struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -971,9 +1000,9 @@ static struct xt_counters *alloc_counter
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	mutex_lock(&table->lock);
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	mutex_unlock(&table->lock);
 
 	return counters;
 }
@@ -1424,13 +1453,14 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
+	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
+	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
@@ -1439,8 +1469,9 @@ do_add_counters(struct net *net, void __
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
+	preempt_enable();
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	mutex_unlock(&t->lock);
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
