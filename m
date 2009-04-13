From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 09:53:09 -0700
Message-ID: <20090413095309.631cf395@nehalam>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48001 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbZDMQxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 12:53:17 -0400
In-Reply-To: <20090413040413.GQ6822@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an alternative version of ip/ip6/arp tables locking using
per-cpu locks.  This avoids the overhead of synchronize_net() during
update but still removes the expensive rwlock in earlier versions.

The idea for this came from an earlier version done by Eric Duzamet.
Locking is done per-cpu, the fast path locks on the current cpu
and updates counters.  The slow case involves acquiring the locks on
all cpu's.

The mutex that was added for 2.6.30 in xt_table is unnecessary since
there already is a mutex for xt[af].mutex that is held.

Tested basic functionality (add/remove/list), but don't have test cases
for stress, ip6tables or arptables.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against 2.6.30-rc1

 include/linux/netfilter/x_tables.h |    5 -
 net/ipv4/netfilter/arp_tables.c    |  122 ++++++++++------------------------
 net/ipv4/netfilter/ip_tables.c     |  129 +++++++++++--------------------------
 net/ipv6/netfilter/ip6_tables.c    |  127 +++++++++++-------------------------
 net/netfilter/x_tables.c           |   21 ------
 5 files changed, 116 insertions(+), 288 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-04-13 08:27:45.698412446 -0700
+++ b/include/linux/netfilter/x_tables.h	2009-04-13 08:34:05.499348295 -0700
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -434,8 +431,6 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
 
 /*
  * This helper is performance critical and must be inlined
--- a/net/ipv4/netfilter/ip_tables.c	2009-04-13 08:27:45.684411824 -0700
+++ b/net/ipv4/netfilter/ip_tables.c	2009-04-13 09:12:54.295536361 -0700
@@ -297,6 +297,8 @@ static void trace_packet(struct sk_buff 
 }
 #endif
 
+static DEFINE_PER_CPU(spinlock_t, ip_tables_lock);
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ipt_do_table(struct sk_buff *skb,
@@ -339,9 +341,10 @@ ipt_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	local_bh_disable();
+	spin_lock(&__get_cpu_var(ip_tables_lock));
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -436,8 +439,8 @@ ipt_do_table(struct sk_buff *skb,
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	spin_unlock(&__get_cpu_var(ip_tables_lock));
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -891,86 +894,34 @@ get_counters(const struct xt_table_info 
 	     struct xt_counters counters[])
 {
 	unsigned int cpu;
-	unsigned int i;
-	unsigned int curcpu;
+	unsigned int i = 0;
+	unsigned int curcpu = raw_smp_processor_id();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
 	 * with data used by 'current' CPU
 	 * We dont care about preemption here.
 	 */
-	curcpu = raw_smp_processor_id();
-
-	i = 0;
+	spin_lock_bh(&per_cpu(ip_tables_lock, curcpu));
 	IPT_ENTRY_ITERATE(t->entries[curcpu],
 			  t->size,
 			  set_entry_to_counter,
 			  counters,
 			  &i);
+	spin_unlock_bh(&per_cpu(ip_tables_lock, curcpu));
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
+
 		i = 0;
+		spin_lock_bh(&per_cpu(ip_tables_lock, cpu));
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
-	}
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
+		spin_unlock_bh(&per_cpu(ip_tables_lock, cpu));
 	}
 }
 
@@ -979,7 +930,6 @@ static struct xt_counters * alloc_counte
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -990,26 +940,10 @@ static struct xt_counters * alloc_counte
 	if (counters == NULL)
 		goto nomem;
 
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
 
- free_counters:
-	vfree(counters);
  nomem:
 	return ERR_PTR(-ENOMEM);
 }
@@ -1377,6 +1311,18 @@ do_replace(struct net *net, void __user 
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
@@ -1386,7 +1332,7 @@ do_add_counters(struct net *net, void __
 	struct xt_counters *paddc;
 	unsigned int num_counters;
 	const char *name;
-	int size;
+	int curcpu, size;
 	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
@@ -1437,25 +1383,27 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
+	local_bh_disable();
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	curcpu = smp_processor_id();
+	spin_lock(&__get_cpu_var(ip_tables_lock));
+	loc_cpu_entry = private->entries[curcpu];
 	IPT_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+	spin_unlock(&__get_cpu_var(ip_tables_lock));
+	local_bh_enable();
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
@@ -2272,7 +2220,10 @@ static struct pernet_operations ip_table
 
 static int __init ip_tables_init(void)
 {
-	int ret;
+	int cpu, ret;
+
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&per_cpu(ip_tables_lock, cpu));
 
 	ret = register_pernet_subsys(&ip_tables_net_ops);
 	if (ret < 0)
--- a/net/netfilter/x_tables.c	2009-04-13 08:27:45.671412509 -0700
+++ b/net/netfilter/x_tables.c	2009-04-13 09:19:51.687537585 -0700
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
@@ -685,22 +671,18 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *oldinfo, *private;
 
 	/* Do the substitution. */
-	mutex_lock(&table->lock);
 	private = table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		mutex_unlock(&table->lock);
 		*error = -EAGAIN;
 		return NULL;
 	}
 	oldinfo = private;
-	rcu_assign_pointer(table->private, newinfo);
+	table->private = newinfo;
 	newinfo->initial_entries = oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
 
-	synchronize_net();
 	return oldinfo;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
@@ -734,7 +716,6 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
--- a/net/ipv6/netfilter/ip6_tables.c	2009-04-13 08:37:58.189723514 -0700
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-04-13 09:14:26.576349680 -0700
@@ -329,6 +329,8 @@ static void trace_packet(struct sk_buff 
 }
 #endif
 
+static DEFINE_PER_CPU(spinlock_t, ip6_tables_lock);
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ip6t_do_table(struct sk_buff *skb,
@@ -365,9 +367,10 @@ ip6t_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	local_bh_disable();
+	spin_lock(&__get_cpu_var(ip6_tables_lock));
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -466,7 +469,8 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	rcu_read_unlock_bh();
+	spin_unlock(&__get_cpu_var(ip6_tables_lock));
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -920,84 +924,33 @@ get_counters(const struct xt_table_info 
 	     struct xt_counters counters[])
 {
 	unsigned int cpu;
-	unsigned int i;
-	unsigned int curcpu;
+	unsigned int i = 0;
+	unsigned int curcpu = raw_smp_processor_id();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
 	 * with data used by 'current' CPU
 	 * We dont care about preemption here.
 	 */
-	curcpu = raw_smp_processor_id();
-
-	i = 0;
+	spin_lock_bh(&per_cpu(ip6_tables_lock, curcpu));
 	IP6T_ENTRY_ITERATE(t->entries[curcpu],
 			   t->size,
 			   set_entry_to_counter,
 			   counters,
 			   &i);
+	spin_unlock_bh(&per_cpu(ip6_tables_lock, curcpu));
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
+		spin_lock_bh(&per_cpu(ip6_tables_lock, cpu));
 		IP6T_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
-	}
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
+		spin_unlock_bh(&per_cpu(ip6_tables_lock, cpu));
 	}
 }
 
@@ -1006,7 +959,6 @@ static struct xt_counters *alloc_counter
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1017,26 +969,9 @@ static struct xt_counters *alloc_counter
 	if (counters == NULL)
 		goto nomem;
 
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
-
+	get_counters(private, counters);
 	return counters;
 
- free_counters:
-	vfree(counters);
  nomem:
 	return ERR_PTR(-ENOMEM);
 }
@@ -1405,6 +1340,19 @@ do_replace(struct net *net, void __user 
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
@@ -1414,7 +1362,7 @@ do_add_counters(struct net *net, void __
 	struct xt_counters *paddc;
 	unsigned int num_counters;
 	char *name;
-	int size;
+	int curcpu, size;
 	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
@@ -1465,25 +1413,27 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
+	local_bh_disable();
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	curcpu = smp_processor_id();
+	spin_lock(&__get_cpu_var(ip6_tables_lock));
+	loc_cpu_entry = private->entries[curcpu];
 	IP6T_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+	spin_unlock(&__get_cpu_var(ip6_tables_lock));
+	local_bh_enable();
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
@@ -2298,7 +2248,10 @@ static struct pernet_operations ip6_tabl
 
 static int __init ip6_tables_init(void)
 {
-	int ret;
+	int cpu, ret;
+
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&per_cpu(ip6_tables_lock, cpu));
 
 	ret = register_pernet_subsys(&ip6_tables_net_ops);
 	if (ret < 0)
--- a/net/ipv4/netfilter/arp_tables.c	2009-04-13 08:38:05.803598692 -0700
+++ b/net/ipv4/netfilter/arp_tables.c	2009-04-13 09:19:57.079411426 -0700
@@ -231,6 +231,8 @@ static inline struct arpt_entry *get_ent
 	return (struct arpt_entry *)(base + offset);
 }
 
+static DEFINE_PER_CPU(spinlock_t, arp_tables_lock);
+
 unsigned int arpt_do_table(struct sk_buff *skb,
 			   unsigned int hook,
 			   const struct net_device *in,
@@ -253,9 +255,10 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	rcu_read_lock_bh();
-	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	local_bh_disable();
+	spin_lock(&__get_cpu_var(arp_tables_lock));
+	private = table->private;
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -328,8 +331,8 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
-	rcu_read_unlock_bh();
+	spin_unlock(&__get_cpu_var(arp_tables_lock));
+	local_bh_enable();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -705,85 +708,33 @@ static void get_counters(const struct xt
 			 struct xt_counters counters[])
 {
 	unsigned int cpu;
-	unsigned int i;
-	unsigned int curcpu;
+	unsigned int i = 0;
+	unsigned int curcpu = raw_smp_processor_id();
 
 	/* Instead of clearing (by a previous call to memset())
 	 * the counters and using adds, we set the counters
 	 * with data used by 'current' CPU
 	 * We dont care about preemption here.
 	 */
-	curcpu = raw_smp_processor_id();
-
-	i = 0;
+	spin_lock_bh(&per_cpu(arp_tables_lock, curcpu));
 	ARPT_ENTRY_ITERATE(t->entries[curcpu],
 			   t->size,
 			   set_entry_to_counter,
 			   counters,
 			   &i);
+	spin_unlock_bh(&per_cpu(arp_tables_lock, curcpu));
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
+		spin_lock_bh(&per_cpu(arp_tables_lock, cpu));
 		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
 				   counters,
 				   &i);
-	}
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
+		spin_unlock_bh(&per_cpu(arp_tables_lock, cpu));
 	}
 }
 
@@ -792,7 +743,6 @@ static struct xt_counters *alloc_counter
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -804,26 +754,10 @@ static struct xt_counters *alloc_counter
 	if (counters == NULL)
 		goto nomem;
 
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
 
- free_counters:
-	vfree(counters);
  nomem:
 	return ERR_PTR(-ENOMEM);
 }
@@ -1165,6 +1099,19 @@ static int do_replace(struct net *net, v
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
@@ -1173,7 +1120,7 @@ static int do_add_counters(struct net *n
 	struct xt_counters *paddc;
 	unsigned int num_counters;
 	const char *name;
-	int size;
+	int curcpu, size;
 	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
@@ -1224,25 +1171,26 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
 	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[smp_processor_id()];
+	local_bh_disable();
+	curcpu = smp_processor_id();
+	spin_lock(&__get_cpu_var(arp_tables_lock));
+	loc_cpu_entry = private->entries[curcpu];
 	ARPT_ENTRY_ITERATE(loc_cpu_entry,
 			   private->size,
 			   add_counter_to_entry,
 			   paddc,
 			   &i);
-	preempt_enable();
+	spin_unlock(&__get_cpu_var(arp_tables_lock));
+	local_bh_enable();
  unlock_up_free:
-	mutex_unlock(&t->lock);
 
 	xt_table_unlock(t);
 	module_put(t->me);
