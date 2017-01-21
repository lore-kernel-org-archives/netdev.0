From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Sat, 21 Jan 2017 10:09:35 -0800
Message-ID: <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com> <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33322 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751273AbdAUSKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 13:10:07 -0500
Received: by mail-qt0-f194.google.com with SMTP id n13so9738808qtc.0
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2017 10:09:36 -0800 (PST)
In-Reply-To: <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 11:14 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> A driver using dev_alloc_page() must not reuse a page allocated from
>> emergency memory reserve.
>>
>> Otherwise all packets using this page will be immediately dropped,
>> unless for very specific sockets having SOCK_MEMALLOC bit set.
>>
>> This issue might be hard to debug, because only a fraction of received
>> packets would be dropped.
>
> Hi Eric,
>
> When you say reuse, you mean point to the same page from several SKBs ?
>
> Because in our page cache implementation we don't reuse pages that
> already passed to the stack,
> we just keep them in the page cache until the ref count drop back to
> one, so we recycle them (i,e they will be re-used only when no one
> else is using them).
>
Saeed,

Speaking of the mlx page cache can we remove this or a least make it
optional to use. It is another example of complex functionality being
put into drivers that makes things like backports more complicated and
provide at best some marginal value. In the case of the mlx5e cache
code the results from pktgen really weren't very impressive in the
first place. Also, the cache suffers from HOL blocking where we can
block the whole cache due to an outstanding reference on just one page
(something that you wouldn't see in pktgen but is likely to happen in
real applications).

Thanks,
Tom

> on mlx5e rx re-post to the HW buffer we will call
> mlx5e_page_alloc_mapped->mlx5e_rx_cache_get, and  mlx5e_rx_cache_get
> will only return a page that is already freed by all stack users,
> otherwise it will allocated a brand new one.
>
> a page form mlx5e_page_cache can have one of 2 states
> 1. passed to the stack (not free)
> 2. free (already used and freed by the stack)
>
> a non free page will never get reused for another SKB.
>
> this is true for both mlx5 rx modes (striding and non-striding)
>
> but in the striding mode regardless of page cache, small packets can
> always fit in one page and this page can get pointed to by several
> SKBs - should we be concerned about this case ?
>
> Anyway, if you meant by this patch to avoid keeping such special pages
> in the mlx5 page cache,
> then it looks very good to me.
>
> Thanks,
> Saeed.
>
>
>>
>> Fixes: 4415a0319f92 ("net/mlx5e: Implement RX mapped page cache for page recycle")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Tariq Toukan <tariqt@mellanox.com>
>> Cc: Saeed Mahameed <saeedm@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> index 0e2fb3ed1790900ccdc0bbbef8bc5c33267df092..ce46409bde2736ea4d1246ca97855098f052f271 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>> @@ -193,6 +193,9 @@ static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
>>                 return false;
>>         }
>>
>> +       if (unlikely(page_is_pfmemalloc(dma_info->page)))
>> +               return false;
>> +
>>         cache->page_cache[cache->tail] = *dma_info;
>>         cache->tail = tail_next;
>>         return true;
>>
>>
