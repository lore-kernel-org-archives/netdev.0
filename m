From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/14] gro: Open-code frags copy in skb_gro_receive
Date: Wed, 27 May 2009 14:50:19 +1000
Message-ID: <E1M9B5n-0001QR-Sm@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49816 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756526AbZE0FIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:08:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Open-code frags copy in skb_gro_receive

gcc does a poor job at generating code for the memcpy of the frags
array in skb_gro_receive, which is the primary purpose of that
function when merging frags.  In particular, it can't utilise the
alignment information of the source and destination.  This patch
open-codes the copy so we process words instead of bytes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d429c41..c88426b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2673,6 +2673,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	if (skb_shinfo(p)->frag_list)
 		goto merge;
 	else if (skb_headlen(skb) <= skb_gro_offset(skb)) {
+		skb_frag_t *frag;
+		int i;
+
 		if (skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags >
 		    MAX_SKB_FRAGS)
 			return -E2BIG;
@@ -2682,9 +2685,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		skb_shinfo(skb)->frags[0].size -=
 			skb_gro_offset(skb) - skb_headlen(skb);
 
-		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
-		       skb_shinfo(skb)->frags,
-		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
+		frag = skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags;
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+			*frag++ = skb_shinfo(skb)->frags[i];
 
 		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
 		skb_shinfo(skb)->nr_frags = 0;
