From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Reset gso_segs if packet is dodgy
Date: Fri, 30 Jun 2006 12:00:44 +1000
Message-ID: <20060630020044.GA28317@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:35589 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1750724AbWF3CBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 22:01:30 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I forgot to verify gso_segs on packets from untrusted sources.  In fact
looking around it seems that gso_segs is used by exactly one driver outside
of the TCP stack.  In fact it also happens to be a virtual driver: s390/qeth.

Since the only other GSO user we have at the moment -- UFO, doesn't even set
gso_segs, I'd like to move it to skb->cb and get rid of this.  However, for
now let's simply reset it in tcp_tso_segment.

[TCP]: Reset gso_segs if packet is dodgy

I wasn't paranoid enough in verifying GSO information.  A bogus gso_segs
could upset drivers as much as a bogus header would.  Let's reset it in
the per-protocol gso_segment functions.

I didn't verify gso_size because that can be verified by the source of
the dodgy packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0336422..0bb0ac9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2166,13 +2166,19 @@ struct sk_buff *tcp_tso_segment(struct s
 	if (!pskb_may_pull(skb, thlen))
 		goto out;
 
-	segs = NULL;
-	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))
-		goto out;
-
 	oldlen = (u16)~skb->len;
 	__skb_pull(skb, thlen);
 
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int mss = skb_shinfo(skb)->gso_size;
+
+		skb_shinfo(skb)->gso_segs = (skb->len + mss - 1) / mss;
+
+		segs = NULL;
+		goto out;
+	}
+
 	segs = skb_segment(skb, features);
 	if (IS_ERR(segs))
 		goto out;
