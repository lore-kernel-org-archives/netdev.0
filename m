From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] gro: Open-code memcpy in napi_fraginfo_skb
Date: Fri, 30 Jan 2009 11:19:52 +1100
Message-ID: <E1LSh6u-0000Od-Bv@gondolin.me.apana.org.au>
References: <20090130001849.GA1272@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37718 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756078AbZA3AT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Open-code memcpy in napi_fraginfo_skb

This patch optimises napi_fraginfo_skb to only copy the bits
necessary.  We also open-code the memcpy so that the alignment
information is always available to gcc.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3742397..d55f725 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2541,6 +2541,8 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
 	struct ethhdr *eth;
+	skb_frag_t *frag;
+	int i;
 
 	napi->skb = NULL;
 
@@ -2553,8 +2555,14 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	}
 
 	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
+	frag = &info->frags[info->nr_frags - 1];
+
+	for (i = skb_shinfo(skb)->nr_frags; i < info->nr_frags; i++) {
+		skb_fill_page_desc(skb, i, frag->page, frag->page_offset,
+				   frag->size);
+		frag++;
+	}
 	skb_shinfo(skb)->nr_frags = info->nr_frags;
-	memcpy(skb_shinfo(skb)->frags, info->frags, sizeof(info->frags));
 
 	skb->data_len = info->len;
 	skb->len += info->len;
