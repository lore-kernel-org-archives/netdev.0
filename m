From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: x_table: speedup compat operations
Date: Sat, 18 Dec 2010 18:35:15 +0100
Message-ID: <1292693715.18869.148.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One iptables invocation with 135000 rules takes 35 seconds of cpu time
on a recent server, using a 32bit distro and a 64bit kernel.

We eventually trigger NMI/RCU watchdog.

INFO: rcu_sched_state detected stall on CPU 3 (t=6000 jiffies)

COMPAT mode has quadratic behavior and consume 16 bytes of memory per
rule.

Switch the xt_compat algos to use an array instead of list, and use a
binary search to locate an offset in the sorted array.

This halves memory need (8 bytes per rule), and removes quadratic
behavior [ O(N*N) -> O(N*log2(N)) ]

Time of iptables goes from 35 s to 150 ms.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netfilter/x_tables.h |    3 
 net/bridge/netfilter/ebtables.c    |    1 
 net/ipv4/netfilter/arp_tables.c    |    2 
 net/ipv4/netfilter/ip_tables.c     |    2 
 net/ipv6/netfilter/ip6_tables.c    |    2 
 net/netfilter/x_tables.c           |   82 +++++++++++++++------------
 6 files changed, 57 insertions(+), 35 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 742bec0..0f04d98 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -611,8 +611,9 @@ struct _compat_xt_align {
 extern void xt_compat_lock(u_int8_t af);
 extern void xt_compat_unlock(u_int8_t af);
 
-extern int xt_compat_add_offset(u_int8_t af, unsigned int offset, short delta);
+extern int xt_compat_add_offset(u_int8_t af, unsigned int offset, int delta);
 extern void xt_compat_flush_offsets(u_int8_t af);
+extern void xt_compat_init_offsets(u_int8_t af, unsigned int number);
 extern int xt_compat_calc_jump(u_int8_t af, unsigned int offset);
 
 extern int xt_compat_match_offset(const struct xt_match *match);
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index cbc9f39..2bf2fb2 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1764,6 +1764,7 @@ static int compat_table_info(const struct ebt_table_info *info,
 
 	newinfo->entries_size = size;
 
+	xt_compat_init_offsets(AF_INET, info->nentries);
 	return EBT_ENTRY_ITERATE(entries, size, compat_calc_entry, info,
 							entries, newinfo);
 }
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 3fac340..47e5178 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -883,6 +883,7 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	xt_compat_init_offsets(NFPROTO_ARP, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
@@ -1350,6 +1351,7 @@ static int translate_compat_table(const char *name,
 	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(NFPROTO_ARP);
+	xt_compat_init_offsets(NFPROTO_ARP, number);
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a846d63..c5a75d7 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1080,6 +1080,7 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	xt_compat_init_offsets(AF_INET, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
@@ -1681,6 +1682,7 @@ translate_compat_table(struct net *net,
 	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(AF_INET);
+	xt_compat_init_offsets(AF_INET, number);
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4555823..0c9973a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1093,6 +1093,7 @@ static int compat_table_info(const struct xt_table_info *info,
 	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
 	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
+	xt_compat_init_offsets(AF_INET6, info->number);
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
@@ -1696,6 +1697,7 @@ translate_compat_table(struct net *net,
 	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(AF_INET6);
+	xt_compat_init_offsets(AF_INET6, number);
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8046350..75182ed 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -38,9 +38,8 @@ MODULE_DESCRIPTION("{ip,ip6,arp,eb}_tables backend module");
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
 struct compat_delta {
-	struct compat_delta *next;
-	unsigned int offset;
-	int delta;
+	unsigned int offset; /* offset in kernel */
+	int delta; /* delta in 32bit user land */
 };
 
 struct xt_af {
@@ -49,7 +48,9 @@ struct xt_af {
 	struct list_head target;
 #ifdef CONFIG_COMPAT
 	struct mutex compat_mutex;
-	struct compat_delta *compat_offsets;
+	struct compat_delta *compat_tab;
+	unsigned int number; /* number of slots in compat_tab[] */
+	unsigned int cur; /* number of used slots in compat_tab[] */
 #endif
 };
 
@@ -414,54 +415,67 @@ int xt_check_match(struct xt_mtchk_param *par,
 EXPORT_SYMBOL_GPL(xt_check_match);
 
 #ifdef CONFIG_COMPAT
-int xt_compat_add_offset(u_int8_t af, unsigned int offset, short delta)
+int xt_compat_add_offset(u_int8_t af, unsigned int offset, int delta)
 {
-	struct compat_delta *tmp;
+	struct xt_af *xp = &xt[af];
 
-	tmp = kmalloc(sizeof(struct compat_delta), GFP_KERNEL);
-	if (!tmp)
-		return -ENOMEM;
+	if (!xp->compat_tab) {
+		if (!xp->number)
+			return -EINVAL;
+		xp->compat_tab = vmalloc(sizeof(struct compat_delta) * xp->number);
+		if (!xp->compat_tab)
+			return -ENOMEM;
+		xp->cur = 0;
+	}
 
-	tmp->offset = offset;
-	tmp->delta = delta;
+	if (xp->cur >= xp->number)
+		return -EINVAL;
 
-	if (xt[af].compat_offsets) {
-		tmp->next = xt[af].compat_offsets->next;
-		xt[af].compat_offsets->next = tmp;
-	} else {
-		xt[af].compat_offsets = tmp;
-		tmp->next = NULL;
-	}
+	if (xp->cur)
+		delta += xp->compat_tab[xp->cur - 1].delta;
+	xp->compat_tab[xp->cur].offset = offset;
+	xp->compat_tab[xp->cur].delta = delta;
+	xp->cur++;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xt_compat_add_offset);
 
 void xt_compat_flush_offsets(u_int8_t af)
 {
-	struct compat_delta *tmp, *next;
-
-	if (xt[af].compat_offsets) {
-		for (tmp = xt[af].compat_offsets; tmp; tmp = next) {
-			next = tmp->next;
-			kfree(tmp);
-		}
-		xt[af].compat_offsets = NULL;
+	if (xt[af].compat_tab) {
+		vfree(xt[af].compat_tab);
+		xt[af].compat_tab = NULL;
+		xt[af].number = 0;
 	}
 }
 EXPORT_SYMBOL_GPL(xt_compat_flush_offsets);
 
 int xt_compat_calc_jump(u_int8_t af, unsigned int offset)
 {
-	struct compat_delta *tmp;
-	int delta;
-
-	for (tmp = xt[af].compat_offsets, delta = 0; tmp; tmp = tmp->next)
-		if (tmp->offset < offset)
-			delta += tmp->delta;
-	return delta;
+	struct compat_delta *tmp = xt[af].compat_tab;
+	int mid, left = 0, right = xt[af].cur - 1;
+
+	while (left <= right) {
+		mid = (left + right) >> 1;
+		if (offset > tmp[mid].offset)
+			left = mid + 1;
+		else if (offset < tmp[mid].offset)
+			right = mid - 1;
+		else
+			return mid ? tmp[mid - 1].delta : 0;
+	}
+	WARN_ON_ONCE(1);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(xt_compat_calc_jump);
 
+void xt_compat_init_offsets(u_int8_t af, unsigned int number)
+{
+	xt[af].number = number;
+	xt[af].cur = 0;
+}
+EXPORT_SYMBOL(xt_compat_init_offsets);
+
 int xt_compat_match_offset(const struct xt_match *match)
 {
 	u_int16_t csize = match->compatsize ? : match->matchsize;
@@ -1337,7 +1351,7 @@ static int __init xt_init(void)
 		mutex_init(&xt[i].mutex);
 #ifdef CONFIG_COMPAT
 		mutex_init(&xt[i].compat_mutex);
-		xt[i].compat_offsets = NULL;
+		xt[i].compat_tab = NULL;
 #endif
 		INIT_LIST_HEAD(&xt[i].target);
 		INIT_LIST_HEAD(&xt[i].match);


