From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Thu, 27 May 2010 21:54:40 +1000
Message-ID: <20100527115440.GA9952@gondor.apana.org.au>
References: <20100526102758.GA25914@gondor.apana.org.au> <20100526152019.GA11985@linux-mips.org> <20100526221601.GA3369@gondor.apana.org.au> <20100527102429.GA9017@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:34381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932464Ab0E0Lyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 07:54:50 -0400
Content-Disposition: inline
In-Reply-To: <20100527102429.GA9017@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 08:24:29PM +1000, Herbert Xu wrote:
> 
> Actually, this patch is still not quite right for the GSO case.
> Right now it's only adding the IP header size, not the full header
> size.
> 
> I need to think a bit more about this.

Let's do it the old way first, so that it at least works for the
common case.  I'll fix it properly later.

ipv6: Add GSO support on forwarding path

Currently we disallow GSO packets on the IPv6 forward path.
This patch fixes this.

Note that I discovered that our existing GSO MTU checks (e.g.,
IPv4 forwarding) are buggy in that they skip the check altogether, 
hen they really should be checking gso_size + header instead.

I have also been lazy here in that I haven't bothered to segment
the GSO packet by hand before generating an ICMP message.  Someone
should add that to be 100% correct.

Reported-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cd963f6..89425af 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -507,7 +507,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
