From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Thu, 16 Apr 2009 16:52:33 -0700
Message-ID: <20090416165233.5d8bbfb5@nehalam>
References: <20090415170111.6e1ca264@nehalam>
	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	<49E72E83.50702@trash.net>
	<20090416.153354.170676392.davem@davemloft.net>
	<20090416234955.GL6924@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090416234955.GL6924@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This version of x_tables (ip/ip6/arp) locking uses a per-cpu
recursive lock that can be nested. It is sort of like existing kernel_lock,
rwlock_t and even old 2.4 brlock.

"Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
It needs to ensure that the rules are not being changed while packet
is being processed.

"Writer" is used in two cases: first is replacing rules in which case
all packets in flight have to be processed before rules are swapped,
then counters are read from the old (stale) info. Second case is where
counters need to be read on the fly, in this case all CPU's are blocked
from further rule processing until values are aggregated.

The idea for this came from an earlier version done by Eric Dumazet.
Locking is done per-cpu, the fast path locks on the current cpu
and updates counters.  This reduces the contention of a
single reader lock (in 2.6.29) without the delay of synchronize_net()
(in 2.6.30-rc2). 


The mutex that was added for 2.6.30 in xt_table is unnecessary since
there already is a mutex for xt[af].mutex that is held.

Future optimizations possible:
  - Lockdep doesn't really handle this well
  - hot plug CPU case, if kernel is built with large # of CPU's, skip
    the inactive ones; migrate values when CPU is removed.
  - reading counters could be incremental by CPU.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com

---
 include/linux/netfilter/x_tables.h |   10 +--
 net/ipv4/netfilter/arp_tables.c    |  110 ++++++++----------------------------
 net/ipv4/netfilter/ip_tables.c     |  110 +++++++-----------------------------
 net/ipv6/netfilter/ip6_tables.c    |  108 ++++++++---------------------------
 net/netfilter/x_tables.c           |  113 ++++++++++++++++++++++++++++++-------
 5 files changed, 170 insertions(+), 281 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-04-16 15:09:53.082406828 -0700
+++ b/include/linux/netfilter/x_tables.h	2009-04-16 15:10:17.154966874 -0700
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -434,8 +431,11 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
+
+extern void xt_table_info_lock(void);
+extern void xt_table_info_unlock(void);
+extern void xt_table_info_lock_all(void);
+extern void xt_table_info_unlock_all(void);
 
 /*
  * This helper is performance critical and must be inlined
--- a/net/ipv4/netfilter/ip_tables.c	2009-04-16 15:09:53.066406011 -0700
+++ b/net/ipv4/netfilter/ip_tables.c	2009-04-16 15:10:17.155966637 -0700
@@ -338,10 +338,9 @@ ipt_do_table(struct sk_buff *skb,
 	tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_table_info_lock();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -436,8 +435,7 @@ ipt_do_table(struct sk_buff *skb,
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	xt_table_info_unlock();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -918,60 +916,6 @@ get_counters(const struct xt_table_info 
 				  counters,
 				  &i);
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
-	local_bh_enable();
-}
-
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
 }
 
 static struct xt_counters * alloc_counters(struct xt_table *table)
@@ -979,7 +923,6 @@ static struct xt_counters * alloc_counte
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -988,30 +931,13 @@ static struct xt_counters * alloc_counte
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
-
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
-
-	clone_counters(info, private);
+		return ERR_PTR(-ENOMEM);
 
-	mutex_lock(&table->lock);
-	xt_table_entry_swap_rcu(private, info);
-	synchronize_net();	/* Wait until smoke has cleared */
-
-	get_counters(info, counters);
-	put_counters(private, counters);
-	mutex_unlock(&table->lock);
-
-	xt_free_table_info(info);
+	xt_table_info_lock_all();
+	get_counters(private, counters);
+	xt_table_info_unlock_all();
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1377,6 +1303,18 @@ do_replace(struct net *net, void __user 
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
@@ -1437,25 +1375,23 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+	xt_table_info_lock_all();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries[smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
  unlock_up_free:
-	mutex_unlock(&t->lock);
+	xt_table_info_unlock_all();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-04-16 15:09:53.028984288 -0700
+++ b/net/netfilter/x_tables.c	2009-04-16 16:35:36.996150064 -0700
@@ -625,20 +625,6 @@ void xt_free_table_info(struct xt_table_
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
@@ -676,6 +662,90 @@ void xt_compat_unlock(u_int8_t af)
 EXPORT_SYMBOL_GPL(xt_compat_unlock);
 #endif
 
+struct xt_lock {
+	spinlock_t lock;
+	int   	   depth;	/* # readers - 1 */
+};
+
+static DEFINE_PER_CPU(struct xt_lock, xt_info_locks);
+
+static void xt_lock_init(struct xt_lock *lock)
+{
+	spin_lock_init(&lock->lock);
+	lock->depth = -1;
+}
+
+/**
+ * xt_table_info_lock - recursive read lock for xt table info
+ *
+ * Used for current CPU to read table and update counters.
+ * Allows recursive locking, on same CPU.
+ */
+void xt_table_info_lock(void)
+{
+	struct xt_lock *lock;
+
+	preempt_disable();
+	lock = &__get_cpu_var(xt_info_locks);
+	if (likely(++lock->depth == 0))
+		spin_lock(&lock->lock);
+}
+EXPORT_SYMBOL_GPL(xt_table_info_lock);
+
+/**
+ * xt_table_info_unlock - release recursive table info lock
+ *
+ * Used after read table and update counters.
+ */
+void xt_table_info_unlock(void)
+{
+	struct xt_lock *lock = &__get_cpu_var(xt_info_locks);
+
+	BUG_ON(lock->depth < 0);
+	if (likely(--lock->depth < 0))
+		spin_unlock(&lock->lock);
+	preempt_enable();
+}
+EXPORT_SYMBOL_GPL(xt_table_info_unlock);
+
+
+/**
+ * xt_table_info_lock_all - lock xt table info for update
+ *
+ * Locks out all readers, and blocks bottom half
+ */
+void xt_table_info_lock_all(void)
+{
+	int i;
+
+	local_bh_disable();
+	for_each_possible_cpu(i) {
+		struct xt_lock *lock = &per_cpu(xt_info_locks, i);
+		spin_lock(&lock->lock);
+		BUG_ON(lock->depth != -1);
+	}
+}
+EXPORT_SYMBOL_GPL(xt_table_info_lock_all);
+
+/**
+ * xt_table_info_unlock_all - lock xt table info for update
+ *
+ * Unlocks all readers, and unblocks bottom half
+ */
+void xt_table_info_unlock_all(void)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct xt_lock *lock = &per_cpu(xt_info_locks, i);
+		BUG_ON(lock->depth != -1);
+		spin_unlock(&lock->lock);
+	}
+	local_bh_enable();
+}
+EXPORT_SYMBOL_GPL(xt_table_info_unlock_all);
+
+
 struct xt_table_info *
 xt_replace_table(struct xt_table *table,
 	      unsigned int num_counters,
@@ -685,22 +755,21 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *oldinfo, *private;
 
 	/* Do the substitution. */
-	mutex_lock(&table->lock);
+	xt_table_info_lock_all();
 	private = table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		mutex_unlock(&table->lock);
+		xt_table_info_unlock_all();
 		*error = -EAGAIN;
 		return NULL;
 	}
 	oldinfo = private;
-	rcu_assign_pointer(table->private, newinfo);
-	newinfo->initial_entries = oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
+	table->private =  newinfo;
+	newinfo->initial_entries = private->initial_entries;
+	xt_table_info_unlock_all();
 
-	synchronize_net();
 	return oldinfo;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
@@ -734,7 +803,6 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
@@ -1149,6 +1217,9 @@ static int __init xt_init(void)
 {
 	int i, rv;
 
+	for_each_possible_cpu(i)
+		xt_lock_init(&per_cpu(xt_info_locks, i));
+
 	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
 	if (!xt)
 		return -ENOMEM;
--- a/net/ipv6/netfilter/ip6_tables.c	2009-04-16 15:09:53.041965912 -0700
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-04-16 15:10:17.158972154 -0700
@@ -365,9 +365,9 @@ ip6t_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_table_info_lock();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -466,7 +466,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	rcu_read_unlock_bh();
+	xt_table_info_unlock();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -949,64 +949,11 @@ get_counters(const struct xt_table_info 
 	}
 }
 
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
-	local_bh_enable();
-}
-
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
@@ -1015,30 +962,13 @@ static struct xt_counters *alloc_counter
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
-
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
+		return ERR_PTR(-ENOMEM);
 
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
+	xt_table_info_lock_all();
+	get_counters(private, counters);
+	xt_table_info_unlock_all();
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1405,6 +1335,19 @@ do_replace(struct net *net, void __user 
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
@@ -1465,25 +1408,24 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+	xt_table_info_lock_all();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	loc_cpu_entry = private->entries[smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
+	xt_table_info_unlock_all();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/arp_tables.c	2009-04-16 15:09:53.052406917 -0700
+++ b/net/ipv4/netfilter/arp_tables.c	2009-04-16 15:10:17.160029716 -0700
@@ -253,9 +253,9 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	xt_table_info_lock();
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -273,6 +273,7 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
+
 			ADD_COUNTER(e->counters, hdr_len, 1);
 
 			t = arpt_get_target(e);
@@ -328,8 +329,7 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	xt_table_info_unlock();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -734,65 +734,11 @@ static void get_counters(const struct xt
 	}
 }
 
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
-	local_bh_enable();
-}
-
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
@@ -802,30 +748,13 @@ static struct xt_counters *alloc_counter
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		goto nomem;
-
-	info = xt_alloc_table_info(private->size);
-	if (!info)
-		goto free_counters;
+		return ERR_PTR(-ENOMEM);
 
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
+	xt_table_info_lock_all();
+	get_counters(private, counters);
+	xt_table_info_unlock_all();
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int copy_entries_to_user(unsigned int total_size,
@@ -1165,6 +1094,19 @@ static int do_replace(struct net *net, v
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
@@ -1224,14 +1166,13 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
+	xt_table_info_lock_all();
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
 	loc_cpu_entry = private->entries[smp_processor_id()];
@@ -1240,10 +1181,9 @@ static int do_add_counters(struct net *n
 			   add_counter_to_entry,
 			   paddc,
 			   &i);
-	preempt_enable();
- unlock_up_free:
-	mutex_unlock(&t->lock);
 
+ unlock_up_free:
+	xt_table_info_unlock_all();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
