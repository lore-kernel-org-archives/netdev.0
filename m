From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/08: xtables: replace XT_ENTRY_ITERATE macro
Date: Wed, 24 Feb 2010 18:49:32 +0100 (MET)
Message-ID: <20100224174932.16391.69655.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48777 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757413Ab0BXRte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 12:49:34 -0500
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 72b2b1dd77e8feb0b7c0b26dee58f2a1e2c9828c
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 24 18:32:59 2010 +0100

    netfilter: xtables: replace XT_ENTRY_ITERATE macro
    
    The macro is replaced by a list.h-like foreach loop. This makes
    the code much more inspectable.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index a18119f..9df3f5a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -139,6 +139,7 @@ struct xt_counters_info {
 	__ret;							\
 })
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define XT_ENTRY_ITERATE_CONTINUE(type, entries, size, n, fn, args...) \
 ({								\
@@ -163,6 +164,14 @@ struct xt_counters_info {
 #define XT_ENTRY_ITERATE(type, entries, size, fn, args...) \
 	XT_ENTRY_ITERATE_CONTINUE(type, entries, size, 0, fn, args)
 
+#endif /* !__KERNEL__ */
+
+/* pos is normally a struct ipt_entry/ip6t_entry/etc. */
+#define xt_entry_foreach(pos, ehead, esize) \
+	for ((pos) = (typeof(pos))(ehead); \
+	     (pos) < (typeof(pos))((char *)(ehead) + (esize)); \
+	     (pos) = (typeof(pos))((char *)(pos) + (pos)->next_offset))
+
 #ifdef __KERNEL__
 
 #include <linux/netdevice.h>
diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 0b33980..e9948c0 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -211,9 +211,11 @@ static __inline__ struct arpt_entry_target *arpt_get_target(struct arpt_entry *e
 	return (void *)e + e->target_offset;
 }
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define ARPT_ENTRY_ITERATE(entries, size, fn, args...) \
 	XT_ENTRY_ITERATE(struct arpt_entry, entries, size, fn, ## args)
+#endif
 
 /*
  *	Main firewall chains definitions and global var's definitions.
@@ -291,14 +293,6 @@ compat_arpt_get_target(struct compat_arpt_entry *e)
 
 #define COMPAT_ARPT_ALIGN(s)	COMPAT_XT_ALIGN(s)
 
-/* fn returns 0 to continue iteration */
-#define COMPAT_ARPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct compat_arpt_entry, entries, size, fn, ## args)
-
-#define COMPAT_ARPT_ENTRY_ITERATE_CONTINUE(entries, size, n, fn, args...) \
-	XT_ENTRY_ITERATE_CONTINUE(struct compat_arpt_entry, entries, size, n, \
-				  fn, ## args)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _ARPTABLES_H */
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 364973b..5b20ae7 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -227,9 +227,11 @@ ipt_get_target(struct ipt_entry *e)
 #define IPT_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct ipt_entry, e, fn, ## args)
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IPT_ENTRY_ITERATE(entries, size, fn, args...) \
 	XT_ENTRY_ITERATE(struct ipt_entry, entries, size, fn, ## args)
+#endif
 
 /*
  *	Main firewall chains definitions and global var's definitions.
@@ -317,15 +319,6 @@ compat_ipt_get_target(struct compat_ipt_entry *e)
 #define COMPAT_IPT_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct compat_ipt_entry, e, fn, ## args)
 
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct compat_ipt_entry, entries, size, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_ENTRY_ITERATE_CONTINUE(entries, size, n, fn, args...) \
-	XT_ENTRY_ITERATE_CONTINUE(struct compat_ipt_entry, entries, size, n, \
-				  fn, ## args)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 8031eb4..8bb3f5b 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -284,9 +284,11 @@ ip6t_get_target(struct ip6t_entry *e)
 #define IP6T_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct ip6t_entry, e, fn, ## args)
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IP6T_ENTRY_ITERATE(entries, size, fn, args...) \
 	XT_ENTRY_ITERATE(struct ip6t_entry, entries, size, fn, ## args)
+#endif
 
 /*
  *	Main firewall chains definitions and global var's definitions.
@@ -345,14 +347,6 @@ compat_ip6t_get_target(struct compat_ip6t_entry *e)
 #define COMPAT_IP6T_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct compat_ip6t_entry, e, fn, ## args)
 
-/* fn returns 0 to continue iteration */
-#define COMPAT_IP6T_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct compat_ip6t_entry, entries, size, fn, ## args)
-
-#define COMPAT_IP6T_ENTRY_ITERATE_CONTINUE(entries, size, n, fn, args...) \
-	XT_ENTRY_ITERATE_CONTINUE(struct compat_ip6t_entry, entries, size, n, \
-				  fn, ## args)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IP6_TABLES_H */
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 4db5c1e..f733886 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -641,8 +641,9 @@ static int translate_table(const char *name,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows)
 {
+	struct arpt_entry *iter;
 	unsigned int i;
-	int ret;
+	int ret = 0;
 
 	newinfo->size = size;
 	newinfo->number = number;
@@ -657,12 +658,13 @@ static int translate_table(const char *name,
 	i = 0;
 
 	/* Walk through entries, checking offsets. */
-	ret = ARPT_ENTRY_ITERATE(entry0, newinfo->size,
-				 check_entry_size_and_hooks,
-				 newinfo,
-				 entry0,
-				 entry0 + size,
-				 hook_entries, underflows, valid_hooks, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
+		      entry0 + size, hook_entries, underflows,
+		      valid_hooks, &i);
+		if (ret != 0)
+			break;
+	}
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
 		return ret;
@@ -697,12 +699,16 @@ static int translate_table(const char *name,
 
 	/* Finally, each sanity check must pass */
 	i = 0;
-	ret = ARPT_ENTRY_ITERATE(entry0, newinfo->size,
-				 find_check_entry, name, size, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = find_check_entry(iter, name, size, &i);
+		if (ret != 0)
+			break;
+	}
 
 	if (ret != 0) {
-		ARPT_ENTRY_ITERATE(entry0, newinfo->size,
-				cleanup_entry, &i);
+		xt_entry_foreach(iter, entry0, newinfo->size)
+			if (cleanup_entry(iter, &i) != 0)
+				break;
 		return ret;
 	}
 
@@ -739,6 +745,7 @@ static inline int set_entry_to_counter(const struct arpt_entry *e,
 static void get_counters(const struct xt_table_info *t,
 			 struct xt_counters counters[])
 {
+	struct arpt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
@@ -754,22 +761,18 @@ static void get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	ARPT_ENTRY_ITERATE(t->entries[curcpu],
-			   t->size,
-			   set_entry_to_counter,
-			   counters,
-			   &i);
+	xt_entry_foreach(iter, t->entries[curcpu], t->size)
+		if (set_entry_to_counter(iter, counters, &i) != 0)
+			break;
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		ARPT_ENTRY_ITERATE(t->entries[cpu],
-				   t->size,
-				   add_entry_to_counter,
-				   counters,
-				   &i);
+		xt_entry_foreach(iter, t->entries[cpu], t->size)
+			if (add_entry_to_counter(iter, counters, &i) != 0)
+				break;
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -899,7 +902,9 @@ static int compat_calc_entry(const struct arpt_entry *e,
 static int compat_table_info(const struct xt_table_info *info,
 			     struct xt_table_info *newinfo)
 {
+	struct arpt_entry *iter;
 	void *loc_cpu_entry;
+	int ret = 0;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -908,9 +913,12 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
-	return ARPT_ENTRY_ITERATE(loc_cpu_entry, info->size,
-				  compat_calc_entry, info, loc_cpu_entry,
-				  newinfo);
+	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
+		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
+		if (ret != 0)
+			break;
+	}
+	return ret;
 }
 #endif
 
@@ -1025,6 +1033,7 @@ static int __do_replace(struct net *net, const char *name,
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
 	void *loc_cpu_old_entry;
+	struct arpt_entry *iter;
 
 	ret = 0;
 	counters = vmalloc_node(num_counters * sizeof(struct xt_counters),
@@ -1068,8 +1077,9 @@ static int __do_replace(struct net *net, const char *name,
 
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	ARPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
-			   NULL);
+	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+		if (cleanup_entry(iter, NULL) != 0)
+			break;
 
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
@@ -1095,6 +1105,7 @@ static int do_replace(struct net *net, const void __user *user,
 	struct arpt_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct arpt_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1130,7 +1141,9 @@ static int do_replace(struct net *net, const void __user *user,
 	return 0;
 
  free_newinfo_untrans:
-	ARPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1163,6 +1176,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	const struct xt_table_info *private;
 	int ret = 0;
 	void *loc_cpu_entry;
+	struct arpt_entry *iter;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1220,11 +1234,9 @@ static int do_add_counters(struct net *net, const void __user *user,
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_info_wrlock(curcpu);
-	ARPT_ENTRY_ITERATE(loc_cpu_entry,
-			   private->size,
-			   add_counter_to_entry,
-			   paddc,
-			   &i);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (add_counter_to_entry(iter, paddc, &i) != 0)
+			break;
 	xt_info_wrunlock(curcpu);
  unlock_up_free:
 	local_bh_enable();
@@ -1388,8 +1400,10 @@ static int translate_compat_table(const char *name,
 	unsigned int i, j;
 	struct xt_table_info *newinfo, *info;
 	void *pos, *entry0, *entry1;
+	struct compat_arpt_entry *iter0;
+	struct arpt_entry *iter1;
 	unsigned int size;
-	int ret;
+	int ret = 0;
 
 	info = *pinfo;
 	entry0 = *pentry0;
@@ -1406,11 +1420,13 @@ static int translate_compat_table(const char *name,
 	j = 0;
 	xt_compat_lock(NFPROTO_ARP);
 	/* Walk through entries, checking offsets. */
-	ret = COMPAT_ARPT_ENTRY_ITERATE(entry0, total_size,
-					check_compat_entry_size_and_hooks,
-					info, &size, entry0,
-					entry0 + total_size,
-					hook_entries, underflows, &j, name);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
+		      entry0, entry0 + total_size, hook_entries, underflows,
+		      &j, name);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto out_unlock;
 
@@ -1451,9 +1467,12 @@ static int translate_compat_table(const char *name,
 	entry1 = newinfo->entries[raw_smp_processor_id()];
 	pos = entry1;
 	size = total_size;
-	ret = COMPAT_ARPT_ENTRY_ITERATE(entry0, total_size,
-					compat_copy_entry_from_user,
-					&pos, &size, name, newinfo, entry1);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = compat_copy_entry_from_user(iter0, &pos,
+		      &size, name, newinfo, entry1);
+		if (ret != 0)
+			break;
+	}
 	xt_compat_flush_offsets(NFPROTO_ARP);
 	xt_compat_unlock(NFPROTO_ARP);
 	if (ret)
@@ -1464,13 +1483,28 @@ static int translate_compat_table(const char *name,
 		goto free_newinfo;
 
 	i = 0;
-	ret = ARPT_ENTRY_ITERATE(entry1, newinfo->size, compat_check_entry,
-				 name, &i);
+	xt_entry_foreach(iter1, entry1, newinfo->size) {
+		ret = compat_check_entry(iter1, name, &i);
+		if (ret != 0)
+			break;
+	}
 	if (ret) {
+		/*
+		 * The first i matches need cleanup_entry (calls ->destroy)
+		 * because they had called ->check already. The other j-i
+		 * entries need only release.
+		 */
+		int skip = i;
 		j -= i;
-		COMPAT_ARPT_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
-						   compat_release_entry, &j);
-		ARPT_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, &i);
+		xt_entry_foreach(iter0, entry0, newinfo->size) {
+			if (skip-- > 0)
+				continue;
+			if (compat_release_entry(iter0, &j) != 0)
+				break;
+		}
+		xt_entry_foreach(iter1, entry1, newinfo->size)
+			if (cleanup_entry(iter1, &i) != 0)
+				break;
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1488,7 +1522,9 @@ static int translate_compat_table(const char *name,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	COMPAT_ARPT_ENTRY_ITERATE(entry0, total_size, compat_release_entry, &j);
+	xt_entry_foreach(iter0, entry0, total_size)
+		if (compat_release_entry(iter0, &j) != 0)
+			break;
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(NFPROTO_ARP);
@@ -1515,6 +1551,7 @@ static int compat_do_replace(struct net *net, void __user *user,
 	struct compat_arpt_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct arpt_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1552,7 +1589,9 @@ static int compat_do_replace(struct net *net, void __user *user,
 	return 0;
 
  free_newinfo_untrans:
-	ARPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1636,6 +1675,7 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	int ret = 0;
 	void *loc_cpu_entry;
 	unsigned int i = 0;
+	struct arpt_entry *iter;
 
 	counters = alloc_counters(table);
 	if (IS_ERR(counters))
@@ -1645,9 +1685,12 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	ret = ARPT_ENTRY_ITERATE(loc_cpu_entry, total_size,
-				 compat_copy_entry_to_user,
-				 &pos, &size, counters, &i);
+	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+		ret = compat_copy_entry_to_user(iter, &pos,
+		      &size, counters, &i);
+		if (ret != 0)
+			break;
+	}
 	vfree(counters);
 	return ret;
 }
@@ -1843,13 +1886,15 @@ void arpt_unregister_table(struct xt_table *table)
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
 	struct module *table_owner = table->me;
+	struct arpt_entry *iter;
 
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
-	ARPT_ENTRY_ITERATE(loc_cpu_entry, private->size,
-			   cleanup_entry, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (cleanup_entry(iter, NULL) != 0)
+			break;
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e94c18b..b43280a 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -288,6 +288,7 @@ static void trace_packet(const struct sk_buff *skb,
 	const void *table_base;
 	const struct ipt_entry *root;
 	const char *hookname, *chainname, *comment;
+	const struct ipt_entry *iter;
 	unsigned int rulenum = 0;
 
 	table_base = private->entries[smp_processor_id()];
@@ -296,10 +297,10 @@ static void trace_packet(const struct sk_buff *skb,
 	hookname = chainname = hooknames[hook];
 	comment = comments[NF_IP_TRACE_COMMENT_RULE];
 
-	IPT_ENTRY_ITERATE(root,
-			  private->size - private->hook_entry[hook],
-			  get_chainname_rulenum,
-			  e, hookname, &chainname, &comment, &rulenum);
+	xt_entry_foreach(iter, root, private->size - private->hook_entry[hook])
+		if (get_chainname_rulenum(iter, e, hookname,
+		    &chainname, &comment, &rulenum) != 0)
+			break;
 
 	nf_log_packet(AF_INET, hook, skb, in, out, &trace_loginfo,
 		      "TRACE: %s:%s:%s:%u ",
@@ -826,8 +827,9 @@ translate_table(struct net *net,
 		const unsigned int *hook_entries,
 		const unsigned int *underflows)
 {
+	struct ipt_entry *iter;
 	unsigned int i;
-	int ret;
+	int ret = 0;
 
 	newinfo->size = size;
 	newinfo->number = number;
@@ -841,12 +843,13 @@ translate_table(struct net *net,
 	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 	/* Walk through entries, checking offsets. */
-	ret = IPT_ENTRY_ITERATE(entry0, newinfo->size,
-				check_entry_size_and_hooks,
-				newinfo,
-				entry0,
-				entry0 + size,
-				hook_entries, underflows, valid_hooks, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
+		      entry0 + size, hook_entries, underflows,
+		      valid_hooks, &i);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		return ret;
 
@@ -878,12 +881,16 @@ translate_table(struct net *net,
 
 	/* Finally, each sanity check must pass */
 	i = 0;
-	ret = IPT_ENTRY_ITERATE(entry0, newinfo->size,
-				find_check_entry, net, name, size, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = find_check_entry(iter, net, name, size, &i);
+		if (ret != 0)
+			break;
+	}
 
 	if (ret != 0) {
-		IPT_ENTRY_ITERATE(entry0, newinfo->size,
-				cleanup_entry, net, &i);
+		xt_entry_foreach(iter, entry0, newinfo->size)
+			if (cleanup_entry(iter, net, &i) != 0)
+				break;
 		return ret;
 	}
 
@@ -923,6 +930,7 @@ static void
 get_counters(const struct xt_table_info *t,
 	     struct xt_counters counters[])
 {
+	struct ipt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
@@ -938,22 +946,18 @@ get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	IPT_ENTRY_ITERATE(t->entries[curcpu],
-			  t->size,
-			  set_entry_to_counter,
-			  counters,
-			  &i);
+	xt_entry_foreach(iter, t->entries[curcpu], t->size)
+		if (set_entry_to_counter(iter, counters, &i) != 0)
+			break;
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		IPT_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+		xt_entry_foreach(iter, t->entries[cpu], t->size)
+			if (add_entry_to_counter(iter, counters, &i) != 0)
+				break;
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -1111,7 +1115,9 @@ static int compat_calc_entry(const struct ipt_entry *e,
 static int compat_table_info(const struct xt_table_info *info,
 			     struct xt_table_info *newinfo)
 {
+	struct ipt_entry *iter;
 	void *loc_cpu_entry;
+	int ret = 0;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -1120,9 +1126,12 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
-	return IPT_ENTRY_ITERATE(loc_cpu_entry, info->size,
-				 compat_calc_entry, info, loc_cpu_entry,
-				 newinfo);
+	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
+		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
+		if (ret != 0)
+			break;
+	}
+	return ret;
 }
 #endif
 
@@ -1236,6 +1245,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
 	void *loc_cpu_old_entry;
+	struct ipt_entry *iter;
 
 	ret = 0;
 	counters = vmalloc(num_counters * sizeof(struct xt_counters));
@@ -1278,8 +1288,10 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
-			  net, NULL);
+	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
+
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
 			 sizeof(struct xt_counters) * num_counters) != 0)
@@ -1304,6 +1316,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	struct ipt_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct ipt_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1339,7 +1352,9 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1373,6 +1388,7 @@ do_add_counters(struct net *net, const void __user *user,
 	const struct xt_table_info *private;
 	int ret = 0;
 	void *loc_cpu_entry;
+	struct ipt_entry *iter;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1430,11 +1446,9 @@ do_add_counters(struct net *net, const void __user *user,
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_info_wrlock(curcpu);
-	IPT_ENTRY_ITERATE(loc_cpu_entry,
-			  private->size,
-			  add_counter_to_entry,
-			  paddc,
-			  &i);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (add_counter_to_entry(iter, paddc, &i) != 0)
+			break;
 	xt_info_wrunlock(curcpu);
  unlock_up_free:
 	local_bh_enable();
@@ -1720,8 +1734,10 @@ translate_compat_table(struct net *net,
 	unsigned int i, j;
 	struct xt_table_info *newinfo, *info;
 	void *pos, *entry0, *entry1;
+	struct compat_ipt_entry *iter0;
+	struct ipt_entry *iter1;
 	unsigned int size;
-	int ret;
+	int ret = 0;
 
 	info = *pinfo;
 	entry0 = *pentry0;
@@ -1738,11 +1754,13 @@ translate_compat_table(struct net *net,
 	j = 0;
 	xt_compat_lock(AF_INET);
 	/* Walk through entries, checking offsets. */
-	ret = COMPAT_IPT_ENTRY_ITERATE(entry0, total_size,
-				       check_compat_entry_size_and_hooks,
-				       info, &size, entry0,
-				       entry0 + total_size,
-				       hook_entries, underflows, &j, name);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
+		      entry0, entry0 + total_size, hook_entries, underflows,
+		      &j, name);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto out_unlock;
 
@@ -1783,9 +1801,12 @@ translate_compat_table(struct net *net,
 	entry1 = newinfo->entries[raw_smp_processor_id()];
 	pos = entry1;
 	size = total_size;
-	ret = COMPAT_IPT_ENTRY_ITERATE(entry0, total_size,
-				       compat_copy_entry_from_user,
-				       &pos, &size, name, newinfo, entry1);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = compat_copy_entry_from_user(iter0, &pos,
+		      &size, name, newinfo, entry1);
+		if (ret != 0)
+			break;
+	}
 	xt_compat_flush_offsets(AF_INET);
 	xt_compat_unlock(AF_INET);
 	if (ret)
@@ -1796,13 +1817,28 @@ translate_compat_table(struct net *net,
 		goto free_newinfo;
 
 	i = 0;
-	ret = IPT_ENTRY_ITERATE(entry1, newinfo->size, compat_check_entry,
-				net, name, &i);
+	xt_entry_foreach(iter1, entry1, newinfo->size) {
+		ret = compat_check_entry(iter1, net, name, &i);
+		if (ret != 0)
+			break;
+	}
 	if (ret) {
+		/*
+		 * The first i matches need cleanup_entry (calls ->destroy)
+		 * because they had called ->check already. The other j-i
+		 * entries need only release.
+		 */
+		int skip = i;
 		j -= i;
-		COMPAT_IPT_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
-						  compat_release_entry, &j);
-		IPT_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, net, &i);
+		xt_entry_foreach(iter0, entry0, newinfo->size) {
+			if (skip-- > 0)
+				continue;
+			if (compat_release_entry(iter0, &i) != 0)
+				break;
+		}
+		xt_entry_foreach(iter1, entry1, newinfo->size)
+			if (cleanup_entry(iter1, net, &i) != 0)
+				break;
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1820,7 +1856,9 @@ translate_compat_table(struct net *net,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	COMPAT_IPT_ENTRY_ITERATE(entry0, total_size, compat_release_entry, &j);
+	xt_entry_foreach(iter0, entry0, total_size)
+		if (compat_release_entry(iter0, &j) != 0)
+			break;
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(AF_INET);
@@ -1835,6 +1873,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	struct compat_ipt_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct ipt_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1873,7 +1912,9 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1922,6 +1963,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	int ret = 0;
 	const void *loc_cpu_entry;
 	unsigned int i = 0;
+	struct ipt_entry *iter;
 
 	counters = alloc_counters(table);
 	if (IS_ERR(counters))
@@ -1934,9 +1976,12 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	ret = IPT_ENTRY_ITERATE(loc_cpu_entry, total_size,
-				compat_copy_entry_to_user,
-				&pos, &size, counters, &i);
+	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+		ret = compat_copy_entry_to_user(iter, &pos,
+		      &size, counters, &i);
+		if (ret != 0)
+			break;
+	}
 
 	vfree(counters);
 	return ret;
@@ -2137,12 +2182,15 @@ void ipt_unregister_table(struct net *net, struct xt_table *table)
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
 	struct module *table_owner = table->me;
+	struct ipt_entry *iter;
 
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
-	IPT_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4185099..23926e3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -318,6 +318,7 @@ static void trace_packet(const struct sk_buff *skb,
 	const void *table_base;
 	const struct ip6t_entry *root;
 	const char *hookname, *chainname, *comment;
+	const struct ip6t_entry *iter;
 	unsigned int rulenum = 0;
 
 	table_base = private->entries[smp_processor_id()];
@@ -326,10 +327,10 @@ static void trace_packet(const struct sk_buff *skb,
 	hookname = chainname = hooknames[hook];
 	comment = comments[NF_IP6_TRACE_COMMENT_RULE];
 
-	IP6T_ENTRY_ITERATE(root,
-			   private->size - private->hook_entry[hook],
-			   get_chainname_rulenum,
-			   e, hookname, &chainname, &comment, &rulenum);
+	xt_entry_foreach(iter, root, private->size - private->hook_entry[hook])
+		if (get_chainname_rulenum(iter, e, hookname,
+		    &chainname, &comment, &rulenum) != 0)
+			break;
 
 	nf_log_packet(AF_INET6, hook, skb, in, out, &trace_loginfo,
 		      "TRACE: %s:%s:%s:%u ",
@@ -857,8 +858,9 @@ translate_table(struct net *net,
 		const unsigned int *hook_entries,
 		const unsigned int *underflows)
 {
+	struct ip6t_entry *iter;
 	unsigned int i;
-	int ret;
+	int ret = 0;
 
 	newinfo->size = size;
 	newinfo->number = number;
@@ -872,12 +874,13 @@ translate_table(struct net *net,
 	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 	/* Walk through entries, checking offsets. */
-	ret = IP6T_ENTRY_ITERATE(entry0, newinfo->size,
-				check_entry_size_and_hooks,
-				newinfo,
-				entry0,
-				entry0 + size,
-				hook_entries, underflows, valid_hooks, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
+		      entry0 + size, hook_entries, underflows,
+		      valid_hooks, &i);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		return ret;
 
@@ -909,12 +912,16 @@ translate_table(struct net *net,
 
 	/* Finally, each sanity check must pass */
 	i = 0;
-	ret = IP6T_ENTRY_ITERATE(entry0, newinfo->size,
-				find_check_entry, net, name, size, &i);
+	xt_entry_foreach(iter, entry0, newinfo->size) {
+		ret = find_check_entry(iter, net, name, size, &i);
+		if (ret != 0)
+			break;
+	}
 
 	if (ret != 0) {
-		IP6T_ENTRY_ITERATE(entry0, newinfo->size,
-				   cleanup_entry, net, &i);
+		xt_entry_foreach(iter, entry0, newinfo->size)
+			if (cleanup_entry(iter, net, &i) != 0)
+				break;
 		return ret;
 	}
 
@@ -954,6 +961,7 @@ static void
 get_counters(const struct xt_table_info *t,
 	     struct xt_counters counters[])
 {
+	struct ip6t_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
 	unsigned int curcpu;
@@ -969,22 +977,18 @@ get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	IP6T_ENTRY_ITERATE(t->entries[curcpu],
-			   t->size,
-			   set_entry_to_counter,
-			   counters,
-			   &i);
+	xt_entry_foreach(iter, t->entries[curcpu], t->size)
+		if (set_entry_to_counter(iter, counters, &i) != 0)
+			break;
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		IP6T_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+		xt_entry_foreach(iter, t->entries[cpu], t->size)
+			if (add_entry_to_counter(iter, counters, &i) != 0)
+				break;
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -1142,7 +1146,9 @@ static int compat_calc_entry(const struct ip6t_entry *e,
 static int compat_table_info(const struct xt_table_info *info,
 			     struct xt_table_info *newinfo)
 {
+	struct ip6t_entry *iter;
 	void *loc_cpu_entry;
+	int ret = 0;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -1151,9 +1157,12 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
-	return IP6T_ENTRY_ITERATE(loc_cpu_entry, info->size,
-				  compat_calc_entry, info, loc_cpu_entry,
-				  newinfo);
+	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
+		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
+		if (ret != 0)
+			break;
+	}
+	return ret;
 }
 #endif
 
@@ -1267,6 +1276,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	struct xt_table_info *oldinfo;
 	struct xt_counters *counters;
 	const void *loc_cpu_old_entry;
+	struct ip6t_entry *iter;
 
 	ret = 0;
 	counters = vmalloc_node(num_counters * sizeof(struct xt_counters),
@@ -1310,8 +1320,10 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
-	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
-			   net, NULL);
+	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
+
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
 			 sizeof(struct xt_counters) * num_counters) != 0)
@@ -1336,6 +1348,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	struct ip6t_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct ip6t_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1371,7 +1384,9 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1405,6 +1420,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	const struct xt_table_info *private;
 	int ret = 0;
 	const void *loc_cpu_entry;
+	struct ip6t_entry *iter;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1463,11 +1479,9 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	curcpu = smp_processor_id();
 	xt_info_wrlock(curcpu);
 	loc_cpu_entry = private->entries[curcpu];
-	IP6T_ENTRY_ITERATE(loc_cpu_entry,
-			  private->size,
-			  add_counter_to_entry,
-			  paddc,
-			  &i);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (add_counter_to_entry(iter, paddc, &i) != 0)
+			break;
 	xt_info_wrunlock(curcpu);
 
  unlock_up_free:
@@ -1753,8 +1767,10 @@ translate_compat_table(struct net *net,
 	unsigned int i, j;
 	struct xt_table_info *newinfo, *info;
 	void *pos, *entry0, *entry1;
+	struct compat_ip6t_entry *iter0;
+	struct ip6t_entry *iter1;
 	unsigned int size;
-	int ret;
+	int ret = 0;
 
 	info = *pinfo;
 	entry0 = *pentry0;
@@ -1771,11 +1787,13 @@ translate_compat_table(struct net *net,
 	j = 0;
 	xt_compat_lock(AF_INET6);
 	/* Walk through entries, checking offsets. */
-	ret = COMPAT_IP6T_ENTRY_ITERATE(entry0, total_size,
-					check_compat_entry_size_and_hooks,
-					info, &size, entry0,
-					entry0 + total_size,
-					hook_entries, underflows, &j, name);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
+		      entry0, entry0 + total_size, hook_entries, underflows,
+		      &j, name);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto out_unlock;
 
@@ -1816,9 +1834,12 @@ translate_compat_table(struct net *net,
 	entry1 = newinfo->entries[raw_smp_processor_id()];
 	pos = entry1;
 	size = total_size;
-	ret = COMPAT_IP6T_ENTRY_ITERATE(entry0, total_size,
-					compat_copy_entry_from_user,
-					&pos, &size, name, newinfo, entry1);
+	xt_entry_foreach(iter0, entry0, total_size) {
+		ret = compat_copy_entry_from_user(iter0, &pos,
+		      &size, name, newinfo, entry1);
+		if (ret != 0)
+			break;
+	}
 	xt_compat_flush_offsets(AF_INET6);
 	xt_compat_unlock(AF_INET6);
 	if (ret)
@@ -1829,13 +1850,28 @@ translate_compat_table(struct net *net,
 		goto free_newinfo;
 
 	i = 0;
-	ret = IP6T_ENTRY_ITERATE(entry1, newinfo->size, compat_check_entry,
-				 net, name, &i);
+	xt_entry_foreach(iter1, entry1, newinfo->size) {
+		ret = compat_check_entry(iter1, net, name, &i);
+		if (ret != 0)
+			break;
+	}
 	if (ret) {
+		/*
+		 * The first i matches need cleanup_entry (calls ->destroy)
+		 * because they had called ->check already. The other j-i
+		 * entries need only release.
+		 */
+		int skip = i;
 		j -= i;
-		COMPAT_IP6T_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
-						   compat_release_entry, &j);
-		IP6T_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, net, &i);
+		xt_entry_foreach(iter0, entry0, newinfo->size) {
+			if (skip-- > 0)
+				continue;
+			if (compat_release_entry(iter0, &j) != 0)
+				break;
+		}
+		xt_entry_foreach(iter1, entry1, newinfo->size)
+			if (cleanup_entry(iter1, net, &i) != 0)
+				break;
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1853,7 +1889,9 @@ translate_compat_table(struct net *net,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	COMPAT_IP6T_ENTRY_ITERATE(entry0, total_size, compat_release_entry, &j);
+	xt_entry_foreach(iter0, entry0, total_size)
+		if (compat_release_entry(iter0, &j) != 0)
+			break;
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(AF_INET6);
@@ -1868,6 +1906,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	struct compat_ip6t_replace tmp;
 	struct xt_table_info *newinfo;
 	void *loc_cpu_entry;
+	struct ip6t_entry *iter;
 
 	if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
 		return -EFAULT;
@@ -1906,7 +1945,9 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1955,6 +1996,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	int ret = 0;
 	const void *loc_cpu_entry;
 	unsigned int i = 0;
+	struct ip6t_entry *iter;
 
 	counters = alloc_counters(table);
 	if (IS_ERR(counters))
@@ -1967,9 +2009,12 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	pos = userptr;
 	size = total_size;
-	ret = IP6T_ENTRY_ITERATE(loc_cpu_entry, total_size,
-				 compat_copy_entry_to_user,
-				 &pos, &size, counters, &i);
+	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
+		ret = compat_copy_entry_to_user(iter, &pos,
+		      &size, counters, &i);
+		if (ret != 0)
+			break;
+	}
 
 	vfree(counters);
 	return ret;
@@ -2169,12 +2214,15 @@ void ip6t_unregister_table(struct net *net, struct xt_table *table)
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
 	struct module *table_owner = table->me;
+	struct ip6t_entry *iter;
 
 	private = xt_unregister_table(table);
 
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, net, NULL);
+	xt_entry_foreach(iter, loc_cpu_entry, private->size)
+		if (cleanup_entry(iter, net, NULL) != 0)
+			break;
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
