From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] don't put multicasts with mc_ttl=0 on the wire
Date: Tue, 15 May 2007 14:40:55 -0700
Message-ID: <OF4C423F38.96094E7A-ON882572DC.00711F94-882572DC.00770F97@us.ibm.com>
References: <20070515195602.GK19036@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: arenaud@sgi.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45427 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbXEOVk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:40:58 -0400
In-Reply-To: <20070515195602.GK19036@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arthur,
        I assume you're making use of the hack mentioned in route.c:

 "... This hack is not just for fun, it allows vic, vat and friends to 
work.
They bind socket to loopback, set ttl to zero and expect that it will 
work."
        I don't know the details of the intent for this hack, but did you
test that it won't break them?
        A multicast application that relies on the (unicast) routing table
at all is broken IMHO, as is an app that sets the TTL to 0, but shouldn't
all ttl 0 packets about to be sent to the wire be dropped? Wouldn't that
be a better way to handle this case?

                                                +-DLS

netdev-owner@vger.kernel.org wrote on 05/15/2007 12:56:02 PM:

> A colleague of mine found that multicasts with a ttl of 0
> can be sent on the wire. This happens if the sender doesn't
> belong to the destination multicast group.
> 
> With the following the multicast ttl is respected whether
> or not the sender belongs to the destination multicast group.
> 
> Signed-off-by: Arthur Kepner <akepner@sgi.com>
> 
> ---
> 
>  net/ipv4/route.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index cb76e3c..bf25cf5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2249,8 +2249,7 @@ static inline int __mkroute_output(struct rtable 
**result,
>     }
>     if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
>        rth->rt_spec_dst = fl->fl4_src;
> -      if (flags & RTCF_LOCAL &&
> -          !(dev_out->flags & IFF_LOOPBACK)) {
> +      if (!(dev_out->flags & IFF_LOOPBACK)) {
>           rth->u.dst.output = ip_mc_output;
>           RT_CACHE_STAT_INC(out_slow_mc);
>        }
> 
> -- 
> Arthur
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

