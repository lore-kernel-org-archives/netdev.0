From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/4] inet: frags: rename last_in to flags, enum the definitions and add comments
Date: Thu, 31 Jul 2014 17:11:37 +0200
Message-ID: <1406819499-11198-3-git-send-email-nikolay@redhat.com>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:9161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbaGaPOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 11:14:50 -0400
In-Reply-To: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last_in field has been used to store various flags different from
first/last frag in so give it a more descriptive name: flags. Move
the flags to an enum definion, swap FIRST_IN/LAST_IN to be in logical
order and add comments explaining each flag, also add comments explaining
the inet_frag_queue struct members. While at it align some function
declarations.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 include/net/inet_frag.h                 | 46 +++++++++++++++++++++++++--------
 net/ieee802154/reassembly.c             | 14 +++++-----
 net/ipv4/inet_fragment.c                | 25 +++++++++---------
 net/ipv4/ip_fragment.c                  | 20 +++++++-------
 net/ipv6/netfilter/nf_conntrack_reasm.c | 12 ++++-----
 net/ipv6/reassembly.c                   | 18 ++++++-------
 6 files changed, 80 insertions(+), 55 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f4930a0b660..90015c47b447 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -15,25 +15,49 @@ struct netns_frags {
 	int			low_thresh;
 };
 
+/**
+ * fragment queue flags
+ *
+ * @INET_FRAG_FIRST_IN: first fragment has arrived
+ * @INET_FRAG_LAST_IN: final fragment has arrived
+ * @INET_FRAG_COMPLETE: frag queue has been processed and is due for destruction
+ * @INET_FRAG_EVICTED: frag queue is being evicted
+ */
+enum {
+	INET_FRAG_FIRST_IN	= BIT(0),
+	INET_FRAG_LAST_IN	= BIT(1),
+	INET_FRAG_COMPLETE	= BIT(2),
+	INET_FRAG_EVICTED	= BIT(3)
+};
+
+/**
+ * struct inet_frag_queue - fragment queue
+ *
+ * @lock: spinlock protecting the queue
+ * @timer: queue expiration timer
+ * @list: hash bucket list
+ * @refcnt: reference count of the queue
+ * @fragments: received fragments head
+ * @fragments_tail: received fragments tail
+ * @stamp: timestamp of the last received fragment
+ * @len: total length of the original datagram
+ * @meat: length of received fragments so far
+ * @flags: fragment queue flags
+ * @max_size: (ipv4 only) maximum received fragment size with IP_DF set
+ * @net: namespace that this frag belongs to
+ */
 struct inet_frag_queue {
 	spinlock_t		lock;
-	struct timer_list	timer;      /* when will this queue expire? */
+	struct timer_list	timer;
 	struct hlist_node	list;
 	atomic_t		refcnt;
-	struct sk_buff		*fragments; /* list of received fragments */
+	struct sk_buff		*fragments;
 	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
-	int			len;        /* total length of orig datagram */
+	int			len;
 	int			meat;
-	__u8			last_in;    /* first/last segment arrived? */
-
-#define INET_FRAG_EVICTED	8
-#define INET_FRAG_COMPLETE	4
-#define INET_FRAG_FIRST_IN	2
-#define INET_FRAG_LAST_IN	1
-
+	__u8			flags;
 	u16			max_size;
-
 	struct netns_frags	*net;
 };
 
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index f13d4f32e207..5607accd2fee 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -99,7 +99,7 @@ static void lowpan_frag_expire(unsigned long data)
 
 	spin_lock(&fq->q.lock);
 
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
+	if (fq->q.flags & INET_FRAG_COMPLETE)
 		goto out;
 
 	inet_frag_kill(&fq->q, &lowpan_frags);
@@ -142,7 +142,7 @@ static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
 	struct net_device *dev;
 	int end, offset;
 
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
+	if (fq->q.flags & INET_FRAG_COMPLETE)
 		goto err;
 
 	offset = lowpan_cb(skb)->d_offset << 3;
@@ -154,14 +154,14 @@ static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < fq->q.len ||
-		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len))
+		    ((fq->q.flags & INET_FRAG_LAST_IN) && end != fq->q.len))
 			goto err;
-		fq->q.last_in |= INET_FRAG_LAST_IN;
+		fq->q.flags |= INET_FRAG_LAST_IN;
 		fq->q.len = end;
 	} else {
 		if (end > fq->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (fq->q.last_in & INET_FRAG_LAST_IN)
+			if (fq->q.flags & INET_FRAG_LAST_IN)
 				goto err;
 			fq->q.len = end;
 		}
@@ -201,13 +201,13 @@ found:
 	if (frag_type == LOWPAN_DISPATCH_FRAG1) {
 		/* Calculate uncomp. 6lowpan header to estimate full size */
 		fq->q.meat += lowpan_uncompress_size(skb, NULL);
-		fq->q.last_in |= INET_FRAG_FIRST_IN;
+		fq->q.flags |= INET_FRAG_FIRST_IN;
 	} else {
 		fq->q.meat += skb->len;
 	}
 	add_frag_mem_limit(&fq->q, skb->truesize);
 
-	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
 		int res;
 		unsigned long orefdst = skb->_skb_refdst;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 62b1f73749dc..01d9b268f863 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -152,8 +152,8 @@ evict_again:
 		}
 
 		/* suppress xmit of (icmp) error packet */
-		fq->last_in &= ~INET_FRAG_FIRST_IN;
-		fq->last_in |= INET_FRAG_EVICTED;
+		fq->flags &= ~INET_FRAG_FIRST_IN;
+		fq->flags |= INET_FRAG_EVICTED;
 		hlist_del(&fq->list);
 		hlist_add_head(&fq->list, &expired);
 		++evicted;
@@ -289,16 +289,16 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 	if (del_timer(&fq->timer))
 		atomic_dec(&fq->refcnt);
 
-	if (!(fq->last_in & INET_FRAG_COMPLETE)) {
+	if (!(fq->flags & INET_FRAG_COMPLETE)) {
 		fq_unlink(fq, f);
 		atomic_dec(&fq->refcnt);
-		fq->last_in |= INET_FRAG_COMPLETE;
+		fq->flags |= INET_FRAG_COMPLETE;
 	}
 }
 EXPORT_SYMBOL(inet_frag_kill);
 
 static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
-		struct sk_buff *skb)
+				  struct sk_buff *skb)
 {
 	if (f->skb_free)
 		f->skb_free(skb);
@@ -311,7 +311,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 	struct netns_frags *nf;
 	unsigned int sum, sum_truesize = 0;
 
-	WARN_ON(!(q->last_in & INET_FRAG_COMPLETE));
+	WARN_ON(!(q->flags & INET_FRAG_COMPLETE));
 	WARN_ON(del_timer(&q->timer) != 0);
 
 	/* Release all fragment data. */
@@ -334,8 +334,8 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 EXPORT_SYMBOL(inet_frag_destroy);
 
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
-		struct inet_frag_queue *qp_in, struct inet_frags *f,
-		void *arg)
+						struct inet_frag_queue *qp_in,
+						struct inet_frags *f, void *arg)
 {
 	struct inet_frag_bucket *hb = get_frag_bucket_locked(qp_in, f);
 	struct inet_frag_queue *qp;
@@ -349,7 +349,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
 			spin_unlock(&hb->chain_lock);
-			qp_in->last_in |= INET_FRAG_COMPLETE;
+			qp_in->flags |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
 		}
@@ -368,7 +368,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 }
 
 static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
-		struct inet_frags *f, void *arg)
+					       struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
 
@@ -393,7 +393,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 }
 
 static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
-		struct inet_frags *f, void *arg)
+						struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
 
@@ -405,7 +405,8 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 }
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
-		struct inet_frags *f, void *key, unsigned int hash)
+				       struct inet_frags *f,
+				       void *key, unsigned int hash)
 {
 	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 634fc31aa243..6fce1ecc5bca 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -185,16 +185,16 @@ static void ip_expire(unsigned long arg)
 
 	spin_lock(&qp->q.lock);
 
-	if (qp->q.last_in & INET_FRAG_COMPLETE)
+	if (qp->q.flags & INET_FRAG_COMPLETE)
 		goto out;
 
 	ipq_kill(qp);
 
-	if (!(qp->q.last_in & INET_FRAG_EVICTED))
+	if (!(qp->q.flags & INET_FRAG_EVICTED))
 		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 
-	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
+	if ((qp->q.flags & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
 		const struct iphdr *iph;
 		int err;
@@ -302,7 +302,7 @@ static int ip_frag_reinit(struct ipq *qp)
 	} while (fp);
 	sub_frag_mem_limit(&qp->q, sum_truesize);
 
-	qp->q.last_in = 0;
+	qp->q.flags = 0;
 	qp->q.len = 0;
 	qp->q.meat = 0;
 	qp->q.fragments = NULL;
@@ -323,7 +323,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	int err = -ENOENT;
 	u8 ecn;
 
-	if (qp->q.last_in & INET_FRAG_COMPLETE)
+	if (qp->q.flags & INET_FRAG_COMPLETE)
 		goto err;
 
 	if (!(IPCB(skb)->flags & IPSKB_FRAG_COMPLETE) &&
@@ -350,9 +350,9 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < qp->q.len ||
-		    ((qp->q.last_in & INET_FRAG_LAST_IN) && end != qp->q.len))
+		    ((qp->q.flags & INET_FRAG_LAST_IN) && end != qp->q.len))
 			goto err;
-		qp->q.last_in |= INET_FRAG_LAST_IN;
+		qp->q.flags |= INET_FRAG_LAST_IN;
 		qp->q.len = end;
 	} else {
 		if (end&7) {
@@ -362,7 +362,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		}
 		if (end > qp->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (qp->q.last_in & INET_FRAG_LAST_IN)
+			if (qp->q.flags & INET_FRAG_LAST_IN)
 				goto err;
 			qp->q.len = end;
 		}
@@ -471,13 +471,13 @@ found:
 	qp->ecn |= ecn;
 	add_frag_mem_limit(&qp->q, skb->truesize);
 	if (offset == 0)
-		qp->q.last_in |= INET_FRAG_FIRST_IN;
+		qp->q.flags |= INET_FRAG_FIRST_IN;
 
 	if (ip_hdr(skb)->frag_off & htons(IP_DF) &&
 	    skb->len + ihl > qp->q.max_size)
 		qp->q.max_size = skb->len + ihl;
 
-	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (qp->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    qp->q.meat == qp->q.len) {
 		unsigned long orefdst = skb->_skb_refdst;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3d4bccf6d67d..cca686e42b97 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -222,7 +222,7 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 	int offset, end;
 	u8 ecn;
 
-	if (fq->q.last_in & INET_FRAG_COMPLETE) {
+	if (fq->q.flags & INET_FRAG_COMPLETE) {
 		pr_debug("Already completed\n");
 		goto err;
 	}
@@ -253,11 +253,11 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < fq->q.len ||
-		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len)) {
+		    ((fq->q.flags & INET_FRAG_LAST_IN) && end != fq->q.len)) {
 			pr_debug("already received last fragment\n");
 			goto err;
 		}
-		fq->q.last_in |= INET_FRAG_LAST_IN;
+		fq->q.flags |= INET_FRAG_LAST_IN;
 		fq->q.len = end;
 	} else {
 		/* Check if the fragment is rounded to 8 bytes.
@@ -272,7 +272,7 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 		}
 		if (end > fq->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (fq->q.last_in & INET_FRAG_LAST_IN) {
+			if (fq->q.flags & INET_FRAG_LAST_IN) {
 				pr_debug("last packet already reached.\n");
 				goto err;
 			}
@@ -354,7 +354,7 @@ found:
 	 */
 	if (offset == 0) {
 		fq->nhoffset = nhoff;
-		fq->q.last_in |= INET_FRAG_FIRST_IN;
+		fq->q.flags |= INET_FRAG_FIRST_IN;
 	}
 
 	return 0;
@@ -617,7 +617,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		goto ret_orig;
 	}
 
-	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
 		ret_skb = nf_ct_frag6_reasm(fq, dev);
 		if (ret_skb == NULL)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 512ccc027ce3..b4baceed0d0d 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -131,7 +131,7 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 
 	spin_lock(&fq->q.lock);
 
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
+	if (fq->q.flags & INET_FRAG_COMPLETE)
 		goto out;
 
 	inet_frag_kill(&fq->q, frags);
@@ -141,13 +141,13 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 	if (!dev)
 		goto out_rcu_unlock;
 
-	if (!(fq->q.last_in & INET_FRAG_EVICTED))
+	if (!(fq->q.flags & INET_FRAG_EVICTED))
 		IP6_INC_STATS_BH(net, __in6_dev_get(dev),
 				 IPSTATS_MIB_REASMTIMEOUT);
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 
 	/* Don't send error if the first segment did not arrive. */
-	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
+	if (!(fq->q.flags & INET_FRAG_FIRST_IN) || !fq->q.fragments)
 		goto out_rcu_unlock;
 
 	/*
@@ -209,7 +209,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	u8 ecn;
 
-	if (fq->q.last_in & INET_FRAG_COMPLETE)
+	if (fq->q.flags & INET_FRAG_COMPLETE)
 		goto err;
 
 	offset = ntohs(fhdr->frag_off) & ~0x7;
@@ -240,9 +240,9 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < fq->q.len ||
-		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len))
+		    ((fq->q.flags & INET_FRAG_LAST_IN) && end != fq->q.len))
 			goto err;
-		fq->q.last_in |= INET_FRAG_LAST_IN;
+		fq->q.flags |= INET_FRAG_LAST_IN;
 		fq->q.len = end;
 	} else {
 		/* Check if the fragment is rounded to 8 bytes.
@@ -260,7 +260,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		}
 		if (end > fq->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (fq->q.last_in & INET_FRAG_LAST_IN)
+			if (fq->q.flags & INET_FRAG_LAST_IN)
 				goto err;
 			fq->q.len = end;
 		}
@@ -335,10 +335,10 @@ found:
 	 */
 	if (offset == 0) {
 		fq->nhoffset = nhoff;
-		fq->q.last_in |= INET_FRAG_FIRST_IN;
+		fq->q.flags |= INET_FRAG_FIRST_IN;
 	}
 
-	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
 		int res;
 		unsigned long orefdst = skb->_skb_refdst;
-- 
1.9.3
