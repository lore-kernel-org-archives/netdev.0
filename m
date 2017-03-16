From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 18:10:55 -0700
Message-ID: <1489626655.28631.199.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170314151143.16231-1-edumazet@google.com>
         <20170315040657.GA29637@ast-mbp.thefacebook.com>
         <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170315230608.GA90318@ast-mbp.thefacebook.com>
         <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33654 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdCPBLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:11:30 -0400
Received: by mail-pg0-f67.google.com with SMTP id y17so4022908pgh.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:10:57 -0700 (PDT)
In-Reply-To: <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 18:07 -0700, Eric Dumazet wrote:
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
> 
> So I guess your supervision was not really tested.
> 
> Just to show you what you are asking, here is a diff against latest
> version.
> 
> You want to make sure a fresh page is there before calling XDP program.
> 
> Is it really what you want ?
> 
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
> +                       if (unlikely(!ring->page_cache.index)) {
> +                               npage = mlx4_alloc_page(priv, ring,
> +                                                       &ring->page_cache.buf[0].dma,
> +                                                       numa_mem_id(),
> +                                                       GFP_ATOMIC | __GFP_MEMALLOC);
> +                               if (!npage) {
> +                                       /* replace this by a new ring->rx_alloc_failed++
> +                                        */
> +                                       ring->xdp_drop++;
> +                                       goto next;
> +                               }
> +                               ring->page_cache.buf[0].page = npage;

Plus a missing :
				ring->page_cache.index = 1;

> +                       }
>                         dma = frags[0].dma + frags[0].page_offset;
>                         dma_sync_single_for_cpu(priv->ddev, dma,
>                                                 priv->frag_info[0].frag_size,
> @@ -820,29 +834,13 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                         case XDP_PASS:
>                                 break;
>                         case XDP_TX:
> -                               /* Make sure we have one page ready to replace this one */
> -                               npage = NULL;
> -                               if (!ring->page_cache.index) {
> -                                       npage = mlx4_alloc_page(priv, ring,
> -                                                               &ndma, numa_mem_id(),
> -                                                               GFP_ATOMIC | __GFP_MEMALLOC);
> -                                       if (!npage) {
> -                                               ring->xdp_drop++;
> -                                               goto next;
> -                                       }
> -                               }
>                                 if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
>                                                         length, cq->ring,
>                                                         &doorbell_pending))) {
> -                                       if (ring->page_cache.index) {
> -                                               u32 idx = --ring->page_cache.index;
> +                                       u32 idx = --ring->page_cache.index;
>  
> -                                               frags[0].page = ring->page_cache.buf[idx].page;
> -                                               frags[0].dma = ring->page_cache.buf[idx].dma;
> -                                       } else {
> -                                               frags[0].page = npage;
> -                                               frags[0].dma = ndma;
> -                                       }
> +                                       frags[0].page = ring->page_cache.buf[idx].page;
> +                                       frags[0].dma = ring->page_cache.buf[idx].dma;
>                                         frags[0].page_offset = XDP_PACKET_HEADROOM;
>                                         goto next;
>                                 }
> 
> 
> 
> 
