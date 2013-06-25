From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX path
Date: Tue, 25 Jun 2013 11:53:50 +0300
Message-ID: <CAJZOPZLHueS5X=PN-RP3bwGv1x8C2TUrSwevGHcy=hXjBqji-Q@mail.gmail.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	<1371757222-21412-2-git-send-email-amirv@mellanox.com>
	<1371763689.3252.419.camel@edumazet-glaptop>
	<51C6B602.20703@mellanox.com>
	<1372000676.3301.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:53214 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab3FYIxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 04:53:51 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so433882qae.6
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:53:50 -0700 (PDT)
In-Reply-To: <1372000676.3301.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> mlx4 exclusively uses order-2 allocations in RX path, which are
> likely to fail under memory pressure.
>
> We therefore drop frames more than needed.
>
> This patch tries order-3, order-2, order-1 and finally order-0
> allocations to keep good performance, yet allow allocations if/when
> memory gets fragmented.
>
> By using larger pages, and avoiding unnecessary get_page()/put_page()
> on compound pages, this patch improves performance as well, lowering
> false sharing on struct page.
>
> Also use GFP_KERNEL allocations in initialization path, as allocating 12
> MB (390 order-3 pages) can easily fail with GFP_ATOMIC.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |  169 ++++++++---------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   12 -
>  2 files changed, 95 insertions(+), 86 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 9c57581..76997b9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -43,40 +43,64 @@
>
>  #include "mlx4_en.h"
>
> +static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
> +                           struct mlx4_en_rx_alloc *page_alloc,
> +                           const struct mlx4_en_frag_info *frag_info,
> +                           gfp_t _gfp)
> +{
> +       int order;
> +       struct page *page;
> +       dma_addr_t dma;
> +
> +       for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
> +               gfp_t gfp = _gfp;
> +
> +               if (order)
> +                       gfp |= __GFP_COMP | __GFP_NOWARN;
> +               page = alloc_pages(gfp, order);
> +               if (likely(page))
> +                       break;
> +               if (--order < 0 ||
> +                   ((PAGE_SIZE << order) < frag_info->frag_size))
> +                       return -ENOMEM;
> +       }
> +       dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
> +                          PCI_DMA_FROMDEVICE);
> +       if (dma_mapping_error(priv->ddev, dma)) {
> +               put_page(page);
> +               return -ENOMEM;
> +       }
> +       page_alloc->size = PAGE_SIZE << order;
> +       page_alloc->page = page;
> +       page_alloc->dma = dma;
> +       page_alloc->offset = frag_info->frag_align;
> +       /* Not doing get_page() for each frag is a big win
> +        * on asymetric workloads.
> +        */
> +       atomic_set(&page->_count, page_alloc->size / frag_info->frag_stride);
> +       return 0;
> +}
> +
>  static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
>                                struct mlx4_en_rx_desc *rx_desc,
>                                struct mlx4_en_rx_alloc *frags,
> -                              struct mlx4_en_rx_alloc *ring_alloc)
> +                              struct mlx4_en_rx_alloc *ring_alloc,
> +                              gfp_t gfp)
>  {
>         struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
> -       struct mlx4_en_frag_info *frag_info;
> +       const struct mlx4_en_frag_info *frag_info;
>         struct page *page;
>         dma_addr_t dma;
>         int i;
>
>         for (i = 0; i < priv->num_frags; i++) {
>                 frag_info = &priv->frag_info[i];
> -               if (ring_alloc[i].offset == frag_info->last_offset) {
> -                       page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
> -                                       MLX4_EN_ALLOC_ORDER);
> -                       if (!page)
> -                               goto out;
> -                       dma = dma_map_page(priv->ddev, page, 0,
> -                               MLX4_EN_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
> -                       if (dma_mapping_error(priv->ddev, dma)) {
> -                               put_page(page);
> -                               goto out;
> -                       }
> -                       page_alloc[i].page = page;
> -                       page_alloc[i].dma = dma;
> -                       page_alloc[i].offset = frag_info->frag_align;
> -               } else {
> -                       page_alloc[i].page = ring_alloc[i].page;
> -                       get_page(ring_alloc[i].page);
> -                       page_alloc[i].dma = ring_alloc[i].dma;
> -                       page_alloc[i].offset = ring_alloc[i].offset +
> -                                               frag_info->frag_stride;
> -               }
> +               page_alloc[i] = ring_alloc[i];
> +               page_alloc[i].offset += frag_info->frag_stride;
> +               if (page_alloc[i].offset + frag_info->frag_stride <= ring_alloc[i].size)
> +                       continue;
> +               if (mlx4_alloc_pages(priv, &page_alloc[i], frag_info, gfp))
> +                       goto out;
>         }
>
>         for (i = 0; i < priv->num_frags; i++) {
> @@ -88,14 +112,16 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
>
>         return 0;
>
> -
>  out:
>         while (i--) {
>                 frag_info = &priv->frag_info[i];
> -               if (ring_alloc[i].offset == frag_info->last_offset)
> +               if (page_alloc[i].page != ring_alloc[i].page) {
>                         dma_unmap_page(priv->ddev, page_alloc[i].dma,
> -                               MLX4_EN_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
> -               put_page(page_alloc[i].page);
> +                               page_alloc[i].size, PCI_DMA_FROMDEVICE);
> +                       page = page_alloc[i].page;
> +                       atomic_set(&page->_count, 1);
> +                       put_page(page);
> +               }
>         }
>         return -ENOMEM;
>  }
> @@ -104,12 +130,12 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
>                               struct mlx4_en_rx_alloc *frags,
>                               int i)
>  {
> -       struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
> +       const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
>
> -       if (frags[i].offset == frag_info->last_offset) {
> -               dma_unmap_page(priv->ddev, frags[i].dma, MLX4_EN_ALLOC_SIZE,
> +       if (frags[i].offset + frag_info->frag_stride > frags[i].size)
> +               dma_unmap_page(priv->ddev, frags[i].dma, frags[i].size,
>                                          PCI_DMA_FROMDEVICE);
> -       }
> +
>         if (frags[i].page)
>                 put_page(frags[i].page);
>  }
> @@ -117,35 +143,28 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
>  static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
>                                   struct mlx4_en_rx_ring *ring)
>  {
> -       struct mlx4_en_rx_alloc *page_alloc;
>         int i;
> +       struct mlx4_en_rx_alloc *page_alloc;
>
>         for (i = 0; i < priv->num_frags; i++) {
> -               page_alloc = &ring->page_alloc[i];
> -               page_alloc->page = alloc_pages(GFP_ATOMIC | __GFP_COMP,
> -                                              MLX4_EN_ALLOC_ORDER);
> -               if (!page_alloc->page)
> -                       goto out;
> +               const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
>
> -               page_alloc->dma = dma_map_page(priv->ddev, page_alloc->page, 0,
> -                                       MLX4_EN_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
> -               if (dma_mapping_error(priv->ddev, page_alloc->dma)) {
> -                       put_page(page_alloc->page);
> -                       page_alloc->page = NULL;
> +               if (mlx4_alloc_pages(priv, &ring->page_alloc[i],
> +                                    frag_info, GFP_KERNEL))
>                         goto out;
> -               }
> -               page_alloc->offset = priv->frag_info[i].frag_align;
> -               en_dbg(DRV, priv, "Initialized allocator:%d with page:%p\n",
> -                      i, page_alloc->page);
>         }
>         return 0;
>
>  out:
>         while (i--) {
> +               struct page *page;
> +
>                 page_alloc = &ring->page_alloc[i];
>                 dma_unmap_page(priv->ddev, page_alloc->dma,
> -                               MLX4_EN_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
> -               put_page(page_alloc->page);
> +                              page_alloc->size, PCI_DMA_FROMDEVICE);
> +               page = page_alloc->page;
> +               atomic_set(&page->_count, 1);
> +               put_page(page);
>                 page_alloc->page = NULL;
>         }
>         return -ENOMEM;
> @@ -158,13 +177,18 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
>         int i;
>
>         for (i = 0; i < priv->num_frags; i++) {
> +               const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
> +
>                 page_alloc = &ring->page_alloc[i];
>                 en_dbg(DRV, priv, "Freeing allocator:%d count:%d\n",
>                        i, page_count(page_alloc->page));
>
>                 dma_unmap_page(priv->ddev, page_alloc->dma,
> -                               MLX4_EN_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
> -               put_page(page_alloc->page);
> +                               page_alloc->size, PCI_DMA_FROMDEVICE);
> +               while (page_alloc->offset + frag_info->frag_stride < page_alloc->size) {
> +                       put_page(page_alloc->page);
> +                       page_alloc->offset += frag_info->frag_stride;
> +               }
>                 page_alloc->page = NULL;
>         }
>  }
> @@ -195,13 +219,14 @@ static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
>  }
>
>  static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
> -                                  struct mlx4_en_rx_ring *ring, int index)
> +                                  struct mlx4_en_rx_ring *ring, int index,
> +                                  gfp_t gfp)
>  {
>         struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
>         struct mlx4_en_rx_alloc *frags = ring->rx_info +
>                                         (index << priv->log_rx_info);
>
> -       return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc);
> +       return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc, gfp);
>  }
>
>  static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
> @@ -235,7 +260,8 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
>                         ring = &priv->rx_ring[ring_ind];
>
>                         if (mlx4_en_prepare_rx_desc(priv, ring,
> -                                                   ring->actual_size)) {
> +                                                   ring->actual_size,
> +                                                   GFP_KERNEL)) {
>                                 if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
>                                         en_err(priv, "Failed to allocate "
>                                                      "enough rx buffers\n");
> @@ -450,11 +476,11 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
>                                         DMA_FROM_DEVICE);
>
>                 /* Save page reference in skb */
> -               get_page(frags[nr].page);
>                 __skb_frag_set_page(&skb_frags_rx[nr], frags[nr].page);
>                 skb_frag_size_set(&skb_frags_rx[nr], frag_info->frag_size);
>                 skb_frags_rx[nr].page_offset = frags[nr].offset;
>                 skb->truesize += frag_info->frag_stride;
> +               frags[nr].page = NULL;
>         }
>         /* Adjust size of last fragment to match actual length */
>         if (nr > 0)
> @@ -547,7 +573,7 @@ static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
>         int index = ring->prod & ring->size_mask;
>
>         while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
> -               if (mlx4_en_prepare_rx_desc(priv, ring, index))
> +               if (mlx4_en_prepare_rx_desc(priv, ring, index, GFP_ATOMIC))
>                         break;
>                 ring->prod++;
>                 index = ring->prod & ring->size_mask;
> @@ -805,21 +831,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
>         return done;
>  }
>
> -
> -/* Calculate the last offset position that accommodates a full fragment
> - * (assuming fagment size = stride-align) */
> -static int mlx4_en_last_alloc_offset(struct mlx4_en_priv *priv, u16 stride, u16 align)
> -{
> -       u16 res = MLX4_EN_ALLOC_SIZE % stride;
> -       u16 offset = MLX4_EN_ALLOC_SIZE - stride - res + align;
> -
> -       en_dbg(DRV, priv, "Calculated last offset for stride:%d align:%d "
> -                           "res:%d offset:%d\n", stride, align, res, offset);
> -       return offset;
> -}
> -
> -
> -static int frag_sizes[] = {
> +static const int frag_sizes[] = {
>         FRAG_SZ0,
>         FRAG_SZ1,
>         FRAG_SZ2,
> @@ -847,9 +859,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
>                         priv->frag_info[i].frag_stride =
>                                 ALIGN(frag_sizes[i], SMP_CACHE_BYTES);
>                 }
> -               priv->frag_info[i].last_offset = mlx4_en_last_alloc_offset(
> -                                               priv, priv->frag_info[i].frag_stride,
> -                                               priv->frag_info[i].frag_align);
>                 buf_size += priv->frag_info[i].frag_size;
>                 i++;
>         }
> @@ -861,13 +870,13 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
>         en_dbg(DRV, priv, "Rx buffer scatter-list (effective-mtu:%d "
>                   "num_frags:%d):\n", eff_mtu, priv->num_frags);
>         for (i = 0; i < priv->num_frags; i++) {
> -               en_dbg(DRV, priv, "  frag:%d - size:%d prefix:%d align:%d "
> -                               "stride:%d last_offset:%d\n", i,
> -                               priv->frag_info[i].frag_size,
> -                               priv->frag_info[i].frag_prefix_size,
> -                               priv->frag_info[i].frag_align,
> -                               priv->frag_info[i].frag_stride,
> -                               priv->frag_info[i].last_offset);
> +               en_err(priv,
> +                      "  frag:%d - size:%d prefix:%d align:%d stride:%d\n",
> +                      i,
> +                      priv->frag_info[i].frag_size,
> +                      priv->frag_info[i].frag_prefix_size,
> +                      priv->frag_info[i].frag_align,
> +                      priv->frag_info[i].frag_stride);
>         }
>  }
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 57192a8..35fb60e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -96,7 +96,8 @@
>
>  /* Use the maximum between 16384 and a single page */
>  #define MLX4_EN_ALLOC_SIZE     PAGE_ALIGN(16384)
> -#define MLX4_EN_ALLOC_ORDER    get_order(MLX4_EN_ALLOC_SIZE)
> +
> +#define MLX4_EN_ALLOC_PREFER_ORDER     PAGE_ALLOC_COSTLY_ORDER
>
>  /* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
>   * and 4K allocations) */
> @@ -234,9 +235,10 @@ struct mlx4_en_tx_desc {
>  #define MLX4_EN_CX3_HIGH_ID    0x1005
>
>  struct mlx4_en_rx_alloc {
> -       struct page *page;
> -       dma_addr_t dma;
> -       u16 offset;
> +       struct page     *page;
> +       dma_addr_t      dma;
> +       u32             offset;
> +       u32             size;
>  };
>
>  struct mlx4_en_tx_ring {
> @@ -439,8 +441,6 @@ struct mlx4_en_frag_info {
>         u16 frag_prefix_size;
>         u16 frag_stride;
>         u16 frag_align;
> -       u16 last_offset;
> -
>  };
>
>  #ifdef CONFIG_MLX4_EN_DCB

Amir is OOO and I am covering for him, so:

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
