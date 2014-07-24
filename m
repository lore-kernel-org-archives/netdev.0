From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 4/9] inet: frag: move eviction of queues to work queue
Date: Thu, 24 Jul 2014 16:50:32 +0200
Message-ID: <1406213437-6155-5-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49663 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933491AbaGXOwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:07 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

When the high_thresh limit is reached we try to toss the 'oldest'
incomplete fragment queues until memory limits are below the low_thresh
value.  This happens in softirq/packet processing context.

This has two drawbacks:

1) processors might evict a queue that was about to be completed
by another cpu, because they will compete wrt. resource usage and
resource reclaim.

2) LRU list maintenance is expensive.

But when constantly overloaded, even the 'least recently used' element is
recent, so removing 'lru' queue first is not 'fairer' than removing any
other fragment queue.

This moves eviction out of the fast path:

When the low threshold is reached, a work queue is scheduled
which then iterates over the table and removes the queues that exceed
the memory limits of the namespace. It sets a new flag called
INET_FRAG_EVICTED on the evicted queues so the proper counters will get
incremented when the queue is forcefully expired.

When the high threshold is reached, no more fragment queues are
created until we're below the limit again.

The LRU list is now unused and will be removed in a followup patch.

Joint work with Nikolay Aleksandrov.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 Documentation/networking/ip-sysctl.txt |   4 +-
 include/net/inet_frag.h                |   6 +-
 net/ipv4/inet_fragment.c               | 142 +++++++++++++++++++++++----------
 net/ipv4/ip_fragment.c                 |   3 +-
 net/ipv6/reassembly.c                  |   4 +-
 5 files changed, 112 insertions(+), 47 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f35bfe43bf7a..625c8dda4be7 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -104,7 +104,9 @@ ipfrag_high_thresh - INTEGER
 	is reached.
 
 ipfrag_low_thresh - INTEGER
-	See ipfrag_high_thresh
+	Maximum memory used to reassemble IP fragments before the kernel
+	begins to remove incomplete fragment queues to free up resources.
+	The kernel still accepts new fragments for defragmentation.
 
 ipfrag_time - INTEGER
 	Time in seconds to keep an IP fragment in memory.
diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 9fe644d1a26e..e975032ea11b 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -32,6 +32,7 @@ struct inet_frag_queue {
 	int			meat;
 	__u8			last_in;    /* first/last segment arrived? */
 
+#define INET_FRAG_EVICTED	8
 #define INET_FRAG_COMPLETE	4
 #define INET_FRAG_FIRST_IN	2
 #define INET_FRAG_LAST_IN	1
@@ -48,7 +49,7 @@ struct inet_frag_queue {
  *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
  *	       struct frag_queue))
  */
-#define INETFRAGS_MAXDEPTH		128
+#define INETFRAGS_MAXDEPTH	128
 
 struct inet_frag_bucket {
 	struct hlist_head	chain;
@@ -65,6 +66,9 @@ struct inet_frags {
 	int			secret_interval;
 	struct timer_list	secret_timer;
 
+	struct work_struct	frags_work;
+	unsigned int next_bucket;
+
 	/* The first call to hashfn is responsible to initialize
 	 * rnd. This is best done with net_get_random_once.
 	 */
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 535636017534..43315ecb9400 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -25,6 +25,9 @@
 #include <net/inet_frag.h>
 #include <net/inet_ecn.h>
 
+#define INETFRAGS_EVICT_BUCKETS   128
+#define INETFRAGS_EVICT_MAX	  512
+
 /* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
  * Value : 0xff if frame should be dropped.
  *         0 or INET_ECN_CE value, to be ORed in to final iph->tos field
@@ -46,8 +49,6 @@ const u8 ip_frag_ecn_table[16] = {
 };
 EXPORT_SYMBOL(ip_frag_ecn_table);
 
-static int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
-
 static unsigned int
 inet_frag_hashfn(const struct inet_frags *f, const struct inet_frag_queue *q)
 {
@@ -89,10 +90,92 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 	mod_timer(&f->secret_timer, now + f->secret_interval);
 }
 
+static bool inet_fragq_should_evict(const struct inet_frag_queue *q)
+{
+	return q->net->low_thresh == 0 ||
+	       frag_mem_limit(q->net) >= q->net->low_thresh;
+}
+
+static unsigned int
+inet_evict_bucket(struct inet_frags *f, struct inet_frag_bucket *hb)
+{
+	struct inet_frag_queue *fq;
+	struct hlist_node *n;
+	unsigned int evicted = 0;
+	HLIST_HEAD(expired);
+
+evict_again:
+	spin_lock(&hb->chain_lock);
+
+	hlist_for_each_entry_safe(fq, n, &hb->chain, list) {
+		if (!inet_fragq_should_evict(fq))
+			continue;
+
+		if (!del_timer(&fq->timer)) {
+			/* q expiring right now thus increment its refcount so
+			 * it won't be freed under us and wait until the timer
+			 * has finished executing then destroy it
+			 */
+			atomic_inc(&fq->refcnt);
+			spin_unlock(&hb->chain_lock);
+			del_timer_sync(&fq->timer);
+			WARN_ON(atomic_read(&fq->refcnt) != 1);
+			inet_frag_put(fq, f);
+			goto evict_again;
+		}
+
+		/* suppress xmit of (icmp) error packet */
+		fq->last_in &= ~INET_FRAG_FIRST_IN;
+		fq->last_in |= INET_FRAG_EVICTED;
+		hlist_del(&fq->list);
+		hlist_add_head(&fq->list, &expired);
+		++evicted;
+	}
+
+	spin_unlock(&hb->chain_lock);
+
+	hlist_for_each_entry_safe(fq, n, &expired, list)
+		f->frag_expire((unsigned long) fq);
+
+	return evicted;
+}
+
+static void inet_frag_worker(struct work_struct *work)
+{
+	unsigned int budget = INETFRAGS_EVICT_BUCKETS;
+	unsigned int i, evicted = 0;
+	struct inet_frags *f;
+
+	f = container_of(work, struct inet_frags, frags_work);
+
+	BUILD_BUG_ON(INETFRAGS_EVICT_BUCKETS >= INETFRAGS_HASHSZ);
+
+	read_lock_bh(&f->lock);
+
+	for (i = ACCESS_ONCE(f->next_bucket); budget; --budget) {
+		evicted += inet_evict_bucket(f, &f->hash[i]);
+		i = (i + 1) & (INETFRAGS_HASHSZ - 1);
+		if (evicted > INETFRAGS_EVICT_MAX)
+			break;
+	}
+
+	f->next_bucket = i;
+
+	read_unlock_bh(&f->lock);
+}
+
+static void inet_frag_schedule_worker(struct inet_frags *f)
+{
+	if (unlikely(!work_pending(&f->frags_work)))
+		schedule_work(&f->frags_work);
+}
+
 void inet_frags_init(struct inet_frags *f)
 {
 	int i;
 
+	INIT_WORK(&f->frags_work, inet_frag_worker);
+
 	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
 		struct inet_frag_bucket *hb = &f->hash[i];
 
@@ -120,16 +203,22 @@ EXPORT_SYMBOL(inet_frags_init_net);
 void inet_frags_fini(struct inet_frags *f)
 {
 	del_timer(&f->secret_timer);
+	cancel_work_sync(&f->frags_work);
 }
 EXPORT_SYMBOL(inet_frags_fini);
 
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 {
+	int i;
+
 	nf->low_thresh = 0;
 
-	local_bh_disable();
-	inet_frag_evictor(nf, f, true);
-	local_bh_enable();
+	read_lock_bh(&f->lock);
+
+	for (i = 0; i < INETFRAGS_HASHSZ ; i++)
+		inet_evict_bucket(f, &f->hash[i]);
+
+	read_unlock_bh(&f->lock);
 
 	percpu_counter_destroy(&nf->mem);
 }
@@ -205,41 +294,6 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-static int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
-{
-	struct inet_frag_queue *q;
-	int work, evicted = 0;
-
-	work = frag_mem_limit(nf) - nf->low_thresh;
-	while (work > 0 || force) {
-		spin_lock(&nf->lru_lock);
-
-		if (list_empty(&nf->lru_list)) {
-			spin_unlock(&nf->lru_lock);
-			break;
-		}
-
-		q = list_first_entry(&nf->lru_list,
-				struct inet_frag_queue, lru_list);
-		atomic_inc(&q->refcnt);
-		/* Remove q from list to avoid several CPUs grabbing it */
-		list_del_init(&q->lru_list);
-
-		spin_unlock(&nf->lru_lock);
-
-		spin_lock(&q->lock);
-		if (!(q->last_in & INET_FRAG_COMPLETE))
-			inet_frag_kill(q, f);
-		spin_unlock(&q->lock);
-
-		if (atomic_dec_and_test(&q->refcnt))
-			inet_frag_destroy(q, f, &work);
-		evicted++;
-	}
-
-	return evicted;
-}
-
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
 		void *arg)
@@ -292,8 +346,10 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 {
 	struct inet_frag_queue *q;
 
-	if (frag_mem_limit(nf) > nf->high_thresh)
+	if (frag_mem_limit(nf) > nf->high_thresh) {
+		inet_frag_schedule_worker(f);
 		return NULL;
+	}
 
 	q = kzalloc(f->qsize, GFP_ATOMIC);
 	if (q == NULL)
@@ -331,8 +387,8 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	struct inet_frag_queue *q;
 	int depth = 0;
 
-	if (frag_mem_limit(nf) > nf->high_thresh)
-		inet_frag_evictor(nf, f, false);
+	if (frag_mem_limit(nf) > nf->low_thresh)
+		inet_frag_schedule_worker(f);
 
 	hash &= (INETFRAGS_HASHSZ - 1);
 	hb = &f->hash[hash];
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 54988672d00d..54bd170c5eb4 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -195,7 +195,8 @@ static void ip_expire(unsigned long arg)
 
 	ipq_kill(qp);
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
+	if (!(qp->q.last_in & INET_FRAG_EVICTED))
+		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 97acbc490d9e..b3924b10dff3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -141,7 +141,9 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 	if (!dev)
 		goto out_rcu_unlock;
 
-	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+	if (!(fq->q.last_in & INET_FRAG_EVICTED))
+		IP6_INC_STATS_BH(net, __in6_dev_get(dev),
+				 IPSTATS_MIB_REASMTIMEOUT);
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 
 	/* Don't send error if the first segment did not arrive. */
-- 
1.9.3
