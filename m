From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 4/5] netfilter: xtables2: make ip_tables reentrant
Date: Wed, 31 Mar 2010 12:38:52 +0200
Message-ID: <1270031934-15940-5-git-send-email-jengelh@medozas.de>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the table traverser stores return addresses in the ruleset
itself (struct ip6t_entry->comefrom). This has a well-known drawback:
the jumpstack is overwritten on reentry, making it necessary for
targets to return absolute verdicts. Also, the ruleset (which might
be heavy memory-wise) needs to be replicated for each CPU that can
possibly invoke ip6t_do_table.

This patch decouples the jumpstack from struct ip6t_entry and instead
puts it into xt_table_info. Not being restricted by 'comefrom'
anymore, we can set up a stack as needed. By default, there is room
allocated for two entries into the traverser. The setting is
configurable at runtime through sysfs and will take effect when a
table is replaced by a new one.

arp_tables is not touched though, because there is just one/two
modules and further patches seek to collapse the table traverser
anyhow.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    7 +++
 net/ipv4/netfilter/arp_tables.c    |    6 ++-
 net/ipv4/netfilter/ip_tables.c     |   65 ++++++++++++++++--------------
 net/ipv6/netfilter/ip6_tables.c    |   56 ++++++++++---------------
 net/netfilter/x_tables.c           |   79 ++++++++++++++++++++++++++++++++++++
 5 files changed, 147 insertions(+), 66 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 1a65d45..62cc5ca 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -401,6 +401,13 @@ struct xt_table_info {
 	unsigned int hook_entry[NF_INET_NUMHOOKS];
 	unsigned int underflow[NF_INET_NUMHOOKS];
 
+	/*
+	 * Number of user chains. Since tables cannot have loops, at most
+	 * @stacksize jumps (number of user chains) can possibly be made.
+	 */
+	unsigned int stacksize;
+	unsigned int *stackptr;
+	void ***jumpstack;
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
 	void *entries[1];
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index e8e363d..07a6990 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -649,6 +649,9 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			break;
 		++i;
+		if (strcmp(arpt_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
@@ -1774,8 +1777,7 @@ struct xt_table *arpt_register_table(struct net *net,
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap = {0};
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 18c5b15..70900ec 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -321,8 +321,6 @@ ipt_do_table(struct sk_buff *skb,
 	     const struct net_device *out,
 	     struct xt_table *table)
 {
-#define tb_comefrom ((struct ipt_entry *)table_base)->comefrom
-
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
 	bool hotdrop = false;
@@ -330,7 +328,8 @@ ipt_do_table(struct sk_buff *skb,
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
 	const void *table_base;
-	struct ipt_entry *e, *back;
+	struct ipt_entry *e, **jumpstack;
+	unsigned int *stackptr, origptr, cpu;
 	const struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
@@ -356,19 +355,23 @@ ipt_do_table(struct sk_buff *skb,
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	xt_info_rdlock_bh();
 	private = table->private;
-	table_base = private->entries[smp_processor_id()];
+	cpu        = smp_processor_id();
+	table_base = private->entries[cpu];
+	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
+	stackptr   = &private->stackptr[cpu];
+	origptr    = *stackptr;
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	/* For return from builtin chain */
-	back = get_entry(table_base, private->underflow[hook]);
+	pr_devel("Entering %s(hook %u); sp at %u (UF %p)\n",
+		 table->name, hook, origptr,
+		 get_entry(table_base, private->underflow[hook]));
 
 	do {
 		const struct ipt_entry_target *t;
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
-		IP_NF_ASSERT(back);
 		if (!ip_packet_match(ip, indev, outdev,
 		    &e->ip, mtpar.fragoff)) {
  no_match:
@@ -403,17 +406,28 @@ ipt_do_table(struct sk_buff *skb,
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
-				e = back;
-				back = get_entry(table_base, back->comefrom);
+				if (*stackptr == 0) {
+					e = get_entry(table_base,
+					    private->underflow[hook]);
+					pr_devel("Underflow (this is normal) "
+						 "to %p\n", e);
+				} else {
+					e = jumpstack[--*stackptr];
+					pr_devel("Pulled %p out from pos %u\n",
+						 e, *stackptr);
+					e = ipt_next_entry(e);
+				}
 				continue;
 			}
 			if (table_base + v != ipt_next_entry(e) &&
 			    !(e->ip.flags & IPT_F_GOTO)) {
-				/* Save old back ptr in next entry */
-				struct ipt_entry *next = ipt_next_entry(e);
-				next->comefrom = (void *)back - table_base;
-				/* set back pointer to next entry */
-				back = next;
+				if (*stackptr >= private->stacksize) {
+					verdict = NF_DROP;
+					break;
+				}
+				jumpstack[(*stackptr)++] = e;
+				pr_devel("Pushed %p into pos %u\n",
+					 e, *stackptr - 1);
 			}
 
 			e = get_entry(table_base, v);
@@ -426,18 +440,7 @@ ipt_do_table(struct sk_buff *skb,
 		tgpar.targinfo = t->data;
 
 
-#ifdef CONFIG_NETFILTER_DEBUG
-		tb_comefrom = 0xeeeeeeec;
-#endif
 		verdict = t->u.kernel.target->target(skb, &tgpar);
-#ifdef CONFIG_NETFILTER_DEBUG
-		if (tb_comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
-			printk("Target %s reentered!\n",
-			       t->u.kernel.target->name);
-			verdict = NF_DROP;
-		}
-		tb_comefrom = 0x57acc001;
-#endif
 		/* Target might have changed stuff. */
 		ip = ip_hdr(skb);
 		if (verdict == IPT_CONTINUE)
@@ -447,7 +450,9 @@ ipt_do_table(struct sk_buff *skb,
 			break;
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
-
+	pr_devel("Exiting %s; resetting sp from %u to %u\n",
+		 __func__, *stackptr, origptr);
+	*stackptr = origptr;
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
@@ -455,8 +460,6 @@ ipt_do_table(struct sk_buff *skb,
 		return NF_DROP;
 	else return verdict;
 #endif
-
-#undef tb_comefrom
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
@@ -838,6 +841,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
+		if (strcmp(ipt_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -2086,8 +2092,7 @@ struct xt_table *ipt_register_table(struct net *net,
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap = {0};
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index f2b815e..2a2770b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -351,15 +351,14 @@ ip6t_do_table(struct sk_buff *skb,
 	      const struct net_device *out,
 	      struct xt_table *table)
 {
-#define tb_comefrom ((struct ip6t_entry *)table_base)->comefrom
-
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	bool hotdrop = false;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
 	const void *table_base;
-	struct ip6t_entry *e, *back;
+	struct ip6t_entry *e, **jumpstack;
+	unsigned int *stackptr, origptr, cpu;
 	const struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
@@ -383,19 +382,19 @@ ip6t_do_table(struct sk_buff *skb,
 
 	xt_info_rdlock_bh();
 	private = table->private;
-	table_base = private->entries[smp_processor_id()];
+	cpu        = smp_processor_id();
+	table_base = private->entries[cpu];
+	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
+	stackptr   = &private->stackptr[cpu];
+	origptr    = *stackptr;
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	/* For return from builtin chain */
-	back = get_entry(table_base, private->underflow[hook]);
-
 	do {
 		const struct ip6t_entry_target *t;
 		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
-		IP_NF_ASSERT(back);
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
 		    &mtpar.thoff, &mtpar.fragoff, &hotdrop)) {
  no_match:
@@ -432,17 +431,20 @@ ip6t_do_table(struct sk_buff *skb,
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
-				e = back;
-				back = get_entry(table_base, back->comefrom);
+				if (*stackptr == 0)
+					e = get_entry(table_base,
+					    private->underflow[hook]);
+				else
+					e = ip6t_next_entry(jumpstack[--*stackptr]);
 				continue;
 			}
 			if (table_base + v != ip6t_next_entry(e) &&
 			    !(e->ipv6.flags & IP6T_F_GOTO)) {
-				/* Save old back ptr in next entry */
-				struct ip6t_entry *next = ip6t_next_entry(e);
-				next->comefrom = (void *)back - table_base;
-				/* set back pointer to next entry */
-				back = next;
+				if (*stackptr >= private->stacksize) {
+					verdict = NF_DROP;
+					break;
+				}
+				jumpstack[(*stackptr)++] = e;
 			}
 
 			e = get_entry(table_base, v);
@@ -454,19 +456,7 @@ ip6t_do_table(struct sk_buff *skb,
 		tgpar.target   = t->u.kernel.target;
 		tgpar.targinfo = t->data;
 
-#ifdef CONFIG_NETFILTER_DEBUG
-		tb_comefrom = 0xeeeeeeec;
-#endif
 		verdict = t->u.kernel.target->target(skb, &tgpar);
-
-#ifdef CONFIG_NETFILTER_DEBUG
-		if (tb_comefrom != 0xeeeeeeec && verdict == IP6T_CONTINUE) {
-			printk("Target %s reentered!\n",
-			       t->u.kernel.target->name);
-			verdict = NF_DROP;
-		}
-		tb_comefrom = 0x57acc001;
-#endif
 		if (verdict == IP6T_CONTINUE)
 			e = ip6t_next_entry(e);
 		else
@@ -474,10 +464,8 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!hotdrop);
 
-#ifdef CONFIG_NETFILTER_DEBUG
-	tb_comefrom = NETFILTER_LINK_POISON;
-#endif
 	xt_info_rdunlock_bh();
+	*stackptr = origptr;
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -486,8 +474,6 @@ ip6t_do_table(struct sk_buff *skb,
 		return NF_DROP;
 	else return verdict;
 #endif
-
-#undef tb_comefrom
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
@@ -869,6 +855,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
+		if (strcmp(ip6t_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -2120,8 +2109,7 @@ struct xt_table *ip6t_register_table(struct net *net,
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap = {0};
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8e23d8f..2010b56 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -62,6 +62,11 @@ static const char *const xt_prefix[NFPROTO_NUMPROTO] = {
 	[NFPROTO_IPV6]   = "ip6",
 };
 
+/* Allow this many total (re)entries. */
+static unsigned int xt_jumpstack_multiplier = 2;
+module_param_named(jumpstack_multiplier, xt_jumpstack_multiplier,
+	uint, S_IRUGO | S_IWUSR);
+
 /* Registration hooks for targets. */
 int
 xt_register_target(struct xt_target *target)
@@ -680,6 +685,26 @@ void xt_free_table_info(struct xt_table_info *info)
 		else
 			vfree(info->entries[cpu]);
 	}
+
+	if (info->jumpstack != NULL) {
+		if (sizeof(void *) * info->stacksize > PAGE_SIZE) {
+			for_each_possible_cpu(cpu)
+				vfree(info->jumpstack[cpu]);
+		} else {
+			for_each_possible_cpu(cpu)
+				kfree(info->jumpstack[cpu]);
+		}
+	}
+
+	if (sizeof(void **) * nr_cpu_ids > PAGE_SIZE)
+		vfree(info->jumpstack);
+	else
+		kfree(info->jumpstack);
+	if (sizeof(unsigned int) * nr_cpu_ids > PAGE_SIZE)
+		vfree(info->stackptr);
+	else
+		kfree(info->stackptr);
+
 	kfree(info);
 }
 EXPORT_SYMBOL(xt_free_table_info);
@@ -724,6 +749,49 @@ EXPORT_SYMBOL_GPL(xt_compat_unlock);
 DEFINE_PER_CPU(struct xt_info_lock, xt_info_locks);
 EXPORT_PER_CPU_SYMBOL_GPL(xt_info_locks);
 
+static int xt_jumpstack_alloc(struct xt_table_info *i)
+{
+	unsigned int size;
+	int cpu;
+
+	size = sizeof(unsigned int) * nr_cpu_ids;
+	if (size > PAGE_SIZE)
+		i->stackptr = vmalloc(size);
+	else
+		i->stackptr = kmalloc(size, GFP_KERNEL);
+	if (i->stackptr == NULL)
+		return -ENOMEM;
+	memset(i->stackptr, 0, size);
+
+	size = sizeof(void **) * nr_cpu_ids;
+	if (size > PAGE_SIZE)
+		i->jumpstack = vmalloc(size);
+	else
+		i->jumpstack = kmalloc(size, GFP_KERNEL);
+	if (i->jumpstack == NULL)
+		return -ENOMEM;
+	memset(i->jumpstack, 0, size);
+
+	i->stacksize *= xt_jumpstack_multiplier;
+	size = sizeof(void *) * i->stacksize;
+	for_each_possible_cpu(cpu) {
+		if (size > PAGE_SIZE)
+			i->jumpstack[cpu] = vmalloc_node(size,
+				cpu_to_node(cpu));
+		else
+			i->jumpstack[cpu] = kmalloc_node(size,
+				GFP_KERNEL, cpu_to_node(cpu));
+		if (i->jumpstack[cpu] == NULL)
+			/*
+			 * Freeing will be done later on by the callers. The
+			 * chain is: xt_replace_table -> __do_replace ->
+			 * do_replace -> xt_free_table_info.
+			 */
+			return -ENOMEM;
+	}
+
+	return 0;
+}
 
 struct xt_table_info *
 xt_replace_table(struct xt_table *table,
@@ -732,6 +800,7 @@ xt_replace_table(struct xt_table *table,
 	      int *error)
 {
 	struct xt_table_info *private;
+	int ret;
 
 	/* Do the substitution. */
 	local_bh_disable();
@@ -746,6 +815,12 @@ xt_replace_table(struct xt_table *table,
 		return NULL;
 	}
 
+	ret = xt_jumpstack_alloc(newinfo);
+	if (ret < 0) {
+		*error = ret;
+		return NULL;
+	}
+
 	table->private = newinfo;
 	newinfo->initial_entries = private->initial_entries;
 
@@ -770,6 +845,10 @@ struct xt_table *xt_register_table(struct net *net,
 	struct xt_table_info *private;
 	struct xt_table *t, *table;
 
+	ret = xt_jumpstack_alloc(newinfo);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
 	/* Don't add one object to multiple lists. */
 	table = kmemdup(input_table, sizeof(struct xt_table), GFP_KERNEL);
 	if (!table) {
-- 
1.7.0.2

