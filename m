From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 1/2] net: esp{4,6}: remove padlen from struct esp_data
Date: Fri, 18 Oct 2013 12:09:04 +0200
Message-ID: <1382090945-20860-2-git-send-email-mathias.krause@secunet.com>
References: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Cc: Mathias Krause <mathias.krause@secunet.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54006 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550Ab3JRKJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 06:09:18 -0400
In-Reply-To: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The padlen member of struct esp_data is always zero. Get rid of it.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
---
 include/net/esp.h |    3 ---
 net/ipv4/esp4.c   |    9 +--------
 net/ipv6/esp6.c   |    9 +--------
 3 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index 1356dda..706b740 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -6,9 +6,6 @@
 struct crypto_aead;
 
 struct esp_data {
-	/* 0..255 */
-	int padlen;
-
 	/* Confidentiality & Integrity */
 	struct crypto_aead *aead;
 };
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 109ee89..8b5386a 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -154,8 +154,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(skb->len + 2 + tfclen, blksize);
-	if (esp->padlen)
-		clen = ALIGN(clen, esp->padlen);
 	plen = clen - skb->len - tfclen;
 
 	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
@@ -461,7 +459,6 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
-	u32 align = max_t(u32, blksize, esp->padlen);
 	unsigned int net_adj;
 
 	switch (x->props.mode) {
@@ -477,7 +474,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 	}
 
 	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
-		 net_adj) & ~(align - 1)) + net_adj - 2;
+		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
 static void esp4_err(struct sk_buff *skb, u32 info)
@@ -659,8 +656,6 @@ static int esp_init_state(struct xfrm_state *x)
 
 	aead = esp->aead;
 
-	esp->padlen = 0;
-
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
@@ -683,8 +678,6 @@ static int esp_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	if (esp->padlen)
-		align = max_t(u32, align, esp->padlen);
 	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
 
 error:
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d3618a7..0073cd0 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -181,8 +181,6 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(skb->len + 2 + tfclen, blksize);
-	if (esp->padlen)
-		clen = ALIGN(clen, esp->padlen);
 	plen = clen - skb->len - tfclen;
 
 	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
@@ -416,7 +414,6 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
-	u32 align = max_t(u32, blksize, esp->padlen);
 	unsigned int net_adj;
 
 	if (x->props.mode != XFRM_MODE_TUNNEL)
@@ -425,7 +422,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 		net_adj = 0;
 
 	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
-		 net_adj) & ~(align - 1)) + net_adj - 2;
+		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -606,8 +603,6 @@ static int esp6_init_state(struct xfrm_state *x)
 
 	aead = esp->aead;
 
-	esp->padlen = 0;
-
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
@@ -626,8 +621,6 @@ static int esp6_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	if (esp->padlen)
-		align = max_t(u32, align, esp->padlen);
 	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
 
 error:
-- 
1.7.10.4
