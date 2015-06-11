From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 13:48:07 -0700
Message-ID: <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
	Eric Dumazet <edumazet@google.com>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org
To: Shaohua Li <shli@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f193.google.com ([209.85.223.193]:36001 "EHLO
	mail-ie0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbbFKUsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 16:48:10 -0400
Received: by ierx19 with SMTP id x19so5101042ier.3
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 13:48:09 -0700 (PDT)
In-Reply-To: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:
> We saw excessive memory compaction triggered by skb_page_frag_refill.
> This causes performance issues. Commit 5640f7685831e0 introduces the
> order-3 allocation to improve performance. But memory compaction has
> high overhead. The benefit of order-3 allocation can't compensate the
> overhead of memory compaction.
> 
> This patch makes the order-3 page allocation atomic. If there is no
> memory pressure and memory isn't fragmented, the alloction will still
> success, so we don't sacrifice the order-3 benefit here. If the atomic
> allocation fails, compaction will not be triggered and we will fallback
> to order-0 immediately.
> 
> The mellanox driver does similar thing, if this is accepted, we must fix
> the driver too.
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

This is not a specific networking issue, but mm one.

You really need to start a discussion with mm experts.

Your changelog does not exactly explains what _is_ the problem.

If the problem lies in mm layer, it might be time to fix it, instead of
work around the bug by never triggering it from this particular point,
which is a safe point where a process is willing to wait a bit.

Memory compaction is either working as intending, or not.

If we enabled it but never run it because it hurts, what is the point
enabling it ?
