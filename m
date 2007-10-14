From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] [IPV6]: Make ipv6_frag_rcv return the same packet
Date: Sun, 14 Oct 2007 22:49:03 +0800
Message-ID: <E1Ih4m7-0003rk-00@gondolin.me.apana.org.au>
References: <20071014144649.GA14792@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Tho
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1779 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751040AbXJNOtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 10:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Make ipv6_frag_rcv return the same packet

This patch implements the same change taht was done to ip_defrag.  It
makes ipv6_frag_rcv return the last packet received of a train of fragments
rather than the head of that sequence.

This allows us to get rid of the sk_buff ** argument later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/reassembly.c |   57 +++++++++++++++++++++++++++++++++++---------------
 1 files changed, 40 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 31601c9..fa1055b 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -42,6 +42,7 @@
 #include <linux/icmpv6.h>
 #include <linux/random.h>
 #include <linux/jhash.h>
+#include <linux/skbuff.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -107,6 +108,9 @@ static u32 ip6_frag_hash_rnd;
 static LIST_HEAD(ip6_frag_lru_list);
 int ip6_frag_nqueues = 0;
 
+static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
+			  struct net_device *dev);
+
 static __inline__ void __fq_unlink(struct frag_queue *fq)
 {
 	hlist_del(&fq->list);
@@ -420,10 +424,11 @@ fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst,
 }
 
 
-static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
+static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			   struct frag_hdr *fhdr, int nhoff)
 {
 	struct sk_buff *prev, *next;
+	struct net_device *dev;
 	int offset, end;
 
 	if (fq->last_in & COMPLETE)
@@ -439,7 +444,7 @@ static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((u8 *)&fhdr->frag_off -
 				   skb_network_header(skb)));
-		return;
+		return -1;
 	}
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
@@ -471,7 +476,7 @@ static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 					  offsetof(struct ipv6hdr, payload_len));
-			return;
+			return -1;
 		}
 		if (end > fq->len) {
 			/* Some bits beyond end -> corruption. */
@@ -564,9 +569,11 @@ static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	else
 		fq->fragments = skb;
 
-	if (skb->dev)
-		fq->iif = skb->dev->ifindex;
-	skb->dev = NULL;
+	dev = skb->dev;
+	if (dev) {
+		fq->iif = dev->ifindex;
+		skb->dev = NULL;
+	}
 	fq->stamp = skb->tstamp;
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &ip6_frag_mem);
@@ -578,14 +585,19 @@ static void ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		fq->nhoffset = nhoff;
 		fq->last_in |= FIRST_IN;
 	}
+
+	if (fq->last_in == (FIRST_IN | LAST_IN) && fq->meat == fq->len)
+		return ip6_frag_reasm(fq, prev, dev);
+
 	write_lock(&ip6_frag_lock);
 	list_move_tail(&fq->lru_list, &ip6_frag_lru_list);
 	write_unlock(&ip6_frag_lock);
-	return;
+	return -1;
 
 err:
 	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
+	return -1;
 }
 
 /*
@@ -597,7 +609,7 @@ err:
  *	queue is eligible for reassembly i.e. it is not COMPLETE,
  *	the last and the first frames arrived and all the bits are here.
  */
-static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in,
+static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			  struct net_device *dev)
 {
 	struct sk_buff *fp, *head = fq->fragments;
@@ -606,6 +618,24 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in,
 
 	fq_kill(fq);
 
+	/* Make the one we just received the head. */
+	if (prev) {
+		head = prev->next;
+		fp = skb_clone(head, GFP_ATOMIC);
+
+		if (!fp)
+			goto out_oom;
+
+		fp->next = head->next;
+		prev->next = fp;
+
+		skb_morph(head, fq->fragments);
+		head->next = fq->fragments->next;
+
+		kfree_skb(fq->fragments);
+		fq->fragments = head;
+	}
+
 	BUG_TRAP(head != NULL);
 	BUG_TRAP(FRAG6_CB(head)->offset == 0);
 
@@ -674,8 +704,6 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff **skb_in,
 	ipv6_hdr(head)->payload_len = htons(payload_len);
 	IP6CB(head)->nhoff = nhoff;
 
-	*skb_in = head;
-
 	/* Yes, and fold redundant checksum back. 8) */
 	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(skb_network_header(head),
@@ -705,7 +733,6 @@ out_fail:
 static int ipv6_frag_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
-	struct net_device *dev = skb->dev;
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
@@ -744,15 +771,11 @@ static int ipv6_frag_rcv(struct sk_buff **skbp)
 
 	if ((fq = fq_find(fhdr->identification, &hdr->saddr, &hdr->daddr,
 			  ip6_dst_idev(skb->dst))) != NULL) {
-		int ret = -1;
+		int ret;
 
 		spin_lock(&fq->lock);
 
-		ip6_frag_queue(fq, skb, fhdr, IP6CB(skb)->nhoff);
-
-		if (fq->last_in == (FIRST_IN|LAST_IN) &&
-		    fq->meat == fq->len)
-			ret = ip6_frag_reasm(fq, skbp, dev);
+		ret = ip6_frag_queue(fq, skb, fhdr, IP6CB(skb)->nhoff);
 
 		spin_unlock(&fq->lock);
 		fq_put(fq, NULL);
