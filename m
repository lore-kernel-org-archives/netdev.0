From: Eric dumazet <abuse@cosmosbay.com>
Subject: [PATCH, netfilter] NUMA aware ipv4/netfilter/ip_tables.c
Date: Mon, 19 Sep 2005 19:09:25 +0200
Message-ID: <432EF0C5.5090908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010100020506070801020704"
Cc: netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010100020506070801020704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi

Part of the performance problem we have with netfilter  is memory 
allocation is not NUMA aware, but 'only' SMP aware.

What do you think of this patch ?

Note : The allocation function is quite complex (copied from 
drivers/pci/pci-driver.c pci_call_probe())
because current kernel doesnt have a NUMA aware vmalloc() wrapper, maybe 
a future kernel will export
such a common function ?

Thank you

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------010100020506070801020704
Content-Type: text/plain;
 name="patch_ip_tables_numa"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_ip_tables_numa"

--- linux-2.6.14-rc1.p1/net/ipv4/netfilter/ip_tables.c	2005-09-19 19:56:12.000000000 +0200
+++ linux-2.6.14-rc1/net/ipv4/netfilter/ip_tables.c	2005-09-19 21:03:44.000000000 +0200
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/kmod.h>
 #include <linux/vmalloc.h>
+#include <linux/mempolicy.h>
 #include <linux/netdevice.h>
 #include <linux/module.h>
 #include <linux/tcp.h>
@@ -82,11 +83,6 @@
    context stops packets coming through and allows user context to read
    the counters or update the rules.
 
-   To be cache friendly on SMP, we arrange them like so:
-   [ n-entries ]
-   ... cache-align padding ...
-   [ n-entries ]
-
    Hence the start of any table is given by get_table() below.  */
 
 /* The table itself */
@@ -104,7 +100,8 @@
 	unsigned int underflow[NF_IP_NUMHOOKS];
 
 	/* ipt_entry tables: one per CPU */
-	char entries[0] ____cacheline_aligned;
+	void *entry0 ; /* entry for the first possible cpu */
+	void *entries[NR_CPUS];
 };
 
 static LIST_HEAD(ipt_target);
@@ -112,11 +109,6 @@
 static LIST_HEAD(ipt_tables);
 #define ADD_COUNTER(c,b,p) do { (c).bcnt += (b); (c).pcnt += (p); } while(0)
 
-#ifdef CONFIG_SMP
-#define TABLE_OFFSET(t,p) (SMP_ALIGN((t)->size)*(p))
-#else
-#define TABLE_OFFSET(t,p) 0
-#endif
 
 #if 0
 #define down(x) do { printk("DOWN:%u:" #x "\n", __LINE__); down(x); } while(0)
@@ -289,8 +281,7 @@
 
 	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	table_base = (void *)table->private->entries
-		+ TABLE_OFFSET(table->private, smp_processor_id());
+	table_base = (void *)table->private->entries[smp_processor_id()];
 	e = get_entry(table_base, table->private->hook_entry[hook]);
 
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -571,7 +562,7 @@
 	for (hook = 0; hook < NF_IP_NUMHOOKS; hook++) {
 		unsigned int pos = newinfo->hook_entry[hook];
 		struct ipt_entry *e
-			= (struct ipt_entry *)(newinfo->entries + pos);
+			= (struct ipt_entry *)(newinfo->entry0 + pos);
 
 		if (!(valid_hooks & (1 << hook)))
 			continue;
@@ -621,13 +612,13 @@
 						goto next;
 
 					e = (struct ipt_entry *)
-						(newinfo->entries + pos);
+						(newinfo->entry0 + pos);
 				} while (oldpos == pos + e->next_offset);
 
 				/* Move along one */
 				size = e->next_offset;
 				e = (struct ipt_entry *)
-					(newinfo->entries + pos + size);
+					(newinfo->entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
 			} else {
@@ -644,7 +635,7 @@
 					newpos = pos + e->next_offset;
 				}
 				e = (struct ipt_entry *)
-					(newinfo->entries + newpos);
+					(newinfo->entry0 + newpos);
 				e->counters.pcnt = pos;
 				pos = newpos;
 			}
@@ -874,11 +865,11 @@
 	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 	/* Walk through entries, checking offsets. */
-	ret = IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret = IPT_ENTRY_ITERATE(newinfo->entry0, newinfo->size,
 				check_entry_size_and_hooks,
 				newinfo,
-				newinfo->entries,
-				newinfo->entries + size,
+				newinfo->entry0,
+				newinfo->entry0 + size,
 				hook_entries, underflows, &i);
 	if (ret != 0)
 		return ret;
@@ -911,20 +902,21 @@
 
 	/* Finally, each sanity check must pass */
 	i = 0;
-	ret = IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret = IPT_ENTRY_ITERATE(newinfo->entry0, newinfo->size,
 				check_entry, name, size, &i);
 
 	if (ret != 0) {
-		IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+		IPT_ENTRY_ITERATE(newinfo->entry0, newinfo->size,
 				  cleanup_entry, &i);
 		return ret;
 	}
 
 	/* And one copy for every other CPU */
-	for (i = 1; i < num_possible_cpus(); i++) {
-		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size)*i,
-		       newinfo->entries,
-		       SMP_ALIGN(newinfo->size));
+	for_each_cpu(i) {
+		if (newinfo->entries[i] != newinfo->entry0)
+			memcpy(newinfo->entries[i],
+				newinfo->entry0,
+				newinfo->size);
 	}
 
 	return ret;
@@ -940,15 +932,12 @@
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	{
-		struct ipt_entry *table_base;
-		unsigned int i;
-
-		for (i = 0; i < num_possible_cpus(); i++) {
-			table_base =
-				(void *)newinfo->entries
-				+ TABLE_OFFSET(newinfo, i);
+		int cpu;
 
-			table_base->comefrom = 0xdead57ac;
+		for_each_cpu(cpu) {
+			struct ipt_entry *table_base = newinfo->entries[cpu];
+			if (table_base)
+				table_base->comefrom = 0xdead57ac;
 		}
 	}
 #endif
@@ -990,9 +979,9 @@
 	unsigned int cpu;
 	unsigned int i;
 
-	for (cpu = 0; cpu < num_possible_cpus(); cpu++) {
+	for_each_cpu(cpu) {
 		i = 0;
-		IPT_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
+		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
@@ -1026,7 +1015,7 @@
 	write_unlock_bh(&table->lock);
 
 	/* ... then copy entire thing from CPU 0... */
-	if (copy_to_user(userptr, table->private->entries, total_size) != 0) {
+	if (copy_to_user(userptr, table->private->entry0, total_size) != 0) {
 		ret = -EFAULT;
 		goto free_counters;
 	}
@@ -1038,7 +1027,7 @@
 		struct ipt_entry_match *m;
 		struct ipt_entry_target *t;
 
-		e = (struct ipt_entry *)(table->private->entries + off);
+		e = (struct ipt_entry *)(table->private->entry0 + off);
 		if (copy_to_user(userptr + off
 				 + offsetof(struct ipt_entry, counters),
 				 &counters[num],
@@ -1107,6 +1096,51 @@
 	return ret;
 }
 
+static void free_table_info(struct ipt_table_info *info)
+{
+	int cpu;
+	for_each_cpu(cpu)
+		vfree(info->entries[cpu]);
+	kfree(info);
+}
+
+static struct ipt_table_info *alloc_table_info(unsigned int size)
+{
+struct ipt_table_info *newinfo;
+int cpu;
+	newinfo = kmalloc(sizeof(struct ipt_table_info), GFP_KERNEL);
+	if (!newinfo)
+		return NULL;
+	memset(newinfo, 0, sizeof(*newinfo));
+	for_each_cpu(cpu) {
+#ifdef CONFIG_NUMA
+		struct mempolicy *oldpol;
+		cpumask_t oldmask = current->cpus_allowed;
+		int node = cpu_to_node(cpu);
+		if (node >= 0 && node_online(node))
+		    set_cpus_allowed(current, node_to_cpumask(node));
+		/* And set default memory allocation policy */
+		oldpol = current->mempolicy;
+		current->mempolicy = &default_policy;
+		mpol_get(current->mempolicy);
+#endif
+		newinfo->entries[cpu] = vmalloc(size);
+#ifdef CONFIG_NUMA
+		set_cpus_allowed(current, oldmask);
+		mpol_free(current->mempolicy);
+		current->mempolicy = oldpol;
+#endif
+		if (newinfo->entries[cpu] == 0) {
+			free_table_info(newinfo);
+			return NULL;
+		if (!newinfo->entry0)
+			newinfo->entry0 = newinfo->entries[cpu];
+		}
+	}
+	return newinfo;
+}
+
+
 static int
 do_replace(void __user *user, unsigned int len)
 {
@@ -1127,12 +1161,10 @@
 	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
 		return -ENOMEM;
 
-	newinfo = vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(tmp.size) * num_possible_cpus());
+	newinfo = alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
-
-	if (copy_from_user(newinfo->entries, user + sizeof(tmp),
+	if (copy_from_user(newinfo->entry0, user + sizeof(tmp),
 			   tmp.size) != 0) {
 		ret = -EFAULT;
 		goto free_newinfo;
@@ -1185,8 +1217,8 @@
 	/* Get the old counters. */
 	get_counters(oldinfo, counters);
 	/* Decrease module usage counts and free resource */
-	IPT_ENTRY_ITERATE(oldinfo->entries, oldinfo->size, cleanup_entry,NULL);
-	vfree(oldinfo);
+	IPT_ENTRY_ITERATE(oldinfo->entry0, oldinfo->size, cleanup_entry,NULL);
+	free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
 			 sizeof(struct ipt_counters) * tmp.num_counters) != 0)
 		ret = -EFAULT;
@@ -1198,11 +1230,11 @@
 	module_put(t->me);
 	up(&ipt_mutex);
  free_newinfo_counters_untrans:
-	IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size, cleanup_entry,NULL);
+	IPT_ENTRY_ITERATE(newinfo->entry0, newinfo->size, cleanup_entry,NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	vfree(newinfo);
+	free_table_info(newinfo);
 	return ret;
 }
 
@@ -1264,7 +1296,7 @@
 	}
 
 	i = 0;
-	IPT_ENTRY_ITERATE(t->private->entries,
+	IPT_ENTRY_ITERATE(t->private->entry0,
 			  t->private->size,
 			  add_counter_to_entry,
 			  paddc->counters,
@@ -1454,15 +1486,20 @@
 {
 	int ret;
 	struct ipt_table_info *newinfo;
-	static struct ipt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	static struct ipt_table_info bootstrap = {
+		.size = 0,
+		.number = 0,
+		.initial_entries = 0,
+		.hook_entry = { 0 },
+		.underflow = { 0 },
+		.entry0 = NULL,
+		.entries = {NULL }
+		};
 
-	newinfo = vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(repl->size) * num_possible_cpus());
+	newinfo = alloc_table_info(repl->size);
 	if (!newinfo)
 		return -ENOMEM;
-
-	memcpy(newinfo->entries, repl->entries, repl->size);
+	memcpy(newinfo->entry0, repl->entries, repl->size);
 
 	ret = translate_table(table->name, table->valid_hooks,
 			      newinfo, repl->size,
@@ -1470,13 +1507,13 @@
 			      repl->hook_entry,
 			      repl->underflow);
 	if (ret != 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
 
 	ret = down_interruptible(&ipt_mutex);
 	if (ret != 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
 
@@ -1505,7 +1542,7 @@
 	return ret;
 
  free_unlock:
-	vfree(newinfo);
+	free_table_info(newinfo);
 	goto unlock;
 }
 
@@ -1516,9 +1553,9 @@
 	up(&ipt_mutex);
 
 	/* Decrease module usage counts and free resources */
-	IPT_ENTRY_ITERATE(table->private->entries, table->private->size,
+	IPT_ENTRY_ITERATE(table->private->entry0, table->private->size,
 			  cleanup_entry, NULL);
-	vfree(table->private);
+	free_table_info(table->private);
 }
 
 /* Returns 1 if the port is matched by the range, 0 otherwise */

--------------010100020506070801020704--
