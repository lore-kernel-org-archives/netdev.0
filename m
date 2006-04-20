From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Account skb overhead in tcp_fragment
Date: Thu, 20 Apr 2006 11:01:11 +1000
Message-ID: <20060420010111.GA20576@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58889 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750703AbWDTBBO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 21:01:14 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Since sk_stream_alloc_pskb takes an extra argument that accounts for
paged data all we need to do to account sk_buff overhead correctly
is to use that instead of sk_stream_alloc_skb.

This patch does just that for both tcp_fragment and tso_fragment.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-fragment-charge.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 44df1db..fb40d32 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -548,12 +548,10 @@
 		return -ENOMEM;
 
 	/* Get a new skb... force flag on. */
-	buff = sk_stream_alloc_skb(sk, nsize, GFP_ATOMIC);
+	buff = sk_stream_alloc_pskb(sk, nsize, skb->len - len - nsize, GFP_ATOMIC);
 	if (buff == NULL)
 		return -ENOMEM; /* We'll just try again later. */
-
-	buff->truesize = skb->len - len;
-	skb->truesize -= buff->truesize;
+	sk_charge_skb(sk, buff);
 
 	/* Correct the sequence numbers. */
 	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;
@@ -1035,12 +1033,10 @@
 	if (skb->len != skb->data_len)
 		return tcp_fragment(sk, skb, len, mss_now);
 
-	buff = sk_stream_alloc_pskb(sk, 0, 0, GFP_ATOMIC);
+	buff = sk_stream_alloc_pskb(sk, 0, nlen, GFP_ATOMIC);
 	if (unlikely(buff == NULL))
 		return -ENOMEM;
-
-	buff->truesize = nlen;
-	skb->truesize -= nlen;
+	sk_charge_skb(sk, buff);
 
 	/* Correct the sequence numbers. */
 	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;

--VS++wcV0S1rZb1Fb--
