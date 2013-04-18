From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 3/3] net: remove fragmentation LRU list system
Date: Thu, 18 Apr 2013 23:39:01 +0200
Message-ID: <20130418213805.14296.21621.stgit@dragon>
References: <20130418213637.14296.43143.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab3DRVga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 17:36:30 -0400
In-Reply-To: <20130418213637.14296.43143.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WORK-IN-PROGRESS

I have a bug in inet_frag_cleanup_netns(), which clean/deletes fragments
when a network namespace is taken down.

TODO:
- netns mem limits and hash cleaning have conflicts
- Howto can we re-add the IPSTATS_MIB_REASMFAILS stats?
- Remove nf->low_thresh
- Doc new max_hash_depth

NOT-signed-off
---

 include/net/inet_frag.h                 |   36 ++++++------
 include/net/ipv6.h                      |    2 -
 net/ipv4/inet_fragment.c                |   96 +++++++++++++++++--------------
 net/ipv4/ip_fragment.c                  |   19 +-----
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 --
 net/ipv6/reassembly.c                   |    8 ---
 6 files changed, 75 insertions(+), 91 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index b2cd72a..276900b 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -4,9 +4,7 @@
 #include <linux/percpu_counter.h>
 
 struct netns_frags {
-	int			nqueues;
-	struct list_head	lru_list;
-	spinlock_t		lru_lock;
+	struct percpu_counter   nqueues;
 
 	/* The percpu_counter "mem" need to be cacheline aligned.
 	 *  mem.count must not share cacheline with other writers
@@ -133,28 +131,30 @@ static inline int sum_frag_mem_limit(struct netns_frags *nf)
 	return res;
 }
 
-static inline void inet_frag_lru_move(struct inet_frag_queue *q)
+static inline void dec_frag_nqueues(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
-	list_move_tail(&q->lru_list, &q->net->lru_list);
-	spin_unlock(&q->net->lru_lock);
+	percpu_counter_dec(&q->net->nqueues);
 }
 
-static inline void inet_frag_lru_del(struct inet_frag_queue *q)
+static inline void inc_frag_nqueues(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
-	list_del(&q->lru_list);
-	q->net->nqueues--;
-	spin_unlock(&q->net->lru_lock);
+	percpu_counter_inc(&q->net->nqueues);
 }
 
-static inline void inet_frag_lru_add(struct netns_frags *nf,
-				     struct inet_frag_queue *q)
+static inline void init_frag_nqueues(struct netns_frags *nf)
 {
-	spin_lock(&nf->lru_lock);
-	list_add_tail(&q->lru_list, &nf->lru_list);
-	q->net->nqueues++;
-	spin_unlock(&nf->lru_lock);
+	percpu_counter_init(&nf->nqueues, 0);
+}
+
+static inline int sum_frag_nqueues(struct netns_frags *nf)
+{
+	int res;
+
+	local_bh_disable();
+	res = percpu_counter_sum_positive(&nf->nqueues);
+	local_bh_enable();
+
+	return res;
 }
 
 /* RFC 3168 support :
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 0810aa5..c35873c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -286,7 +286,7 @@ static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ip6_frag_nqueues(struct net *net)
 {
-	return net->ipv6.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv6.frags);
 }
 
 static inline int ip6_frag_mem(struct net *net)
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index fd9fe5c..8cb46fa 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -105,10 +105,8 @@ EXPORT_SYMBOL(inet_frags_init);
 
 void inet_frags_init_net(struct netns_frags *nf)
 {
-	nf->nqueues = 0;
+	init_frag_nqueues(nf);
 	init_frag_mem_limit(nf);
-	INIT_LIST_HEAD(&nf->lru_list);
-	spin_lock_init(&nf->lru_lock);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -118,18 +116,6 @@ void inet_frags_fini(struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frags_fini);
 
-void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
-{
-	nf->low_thresh = 0;
-
-	local_bh_disable();
-	inet_frag_evictor(nf, f, true);
-	local_bh_enable();
-
-	percpu_counter_destroy(&nf->mem);
-}
-EXPORT_SYMBOL(inet_frags_exit_net);
-
 static inline void fq_unlink_hash(struct inet_frag_queue *fq,
 				  struct inet_frags *f)
 {
@@ -160,7 +146,7 @@ void __inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f,
 	if (!(fq->last_in & INET_FRAG_COMPLETE)) {
 		if (unlink_hash)
 			fq_unlink_hash(fq, f);
-		inet_frag_lru_del(fq);
+		dec_frag_nqueues(fq);
 		atomic_dec(&fq->refcnt);
 		fq->last_in |= INET_FRAG_COMPLETE;
 	}
@@ -212,46 +198,60 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
+int inet_frag_cleanup_netns(struct netns_frags *nf, struct inet_frags *f)
 {
+	struct hlist_head kill_list;
 	struct inet_frag_queue *q;
-	int work, evicted = 0;
+	struct hlist_node *n;
+	int i, evicted = 0;
 
-	if (!force) {
-		if (frag_mem_limit(nf) <= nf->high_thresh)
-			return 0;
-	}
+	/* Move inet_frag_queue's from hash table to the kill_list */
+	read_lock(&f->lock);
+	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb;
 
-	work = frag_mem_limit(nf) - nf->low_thresh;
-	while (work > 0) {
-		spin_lock(&nf->lru_lock);
+		hb = &f->hash[i];
+		spin_lock(&hb->chain_lock);
+		hlist_for_each_entry_safe(q, n, &hb->chain, list) {
 
-		if (list_empty(&nf->lru_list)) {
-			spin_unlock(&nf->lru_lock);
-			break;
+			if (q->net == nf) { /* Only for specific netns */
+				atomic_inc(&q->refcnt);
+				hlist_del(&q->list);
+				hlist_add_head(&q->list, &kill_list);
+			}
 		}
+		spin_unlock(&hb->chain_lock);
+	}
+	read_unlock(&f->lock);
 
-		q = list_first_entry(&nf->lru_list,
-				struct inet_frag_queue, lru_list);
-		atomic_inc(&q->refcnt);
-		/* Remove q from list to avoid several CPUs grabbing it */
-		list_del_init(&q->lru_list);
-
-		spin_unlock(&nf->lru_lock);
-
+	/* Kill off the inet_frag_queue's */
+	hlist_for_each_entry_safe(q, n, &kill_list, list) {
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
 			inet_frag_kill(q, f);
 		spin_unlock(&q->lock);
 
 		if (atomic_dec_and_test(&q->refcnt))
-			inet_frag_destroy(q, f, &work);
+			inet_frag_destroy(q, f, NULL);
+
 		evicted++;
 	}
 
 	return evicted;
 }
-EXPORT_SYMBOL(inet_frag_evictor);
+
+void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
+{
+	nf->low_thresh = 0;
+
+	local_bh_disable();
+	//BROKEN: inet_frag_cleanup_netns(nf, f);
+	local_bh_enable();
+
+	percpu_counter_destroy(&nf->nqueues);
+	percpu_counter_destroy(&nf->mem);
+}
+EXPORT_SYMBOL(inet_frags_exit_net);
 
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
@@ -295,7 +295,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
-	inet_frag_lru_add(nf, qp);
+	inc_frag_nqueues(qp);
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
 	return qp;
@@ -356,9 +356,19 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		q_evict = q; /* candidate for eviction */
 	}
 	/* Not found situation */
-	if (depth > f->max_hash_depth) {
-		atomic_inc(&q_evict->refcnt);
-		hlist_del_init(&q_evict->list);
+	if ((depth > f->max_hash_depth)
+	    || (frag_mem_limit(nf) > nf->high_thresh)) {
+
+		/* This is in principal wrong, notice
+		 * frag_mem_limit(nf) is per netns, and we might
+		 * delete q_evict belonging to another netns, which is
+		 * not going to lower the frag_mem_limit(nf) for this
+		 * netns. What to do?
+		 */
+		if (q_evict) {
+			atomic_inc(&q_evict->refcnt);
+			hlist_del_init(&q_evict->list);
+		}
 	} else
 		q_evict = NULL;
 	spin_unlock(&hb->chain_lock);
@@ -374,7 +384,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			inet_frag_destroy(q_evict, f, NULL);
 
 		LIMIT_NETDEBUG(KERN_WARNING "%s(): Fragment hash bucket"
-			       " list length grew over limit (len %d),"
+			       " grew over lenght or mem limit (len %d),"
 			       " Dropping another fragment.\n",
 			       __func__, depth);
 	}
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 4e8489b..193e360 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -18,6 +18,7 @@
  *		John McDonald	:	0 length frag bug.
  *		Alexey Kuznetsov:	SMP races, threading, cleanup.
  *		Patrick McHardy :	LRU queue of frag heads for evictor.
+ *		Jesper D Brouer :	Removed LRU queue for evictor.
  */
 
 #define pr_fmt(fmt) "IPv4: " fmt
@@ -88,7 +89,7 @@ static struct inet_frags ip4_frags;
 
 int ip_frag_nqueues(struct net *net)
 {
-	return net->ipv4.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv4.frags);
 }
 
 int ip_frag_mem(struct net *net)
@@ -176,18 +177,6 @@ static void ipq_kill(struct ipq *ipq)
 	inet_frag_kill(&ipq->q, &ip4_frags);
 }
 
-/* Memory limiting on fragments.  Evictor trashes the oldest
- * fragment queue until we are back under the threshold.
- */
-static void ip_evictor(struct net *net)
-{
-	int evicted;
-
-	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
-	if (evicted)
-		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
-}
-
 /*
  * Oops, a fragment queue timed out.  Kill it and send an ICMP reply.
  */
@@ -495,7 +484,6 @@ found:
 	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
 
-	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
 err:
@@ -645,9 +633,6 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
-	/* Start by cleaning up the memory. */
-	ip_evictor(net);
-
 	/* Lookup (or create) queue header */
 	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
 		int ret;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3713764..c865d3c 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -338,7 +338,6 @@ found:
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 
-	inet_frag_lru_move(&fq->q);
 	return 0;
 
 discard_fq:
@@ -583,10 +582,6 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	hdr = ipv6_hdr(clone);
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
-	local_bh_disable();
-	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
-	local_bh_enable();
-
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
 	if (fq == NULL) {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 45de5eb..ab1c843 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -25,6 +25,7 @@
  *	David Stevens and
  *	YOSHIFUJI,H. @USAGI	Always remove fragment header to
  *				calculate ICV correctly.
+ *	Jesper Dangaard Brouer	Removed LRU queue for evictor.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -343,7 +344,6 @@ found:
 	    fq->q.meat == fq->q.len)
 		return ip6_frag_reasm(fq, prev, dev);
 
-	inet_frag_lru_move(&fq->q);
 	return -1;
 
 discard_fq:
@@ -512,7 +512,6 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct frag_queue *fq;
 	const struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct net *net = dev_net(skb_dst(skb)->dev);
-	int evicted;
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
@@ -537,11 +536,6 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
-	if (evicted)
-		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_REASMFAILS, evicted);
-
 	fq = fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
 	if (fq != NULL) {
