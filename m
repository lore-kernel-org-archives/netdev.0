From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 3 Feb 2009 15:18:23 -0800
Message-ID: <20090203151823.457b24f1@extreme>
References: <20090130215700.965611970@vyatta.com>
	<20090130215729.416851870@vyatta.com>
	<498594B6.6000905@cosmosbay.com>
	<20090202153357.3ac6edfa@extreme>
	<49889440.60702@cosmosbay.com>
	<20090203193214.GH6607@linux.vnet.ibm.com>
	<4988A6F4.6000902@cosmosbay.com>
	<20090203211000.GI6607@linux.vnet.ibm.com>
	<20090203132220.21a16ea1@extreme>
	<20090203231124.GL6607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49854 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbZBCXSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 18:18:24 -0500
In-Reply-To: <20090203231124.GL6607@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the "interesting bits" of what I am testing.
What it does is swap in new counters, sum, then put counter values
back onto the current cpu.

The replace case is easier since the counters are "old" at that point.


--- a/net/ipv4/netfilter/ip_tables.c	2009-02-02 15:06:29.684249364 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-02-03 15:08:30.230188116 -0800
@@ -347,10 +347,12 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
 	tgpar.hooknum = hook;
 
-	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	private = table->private;
-	table_base = (void *)private->entries[smp_processor_id()];
+
+	rcu_read_lock_bh();
+	private = rcu_dereference(table->private);
+	table_base = rcu_dereference(private->entries[smp_processor_id()]);
+
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -445,7 +447,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	read_unlock_bh(&table->lock);
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -924,13 +926,62 @@ get_counters(const struct xt_table_info 
 				  counters,
 				  &i);
 	}
+
+}
+
+/* Swap existing counter entries with new zeroed ones */
+static void swap_counters(struct xt_table_info *o, struct xt_table_info *n)
+{
+	unsigned int cpu;
+
+	for_each_possible_cpu(cpu) {
+		void *p = o->entries[cpu];
+		memset(n->entries[cpu], 0, n->size);
+
+		rcu_assign_pointer(o->entries[cpu], n->entries[cpu]);
+		n->entries[cpu] = p;
+	}
+
+	/* Wait until smoke has cleared */
+	synchronize_net();
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
 }
 
 static struct xt_counters * alloc_counters(struct xt_table *table)
 {
 	unsigned int countersize;
 	struct xt_counters *counters;
-	const struct xt_table_info *private = table->private;
+	struct xt_table_info *private = table->private;
+	struct xt_table_info *tmp;
 
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -939,14 +990,26 @@ static struct xt_counters * alloc_counte
 	counters = vmalloc_node(countersize, numa_node_id());
 
 	if (counters == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto nomem;
+
+	tmp = xt_alloc_table_info(private->size);
+	if (!tmp)
+		goto free_counters;
 
-	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	mutex_lock(&table->lock);
+	swap_counters(private, tmp);
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	put_counters(private, counters);
+	mutex_unlock(&table->lock);
+
+	xt_free_table_info(tmp);
 
 	return counters;
+
+ free_counters:
+	vfree(counters);
+ nomem:
+	return ERR_PTR(-ENOMEM);
 }
 
 static int
@@ -1242,7 +1305,9 @@ __do_replace(struct net *net, const char
 		module_put(t->me);
 
 	/* Get the old counters. */
+	synchronize_net();
 	get_counters(oldinfo, counters);
+
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
@@ -1312,27 +1377,6 @@ do_replace(struct net *net, void __user 
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
@@ -1393,13 +1437,14 @@ do_add_counters(struct net *net, void __
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
@@ -1408,8 +1453,9 @@ do_add_counters(struct net *net, void __
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
