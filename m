From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Only reset frag0 when skb can be pulled
Date: Wed, 27 Jul 2011 21:10:08 +0800
Message-ID: <20110727131008.GA28825@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49550 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab1G0NKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 09:10:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Only reset frag0 when skb can be pulled

Currently skb_gro_header_slow unconditionally resets frag0 and
frag0_len.  However, when we can't pull on the skb this leaves
the GRO fields in an inconsistent state.

This patch fixes this by only resetting those fields after the
pskb_may_pull test.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ea6f4aa..a692a7c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1679,9 +1679,12 @@ static inline int skb_gro_header_hard(struct sk_buff *skb, unsigned int hlen)
 static inline void *skb_gro_header_slow(struct sk_buff *skb, unsigned int hlen,
 					unsigned int offset)
 {
+	if (!pskb_may_pull(skb, hlen))
+		return NULL;
+
 	NAPI_GRO_CB(skb)->frag0 = NULL;
 	NAPI_GRO_CB(skb)->frag0_len = 0;
-	return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
+	return skb->data + offset;
 }
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
