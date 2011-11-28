From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] route: set iif and oif information in flowi struct
Date: Tue, 29 Nov 2011 01:53:55 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1111290051240.2497@ja.ssi.bg>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com> <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ulrich Weber <ulrich.weber@sophos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41940 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378Ab1K1XxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 18:53:18 -0500
In-Reply-To: <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 28 Nov 2011, Ulrich Weber wrote:

> Outgoing packets have loopback interface as incoming interface.
> 
> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
> ---
>  net/ipv4/route.c        |    4 ++++
>  net/ipv4/xfrm4_policy.c |   19 +++++++++++++++++--
>  net/ipv6/fib6_rules.c   |   10 ++++++++--
>  net/ipv6/xfrm6_policy.c |   18 ++++++++++++++++--
>  4 files changed, 45 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index fb47c8f..1702ec0 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2744,6 +2744,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
>  				flp4->saddr = rth->rt_src;
>  			if (!flp4->daddr)
>  				flp4->daddr = rth->rt_dst;
> +			if (!flp4->flowi4_iif)
> +				flp4->flowi4_iif = net->loopback_dev->ifindex;
> +			if (!flp4->flowi4_oif)
> +				flp4->flowi4_oif = rth->rt_iif;

	May be setting flowi4_oif unconditionally here is more
correct because ip_route_output_slow fills flowi4_oif with
the selected oif, it can even change the provided original
oif in flowi4_oif. What about this?:

			flp4->flowi4_oif = rth->dst.dev->ifindex;

	OTOH, rt_iif has some complex semantic: original oif
or the selected oif. May be you prefer flowi4_oif to hold
the selected oif, right?

	I see one dangerous place that must be checked:
icmp_route_lookup. Before now __ip_route_output_key was
called after xfrm_decode_session_reverse with 0 in
flowi4_oif, i.e. no oif binding was used. But now when
decode_session sets flowi4_oif we will restrict the route
via this interface?

>  			return rth;
>  		}
>  		RT_CACHE_STAT_INC(out_hlist_search);

Regards

--
Julian Anastasov <ja@ssi.bg>
