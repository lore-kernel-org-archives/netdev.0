From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: router reachability probing
Date: Tue, 10 Dec 2013 21:51:01 +0100
Message-ID: <20131210205101.GA25505@order.stressinduktion.org>
References: <ce8e9118b640b938048aaf18b59e998d46ab400e.1386692051.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46302 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab3LJUvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 15:51:03 -0500
Content-Disposition: inline
In-Reply-To: <ce8e9118b640b938048aaf18b59e998d46ab400e.1386692051.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 05:15:44PM +0100, Jiri Benc wrote:
> RFC 4191 states in 3.5:
> 
>    When a host avoids using any non-reachable router X and instead sends
>    a data packet to another router Y, and the host would have used
>    router X if router X were reachable, then the host SHOULD probe each
>    such router X's reachability by sending a single Neighbor
>    Solicitation to that router's address.  A host MUST NOT probe a
>    router's reachability in the absence of useful traffic that the host
>    would have sent to the router if it were reachable.  In any case,
>    these probes MUST be rate-limited to no more than one per minute per
>    router.
> 
> Currently, when the neighbour corresponding to a router falls into
> NUD_FAILED, it's never considered again. Introduce a new rt6_nud_state
> value, RT6_NUD_FAIL_PROBE, which suggests the route should not be used but
> should be probed with a single NS. The probe is ratelimited by the existing
> code. To better distinguish meanings of the failure values, rename
> RT6_NUD_FAIL_SOFT to RT6_NUD_FAIL_DO_RR.
> 
> We also need to accept NAs when in NUD_FAILED state.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> I admit I'm not much sure about the removal of the NUD_FAILED check in
> ndisc_recv_na. I can't find anything in RFC 4861 nor in RFC 4191 which would
> prohibit taking the neighbor entry out of failed state if a NA is received.
> I also cannot find any place where such change would cause problems in the
> kernel, but I may have easily overlooked something. Comments are welcome.
> ---
>  net/ipv6/ndisc.c |    3 ---
>  net/ipv6/route.c |   14 +++++++++-----
>  2 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 09a22f4f36c9..faf67efc4c99 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -918,9 +918,6 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  		u8 old_flags = neigh->flags;
>  		struct net *net = dev_net(dev);
>  
> -		if (neigh->nud_state & NUD_FAILED)
> -			goto out;
> -
>  		/*
>  		 * Don't update the neighbor cache entry on a proxy NA from
>  		 * ourselves because either the proxied node is off link or it

The reason is that we don't send a neighbour advertisment in FAILED state
and thus shouldn't accept one. RFC 4861 7.2.5. specifies that we should
not add a new entry to the neighbour discovery table just because of a
neighbour advertisment. Because NUD_FAILED is just an artifical state
to the linux kernel we should treat it like the entry is not existent.

The canonical way would be to place this neighbor in the NUD_PROBE state
in rt6_probe.

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ddb9d41c8eea..147c39f7f70d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -66,8 +66,9 @@
>  #endif
>  
>  enum rt6_nud_state {
> -	RT6_NUD_FAIL_HARD = -2,
> -	RT6_NUD_FAIL_SOFT = -1,
> +	RT6_NUD_FAIL_HARD = -3,
> +	RT6_NUD_FAIL_PROBE = -2,
> +	RT6_NUD_FAIL_DO_RR = -1,
>  	RT6_NUD_SUCCEED = 1
>  };
>  
> @@ -577,11 +578,13 @@ static inline enum rt6_nud_state rt6_check_neigh(struct rt6_info *rt)
>  #ifdef CONFIG_IPV6_ROUTER_PREF
>  		else if (!(neigh->nud_state & NUD_FAILED))
>  			ret = RT6_NUD_SUCCEED;
> +		else
> +			ret = RT6_NUD_FAIL_PROBE;
>  #endif

Nit:
We could now change the declaration of ret in rt6_check_neigh from
"enum rt6_nud_state ret = RT6_NUD_FAIL_HARD"
to
"enum rt6_nud_state ret;" as all cases are covered now.

Otherwise the patch is a nice improvment.

Thanks,

  Hannes
