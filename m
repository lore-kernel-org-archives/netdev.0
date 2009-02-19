From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] iptables: lock free counters
Date: Thu, 19 Feb 2009 11:47:19 -0800
Message-ID: <20090219114719.560999b5@extreme>
References: <20090218051906.174295181@vyatta.com>
	<20090218052747.321329022@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47228 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbZBSTrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 14:47:21 -0500
In-Reply-To: <20090218052747.321329022@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reader/writer lock in ip_tables is acquired in the critical path of
processing packets and is one of the reasons just loading iptables can cause
a 20% performance loss. The rwlock serves two functions:

1) it prevents changes to table state (xt_replace) while table is in use.
   This is now handled by doing rcu on the xt_table. When table is
   replaced, the new table(s) are put in and the old one table(s) are freed
   after RCU period.

2) it provides synchronization when accesing the counter values.
   This is now handled by swapping in new table_info entries for each cpu
   then summing the old values, and putting the result back onto one
   cpu.  On a busy system it may cause sampling to occur at different
   times on each cpu, but no packet/byte counts are lost in the process.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Added missing preempt_enable.  Patch against nf-next-2.6 git tree.

 include/linux/netfilter/x_tables.h |    6 +
 net/ipv4/netfilter/arp_tables.c    |  115 +++++++++++++++++++++++++++--------
 net/ipv4/netfilter/ip_tables.c     |  120 ++++++++++++++++++++++++++-----------
 net/ipv6/netfilter/ip6_tables.c    |  119 +++++++++++++++++++++++++-----------
 net/netfilter/x_tables.c           |   26 ++++++--
 5 files changed, 284 insertions(+), 102 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-02-19 11:42:43.060110657 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-02-19 11:42:58.863663575 -0800
@@ -353,7 +353,7 @@ struct xt_table
 	unsigned int valid_hooks;
 
 	/* Lock for the curtain */
-	rwlock_t lock;
+	struct mutex lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -385,7 +385,7 @@ struct xt_table_info
 
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
-	char *entries[1];
+	void *entries[1];
 };
 
 #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
@@ -432,6 +432,8 @@ extern void xt_proto_fini(struct net *ne
 
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
+extern void xt_table_entry_swap_rcu(struct xt_table_info *old,
+				    struct xt_table_info *new);
 
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
--- a/net/ipv4/netfilter/ip_tables.c	2009-02-19 11:42:12.968410890 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-02-19 11:42:58.863663575 -0800
@@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+
+	rcu_read_lock();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -924,13 +926,68 @@ get_counters(const struct xt_table_info 
 				  counters,
 				  &i);
 	}
+
+}
+
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
+
+/* Take values from counters and add them back onto the current cpu */
+static void put_counters(struct xt_table_info *t,
+			 const struct xt_counters counters[])
+{
+	unsigned int i, cpu;
+
+	local_bh_disable();
+	cpu = smp_processor_id();
+	i = 0;
+	IPT_ENTRY_ITERATE(t->entries[cpu],
+			  t->size,
+			  add_counter_to_entry,
+			  counters,
+			  &i);
+	local_bh_enable();
+}
+
+
+static inline int
+zero_entry_counter(struct ipt_entry *e, void *arg)
+{
+	e->counters.bcnt = 0;
+	e->counters.pcnt = 0;
+	return 0;
+}
+
+static void
+clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
+{
+	unsigned int cpu;
+	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
+
+	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
+	for_each_possible_cpu(cpu) {
+		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
+		IPT_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
+				  zero_entry_counter, NULL);
+	}
 }
 
 static struct xt_counters * alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
+	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -939,14 +996,30 @@ static struct xt_counters * alloc_counte
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto nomem;
+
+	info = xt_alloc_table_info(private->size);
+	if (!info)
+		goto free_counters;
+
+	clone_counters(info, private);
 
-	/* First, sum counters... */
-	write_lock_bh(&table->lock);
-	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	mutex_lock(&table->lock);
+	xt_table_entry_swap_rcu(private, info);
+	synchronize_net();	/* Wait until smoke has cleared */
+
+	get_counters(info, counters);
+	put_counters(private, counters);
+	mutex_unlock(&table->lock);
+
+	xt_free_table_info(info);
 
 	return counters;
+
+ free_counters:
+	vfree(counters);
+ nomem:
+	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1312,27 +1385,6 @@ do_replace(struct net *net, void __user 
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct ipt_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-#if 0
-	duprintf("add_counter: Entry %u %lu/%lu + %lu/%lu\n",
-		 *i,
-		 (long unsigned int)e->counters.pcnt,
-		 (long unsigned int)e->counters.bcnt,
-		 (long unsigned int)addme[*i].pcnt,
-		 (long unsigned int)addme[*i].bcnt);
-#endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
 
 static int
 do_add_counters(struct net *net, void __user *user, unsigned int len, int compat)
@@ -1393,13 +1445,14 @@ do_add_counters(struct net *net, void __
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
@@ -1408,8 +1461,9 @@ do_add_counters(struct net *net, void __
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
--- a/net/netfilter/x_tables.c	2009-02-19 11:42:12.988414682 -0800
+++ b/net/netfilter/x_tables.c	2009-02-19 11:42:58.863663575 -0800
@@ -625,6 +625,20 @@ void xt_free_table_info(struct xt_table_
 }
 EXPORT_SYMBOL(xt_free_table_info);
 
+void xt_table_entry_swap_rcu(struct xt_table_info *oldinfo,
+			     struct xt_table_info *newinfo)
+{
+	unsigned int cpu;
+
+	for_each_possible_cpu(cpu) {
+		void *p = oldinfo->entries[cpu];
+		rcu_assign_pointer(oldinfo->entries[cpu], newinfo->entries[cpu]);
+		newinfo->entries[cpu] = p;
+	}
+
+}
+EXPORT_SYMBOL_GPL(xt_table_entry_swap_rcu);
+
 /* Find table by name, grabs mutex & ref.  Returns ERR_PTR() on error. */
 struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
 				    const char *name)
@@ -671,21 +685,22 @@ xt_replace_table(struct xt_table *table,
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
 
+	synchronize_net();
 	return oldinfo;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
@@ -719,7 +734,8 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	mutex_init(&table->lock);
+
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 
--- a/net/ipv4/netfilter/arp_tables.c	2009-02-19 11:42:43.064477910 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-02-19 11:42:58.863663575 -0800
@@ -261,9 +261,10 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	read_lock_bh(&table->lock);
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+	rcu_read_lock();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
@@ -335,7 +336,8 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-	read_unlock_bh(&table->lock);
+
+	rcu_read_unlock();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -738,11 +740,65 @@ static void get_counters(const struct xt
 	}
 }
 
-static inline struct xt_counters *alloc_counters(struct xt_table *table)
+
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
+/* Take values from counters and add them back onto the current cpu */
+static void put_counters(struct xt_table_info *t,
+			 const struct xt_counters counters[])
+{
+	unsigned int i, cpu;
+
+	local_bh_disable();
+	cpu = smp_processor_id();
+	i = 0;
+	ARPT_ENTRY_ITERATE(t->entries[cpu],
+			  t->size,
+			  add_counter_to_entry,
+			  counters,
+			  &i);
+	local_bh_enable();
+}
+
+static inline int
+zero_entry_counter(struct arpt_entry *e, void *arg)
+{
+	e->counters.bcnt = 0;
+	e->counters.pcnt = 0;
+	return 0;
+}
+
+static void
+clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
+{
+	unsigned int cpu;
+	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
+
+	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
+	for_each_possible_cpu(cpu) {
+		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
+		ARPT_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
+				  zero_entry_counter, NULL);
+	}
+}
+
+static struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
+	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -752,14 +808,30 @@ static inline struct xt_counters *alloc_
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto nomem;
 
-	/* First, sum counters... */
-	write_lock_bh(&table->lock);
-	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	info = xt_alloc_table_info(private->size);
+	if (!info)
+		goto free_counters;
+
+	clone_counters(info, private);
+
+	mutex_lock(&table->lock);
+	xt_table_entry_swap_rcu(private, info);
+	synchronize_net();	/* Wait until smoke has cleared */
+
+	get_counters(info, counters);
+	put_counters(private, counters);
+	mutex_unlock(&table->lock);
+
+	xt_free_table_info(info);
 
 	return counters;
+
+ free_counters:
+	vfree(counters);
+ nomem:
+	return ERR_PTR(-ENOMEM);
 }
 
 static int copy_entries_to_user(unsigned int total_size,
@@ -1099,20 +1171,6 @@ static int do_replace(struct net *net, v
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK.
- */
-static inline int add_counter_to_entry(struct arpt_entry *e,
-				       const struct xt_counters addme[],
-				       unsigned int *i)
-{
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static int do_add_counters(struct net *net, void __user *user, unsigned int len,
 			   int compat)
 {
@@ -1172,13 +1230,14 @@ static int do_add_counters(struct net *n
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
@@ -1187,8 +1246,10 @@ static int do_add_counters(struct net *n
 			   add_counter_to_entry,
 			   paddc,
 			   &i);
+	preempt_enable();
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	mutex_unlock(&t->lock);
+
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-02-19 11:42:54.219410544 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-02-19 11:42:58.867668311 -0800
@@ -382,10 +382,12 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+
+	rcu_read_lock();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -483,7 +485,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -964,11 +966,64 @@ get_counters(const struct xt_table_info 
 	}
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
+/* Take values from counters and add them back onto the current cpu */
+static void put_counters(struct xt_table_info *t,
+			 const struct xt_counters counters[])
+{
+	unsigned int i, cpu;
+
+	local_bh_disable();
+	cpu = smp_processor_id();
+	i = 0;
+	IP6T_ENTRY_ITERATE(t->entries[cpu],
+			   t->size,
+			   add_counter_to_entry,
+			   counters,
+			   &i);
+	local_bh_enable();
+}
+
+static inline int
+zero_entry_counter(struct ip6t_entry *e, void *arg)
+{
+	e->counters.bcnt = 0;
+	e->counters.pcnt = 0;
+	return 0;
+}
+
+static void
+clone_counters(struct xt_table_info *newinfo, const struct xt_table_info *info)
+{
+	unsigned int cpu;
+	const void *loc_cpu_entry = info->entries[raw_smp_processor_id()];
+
+	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
+	for_each_possible_cpu(cpu) {
+		memcpy(newinfo->entries[cpu], loc_cpu_entry, info->size);
+		IP6T_ENTRY_ITERATE(newinfo->entries[cpu], newinfo->size,
+				   zero_entry_counter, NULL);
+	}
+}
+
 static struct xt_counters *alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
+	struct xt_table_info *info;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -977,14 +1032,28 @@ static struct xt_counters *alloc_counter
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto nomem;
 
-	/* First, sum counters... */
-	write_lock_bh(&table->lock);
-	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	info = xt_alloc_table_info(private->size);
+	if (!info)
+		goto free_counters;
+
+	clone_counters(info, private);
 
-	return counters;
+	mutex_lock(&table->lock);
+	xt_table_entry_swap_rcu(private, info);
+	synchronize_net();	/* Wait until smoke has cleared */
+
+	get_counters(info, counters);
+	put_counters(private, counters);
+	mutex_unlock(&table->lock);
+
+	xt_free_table_info(info);
+
+ free_counters:
+	vfree(counters);
+ nomem:
+	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1351,28 +1420,6 @@ do_replace(struct net *net, void __user 
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static inline int
-add_counter_to_entry(struct ip6t_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-#if 0
-	duprintf("add_counter: Entry %u %lu/%lu + %lu/%lu\n",
-		 *i,
-		 (long unsigned int)e->counters.pcnt,
-		 (long unsigned int)e->counters.bcnt,
-		 (long unsigned int)addme[*i].pcnt,
-		 (long unsigned int)addme[*i].bcnt);
-#endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static int
 do_add_counters(struct net *net, void __user *user, unsigned int len,
 		int compat)
@@ -1433,13 +1480,14 @@ do_add_counters(struct net *net, void __
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
@@ -1448,8 +1496,9 @@ do_add_counters(struct net *net, void __
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
