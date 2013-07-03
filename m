From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until next-hop
 is in neighbor cache
Date: Wed, 03 Jul 2013 22:21:19 +0400
Message-ID: <51D46B9F.6050400@cogentembedded.com>
References: <CA+PSOpyxWf2s_JscuBYfOAW9hVkSqqC1JwdRDQ4WtZrkneQf6A@mail.gmail.com> <20130703050007.GA11216@order.stressinduktion.org> <20130703181546.GC12615@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Pierre Emeriaud <petrus.lt@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:54282 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab3GCSVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 14:21:22 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so447224lab.30
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 11:21:19 -0700 (PDT)
In-Reply-To: <20130703181546.GC12615@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/03/2013 10:15 PM, Hannes Frederic Sowa wrote:

> I looked up the relevant RFCs and do think this is the proper fix. Could you
> give it a test?

> [PATCH net] ipv6: rt6_check_neigh should successfully verify neigh if no NUD information are available

> After the removal of rt->n we do not create a neighbour entry at route
> insertion time (rt6_bind_neighbour is gone). As long as no neighbour is
> created because of "useful traffic" we skip this routing entry because
> rt6_check_neigh cannot pick up a valid neighbour (neigh == NULL) and
> thus returns false.

> This change was introduced by commit
> 887c95cc1da53f66a5890fdeab13414613010097 ("ipv6: Complete neighbour
> entry removal from dst_entry.")

> To quote RFC4191:
> "If the host has no information about the router's reachability, then
> the host assumes the router is reachable."

> and also:
> "A host MUST NOT probe a router's reachability in the absence of useful
> traffic that the host would have sent to the router if it were reachable."

> So, just assume the router is reachable and let's rt6_probe do the
> rest. We don't need to create a neighbour on route insertion time.

> If we don't compile with CONFIG_IPV6_ROUTER_PREF (RFC4191 support)
> a neighbour is only valid if its nud_state is NUD_VALID. I did not find
> any references that we should probe the router on route insertion time
> via the other RFCs. So skip this route in that case.

> Reported-by: Pierre Emeriaud <petrus.lt@gmail.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   net/ipv6/route.c | 4 ++++
>   1 file changed, 4 insertions(+)

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ad0aa6b..450979d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -547,6 +547,10 @@ static inline bool rt6_check_neigh(struct rt6_info *rt)
>   			ret = true;
>   #endif
>   		read_unlock(&neigh->lock);
> +	} else {
> +#ifdef CONFIG_IPV6_ROUTER_PREF

    How about:

	} else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {

> +		ret = true;
> +#endif
>   	}

WBR, Sergei
