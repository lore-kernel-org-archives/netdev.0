From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2] net: frag queue per hash bucket locking
Date: Thu, 04 Apr 2013 09:52:26 +0200
Message-ID: <20130404075226.18493.75426.stgit@dragon>
References: <1365027060.12728.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763863Ab3DDHwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 03:52:40 -0400
In-Reply-To: <1365027060.12728.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements per hash bucket locking for the frag queue
hash.  This removes two write locks, and the only remaining write
lock is for protecting hash rebuild.  This essentially reduce the
readers-writer lock to a rebuild lock.

V2:
- By analysis from Hannes Frederic Sowa and Eric Dumazet, we don't
  need the spinlock _bh versions, as Netfilter currently does a
  local_bh_disable() before entering inet_fragment.
- Fold-in desc from cover-mail

This patch is part of "net: frag performance followup"
 http://thread.gmane.org/gmane.linux.network/263644
of which two patches have already been accepted:

Same test setup as previous:
 (http://thread.gmane.org/gmane.linux.network/257155)
 Two 10G interfaces, on seperate NUMA nodes, are under-test, and uses
 Ethernet flow-control.  A third interface is used for generating the
 DoS attack (with trafgen).

Notice, I have changed the frag DoS generator script to be more
efficient/deadly.  Before it would only hit one RX queue, now its
sending packets causing multi-queue RX, due to "better" RX hashing.

Test types summary (netperf UDP_STREAM):
 Test-20G64K     == 2x10G with 65K fragments
 Test-20G3F      == 2x10G with 3x fragments (3*1472 bytes)
 Test-20G64K+DoS == Same as 20G64K with frag DoS
 Test-20G3F+DoS  == Same as 20G3F  with frag DoS
 Test-20G64K+MQ  == Same as 20G64K with Multi-Queue frag DoS
 Test-20G3F+MQ   == Same as 20G3F  with Multi-Queue frag DoS

When I rebased this-patch(03) (on top of net-next commit a210576c) and
removed the _bh spinlock, I saw a performance regression.  BUT this
was caused by some unrelated change in-between.  See tests below.

Test (A) is what I reported before for patch-02, accepted in commit 1b5ab0de.
Test (B) verifying-retest of commit 1b5ab0de corrospond to patch-02.
Test (C) is what I reported before for this-patch

Test (D) is net-next master HEAD (commit a210576c), which reveals some
(unknown) performance regression (compared against test (B)).
Test (D) function as a new base-test.

Performance table summary (in Mbit/s):

(#) Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
    ----------  -------   -------  ----------  ---------  --------  -------
(A) Patch-02  : 18848.7   13230.1   4103.04     5310.36     130.0    440.2
(B) 1b5ab0de  : 18841.5   13156.8   4101.08     5314.57     129.0    424.2
(C) Patch-03v1: 18838.0   13490.5   4405.11     6814.72     196.6    461.6

(D) a210576c  : 18321.5   11250.4   3635.34     5160.13     119.1    405.2
(E) with _bh  : 17247.3   11492.6   3994.74     6405.29     166.7    413.6
(F) without bh: 17471.3   11298.7   3818.05     6102.11     165.7    406.3

Test (E) and (F) is this-patch(03), with(V1) and without(V2) the _bh spinlocks.

I cannot explain the slow down for 20G64K (but its an artificial
"lab-test" so I'm not worried).  But the other results does show
improvements.  And test (E) "with _bh" version is slightly better.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h  |    9 ++++++-
 net/ipv4/inet_fragment.c |   60 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 7cac9c5..c4f5183 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -50,10 +50,17 @@ struct inet_frag_queue {
  */
 #define INETFRAGS_MAXDEPTH		128
 
+struct inet_frag_bucket {
+	struct hlist_head	chain;
+	spinlock_t		chain_lock;
+	u16			chain_len;
+};
+
 struct inet_frags {
-	struct hlist_head	hash[INETFRAGS_HASHSZ];
+	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
 	/* This rwlock is a global lock (seperate per IPv4, IPv6 and
 	 * netfilter). Important to keep this on a seperate cacheline.
+	 * Its primarily a rebuild protection rwlock.
 	 */
 	rwlock_t		lock ____cacheline_aligned_in_smp;
 	int			secret_interval;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 1206ca6..2bf15e8 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -52,20 +52,27 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 	unsigned long now = jiffies;
 	int i;
 
+	/* Per bucket lock NOT needed here, due to write lock protection */
 	write_lock(&f->lock);
+
 	get_random_bytes(&f->rnd, sizeof(u32));
 	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb;
 		struct inet_frag_queue *q;
 		struct hlist_node *n;
 
-		hlist_for_each_entry_safe(q, n, &f->hash[i], list) {
+		hb = &f->hash[i];
+		hlist_for_each_entry_safe(q, n, &hb->chain, list) {
 			unsigned int hval = f->hashfn(q);
 
 			if (hval != i) {
+				struct inet_frag_bucket *hb_dest;
+
 				hlist_del(&q->list);
 
 				/* Relink to new hash chain. */
-				hlist_add_head(&q->list, &f->hash[hval]);
+				hb_dest = &f->hash[hval];
+				hlist_add_head(&q->list, &hb_dest->chain);
 			}
 		}
 	}
@@ -78,9 +85,13 @@ void inet_frags_init(struct inet_frags *f)
 {
 	int i;
 
-	for (i = 0; i < INETFRAGS_HASHSZ; i++)
-		INIT_HLIST_HEAD(&f->hash[i]);
+	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb = &f->hash[i];
 
+		spin_lock_init(&hb->chain_lock);
+		INIT_HLIST_HEAD(&hb->chain);
+		hb->chain_len = 0;
+	}
 	rwlock_init(&f->lock);
 
 	f->rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
@@ -122,9 +133,19 @@ EXPORT_SYMBOL(inet_frags_exit_net);
 
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
+	spin_lock(&hb->chain_lock);
 	hlist_del(&fq->list);
-	write_unlock(&f->lock);
+	hb->chain_len--;
+	spin_unlock(&hb->chain_lock);
+
+	read_unlock(&f->lock);
 	inet_frag_lru_del(fq);
 }
 
@@ -226,27 +247,32 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
 		void *arg)
 {
+	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *qp;
 #ifdef CONFIG_SMP
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
+	spin_lock(&hb->chain_lock);
+
 #ifdef CONFIG_SMP
 	/* With SMP race we have to recheck hash table, because
 	 * such entry could be created on other cpu, while we
-	 * promoted read lock to write lock.
+	 * released the hash bucket lock.
 	 */
-	hlist_for_each_entry(qp, &f->hash[hash], list) {
+	hlist_for_each_entry(qp, &hb->chain, list) {
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
-			write_unlock(&f->lock);
+			spin_unlock(&hb->chain_lock);
+			read_unlock(&f->lock);
 			qp_in->last_in |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
@@ -258,8 +284,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		atomic_inc(&qp->refcnt);
 
 	atomic_inc(&qp->refcnt);
-	hlist_add_head(&qp->list, &f->hash[hash]);
-	write_unlock(&f->lock);
+	hlist_add_head(&qp->list, &hb->chain);
+	hb->chain_len++;
+	spin_unlock(&hb->chain_lock);
+	read_unlock(&f->lock);
 	inet_frag_lru_add(nf, qp);
 	return qp;
 }
@@ -300,17 +328,23 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock)
 {
+	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
 	int depth = 0;
 
-	hlist_for_each_entry(q, &f->hash[hash], list) {
+	hb = &f->hash[hash];
+
+	spin_lock(&hb->chain_lock);
+	hlist_for_each_entry(q, &hb->chain, list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
+			spin_unlock(&hb->chain_lock);
 			read_unlock(&f->lock);
 			return q;
 		}
 		depth++;
 	}
+	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
 
 	if (depth <= INETFRAGS_MAXDEPTH)
