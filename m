From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bisected] ICMP fragmentation needed ignored / PMTU discovery
 broken since 3.19-rc7
Date: Tue, 28 Apr 2015 11:43:15 +0800
Message-ID: <20150428034314.GA30299@gondor.apana.org.au>
References: <1508242.C2rIQlqbSL@thunder>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lw@cn.fujitsu.com, davem@davemloft.net
To: "Gerd v. Egidy" <gerd.von.egidy@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59845 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbD1DnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:43:21 -0400
Content-Disposition: inline
In-Reply-To: <1508242.C2rIQlqbSL@thunder>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerd v. Egidy <gerd.von.egidy@intra2net.com> wrote:
> 
> my colleagues recently reported that they had spurious problems connecting
> to a specific server via ssh. Investigation showed that the kernel completely 
> ignored the ICMP dest. unreachable / fragmentation needed packets in this case:

This patch might help:

---8<---
Subject: route: Use ipv4_mtu instead of raw rt_pmtu

The commit 3cdaa5be9e81a914e633a6be7b7d2ef75b528562 ("ipv4: Don't
increase PMTU with Datagram Too Big message") broke PMTU in cases
where the rt_pmtu value has expired but is smaller than the new
PMTU value.

This obsolete rt_pmtu then prevents the new PMTU value from being
installed.

Fixes: 3cdaa5be9e81 ("ipv4: Don't increase PMTU with Datagram Too Big message")
Reported-by: Gerd v. Egidy <gerd.von.egidy@intra2net.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a78540f..bff62fc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -962,10 +962,7 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 	if (dst_metric_locked(dst, RTAX_MTU))
 		return;
 
-	if (dst->dev->mtu < mtu)
-		return;
-
-	if (rt->rt_pmtu && rt->rt_pmtu < mtu)
+	if (ipv4_mtu(dst) < mtu)
 		return;
 
 	if (mtu < ip_rt_min_pmtu)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
