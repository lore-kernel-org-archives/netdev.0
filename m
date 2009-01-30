From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] gro: Do not merge paged packets into frag_list
Date: Fri, 30 Jan 2009 11:19:51 +1100
Message-ID: <E1LSh6t-0000OM-8D@gondolin.me.apana.org.au>
References: <20090130001849.GA1272@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37716 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755750AbZA3ATy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:19:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Do not merge paged packets into frag_list

Bigger is not always better :)

It was easy to continue to merged packets into frag_list after the
page array is full.  However, this turns out to be worse than LRO
because frag_list is a much less efficient form of storage than the
page array.  So we're better off stopping the merge and starting
a new entry with an empty page array.

In future we can optimise this further by doing frag_list merging
but making sure that we continue to fill in the page array.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/skbuff.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6ecb8d7..d7efaf9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2594,9 +2594,11 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	if (skb_shinfo(p)->frag_list)
 		goto merge;
-	else if (skb_headlen(skb) <= skb_gro_offset(skb) &&
-		 skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags <=
-		 MAX_SKB_FRAGS) {
+	else if (skb_headlen(skb) <= skb_gro_offset(skb)) {
+		if (skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags >
+		    MAX_SKB_FRAGS)
+			return -E2BIG;
+
 		skb_shinfo(skb)->frags[0].page_offset +=
 			skb_gro_offset(skb) - skb_headlen(skb);
 		skb_shinfo(skb)->frags[0].size -=
