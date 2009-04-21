From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 11:15:41 -0700
Message-ID: <20090421111541.228e977a@nehalam>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	<49E72E83.50702@trash.net>
	<20090416.153354.170676392.davem@davemloft.net>
	<20090416234955.GL6924@linux.vnet.ibm.com>
	<20090417012812.GA25534@linux.vnet.ibm.com>
	<20090418094001.GA2369@ioremap.net>
	<20090418141455.GA7082@linux.vnet.ibm.com>
	<20090420103414.1b4c490f@nehalam>
	<49ECBE0A.7010303@cosmosbay.com>
	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>
	<20090420215827.GK6822@linux.vnet.ibm.com>
	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>
	<20090420160121.268a8226@nehalam>
	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: netfilter: use per-cpu recursive lock (v12)

This version of x_tables (ip/ip6/arp) locking uses a per-cpu
recursive lock that can be nested.

The idea for this came from an earlier version done by Eric Dumazet.
Locking is done per-cpu, the fast path locks on the current cpu
and updates counters.  This reduces the contention of a
single reader lock (in 2.6.29) without the delay of synchronize_net()
(in 2.6.30-rc2). 

The mutex that was added for 2.6.30 in xt_table is unnecessary since
there already is a mutex for xt[af].mutex that is held.

I don't like the NR_CPUS preempt count kludge, it is working around an
issue that should be handled in a more generic way.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com

---
CHANGES 
  - go back to read/write lock
  - reader case is now inline
  - more comments
  - always disables bottom half
  - only play preempt count mindgames if really necessary
  - add lockdep keys

 include/linux/netfilter/x_tables.h |   42 ++++++++++++--
 net/ipv4/netfilter/arp_tables.c    |  110 ++++++++-----------------------------
 net/ipv4/netfilter/ip_tables.c     |  110 +++++++------------------------------
 net/ipv6/netfilter/ip6_tables.c    |  108 ++++++++----------------------------
 net/netfilter/x_tables.c           |   77 ++++++++++++++++++-------
 5 files changed, 165 insertions(+), 282 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-04-21 07:57:06.668582345 -0700
+++ b/include/linux/netfilter/x_tables.h	2009-04-21 11:06:10.381487605 -0700
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -434,8 +431,43 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
+
+
+/*
+ * Per-CPU read/write lock. This makes reader locking fast since
+ * there is no shared variable to cause cache ping-pong; but adds an
+ * additional write-side penalty since write must iterate over all
+ * possible CPU's. Readers read lock their per-cpu lock, and writers
+ * write lock on all CPU's.
+ *
+ * Read lock is used by ip/arp/ip6 tables rule processing which runs per-cpu.
+ * It needs to ensure that the rules are not being changed while packet
+ * is being processed.
+ *
+ * Write lock is used in two cases:
+ *    1. reading counter values
+ *       all readers need to be stopped and the per-CPU values are summed.
+ *
+ *    2. replacing rules
+ *       all packets in flight have to be processed before rules are swapped,
+ *       then counters are read from the old (stale) info.
+ *
+ */
+DECLARE_PER_CPU(rwlock_t, xt_info_locks);
+
+static inline void xt_info_rdlock_bh(void)
+{
+	local_bh_disable();
+	read_lock(&__get_cpu_var(xt_info_locks));
+}
+
+static inline void xt_info_rdunlock_bh(void)
+{
+	read_unlock_bh(&__get_cpu_var(xt_info_locks));
+}
+
+extern void xt_info_wrlock_bh(void);
+extern void xt_info_wrunlock_bh(void);
 
 /*
  * This helper is performance critical and must be inlined
--- a/net/ipv4/netfilter/ip_tables.c	2009-04-21 07:57:06.649549203 -0700
+++ b/net/ipv4/netfilter/ip_tables.c	2009-04-21 08:13:36.133673244 -0700
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
+	xt_info_wrlock_bh();
+	get_counters(private, counters);
+	xt_info_wrunlock_bh();
 
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
+	xt_info_wrlock_bh();
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
+	xt_info_wrunlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-04-21 07:57:06.605264365 -0700
+++ b/net/netfilter/x_tables.c	2009-04-21 11:08:00.526402956 -0700
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
@@ -676,6 +662,46 @@ void xt_compat_unlock(u_int8_t af)
 EXPORT_SYMBOL_GPL(xt_compat_unlock);
 #endif
 
+DEFINE_PER_CPU(rwlock_t, xt_info_locks);
+EXPORT_PER_CPU_SYMBOL_GPL(xt_info_locks);
+
+void xt_info_wrlock_bh(void)
+{
+	unsigned int i;
+
+	local_bh_disable();
+	for_each_possible_cpu(i) {
+		write_lock(&per_cpu(xt_info_locks, i));
+#if NR_CPUS > (PREEMPT_MASK - 1)
+		/*
+		 * Since spin_lock disables preempt, the following is
+		 * required to avoid overflowing the preempt counter
+		 */
+		preempt_enable_no_resched();
+#endif
+	}
+}
+EXPORT_SYMBOL_GPL(xt_info_wrlock_bh);
+
+void xt_info_wrunlock_bh(void)
+	__releases(xt_info_lock)
+{
+	unsigned int i;
+
+	for_each_possible_cpu(i) {
+#if NR_CPUS > (PREEMPT_MASK - 1)
+		/*
+		 * Spin_unlock calls preempt_enable, but since we had
+		 * to adjust the count in xt_info_wrlock_bh, do it again
+		 */
+		preempt_disable();
+#endif
+		write_unlock(&per_cpu(xt_info_locks, i));
+	}
+	local_bh_enable();
+}
+EXPORT_SYMBOL_GPL(xt_info_wrunlock_bh);
+
 struct xt_table_info *
 xt_replace_table(struct xt_table *table,
 	      unsigned int num_counters,
@@ -685,22 +711,21 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *oldinfo, *private;
 
 	/* Do the substitution. */
-	mutex_lock(&table->lock);
+	xt_info_wrlock_bh();
 	private = table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		mutex_unlock(&table->lock);
+		xt_info_wrunlock_bh();
 		*error = -EAGAIN;
 		return NULL;
 	}
 	oldinfo = private;
-	rcu_assign_pointer(table->private, newinfo);
-	newinfo->initial_entries = oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
+	table->private =  newinfo;
+	newinfo->initial_entries = private->initial_entries;
+	xt_info_wrunlock_bh();
 
-	synchronize_net();
 	return oldinfo;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
@@ -734,7 +759,6 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
@@ -1147,7 +1171,16 @@ static struct pernet_operations xt_net_o
 
 static int __init xt_init(void)
 {
-	int i, rv;
+	unsigned int i;
+	int rv;
+	static struct lock_class_key xt_lock_key[NR_CPUS];
+
+	for_each_possible_cpu(i) {
+		rwlock_t *lock = &per_cpu(xt_info_locks, i);
+
+		rwlock_init(lock);
+		lockdep_set_class(lock, xt_lock_key+i);
+	}
 
 	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
 	if (!xt)
--- a/net/ipv6/netfilter/ip6_tables.c	2009-04-21 07:57:06.621260619 -0700
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-04-21 08:13:36.160551552 -0700
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
+	xt_info_wrlock_bh();
+	get_counters(private, counters);
+	xt_info_wrunlock_bh();
 
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
+	xt_info_wrlock_bh();
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
+	xt_info_wrunlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/arp_tables.c	2009-04-21 07:57:06.633261308 -0700
+++ b/net/ipv4/netfilter/arp_tables.c	2009-04-21 08:13:36.163555922 -0700
@@ -253,9 +253,9 @@ unsigned int arpt_do_table(struct sk_buf
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
+	xt_info_rdunlock_bh();
 
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
+	xt_info_wrlock_bh();
+	get_counters(private, counters);
+	xt_info_wrunlock_bh();
 
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
+	xt_info_wrlock_bh();
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
+	xt_info_wrunlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
