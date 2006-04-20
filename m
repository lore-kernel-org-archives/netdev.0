From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP]: Account skb overhead in tcp_fragment
Date: Thu, 20 Apr 2006 13:26:02 +1000
Message-ID: <20060420032602.GA21406@gondor.apana.org.au>
References: <20060420010111.GA20576@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50700 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751156AbWDTD0E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 23:26:04 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060420010111.GA20576@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 20, 2006 at 11:01:11AM +1000, herbert wrote:
> Hi Dave:
> 
> Since sk_stream_alloc_pskb takes an extra argument that accounts for
> paged data all we need to do to account sk_buff overhead correctly
> is to use that instead of sk_stream_alloc_skb.

Here is a better version that does not double-count the paged bits
that get moved across.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-fragment-charge-2.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 44df1db..a28ae59 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -533,6 +533,7 @@
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
 	int nsize, old_factor;
+	int nlen;
 	u16 flags;
 
 	BUG_ON(len > skb->len);
@@ -552,8 +553,10 @@
 	if (buff == NULL)
 		return -ENOMEM; /* We'll just try again later. */
 
-	buff->truesize = skb->len - len;
-	skb->truesize -= buff->truesize;
+	sk_charge_skb(sk, buff);
+	nlen = skb->len - len - nsize;
+	buff->truesize += nlen;
+	skb->truesize -= nlen;
 
 	/* Correct the sequence numbers. */
 	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;
@@ -1039,7 +1042,8 @@
 	if (unlikely(buff == NULL))
 		return -ENOMEM;
 
-	buff->truesize = nlen;
+	sk_charge_skb(sk, buff);
+	buff->truesize += nlen;
 	skb->truesize -= nlen;
 
 	/* Correct the sequence numbers. */

--ew6BAiZeqk4r7MaW--
