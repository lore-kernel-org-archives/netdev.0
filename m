From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 12/14] gro: Nasty optimisations for page frags in skb_gro_receive
Date: Wed, 27 May 2009 14:50:32 +1000
Message-ID: <E1M9B60-0001TO-4D@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51781 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757749AbZE0FTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:19:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Nasty optimisations for page frags in skb_gro_receive

This patch reverses the direction of the frags array copy in
skb_gro_receive in order simplify the loop conditional.  It
also avoids touching the first element of the original frags
array.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 168e949..19afb18 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2676,21 +2676,26 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		goto merge;
 	else if (headlen <= offset) {
 		skb_frag_t *frag;
-		int i;
+		skb_frag_t *frag2;
+		int i = skb_shinfo(skb)->nr_frags;
+		int nr_frags = skb_shinfo(p)->nr_frags + i;
+
+		offset -= headlen;
 
-		if (skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags >
-		    MAX_SKB_FRAGS)
+		if (nr_frags > MAX_SKB_FRAGS)
 			return -E2BIG;
 
-		skb_shinfo(skb)->frags[0].page_offset += offset - headlen;
-		skb_shinfo(skb)->frags[0].size -= offset - headlen;
+		skb_shinfo(p)->nr_frags = nr_frags;
+		skb_shinfo(skb)->nr_frags = 0;
 
-		frag = skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags;
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-			*frag++ = skb_shinfo(skb)->frags[i];
+		frag = skb_shinfo(p)->frags + nr_frags;
+		frag2 = skb_shinfo(skb)->frags + i;
+		do {
+			*--frag = *--frag2;
+		} while (--i);
 
-		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
-		skb_shinfo(skb)->nr_frags = 0;
+		frag->page_offset += offset;
+		frag->size -= offset;
 
 		skb->truesize -= skb->data_len;
 		skb->len -= skb->data_len;
