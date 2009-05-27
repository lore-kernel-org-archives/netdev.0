From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 11/14] gro: Open-code final pskb_may_pull
Date: Wed, 27 May 2009 14:50:31 +1000
Message-ID: <E1M9B5z-0001TF-1F@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49804 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752152AbZE0FHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Open-code final pskb_may_pull

As we know the only packets which need the final pskb_may_pull
are completely non-linear, and have all the required bits in
frag0, we can perform a straight memcpy instead of going through
pskb_may_pull and doing skb_copy_bits.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5a81302..ed7513c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2449,10 +2449,25 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	ret = GRO_HELD;
 
 pull:
-	if (unlikely(!pskb_may_pull(skb, skb_gro_offset(skb)))) {
-		if (napi->gro_list == skb)
-			napi->gro_list = skb->next;
-		ret = GRO_DROP;
+	if (skb_headlen(skb) < skb_gro_offset(skb)) {
+		int grow = skb_gro_offset(skb) - skb_headlen(skb);
+
+		BUG_ON(skb->end - skb->tail < grow);
+
+		memcpy(skb_tail_pointer(skb), NAPI_GRO_CB(skb)->frag0, grow);
+
+		skb->tail += grow;
+		skb->data_len -= grow;
+
+		skb_shinfo(skb)->frags[0].page_offset += grow;
+		skb_shinfo(skb)->frags[0].size -= grow;
+
+		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
+			put_page(skb_shinfo(skb)->frags[0].page);
+			memmove(skb_shinfo(skb)->frags,
+				skb_shinfo(skb)->frags + 1,
+				--skb_shinfo(skb)->nr_frags);
+		}
 	}
 
 ok:
