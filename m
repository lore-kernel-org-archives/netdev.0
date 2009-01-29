From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] netfilter: convert x_tables to use RCU
Date: Thu, 29 Jan 2009 11:12:45 -0800
Message-ID: <20090129191520.647342549@vyatta.com>
References: <20090129191239.483204605@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:51501 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbZA2Ue6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 15:34:58 -0500
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
 net/ipv4/netfilter/arp_tables.c    |   12 ++++-----
 net/ipv4/netfilter/ip_tables.c     |   12 ++++-----
 net/ipv6/netfilter/ip6_tables.c    |   12 ++++-----
 net/netfilter/x_tables.c           |   45 ++++++++++++++++++++++++++-----------
 5 files changed, 58 insertions(+), 33 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-29 11:09:20.724069866 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-29 11:10:49.823071289 -0800
@@ -357,8 +357,8 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	rwlock_t lock;
+	/* Lock for curtain */
+	spinlock_t lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -388,6 +388,12 @@ struct xt_table_info
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
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-29 11:09:20.720069979 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-29 11:10:49.823071289 -0800
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
@@ -1152,8 +1152,8 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1168,7 +1168,7 @@ static int do_add_counters(struct net *n
 			   paddc,
 			   &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:09:20.720069979 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:10:49.827070289 -0800
@@ -347,9 +347,9 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
+	rcu_read_lock_bh();
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
+	private = rcu_dereference(table->private);
 	table_base = (void *)private->entries[smp_processor_id()];
 	e = get_entry(table_base, private->hook_entry[hook]);
 
@@ -445,7 +445,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -1397,8 +1397,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1413,7 +1413,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-29 11:09:20.724069866 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-29 11:10:49.827070289 -0800
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
@@ -1428,8 +1428,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1444,7 +1444,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-01-29 11:10:03.595571234 -0800
+++ b/net/netfilter/x_tables.c	2009-01-29 11:11:43.496192079 -0800
@@ -639,18 +639,37 @@ struct xt_table_info *xt_alloc_table_inf
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
@@ -699,20 +718,20 @@ xt_replace_table(struct xt_table *table,
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
@@ -747,7 +766,7 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	spin_lock_init(&table->lock);
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 

-- 

