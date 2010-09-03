From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 2/2] netfilter: discard overlapping IPv6 fragment
Date: Fri, 03 Sep 2010 17:13:07 +0200
Message-ID: <4C811083.4080302@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090402000600070005000206"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41593 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0ICPNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 11:13:12 -0400
Received: by ewy23 with SMTP id 23so1159289ewy.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 08:13:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090402000600070005000206
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

here is a patch to take care of RFC5722 "Handling of Overlapping IPv6 Fragments" 
in Netfilter IPv6 stack.


Regards,
Nicolas

--------------090402000600070005000206
Content-Type: text/x-diff;
 name="0002-netfilter-discard-overlapping-IPv6-fragment.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0002-netfilter-discard-overlapping-IPv6-fragment.patch"

>From d4629af70ebe1e739c0df33532d56aedd7cbb11e Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 3 Sep 2010 16:41:18 +0200
Subject: [PATCH] netfilter: discard overlapping IPv6 fragment

RFC5722 prohibits reassembling IPv6 fragments when some data overlaps.

Bug spotted by Zhang Zuotao <zuotao.zhang@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   80 ++++++-------------------------
 1 files changed, 15 insertions(+), 65 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 13ef5bc..578f3c1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -113,14 +113,6 @@ static void nf_skb_free(struct sk_buff *skb)
 		kfree_skb(NFCT_FRAG6_CB(skb)->orig);
 }
 
-/* Memory Tracking Functions. */
-static void frag_kfree_skb(struct sk_buff *skb)
-{
-	atomic_sub(skb->truesize, &nf_init_frags.mem);
-	nf_skb_free(skb);
-	kfree_skb(skb);
-}
-
 /* Destruction primitives. */
 
 static __inline__ void fq_put(struct nf_ct_frag6_queue *fq)
@@ -282,66 +274,22 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	}
 
 found:
-	/* We found where to put this one.  Check for overlap with
-	 * preceding fragment, and, if needed, align things so that
-	 * any overlaps are eliminated.
-	 */
-	if (prev) {
-		int i = (NFCT_FRAG6_CB(prev)->offset + prev->len) - offset;
-
-		if (i > 0) {
-			offset += i;
-			if (end <= offset) {
-				pr_debug("overlap\n");
-				goto err;
-			}
-			if (!pskb_pull(skb, i)) {
-				pr_debug("Can't pull\n");
-				goto err;
-			}
-			if (skb->ip_summed != CHECKSUM_UNNECESSARY)
-				skb->ip_summed = CHECKSUM_NONE;
-		}
-	}
-
-	/* Look for overlap with succeeding segments.
-	 * If we can merge fragments, do it.
+	/* RFC5722, Section 4:
+	 *                                  When reassembling an IPv6 datagram, if
+	 *   one or more its constituent fragments is determined to be an
+	 *   overlapping fragment, the entire datagram (and any constituent
+	 *   fragments, including those not yet received) MUST be silently
+	 *   discarded.
 	 */
-	while (next && NFCT_FRAG6_CB(next)->offset < end) {
-		/* overlap is 'i' bytes */
-		int i = end - NFCT_FRAG6_CB(next)->offset;
-
-		if (i < next->len) {
-			/* Eat head of the next overlapped fragment
-			 * and leave the loop. The next ones cannot overlap.
-			 */
-			pr_debug("Eat head of the overlapped parts.: %d", i);
-			if (!pskb_pull(next, i))
-				goto err;
 
-			/* next fragment */
-			NFCT_FRAG6_CB(next)->offset += i;
-			fq->q.meat -= i;
-			if (next->ip_summed != CHECKSUM_UNNECESSARY)
-				next->ip_summed = CHECKSUM_NONE;
-			break;
-		} else {
-			struct sk_buff *free_it = next;
-
-			/* Old fragmnet is completely overridden with
-			 * new one drop it.
-			 */
-			next = next->next;
+	/* Check for overlap with preceding fragment. */
+	if (prev &&
+	    (NFCT_FRAG6_CB(prev)->offset + prev->len) - offset > 0)
+		goto discard_fq;
 
-			if (prev)
-				prev->next = next;
-			else
-				fq->q.fragments = next;
-
-			fq->q.meat -= free_it->len;
-			frag_kfree_skb(free_it);
-		}
-	}
+	/* Look for overlap with succeeding segment. */
+	if (next && NFCT_FRAG6_CB(next)->offset < end)
+		goto discard_fq;
 
 	NFCT_FRAG6_CB(skb)->offset = offset;
 
@@ -371,6 +319,8 @@ found:
 	write_unlock(&nf_frags.lock);
 	return 0;
 
+discard_fq:
+	fq_kill(fq);
 err:
 	return -1;
 }
-- 
1.5.4.5


--------------090402000600070005000206--
