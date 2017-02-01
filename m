From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 14/15] net: Drop secpath on free after gro merge.
Date: Wed, 1 Feb 2017 09:17:56 +0100
Message-ID: <1485937077-612-15-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37104 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751814AbdBAISP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:15 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a followup patch, a gro merged skb can have a secpath.
So drop it before freeing or reusing the skb.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 56818f7..ef3a969 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4623,6 +4623,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 	case GRO_MERGED_FREE:
 		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
 			skb_dst_drop(skb);
+			secpath_reset(skb);
 			kmem_cache_free(skbuff_head_cache, skb);
 		} else {
 			__kfree_skb(skb);
@@ -4663,6 +4664,7 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	skb->encapsulation = 0;
 	skb_shinfo(skb)->gso_type = 0;
 	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
+	secpath_reset(skb);
 
 	napi->skb = skb;
 }
-- 
1.9.1
