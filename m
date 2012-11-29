From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 3/9] net: frag,
	move LRU list maintenance outside of rwlock
Date: Thu, 29 Nov 2012 17:12:24 +0100
Message-ID: <20121129161137.17754.48002.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:16215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754708Ab2K2QNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:13:44 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating the fragmentation queues LRU (Least-Recently-Used) list,
required taking the hash writer lock.  However, the LRU list isn't
tied to the hash at all, so we can use a separate lock for it.

This change, in it self, does not improve performance significantly.
But its part of making the fragmentation code scale.

Original-idea-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Don't perform inet_frag_lru_move() outside the q.lock (inet_frag_queue)
   Because there were a theoretical chance of a race between
   inet_frag_lru_move() and fq_unlink() which is called under the
   q.lock. I have not been able to provoke this though (it should
   result in a list poison error)

 include/net/inet_frag.h                 |   22 ++++++++++++++++++++++
 net/ipv4/inet_fragment.c                |   14 ++++++++------
 net/ipv4/ip_fragment.c                  |    4 +---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 ++---
 net/ipv6/reassembly.c                   |    4 +---
 5 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 1f75316..312a3fa 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -5,6 +5,7 @@ struct netns_frags {
 	int			nqueues;
 	atomic_t		mem;
 	struct list_head	lru_list;
+	spinlock_t		lru_lock;
 
 	/* sysctls */
 	int			timeout;
@@ -73,4 +74,25 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 		inet_frag_destroy(q, f, NULL);
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
index 9bb6237..4e56587 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -75,6 +75,7 @@ void inet_frags_init_net(struct netns_frags *nf)
 	nf->nqueues = 0;
 	atomic_set(&nf->mem, 0);
 	INIT_LIST_HEAD(&nf->lru_list);
+	spin_lock_init(&nf->lru_lock);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -98,9 +99,9 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 {
 	write_lock(&f->lock);
 	hlist_del(&fq->list);
-	list_del(&fq->lru_list);
 	fq->net->nqueues--;
 	write_unlock(&f->lock);
+	inet_frag_lru_del(fq);
 }
 
 void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
@@ -170,9 +171,10 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 
 	work = atomic_read(&nf->mem) - nf->low_thresh;
 	while (work > 0) {
-		read_lock(&f->lock);
+		spin_lock(&nf->lru_lock);
+
 		if (list_empty(&nf->lru_list)) {
-			read_unlock(&f->lock);
+			spin_unlock(&nf->lru_lock);
 			break;
 		}
 
@@ -186,12 +188,12 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 		 * completes.
 		 */
 		if (!force && q->creation_ts == (u32) jiffies) {
-			read_unlock(&f->lock);
+			spin_unlock(&nf->lru_lock);
 			break;
 		}
 
 		atomic_inc(&q->refcnt);
-		read_unlock(&f->lock);
+		spin_unlock(&nf->lru_lock);
 
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
@@ -245,9 +247,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &f->hash[hash]);
-	list_add_tail(&qp->lru_list, &nf->lru_list);
 	nf->nqueues++;
 	write_unlock(&f->lock);
+	inet_frag_lru_add(nf, qp);
 	return qp;
 }
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index ef00d0a..b2425bf 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -531,9 +531,7 @@ found:
 	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
 
-	write_lock(&ip4_frags.lock);
-	list_move_tail(&qp->q.lru_list, &qp->q.net->lru_list);
-	write_unlock(&ip4_frags.lock);
+	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
 err:
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 22c8ea9..b0a1c96 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -325,9 +325,8 @@ found:
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
index e5253ec..b373309 100644
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
