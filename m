From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: esp4: Use high-order sequence number bits for IV generation
Date: Wed, 13 May 2015 15:26:10 +0800
Message-ID: <20150513072610.GA27424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44345 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075AbbEMH0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:26:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed we were only using the low-order bits for IV generation
when ESN is enabled.  This is very bad because it means that the
IV can repeat.  We must use the full 64 bits.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 421a80b..30b544f 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -256,7 +256,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, assoclen);
 	aead_givcrypt_set_giv(req, esph->enc_data,
-			      XFRM_SKB_CB(skb)->seq.output.low);
+			      XFRM_SKB_CB(skb)->seq.output.low +
+			      ((u64)XFRM_SKB_CB(skb)->seq.output.hi << 32));
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
