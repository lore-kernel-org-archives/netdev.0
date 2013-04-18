From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash list
	depth
Date: Thu, 18 Apr 2013 23:38:00 +0200
Message-ID: <20130418213732.14296.36026.stgit@dragon>
References: <20130418213637.14296.43143.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782Ab3DRVfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 17:35:30 -0400
In-Reply-To: <20130418213637.14296.43143.stgit@dragon>
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
Thus, an attacker can effectivly block handling of fragments for 30
sec (as each frag queue have a timeout of 30 sec).

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
an oops). This have been addressed by using hlist_del_init() and a
hlist_unhashed() check in fq_unlink_hash().

Extra:
* Added new sysctl "max_hash_depth" option, to allow users to adjust the hash
  depth along with adjusting the thresh limits.
* Change max hash depth to 32, thus limit handling to approx 2048 frag queues.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h                 |    9 +---
 net/ipv4/inet_fragment.c                |   64 ++++++++++++++++++++-----------
 net/ipv4/ip_fragment.c                  |   13 +++++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 +-
 net/ipv6/reassembly.c                   |   15 ++++++-
 5 files changed, 68 insertions(+), 38 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f41b45..b2cd72a 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -42,13 +42,7 @@ struct inet_frag_queue {
 };
 
 #define INETFRAGS_HASHSZ		64
-
-/* averaged:
- * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
- *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
- *	       struct frag_queue))
- */
-#define INETFRAGS_MAXDEPTH		128
+#define INETFRAGS_MAX_HASH_DEPTH	32
 
 struct inet_frag_bucket {
 	struct hlist_head	chain;
@@ -65,6 +59,7 @@ struct inet_frags {
 	int			secret_interval;
 	struct timer_list	secret_timer;
 	u32			rnd;
+	u32			max_hash_depth;
 	int			qsize;
 
 	unsigned int		(*hashfn)(struct inet_frag_queue *);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index beec05b..fd9fe5c 100644
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
@@ -340,25 +353,32 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			return q;
 		}
 		depth++;
+		q_evict = q; /* candidate for eviction */
 	}
+	/* Not found situation */
+	if (depth > f->max_hash_depth) {
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
-}
-EXPORT_SYMBOL(inet_frag_find);
+	if (q_evict) {
+		spin_lock(&q_evict->lock);
+		if (!(q_evict->last_in & INET_FRAG_COMPLETE))
+			__inet_frag_kill(q_evict, f, false);
+		spin_unlock(&q_evict->lock);
 
-void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
-				   const char *prefix)
-{
-	static const char msg[] = "inet_frag_find: Fragment hash bucket"
-		" list length grew over limit " __stringify(INETFRAGS_MAXDEPTH)
-		". Dropping fragment.\n";
+		if (atomic_dec_and_test(&q_evict->refcnt))
+			inet_frag_destroy(q_evict, f, NULL);
 
-	if (PTR_ERR(q) == -ENOBUFS)
-		LIMIT_NETDEBUG(KERN_WARNING "%s%s", prefix, msg);
+		LIMIT_NETDEBUG(KERN_WARNING "%s(): Fragment hash bucket"
+			       " list length grew over limit (len %d),"
+			       " Dropping another fragment.\n",
+			       __func__, depth);
+	}
+
+	return inet_frag_create(nf, f, key);
 }
-EXPORT_SYMBOL(inet_frag_maybe_warn_overflow);
+EXPORT_SYMBOL(inet_frag_find);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9385206..4e8489b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -263,10 +263,8 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
+	if (q == NULL)
 		return NULL;
-	}
 	return container_of(q, struct ipq, q);
 }
 
@@ -748,6 +746,14 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "ipfrag_max_hash_depth",
+		.data		= &ip4_frags.max_hash_depth,
+		.maxlen		= sizeof(u32),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero
+	},
 	{ }
 };
 
@@ -866,5 +872,6 @@ void __init ipfrag_init(void)
 	ip4_frags.match = ip4_frag_match;
 	ip4_frags.frag_expire = ip_expire;
 	ip4_frags.secret_interval = 10 * 60 * HZ;
+	ip4_frags.max_hash_depth = INETFRAGS_MAX_HASH_DEPTH;
 	inet_frags_init(&ip4_frags);
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index dffdc1a..3713764 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -189,10 +189,8 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
+	if (q == NULL)
 		return NULL;
-	}
 	return container_of(q, struct frag_queue, q);
 }
 
@@ -681,6 +679,7 @@ int nf_ct_frag6_init(void)
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
 	nf_frags.secret_interval = 10 * 60 * HZ;
+	nf_frags.max_hash_depth = INETFRAGS_MAX_HASH_DEPTH;
 	inet_frags_init(&nf_frags);
 
 	ret = register_pernet_subsys(&nf_ct_net_ops);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e6e44ce..45de5eb 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -196,10 +196,8 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
+	if (q == NULL)
 		return NULL;
-	}
 	return container_of(q, struct frag_queue, q);
 }
 
@@ -600,6 +598,8 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{ }
 };
 
+static int zero;
+
 static struct ctl_table ip6_frags_ctl_table[] = {
 	{
 		.procname	= "ip6frag_secret_interval",
@@ -608,6 +608,14 @@ static struct ctl_table ip6_frags_ctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "ip6frag_max_hash_depth",
+		.data		= &ip6_frags.max_hash_depth,
+		.maxlen		= sizeof(u32),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero
+	},
 	{ }
 };
 
@@ -734,6 +742,7 @@ int __init ipv6_frag_init(void)
 	ip6_frags.match = ip6_frag_match;
 	ip6_frags.frag_expire = ip6_frag_expire;
 	ip6_frags.secret_interval = 10 * 60 * HZ;
+	ip6_frags.max_hash_depth = INETFRAGS_MAX_HASH_DEPTH;
 	inet_frags_init(&ip6_frags);
 out:
 	return ret;
