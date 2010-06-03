From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 3 Jun 2010 15:01:08 -0700
Message-ID: <20100603150108.38215813.akpm@linux-foundation.org>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	<20100603130235.c372b38f.akpm@linux-foundation.org>
	<1275599603.2533.58.camel@edumazet-laptop>
	<1275601036.2533.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52745 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab0FCWBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 18:01:11 -0400
In-Reply-To: <1275601036.2533.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Jun 2010 23:37:16 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 03 juin 2010 __ 23:13 +0200, Eric Dumazet a __crit :
> 
> > MTU=9000 on a system with 4K pages... Oh well...
> > 
> > maybe net/ipv6/mcast.c should cap dev->mtu to PAGE_SIZE-128 or
> > something, so that order-0 allocations are done.
> > 
> > 
> 
> Something like this patch (completely untested) :
> 
> [PATCH] ipv6: avoid high order allocations
> 
> With mtu=9000, mld_newpack() use order-2 GFP_ATOMIC allocations, that
> are very unreliable, on machines where PAGE_SIZE=4K
> 
> Limit allocated skbs to be at most one page. (order-0 allocations)
> 

Maybe - I wouldn't know how desirable that is from the
imapct-on-efficiency POV.  But I think most failures I've seen are for
regular old tcpipv4.  Often with e1000, which does larger-than-needed
allocations for (iirc) weird alignment requirements.

> ---
>  net/ipv6/mcast.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 59f1881..3484794 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1356,7 +1356,10 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
>  		     IPV6_TLV_PADN, 0 };
>  
>  	/* we assume size > sizeof(ra) here */
> -	skb = sock_alloc_send_skb(sk, size + LL_ALLOCATED_SPACE(dev), 1, &err);
> +	size += LL_ALLOCATED_SPACE(dev);
> +	/* limit our allocations to order-0 page */
> +	size = min(size, SKB_MAX_ORDER(0, 0));
> +	skb = sock_alloc_send_skb(sk, size, 1, &err);
>  
>  	if (!skb)
>  		return NULL;

An alternative which retains any performance benefit from the order-2
allocation would be:

	p = alloc_pages(__GFP_NOWARN|..., 2);
	if (!p)
		p = alloc_pages(..., 0);

if you see what I mean.

This would also fix any retry/timeout-related stalls which people might
experience when the order-2 allocation fails, so it might make things
better in general.


