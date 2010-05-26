From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Thu, 27 May 2010 08:16:01 +1000
Message-ID: <20100526221601.GA3369@gondor.apana.org.au>
References: <20100526102758.GA25914@gondor.apana.org.au> <20100526152019.GA11985@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42776 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753915Ab0EZWQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 18:16:13 -0400
Content-Disposition: inline
In-Reply-To: <20100526152019.GA11985@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 04:20:19PM +0100, Ralf Baechle wrote:
> 
> I tested this on top of a 2.6.34 release kernel and asked the user
> experiencing the problem to re-test and the problem still persists.

OK, it looks like my patch doesn't work because the transport
header isn't set on the forwarding path.  Here's an updated patch:

ipv6: Add GSO support on forwarding path

Currently we disallow GSO packets on the IPv6 forward path.
This patch fixes this.

Note that I discovered that our existing GSO MTU checks (e.g.,
IPv4 forwarding) are buggy in that they skip the check altogether, 
hen they really should be checking gso_size instead.

I have also been lazy here in that I haven't bothered to segment
the GSO packet by hand before generating an ICMP message.  Someone
should add that to be 100% correct.

Reported-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7cdfb4d..6ec5238 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2117,6 +2117,13 @@ static inline int skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+static inline int skb_gso_len(const struct sk_buff *skb)
+{
+	return skb_is_gso(skb) ?
+	       skb_shinfo(skb)->gso_size +
+	       (skb->csum_start - skb_headroom(skb)) : skb->len;
+}
+
 static inline int skb_is_gso_v6(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cd963f6..8904767 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -507,7 +507,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-	if (skb->len > mtu) {
+	if (skb_gso_len(skb) > mtu) {
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
