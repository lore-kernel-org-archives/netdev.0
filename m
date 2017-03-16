From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 19:48:04 -0700
Message-ID: <CANn89iJRPmQcShBiPwcK_jaAQZsQOOStg5TmY-=AmORKSNPiOA@mail.gmail.com>
References: <20170314151143.16231-1-edumazet@google.com> <20170315040657.GA29637@ast-mbp.thefacebook.com>
 <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170315230608.GA90318@ast-mbp.thefacebook.com> <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170316015618.GA12660@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:34837 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751431AbdCPCsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 22:48:12 -0400
Received: by mail-it0-f44.google.com with SMTP id m27so77649776iti.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 19:48:06 -0700 (PDT)
In-Reply-To: <20170316015618.GA12660@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 6:56 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Mar 15, 2017 at 06:07:16PM -0700, Eric Dumazet wrote:
>> On Wed, 2017-03-15 at 16:06 -0700, Alexei Starovoitov wrote:
>>
>> > yes. and we have 'xdp_tx_full' counter for it that we monitor.
>> > When tx ring and mtu are sized properly, we don't expect to see it
>> > incrementing at all. This is something in our control. 'Our' means
>> > humans that setup the environment.
>> > 'cache empty' condition is something ephemeral. Packets will be dropped
>> > and we won't have any tools to address it. These packets are real
>> > people requests. Any drop needs to be categorized.
>> > Like there is 'rx_fifo_errors' counter that mlx4 reports when
>> > hw is dropping packets before they reach the driver. We see it
>> > incrementing depending on the traffic pattern though overall Mpps
>> > through the nic is not too high and this is something we
>> > actively investigating too.
>>
>>
>> This all looks nice, except that current mlx4 driver does not have a
>> counter of failed allocations.
>>
>> You are asking me to keep some inexistent functionality.
>>
>> Look in David net tree :
>>
>> mlx4_en_refill_rx_buffers()
>> ...
>>    if (mlx4_en_prepare_rx_desc(...))
>>       break;
>>
>>
>> So in case of memory pressure, mlx4 stops working and not a single
>> counter is incremented/reported.
>
> Not quite. That is exactly the case i'm asking to keep.
> In case of memory pressure (like in the above case rx fifo
> won't be replenished) and in case of hw receiving
> faster than the driver can drain the rx ring,
> the hw will increment 'rx_fifo_errors' counter.

In current mlx4 driver, if napi_get_frags() fails, no counter is incremented.

So you are describing quite a different behavior, where _cpu_ can not
keep up and rx_fifo_errors is incremented.

But in case of _memory_ pressure (and normal traffic), rx_fifo_errors
wont be incremented.

And even if xdp_prog 'decides' to return XDP_PASS, the fine packet
will be dropped anyway.


> And that's what we monitor already and what I described in previous email.
>
>> Is it really what you want ?
>
> almost. see below.
>
>>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |   38 +++++++++++++----------------
>>  1 file changed, 18 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> index cc41f2f145541b469b52e7014659d5fdbb7dac68..e5ef8999087b52705faf083c94cde439aab9e2b7 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -793,10 +793,24 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>>                 if (xdp_prog) {
>>                         struct xdp_buff xdp;
>>                         struct page *npage;
>> -                       dma_addr_t ndma, dma;
>> +                       dma_addr_t dma;
>>                         void *orig_data;
>>                         u32 act;
>>
>> +                       /* Make sure we have one page ready to replace this one, per Alexei request */
>
> do you have to add snarky comments?

Is request a bad or offensive word ?

What would be the best way to say that you asked to move this code
here, while in my opinion it was better where it was  ?

>
>> +                       if (unlikely(!ring->page_cache.index)) {
>> +                               npage = mlx4_alloc_page(priv, ring,
>> +                                                       &ring->page_cache.buf[0].dma,
>> +                                                       numa_mem_id(),
>> +                                                       GFP_ATOMIC | __GFP_MEMALLOC);
>> +                               if (!npage) {
>> +                                       /* replace this by a new ring->rx_alloc_failed++
>> +                                        */
>> +                                       ring->xdp_drop++;
>
> counting it as 'xdp_drop' is incorrect.

I added a comment to make that very clear .

If you do not read the comment, what can I say ?

So the comment is :

 replace this by a new ring->rx_alloc_failed++

This of course will require other changes in other files (folding
stats at ethtool -S)
that are irrelevant for the discussion we have right now.

I wont provide full patch without knowing exactly what you are requesting.


> 'xdp_drop' should be incremented only when program actually doing it,
> otherwise that's confusing to the user.
> If you add new counter 'rx_alloc_failed' (as you implying above)
> than it's similar to the existing state.
> Before: for both hw receives too much and oom with rx fifo empty - we
> will see 'rx_fifo_errors' counter.
> After: most rx_fifo_erros would mean hw receive issues and oom will
> be covered by this new counter.
>
> Another thought... if we do this 'replenish rx ring immediately'
> why do it for xdp rings only? Let's do it for all rings?
> the above 'if (unlikely(!ring->page_cache.index)) ..alloc_page'
> can move before 'if (xdp_prog)' and simplify the rest?
>

Because non XDP paths attempt to use the page pool first.

_if_ the oldest page in page pool can not be recycled, then we
allocate a fresh page,
from a special pool (order-X preallocations) that does not fit the
page_cache order-0 model

Non XDP paths do not need to populate page_cache with one order-0
page, that would add extra useless code.
