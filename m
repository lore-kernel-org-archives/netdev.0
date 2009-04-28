From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 08:00:31 -0700 (PDT)
Message-ID: <20090428.080031.14741305.davem@davemloft.net>
References: <20090428135219.GA28513@Krystal>
	<20090428.073759.78537345.davem@davemloft.net>
	<20090428144920.GA28942@Krystal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	jarkao2@gmail.com, paulus@samba.org, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: mathieu.desnoyers@polymtl.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbZD1PAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:00:38 -0400
In-Reply-To: <20090428144920.GA28942@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Tue, 28 Apr 2009 10:49:20 -0400

> .. and what's the point in making it generic if it can be replaced
> by a proper RCU implementation ? :-) I am not convinced of the added
> value we get in making it a generic header this soon. I would wait for
> other users to express similar needs, otherwise this could soon become
> an orphaned piece of locking code.

That is my opinion as well.

Anyways, here is a patch that builds, I haven't started working
on the commit message yet.

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 7b1a652..086e976 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -434,8 +431,79 @@ extern void xt_proto_fini(struct net *net, u_int8_t af);
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
+
+/*
+ * Per-CPU spinlock associated with per-cpu table entries, and
+ * with a counter for the "reading" side that allows a recursive
+ * reader to avoid taking the lock and deadlocking.
+ *
+ * "reading" is used by ip/arp/ip6 tables rule processing which runs per-cpu.
+ * It needs to ensure that the rules are not being changed while the packet
+ * is being processed. In some cases, the read lock will be acquired
+ * twice on the same CPU; this is okay because of the count.
+ *
+ * The write lock is used in two cases:
+ *    1. reading counter values
+ *       all rule processing need to be stopped and the per-CPU values are summed.
+ *
+ *    2. replacing tables
+ *       any readers that are using the old tables have to complete
+ *       before freeing the old table. This is handled by reading
+ *       as a side effect of reading counters
+ */
+struct xt_info_lock {
+	spinlock_t lock;
+	unsigned char readers;
+};
+DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);
+
+/*
+ * Note: we need to ensure that preemption is disabled before acquiring
+ * the per-cpu-variable, so we do it as a two step process rather than
+ * using "spin_lock_bh()". 
+ *
+ * We _also_ need to disable bottom half processing before updating our
+ * nesting count, to make sure that the only kind of re-entrancy is this
+ * code being called by itself: since the count+lock is not an atomic
+ * operation, we can allow no races. 
+ *
+ * _Only_ that special combination of being per-cpu and never getting
+ * re-entered asynchronously means that the count is safe. 
+ */
+static inline void xt_info_rdlock_bh(void)
+{
+	struct xt_info_lock *lock;
+
+	local_bh_disable();
+	lock = &__get_cpu_var(xt_info_locks);
+	if (!lock->readers++)
+		spin_lock(&lock->lock);
+}
+
+static inline void xt_info_rdunlock_bh(void)
+{
+	struct xt_info_lock *lock;
+
+	lock = &__get_cpu_var(xt_info_locks);
+	if (!--lock->readers)
+		spin_unlock(&lock->lock);
+	local_bh_enable();
+}
+
+/*
+ * The "writer" side needs to get exclusive access to the lock,
+ * regardless of readers.  This must be called with bottom half
+ * processing (and thus also preemption) disabled. 
+ */
+static inline void xt_info_wrlock(unsigned int cpu)
+{
+	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
+}
+
+static inline void xt_info_wrunlock(unsigned int cpu)
+{
+	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
+}
 
 /*
  * This helper is performance critical and must be inlined
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 5ba533d..831fe18 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -253,9 +253,9 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_info_rdlock_bh();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -273,6 +273,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
+
 			ADD_COUNTER(e->counters, hdr_len, 1);
 
 			t = arpt_get_target(e);
@@ -328,8 +329,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	xt_info_rdunlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -711,9 +711,12 @@ static void get_counters(const struct xt_table_info *t,
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
 	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
+	 *
+	 * Bottom half has to be disabled to prevent deadlock
+	 * if new softirq were to run and call ipt_do_table
 	 */
-	curcpu = raw_smp_processor_id();
+	local_bh_disable();
+	curcpu = smp_processor_id();
 
 	i = 0;
 	ARPT_ENTRY_ITERATE(t->entries[curcpu],
@@ -726,73 +729,22 @@ static void get_counters(const struct xt_table_info *t,
 		if (cpu == curcpu)
 			continue;
 		i = 0;
+		xt_info_wrlock(cpu);
 		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
 				   counters,
 				   &i);
+		xt_info_wrunlock(cpu);
 	}
-}
-
-
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct arpt_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-/* Take values from counters and add them back onto the current cpu */
-static void put_counters(struct xt_table_info *t,
-			 const struct xt_counters counters[])
-{
-	unsigned int i, cpu;
-
-	local_bh_disable();
-	cpu = smp_processor_id();
-	i = 0;
-	ARPT_ENTRY_ITERATE(t->entries[cpu],
-			  t->size,
-			  add_counter_to_entry,
-			  counters,
-			  &i);
 	local_bh_enable();
 }
 
-static inline int
-zero_entry_counter(struct arpt_entry *e, void *arg)
-{
-	e->counters.bcnt = 0;
-	e->counters.pcnt = 0;
-	return 0;
-}
-
-static void
-clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
-{
-	unsigned int cpu;
-	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
-
-	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
-	for_each_possible_cpu(cpu) {
-		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
-		ARPT_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
-				  zero_entry_counter, NULL);
-	}
-}
-
 static struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -802,30 +754,11 @@ static struct xt_counters *alloc_counters(struct xt_table *table)
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
-
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
-
-	clone_counters(info, private);
-
-	mutex_lock(&table->lock);
-	xt_table_entry_swap_rcu(private, info);
-	synchronize_net();	/* Wait until smoke has cleared */
+		return ERR_PTR(-ENOMEM);
 
-	get_counters(info, counters);
-	put_counters(private, counters);
-	mutex_unlock(&table->lock);
-
-	xt_free_table_info(info);
+	get_counters(private, counters);
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int copy_entries_to_user(unsigned int total_size,
@@ -1094,8 +1027,9 @@ static int __do_replace(struct net *net, const char *name,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	ARPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1165,10 +1099,23 @@ static int do_replace(struct net *net, void __user *user, unsigned int len)
 	return ret;
 }
 
+/* We're lazy, and add to the first CPU; overflow works its fey magic
+ * and everything is OK. */
+static int
+add_counter_to_entry(struct arpt_entry *e,
+		     const struct xt_counters addme[],
+		     unsigned int *i)
+{
+	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static int do_add_counters(struct net *net, void __user *user, unsigned int len,
 			   int compat)
 {
-	unsigned int i;
+	unsigned int i, curcpu;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1224,26 +1171,26 @@ static int do_add_counters(struct net *net, void __user *user, unsigned int len,
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+	local_bh_disable();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[smp_processor_id()];
+	curcpu = smp_processor_id();
+	loc_cpu_entry = private->entries[curcpu];
+	xt_info_wrlock(curcpu);
 	ARPT_ENTRY_ITERATE(loc_cpu_entry,
 			   private->size,
 			   add_counter_to_entry,
 			   paddc,
 			   &i);
-	preempt_enable();
+	xt_info_wrunlock(curcpu);
  unlock_up_free:
-	mutex_unlock(&t->lock);
-
+	local_bh_enable();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 810c0b6..2ec8d72 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -338,10 +338,9 @@ ipt_do_table(struct sk_buff *skb,
 	tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_info_rdlock_bh();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -436,8 +435,7 @@ ipt_do_table(struct sk_buff *skb,
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	xt_info_rdunlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -896,10 +894,13 @@ get_counters(const struct xt_table_info *t,
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
+	 * with data used by 'current' CPU.
+	 *
+	 * Bottom half has to be disabled to prevent deadlock
+	 * if new softirq were to run and call ipt_do_table
 	 */
-	curcpu = raw_smp_processor_id();
+	local_bh_disable();
+	curcpu = smp_processor_id();
 
 	i = 0;
 	IPT_ENTRY_ITERATE(t->entries[curcpu],
@@ -912,74 +913,22 @@ get_counters(const struct xt_table_info *t,
 		if (cpu == curcpu)
 			continue;
 		i = 0;
+		xt_info_wrlock(cpu);
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
+		xt_info_wrunlock(cpu);
 	}
-
-}
-
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct ipt_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-/* Take values from counters and add them back onto the current cpu */
-static void put_counters(struct xt_table_info *t,
-			 const struct xt_counters counters[])
-{
-	unsigned int i, cpu;
-
-	local_bh_disable();
-	cpu = smp_processor_id();
-	i = 0;
-	IPT_ENTRY_ITERATE(t->entries[cpu],
-			  t->size,
-			  add_counter_to_entry,
-			  counters,
-			  &i);
 	local_bh_enable();
 }
 
-
-static inline int
-zero_entry_counter(struct ipt_entry *e, void *arg)
-{
-	e->counters.bcnt = 0;
-	e->counters.pcnt = 0;
-	return 0;
-}
-
-static void
-clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
-{
-	unsigned int cpu;
-	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
-
-	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
-	for_each_possible_cpu(cpu) {
-		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
-		IPT_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
-				  zero_entry_counter, NULL);
-	}
-}
-
 static struct xt_counters * alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -988,30 +937,11 @@ static struct xt_counters * alloc_counters(struct xt_table *table)
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
+		return ERR_PTR(-ENOMEM);
 
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
-
-	clone_counters(info, private);
-
-	mutex_lock(&table->lock);
-	xt_table_entry_swap_rcu(private, info);
-	synchronize_net();	/* Wait until smoke has cleared */
-
-	get_counters(info, counters);
-	put_counters(private, counters);
-	mutex_unlock(&table->lock);
-
-	xt_free_table_info(info);
+	get_counters(private, counters);
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1306,8 +1236,9 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1377,11 +1308,23 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 	return ret;
 }
 
+/* We're lazy, and add to the first CPU; overflow works its fey magic
+ * and everything is OK. */
+static int
+add_counter_to_entry(struct ipt_entry *e,
+		     const struct xt_counters addme[],
+		     unsigned int *i)
+{
+	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+
+	(*i)++;
+	return 0;
+}
 
 static int
 do_add_counters(struct net *net, void __user *user, unsigned int len, int compat)
 {
-	unsigned int i;
+	unsigned int i, curcpu;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1437,25 +1380,26 @@ do_add_counters(struct net *net, void __user *user, unsigned int len, int compat
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+	local_bh_disable();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	curcpu = smp_processor_id();
+	loc_cpu_entry = private->entries[curcpu];
+	xt_info_wrlock(curcpu);
 	IPT_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+	xt_info_wrunlock(curcpu);
  unlock_up_free:
-	mutex_unlock(&t->lock);
+	local_bh_enable();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 800ae85..219e165 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -365,9 +365,9 @@ ip6t_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_info_rdlock_bh();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -466,7 +466,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	rcu_read_unlock_bh();
+	xt_info_rdunlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -926,9 +926,12 @@ get_counters(const struct xt_table_info *t,
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
 	 * with data used by 'current' CPU
-	 * We dont care about preemption here.
+	 *
+	 * Bottom half has to be disabled to prevent deadlock
+	 * if new softirq were to run and call ipt_do_table
 	 */
-	curcpu = raw_smp_processor_id();
+	local_bh_disable();
+	curcpu = smp_processor_id();
 
 	i = 0;
 	IP6T_ENTRY_ITERATE(t->entries[curcpu],
@@ -941,72 +944,22 @@ get_counters(const struct xt_table_info *t,
 		if (cpu == curcpu)
 			continue;
 		i = 0;
+		xt_info_wrlock(cpu);
 		IP6T_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
+		xt_info_wrunlock(cpu);
 	}
-}
-
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct ip6t_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-/* Take values from counters and add them back onto the current cpu */
-static void put_counters(struct xt_table_info *t,
-			 const struct xt_counters counters[])
-{
-	unsigned int i, cpu;
-
-	local_bh_disable();
-	cpu = smp_processor_id();
-	i = 0;
-	IP6T_ENTRY_ITERATE(t->entries[cpu],
-			   t->size,
-			   add_counter_to_entry,
-			   counters,
-			   &i);
 	local_bh_enable();
 }
 
-static inline int
-zero_entry_counter(struct ip6t_entry *e, void *arg)
-{
-	e->counters.bcnt = 0;
-	e->counters.pcnt = 0;
-	return 0;
-}
-
-static void
-clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
-{
-	unsigned int cpu;
-	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
-
-	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
-	for_each_possible_cpu(cpu) {
-		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
-		IP6T_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
-				   zero_entry_counter, NULL);
-	}
-}
-
 static struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1015,30 +968,11 @@ static struct xt_counters *alloc_counters(struct xt_table *table)
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
+		return ERR_PTR(-ENOMEM);
 
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
-
-	clone_counters(info, private);
-
-	mutex_lock(&table->lock);
-	xt_table_entry_swap_rcu(private, info);
-	synchronize_net();	/* Wait until smoke has cleared */
-
-	get_counters(info, counters);
-	put_counters(private, counters);
-	mutex_unlock(&table->lock);
-
-	xt_free_table_info(info);
+	get_counters(private, counters);
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1334,8 +1268,9 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1405,11 +1340,24 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 	return ret;
 }
 
+/* We're lazy, and add to the first CPU; overflow works its fey magic
+ * and everything is OK. */
+static int
+add_counter_to_entry(struct ip6t_entry *e,
+		     const struct xt_counters addme[],
+		     unsigned int *i)
+{
+	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static int
 do_add_counters(struct net *net, void __user *user, unsigned int len,
 		int compat)
 {
-	unsigned int i;
+	unsigned int i, curcpu;
 	struct xt_counters_info tmp;
 	struct xt_counters *paddc;
 	unsigned int num_counters;
@@ -1465,25 +1413,28 @@ do_add_counters(struct net *net, void __user *user, unsigned int len,
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+
+	local_bh_disable();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	curcpu = smp_processor_id();
+	xt_info_wrlock(curcpu);
+	loc_cpu_entry = private->entries[curcpu];
 	IP6T_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+	xt_info_wrunlock(curcpu);
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
+	local_bh_enable();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 509a956..020e97b 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -625,20 +625,6 @@ void xt_free_table_info(struct xt_table_info *info)
 }
 EXPORT_SYMBOL(xt_free_table_info);
 
-void xt_table_entry_swap_rcu(struct xt_table_info *oldinfo,
-			     struct xt_table_info *newinfo)
-{
-	unsigned int cpu;
-
-	for_each_possible_cpu(cpu) {
-		void *p = oldinfo->entries[cpu];
-		rcu_assign_pointer(oldinfo->entries[cpu], newinfo->entries[cpu]);
-		newinfo->entries[cpu] = p;
-	}
-
-}
-EXPORT_SYMBOL_GPL(xt_table_entry_swap_rcu);
-
 /* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
 struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
 				    const char *name)
@@ -676,32 +662,43 @@ void xt_compat_unlock(u_int8_t af)
 EXPORT_SYMBOL_GPL(xt_compat_unlock);
 #endif
 
+DEFINE_PER_CPU(struct xt_info_lock, xt_info_locks);
+EXPORT_PER_CPU_SYMBOL_GPL(xt_info_locks);
+
+
 struct xt_table_info *
 xt_replace_table(struct xt_table *table,
 	      unsigned int num_counters,
 	      struct xt_table_info *newinfo,
 	      int *error)
 {
-	struct xt_table_info *oldinfo, *private;
+	struct xt_table_info *private;
 
 	/* Do the substitution. */
-	mutex_lock(&table->lock);
+	local_bh_disable();
 	private = table->private;
+
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		mutex_unlock(&table->lock);
+		local_bh_enable();
 		*error = -EAGAIN;
 		return NULL;
 	}
-	oldinfo = private;
-	rcu_assign_pointer(table->private, newinfo);
-	newinfo->initial_entries = oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
 
-	synchronize_net();
-	return oldinfo;
+	table->private = newinfo;
+	newinfo->initial_entries = private->initial_entries;
+
+	/*
+	 * Even though table entries have now been swapped, other CPU's
+	 * may still be using the old entries. This is okay, because
+	 * resynchronization happens because of the locking done
+	 * during the get_counters() routine.
+	 */
+	local_bh_enable();
+
+	return private;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
 
@@ -734,7 +731,6 @@ struct xt_table *xt_register_table(struct net *net, struct xt_table *table,
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
@@ -1147,7 +1143,11 @@ static struct pernet_operations xt_net_ops = {
 
 static int __init xt_init(void)
 {
-	int i, rv;
+	unsigned int i;
+	int rv;
+
+	for_each_possible_cpu(i)
+		spin_lock_init(&per_cpu(xt_info_locks, i).lock);
 
 	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
 	if (!xt)
