From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/14] gro: Only use skb_gro_header for completely non-linear packets
Date: Wed, 27 May 2009 14:50:23 +1000
Message-ID: <E1M9B5r-0001RY-B3@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49806 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752274AbZE0FHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Only use skb_gro_header for completely non-linear packets

Currently skb_gro_header is used for packets which put the hardware
header in skb->data with the rest in frags.  Since the drivers that
need this optimisation all provide completely non-linear packets,
we can gain extra optimisations by only performing the frag0
optimisation for completely non-linear packets.

In particular, we can simply test frag0 (instead of skb_headlen)
to see whether the optimisation is in force.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |   11 ++++++-----
 net/core/dev.c            |    3 ++-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fcb1cc9..38678bc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1135,22 +1135,23 @@ static inline void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
 
 	hlen += offset;
 	if (!NAPI_GRO_CB(skb)->frag0 ||
-	    unlikely(skb_shinfo(skb)->frags[0].size + skb_headlen(skb) < hlen))
+	    unlikely(skb_shinfo(skb)->frags[0].size < hlen)) {
+		NAPI_GRO_CB(skb)->frag0 = NULL;
 		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
+	}
 
 	return NAPI_GRO_CB(skb)->frag0 + offset;
 }
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)
 {
-	return skb_headlen(skb) ? skb_mac_header(skb) :
-	       NAPI_GRO_CB(skb)->frag0;
+	return NAPI_GRO_CB(skb)->frag0 ?: skb_mac_header(skb);
 }
 
 static inline void *skb_gro_network_header(struct sk_buff *skb)
 {
-	return skb_headlen(skb) ? skb_network_header(skb) :
-	       NAPI_GRO_CB(skb)->frag0 + skb_network_offset(skb);
+	return (NAPI_GRO_CB(skb)->frag0 ?: skb->data) +
+	       skb_network_offset(skb);
 }
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 9b4c8da..07ad237 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2507,7 +2507,8 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->data_offset = 0;
 	NAPI_GRO_CB(skb)->frag0 = NULL;
 
-	if (!skb_headlen(skb) && !PageHighMem(skb_shinfo(skb)->frags[0].page))
+	if (skb->mac_header == skb->tail &&
+	    !PageHighMem(skb_shinfo(skb)->frags[0].page))
 		NAPI_GRO_CB(skb)->frag0 =
 			page_address(skb_shinfo(skb)->frags[0].page) +
 			skb_shinfo(skb)->frags[0].page_offset;
