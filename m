From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix potential use after free
Date: Sat, 27 Dec 2008 09:44:01 +1100
Message-ID: <20081226224401.GA22329@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35575 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751919AbYLZWoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 17:44:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

While implementing GRO support for page frags, I found a little bug
in the original code.

gro: Fix potential use after free

The initial skb may have been freed after napi_gro_complete in
napi_gro_receive if it was merged into an existing packet.  Thus
we cannot check same_flow (which indicates whether it was merged)
after calling napi_gro_complete.

This patch fixes this by saving the same_flow status before the
call to napi_gro_complete.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index daca72e..9d60941 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2390,6 +2390,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	__be16 type = skb->protocol;
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
 	int count = 0;
+	int same_flow;
 	int mac_len;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
@@ -2425,6 +2426,8 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (&ptype->list == head)
 		goto normal;
 
+	same_flow = NAPI_GRO_CB(skb)->same_flow;
+
 	if (pp) {
 		struct sk_buff *nskb = *pp;
 
@@ -2434,7 +2437,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		count--;
 	}
 
-	if (NAPI_GRO_CB(skb)->same_flow)
+	if (same_flow)
 		goto ok;
 
 	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS) {

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
