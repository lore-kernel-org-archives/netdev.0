From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/29] netfilter: conntrack: add gc worker to remove timed-out entries
Date: Mon,  5 Sep 2016 12:58:40 +0200
Message-ID: <1473073124-5015-26-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Conntrack gc worker to evict stale entries.

GC happens once every 5 seconds, but we only scan at most 1/64th of the
table (and not more than 8k) buckets to avoid hogging cpu.

This means that a complete scan of the table will take several minutes
of wall-clock time.

Considering that the gc run will never have to evict any entries
during normal operation because those will happen from packet path
this should be fine.

We only need gc to make sure userspace (conntrack event listeners)
eventually learn of the timeout, and for resource reclaim in case the
system becomes idle.

We do not disable BH and cond_resched for every bucket so this should
not introduce noticeable latencies either.

A followup patch will add a small change to speed up GC for the extreme
case where most entries are timed out on an otherwise idle system.

v2: Use cond_resched_rcu_qs & add comment wrt. missing restart on
nulls value change in gc worker, suggested by Eric Dumazet.

v3: don't call cancel_delayed_work_sync twice (again, Eric).

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 76 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 87ee6da..f95a9e9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -72,11 +72,24 @@ EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 struct hlist_nulls_head *nf_conntrack_hash __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_hash);
 
+struct conntrack_gc_work {
+	struct delayed_work	dwork;
+	u32			last_bucket;
+	bool			exiting;
+};
+
 static __read_mostly struct kmem_cache *nf_conntrack_cachep;
 static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
 static __read_mostly bool nf_conntrack_locks_all;
 
+#define GC_MAX_BUCKETS_DIV	64u
+#define GC_MAX_BUCKETS		8192u
+#define GC_INTERVAL		(5 * HZ)
+#define GC_MAX_EVICTS		256u
+
+static struct conntrack_gc_work conntrack_gc_work;
+
 void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
 {
 	spin_lock(lock);
@@ -928,6 +941,63 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 	return false;
 }
 
+static void gc_worker(struct work_struct *work)
+{
+	unsigned int i, goal, buckets = 0, expired_count = 0;
+	unsigned long next_run = GC_INTERVAL;
+	struct conntrack_gc_work *gc_work;
+
+	gc_work = container_of(work, struct conntrack_gc_work, dwork.work);
+
+	goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);
+	i = gc_work->last_bucket;
+
+	do {
+		struct nf_conntrack_tuple_hash *h;
+		struct hlist_nulls_head *ct_hash;
+		struct hlist_nulls_node *n;
+		unsigned int hashsz;
+		struct nf_conn *tmp;
+
+		i++;
+		rcu_read_lock();
+
+		nf_conntrack_get_ht(&ct_hash, &hashsz);
+		if (i >= hashsz)
+			i = 0;
+
+		hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[i], hnnode) {
+			tmp = nf_ct_tuplehash_to_ctrack(h);
+
+			if (nf_ct_is_expired(tmp)) {
+				nf_ct_gc_expired(tmp);
+				expired_count++;
+				continue;
+			}
+		}
+
+		/* could check get_nulls_value() here and restart if ct
+		 * was moved to another chain.  But given gc is best-effort
+		 * we will just continue with next hash slot.
+		 */
+		rcu_read_unlock();
+		cond_resched_rcu_qs();
+	} while (++buckets < goal &&
+		 expired_count < GC_MAX_EVICTS);
+
+	if (gc_work->exiting)
+		return;
+
+	gc_work->last_bucket = i;
+	schedule_delayed_work(&gc_work->dwork, next_run);
+}
+
+static void conntrack_gc_work_init(struct conntrack_gc_work *gc_work)
+{
+	INIT_DELAYED_WORK(&gc_work->dwork, gc_worker);
+	gc_work->exiting = false;
+}
+
 static struct nf_conn *
 __nf_conntrack_alloc(struct net *net,
 		     const struct nf_conntrack_zone *zone,
@@ -1534,6 +1604,7 @@ static int untrack_refs(void)
 
 void nf_conntrack_cleanup_start(void)
 {
+	conntrack_gc_work.exiting = true;
 	RCU_INIT_POINTER(ip_ct_attach, NULL);
 }
 
@@ -1543,6 +1614,7 @@ void nf_conntrack_cleanup_end(void)
 	while (untrack_refs() > 0)
 		schedule();
 
+	cancel_delayed_work_sync(&conntrack_gc_work.dwork);
 	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_htable_size);
 
 	nf_conntrack_proto_fini();
@@ -1817,6 +1889,10 @@ int nf_conntrack_init_start(void)
 	}
 	/*  - and look it like as a confirmed connection */
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
+
+	conntrack_gc_work_init(&conntrack_gc_work);
+	schedule_delayed_work(&conntrack_gc_work.dwork, GC_INTERVAL);
+
 	return 0;
 
 err_proto:
-- 
2.1.4

