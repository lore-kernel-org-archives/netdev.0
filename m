From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] netfilter: get rid of atomic ops in fast path
Date: Wed, 16 Mar 2011 20:00:05 +0100
Message-ID: <1300302005.3202.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently use a percpu spinlock to 'protect' rule bytes/packets
counters, after various attempts to use RCU instead.

Lately we added a seqlock so that get_counters() can run without
blocking BH or 'writers'. But we really use the seqcount in it.

Spinlock itself is only locked by the current cpu, so we can remove it
completely.

This cleanups api, using correct 'writer' vs 'reader' semantic.

At replace time, the get_counters() call makes sure all cpus are done
using the old table.

We could probably avoid blocking BH (we currently block them in xmit
path), but thats a different topic ;)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
This is a POC patch (based on net-next-2.6), only handling ip_tables.
ip6/arp/... need similar changes.

 include/linux/netfilter/x_tables.h |   77 ++++++++-------------------
 net/ipv4/netfilter/ip_tables.c     |   27 +++------
 net/netfilter/x_tables.c           |    9 +--
 3 files changed, 39 insertions(+), 74 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 3721952..5b13fa5 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -457,71 +457,42 @@ extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
 extern void xt_free_table_info(struct xt_table_info *info);
 
 /*
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
+ * xt_recseq is a recursive seqcount
+ * 
+ * Packet processing changes the seqcount only if no recursion happened
+ * get_counters() can use read_seqcount_begin()/read_seqcount_retry()
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
+/** xt_write_recseq_begin - start of a write section
  *
- * We _also_ need to disable bottom half processing before updating our
- * nesting count, to make sure that the only kind of re-entrancy is this
- * code being called by itself: since the count+lock is not an atomic
- * operation, we can allow no races.
- *
- * _Only_ that special combination of being per-cpu and never getting
- * re-entered asynchronously means that the count is safe.
+ * Begin packet processing : all readers must wait the end
+ * Must be called with BH off
  */
-static inline void xt_info_rdlock_bh(void)
+static inline seqcount_t *xt_write_recseq_begin(void)
 {
-	struct xt_info_lock *lock;
+	seqcount_t *s;
 
-	local_bh_disable();
-	lock = &__get_cpu_var(xt_info_locks);
-	if (likely(!lock->readers++))
-		write_seqlock(&lock->lock);
-}
+	s = &__get_cpu_var(xt_recseq);
 
-static inline void xt_info_rdunlock_bh(void)
-{
-	struct xt_info_lock *lock = &__get_cpu_var(xt_info_locks);
+	if (s->sequence & 1)
+		return NULL;
 
-	if (likely(!--lock->readers))
-		write_sequnlock(&lock->lock);
-	local_bh_enable();
+	write_seqcount_begin(s);
+	return s;
 }
 
-/*
- * The "writer" side needs to get exclusive access to the lock,
- * regardless of readers.  This must be called with bottom half
- * processing (and thus also preemption) disabled.
+/** xt_write_recseq_end - end of a write section
+ *
+ * @seq: pointer to seqcount or NULL, return value from xt_write_recseq_begin
+ *
+ * End packet processing : all readers can proceed
+ * Must be called with BH off
  */
-static inline void xt_info_wrlock(unsigned int cpu)
-{
-	write_seqlock(&per_cpu(xt_info_locks, cpu).lock);
-}
-
-static inline void xt_info_wrunlock(unsigned int cpu)
+static inline void xt_write_recseq_end(seqcount_t *seq)
 {
-	write_sequnlock(&per_cpu(xt_info_locks, cpu).lock);
+	if (seq)
+		write_seqcount_end(seq);
 }
 
 /*
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b09ed0d..af5cf4a 100644
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
+	seqcount_t *seqp;
 
 	/* Initialization */
 	ip = ip_hdr(skb);
@@ -331,7 +323,8 @@ ipt_do_table(struct sk_buff *skb,
 	acpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	xt_info_rdlock_bh();
+	local_bh_disable();
+	seqp = xt_write_recseq_begin();
 	private = table->private;
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
@@ -427,7 +420,8 @@ ipt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	xt_info_rdunlock_bh();
+	xt_write_recseq_end(seqp);
+	local_bh_enable();
 	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
 	*stackptr = origptr;
@@ -886,7 +880,7 @@ get_counters(const struct xt_table_info *t,
 	unsigned int i;
 
 	for_each_possible_cpu(cpu) {
-		seqlock_t *lock = &per_cpu(xt_info_locks, cpu).lock;
+		seqcount_t *s = &per_cpu(xt_recseq, cpu);
 
 		i = 0;
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
@@ -894,10 +888,10 @@ get_counters(const struct xt_table_info *t,
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
@@ -1312,6 +1306,7 @@ do_add_counters(struct net *net, const void __user *user,
 	int ret = 0;
 	void *loc_cpu_entry;
 	struct ipt_entry *iter;
+	seqcount_t *seqp;
 #ifdef CONFIG_COMPAT
 	struct compat_xt_counters_info compat_tmp;
 
@@ -1368,12 +1363,12 @@ do_add_counters(struct net *net, const void __user *user,
 	/* Choose the copy that is on our node */
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
-	xt_info_wrlock(curcpu);
+	seqp = xt_write_recseq_begin();
 	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
 		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
 		++i;
 	}
-	xt_info_wrunlock(curcpu);
+	xt_write_recseq_end(seqp);
  unlock_up_free:
 	local_bh_enable();
 	xt_table_unlock(t);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index a9adf4c..18290d2 100644
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
@@ -1362,10 +1362,9 @@ static int __init xt_init(void)
 	int rv;
 
 	for_each_possible_cpu(i) {
-		struct xt_info_lock *lock = &per_cpu(xt_info_locks, i);
+		seqcount_t *s = &per_cpu(xt_recseq, i);
 
-		seqlock_init(&lock->lock);
-		lock->readers = 0;
+		seqcount_init(s);
 	}
 
 	xt = kmalloc(sizeof(struct xt_af) * NFPROTO_NUMPROTO, GFP_KERNEL);


