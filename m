From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/14] gro: Optimise length comparison in skb_gro_header
Date: Wed, 27 May 2009 14:50:27 +1000
Message-ID: <E1M9B5v-0001SU-M7@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37539 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752770AbZE0Eub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Optimise length comparison in skb_gro_header

By caching frag0_len, we can avoid checking both frag0 and the
length separately in skb_gro_header.  This helps as skb_gro_header
is called four times per packet which amounts to a few million
times at 10Gb/s.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    7 +++++--
 net/core/dev.c            |    5 ++++-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 38678bc..966c413 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1011,6 +1011,9 @@ struct napi_gro_cb {
 	/* Virtual address of skb_shinfo(skb)->frags[0].page + offset. */
 	void *frag0;
 
+	/* Length of frag0. */
+	unsigned int frag0_len;
+
 	/* This indicates where we are processing relative to skb->data. */
 	int data_offset;
 
@@ -1134,9 +1137,9 @@ static inline void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
 	unsigned int offset = skb_gro_offset(skb);
 
 	hlen += offset;
-	if (!NAPI_GRO_CB(skb)->frag0 ||
-	    unlikely(skb_shinfo(skb)->frags[0].size < hlen)) {
+	if (NAPI_GRO_CB(skb)->frag0_len < hlen) {
 		NAPI_GRO_CB(skb)->frag0 = NULL;
+		NAPI_GRO_CB(skb)->frag0_len = 0;
 		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 07ad237..e634c8a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2506,12 +2506,15 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 {
 	NAPI_GRO_CB(skb)->data_offset = 0;
 	NAPI_GRO_CB(skb)->frag0 = NULL;
+	NAPI_GRO_CB(skb)->frag0_len = 0;
 
 	if (skb->mac_header == skb->tail &&
-	    !PageHighMem(skb_shinfo(skb)->frags[0].page))
+	    !PageHighMem(skb_shinfo(skb)->frags[0].page)) {
 		NAPI_GRO_CB(skb)->frag0 =
 			page_address(skb_shinfo(skb)->frags[0].page) +
 			skb_shinfo(skb)->frags[0].page_offset;
+		NAPI_GRO_CB(skb)->frag0_len = skb_shinfo(skb)->frags[0].size;
+	}
 }
 EXPORT_SYMBOL(skb_gro_reset_offset);
 
