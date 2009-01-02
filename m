From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] icmpv6fuzz creates bad paging request
Date: Fri, 2 Jan 2009 19:59:43 +1100
Message-ID: <20090102085943.GA25100@gondor.apana.org.au>
References: <20090101201304.GA6698@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, Yang Hongyang <yanghy@cn.fujitsu.com>
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:41473 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751304AbZABJAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 04:00:43 -0500
Content-Disposition: inline
In-Reply-To: <20090101201304.GA6698@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 01, 2009 at 08:13:04PM +0000, Eric Sesterhenn wrote:
> 
> running "icmpv6fuzz -r 2187" gives me the following oops with current -git

Thanks, this should fix it:

ipv6: Fix memory overrun in do_ipv6_setsockopt

The newly added IPV6_PKTINFO option uses the user-supplied length
without checking, thus overwriting kernel stack memory if a bogus
value is provided.

This patch fixes it by capping the size to that of struct in6_pktinfo.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index eeeaad2..0df4b10 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -399,15 +399,13 @@ sticky_done:
 	{
 		struct in6_pktinfo pkt;
 
-		if (optlen == 0)
-			goto e_inval;
-		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
+		if (optlen < sizeof(pkt))
 			goto e_inval;
 
-		if (copy_from_user(&pkt, optval, optlen)) {
-				retv = -EFAULT;
-				break;
-		}
+		retv = -EFAULT;
+		if (copy_from_user(&pkt, optval, sizeof(pkt)))
+			break;
+
 		if (sk->sk_bound_dev_if && pkt.ipi6_ifindex != sk->sk_bound_dev_if)
 			goto e_inval;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
