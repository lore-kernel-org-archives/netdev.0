From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 8/9] net: frag queue locking per hash bucket
Date: Thu, 29 Nov 2012 17:15:47 +0100
Message-ID: <20121129161512.17754.93933.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:33775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852Ab2K2QR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:17:27 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements per hash bucket locking for the frag queue
hash.  This removes two write locks, and the only remaining write
lock is for protecting hash rebuild.  This essentially reduce the
readers-writer lock to a rebuild lock.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Fixed two bugs
 - 1) Missed/too-late read_lock() for protecting hashfn in fq_unlink()
 - 2) Uses old hash bucket instead of new dest bucket in inet_frag_secret_rebuild()

 include/net/inet_frag.h  |   10 +++++++-
 net/ipv4/inet_fragment.c |   56 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index f58590f..431f68e 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -49,9 +49,15 @@ struct inet_frag_queue {
 
 #define INETFRAGS_HASHSZ		64
 
+
+struct inet_frag_bucket {
+	struct hlist_head	chain;
+	spinlock_t		chain_lock;
+};
+
 struct inet_frags {
-	struct hlist_head	hash[INETFRAGS_HASHSZ];
-	rwlock_t		lock;
+	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
+	rwlock_t		lock; /* Rebuild lock */
 	u32			rnd;
 	int			qsize;
 	int			secret_interval;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 9b97f2e..59999e6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -41,20 +41,27 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 	unsigned long now = jiffies;
 	int i;
 
+	/* Per bucket lock NOT needed here, due to write lock protection */
 	write_lock(&f->lock);
+
 	get_random_bytes(&f->rnd, sizeof(u32));
 	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb;
 		struct inet_frag_queue *q;
 		struct hlist_node *p, *n;
 
-		hlist_for_each_entry_safe(q, p, n, &f->hash[i], list) {
+		hb = &f->hash[i];
+		hlist_for_each_entry_safe(q, p, n, &hb->chain, list) {
 			unsigned int hval = f->hashfn(q);
 
 			if (hval != i) {
+				struct inet_frag_bucket *hb_dest;
+
 				hlist_del(&q->list);
 
 				/* Relink to new hash chain. */
-				hlist_add_head(&q->list, &f->hash[hval]);
+				hb_dest = &f->hash[hval];
+				hlist_add_head(&q->list, &hb->chain);
 			}
 		}
 	}
@@ -67,9 +74,12 @@ void inet_frags_init(struct inet_frags *f)
 {
 	int i;
 
-	for (i = 0; i < INETFRAGS_HASHSZ; i++)
-		INIT_HLIST_HEAD(&f->hash[i]);
+	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb = &f->hash[i];
 
+		spin_lock_init(&hb->chain_lock);
+		INIT_HLIST_HEAD(&hb->chain);
+	}
 	rwlock_init(&f->lock);
 
 	f->rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
@@ -129,9 +139,17 @@ EXPORT_SYMBOL(inet_frags_exit_net);
 
 static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 {
-	write_lock(&f->lock);
+	struct inet_frag_bucket *hb;
+	unsigned int hash;
+
+	read_lock(&f->lock);
+	hash = f->hashfn(fq);
+	hb = &f->hash[hash];
+
+	spin_lock_bh(&hb->chain_lock);
 	hlist_del(&fq->list);
-	write_unlock(&f->lock);
+	spin_unlock_bh(&hb->chain_lock);
+	read_unlock(&f->lock);
 	inet_frag_lru_del(fq);
 }
 
@@ -245,28 +263,33 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
 		void *arg)
 {
+	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *qp;
 #ifdef CONFIG_SMP
 	struct hlist_node *n;
 #endif
 	unsigned int hash;
 
-	write_lock(&f->lock);
+	read_lock(&f->lock); /* Protects against hash rebuild */
 	/*
 	 * While we stayed w/o the lock other CPU could update
 	 * the rnd seed, so we need to re-calculate the hash
 	 * chain. Fortunatelly the qp_in can be used to get one.
 	 */
 	hash = f->hashfn(qp_in);
+	hb = &f->hash[hash];
+	spin_lock_bh(&hb->chain_lock);
+
 #ifdef CONFIG_SMP
 	/* With SMP race we have to recheck hash table, because
 	 * such entry could be created on other cpu, while we
-	 * promoted read lock to write lock.
+	 * promoted read lock to write lock. ***Comment FIXME***
 	 */
-	hlist_for_each_entry(qp, n, &f->hash[hash], list) {
+	hlist_for_each_entry(qp, n, &hb->chain, list) {
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
-			write_unlock(&f->lock);
+			spin_unlock_bh(&hb->chain_lock);
+			read_unlock(&f->lock);
 			qp_in->last_in |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
@@ -278,8 +301,9 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		atomic_inc(&qp->refcnt);
 
 	atomic_inc(&qp->refcnt);
-	hlist_add_head(&qp->list, &f->hash[hash]);
-	write_unlock(&f->lock);
+	hlist_add_head(&qp->list, &hb->chain);
+	spin_unlock_bh(&hb->chain_lock);
+	read_unlock(&f->lock);
 	inet_frag_lru_add(nf, qp);
 	return qp;
 }
@@ -328,16 +352,22 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock)
 {
+	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
 	struct hlist_node *n;
 
-	hlist_for_each_entry(q, n, &f->hash[hash], list) {
+	hb = &f->hash[hash];
+
+	spin_lock_bh(&hb->chain_lock);
+	hlist_for_each_entry(q, n, &hb->chain, list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
+			spin_unlock_bh(&hb->chain_lock);
 			read_unlock(&f->lock);
 			return q;
 		}
 	}
+	spin_unlock_bh(&hb->chain_lock);
 	read_unlock(&f->lock);
 
 	return inet_frag_create(nf, f, key);
