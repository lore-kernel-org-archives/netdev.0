From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Sat, 24 Jun 2006 09:38:40 +1000
Message-ID: <20060623233840.GA6258@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au> <20060622081400.GC22671@gondor.apana.org.au> <1151091230.6498.4.camel@rh4> <1151097976.6498.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43529 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751673AbWFWXjJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 19:39:09 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151097976.6498.7.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 02:26:16PM -0700, Michael Chan wrote:
>
> This patch is more correct.  Please ignore the previous one.
> 
> [NET]: Fix CHECKSUM_HW GSO problems.
> 
> Fix checksum problems in the GSO code path for CHECKSUM_HW packets.
> 
> The ipv4 TCP pseudo header checksum has to be adjusted for GSO
> segmented packets.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch.  Obviously the only CHECKSUM_HW I tested was loop :)
Looking at this again it seems that we can optimise it further so
how about this?

[NET]: Fix CHECKSUM_HW GSO problems.

Fix checksum problems in the GSO code path for CHECKSUM_HW packets.

The ipv4 TCP pseudo header checksum has to be adjusted for GSO
segmented packets.

The adjustment is needed because the length field in the pseudo-header
changes.  However, because we have the inequality oldlen > newlen, we
know that delta = (u16)~oldlen + newlen is still a 16-bit quantity.
This also means that htonl(delta) + th->check still fits in 32 bits.
Therefore we don't have to use csum_add on this operations.

This is based on a patch by Michael Chan <mchan@broadcom.com>.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0e029c4..10f1a8c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2166,7 +2166,7 @@ struct sk_buff *tcp_tso_segment(struct s
 	if (!pskb_may_pull(skb, thlen))
 		goto out;
 
-	oldlen = ~htonl(skb->len);
+	oldlen = (u16)~skb->len;
 	__skb_pull(skb, thlen);
 
 	segs = skb_segment(skb, sg);
@@ -2174,7 +2174,7 @@ struct sk_buff *tcp_tso_segment(struct s
 		goto out;
 
 	len = skb_shinfo(skb)->gso_size;
-	delta = csum_add(oldlen, htonl(thlen + len));
+	delta = htonl(oldlen + (thlen + len));
 
 	skb = segs;
 	th = skb->h.th;
@@ -2183,10 +2183,10 @@ struct sk_buff *tcp_tso_segment(struct s
 	do {
 		th->fin = th->psh = 0;
 
-		if (skb->ip_summed == CHECKSUM_NONE) {
-			th->check = csum_fold(csum_partial(
-				skb->h.raw, thlen, csum_add(skb->csum, delta)));
-		}
+		th->check = ~csum_fold(th->check + delta);
+		if (skb->ip_summed != CHECKSUM_HW)
+			th->check = csum_fold(csum_partial(skb->h.raw, thlen,
+							   skb->csum));
 
 		seq += len;
 		skb = skb->next;
@@ -2196,11 +2196,11 @@ struct sk_buff *tcp_tso_segment(struct s
 		th->cwr = 0;
 	} while (skb->next);
 
-	if (skb->ip_summed == CHECKSUM_NONE) {
-		delta = csum_add(oldlen, htonl(skb->tail - skb->h.raw));
-		th->check = csum_fold(csum_partial(
-			skb->h.raw, thlen, csum_add(skb->csum, delta)));
-	}
+	delta = htonl(oldlen + (skb->tail - skb->h.raw));
+	th->check = ~csum_fold(th->check + delta);
+	if (skb->ip_summed != CHECKSUM_HW)
+		th->check = csum_fold(csum_partial(skb->h.raw, thlen,
+						   skb->csum));
 
 out:
 	return segs;
