From: Joe Perches <joe@perches.com>
Subject: [PATCH] net-2.6.26 -  Rename inet_frag.h identifiers COMPLETE,
	FIRST_IN, LAST_IN to INET_FRAG_*
Date: Fri, 28 Mar 2008 11:26:31 -0700
Message-ID: <1206728791.3445.39.camel@localhost>
References: <20080328032449.cbc09f3b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	David S Miller <davem@davemloft.net>,
	Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2293 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbYC1S1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 14:27:14 -0400
In-Reply-To: <20080328032449.cbc09f3b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-03-28 at 03:24 -0700, Andrew Morton wrote:
> they should all be renamed.

Done for include/net and net

Signed-off-by: Joe Perches <joe@perches.com>
--- 
 include/net/inet_frag.h                 |    6 +++---
 net/ipv4/inet_fragment.c                |   10 +++++-----
 net/ipv4/ip_fragment.c                  |   17 +++++++++--------
 net/ipv6/netfilter/nf_conntrack_reasm.c |   15 ++++++++-------
 net/ipv6/reassembly.c                   |   17 +++++++++--------
 5 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 7374251..e081eef 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -25,9 +25,9 @@ struct inet_frag_queue {
 	int			meat;
 	__u8			last_in;    /* first/last segment arrived? */
 
-#define COMPLETE		4
-#define FIRST_IN		2
-#define LAST_IN			1
+#define INET_FRAG_COMPLETE	4
+#define INET_FRAG_FIRST_IN	2
+#define INET_FRAG_LAST_IN	1
 };
 
 #define INETFRAGS_HASHSZ		64
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 724d69a..93170bf 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -104,10 +104,10 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 	if (del_timer(&fq->timer))
 		atomic_dec(&fq->refcnt);
 
-	if (!(fq->last_in & COMPLETE)) {
+	if (!(fq->last_in & INET_FRAG_COMPLETE)) {
 		fq_unlink(fq, f);
 		atomic_dec(&fq->refcnt);
-		fq->last_in |= COMPLETE;
+		fq->last_in |= INET_FRAG_COMPLETE;
 	}
 }
 
@@ -131,7 +131,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 	struct sk_buff *fp;
 	struct netns_frags *nf;
 
-	BUG_TRAP(q->last_in & COMPLETE);
+	BUG_TRAP(q->last_in & INET_FRAG_COMPLETE);
 	BUG_TRAP(del_timer(&q->timer) == 0);
 
 	/* Release all fragment data. */
@@ -174,7 +174,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f)
 		read_unlock(&f->lock);
 
 		spin_lock(&q->lock);
-		if (!(q->last_in & COMPLETE))
+		if (!(q->last_in & INET_FRAG_COMPLETE))
 			inet_frag_kill(q, f);
 		spin_unlock(&q->lock);
 
@@ -206,7 +206,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
 			write_unlock(&f->lock);
-			qp_in->last_in |= COMPLETE;
+			qp_in->last_in |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
 		}
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fcb60e7..02ae470 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -194,7 +194,7 @@ static void ip_expire(unsigned long arg)
 
 	spin_lock(&qp->q.lock);
 
-	if (qp->q.last_in & COMPLETE)
+	if (qp->q.last_in & INET_FRAG_COMPLETE)
 		goto out;
 
 	ipq_kill(qp);
@@ -202,7 +202,7 @@ static void ip_expire(unsigned long arg)
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMTIMEOUT);
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
 
-	if ((qp->q.last_in&FIRST_IN) && qp->q.fragments != NULL) {
+	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
 		struct net *net;
 
@@ -301,7 +301,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	int ihl, end;
 	int err = -ENOENT;
 
-	if (qp->q.last_in & COMPLETE)
+	if (qp->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
 
 	if (!(IPCB(skb)->flags & IPSKB_FRAG_COMPLETE) &&
@@ -327,9 +327,9 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		 * or have different end, the segment is corrrupted.
 		 */
 		if (end < qp->q.len ||
-		    ((qp->q.last_in & LAST_IN) && end != qp->q.len))
+		    ((qp->q.last_in & INET_FRAG_LAST_IN) && end != qp->q.len))
 			goto err;
-		qp->q.last_in |= LAST_IN;
+		qp->q.last_in |= INET_FRAG_LAST_IN;
 		qp->q.len = end;
 	} else {
 		if (end&7) {
@@ -339,7 +339,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		}
 		if (end > qp->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (qp->q.last_in & LAST_IN)
+			if (qp->q.last_in & INET_FRAG_LAST_IN)
 				goto err;
 			qp->q.len = end;
 		}
@@ -438,9 +438,10 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	qp->q.meat += skb->len;
 	atomic_add(skb->truesize, &qp->q.net->mem);
 	if (offset == 0)
-		qp->q.last_in |= FIRST_IN;
+		qp->q.last_in |= INET_FRAG_FIRST_IN;
 
-	if (qp->q.last_in == (FIRST_IN | LAST_IN) && qp->q.meat == qp->q.len)
+	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
 
 	write_lock(&ip4_frags.lock);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 2a0d698..ad80662 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -183,7 +183,7 @@ static void nf_ct_frag6_expire(unsigned long data)
 
 	spin_lock(&fq->q.lock);
 
-	if (fq->q.last_in & COMPLETE)
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto out;
 
 	fq_kill(fq);
@@ -225,7 +225,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	struct sk_buff *prev, *next;
 	int offset, end;
 
-	if (fq->q.last_in & COMPLETE) {
+	if (fq->q.last_in & INET_FRAG_COMPLETE) {
 		pr_debug("Allready completed\n");
 		goto err;
 	}
@@ -252,11 +252,11 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < fq->q.len ||
-		    ((fq->q.last_in & LAST_IN) && end != fq->q.len)) {
+		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len)) {
 			pr_debug("already received last fragment\n");
 			goto err;
 		}
-		fq->q.last_in |= LAST_IN;
+		fq->q.last_in |= INET_FRAG_LAST_IN;
 		fq->q.len = end;
 	} else {
 		/* Check if the fragment is rounded to 8 bytes.
@@ -271,7 +271,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 		}
 		if (end > fq->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (fq->q.last_in & LAST_IN) {
+			if (fq->q.last_in & INET_FRAG_LAST_IN) {
 				pr_debug("last packet already reached.\n");
 				goto err;
 			}
@@ -383,7 +383,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	 */
 	if (offset == 0) {
 		fq->nhoffset = nhoff;
-		fq->q.last_in |= FIRST_IN;
+		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 	write_lock(&nf_frags.lock);
 	list_move_tail(&fq->q.lru_list, &nf_init_frags.lru_list);
@@ -645,7 +645,8 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb)
 		goto ret_orig;
 	}
 
-	if (fq->q.last_in == (FIRST_IN|LAST_IN) && fq->q.meat == fq->q.len) {
+	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	    fq->q.meat == fq->q.len) {
 		ret_skb = nf_ct_frag6_reasm(fq, dev);
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 4e14476..7b247e3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -202,7 +202,7 @@ static void ip6_frag_expire(unsigned long data)
 
 	spin_lock(&fq->q.lock);
 
-	if (fq->q.last_in & COMPLETE)
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto out;
 
 	fq_kill(fq);
@@ -217,7 +217,7 @@ static void ip6_frag_expire(unsigned long data)
 	rcu_read_unlock();
 
 	/* Don't send error if the first segment did not arrive. */
-	if (!(fq->q.last_in&FIRST_IN) || !fq->q.fragments)
+	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
 		goto out;
 
 	/*
@@ -265,7 +265,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct net_device *dev;
 	int offset, end;
 
-	if (fq->q.last_in & COMPLETE)
+	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
 
 	offset = ntohs(fhdr->frag_off) & ~0x7;
@@ -294,9 +294,9 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		 * or have different end, the segment is corrupted.
 		 */
 		if (end < fq->q.len ||
-		    ((fq->q.last_in & LAST_IN) && end != fq->q.len))
+		    ((fq->q.last_in & INET_FRAG_LAST_IN) && end != fq->q.len))
 			goto err;
-		fq->q.last_in |= LAST_IN;
+		fq->q.last_in |= INET_FRAG_LAST_IN;
 		fq->q.len = end;
 	} else {
 		/* Check if the fragment is rounded to 8 bytes.
@@ -314,7 +314,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		}
 		if (end > fq->q.len) {
 			/* Some bits beyond end -> corruption. */
-			if (fq->q.last_in & LAST_IN)
+			if (fq->q.last_in & INET_FRAG_LAST_IN)
 				goto err;
 			fq->q.len = end;
 		}
@@ -417,10 +417,11 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	 */
 	if (offset == 0) {
 		fq->nhoffset = nhoff;
-		fq->q.last_in |= FIRST_IN;
+		fq->q.last_in |= INET_FRAG_FIRST_IN;
 	}
 
-	if (fq->q.last_in == (FIRST_IN | LAST_IN) && fq->q.meat == fq->q.len)
+	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	    fq->q.meat == fq->q.len)
 		return ip6_frag_reasm(fq, prev, dev);
 
 	write_lock(&ip6_frags.lock);


