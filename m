From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Thu, 19 Jan 2017 21:39:58 +0200
Message-ID: <CALzJLG8womR8bW85s0njkwNiarSHCkhbzWmgZWnBbq41UZ9iMw@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com> <1484853949.16328.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:35427 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754317AbdASTs7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 14:48:59 -0500
Received: by mail-yb0-f193.google.com with SMTP id p3so4223411yba.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 11:48:59 -0800 (PST)
In-Reply-To: <1484853949.16328.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 9:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-01-19 at 21:14 +0200, Saeed Mahameed wrote:
>> On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > A driver using dev_alloc_page() must not reuse a page allocated from
>> > emergency memory reserve.
>> >
>> > Otherwise all packets using this page will be immediately dropped,
>> > unless for very specific sockets having SOCK_MEMALLOC bit set.
>> >
>> > This issue might be hard to debug, because only a fraction of received
>> > packets would be dropped.
>>
>> Hi Eric,
>>
>> When you say reuse, you mean point to the same page from several SKBs ?
>>
>> Because in our page cache implementation we don't reuse pages that
>> already passed to the stack,
>> we just keep them in the page cache until the ref count drop back to
>> one, so we recycle them (i,e they will be re-used only when no one
>> else is using them).
>
> Look at other page_is_pfmemalloc() calls in other network drivers.
>
> The point is :
>
> We do not want to reuse a page that was initially allocated from
> emergency reserve.
>
> Chances are high that the packet will be simply dropped.
>
> If your cache is not refilled with such problematic pages,
> future dev_page_alloc() will likely give you sane pages, after stress
> has ended.
>
> By definition, emergency reserves are small, we do not want to keep
> pages from the reserve in another cache, depleting the reserve for too
> long.

Got it, Thanks for the explanation, I got confused since the term "reuse"
can also imply "reuse same page for another RX packet", I guess the
correct term for
mlx5 page cache is "recycle".

>
> dev_alloc_page() in mlx5 was introduced in commit
> bc77b240b3c57236cdcc08d64ca390655d3a16ff
> ("net/mlx5e: Add fragmented memory support for RX multi packet WQE")
>
> Maybe my Fixes: tag was slightly wrong.
>

No, i think you got it right in first place, you are fixing the RX
cache to not keep hold on such pages.
before the RX cache we didn't have this issue.

>>
>> on mlx5e rx re-post to the HW buffer we will call
>> mlx5e_page_alloc_mapped->mlx5e_rx_cache_get, and  mlx5e_rx_cache_get
>> will only return a page that is already freed by all stack users,
>> otherwise it will allocated a brand new one.
>>
>> a page form mlx5e_page_cache can have one of 2 states
>> 1. passed to the stack (not free)
>> 2. free (already used and freed by the stack)
>>
>> a non free page will never get reused for another SKB.
>
>
> Of course.
>
>>
>> this is true for both mlx5 rx modes (striding and non-striding)
>>
>> but in the striding mode regardless of page cache, small packets can
>> always fit in one page and this page can get pointed to by several
>> SKBs - should we be concerned about this case ?
>>
>> Anyway, if you meant by this patch to avoid keeping such special pages
>> in the mlx5 page cache,
>> then it looks very good to me.
>>
>> Thanks,
>> Saeed.
>>
>>
>> >
>> > Fixes: 4415a0319f92 ("net/mlx5e: Implement RX mapped page cache for page recycle")
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> > Cc: Tariq Toukan <tariqt@mellanox.com>
>> > Cc: Saeed Mahameed <saeedm@mellanox.com>
>> > ---
>> >  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    3 +++
>> >  1 file changed, 3 insertions(+)
>> >
>> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> > index 0e2fb3ed1790900ccdc0bbbef8bc5c33267df092..ce46409bde2736ea4d1246ca97855098f052f271 100644
>> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> > @@ -193,6 +193,9 @@ static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
>> >                 return false;
>> >         }
>> >
>> > +       if (unlikely(page_is_pfmemalloc(dma_info->page)))
>> > +               return false;
>> > +
>> >         cache->page_cache[cache->tail] = *dma_info;
>> >         cache->tail = tail_next;
>> >         return true;
>> >
>> >
>
>
