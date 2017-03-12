From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Sun, 12 Mar 2017 17:49:42 +0200
Message-ID: <CALzJLG-0V=o95so59ua34uNV8Zp_imYZxP883eXnsPg38f1mfg@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
 <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com>
 <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
 <1489330636.28631.55.camel@edumazet-glaptop3.roam.corp.google.com> <1489332566.28631.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36137 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755675AbdCLPuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 11:50:04 -0400
Received: by mail-qk0-f193.google.com with SMTP id n141so34540812qke.3
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 08:50:03 -0700 (PDT)
In-Reply-To: <1489332566.28631.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 5:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2017-03-12 at 07:57 -0700, Eric Dumazet wrote:
>
>> Problem is XDP TX :
>>
>> I do not see any guarantee mlx4_en_recycle_tx_desc() runs while the NAPI
>> RX is owned by current cpu.
>>
>> Since TX completion is using a different NAPI, I really do not believe
>> we can avoid an atomic operation, like a spinlock, to protect the list
>> of pages ( ring->page_cache )
>
> A quick fix for net-next would be :
>

Hi Eric, Good catch.

I don't think we need to complicate with an expensive spinlock,
 we can simply fix this by not enabling interrupts on XDP TX CQ (not
arm this CQ at all).
and handle XDP TX CQ completion from the RX NAPI context, in a serial
(Atomic) manner before handling RX completions themselves.
This way locking is not required since all page cache handling is done
from the same context (RX NAPI).

This is how we do this in mlx5, and this is the best approach
(performance wise) since we dealy XDP TX CQ completions handling
until we really need the space they hold (On new RX packets).

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index aa074e57ce06fb2842fa1faabd156c3cd2fe10f5..e0b2ea8cefd6beef093c41bade199e3ec4f0291c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -137,13 +137,17 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
>         struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
>         struct mlx4_en_rx_alloc *frags = ring->rx_info +
>                                         (index << priv->log_rx_info);
> +
>         if (ring->page_cache.index > 0) {
> +               spin_lock(&ring->page_cache.lock);
> +
>                 /* XDP uses a single page per frame */
>                 if (!frags->page) {
>                         ring->page_cache.index--;
>                         frags->page = ring->page_cache.buf[ring->page_cache.index].page;
>                         frags->dma  = ring->page_cache.buf[ring->page_cache.index].dma;
>                 }
> +               spin_unlock(&ring->page_cache.lock);
>                 frags->page_offset = XDP_PACKET_HEADROOM;
>                 rx_desc->data[0].addr = cpu_to_be64(frags->dma +
>                                                     XDP_PACKET_HEADROOM);
> @@ -277,6 +281,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
>                 }
>         }
>
> +       spin_lock_init(&ring->page_cache.lock);
>         ring->prod = 0;
>         ring->cons = 0;
>         ring->size = size;
> @@ -419,10 +424,13 @@ bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
>
>         if (cache->index >= MLX4_EN_CACHE_SIZE)
>                 return false;
> -
> -       cache->buf[cache->index].page = frame->page;
> -       cache->buf[cache->index].dma = frame->dma;
> -       cache->index++;
> +       spin_lock(&cache->lock);
> +       if (cache->index < MLX4_EN_CACHE_SIZE) {
> +               cache->buf[cache->index].page = frame->page;
> +               cache->buf[cache->index].dma = frame->dma;
> +               cache->index++;
> +       }
> +       spin_unlock(&cache->lock);
>         return true;
>  }
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 39f401aa30474e61c0b0029463b23a829ec35fa3..090a08020d13d8e11cc163ac9fc6ac6affccc463 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -258,7 +258,8 @@ struct mlx4_en_rx_alloc {
>  #define MLX4_EN_CACHE_SIZE (2 * NAPI_POLL_WEIGHT)
>
>  struct mlx4_en_page_cache {
> -       u32 index;
> +       u32                     index;
> +       spinlock_t              lock;
>         struct {
>                 struct page     *page;
>                 dma_addr_t      dma;
>
>
