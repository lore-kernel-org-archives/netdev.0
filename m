From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Add xfrm_input_state helper
Date: Tue, 11 Dec 2007 11:45:31 +0800
Message-ID: <20071211034531.GA10033@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1704 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751941AbXLKDpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 22:45:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This is the last patch we need before converting ESP over to
crypto_aead.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
[IPSEC]: Add xfrm_input_state helper

This patch adds the xfrm_input_state helper function which returns the
current xfrm state being processed on the input path given an sk_buff.
This is currently only used by xfrm_input but will be used by ESP upon
asynchronous resumption.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index fb154a6..c49fe0f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1302,4 +1302,9 @@ static inline void xfrm_states_delete(struct xfrm_state **states, int n)
 }
 #endif
 
+static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
+{
+	return skb->sp->xvec[skb->sp->len - 1];
+}
+
 #endif	/* _NET_XFRM_H */
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 8b2b1b5..8624cbd 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -109,7 +109,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	/* A negative encap_type indicates async resumption. */
 	if (encap_type < 0) {
 		async = 1;
-		x = skb->sp->xvec[skb->sp->len - 1];
+		x = xfrm_input_state(skb);
 		seq = XFRM_SKB_CB(skb)->seq;
 		goto resume;
 	}
