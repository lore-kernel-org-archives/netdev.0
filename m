From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] netfilter: convert x_tables to use RCU
Date: Wed, 28 Jan 2009 22:25:26 -0800
Message-ID: <20090129062549.364601936@vyatta.com>
References: <20090129062521.092861272@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59983 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbZA2G1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 01:27:20 -0500
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
 include/linux/netfilter/x_tables.h |   10 ++++++-
 net/ipv4/netfilter/arp_tables.c    |   12 ++++-----
 net/ipv4/netfilter/ip_tables.c     |   12 ++++-----
 net/ipv6/netfilter/ip6_tables.c    |   12 ++++-----
 net/netfilter/x_tables.c           |   48 ++++++++++++++++++++++++++-----------
 5 files changed, 60 insertions(+), 34 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-28 22:04:39.316517913 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-28 22:14:54.648490491 -0800
@@ -352,8 +352,8 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	rwlock_t lock;
+	/* Lock for curtain */
+	spinlock_t lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -386,6 +386,12 @@ struct xt_table_info
 	/* Secret compartment */
 	seqcount_t *seq;
 
+	/* For the dustman... */
+	union {
+		struct rcu_head rcu;
+		struct work_struct work;
+	};
+
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
 	char *entries[1];
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:13:16.423490077 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:14:54.648490491 -0800
@@ -238,8 +238,8 @@ unsigned int arpt_do_table(struct sk_buf
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	read_lock_bh(&table->lock);
-	private = table->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
@@ -315,7 +315,7 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -1163,8 +1163,8 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1179,7 +1179,7 @@ static int do_add_counters(struct net *n
 			   paddc,
 			   &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-28 22:06:10.596739805 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-28 22:14:54.648490491 -0800
@@ -348,9 +348,9 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
+	rcu_read_lock_bh();
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
@@ -449,7 +449,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -1408,8 +1408,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1424,7 +1424,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-28 22:13:16.419490741 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-28 22:14:54.652490133 -0800
@@ -374,9 +374,9 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
+	rcu_read_lock_bh();
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
@@ -478,7 +478,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -1439,8 +1439,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1455,7 +1455,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-01-28 22:14:33.143990681 -0800
+++ b/net/netfilter/x_tables.c	2009-01-28 22:17:40.183990832 -0800
@@ -621,19 +621,39 @@ struct xt_table_info *xt_alloc_table_inf
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
-	free_percpu(info->seq);
+	for_each_possible_cpu(cpu)
+		vfree(info->entries[cpu]);
 	kfree(info);
 }
+
+static void xt_free_table_info_rcu(struct rcu_head *arg)
+{
+ 	struct xt_table_info *info = container_of(arg, struct xt_table_info, rcu);
+
+	free_percpu(info->seq);
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
@@ -682,20 +702,20 @@ xt_replace_table(struct xt_table *table,
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
@@ -730,7 +750,7 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	spin_lock_init(&table->lock);
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 

-- 

