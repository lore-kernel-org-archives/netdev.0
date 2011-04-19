From: kaber@trash.net
Subject: [PATCH 1/3] netfilter: get rid of atomic ops in fast path
Date: Tue, 19 Apr 2011 16:31:30 +0200
Message-ID: <1303223492-13549-2-git-send-email-kaber@trash.net>
References: <1303223492-13549-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39712 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab1DSObj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:31:39 -0400
In-Reply-To: <1303223492-13549-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

We currently use a percpu spinlock to 'protect' rule bytes/packets
counters, after various attempts to use RCU instead.

Lately we added a seqlock so that get_counters() can run without
blocking BH or 'writers'. But we really only need the seqcount in it.

Spinlock itself is only locked by the current/owner cpu, so we can
remove it completely.

This cleanups api, using correct 'writer' vs 'reader' semantic.

At replace time, the get_counters() call makes sure all cpus are done
using the old table.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/x_tables.h |   96 ++++++++++++++++--------------------
 net/ipv4/netfilter/arp_tables.c    |   18 ++++---
 net/ipv4/netfilter/ip_tables.c     |   28 +++++------
 net/ipv6/netfilter/ip6_tables.c    |   19 +++++---
 net/netfilter/x_tables.c           |    9 +--
 5 files changed, 80 insertions(+), 90 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 3721952..32cddf7 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -456,72 +456,60 @@ extern void xt_proto_fini(struct net *net, u_int8_t af);
 extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
 
-/*
- * Per-CPU spinlock associated with per-cpu table entries, and
- * with a counter for the "reading" side that allows a recursive
- * reader to avoid taking the lock and deadlocking.
- *
- * "reading" is used by ip/arp/ip6 tables rule processing which runs per-cpu.
- * It needs to ensure that the rules are not being changed while the packet
- * is being processed. In some cases, the read lock will be acquired
- * twice on the same CPU; this is okay because of the count.
- *
- * "writing" is used when reading counters.
- *  During replace any readers that are using the old tables have to complete
- *  before freeing the old table. This is handled by the write locking
- *  necessary for reading the counters.
+/**
+ * xt_recseq - recursive seqcount for netfilter use
+ * 
+ * Packet processing changes the seqcount only if no recursion happened
+ * get_counters() can use read_seqcount_begin()/read_seqcount_retry(),
+ * because we use the normal seqcount convention :
+ * Low order bit set to 1 if a writer is active.
  */
-struct xt_info_lock {
-	seqlock_t lock;
-	unsigned char readers;
-};
-DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);
+DECLARE_PER_CPU(seqcount_t, xt_recseq);
 
-/*
- * Note: we need to ensure that preemption is disabled before acquiring
- * the per-cpu-variable, so we do it as a two step process rather than
- * using "spin_lock_bh()".
- *
- * We _also_ need to disable bottom half processing before updating our
- * nesting count, to make sure that the only kind of re-entrancy is this
- * code being called by itself: since the count+lock is not an atomic
- * operation, we can allow no races.
+/**
+ * xt_write_recseq_begin - start of a write section
  *
- * _Only_ that special combination of being per-cpu and never getting
- * re-entered asynchronously means that the count is safe.
+ * Begin packet processing : all readers must wait the end
+ * 1) Must be called with preemption disabled
+ * 2) softirqs must be disabled too (or we should use irqsafe_cpu_add())
+ * Returns :
+ *  1 if no recursion on this cpu
+ *  0 if recursion detected
  */
-static inline void xt_info_rdlock_bh(void)
+static inline unsigned int xt_write_recseq_begin(void)
 {
-	struct xt_info_lock *lock;
+	unsigned int addend;
 
-	local_bh_disable();
-	lock = &__get_cpu_var(xt_info_locks);
-	if (likely(!lock->readers++))
-		write_seqlock(&lock->lock);
-}
+	/*
+	 * Low order bit of sequence is set if we already
+	 * called xt_write_recseq_begin().
+	 */
+	addend = (__this_cpu_read(xt_recseq.sequence) + 1) & 1;
 
-static inline void xt_info_rdunlock_bh(void)
-{
-	struct xt_info_lock *lock = &__get_cpu_var(xt_info_locks);
+	/*
+	 * This is kind of a write_seqcount_begin(), but addend is 0 or 1
+	 * We dont check addend value to avoid a test and conditional jump,
+	 * since addend is most likely 1
+	 */
+	__this_cpu_add(xt_recseq.sequence, addend);
+	smp_wmb();
 
-	if (likely(!--lock->readers))
-		write_sequnlock(&lock->lock);
-	local_bh_enable();
+	return addend;
 }
 
-/*
- * The "writer" side needs to get exclusive access to the lock,
- * regardless of readers.  This must be called with bottom half
- * processing (and thus also preemption) disabled.
+/**
+ * xt_write_recseq_end - end of a write section
+ * @addend: return value from previous xt_write_recseq_begin()
+ *
+ * End packet processing : all readers can proceed
+ * 1) Must be called with preemption disabled
+ * 2) softirqs must be disabled too (or we should use irqsafe_cpu_add())
  */
-static inline void xt_info_wrlock(unsigned int cpu)
-{
-	write_seqlock(&per_cpu(xt_info_locks, cpu).lock);
-}
-
-static inline void xt_info_wrunlock(unsigned int cpu)
+static inline void xt_write_recseq_end(unsigned int addend)
 {
-	write_sequnlock(&per_cpu(xt_info_locks, cpu).lock);
+	/* this is kind of a write_seqcount_end(), but addend is 0 or 1 */
+	smp_wmb();
+	__this_cpu_add(xt_recseq.sequence, addend);
 }
 
 /*
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 4b5d457..2ea7433 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -260,6 +260,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	void *table_base;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
+	unsigned int addend;
 
 	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return NF_DROP;
@@ -267,7 +268,8 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	xt_info_rdlock_bh();
+	local_bh_disable();
+	addend = xt_write_recseq_begin();
 	private = table->private;
 	table_base = private->entries[smp_processor_id()];
 
@@ -338,7 +340,8 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	xt_info_rdunlock_bh();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 	if (acpar.hotdrop)
 		return NF_DROP;
@@ -712,7 +715,7 @@ static void get_counters(const struct xt_table_info *t,
 	unsigned int i;
 
 	for_each_possible_cpu(cpu) {
-		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
@@ -720,10 +723,10 @@ static void get_counters(const struct xt_table_info *t,
 			unsigned int start;
 
 			do {
-				start = read_seqbegin(lock);
+				start = read_seqcount_begin(s);
 				bcnt = iter->counters.bcnt;
 				pcnt = iter->counters.pcnt;
-			} while (read_seqretry(lock, start));
+			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
@@ -1115,6 +1118,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	int ret = 0;
 	void *loc_cpu_entry;
 	struct arpt_entry *iter;
+	unsigned int addend;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1171,12 +1175,12 @@ static int do_add_counters(struct net *net, const void __user *user,
 	/* Choose the copy that is on our node */
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
-	xt_info_wrlock(curcpu);
+	addend = xt_write_recseq_begin();
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
 		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
-	xt_info_wrunlock(curcpu);
+	xt_write_recseq_end(addend);
  unlock_up_free:
 	local_bh_enable();
 	xt_table_unlock(t);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index ffcea0d..2b6b700 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -68,15 +68,6 @@ void *ipt_alloc_initial_table(const struct xt_table *info)
 }
 EXPORT_SYMBOL_GPL(ipt_alloc_initial_table);
 
-/*
-   We keep a set of rules for each CPU, so we can avoid write-locking
-   them in the softirq when updating the counters and therefore
-   only need to read-lock in the softirq; doing a write_lock_bh() in user
-   context stops packets coming through and allows user context to read
-   the counters or update the rules.
-
-   Hence the start of any table is given by get_table() below.  */
-
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
@@ -311,6 +302,7 @@ ipt_do_table(struct sk_buff *skb,
 	unsigned int *stackptr, origptr, cpu;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
+	unsigned int addend;
 
 	/* Initialization */
 	ip = ip_hdr(skb);
@@ -331,7 +323,8 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	xt_info_rdlock_bh();
+	local_bh_disable();
+	addend = xt_write_recseq_begin();
 	private = table->private;
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
@@ -430,7 +423,9 @@ ipt_do_table(struct sk_buff *skb,
 	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
 	*stackptr = origptr;
-	xt_info_rdunlock_bh();
+ 	xt_write_recseq_end(addend);
+ 	local_bh_enable();
+
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
@@ -886,7 +881,7 @@ get_counters(const struct xt_table_info *t,
 	unsigned int i;
 
 	for_each_possible_cpu(cpu) {
-		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
@@ -894,10 +889,10 @@ get_counters(const struct xt_table_info *t,
 			unsigned int start;
 
 			do {
-				start = read_seqbegin(lock);
+				start = read_seqcount_begin(s);
 				bcnt = iter->counters.bcnt;
 				pcnt = iter->counters.pcnt;
-			} while (read_seqretry(lock, start));
+			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i; /* macro does multi eval of i */
@@ -1312,6 +1307,7 @@ do_add_counters(struct net *net, const void __user *user,
 	int ret = 0;
 	void *loc_cpu_entry;
 	struct ipt_entry *iter;
+	unsigned int addend;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1368,12 +1364,12 @@ do_add_counters(struct net *net, const void __user *user,
 	/* Choose the copy that is on our node */
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
-	xt_info_wrlock(curcpu);
+	addend = xt_write_recseq_begin();
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
 		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
-	xt_info_wrunlock(curcpu);
+	xt_write_recseq_end(addend);
  unlock_up_free:
 	local_bh_enable();
 	xt_table_unlock(t);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 0b2af9b..ec7cf57 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -340,6 +340,7 @@ ip6t_do_table(struct sk_buff *skb,
 	unsigned int *stackptr, origptr, cpu;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
+	unsigned int addend;
 
 	/* Initialization */
 	indev = in ? in->name : nulldevname;
@@ -358,7 +359,8 @@ ip6t_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	xt_info_rdlock_bh();
+	local_bh_disable();
+	addend = xt_write_recseq_begin();
 	private = table->private;
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
@@ -442,7 +444,9 @@ ip6t_do_table(struct sk_buff *skb,
 	} while (!acpar.hotdrop);
 
 	*stackptr = origptr;
-	xt_info_rdunlock_bh();
+
+ 	xt_write_recseq_end(addend);
+ 	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -899,7 +903,7 @@ get_counters(const struct xt_table_info *t,
 	unsigned int i;
 
 	for_each_possible_cpu(cpu) {
-		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
@@ -907,10 +911,10 @@ get_counters(const struct xt_table_info *t,
 			unsigned int start;
 
 			do {
-				start = read_seqbegin(lock);
+				start = read_seqcount_begin(s);
 				bcnt = iter->counters.bcnt;
 				pcnt = iter->counters.pcnt;
-			} while (read_seqretry(lock, start));
+			} while (read_seqcount_retry(s, start));
 
 			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
@@ -1325,6 +1329,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	int ret = 0;
 	const void *loc_cpu_entry;
 	struct ip6t_entry *iter;
+	unsigned int addend;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1381,13 +1386,13 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	i = 0;
 	/* Choose the copy that is on our node */
 	curcpu = smp_processor_id();
-	xt_info_wrlock(curcpu);
+	addend = xt_write_recseq_begin();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
 		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
-	xt_info_wrunlock(curcpu);
+	xt_write_recseq_end(addend);
 
  unlock_up_free:
 	local_bh_enable();
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index a9adf4c..52959ef 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -762,8 +762,8 @@ void xt_compat_unlock(u_int8_t af)
 EXPORT_SYMBOL_GPL(xt_compat_unlock);
 #endif
 
-DEFINE_PER_CPU(struct xt_info_lock, xt_info_locks);
-EXPORT_PER_CPU_SYMBOL_GPL(xt_info_locks);
+DEFINE_PER_CPU(seqcount_t, xt_recseq);
+EXPORT_PER_CPU_SYMBOL_GPL(xt_recseq);
 
 static int xt_jumpstack_alloc(struct xt_table_info *i)
 {
@@ -1362,10 +1362,7 @@ static int __init xt_init(void)
 	int rv;
 
 	for_each_possible_cpu(i) {
-		struct xt_info_lock *lock = &per_cpu(xt_info_locks, i);
-
-		seqlock_init(&lock->lock);
-		lock->readers = 0;
+		seqcount_init(&per_cpu(xt_recseq, i));
 	}
 
 	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);
-- 
1.7.4.4

