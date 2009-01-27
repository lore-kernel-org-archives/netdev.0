From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 4/4] netfilter: convert x_tables to use RCU
Date: Tue, 27 Jan 2009 15:53:14 -0800
Message-ID: <20090127235509.079057447@vyatta.com>
References: <20090127235310.159946902@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40012 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbZA0X5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 18:57:50 -0500
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
isn't going away. There are a couple of harmless races in reading
the counters, but we always give a valid values they just aren't
exactly frozen in time across all cpu's.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |   10 ++++++--
 net/ipv4/netfilter/arp_tables.c    |   12 +++++-----
 net/ipv4/netfilter/ip_tables.c     |   12 +++++-----
 net/ipv6/netfilter/ip6_tables.c    |   12 +++++-----
 net/netfilter/x_tables.c           |   44 ++++++++++++++++++++++++++-----------
 5 files changed, 58 insertions(+), 32 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-27 15:33:10.791377313 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-27 15:46:26.024128742 -0800
@@ -352,8 +352,8 @@ struct xt_table
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
 
-	/* Lock for the curtain */
-	rwlock_t lock;
+	/* Lock for curtain */
+	spinlock_t lock;
 
 	/* Man behind the curtain... */
 	struct xt_table_info *private;
@@ -383,6 +383,12 @@ struct xt_table_info
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
 	void *entries[1];
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-27 15:45:34.566650540 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-27 15:46:26.024128742 -0800
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
@@ -313,7 +313,7 @@ unsigned int arpt_do_table(struct sk_buf
 			e = (void *)e + e->next_offset;
 		}
 	} while (!hotdrop);
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
@@ -1154,8 +1154,8 @@ static int do_add_counters(struct net *n
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1170,7 +1170,7 @@ static int do_add_counters(struct net *n
 			   paddc,
 			   &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-27 15:45:05.766673246 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-27 15:46:26.024128742 -0800
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
 
@@ -447,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -1399,8 +1399,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1415,7 +1415,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-27 15:45:22.262639173 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-27 15:46:26.028128353 -0800
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
 
@@ -476,7 +476,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -1430,8 +1430,8 @@ do_add_counters(struct net *net, void __
 		goto free;
 	}
 
-	write_lock_bh(&t->lock);
-	private = t->private;
+	rcu_read_lock_bh();
+	private = rcu_dereference(t->private);
 	if (private->number != num_counters) {
 		ret = -EINVAL;
 		goto unlock_up_free;
@@ -1446,7 +1446,7 @@ do_add_counters(struct net *net, void __
 			  paddc,
 			  &i);
  unlock_up_free:
-	write_unlock_bh(&t->lock);
+	rcu_read_unlock_bh();
 	xt_table_unlock(t);
 	module_put(t->me);
  free:
--- a/net/netfilter/x_tables.c	2009-01-27 15:14:06.004743434 -0800
+++ b/net/netfilter/x_tables.c	2009-01-27 15:48:07.194667206 -0800
@@ -611,17 +611,37 @@ struct xt_table_info *xt_alloc_table_inf
 }
 EXPORT_SYMBOL(xt_alloc_table_info);
 
-void xt_free_table_info(struct xt_table_info *info)
+/* callback to do free for vmalloc'd case */
+static void xt_free_table_info_work(struct work_struct *arg)
+{
+	struct xt_table_info *info = container_of(arg, struct xt_table_info, work);
+ 	unsigned int cpu;
+
+	for_each_possible_cpu(cpu)
+		vfree(info->entries[cpu]);
+	kfree(info);
+}
+
+/* callback to do free after all cpu's are done */
+static void xt_free_table_info_rcu(struct rcu_head *arg)
 {
-	int cpu;
+	struct xt_table_info *info = container_of(arg, struct xt_table_info, rcu);
 
-	for_each_possible_cpu(cpu) {
-		if (info->size <= PAGE_SIZE)
+	if (info->size <= PAGE_SIZE) {
+		unsigned int cpu;
+		for_each_possible_cpu(cpu)
 			kfree(info->entries[cpu]);
-		else
-			vfree(info->entries[cpu]);
+		kfree(info);
+	} else {
+		/* can't safely call vfree in current context */
+		INIT_WORK(&info->work, xt_free_table_info_work);
+		schedule_work(&info->work);
 	}
-	kfree(info);
+}
+
+void xt_free_table_info(struct xt_table_info *info)
+{
+	call_rcu(&info->rcu, xt_free_table_info_rcu);
 }
 EXPORT_SYMBOL(xt_free_table_info);
 
@@ -671,20 +691,20 @@ xt_replace_table(struct xt_table *table,
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
@@ -719,7 +739,7 @@ struct xt_table *xt_register_table(struc
 
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
-	rwlock_init(&table->lock);
+	spin_lock_init(&table->lock);
 
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;

-- 

