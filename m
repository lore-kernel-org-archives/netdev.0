From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 6/9] inet: frag: remove lru list
Date: Thu, 24 Jul 2014 16:50:34 +0200
Message-ID: <1406213437-6155-7-git-send-email-nikolay@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:47114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbaGXOwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:05 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

no longer used.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h                 | 32 ++------------------------------
 net/ieee802154/reassembly.c             |  1 -
 net/ipv4/inet_fragment.c                | 12 ++----------
 net/ipv4/ip_fragment.c                  |  1 -
 net/ipv6/netfilter/nf_conntrack_reasm.c |  1 -
 net/ipv6/reassembly.c                   |  1 -
 6 files changed, 4 insertions(+), 44 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 68de33765705..90d21ea62c59 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -4,9 +4,6 @@
 #include <linux/percpu_counter.h>
 
 struct netns_frags {
-	struct list_head	lru_list;
-	spinlock_t		lru_lock;
-
 	/* The percpu_counter "mem" need to be cacheline aligned.
 	 *  mem.count must not share cacheline with other writers
 	 */
@@ -21,7 +18,6 @@ struct netns_frags {
 struct inet_frag_queue {
 	spinlock_t		lock;
 	struct timer_list	timer;      /* when will this queue expire? */
-	struct list_head	lru_list;   /* lru list member */
 	struct hlist_node	list;
 	atomic_t		refcnt;
 	struct sk_buff		*fragments; /* list of received fragments */
@@ -91,8 +87,7 @@ void inet_frags_init_net(struct netns_frags *nf);
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
-void inet_frag_destroy(struct inet_frag_queue *q,
-				struct inet_frags *f, int *work);
+void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
@@ -102,7 +97,7 @@ void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
 	if (atomic_dec_and_test(&q->refcnt))
-		inet_frag_destroy(q, f, NULL);
+		inet_frag_destroy(q, f);
 }
 
 /* Memory Tracking Functions. */
@@ -145,29 +140,6 @@ static inline unsigned int sum_frag_mem_limit(struct netns_frags *nf)
 	return res;
 }
 
-static inline void inet_frag_lru_move(struct inet_frag_queue *q)
-{
-	spin_lock(&q->net->lru_lock);
-	if (!list_empty(&q->lru_list))
-		list_move_tail(&q->lru_list, &q->net->lru_list);
-	spin_unlock(&q->net->lru_lock);
-}
-
-static inline void inet_frag_lru_del(struct inet_frag_queue *q)
-{
-	spin_lock(&q->net->lru_lock);
-	list_del_init(&q->lru_list);
-	spin_unlock(&q->net->lru_lock);
-}
-
-static inline void inet_frag_lru_add(struct netns_frags *nf,
-				     struct inet_frag_queue *q)
-{
-	spin_lock(&nf->lru_lock);
-	list_add_tail(&q->lru_list, &nf->lru_list);
-	spin_unlock(&nf->lru_lock);
-}
-
 /* RFC 3168 support :
  * We want to check ECN values of all fragments, do detect invalid combinations.
  * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 9503a48556f7..b4bc7a50eccf 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -219,7 +219,6 @@ found:
 		return res;
 	}
 
-	inet_frag_lru_move(&fq->q);
 	return -1;
 err:
 	kfree_skb(skb);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 231ca0b40811..198a5ed7a815 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -194,8 +194,6 @@ EXPORT_SYMBOL(inet_frags_init);
 void inet_frags_init_net(struct netns_frags *nf)
 {
 	init_frag_mem_limit(nf);
-	INIT_LIST_HEAD(&nf->lru_list);
-	spin_lock_init(&nf->lru_lock);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -237,7 +235,6 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	spin_unlock(&hb->chain_lock);
 
 	read_unlock(&f->lock);
-	inet_frag_lru_del(fq);
 }
 
 void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
@@ -261,8 +258,7 @@ static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
 	kfree_skb(skb);
 }
 
-void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
-					int *work)
+void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 {
 	struct sk_buff *fp;
 	struct netns_frags *nf;
@@ -282,14 +278,11 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 		fp = xp;
 	}
 	sum = sum_truesize + f->qsize;
-	if (work)
-		*work -= sum;
 	sub_frag_mem_limit(q, sum);
 
 	if (f->destructor)
 		f->destructor(q);
 	kfree(q);
-
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
@@ -333,7 +326,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
-	inet_frag_lru_add(nf, qp);
+
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
 
@@ -361,7 +354,6 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
 	spin_lock_init(&q->lock);
 	atomic_set(&q->refcnt, 1);
-	INIT_LIST_HEAD(&q->lru_list);
 
 	return q;
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1f42c2e3966b..8fbeee495037 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -489,7 +489,6 @@ found:
 	}
 
 	skb_dst_drop(skb);
-	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
 err:
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 58e32cf91c95..fb0f72a0ff31 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -349,7 +349,6 @@ found:
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 
-	inet_frag_lru_move(&fq->q);
 	return 0;
 
 discard_fq:
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index b3924b10dff3..af85551682c2 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -351,7 +351,6 @@ found:
 	}
 
 	skb_dst_drop(skb);
-	inet_frag_lru_move(&fq->q);
 	return -1;
 
 discard_fq:
-- 
1.9.3
