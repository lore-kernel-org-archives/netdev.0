From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/10] [IPV4]: Make ip_defrag return the same packet
Date: Sun, 14 Oct 2007 12:27:41 +0800
Message-ID: <E1Igv4n-00030M-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1399 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751460AbXJNE14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Make ip_defrag return the same packet

This patch is a bit of a hack.  However it is worth it if you consider that
this is the only reason why we have to carry around the struct sk_buff **
pointers in netfilter.

It makes ip_defrag always return the packet that was given to it on input.
It does this by cloning the packet and replacing its original contents with
the head fragment if necessary.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ip_fragment.c |   76 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fabb86d..d7fa2bf 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -109,6 +109,9 @@ static u32 ipfrag_hash_rnd;
 static LIST_HEAD(ipq_lru_list);
 int ip_frag_nqueues = 0;
 
+static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+			 struct net_device *dev);
+
 static __inline__ void __ipq_unlink(struct ipq *qp)
 {
 	hlist_del(&qp->list);
@@ -464,17 +467,20 @@ static int ip_frag_reinit(struct ipq *qp)
 }
 
 /* Add new segment to existing queue. */
-static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 {
 	struct sk_buff *prev, *next;
+	struct net_device *dev;
 	int flags, offset;
 	int ihl, end;
+	int err = -ENOENT;
 
 	if (qp->last_in & COMPLETE)
 		goto err;
 
 	if (!(IPCB(skb)->flags & IPSKB_FRAG_COMPLETE) &&
-	    unlikely(ip_frag_too_far(qp)) && unlikely(ip_frag_reinit(qp))) {
+	    unlikely(ip_frag_too_far(qp)) &&
+	    unlikely(err = ip_frag_reinit(qp))) {
 		ipq_kill(qp);
 		goto err;
 	}
@@ -487,6 +493,7 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 
 	/* Determine the position of this fragment. */
 	end = offset + skb->len - ihl;
+	err = -EINVAL;
 
 	/* Is this the final fragment? */
 	if ((flags & IP_MF) == 0) {
@@ -514,9 +521,12 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	if (end == offset)
 		goto err;
 
+	err = -ENOMEM;
 	if (pskb_pull(skb, ihl) == NULL)
 		goto err;
-	if (pskb_trim_rcsum(skb, end-offset))
+
+	err = pskb_trim_rcsum(skb, end - offset);
+	if (err)
 		goto err;
 
 	/* Find out which fragments are in front and at the back of us
@@ -539,8 +549,10 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 
 		if (i > 0) {
 			offset += i;
+			err = -EINVAL;
 			if (end <= offset)
 				goto err;
+			err = -ENOMEM;
 			if (!pskb_pull(skb, i))
 				goto err;
 			if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -548,6 +560,8 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		}
 	}
 
+	err = -ENOMEM;
+
 	while (next && FRAG_CB(next)->offset < end) {
 		int i = end - FRAG_CB(next)->offset; /* overlap is 'i' bytes */
 
@@ -589,37 +603,62 @@ static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	else
 		qp->fragments = skb;
 
-	if (skb->dev)
-		qp->iif = skb->dev->ifindex;
-	skb->dev = NULL;
+	dev = skb->dev;
+	if (dev) {
+		qp->iif = dev->ifindex;
+		skb->dev = NULL;
+	}
 	qp->stamp = skb->tstamp;
 	qp->meat += skb->len;
 	atomic_add(skb->truesize, &ip_frag_mem);
 	if (offset == 0)
 		qp->last_in |= FIRST_IN;
 
+	if (qp->last_in == (FIRST_IN | LAST_IN) && qp->meat == qp->len)
+		return ip_frag_reasm(qp, prev, dev);
+
 	write_lock(&ipfrag_lock);
 	list_move_tail(&qp->lru_list, &ipq_lru_list);
 	write_unlock(&ipfrag_lock);
-
-	return;
+	return -EINPROGRESS;
 
 err:
 	kfree_skb(skb);
+	return err;
 }
 
 
 /* Build a new IP datagram from all its fragments. */
 
-static struct sk_buff *ip_frag_reasm(struct ipq *qp, struct net_device *dev)
+static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+			 struct net_device *dev)
 {
 	struct iphdr *iph;
 	struct sk_buff *fp, *head = qp->fragments;
 	int len;
 	int ihlen;
+	int err;
 
 	ipq_kill(qp);
 
+	/* Make the one we just received the head. */
+	if (prev) {
+		head = prev->next;
+		fp = skb_clone(head, GFP_ATOMIC);
+
+		if (!fp)
+			goto out_nomem;
+
+		fp->next = head->next;
+		prev->next = fp;
+
+		skb_morph(head, qp->fragments);
+		head->next = qp->fragments->next;
+
+		kfree_skb(qp->fragments);
+		qp->fragments = head;
+	}
+
 	BUG_TRAP(head != NULL);
 	BUG_TRAP(FRAG_CB(head)->offset == 0);
 
@@ -627,10 +666,12 @@ static struct sk_buff *ip_frag_reasm(struct ipq *qp, struct net_device *dev)
 	ihlen = ip_hdrlen(head);
 	len = ihlen + qp->len;
 
+	err = -E2BIG;
 	if (len > 65535)
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
+	err = -ENOMEM;
 	if (skb_cloned(head) && pskb_expand_head(head, 0, 0, GFP_ATOMIC))
 		goto out_nomem;
 
@@ -681,7 +722,7 @@ static struct sk_buff *ip_frag_reasm(struct ipq *qp, struct net_device *dev)
 	iph->tot_len = htons(len);
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
 	qp->fragments = NULL;
-	return head;
+	return 0;
 
 out_nomem:
 	LIMIT_NETDEBUG(KERN_ERR "IP: queue_glue: no memory for gluing "
@@ -694,14 +735,13 @@ out_oversize:
 			NIPQUAD(qp->saddr));
 out_fail:
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
-	return NULL;
+	return err;
 }
 
 /* Process an incoming IP datagram fragment. */
 struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
-	struct net_device *dev;
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
 
@@ -709,23 +749,17 @@ struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user)
 	if (atomic_read(&ip_frag_mem) > sysctl_ipfrag_high_thresh)
 		ip_evictor();
 
-	dev = skb->dev;
-
 	/* Lookup (or create) queue header */
 	if ((qp = ip_find(ip_hdr(skb), user)) != NULL) {
-		struct sk_buff *ret = NULL;
+		int ret;
 
 		spin_lock(&qp->lock);
 
-		ip_frag_queue(qp, skb);
-
-		if (qp->last_in == (FIRST_IN|LAST_IN) &&
-		    qp->meat == qp->len)
-			ret = ip_frag_reasm(qp, dev);
+		ret = ip_frag_queue(qp, skb);
 
 		spin_unlock(&qp->lock);
 		ipq_put(qp, NULL);
-		return ret;
+		return ret ? NULL : skb;
 	}
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
