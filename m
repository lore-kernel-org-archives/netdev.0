From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Fix rcv mss estimate for LRO
Date: Thu, 31 Aug 2006 23:18:33 +1000
Message-ID: <20060831131833.GA1903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39442 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932204AbWHaNSc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 09:18:32 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

The Xen performance problem turned out to be something else altogether.
It was an incorrect rcv mss estimate which leads to delayed acks.  So
it's not a bug in Linux yet :) However, since we need this for LRO as
well, here's a patch for net-2.6.19.

[TCP]: Fix rcv mss estimate for LRO

By passing a Linux-generated TSO packet straight back into Linux, Xen
becomes our first LRO user :) Unfortunately, there is at least one spot
in our stack that needs to be changed to cope with this.

The receive MSS estimate is computed from the raw packet size.  This is
broken if the packet is GSO/LRO.  Fortunately the real MSS can be found
in gso_size so we simply need to use that if it is non-zero.

Real LRO NICs should of course set the gso_size field in future.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 104af5d..1fa1536 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -127,7 +127,7 @@ static void tcp_measure_rcv_mss(struct s
 	/* skb->len may jitter because of SACKs, even if peer
 	 * sends good full-sized frames.
 	 */
-	len = skb->len;
+	len = skb_shinfo(skb)->gso_size ?: skb->len;
 	if (len >= icsk->icsk_ack.rcv_mss) {
 		icsk->icsk_ack.rcv_mss = len;
 	} else {
