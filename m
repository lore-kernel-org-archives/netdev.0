From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 15:53:04 -0700
Message-ID: <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
 clm@fb.com,  linux-mm@kvack.org, dbavatar@gmail.com, Eric Dumazet
 <edumazet@google.com>
To: Shaohua Li <shli@fb.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-11 at 15:27 -0700, Shaohua Li wrote:
> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.
> 
> This patch makes the order-3 page allocation atomic. If there is no memory
> pressure and memory isn't fragmented, the alloction will still success, so we
> don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> direct memory compaction will not be triggered, skb_page_frag_refill will
> fallback to order-0 immediately, hence the direct memory compaction overhead is
> avoided. In the allocation failure case, kswapd is waken up and doing
> compaction, so chances are allocation could success next time.
> 
> The mellanox driver does similar thing, if this is accepted, we must fix
> the driver too.
> 
> V2: make the changelog clearer
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  net/core/sock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 292f422..e9855a4 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
>  
>  	pfrag->offset = 0;
>  	if (SKB_FRAG_PAGE_ORDER) {
> -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
>  					  __GFP_NOWARN | __GFP_NORETRY,
>  					  SKB_FRAG_PAGE_ORDER);
>  		if (likely(pfrag->page)) {


OK, now what about alloc_skb_with_frags() ?

This should have same problem right ?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
