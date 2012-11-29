From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 4/9] net: frag helper functions for mem limit
	tracking
Date: Thu, 29 Nov 2012 17:12:58 +0100
Message-ID: <20121129161229.17754.37401.stgit@dragon>
References: <20121129161019.17754.29670.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754777Ab2K2QOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:14:18 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is primarily a preparation to ease the extension of memory
limit tracking.

The change does reduce the number atomic operation, during freeing of
a frag queue.  This does introduce a fairly good performance improvement, as
these atomic operations are at the core of the performance problems
seen on NUMA systems.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h                 |   28 ++++++++++++++++++++++++++++
 include/net/ipv6.h                      |    2 +-
 net/ipv4/inet_fragment.c                |   27 +++++++++++++--------------
 net/ipv4/ip_fragment.c                  |   24 +++++++++++-------------
 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 +++---
 net/ipv6/reassembly.c                   |    6 +++---
 6 files changed, 59 insertions(+), 34 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 312a3fa..9bbef17 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -95,4 +95,32 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 	list_add_tail(&q->lru_list, &nf->lru_list);
 	spin_unlock(&nf->lru_lock);
 }
+
+/* Memory Tracking Functions. */
+
+static inline int frag_mem_limit(struct netns_frags *nf)
+{
+	return atomic_read(&nf->mem);
+}
+
+static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
+{
+	atomic_sub(i, &q->net->mem);
+}
+
+static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
+{
+	atomic_add(i, &q->net->mem);
+}
+
+static inline void init_frag_mem_limit(struct netns_frags *nf)
+{
+	atomic_set(&nf->mem, 0);
+}
+
+static inline int sum_frag_mem_limit(struct netns_frags *nf)
+{
+	return atomic_read(&nf->mem);
+}
+
 #endif
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 979bf6c..a5c1cf1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -279,7 +279,7 @@ static inline int ip6_frag_nqueues(struct net *net)
 
 static inline int ip6_frag_mem(struct net *net)
 {
-	return atomic_read(&net->ipv6.frags.mem);
+	return sum_frag_mem_limit(&net->ipv6.frags);
 }
 #endif
 
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4e56587..0ecacbd 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -73,7 +73,7 @@ EXPORT_SYMBOL(inet_frags_init);
 void inet_frags_init_net(struct netns_frags *nf)
 {
 	nf->nqueues = 0;
-	atomic_set(&nf->mem, 0);
+	init_frag_mem_limit(nf);
 	INIT_LIST_HEAD(&nf->lru_list);
 	spin_lock_init(&nf->lru_lock);
 }
@@ -118,12 +118,8 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 EXPORT_SYMBOL(inet_frag_kill);
 
 static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
-		struct sk_buff *skb, int *work)
+		struct sk_buff *skb)
 {
-	if (work)
-		*work -= skb->truesize;
-
-	atomic_sub(skb->truesize, &nf->mem);
 	if (f->skb_free)
 		f->skb_free(skb);
 	kfree_skb(skb);
@@ -134,6 +130,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 {
 	struct sk_buff *fp;
 	struct netns_frags *nf;
+	unsigned int sum, sum_truesize = 0;
 
 	WARN_ON(!(q->last_in & INET_FRAG_COMPLETE));
 	WARN_ON(del_timer(&q->timer) != 0);
@@ -144,13 +141,14 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 	while (fp) {
 		struct sk_buff *xp = fp->next;
 
-		frag_kfree_skb(nf, f, fp, work);
+		sum_truesize += fp->truesize;
+		frag_kfree_skb(nf, f, fp);
 		fp = xp;
 	}
-
+	sum = sum_truesize + f->qsize;
 	if (work)
-		*work -= f->qsize;
-	atomic_sub(f->qsize, &nf->mem);
+		*work -= sum;
+	sub_frag_mem_limit(q, sum);
 
 	if (f->destructor)
 		f->destructor(q);
@@ -165,11 +163,11 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 	int work, evicted = 0;
 
 	if (!force) {
-		if (atomic_read(&nf->mem) <= nf->high_thresh)
+		if (frag_mem_limit(nf) <= nf->high_thresh)
 			return 0;
 	}
 
-	work = atomic_read(&nf->mem) - nf->low_thresh;
+	work = frag_mem_limit(nf) - nf->low_thresh;
 	while (work > 0) {
 		spin_lock(&nf->lru_lock);
 
@@ -261,7 +259,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	/* Guard creations of new frag queues if mem limit reached, as
 	 * we allow warm/recent elements to survive in inet_frag_evictor()
 	 */
-	if (atomic_read(&nf->mem) > nf->high_thresh)
+	if (frag_mem_limit(nf) > nf->high_thresh)
 		return NULL;
 
 	q = kzalloc(f->qsize, GFP_ATOMIC);
@@ -271,7 +269,8 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	q->creation_ts = (u32) jiffies;
 	q->net = nf;
 	f->constructor(q, arg);
-	atomic_add(f->qsize, &nf->mem);
+	add_frag_mem_limit(q, f->qsize);
+
 	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
 	spin_lock_init(&q->lock);
 	atomic_set(&q->refcnt, 1);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b2425bf..abb5551 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -122,7 +122,7 @@ int ip_frag_nqueues(struct net *net)
 
 int ip_frag_mem(struct net *net)
 {
-	return atomic_read(&net->ipv4.frags.mem);
+	return sum_frag_mem_limit(&net->ipv4.frags);
 }
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
@@ -161,13 +161,6 @@ static bool ip4_frag_match(struct inet_frag_queue *q, void *a)
 		qp->user == arg->user;
 }
 
-/* Memory Tracking Functions. */
-static void frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb)
-{
-	atomic_sub(skb->truesize, &nf->mem);
-	kfree_skb(skb);
-}
-
 static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 {
 	struct ipq *qp = container_of(q, struct ipq, q);
@@ -340,6 +333,7 @@ static inline int ip_frag_too_far(struct ipq *qp)
 static int ip_frag_reinit(struct ipq *qp)
 {
 	struct sk_buff *fp;
+	unsigned int sum_truesize = 0;
 
 	if (!mod_timer(&qp->q.timer, jiffies + qp->q.net->timeout)) {
 		atomic_inc(&qp->q.refcnt);
@@ -349,9 +343,12 @@ static int ip_frag_reinit(struct ipq *qp)
 	fp = qp->q.fragments;
 	do {
 		struct sk_buff *xp = fp->next;
-		frag_kfree_skb(qp->q.net, fp);
+
+		sum_truesize += fp->truesize;
+		kfree_skb(fp);
 		fp = xp;
 	} while (fp);
+	sub_frag_mem_limit(&qp->q, sum_truesize);
 
 	qp->q.last_in = 0;
 	qp->q.len = 0;
@@ -496,7 +493,8 @@ found:
 				qp->q.fragments = next;
 
 			qp->q.meat -= free_it->len;
-			frag_kfree_skb(qp->q.net, free_it);
+			sub_frag_mem_limit(&qp->q, free_it->truesize);
+			kfree_skb(free_it);
 		}
 	}
 
@@ -519,7 +517,7 @@ found:
 	qp->q.stamp = skb->tstamp;
 	qp->q.meat += skb->len;
 	qp->ecn |= ecn;
-	atomic_add(skb->truesize, &qp->q.net->mem);
+	add_frag_mem_limit(&qp->q, skb->truesize);
 	if (offset == 0)
 		qp->q.last_in |= INET_FRAG_FIRST_IN;
 
@@ -615,7 +613,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		head->len -= clone->len;
 		clone->csum = 0;
 		clone->ip_summed = head->ip_summed;
-		atomic_add(clone->truesize, &qp->q.net->mem);
+		add_frag_mem_limit(&qp->q, clone->truesize);
 	}
 
 	skb_push(head, head->data - skb_network_header(head));
@@ -643,7 +641,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		}
 		fp = next;
 	}
-	atomic_sub(sum_truesize, &qp->q.net->mem);
+	sub_frag_mem_limit(&qp->q, sum_truesize);
 
 	head->next = NULL;
 	head->dev = dev;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index b0a1c96..c088831 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -316,7 +316,7 @@ found:
 	fq->q.meat += skb->len;
 	if (payload_len > fq->q.max_size)
 		fq->q.max_size = payload_len;
-	atomic_add(skb->truesize, &fq->q.net->mem);
+	add_frag_mem_limit(&fq->q, skb->truesize);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -394,7 +394,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 		clone->ip_summed = head->ip_summed;
 
 		NFCT_FRAG6_CB(clone)->orig = NULL;
-		atomic_add(clone->truesize, &fq->q.net->mem);
+		add_frag_mem_limit(&fq->q, clone->truesize);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -418,7 +418,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 	}
-	atomic_sub(head->truesize, &fq->q.net->mem);
+	sub_frag_mem_limit(&fq->q, head->truesize);
 
 	head->local_df = 1;
 	head->next = NULL;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index b373309..bab2c27 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -327,7 +327,7 @@ found:
 	}
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
-	atomic_add(skb->truesize, &fq->q.net->mem);
+	add_frag_mem_limit(&fq->q, skb->truesize);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -427,7 +427,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		head->len -= clone->len;
 		clone->csum = 0;
 		clone->ip_summed = head->ip_summed;
-		atomic_add(clone->truesize, &fq->q.net->mem);
+		add_frag_mem_limit(&fq->q, clone->truesize);
 	}
 
 	/* We have to remove fragment header from datagram and to relocate
@@ -465,7 +465,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		}
 		fp = next;
 	}
-	atomic_sub(sum_truesize, &fq->q.net->mem);
+	sub_frag_mem_limit(&fq->q, sum_truesize);
 
 	head->next = NULL;
 	head->dev = dev;
