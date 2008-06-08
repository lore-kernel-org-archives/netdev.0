From: Willy Tarreau <w@1wt.eu>
Subject: Re: [patch 00/50] 2.6.25.6 -stable review
Date: Sun, 8 Jun 2008 14:36:01 +0200
Message-ID: <20080608123601.GB10491@1wt.eu>
References: <20080520.143238.87085088.davem@davemloft.net> <BAY103-DAV11AE409F40D0878FC3A259B2B60@phx.gbl> <20080607204325.GJ5609@1wt.eu> <BAY103-DAV7370611E1B3FEA8FD69B9B2B10@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1581 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbYFHMgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 08:36:19 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV7370611E1B3FEA8FD69B9B2B10@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 08, 2008 at 01:56:01PM +0200, Marco Berizzi wrote:
> Willy Tarreau wrote:
> 
> > On Sat, Jun 07, 2008 at 10:27:58PM +0200, Marco Berizzi wrote:
> >> David Miller wrote:
> >> 
> >> > From: Herbert Xu <herbert@gondor.apana.org.au>
> >> > Date: Tue, 20 May 2008 17:25:11 +0800
> >> > 
> >> >> On Wed, May 14, 2008 at 10:19:57AM +0200, Marco Berizzi wrote:
> >> >> > 
> >> >> > I hope this helps.
> >> >> 
> >> >> OK found the problem, it was my fault after all :)
> >> >> 
> >> >> Dave, this patch needs to go into stable too.
> >> >> 
> >> >> [IPSEC]: Use the correct ip_local_out function
> >> >> 
> >> >> Because the IPsec output function xfrm_output_resume does its
> >> >> own dst_output call it should always call __ip_local_output
> >> >> instead of ip_local_output as the latter may invoke dst_output
> >> >> directly.  Otherwise the return values from nf_hook and dst_output
> >> >> may clash as they both use the value 1 but for different purposes.
> >> >> 
> >> >> When that clash occurs this can cause a packet to be used after
> >> >> it has been freed which usually leads to a crash.  Because the
> >> >> offending value is only returned from dst_output with qdiscs
> >> >> such as HTB, this bug is normally not visible.
> >> >> 
> >> >> Thanks to Marco Berizzi for his perseverance in tracking this
> >> >> down.
> >> >> 
> >> >> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >> > 
> >> > Applied and queued to -stable, thanks!
> >> 
> >> Hi David,
> >> 
> >> I don't see this patch in Chris 2.6.25.6 -stable review message.
> > 
> > Is it already in mainline ?
> 
> yes, since 2008/05/20
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ac06e0306d0192a7a4d9ea1c9e06d355ce7e7d3

Indeed. Most likely it was simply lost somewhere in the e-mail chain.
Then best thing to do is to retransmit it for next batch of patches.
Chris, here's the fix in question.

Thanks,
Willy
--

>From 1ac06e0306d0192a7a4d9ea1c9e06d355ce7e7d3 Mon Sep 17 00:00:00 2001
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 May 2008 14:32:14 -0700
Subject: ipsec: Use the correct ip_local_out function

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
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    2 +-
 net/ipv6/route.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
index b7a4a87..48534c6 100644
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
-- 
1.5.3.8

