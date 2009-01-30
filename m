From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] netfilter: convert x_tables to use RCU
Date: Fri, 30 Jan 2009 13:57:06 -0800
Message-ID: <20090130215729.658203821@vyatta.com>
References: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49662 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978AbZA3V6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:58:01 -0500
Content-Disposition: inline; filename=iptables-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace existing reader/writer lock with Read-Copy-Update to
elminate the overhead of a read lock on each incoming packet.
This should reduce the overhead of iptables especially on SMP
systems.

The previous code used a reader-writer lock for two purposes.
The first was to ensure that the xt_table_info reference was not in
process of being changed. Since xt_table_info is only freed via one
routine, it was a direct conversion to RCU.

The other use of the reader-writer lock was to to block changes
to counters while they were being read. This synchronization was
fixed by the previous patch.  But still need to make sure table info
isn't going away.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |   10 ++++++--
 net/ipv4/netfilter/arp_tables.c    |   16 ++++++-------
 net/ipv4/netfilter/ip_tables.c     |   27 +++++++++++-----------
 net/ipv6/netfilter/ip6_tables.c    |   16 ++++++-------
 net/netfilter/x_tables.c           |   45 ++++++++++++++++++++++++++-----------
 5 files changed, 70 insertions(+), 44 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-30 09:15:52.700542193 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-30 09:17:25.888041887 -0800
@@ -356,8 +356,8 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	rwlock_t lock;
+	/* Lock for curtain */
+	spinlock_t lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -387,6 +387,12 @@ struct xt_table_info
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
 	char *entries[1];
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-30 09:15:52.636542607 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-30 09:24:52.004793273 -0800
@@ -237,8 +237,8 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	read_lock_bh(&table->lock);
-	private = table->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
@@ -311,7 +311,7 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -733,9 +733,9 @@ static inline struct xt_counters *alloc_
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_enable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_disable();
 
 	return counters;
 }
@@ -1149,8 +1149,8 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1165,7 +1165,7 @@ static int do_add_counters(struct net *n
 			   paddc,
 			   &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-30 09:15:52.624542483 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-30 09:25:07.776040828 -0800
@@ -66,11 +66,12 @@ do {								\
 #endif
 
 /*
-   We keep a set of rules for each CPU, so we can avoid write-locking
-   them in the softirq when updating the counters and therefore
-   only need to read-lock in the softirq; doing a write_lock_bh() in user
-   context stops packets coming through and allows user context to read
-   the counters or update the rules.
+   We keep a set of rules for each CPU, so we can avoid locking
+   them in the softirq when updating the counters. We use a sequence
+   counter to keep the counters consistent and RCU to prevent
+   handle counters during replace operation. When reading the
+   counters, need to have bottom half and preempt disabled to
+   get a consistent data.
 
    Hence the start of any table is given by get_table() below.  */
 
@@ -347,9 +348,9 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
+	rcu_read_lock_bh();
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -445,7 +446,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -944,9 +945,9 @@ static struct xt_counters * alloc_counte
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
@@ -1394,8 +1395,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1410,7 +1411,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-30 09:15:52.684541784 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-30 09:25:43.756056066 -0800
@@ -373,9 +373,9 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
+	rcu_read_lock_bh();
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -474,7 +474,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -973,9 +973,9 @@ static struct xt_counters *alloc_counter
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
@@ -1425,8 +1425,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1441,7 +1441,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-01-30 09:17:03.669061821 -0800
+++ b/net/netfilter/x_tables.c	2009-01-30 09:17:25.892042053 -0800
@@ -644,18 +644,37 @@ struct xt_table_info *xt_alloc_table_inf
 }
 EXPORT_SYMBOL(xt_alloc_table_info);
 
-void xt_free_table_info(struct xt_table_info *info)
+/* callback to do free for vmalloc'd case */
+static void xt_free_table_info_work(struct work_struct *arg)
 {
-	int cpu;
+	struct xt_table_info *info = container_of(arg, struct xt_table_info, work);
+	unsigned int cpu;
 
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
+ 	struct xt_table_info *info = container_of(arg, struct xt_table_info, rcu);
+
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
@@ -704,20 +723,20 @@ xt_replace_table(struct xt_table *table,
 	struct xt_table_info *oldinfo, *private;
 
 	/* Do the substitution. */
-	write_lock_bh(&table->lock);
+	spin_lock_bh(&table->lock);
 	private = table->private;
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
 		duprintf("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
-		write_unlock_bh(&table->lock);
+		spin_unlock_bh(&table->lock);
 		*error = -EAGAIN;
 		return NULL;
 	}
 	oldinfo = private;
-	table->private = newinfo;
+	rcu_assign_pointer(table->private, newinfo);
 	newinfo->initial_entries = oldinfo->initial_entries;
-	write_unlock_bh(&table->lock);
+	spin_unlock_bh(&table->lock);
 
 	return oldinfo;
 }
@@ -752,7 +771,7 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	spin_lock_init(&table->lock);
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 

-- 

