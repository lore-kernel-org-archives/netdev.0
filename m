From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  netfilter: use per-CPU recursive lock {XIV}
Date: Thu, 23 Apr 2009 21:09:38 -0700
Message-ID: <20090423210938.1501507b@nehalam>
References: <20090418094001.GA2369@ioremap.net>
	<20090418141455.GA7082@linux.vnet.ibm.com>
	<20090420103414.1b4c490f@nehalam>
	<49ECBE0A.7010303@cosmosbay.com>
	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>
	<20090420215827.GK6822@linux.vnet.ibm.com>
	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>
	<20090420160121.268a8226@nehalam>
	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
	<20090421111541.228e977a@nehalam>
	<20090421193924.GA24404@elte.hu>
	<20090421143927.52d7d89d@nehalam>
	<alpine.LFD.2.00.0904220821240.3101@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49215 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbZDXEJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 00:09:45 -0400
In-Reply-To: <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In days of old in 2.6.29, netfilter did locketh using a 
lock of the reader kind when doing its table business, and do
a writer when with pen in hand like a overworked accountant
did replace the tables. This sucketh and caused the single
lock to fly back and forth like a poor errant boy.

But then netfilter was blessed with RCU and the performance
was divine, but alas there were those that suffered for
trying to replace their many rules one at a time.

So now RCU must be vanquished from the scene, and better
chastity belts be placed upon this valuable asset most dear.
The locks that were but one are now replaced by one per suitor.

The repair was made after much discussion involving
Eric the wise, and Linus the foul. With flowers springing
up amid the thorns some peace has finally prevailed and
all is soothed. This patch and purple prose was penned by
in honor of "Talk like Shakespeare" day.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
What hath changed over the last two setting suns:
  * more words, mostly correct...

  * no need to locketh for writeh on current cpu tis 
    always so

  * the locking of all cpu's on replace is always done as
    part of the get_counters cycle, so the sychronize swip
    in replace tables is gone with only a comment remaing

 include/linux/netfilter/x_tables.h |   55 ++++++++++++++--
 net/ipv4/netfilter/arp_tables.c    |  125 ++++++++++--------------------------
 net/ipv4/netfilter/ip_tables.c     |  126 ++++++++++---------------------------
 net/ipv6/netfilter/ip6_tables.c    |  123 ++++++++++--------------------------
 net/netfilter/x_tables.c           |   55 ++++++++--------
 5 files changed, 188 insertions(+), 296 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-04-23 19:59:36.076558199 -0700
+++ b/include/linux/netfilter/x_tables.h	2009-04-23 20:22:06.566001575 -0700
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -434,8 +431,56 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
+
+/*
+ * Per-CPU read/write lock associated with per-cpu table entries.
+ * This is not a general solution but makes reader locking fast since
+ * there is no shared variable to cause cache ping-pong; but adds an
+ * additional write-side penalty since update must lock all
+ * possible CPU's.
+ *
+ * Read lock is used by ip/arp/ip6 tables rule processing which runs per-cpu.
+ * It needs to ensure that the rules are not being changed while packet
+ * is being processed. In some cases, the read lock will be acquired
+ * twice on the same CPU; this is okay because read locks handle nesting.
+ *
+ * Write lock is used in two cases:
+ *    1. reading counter values
+ *       all readers need to be stopped and the per-CPU values are summed.
+ *
+ *    2. replacing tables
+ *       any readers that are using the old tables have to complete
+ *       before freeing the old table. This is handled by reading
+ *	  as a side effect of reading counters
+ */
+DECLARE_PER_CPU(rwlock_t, xt_info_locks);
+
+static inline void xt_info_rdlock_bh(void)
+{
+	/*
+	 * Note: can not use read_lock_bh(&__get_cpu_var(xt_info_locks))
+	 * because need to ensure that preemption is disable before
+	 * acquiring per-cpu-variable, so do it as a two step process
+	 */
+	local_bh_disable();
+	read_lock(&__get_cpu_var(xt_info_locks));
+}
+
+static inline void xt_info_rdunlock_bh(void)
+{
+	read_unlock_bh(&__get_cpu_var(xt_info_locks));
+}
+
+static inline void xt_info_wrlock(unsigned int cpu)
+{
+	write_lock(&per_cpu(xt_info_locks, cpu));
+}
+
+static inline void xt_info_wrunlock(unsigned int cpu)
+{
+
+	write_unlock(&per_cpu(xt_info_locks, cpu));
+}
 
 /*
  * This helper is performance critical and must be inlined
--- a/net/ipv4/netfilter/arp_tables.c	2009-04-23 19:59:36.055558989 -0700
+++ b/net/ipv4/netfilter/arp_tables.c	2009-04-23 20:38:48.270239729 -0700
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
@@ -711,9 +711,12 @@ static void get_counters(const struct xt
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
@@ -726,73 +729,22 @@ static void get_counters(const struct xt
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
@@ -802,30 +754,11 @@ static struct xt_counters *alloc_counter
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
+	get_counters(private, counters);
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int copy_entries_to_user(unsigned int total_size,
@@ -1094,8 +1027,9 @@ static int __do_replace(struct net *net,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	ARPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1165,10 +1099,23 @@ static int do_replace(struct net *net, v
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
@@ -1224,26 +1171,26 @@ static int do_add_counters(struct net *n
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
--- a/net/ipv4/netfilter/ip_tables.c	2009-04-23 19:59:36.065578531 -0700
+++ b/net/ipv4/netfilter/ip_tables.c	2009-04-23 20:14:24.483579537 -0700
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
@@ -896,10 +894,13 @@ get_counters(const struct xt_table_info 
 
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
@@ -912,74 +913,22 @@ get_counters(const struct xt_table_info 
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
@@ -988,30 +937,11 @@ static struct xt_counters * alloc_counte
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
@@ -1306,8 +1236,9 @@ __do_replace(struct net *net, const char
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1377,11 +1308,23 @@ do_replace(struct net *net, void __user 
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
@@ -1437,25 +1380,26 @@ do_add_counters(struct net *net, void __
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
--- a/net/ipv6/netfilter/ip6_tables.c	2009-04-23 19:59:36.047577942 -0700
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-04-23 20:46:47.356237966 -0700
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
@@ -926,9 +926,12 @@ get_counters(const struct xt_table_info 
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
@@ -941,72 +944,22 @@ get_counters(const struct xt_table_info 
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
@@ -1015,30 +968,11 @@ static struct xt_counters *alloc_counter
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
-
-	get_counters(info, counters);
-	put_counters(private, counters);
-	mutex_unlock(&table->lock);
+		return ERR_PTR(-ENOMEM);
 
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
@@ -1334,8 +1268,9 @@ __do_replace(struct net *net, const char
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters. */
+	/* Get the old counters, and synchronize with replace */
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1405,11 +1340,24 @@ do_replace(struct net *net, void __user 
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
@@ -1465,25 +1413,28 @@ do_add_counters(struct net *net, void __
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
--- a/net/netfilter/x_tables.c	2009-04-23 19:59:36.038563216 -0700
+++ b/net/netfilter/x_tables.c	2009-04-23 20:09:04.809576277 -0700
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
@@ -676,32 +662,43 @@ void xt_compat_unlock(u_int8_t af)
 EXPORT_SYMBOL_GPL(xt_compat_unlock);
 #endif
 
+DEFINE_PER_CPU(rwlock_t, xt_info_locks);
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
 
@@ -734,7 +731,6 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
@@ -1147,7 +1143,16 @@ static struct pernet_operations xt_net_o
 
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
