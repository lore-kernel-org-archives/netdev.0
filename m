From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 8/9] inet: frag: use seqlock for hash rebuild
Date: Thu, 24 Jul 2014 16:50:36 +0200
Message-ID: <1406213437-6155-9-git-send-email-nikolay@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:35731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932464AbaGXOwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:13 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

rehash is rare operation, don't force readers to take
the read-side rwlock.

Instead, we only have to detect the (rare) case where
the secret was altered while we are trying to insert
a new inetfrag queue into the table.

If it was changed, drop the bucket lock and recompute
the hash to get the 'new' chain bucket that we have to
insert into.

Joint work with Nikolay Aleksandrov.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 include/net/inet_frag.h                 | 13 +++--
 net/ieee802154/reassembly.c             |  1 -
 net/ipv4/inet_fragment.c                | 88 ++++++++++++++++++++-------------
 net/ipv4/ip_fragment.c                  |  1 -
 net/ipv6/netfilter/nf_conntrack_reasm.c |  2 +-
 net/ipv6/reassembly.c                   |  1 -
 6 files changed, 62 insertions(+), 44 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index d9cc5bb64854..6f4930a0b660 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -53,11 +53,6 @@ struct inet_frag_bucket {
 
 struct inet_frags {
 	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
-	/* This rwlock is a global lock (seperate per IPv4, IPv6 and
-	 * netfilter). Important to keep this on a seperate cacheline.
-	 * Its primarily a rebuild protection rwlock.
-	 */
-	rwlock_t		lock ____cacheline_aligned_in_smp;
 
 	struct work_struct	frags_work;
 	unsigned int next_bucket;
@@ -66,8 +61,12 @@ struct inet_frags {
 
 	/* The first call to hashfn is responsible to initialize
 	 * rnd. This is best done with net_get_random_once.
+	 *
+	 * rnd_seqlock is used to let hash insertion detect
+	 * when it needs to re-lookup the hash chain to use.
 	 */
 	u32			rnd;
+	seqlock_t		rnd_seqlock;
 	int			qsize;
 
 	unsigned int		(*hashfn)(const struct inet_frag_queue *);
@@ -89,8 +88,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
-		struct inet_frags *f, void *key, unsigned int hash)
-	__releases(&f->lock);
+		struct inet_frags *f, void *key, unsigned int hash);
+
 void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
 				   const char *prefix);
 
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 20d219682d84..8da635d92a58 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -124,7 +124,6 @@ fq_find(struct net *net, const struct lowpan_frag_info *frag_info,
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock(&lowpan_frags.lock);
 	hash = lowpan_hash_frag(frag_info->d_tag, frag_info->d_size, src, dst);
 
 	q = inet_frag_find(&ieee802154_lowpan->frags,
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 58d4c38534f6..62b1f73749dc 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -68,8 +68,7 @@ static void inet_frag_secret_rebuild(struct inet_frags *f)
 {
 	int i;
 
-	/* Per bucket lock NOT needed here, due to write lock protection */
-	write_lock_bh(&f->lock);
+	write_seqlock_bh(&f->rnd_seqlock);
 
 	if (!inet_frag_may_rebuild(f))
 		goto out;
@@ -82,6 +81,8 @@ static void inet_frag_secret_rebuild(struct inet_frags *f)
 		struct hlist_node *n;
 
 		hb = &f->hash[i];
+		spin_lock(&hb->chain_lock);
+
 		hlist_for_each_entry_safe(q, n, &hb->chain, list) {
 			unsigned int hval = inet_frag_hashfn(f, q);
 
@@ -92,15 +93,28 @@ static void inet_frag_secret_rebuild(struct inet_frags *f)
 
 				/* Relink to new hash chain. */
 				hb_dest = &f->hash[hval];
+
+				/* This is the only place where we take
+				 * another chain_lock while already holding
+				 * one.  As this will not run concurrently,
+				 * we cannot deadlock on hb_dest lock below, if its
+				 * already locked it will be released soon since
+				 * other caller cannot be waiting for hb lock
+				 * that we've taken above.
+				 */
+				spin_lock_nested(&hb_dest->chain_lock,
+						 SINGLE_DEPTH_NESTING);
 				hlist_add_head(&q->list, &hb_dest->chain);
+				spin_unlock(&hb_dest->chain_lock);
 			}
 		}
+		spin_unlock(&hb->chain_lock);
 	}
 
 	f->rebuild = false;
 	f->last_rebuild_jiffies = jiffies;
 out:
-	write_unlock_bh(&f->lock);
+	write_sequnlock_bh(&f->rnd_seqlock);
 }
 
 static bool inet_fragq_should_evict(const struct inet_frag_queue *q)
@@ -163,7 +177,7 @@ static void inet_frag_worker(struct work_struct *work)
 
 	BUILD_BUG_ON(INETFRAGS_EVICT_BUCKETS >= INETFRAGS_HASHSZ);
 
-	read_lock_bh(&f->lock);
+	local_bh_disable();
 
 	for (i = ACCESS_ONCE(f->next_bucket); budget; --budget) {
 		evicted += inet_evict_bucket(f, &f->hash[i]);
@@ -174,7 +188,8 @@ static void inet_frag_worker(struct work_struct *work)
 
 	f->next_bucket = i;
 
-	read_unlock_bh(&f->lock);
+	local_bh_enable();
+
 	if (f->rebuild && inet_frag_may_rebuild(f))
 		inet_frag_secret_rebuild(f);
 }
@@ -197,7 +212,8 @@ void inet_frags_init(struct inet_frags *f)
 		spin_lock_init(&hb->chain_lock);
 		INIT_HLIST_HEAD(&hb->chain);
 	}
-	rwlock_init(&f->lock);
+
+	seqlock_init(&f->rnd_seqlock);
 	f->last_rebuild_jiffies = 0;
 }
 EXPORT_SYMBOL(inet_frags_init);
@@ -216,35 +232,56 @@ EXPORT_SYMBOL(inet_frags_fini);
 
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 {
+	unsigned int seq;
 	int i;
 
 	nf->low_thresh = 0;
+	local_bh_disable();
 
-	read_lock_bh(&f->lock);
+evict_again:
+	seq = read_seqbegin(&f->rnd_seqlock);
 
 	for (i = 0; i < INETFRAGS_HASHSZ ; i++)
 		inet_evict_bucket(f, &f->hash[i]);
 
-	read_unlock_bh(&f->lock);
+	if (read_seqretry(&f->rnd_seqlock, seq))
+		goto evict_again;
+
+	local_bh_enable();
 
 	percpu_counter_destroy(&nf->mem);
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
-static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
+static struct inet_frag_bucket *
+get_frag_bucket_locked(struct inet_frag_queue *fq, struct inet_frags *f)
+__acquires(hb->chain_lock)
 {
 	struct inet_frag_bucket *hb;
-	unsigned int hash;
+	unsigned int seq, hash;
+
+ restart:
+	seq = read_seqbegin(&f->rnd_seqlock);
 
-	read_lock(&f->lock);
 	hash = inet_frag_hashfn(f, fq);
 	hb = &f->hash[hash];
 
 	spin_lock(&hb->chain_lock);
+	if (read_seqretry(&f->rnd_seqlock, seq)) {
+		spin_unlock(&hb->chain_lock);
+		goto restart;
+	}
+
+	return hb;
+}
+
+static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
+{
+	struct inet_frag_bucket *hb;
+
+	hb = get_frag_bucket_locked(fq, f);
 	hlist_del(&fq->list);
 	spin_unlock(&hb->chain_lock);
-
-	read_unlock(&f->lock);
 }
 
 void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
@@ -300,30 +337,18 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
 		void *arg)
 {
-	struct inet_frag_bucket *hb;
+	struct inet_frag_bucket *hb = get_frag_bucket_locked(qp_in, f);
 	struct inet_frag_queue *qp;
-	unsigned int hash;
-
-	read_lock(&f->lock); /* Protects against hash rebuild */
-	/*
-	 * While we stayed w/o the lock other CPU could update
-	 * the rnd seed, so we need to re-calculate the hash
-	 * chain. Fortunatelly the qp_in can be used to get one.
-	 */
-	hash = inet_frag_hashfn(f, qp_in);
-	hb = &f->hash[hash];
-	spin_lock(&hb->chain_lock);
 
 #ifdef CONFIG_SMP
 	/* With SMP race we have to recheck hash table, because
-	 * such entry could be created on other cpu, while we
-	 * released the hash bucket lock.
+	 * such entry could have been created on other cpu before
+	 * we acquired hash bucket lock.
 	 */
 	hlist_for_each_entry(qp, &hb->chain, list) {
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
 			spin_unlock(&hb->chain_lock);
-			read_unlock(&f->lock);
 			qp_in->last_in |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
@@ -338,7 +363,6 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 	hlist_add_head(&qp->list, &hb->chain);
 
 	spin_unlock(&hb->chain_lock);
-	read_unlock(&f->lock);
 
 	return qp;
 }
@@ -382,7 +406,6 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
-	__releases(&f->lock)
 {
 	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
@@ -399,19 +422,18 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
 			spin_unlock(&hb->chain_lock);
-			read_unlock(&f->lock);
 			return q;
 		}
 		depth++;
 	}
 	spin_unlock(&hb->chain_lock);
-	read_unlock(&f->lock);
 
 	if (depth <= INETFRAGS_MAXDEPTH)
 		return inet_frag_create(nf, f, key);
 
 	if (inet_frag_may_rebuild(f)) {
-		f->rebuild = true;
+		if (!f->rebuild)
+			f->rebuild = true;
 		inet_frag_schedule_worker(f);
 	}
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 44e591a7e03f..ccee68dffd6e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -244,7 +244,6 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	arg.iph = iph;
 	arg.user = user;
 
-	read_lock(&ip4_frags.lock);
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3b3ef9774cc2..4d9da1e35f8c 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -193,7 +193,7 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	arg.dst = dst;
 	arg.ecn = ecn;
 
-	read_lock_bh(&nf_frags.lock);
+	local_bh_disable();
 	hash = nf_hash_frag(id, src, dst);
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 987fea46b915..57a9707b2032 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -190,7 +190,6 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 	arg.dst = dst;
 	arg.ecn = ecn;
 
-	read_lock(&ip6_frags.lock);
 	hash = inet6_hash_frag(id, src, dst);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
-- 
1.9.3
