From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 1/4] net: allow > 0 order atomic page alloc
 in skb_page_frag_refill
Date: Wed, 8 Jan 2014 20:08:29 +0200
Message-ID: <20140108180829.GB18162@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Michael Dalton <mwdalton@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbaAHSIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 13:08:41 -0500
Content-Disposition: inline
In-Reply-To: <1389072355-20666-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 09:25:52PM -0800, Michael Dalton wrote:
> skb_page_frag_refill currently permits only order-0 page allocs
> unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
> higher-order page allocations whether or not GFP_WAIT is used. If
> memory cannot be allocated, the allocator will fall back to
> successively smaller page allocs (down to order-0 page allocs).
> 
> This change brings skb_page_frag_refill in line with the existing
> page allocation strategy employed by netdev_alloc_frag, which attempts
> higher-order page allocations whether or not GFP_WAIT is set, falling
> back to successively lower-order page allocations on failure. Part
> of migration of virtio-net to per-receive queue page frag allocators.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
>  net/core/sock.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5393b4b..a0d522a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1865,9 +1865,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
>  		put_page(pfrag->page);
>  	}
>  
> -	/* We restrict high order allocations to users that can afford to wait */
> -	order = (prio & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
> -
> +	order = SKB_FRAG_PAGE_ORDER;
>  	do {
>  		gfp_t gfp = prio;


Eric said we also need a patch to add __GFP_NORETRY, right?
Probably before this one in series.

> -- 
> 1.8.5.1
