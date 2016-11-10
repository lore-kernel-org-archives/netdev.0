From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/14] netfilter: conntrack: refine gc worker heuristics
Date: Thu, 10 Nov 2016 01:23:46 +0100
Message-ID: <1478737427-1574-14-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37762 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932267AbcKJAYM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0CD5C9B7F4
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E6F8DDA809
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DB5EDDA811
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:08 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Nicolas Dichtel says:
  After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to
  remove timed-out entries"), netlink conntrack deletion events may be
  sent with a huge delay.

Nicolas further points at this line:

  goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);

and indeed, this isn't optimal at all.  Rationale here was to ensure that
we don't block other work items for too long, even if
nf_conntrack_htable_size is huge.  But in order to have some guarantee
about maximum time period where a scan of the full conntrack table
completes we should always use a fixed slice size, so that once every
N scans the full table has been examined at least once.

We also need to balance this vs. the case where the system is either idle
(i.e., conntrack table (almost) empty) or very busy (i.e. eviction happens
from packet path).

So, after some discussion with Nicolas:

1. want hard guarantee that we scan entire table at least once every X s
-> need to scan fraction of table (get rid of upper bound)

2. don't want to eat cycles on idle or very busy system
-> increase interval if we did not evict any entries

3. don't want to block other worker items for too long
-> make fraction really small, and prefer small scan interval instead

4. Want reasonable short time where we detect timed-out entry when
system went idle after a burst of traffic, while not doing scans
all the time.
-> Store next gc scan in worker, increasing delays when no eviction
happened and shrinking delay when we see timed out entries.

The old gc interval is turned into a max number, scans can now happen
every jiffy if stale entries are present.

Longest possible time period until an entry is evicted is now 2 minutes
in worst case (entry expires right after it was deemed 'not expired').

Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 49 ++++++++++++++++++++++++++++++++-------
 1 file changed, 41 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index df2f5a3901df..0f87e5d21be7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -76,6 +76,7 @@ struct conntrack_gc_work {
 	struct delayed_work	dwork;
 	u32			last_bucket;
 	bool			exiting;
+	long			next_gc_run;
 };
 
 static __read_mostly struct kmem_cache *nf_conntrack_cachep;
@@ -83,9 +84,11 @@ static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
 static __read_mostly bool nf_conntrack_locks_all;
 
+/* every gc cycle scans at most 1/GC_MAX_BUCKETS_DIV part of table */
 #define GC_MAX_BUCKETS_DIV	64u
-#define GC_MAX_BUCKETS		8192u
-#define GC_INTERVAL		(5 * HZ)
+/* upper bound of scan intervals */
+#define GC_INTERVAL_MAX		(2 * HZ)
+/* maximum conntracks to evict per gc run */
 #define GC_MAX_EVICTS		256u
 
 static struct conntrack_gc_work conntrack_gc_work;
@@ -936,13 +939,13 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 static void gc_worker(struct work_struct *work)
 {
 	unsigned int i, goal, buckets = 0, expired_count = 0;
-	unsigned long next_run = GC_INTERVAL;
-	unsigned int ratio, scanned = 0;
 	struct conntrack_gc_work *gc_work;
+	unsigned int ratio, scanned = 0;
+	unsigned long next_run;
 
 	gc_work = container_of(work, struct conntrack_gc_work, dwork.work);
 
-	goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);
+	goal = nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV;
 	i = gc_work->last_bucket;
 
 	do {
@@ -982,17 +985,47 @@ static void gc_worker(struct work_struct *work)
 	if (gc_work->exiting)
 		return;
 
+	/*
+	 * Eviction will normally happen from the packet path, and not
+	 * from this gc worker.
+	 *
+	 * This worker is only here to reap expired entries when system went
+	 * idle after a busy period.
+	 *
+	 * The heuristics below are supposed to balance conflicting goals:
+	 *
+	 * 1. Minimize time until we notice a stale entry
+	 * 2. Maximize scan intervals to not waste cycles
+	 *
+	 * Normally, expired_count will be 0, this increases the next_run time
+	 * to priorize 2) above.
+	 *
+	 * As soon as a timed-out entry is found, move towards 1) and increase
+	 * the scan frequency.
+	 * In case we have lots of evictions next scan is done immediately.
+	 */
 	ratio = scanned ? expired_count * 100 / scanned : 0;
-	if (ratio >= 90 || expired_count == GC_MAX_EVICTS)
+	if (ratio >= 90 || expired_count == GC_MAX_EVICTS) {
+		gc_work->next_gc_run = 0;
 		next_run = 0;
+	} else if (expired_count) {
+		gc_work->next_gc_run /= 2U;
+		next_run = msecs_to_jiffies(1);
+	} else {
+		if (gc_work->next_gc_run < GC_INTERVAL_MAX)
+			gc_work->next_gc_run += msecs_to_jiffies(1);
+
+		next_run = gc_work->next_gc_run;
+	}
 
 	gc_work->last_bucket = i;
-	schedule_delayed_work(&gc_work->dwork, next_run);
+	queue_delayed_work(system_long_wq, &gc_work->dwork, next_run);
 }
 
 static void conntrack_gc_work_init(struct conntrack_gc_work *gc_work)
 {
 	INIT_DELAYED_WORK(&gc_work->dwork, gc_worker);
+	gc_work->next_gc_run = GC_INTERVAL_MAX;
 	gc_work->exiting = false;
 }
 
@@ -1885,7 +1918,7 @@ int nf_conntrack_init_start(void)
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 
 	conntrack_gc_work_init(&conntrack_gc_work);
-	schedule_delayed_work(&conntrack_gc_work.dwork, GC_INTERVAL);
+	queue_delayed_work(system_long_wq, &conntrack_gc_work.dwork, GC_INTERVAL_MAX);
 
 	return 0;
 
-- 
2.1.4
