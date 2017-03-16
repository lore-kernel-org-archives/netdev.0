From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 18:56:20 -0700
Message-ID: <20170316015618.GA12660@ast-mbp.thefacebook.com>
References: <20170314151143.16231-1-edumazet@google.com>
 <20170315040657.GA29637@ast-mbp.thefacebook.com>
 <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170315230608.GA90318@ast-mbp.thefacebook.com>
 <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36294 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbdCPB4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:56:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id r137so142117pfr.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:56:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 06:07:16PM -0700, Eric Dumazet wrote:
> On Wed, 2017-03-15 at 16:06 -0700, Alexei Starovoitov wrote:
> 
> > yes. and we have 'xdp_tx_full' counter for it that we monitor.
> > When tx ring and mtu are sized properly, we don't expect to see it
> > incrementing at all. This is something in our control. 'Our' means
> > humans that setup the environment.
> > 'cache empty' condition is something ephemeral. Packets will be dropped
> > and we won't have any tools to address it. These packets are real
> > people requests. Any drop needs to be categorized.
> > Like there is 'rx_fifo_errors' counter that mlx4 reports when
> > hw is dropping packets before they reach the driver. We see it
> > incrementing depending on the traffic pattern though overall Mpps
> > through the nic is not too high and this is something we
> > actively investigating too.
> 
> 
> This all looks nice, except that current mlx4 driver does not have a
> counter of failed allocations.
> 
> You are asking me to keep some inexistent functionality.
> 
> Look in David net tree :
> 
> mlx4_en_refill_rx_buffers()
> ...
>    if (mlx4_en_prepare_rx_desc(...))
>       break;
> 
> 
> So in case of memory pressure, mlx4 stops working and not a single
> counter is incremented/reported.

Not quite. That is exactly the case i'm asking to keep.
In case of memory pressure (like in the above case rx fifo
won't be replenished) and in case of hw receiving
faster than the driver can drain the rx ring,
the hw will increment 'rx_fifo_errors' counter.
And that's what we monitor already and what I described in previous email.

> Is it really what you want ?

almost. see below.

>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |   38 +++++++++++++----------------
>  1 file changed, 18 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index cc41f2f145541b469b52e7014659d5fdbb7dac68..e5ef8999087b52705faf083c94cde439aab9e2b7 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -793,10 +793,24 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                 if (xdp_prog) {
>                         struct xdp_buff xdp;
>                         struct page *npage;
> -                       dma_addr_t ndma, dma;
> +                       dma_addr_t dma;
>                         void *orig_data;
>                         u32 act;
>  
> +                       /* Make sure we have one page ready to replace this one, per Alexei request */

do you have to add snarky comments?

> +                       if (unlikely(!ring->page_cache.index)) {
> +                               npage = mlx4_alloc_page(priv, ring,
> +                                                       &ring->page_cache.buf[0].dma,
> +                                                       numa_mem_id(),
> +                                                       GFP_ATOMIC | __GFP_MEMALLOC);
> +                               if (!npage) {
> +                                       /* replace this by a new ring->rx_alloc_failed++
> +                                        */
> +                                       ring->xdp_drop++;

counting it as 'xdp_drop' is incorrect.
'xdp_drop' should be incremented only when program actually doing it,
otherwise that's confusing to the user.
If you add new counter 'rx_alloc_failed' (as you implying above)
than it's similar to the existing state.
Before: for both hw receives too much and oom with rx fifo empty - we
will see 'rx_fifo_errors' counter.
After: most rx_fifo_erros would mean hw receive issues and oom will
be covered by this new counter.

Another thought... if we do this 'replenish rx ring immediately'
why do it for xdp rings only? Let's do it for all rings?
the above 'if (unlikely(!ring->page_cache.index)) ..alloc_page'
can move before 'if (xdp_prog)' and simplify the rest?
