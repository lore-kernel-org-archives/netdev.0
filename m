From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 1/2] ipv6: discard overlapping fragment
Date: Fri, 03 Sep 2010 17:13:05 +0200
Message-ID: <4C811081.3030500@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010907040002000004010103"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:48395 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0ICPNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 11:13:09 -0400
Received: by gwj17 with SMTP id 17so719274gwj.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 08:13:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010907040002000004010103
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

here is a patch to take care of RFC5722 "Handling of Overlapping IPv6 Fragments" 
in IPv6 stack.


Regards,
Nicolas

--------------010907040002000004010103
Content-Type: text/x-diff;
 name="0001-ipv6-discard-overlapping-fragment.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-ipv6-discard-overlapping-fragment.patch"

>From d3244c5458cb331f635d68dd52511bd507580bcb Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 3 Sep 2010 15:31:14 +0200
Subject: [PATCH] ipv6: discard overlapping fragment

RFC5722 prohibits reassembling fragments when some data overlaps.

Bug spotted by Zhang Zuotao <zuotao.zhang@6wind.com>.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/reassembly.c |   71 ++++++++++--------------------------------------
 1 files changed, 15 insertions(+), 56 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 545c414..64cfef1 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -149,13 +149,6 @@ int ip6_frag_match(struct inet_frag_queue *q, void *a)
 }
 EXPORT_SYMBOL(ip6_frag_match);
 
-/* Memory Tracking Functions. */
-static void frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb)
-{
-	atomic_sub(skb->truesize, &nf->mem);
-	kfree_skb(skb);
-}
-
 void ip6_frag_init(struct inet_frag_queue *q, void *a)
 {
 	struct frag_queue *fq = container_of(q, struct frag_queue, q);
@@ -346,58 +339,22 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	}
 
 found:
-	/* We found where to put this one.  Check for overlap with
-	 * preceding fragment, and, if needed, align things so that
-	 * any overlaps are eliminated.
+	/* RFC5722, Section 4:
+	 *                                  When reassembling an IPv6 datagram, if
+	 *   one or more its constituent fragments is determined to be an
+	 *   overlapping fragment, the entire datagram (and any constituent
+	 *   fragments, including those not yet received) MUST be silently
+	 *   discarded.
 	 */
-	if (prev) {
-		int i = (FRAG6_CB(prev)->offset + prev->len) - offset;
 
-		if (i > 0) {
-			offset += i;
-			if (end <= offset)
-				goto err;
-			if (!pskb_pull(skb, i))
-				goto err;
-			if (skb->ip_summed != CHECKSUM_UNNECESSARY)
-				skb->ip_summed = CHECKSUM_NONE;
-		}
-	}
+	/* Check for overlap with preceding fragment. */
+	if (prev &&
+	    (FRAG6_CB(prev)->offset + prev->len) - offset > 0)
+		goto discard_fq;
 
-	/* Look for overlap with succeeding segments.
-	 * If we can merge fragments, do it.
-	 */
-	while (next && FRAG6_CB(next)->offset < end) {
-		int i = end - FRAG6_CB(next)->offset; /* overlap is 'i' bytes */
-
-		if (i < next->len) {
-			/* Eat head of the next overlapped fragment
-			 * and leave the loop. The next ones cannot overlap.
-			 */
-			if (!pskb_pull(next, i))
-				goto err;
-			FRAG6_CB(next)->offset += i;	/* next fragment */
-			fq->q.meat -= i;
-			if (next->ip_summed != CHECKSUM_UNNECESSARY)
-				next->ip_summed = CHECKSUM_NONE;
-			break;
-		} else {
-			struct sk_buff *free_it = next;
-
-			/* Old fragment is completely overridden with
-			 * new one drop it.
-			 */
-			next = next->next;
-
-			if (prev)
-				prev->next = next;
-			else
-				fq->q.fragments = next;
-
-			fq->q.meat -= free_it->len;
-			frag_kfree_skb(fq->q.net, free_it);
-		}
-	}
+	/* Look for overlap with succeeding segment. */
+	if (next && FRAG6_CB(next)->offset < end)
+		goto discard_fq;
 
 	FRAG6_CB(skb)->offset = offset;
 
@@ -436,6 +393,8 @@ found:
 	write_unlock(&ip6_frags.lock);
 	return -1;
 
+discard_fq:
+	fq_kill(fq);
 err:
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_REASMFAILS);
-- 
1.5.4.5


--------------010907040002000004010103--
