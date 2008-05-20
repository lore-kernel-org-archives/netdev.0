From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Use the correct ip_local_out function
Date: Tue, 20 May 2008 17:25:11 +0800
Message-ID: <20080520092511.GA9005@gondor.apana.org.au>
References: <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl> <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl> <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51471 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764053AbYETJZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 05:25:16 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 10:19:57AM +0200, Marco Berizzi wrote:
> 
> I hope this helps.

OK found the problem, it was my fault after all :)

Dave, this patch needs to go into stable too.

[IPSEC]: Use the correct ip_local_out function

Because the IPsec output function xfrm_output_resume does its
own dst_output call it should always call __ip_local_output
instead of ip_local_output as the latter may invoke dst_output
directly.  Otherwise the return values from nf_hook and dst_output
may clash as they both use the value 1 but for different purposes.

When that clash occurs this can cause a packet to be used after
it has been freed which usually leads to a crash.  Because the
offending value is only returned from dst_output with qdiscs
such as HTB, this bug is normally not visible.

Thanks to Marco Berizzi for his perseverance in tracking this
down.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92f90ae..df41026 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -160,7 +160,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
-	.local_out =		ip_local_out,
+	.local_out =		__ip_local_out,
 	.entry_size =		sizeof(struct rtable),
 	.entries =		ATOMIC_INIT(0),
 };
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 12bba08..849b78a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -109,7 +109,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.negative_advice	=	ip6_negative_advice,
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
-	.local_out		=	ip6_local_out,
+	.local_out		=	__ip6_local_out,
 	.entry_size		=	sizeof(struct rt6_info),
 	.entries		=	ATOMIC_INIT(0),
 };
