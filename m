From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 14/17] net: convert inet_frag_queue.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:04 +0200
Message-ID: <1489678147-21404-15-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/inet_frag.h  |  4 ++--
 net/ipv4/inet_fragment.c | 14 +++++++-------
 net/ipv4/ip_fragment.c   |  2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 5894730..5a334bf 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -50,7 +50,7 @@ struct inet_frag_queue {
 	spinlock_t		lock;
 	struct timer_list	timer;
 	struct hlist_node	list;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct sk_buff		*fragments;
 	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
@@ -129,7 +129,7 @@ void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
 
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
-	if (atomic_dec_and_test(&q->refcnt))
+	if (refcount_dec_and_test(&q->refcnt))
 		inet_frag_destroy(q, f);
 }
 
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index b5e9317..96e95e8 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -276,11 +276,11 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 {
 	if (del_timer(&fq->timer))
-		atomic_dec(&fq->refcnt);
+		refcount_dec(&fq->refcnt);
 
 	if (!(fq->flags & INET_FRAG_COMPLETE)) {
 		fq_unlink(fq, f);
-		atomic_dec(&fq->refcnt);
+		refcount_dec(&fq->refcnt);
 	}
 }
 EXPORT_SYMBOL(inet_frag_kill);
@@ -329,7 +329,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 	 */
 	hlist_for_each_entry(qp, &hb->chain, list) {
 		if (qp->net == nf && f->match(qp, arg)) {
-			atomic_inc(&qp->refcnt);
+			refcount_inc(&qp->refcnt);
 			spin_unlock(&hb->chain_lock);
 			qp_in->flags |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
@@ -339,9 +339,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 #endif
 	qp = qp_in;
 	if (!mod_timer(&qp->timer, jiffies + nf->timeout))
-		atomic_inc(&qp->refcnt);
+		refcount_inc(&qp->refcnt);
 
-	atomic_inc(&qp->refcnt);
+	refcount_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
 
 	spin_unlock(&hb->chain_lock);
@@ -370,7 +370,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 
 	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
 	spin_lock_init(&q->lock);
-	atomic_set(&q->refcnt, 1);
+	refcount_set(&q->refcnt, 1);
 
 	return q;
 }
@@ -405,7 +405,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	spin_lock(&hb->chain_lock);
 	hlist_for_each_entry(q, &hb->chain, list) {
 		if (q->net == nf && f->match(q, key)) {
-			atomic_inc(&q->refcnt);
+			refcount_inc(&q->refcnt);
 			spin_unlock(&hb->chain_lock);
 			return q;
 		}
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index bbe7f72..4fed6f6 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -303,7 +303,7 @@ static int ip_frag_reinit(struct ipq *qp)
 	unsigned int sum_truesize = 0;
 
 	if (!mod_timer(&qp->q.timer, jiffies + qp->q.net->timeout)) {
-		atomic_inc(&qp->q.refcnt);
+		refcount_inc(&qp->q.refcnt);
 		return -ETIMEDOUT;
 	}
 
-- 
2.7.4
