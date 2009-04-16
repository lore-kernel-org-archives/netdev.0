From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netfilter: use per-cpu spinlock and RCU (v5)
Date: Wed, 15 Apr 2009 17:45:51 -0700
Message-ID: <20090415174551.529d241c@nehalam>
References: <49E5BDF7.8090502@trash.net>
	<20090415135526.2afc4d18@nehalam>
	<49E64C91.5020708@cosmosbay.com>
	<20090415.164811.19905145.davem@davemloft.net>
	<20090415170111.6e1ca264@nehalam>
	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	kaber@trash.net, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an alternative version of ip/ip6/arp tables locking using
per-cpu locks.  This avoids the overhead of synchronize_net() during
update but still removes the expensive rwlock in earlier versions.

The idea for this came from an earlier version done by Eric Dumazet.
Locking is done per-cpu, the fast path locks on the current cpu
and updates counters.  The slow case involves acquiring the locks on
all cpu's. This version uses RCU for the table->base reference
but per-cpu-lock for counters.

The mutex that was added for 2.6.30 in xt_table is unnecessary since
there already is a mutex for xt[af].mutex that is held.

This version does not do coarse locking or synchronize_net() during
the __do_replace function, so there is a small race which allows for
some of the old counter values to be incorrect (Ncpu -1). Scenario
would be replacing a rule set and the same rules are inflight on other
CPU.  The other CPU might still be looking at the old rules (and
update those counters), after counter values have been captured.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netfilter/x_tables.h |   11 +--
 net/ipv4/netfilter/arp_tables.c    |  121 +++++++++++--------------------------
 net/ipv4/netfilter/ip_tables.c     |  121 ++++++++++---------------------------
 net/ipv6/netfilter/ip6_tables.c    |  118 +++++++++++-------------------------
 net/netfilter/x_tables.c           |   45 +++++++------
 5 files changed, 137 insertions(+), 279 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-04-15 08:44:01.449318844 -0700
+++ b/include/linux/netfilter/x_tables.h	2009-04-15 17:08:35.303217128 -0700
@@ -354,9 +354,6 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	struct mutex lock;
-
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
 
@@ -385,6 +382,12 @@ struct xt_table_info
 	unsigned int hook_entry[NF_INET_NUMHOOKS];
 	unsigned int underflow[NF_INET_NUMHOOKS];
 
+	/* Slow death march */
+	union {
+		struct rcu_head rcu;
+		struct work_struct work;
+	};
+
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
 	void *entries[1];
@@ -434,8 +437,6 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
-extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
-				    struct xt_table_info *new);
 
 /*
  * This helper is performance critical and must be inlined
--- a/net/ipv4/netfilter/ip_tables.c	2009-04-15 08:44:01.441318723 -0700
+++ b/net/ipv4/netfilter/ip_tables.c	2009-04-15 17:09:49.600404319 -0700
@@ -297,6 +297,8 @@ static void trace_packet(struct sk_buff 
 }
 #endif
 
+static DEFINE_PER_CPU(spinlock_t, ip_tables_lock);
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ipt_do_table(struct sk_buff *skb,
@@ -341,7 +343,7 @@ ipt_do_table(struct sk_buff *skb,
 
 	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -358,7 +360,9 @@ ipt_do_table(struct sk_buff *skb,
 			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+			spin_lock(&__get_cpu_var(ip_tables_lock));
 			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+			spin_unlock(&__get_cpu_var(ip_tables_lock));
 
 			t = ipt_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -436,9 +440,9 @@ ipt_do_table(struct sk_buff *skb,
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
 	rcu_read_unlock_bh();
 
+
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
@@ -902,75 +906,25 @@ get_counters(const struct xt_table_info 
 	curcpu = raw_smp_processor_id();
 
 	i = 0;
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
 
@@ -979,7 +933,6 @@ static struct xt_counters * alloc_counte
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -988,30 +941,11 @@ static struct xt_counters * alloc_counte
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
+	get_counters(private, counters);
 
 	return counters;
-
- free_counters:
-	vfree(counters);
- nomem:
-	return ERR_PTR(-ENOMEM);
 }
 
 static int
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
+	int cpu, size;
 	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
@@ -1437,25 +1383,25 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
-	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	cpu = raw_smp_processor_id();
+	spin_lock_bh(&per_cpu(ip_tables_lock, cpu));
+	loc_cpu_entry = private->entries[cpu];
+	i = 0;
 	IPT_ENTRY_ITERATE(loc_cpu_entry,
 			  private->size,
 			  add_counter_to_entry,
 			  paddc,
 			  &i);
-	preempt_enable();
+	spin_unlock_bh(&per_cpu(ip_tables_lock, cpu));
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
@@ -2272,7 +2218,10 @@ static struct pernet_operations ip_table
 
 static int __init ip_tables_init(void)
 {
-	int ret;
+	int cpu, ret;
+
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&per_cpu(ip_tables_lock, cpu));
 
 	ret = register_pernet_subsys(&ip_tables_net_ops);
 	if (ret < 0)
--- a/net/netfilter/x_tables.c	2009-04-15 08:44:01.424319035 -0700
+++ b/net/netfilter/x_tables.c	2009-04-15 17:10:24.967344496 -0700
@@ -66,6 +66,8 @@ static const char *const xt_prefix[NFPRO
 	[NFPROTO_IPV6]   = "ip6",
 };
 
+static void __xt_free_table_info(struct xt_table_info *);
+
 /* Registration hooks for targets. */
 int
 xt_register_target(struct xt_target *target)
@@ -602,7 +604,7 @@ struct xt_table_info *xt_alloc_table_inf
 							cpu_to_node(cpu));
 
 		if (newinfo->entries[cpu] == NULL) {
-			xt_free_table_info(newinfo);
+			__xt_free_table_info(newinfo);
 			return NULL;
 		}
 	}
@@ -611,7 +613,7 @@ struct xt_table_info *xt_alloc_table_inf
 }
 EXPORT_SYMBOL(xt_alloc_table_info);
 
-void xt_free_table_info(struct xt_table_info *info)
+static void __xt_free_table_info(struct xt_table_info *info)
 {
 	int cpu;
 
@@ -623,21 +625,28 @@ void xt_free_table_info(struct xt_table_
 	}
 	kfree(info);
 }
-EXPORT_SYMBOL(xt_free_table_info);
 
-void xt_table_entry_swap_rcu(struct xt_table_info *oldinfo,
-			     struct xt_table_info *newinfo)
+static void __xt_free_table_info_wq(struct work_struct *arg)
 {
-	unsigned int cpu;
+	struct xt_table_info *info
+		= container_of(arg, struct xt_table_info, work);
+	__xt_free_table_info(info);
+}
 
-	for_each_possible_cpu(cpu) {
-		void *p = oldinfo->entries[cpu];
-		rcu_assign_pointer(oldinfo->entries[cpu], newinfo->entries[cpu]);
-		newinfo->entries[cpu] = p;
-	}
+static void __xt_free_table_info_rcu(struct rcu_head *arg)
+{
+	struct xt_table_info *info
+		= container_of(arg, struct xt_table_info, rcu);
 
+	INIT_WORK(&info->work, __xt_free_table_info_wq);
+	schedule_work(&info->work);
 }
-EXPORT_SYMBOL_GPL(xt_table_entry_swap_rcu);
+
+void xt_free_table_info(struct xt_table_info *info)
+{
+	call_rcu(&info->rcu, __xt_free_table_info_rcu);
+}
+EXPORT_SYMBOL(xt_free_table_info);
 
 /* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
 struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
@@ -682,26 +691,21 @@ xt_replace_table(struct xt_table *table,
 	      struct xt_table_info *newinfo,
 	      int *error)
 {
-	struct xt_table_info *oldinfo, *private;
+	struct xt_table_info *private;
 
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
-	oldinfo = private;
 	rcu_assign_pointer(table->private, newinfo);
-	newinfo->initial_entries = oldinfo->initial_entries;
-	mutex_unlock(&table->lock);
+	newinfo->initial_entries = private->initial_entries;
 
-	synchronize_net();
-	return oldinfo;
+	return private;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
 
@@ -734,7 +738,6 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	mutex_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
--- a/net/ipv6/netfilter/ip6_tables.c	2009-04-15 08:44:01.430318746 -0700
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-04-15 17:11:37.663345565 -0700
@@ -329,6 +329,8 @@ static void trace_packet(struct sk_buff 
 }
 #endif
 
+static DEFINE_PER_CPU(spinlock_t, ip6_tables_lock);
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ip6t_do_table(struct sk_buff *skb,
@@ -367,7 +369,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -384,9 +386,12 @@ ip6t_do_table(struct sk_buff *skb,
 			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+
+			spin_lock(&__get_cpu_var(ip6_tables_lock));
 			ADD_COUNTER(e->counters,
 				    ntohs(ipv6_hdr(skb)->payload_len) +
 				    sizeof(struct ipv6hdr), 1);
+			spin_unlock(&__get_cpu_var(ip6_tables_lock));
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -931,73 +936,25 @@ get_counters(const struct xt_table_info 
 	curcpu = raw_smp_processor_id();
 
 	i = 0;
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
 
@@ -1006,7 +963,6 @@ static struct xt_counters *alloc_counter
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1015,30 +971,11 @@ static struct xt_counters *alloc_counter
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
@@ -1405,6 +1342,19 @@ do_replace(struct net *net, void __user 
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
@@ -1465,25 +1415,26 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
-	i = 0;
+	local_bh_disable();
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[raw_smp_processor_id()];
+	spin_lock(&__get_cpu_var(ip6_tables_lock));
+	loc_cpu_entry = private->entries[smp_processor_id()];
+	i = 0;
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
@@ -2298,7 +2249,10 @@ static struct pernet_operations ip6_tabl
 
 static int __init ip6_tables_init(void)
 {
-	int ret;
+	int cpu, ret;
+
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&per_cpu(ip6_tables_lock, cpu));
 
 	ret = register_pernet_subsys(&ip6_tables_net_ops);
 	if (ret < 0)
--- a/net/ipv4/netfilter/arp_tables.c	2009-04-15 08:44:01.435318846 -0700
+++ b/net/ipv4/netfilter/arp_tables.c	2009-04-15 17:13:01.909334287 -0700
@@ -231,6 +231,8 @@ static inline struct arpt_entry *get_ent
 	return (struct arpt_entry *)(base + offset);
 }
 
+static DEFINE_PER_CPU(spinlock_t, arp_tables_lock);
+
 unsigned int arpt_do_table(struct sk_buff *skb,
 			   unsigned int hook,
 			   const struct net_device *in,
@@ -255,7 +257,7 @@ unsigned int arpt_do_table(struct sk_buf
 
 	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
-	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -273,7 +275,10 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
+
+			spin_lock(&__get_cpu_var(arp_tables_lock));
 			ADD_COUNTER(e->counters, hdr_len, 1);
+			spin_unlock(&__get_cpu_var(arp_tables_lock));
 
 			t = arpt_get_target(e);
 
@@ -328,7 +333,6 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-
 	rcu_read_unlock_bh();
 
 	if (hotdrop)
@@ -716,74 +720,25 @@ static void get_counters(const struct xt
 	curcpu = raw_smp_processor_id();
 
 	i = 0;
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
 
@@ -792,7 +747,6 @@ static struct xt_counters *alloc_counter
 	unsigned int countersize;
 	struct xt_counters *counters;
 	struct xt_table_info *private = table->private;
-	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -802,30 +756,11 @@ static struct xt_counters *alloc_counter
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
 
 static int copy_entries_to_user(unsigned int total_size,
@@ -1165,6 +1100,19 @@ static int do_replace(struct net *net, v
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
@@ -1173,7 +1121,7 @@ static int do_add_counters(struct net *n
 	struct xt_counters *paddc;
 	unsigned int num_counters;
 	const char *name;
-	int size;
+	int cpu, size;
 	void *ptmp;
 	struct xt_table *t;
 	const struct xt_table_info *private;
@@ -1224,25 +1172,25 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	mutex_lock(&t->lock);
 	private = t->private;
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
 	}
 
-	preempt_disable();
-	i = 0;
 	/* Choose the copy that is on our node */
-	loc_cpu_entry = private->entries[smp_processor_id()];
+	cpu = raw_smp_processor_id();
+	spin_lock_bh(&per_cpu(arp_tables_lock, cpu));
+	loc_cpu_entry = private->entries[cpu];
+	i = 0;
 	ARPT_ENTRY_ITERATE(loc_cpu_entry,
 			   private->size,
 			   add_counter_to_entry,
 			   paddc,
 			   &i);
-	preempt_enable();
+	spin_unlock_bh(&per_cpu(arp_tables_lock, cpu));
+
  unlock_up_free:
-	mutex_unlock(&t->lock);
 
 	xt_table_unlock(t);
 	module_put(t->me);
@@ -1923,7 +1871,10 @@ static struct pernet_operations arp_tabl
 
 static int __init arp_tables_init(void)
 {
-	int ret;
+	int cpu, ret;
+
+	for_each_possible_cpu(cpu)
+		spin_lock_init(&per_cpu(arp_tables_lock, cpu));
 
 	ret = register_pernet_subsys(&arp_tables_net_ops);
 	if (ret < 0)
