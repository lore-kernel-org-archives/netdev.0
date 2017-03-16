From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 22:39:09 -0700
Message-ID: <20170316053907.GA22917@ast-mbp.thefacebook.com>
References: <20170314151143.16231-1-edumazet@google.com>
 <20170315040657.GA29637@ast-mbp.thefacebook.com>
 <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170315230608.GA90318@ast-mbp.thefacebook.com>
 <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170316015618.GA12660@ast-mbp.thefacebook.com>
 <CANn89iJRPmQcShBiPwcK_jaAQZsQOOStg5TmY-=AmORKSNPiOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35874 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdCPFjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 01:39:15 -0400
Received: by mail-pf0-f193.google.com with SMTP id r137so703721pfr.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 22:39:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANn89iJRPmQcShBiPwcK_jaAQZsQOOStg5TmY-=AmORKSNPiOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 07:48:04PM -0700, Eric Dumazet wrote:
> On Wed, Mar 15, 2017 at 6:56 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Wed, Mar 15, 2017 at 06:07:16PM -0700, Eric Dumazet wrote:
> >> On Wed, 2017-03-15 at 16:06 -0700, Alexei Starovoitov wrote:
> >>
> >> > yes. and we have 'xdp_tx_full' counter for it that we monitor.
> >> > When tx ring and mtu are sized properly, we don't expect to see it
> >> > incrementing at all. This is something in our control. 'Our' means
> >> > humans that setup the environment.
> >> > 'cache empty' condition is something ephemeral. Packets will be dropped
> >> > and we won't have any tools to address it. These packets are real
> >> > people requests. Any drop needs to be categorized.
> >> > Like there is 'rx_fifo_errors' counter that mlx4 reports when
> >> > hw is dropping packets before they reach the driver. We see it
> >> > incrementing depending on the traffic pattern though overall Mpps
> >> > through the nic is not too high and this is something we
> >> > actively investigating too.
> >>
> >>
> >> This all looks nice, except that current mlx4 driver does not have a
> >> counter of failed allocations.
> >>
> >> You are asking me to keep some inexistent functionality.
> >>
> >> Look in David net tree :
> >>
> >> mlx4_en_refill_rx_buffers()
> >> ...
> >>    if (mlx4_en_prepare_rx_desc(...))
> >>       break;
> >>
> >>
> >> So in case of memory pressure, mlx4 stops working and not a single
> >> counter is incremented/reported.
> >
> > Not quite. That is exactly the case i'm asking to keep.
> > In case of memory pressure (like in the above case rx fifo
> > won't be replenished) and in case of hw receiving
> > faster than the driver can drain the rx ring,
> > the hw will increment 'rx_fifo_errors' counter.
> 
> In current mlx4 driver, if napi_get_frags() fails, no counter is incremented.
> 
> So you are describing quite a different behavior, where _cpu_ can not
> keep up and rx_fifo_errors is incremented.
> 
> But in case of _memory_ pressure (and normal traffic), rx_fifo_errors
> wont be incremented.

when there is no room in the rx fifo the hw will increment the counter.
That's the same as oom causing alloc fails and rx ring not being replenished.
When there is nothing free in rx ring to dma the packet to, the hw will
increment that counter.

> And even if xdp_prog 'decides' to return XDP_PASS, the fine packet
> will be dropped anyway.

yes. And no counter will be incremented when packet is dropped further
in the stack. So?
The discussion specifically about changing xdp rings behavior for xdp_tx case.

> > And that's what we monitor already and what I described in previous email.
> >
> >> Is it really what you want ?
> >
> > almost. see below.
> >
> >>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |   38 +++++++++++++----------------
> >>  1 file changed, 18 insertions(+), 20 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> index cc41f2f145541b469b52e7014659d5fdbb7dac68..e5ef8999087b52705faf083c94cde439aab9e2b7 100644
> >> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> @@ -793,10 +793,24 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >>                 if (xdp_prog) {
> >>                         struct xdp_buff xdp;
> >>                         struct page *npage;
> >> -                       dma_addr_t ndma, dma;
> >> +                       dma_addr_t dma;
> >>                         void *orig_data;
> >>                         u32 act;
> >>
> >> +                       /* Make sure we have one page ready to replace this one, per Alexei request */
> >
> > do you have to add snarky comments?
> 
> Is request a bad or offensive word ?
> 
> What would be the best way to say that you asked to move this code
> here, while in my opinion it was better where it was  ?

so in other words you're saying that you disagree with
all of my previous explanations of why the drop after xdp_tx is wrong?
And in other words you think it's fine to execute the program,
do map lookups, rewrites and at the last step drop the result
because the driver couldn't allocate to make the rx ring populated, right?
I can try to see why it would be reasonable if you provide the arguments.

> >
> >> +                       if (unlikely(!ring->page_cache.index)) {
> >> +                               npage = mlx4_alloc_page(priv, ring,
> >> +                                                       &ring->page_cache.buf[0].dma,
> >> +                                                       numa_mem_id(),
> >> +                                                       GFP_ATOMIC | __GFP_MEMALLOC);
> >> +                               if (!npage) {
> >> +                                       /* replace this by a new ring->rx_alloc_failed++
> >> +                                        */
> >> +                                       ring->xdp_drop++;
> >
> > counting it as 'xdp_drop' is incorrect.
> 
> I added a comment to make that very clear .
> 
> If you do not read the comment, what can I say ?

enough insults, please?
you're making it difficult to keep the discussion technical.

> So the comment is :
> 
>  replace this by a new ring->rx_alloc_failed++
> 
> This of course will require other changes in other files (folding
> stats at ethtool -S)
> that are irrelevant for the discussion we have right now.

doing ring->xdp_drop++ here is not correct. Hence it's a blocker
for the rest of the patch. Just because 99% of it is good,
it doesn't mean that we can regress this 1%.
The solution to add new counter is trivial, so it's not
clear to me what you're objecting to.

> I wont provide full patch without knowing exactly what you are requesting.
> 
> 
> > 'xdp_drop' should be incremented only when program actually doing it,
> > otherwise that's confusing to the user.
> > If you add new counter 'rx_alloc_failed' (as you implying above)
> > than it's similar to the existing state.
> > Before: for both hw receives too much and oom with rx fifo empty - we
> > will see 'rx_fifo_errors' counter.
> > After: most rx_fifo_erros would mean hw receive issues and oom will
> > be covered by this new counter.
> >
> > Another thought... if we do this 'replenish rx ring immediately'
> > why do it for xdp rings only? Let's do it for all rings?
> > the above 'if (unlikely(!ring->page_cache.index)) ..alloc_page'
> > can move before 'if (xdp_prog)' and simplify the rest?
> >
> 
> Because non XDP paths attempt to use the page pool first.
> 
> _if_ the oldest page in page pool can not be recycled, then we
> allocate a fresh page,
> from a special pool (order-X preallocations) that does not fit the
> page_cache order-0 model

I see. yeah. mlx4_en_complete_rx_desc->mlx4_replenish logic
cannot be hoisted before napi_get_frags().
I was hoping to avoid doing napi_get_frags and populating
skb when we drop the packet due to !mlx4_replenish.
Nevermind.

Concrete steps from this state of patch:
1. either do 'if (unlikely(!ring->page_cache.index)) ..alloc_page'
before the program runs and increment new 'rx_alloc_failed' counter.
Without new counter it's no good.

2. or keep xdp rings as it is today: process all packets, some
packets are going into xdp_tx, some xdp_pass.
The xdp_pass will do your mlx4_en_complete_rx_desc->mlx4_replenish
with potential drop. At the end of the loop call into
mlx4_en_remap_rx_buffers() which will do
if (!frags[0].page)
  mlx4_alloc_page()
mlx4_en_prepare_rx_desc()
alloc will be happening only for pages that went into xdp_tx.
If it's under memory pressure and cannot refill the hw will
see that rx fifo has no free descriptors and will increment
rx_fifo_errors and we have exactly the same situation as today.
And no new counter neccessary.
I think the concern here that rx fifo can become completely
empty and nothing will ever replenish it, hence I'm suggesting
to populate it during processing of tx completion in xdp rings,
since it runs on the same cpu and doesn't race.
This way xdp will still function even under severe memory
pressure and when memory is available again the rx fifo ring
will be filled in mlx4_en_remap_rx_buffers() without
any extra _oom callbacks.
Also doing allocs in mlx4_en_remap_rx_buffers() after the loop
gives opportunity to do batch allocations, so long term
I'd like to try 2 anyway, but 1 is fine too.

In 2 the new counter is not necessary, because rx_fifo_errors
will cover it (would be nice to add in the future for visibility).
For 1 the new counter is needed immediately, otherwise the
drops will be lost that are accounted today.

I think it's important to agree on the problem first.
While you think your current patch is perfect and not seeing
my arguments, it will be impossible to discuss the solution
without agreeing on the problem.
