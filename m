From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 07:16:35 +0800
Message-ID: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:37259 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab0FNBQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 21:16:23 -0400
Received: by pwi1 with SMTP id 1so2392971pwi.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 18:16:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add fast path

As the fragments are usually in order, it is likely the new fragments are
at the end of the inet_frag_queue. In the fast path, we check if the skb at the
end of the inet_frag_queue is the prev we expect.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/inet_frag.h |    1 +
 net/ipv4/ip_fragment.c  |   17 +++++++++++++++++
 net/ipv6/reassembly.c   |   16 ++++++++++++++++
 3 files changed, 34 insertions(+)
diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 39f2dc9..16ff29a 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -20,6 +20,7 @@ struct inet_frag_queue {
 	atomic_t		refcnt;
 	struct timer_list	timer;      /* when will this queue expire? */
 	struct sk_buff		*fragments; /* list of received fragments */
+	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
 	int			len;        /* total length of orig datagram */
 	int			meat;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 75347ea..d8c36d4 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -317,6 +317,7 @@ static int ip_frag_reinit(struct ipq *qp)
 	qp->q.len = 0;
 	qp->q.meat = 0;
 	qp->q.fragments = NULL;
+	qp->q.fragments_tail = NULL;
 	qp->iif = 0;
 
 	return 0;
@@ -389,6 +390,16 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	 * in the chain of fragments so far.  We must know where to put
 	 * this fragment, right?
 	 */
+	prev = qp->q.fragments_tail;
+	if (prev) {
+		if (FRAG_CB(prev)->offset < offset) {
+			next = NULL;
+			goto found;
+		}
+	} else {
+		next = NULL;
+		goto found;
+	}
 	prev = NULL;
 	for (next = qp->q.fragments; next != NULL; next = next->next) {
 		if (FRAG_CB(next)->offset >= offset)
@@ -396,6 +407,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		prev = next;
 	}
 
+found:
 	/* We found where to put this one.  Check for overlap with
 	 * preceding fragment, and, if needed, align things so that
 	 * any overlaps are eliminated.
@@ -454,6 +466,8 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 
 	/* Insert this fragment in the chain of fragments. */
 	skb->next = next;
+	if (!next)
+		qp->q.fragments_tail = skb;
 	if (prev)
 		prev->next = skb;
 	else
@@ -507,6 +521,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 			goto out_nomem;
 
 		fp->next = head->next;
+		if (!fp->next)
+			qp->q.fragments_tail = fp;
 		prev->next = fp;
 
 		skb_morph(head, qp->q.fragments);
@@ -578,6 +594,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	iph->tot_len = htons(len);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
+	qp->q.fragments_tail = NULL;
 	return 0;
 
 out_nomem:
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6d4292f..dc15624 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -336,6 +336,16 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	 * in the chain of fragments so far.  We must know where to put
 	 * this fragment, right?
 	 */
+	prev = fq->q.fragments_tail;
+	if (prev) {
+		if (FRAG6_CB(prev)->offset < offset) {
+			next = NULL;
+			goto found;
+		}
+	} else {
+		next = NULL;
+		goto found;
+	}
 	prev = NULL;
 	for(next = fq->q.fragments; next != NULL; next = next->next) {
 		if (FRAG6_CB(next)->offset >= offset)
@@ -343,6 +353,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		prev = next;
 	}
 
+found:
 	/* We found where to put this one.  Check for overlap with
 	 * preceding fragment, and, if needed, align things so that
 	 * any overlaps are eliminated.
@@ -400,6 +411,8 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 
 	/* Insert this fragment in the chain of fragments. */
 	skb->next = next;
+	if (!next)
+		fq->q.fragments_tail = skb;
 	if (prev)
 		prev->next = skb;
 	else
@@ -466,6 +479,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			goto out_oom;
 
 		fp->next = head->next;
+		if (!fp->next)
+			fq->q.fragments_tail = fp;
 		prev->next = fp;
 
 		skb_morph(head, fq->q.fragments);
@@ -553,6 +568,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
 	rcu_read_unlock();
 	fq->q.fragments = NULL;
+	fq->q.fragments_tail = NULL;
 	return 1;
 
 out_oversize:
