From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 13/14] gro: Store shinfo in local variable in skb_gro_receive
Date: Wed, 27 May 2009 14:50:33 +1000
Message-ID: <E1M9B61-0001Tg-6X@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49798 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751144AbZE0FHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Store shinfo in local variable in skb_gro_receive

This patch stores the two shinfo pointers in local variables
because they're used over and over again in skb_gro_receive.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 19afb18..8e815e6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2664,6 +2664,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	struct sk_buff *p = *head;
 	struct sk_buff *nskb;
+	struct skb_shared_info *skbinfo = skb_shinfo(skb);
+	struct skb_shared_info *pinfo = skb_shinfo(p);
 	unsigned int headroom;
 	unsigned int len = skb_gro_len(skb);
 	unsigned int offset = skb_gro_offset(skb);
@@ -2672,24 +2674,24 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	if (p->len + len >= 65536)
 		return -E2BIG;
 
-	if (skb_shinfo(p)->frag_list)
+	if (pinfo->frag_list)
 		goto merge;
 	else if (headlen <= offset) {
 		skb_frag_t *frag;
 		skb_frag_t *frag2;
-		int i = skb_shinfo(skb)->nr_frags;
-		int nr_frags = skb_shinfo(p)->nr_frags + i;
+		int i = skbinfo->nr_frags;
+		int nr_frags = pinfo->nr_frags + i;
 
 		offset -= headlen;
 
 		if (nr_frags > MAX_SKB_FRAGS)
 			return -E2BIG;
 
-		skb_shinfo(p)->nr_frags = nr_frags;
-		skb_shinfo(skb)->nr_frags = 0;
+		pinfo->nr_frags = nr_frags;
+		skbinfo->nr_frags = 0;
 
-		frag = skb_shinfo(p)->frags + nr_frags;
-		frag2 = skb_shinfo(skb)->frags + i;
+		frag = pinfo->frags + nr_frags;
+		frag2 = skbinfo->frags + i;
 		do {
 			*--frag = *--frag2;
 		} while (--i);
@@ -2726,7 +2728,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
 	skb_shinfo(nskb)->frag_list = p;
-	skb_shinfo(nskb)->gso_size = skb_shinfo(p)->gso_size;
+	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
 	skb_header_release(p);
 	nskb->prev = p;
 
@@ -2742,8 +2744,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 merge:
 	if (offset > headlen) {
-		skb_shinfo(skb)->frags[0].page_offset += offset - headlen;
-		skb_shinfo(skb)->frags[0].size -= offset - headlen;
+		skbinfo->frags[0].page_offset += offset - headlen;
+		skbinfo->frags[0].size -= offset - headlen;
 		offset = headlen;
 	}
 
