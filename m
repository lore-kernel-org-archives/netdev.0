From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH] inet: fix enforcing of fragment queue hash list depth
Date: Mon, 15 Apr 2013 16:25:10 +0200
Message-ID: <20130415142454.14020.18322.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab3DOOXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 10:23:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have found an issues with commit:

 commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
 Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
 Date:   Fri Mar 15 11:32:30 2013 +0000

    inet: limit length of fragment queue hash table bucket lists

There is a connection between the fixed 128 hash depth limit and the
frag mem limit/thresh settings, which limits how high the thresh can
be set.

The 128 elems hash depth limit, results in bad behaviour if mem limit
thresh holds are increased, via /proc/sys/net ::

 /proc/sys/net/ipv4/ipfrag_high_thresh
 /proc/sys/net/ipv4/ipfrag_low_thresh

If we increase the thresh, to something allowing 128 elements in each
bucket, which is not that high given the hash array size of 64
(64*128=8192), e.g.
  big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
  small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968

The problem with commit 5a3da1fe (inet: limit length of fragment queue
hash table bucket lists) is that, once we hit the limit, the we *keep*
the existing frag queues, not allowing new frag queues to be created.
Thus, an attacker can effectivly block handling of fragments for 60
sec (as each frag queue have a timeout of 60 sec).

Even without increasing the limit, as Hannes showed, an attacker on
IPv6 can "attack" a specific hash bucket, and via that change, can
block/drop new fragments also (trying to) utilize this bucket.

Summary:
 With the default mem limit/thresh settings, this is not general
problem, but adjusting the thresh limits result in some-what
unexpected behavior.

Proposed solution:
 IMHO instead of keeping existing frag queues, we should kill one of
the frag queues in the hash instead.

Implementation complications:
 Killing of frag queues while only holding the hash bucket lock, and
not the frag queue lock, complicates the implementation, as we race
and can end up (trying to) remove the hash element twice (resulting in
an oops).

RFC (Request For Comments):
 Can we do better than the hlist_unhashed() check in fq_unlink().

PATCH NOT FINISHED:
 TODO: remove the unused inet_frag_maybe_warn_overflow()
 TODO: Add depth as sysctl option, to make large thresh possible

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/inet_fragment.c |   54 +++++++++++++++++++++++++++++++++++++---------
 1 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e97d66a..a954ff2 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -130,7 +130,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
-static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
+static inline void fq_unlink_hash(struct inet_frag_queue *fq,
+				  struct inet_frags *f)
 {
 	struct inet_frag_bucket *hb;
 	unsigned int hash;
@@ -140,24 +141,35 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	hb = &f->hash[hash];
 
 	spin_lock(&hb->chain_lock);
-	hlist_del(&fq->list);
+	/* Handle race-condition between direct hash tables cleaning
+	 * in inet_frag_find() and users of inet_frag_kill()
+	 */
+	if (!hlist_unhashed(&fq->list))
+		hlist_del(&fq->list);
 	spin_unlock(&hb->chain_lock);
 
 	read_unlock(&f->lock);
-	inet_frag_lru_del(fq);
 }
 
-void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
+void __inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f,
+		      bool unlink_hash)
 {
 	if (del_timer(&fq->timer))
 		atomic_dec(&fq->refcnt);
 
 	if (!(fq->last_in & INET_FRAG_COMPLETE)) {
-		fq_unlink(fq, f);
+		if (unlink_hash)
+			fq_unlink_hash(fq, f);
+		inet_frag_lru_del(fq);
 		atomic_dec(&fq->refcnt);
 		fq->last_in |= INET_FRAG_COMPLETE;
 	}
 }
+
+void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
+{
+	__inet_frag_kill(fq, f, true);
+}
 EXPORT_SYMBOL(inet_frag_kill);
 
 static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
@@ -326,13 +338,14 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	__releases(&f->lock)
 {
 	struct inet_frag_bucket *hb;
-	struct inet_frag_queue *q;
+	struct inet_frag_queue *q, *q_evict = NULL;
+	struct hlist_node *n;
 	int depth = 0;
 
 	hb = &f->hash[hash];
 
 	spin_lock(&hb->chain_lock);
-	hlist_for_each_entry(q, &hb->chain, list) {
+	hlist_for_each_entry_safe(q, n, &hb->chain, list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
 			spin_unlock(&hb->chain_lock);
@@ -340,14 +353,33 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			return q;
 		}
 		depth++;
+		q_evict = q; /* candidate for eviction */
 	}
+	/* Not found situation */
+	if (depth > INETFRAGS_MAXDEPTH) {
+		atomic_inc(&q_evict->refcnt);
+		hlist_del_init(&q_evict->list);
+	} else
+		q_evict = NULL;
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
 
-	if (depth <= INETFRAGS_MAXDEPTH)
-		return inet_frag_create(nf, f, key);
-	else
-		return ERR_PTR(-ENOBUFS);
+	if (q_evict) {
+		spin_lock(&q_evict->lock);
+		if (!(q_evict->last_in & INET_FRAG_COMPLETE))
+			__inet_frag_kill(q_evict, f, false);
+		spin_unlock(&q_evict->lock);
+
+		if (atomic_dec_and_test(&q_evict->refcnt))
+			inet_frag_destroy(q_evict, f, NULL);
+
+		LIMIT_NETDEBUG(KERN_WARNING "%s(): Fragment hash bucket"
+			       " list length grew over limit (len %d),"
+			       " Dropping another fragment.\n",
+			       __func__, depth);
+	}
+
+	return inet_frag_create(nf, f, key);
 }
 EXPORT_SYMBOL(inet_frag_find);
 
