From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 6/6] net: frag,
	move LRU list maintenance outside of rwlock
Date: Tue, 29 Jan 2013 10:45:51 +0100
Message-ID: <20130129094538.13513.44532.stgit@dragon>
References: <20130129094331.13513.28377.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab3A2JmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:42:21 -0500
In-Reply-To: <20130129094331.13513.28377.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating the fragmentation queues LRU (Least-Recently-Used) list,
required taking the hash writer lock.  However, the LRU list isn't
tied to the hash at all, so we can use a separate lock for it.

Original-idea-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h                 |   22 ++++++++++++++++++++++
 net/ipv4/inet_fragment.c                |   12 +++++++-----
 net/ipv4/ip_fragment.c                  |    4 +---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 ++---
 net/ipv6/reassembly.c                   |    4 +---
 5 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index e0eec74..3f237db 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -6,6 +6,7 @@
 struct netns_frags {
 	int			nqueues;
 	struct list_head	lru_list;
+	spinlock_t		lru_lock;
 
 	/* The percpu_counter "mem" need to be cacheline aligned.
 	 *  mem.count must not share cacheline with other writers
@@ -116,4 +117,25 @@ static inline int sum_frag_mem_limit(struct netns_frags *nf)
 	return percpu_counter_sum_positive(&nf->mem);
 }
 
+static inline void inet_frag_lru_move(struct inet_frag_queue *q)
+{
+	spin_lock(&q->net->lru_lock);
+	list_move_tail(&q->lru_list, &q->net->lru_list);
+	spin_unlock(&q->net->lru_lock);
+}
+
+static inline void inet_frag_lru_del(struct inet_frag_queue *q)
+{
+	spin_lock(&q->net->lru_lock);
+	list_del(&q->lru_list);
+	spin_unlock(&q->net->lru_lock);
+}
+
+static inline void inet_frag_lru_add(struct netns_frags *nf,
+				     struct inet_frag_queue *q)
+{
+	spin_lock(&nf->lru_lock);
+	list_add_tail(&q->lru_list, &nf->lru_list);
+	spin_unlock(&nf->lru_lock);
+}
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index b825205..2e453bd 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -75,6 +75,7 @@ void inet_frags_init_net(struct netns_frags *nf)
 	nf->nqueues = 0;
 	init_frag_mem_limit(nf);
 	INIT_LIST_HEAD(&nf->lru_list);
+	spin_lock_init(&nf->lru_lock);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -100,9 +101,9 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 {
 	write_lock(&f->lock);
 	hlist_del(&fq->list);
-	list_del(&fq->lru_list);
 	fq->net->nqueues--;
 	write_unlock(&f->lock);
+	inet_frag_lru_del(fq);
 }
 
 void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
@@ -170,16 +171,17 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 
 	work = frag_mem_limit(nf) - nf->low_thresh;
 	while (work > 0) {
-		read_lock(&f->lock);
+		spin_lock(&nf->lru_lock);
+
 		if (list_empty(&nf->lru_list)) {
-			read_unlock(&f->lock);
+			spin_unlock(&nf->lru_lock);
 			break;
 		}
 
 		q = list_first_entry(&nf->lru_list,
 				struct inet_frag_queue, lru_list);
 		atomic_inc(&q->refcnt);
-		read_unlock(&f->lock);
+		spin_unlock(&nf->lru_lock);
 
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
@@ -233,9 +235,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &f->hash[hash]);
-	list_add_tail(&qp->lru_list, &nf->lru_list);
 	nf->nqueues++;
 	write_unlock(&f->lock);
+	inet_frag_lru_add(nf, qp);
 	return qp;
 }
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 927fe58..1211613 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -529,9 +529,7 @@ found:
 	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
 
-	write_lock(&ip4_frags.lock);
-	list_move_tail(&qp->q.lru_list, &qp->q.net->lru_list);
-	write_unlock(&ip4_frags.lock);
+	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
 err:
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 07ef294..c674f15 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -328,9 +328,8 @@ found:
 		fq->nhoffset = nhoff;
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
-	write_lock(&nf_frags.lock);
-	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
-	write_unlock(&nf_frags.lock);
+
+	inet_frag_lru_move(&fq->q);
 	return 0;
 
 discard_fq:
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 18cb8de..bab2c27 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -341,9 +341,7 @@ found:
 	    fq->q.meat == fq->q.len)
 		return ip6_frag_reasm(fq, prev, dev);
 
-	write_lock(&ip6_frags.lock);
-	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
-	write_unlock(&ip6_frags.lock);
+	inet_frag_lru_move(&fq->q);
 	return -1;
 
 discard_fq:
