From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net 3/4] inet: frag: don't wait for timer deletion when evicting
Date: Thu, 23 Jul 2015 12:05:39 +0200
Message-ID: <1437645940-7895-4-git-send-email-fw@strlen.de>
References: <1437645940-7895-1-git-send-email-fw@strlen.de>
Cc: Johan Schuijt <johan@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41985 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbbGWKjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:39:48 -0400
In-Reply-To: <1437645940-7895-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank reports 'NMI watchdog: BUG: soft lockup' errors when
load is high.  Instead of (potentially) unbounded restarts of the
eviction process, just skip to the next entry.

One caveat is that, when a netns is exiting, a timer may still be running
by the time inet_evict_bucket returns.

We use the frag memory accounting to wait for outstanding timers,
so that when we free the percpu counter we can be sure no running
timer will trip over it.

Reported-and-tested-by: Frank Schreuder <fschreuder@transip.nl>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/inet_fragment.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4473232..a00ca4c 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -131,24 +131,14 @@ inet_evict_bucket(struct inet_frags *f, struct inet_frag_bucket *hb)
 	unsigned int evicted = 0;
 	HLIST_HEAD(expired);
 
-evict_again:
 	spin_lock(&hb->chain_lock);
 
 	hlist_for_each_entry_safe(fq, n, &hb->chain, list) {
 		if (!inet_fragq_should_evict(fq))
 			continue;
 
-		if (!del_timer(&fq->timer)) {
-			/* q expiring right now thus increment its refcount so
-			 * it won't be freed under us and wait until the timer
-			 * has finished executing then destroy it
-			 */
-			atomic_inc(&fq->refcnt);
-			spin_unlock(&hb->chain_lock);
-			del_timer_sync(&fq->timer);
-			inet_frag_put(fq, f);
-			goto evict_again;
-		}
+		if (!del_timer(&fq->timer))
+			continue;
 
 		fq->flags |= INET_FRAG_EVICTED;
 		hlist_add_head(&fq->list_evictor, &expired);
@@ -239,18 +229,20 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 	int i;
 
 	nf->low_thresh = 0;
-	local_bh_disable();
 
 evict_again:
+	local_bh_disable();
 	seq = read_seqbegin(&f->rnd_seqlock);
 
 	for (i = 0; i < INETFRAGS_HASHSZ ; i++)
 		inet_evict_bucket(f, &f->hash[i]);
 
-	if (read_seqretry(&f->rnd_seqlock, seq))
-		goto evict_again;
-
 	local_bh_enable();
+	cond_resched();
+
+	if (read_seqretry(&f->rnd_seqlock, seq) ||
+	    percpu_counter_sum(&nf->mem))
+		goto evict_again;
 
 	percpu_counter_destroy(&nf->mem);
 }
@@ -284,6 +276,7 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 
 	hb = get_frag_bucket_locked(fq, f);
 	hlist_del(&fq->list);
+	fq->flags |= INET_FRAG_COMPLETE;
 	spin_unlock(&hb->chain_lock);
 }
 
@@ -295,7 +288,6 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 	if (!(fq->flags & INET_FRAG_COMPLETE)) {
 		fq_unlink(fq, f);
 		atomic_dec(&fq->refcnt);
-		fq->flags |= INET_FRAG_COMPLETE;
 	}
 }
 EXPORT_SYMBOL(inet_frag_kill);
@@ -328,11 +320,12 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 		fp = xp;
 	}
 	sum = sum_truesize + f->qsize;
-	sub_frag_mem_limit(q->net, sum);
 
 	if (f->destructor)
 		f->destructor(q);
 	kmem_cache_free(f->frags_cachep, q);
+
+	sub_frag_mem_limit(nf, sum);
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-- 
2.0.5
