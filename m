From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: uses build_skb() in receive
 path
Date: Mon, 14 Nov 2011 18:48:49 +0200
Message-ID: <1321289329.3101.7.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1321286734.2272.48.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Tom Herbert" <therbert@google.com>,
	"Jamal Hadi Salim" <hadi@mojatatu.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Thomas Graf" <tgraf@infradead.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1836 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463Ab1KNQti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 11:49:38 -0500
In-Reply-To: <1321286734.2272.48.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 08:05 -0800, Eric Dumazet wrote:
> bnx2x uses following formula to compute its rx_buf_sz :
> 
> dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8 + 2
> 
> Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info))
> 
> Final allocated size for skb head on x86_64 (L1_CACHE_BYTES = 64,
> MTU=1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.
> 
> Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot of
> false sharing because of mem_reclaim in UDP stack.
> 
> One possible way to half truesize is to reduce the need by 64 bytes
> (2112 -> 2048 bytes)
> 
> Instead of allocating a full cache line at the end of packet for
> alignment, we can use the fact that skb_shared_info sits at the end of
> skb->head, and we can use this room, if we convert bnx2x to new
> build_skb() infrastructure.
> 
> skb_shared_info will be initialized after hardware finished its
> transfert, so we can eventually overwrite the final padding.
> 
> Using build_skb() also reduces cache line misses in the driver, since we
> use cache hot skb instead of cold ones. Number of in-flight sk_buff
> structures is lower, they are recycled while still hot.
> 
> Performance results :
> 
> (820.000 pps on a rx UDP monothread benchmark, instead of 720.000 pps)

Wow! This is very impressive. The only problem will be to back port this
driver now... But it is definitely worth the effort :)

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>

> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: Tom Herbert <therbert@google.com>
> CC: Jamal Hadi Salim <hadi@mojatatu.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Thomas Graf <tgraf@infradead.org>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         |   30 -
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  265 ++++------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |   33 -
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    6
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |    4
>  5 files changed, 170 insertions(+), 168 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index 4b90b51..0f7b7a4 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -293,8 +293,13 @@ enum {
>  #define FCOE_TXQ_IDX(bp)       (MAX_ETH_TXQ_IDX(bp))
> 
>  /* fast path */
> +/*
> + * This driver uses new build_skb() API :
> + * RX ring buffer contains pointer to kmalloc() data only,
> + * skb are built only after Hardware filled the frame.
> + */
>  struct sw_rx_bd {
> -       struct sk_buff  *skb;
> +       u8              *data;
>         DEFINE_DMA_UNMAP_ADDR(mapping);
>  };
> 
> @@ -424,8 +429,8 @@ union host_hc_status_block {
> 
>  struct bnx2x_agg_info {
>         /*
> -        * First aggregation buffer is an skb, the following - are pages.
> -        * We will preallocate the skbs for each aggregation when
> +        * First aggregation buffer is a data buffer, the following - are pages.
> +        * We will preallocate the data buffer for each aggregation when
>          * we open the interface and will replace the BD at the consumer
>          * with this one when we receive the TPA_START CQE in order to
>          * keep the Rx BD ring consistent.
> @@ -439,6 +444,7 @@ struct bnx2x_agg_info {
>         u16                     parsing_flags;
>         u16                     vlan_tag;
>         u16                     len_on_bd;
> +       u32                     rxhash;
>  };
> 
>  #define Q_STATS_OFFSET32(stat_name) \
> @@ -1187,10 +1193,20 @@ struct bnx2x {
>  #define ETH_MAX_JUMBO_PACKET_SIZE      9600
> 
>         /* Max supported alignment is 256 (8 shift) */
> -#define BNX2X_RX_ALIGN_SHIFT           ((L1_CACHE_SHIFT < 8) ? \
> -                                        L1_CACHE_SHIFT : 8)
> -       /* FW use 2 Cache lines Alignment for start packet and size  */
> -#define BNX2X_FW_RX_ALIGN              (2 << BNX2X_RX_ALIGN_SHIFT)
> +#define BNX2X_RX_ALIGN_SHIFT           min(8, L1_CACHE_SHIFT)
> +
> +       /* FW uses 2 Cache lines Alignment for start packet and size
> +        *
> +        * We assume skb_build() uses sizeof(struct skb_shared_info) bytes
> +        * at the end of skb->data, to avoid wasting a full cache line.
> +        * This reduces memory use (skb->truesize).
> +        */
> +#define BNX2X_FW_RX_ALIGN_START        (1UL << BNX2X_RX_ALIGN_SHIFT)
> +
> +#define BNX2X_FW_RX_ALIGN_END                                  \
> +       max(1UL << BNX2X_RX_ALIGN_SHIFT,                        \
> +           SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
> +
>  #define BNX2X_PXP_DRAM_ALIGN           (BNX2X_RX_ALIGN_SHIFT - 5)
> 
>         struct host_sp_status_block *def_status_blk;
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 13dad92..0d60b9e 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -294,8 +294,21 @@ static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
>            fp->last_max_sge, fp->rx_sge_prod);
>  }
> 
> +/* Set Toeplitz hash value in the skb using the value from the
> + * CQE (calculated by HW).
> + */
> +static u32 bnx2x_get_rxhash(const struct bnx2x *bp,
> +                           const struct eth_fast_path_rx_cqe *cqe)
> +{
> +       /* Set Toeplitz hash from CQE */
> +       if ((bp->dev->features & NETIF_F_RXHASH) &&
> +           (cqe->status_flags & ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
> +               return le32_to_cpu(cqe->rss_hash_result);
> +       return 0;
> +}
> +
>  static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
> -                           struct sk_buff *skb, u16 cons, u16 prod,
> +                           u16 cons, u16 prod,
>                             struct eth_fast_path_rx_cqe *cqe)
>  {
>         struct bnx2x *bp = fp->bp;
> @@ -310,9 +323,9 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
>         if (tpa_info->tpa_state != BNX2X_TPA_STOP)
>                 BNX2X_ERR("start of bin not in stop [%d]\n", queue);
> 
> -       /* Try to map an empty skb from the aggregation info  */
> +       /* Try to map an empty data buffer from the aggregation info  */
>         mapping = dma_map_single(&bp->pdev->dev,
> -                                first_buf->skb->data,
> +                                first_buf->data + NET_SKB_PAD,
>                                  fp->rx_buf_size, DMA_FROM_DEVICE);
>         /*
>          *  ...if it fails - move the skb from the consumer to the producer
> @@ -322,15 +335,15 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
> 
>         if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
>                 /* Move the BD from the consumer to the producer */
> -               bnx2x_reuse_rx_skb(fp, cons, prod);
> +               bnx2x_reuse_rx_data(fp, cons, prod);
>                 tpa_info->tpa_state = BNX2X_TPA_ERROR;
>                 return;
>         }
> 
> -       /* move empty skb from pool to prod */
> -       prod_rx_buf->skb = first_buf->skb;
> +       /* move empty data from pool to prod */
> +       prod_rx_buf->data = first_buf->data;
>         dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
> -       /* point prod_bd to new skb */
> +       /* point prod_bd to new data */
>         prod_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
>         prod_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
> 
> @@ -344,6 +357,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
>         tpa_info->tpa_state = BNX2X_TPA_START;
>         tpa_info->len_on_bd = le16_to_cpu(cqe->len_on_bd);
>         tpa_info->placement_offset = cqe->placement_offset;
> +       tpa_info->rxhash = bnx2x_get_rxhash(bp, cqe);
> 
>  #ifdef BNX2X_STOP_ON_ERROR
>         fp->tpa_queue_used |= (1 << queue);
> @@ -471,11 +485,12 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  {
>         struct bnx2x_agg_info *tpa_info = &fp->tpa_info[queue];
>         struct sw_rx_bd *rx_buf = &tpa_info->first_buf;
> -       u8 pad = tpa_info->placement_offset;
> +       u32 pad = tpa_info->placement_offset;
>         u16 len = tpa_info->len_on_bd;
> -       struct sk_buff *skb = rx_buf->skb;
> +       struct sk_buff *skb = NULL;
> +       u8 *data = rx_buf->data;
>         /* alloc new skb */
> -       struct sk_buff *new_skb;
> +       u8 *new_data;
>         u8 old_tpa_state = tpa_info->tpa_state;
> 
>         tpa_info->tpa_state = BNX2X_TPA_STOP;
> @@ -486,18 +501,18 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>         if (old_tpa_state == BNX2X_TPA_ERROR)
>                 goto drop;
> 
> -       /* Try to allocate the new skb */
> -       new_skb = netdev_alloc_skb(bp->dev, fp->rx_buf_size);
> +       /* Try to allocate the new data */
> +       new_data = kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
> 
>         /* Unmap skb in the pool anyway, as we are going to change
>            pool entry status to BNX2X_TPA_STOP even if new skb allocation
>            fails. */
>         dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
>                          fp->rx_buf_size, DMA_FROM_DEVICE);
> +       if (likely(new_data))
> +               skb = build_skb(data);
> 
> -       if (likely(new_skb)) {
> -               prefetch(skb);
> -               prefetch(((char *)(skb)) + L1_CACHE_BYTES);
> +       if (likely(skb)) {
> 
>  #ifdef BNX2X_STOP_ON_ERROR
>                 if (pad + len > fp->rx_buf_size) {
> @@ -509,8 +524,9 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>                 }
>  #endif
> 
> -               skb_reserve(skb, pad);
> +               skb_reserve(skb, pad + NET_SKB_PAD);
>                 skb_put(skb, len);
> +               skb->rxhash = tpa_info->rxhash;
> 
>                 skb->protocol = eth_type_trans(skb, bp->dev);
>                 skb->ip_summed = CHECKSUM_UNNECESSARY;
> @@ -526,8 +542,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>                 }
> 
> 
> -               /* put new skb in bin */
> -               rx_buf->skb = new_skb;
> +               /* put new data in bin */
> +               rx_buf->data = new_data;
> 
>                 return;
>         }
> @@ -539,19 +555,6 @@ drop:
>         fp->eth_q_stats.rx_skb_alloc_failed++;
>  }
> 
> -/* Set Toeplitz hash value in the skb using the value from the
> - * CQE (calculated by HW).
> - */
> -static inline void bnx2x_set_skb_rxhash(struct bnx2x *bp, union eth_rx_cqe *cqe,
> -                                       struct sk_buff *skb)
> -{
> -       /* Set Toeplitz hash from CQE */
> -       if ((bp->dev->features & NETIF_F_RXHASH) &&
> -           (cqe->fast_path_cqe.status_flags &
> -            ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
> -               skb->rxhash =
> -               le32_to_cpu(cqe->fast_path_cqe.rss_hash_result);
> -}
> 
>  int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>  {
> @@ -594,6 +597,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>                 u8 cqe_fp_flags;
>                 enum eth_rx_cqe_type cqe_fp_type;
>                 u16 len, pad;
> +               u8 *data;
> 
>  #ifdef BNX2X_STOP_ON_ERROR
>                 if (unlikely(bp->panic))
> @@ -604,13 +608,6 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>                 bd_prod = RX_BD(bd_prod);
>                 bd_cons = RX_BD(bd_cons);
> 
> -               /* Prefetch the page containing the BD descriptor
> -                  at producer's index. It will be needed when new skb is
> -                  allocated */
> -               prefetch((void *)(PAGE_ALIGN((unsigned long)
> -                                            (&fp->rx_desc_ring[bd_prod])) -
> -                                 PAGE_SIZE + 1));
> -
>                 cqe = &fp->rx_comp_ring[comp_ring_cons];
>                 cqe_fp = &cqe->fast_path_cqe;
>                 cqe_fp_flags = cqe_fp->type_error_flags;
> @@ -626,125 +623,110 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
>                 if (unlikely(CQE_TYPE_SLOW(cqe_fp_type))) {
>                         bnx2x_sp_event(fp, cqe);
>                         goto next_cqe;
> +               }
> +               rx_buf = &fp->rx_buf_ring[bd_cons];
> +               data = rx_buf->data;
> 
> -               /* this is an rx packet */
> -               } else {
> -                       rx_buf = &fp->rx_buf_ring[bd_cons];
> -                       skb = rx_buf->skb;
> -                       prefetch(skb);
> -
> -                       if (!CQE_TYPE_FAST(cqe_fp_type)) {
> +               if (!CQE_TYPE_FAST(cqe_fp_type)) {
>  #ifdef BNX2X_STOP_ON_ERROR
> -                               /* sanity check */
> -                               if (fp->disable_tpa &&
> -                                   (CQE_TYPE_START(cqe_fp_type) ||
> -                                    CQE_TYPE_STOP(cqe_fp_type)))
> -                                       BNX2X_ERR("START/STOP packet while "
> -                                                 "disable_tpa type %x\n",
> -                                                 CQE_TYPE(cqe_fp_type));
> +                       /* sanity check */
> +                       if (fp->disable_tpa &&
> +                           (CQE_TYPE_START(cqe_fp_type) ||
> +                            CQE_TYPE_STOP(cqe_fp_type)))
> +                               BNX2X_ERR("START/STOP packet while "
> +                                         "disable_tpa type %x\n",
> +                                         CQE_TYPE(cqe_fp_type));
>  #endif
> 
> -                               if (CQE_TYPE_START(cqe_fp_type)) {
> -                                       u16 queue = cqe_fp->queue_index;
> -                                       DP(NETIF_MSG_RX_STATUS,
> -                                          "calling tpa_start on queue %d\n",
> -                                          queue);
> -
> -                                       bnx2x_tpa_start(fp, queue, skb,
> -                                                       bd_cons, bd_prod,
> -                                                       cqe_fp);
> -
> -                                       /* Set Toeplitz hash for LRO skb */
> -                                       bnx2x_set_skb_rxhash(bp, cqe, skb);
> -
> -                                       goto next_rx;
> +                       if (CQE_TYPE_START(cqe_fp_type)) {
> +                               u16 queue = cqe_fp->queue_index;
> +                               DP(NETIF_MSG_RX_STATUS,
> +                                  "calling tpa_start on queue %d\n",
> +                                  queue);
> 
> -                               } else {
> -                                       u16 queue =
> -                                               cqe->end_agg_cqe.queue_index;
> -                                       DP(NETIF_MSG_RX_STATUS,
> -                                          "calling tpa_stop on queue %d\n",
> -                                          queue);
> +                               bnx2x_tpa_start(fp, queue,
> +                                               bd_cons, bd_prod,
> +                                               cqe_fp);
> +                               goto next_rx;
> +                       } else {
> +                               u16 queue =
> +                                       cqe->end_agg_cqe.queue_index;
> +                               DP(NETIF_MSG_RX_STATUS,
> +                                  "calling tpa_stop on queue %d\n",
> +                                  queue);
> 
> -                                       bnx2x_tpa_stop(bp, fp, queue,
> -                                                      &cqe->end_agg_cqe,
> -                                                      comp_ring_cons);
> +                               bnx2x_tpa_stop(bp, fp, queue,
> +                                              &cqe->end_agg_cqe,
> +                                              comp_ring_cons);
>  #ifdef BNX2X_STOP_ON_ERROR
> -                                       if (bp->panic)
> -                                               return 0;
> +                               if (bp->panic)
> +                                       return 0;
>  #endif
> 
> -                                       bnx2x_update_sge_prod(fp, cqe_fp);
> -                                       goto next_cqe;
> -                               }
> +                               bnx2x_update_sge_prod(fp, cqe_fp);
> +                               goto next_cqe;
>                         }
> -                       /* non TPA */
> -                       len = le16_to_cpu(cqe_fp->pkt_len);
> -                       pad = cqe_fp->placement_offset;
> -                       dma_sync_single_for_cpu(&bp->pdev->dev,
> +               }
> +               /* non TPA */
> +               len = le16_to_cpu(cqe_fp->pkt_len);
> +               pad = cqe_fp->placement_offset;
> +               dma_sync_single_for_cpu(&bp->pdev->dev,
>                                         dma_unmap_addr(rx_buf, mapping),
> -                                                      pad + RX_COPY_THRESH,
> -                                                      DMA_FROM_DEVICE);
> -                       prefetch(((char *)(skb)) + L1_CACHE_BYTES);
> +                                       pad + RX_COPY_THRESH,
> +                                       DMA_FROM_DEVICE);
> +               pad += NET_SKB_PAD;
> +               prefetch(data + pad); /* speedup eth_type_trans() */
> +               /* is this an error packet? */
> +               if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
> +                       DP(NETIF_MSG_RX_ERR,
> +                          "ERROR  flags %x  rx packet %u\n",
> +                          cqe_fp_flags, sw_comp_cons);
> +                       fp->eth_q_stats.rx_err_discard_pkt++;
> +                       goto reuse_rx;
> +               }
> 
> -                       /* is this an error packet? */
> -                       if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
> +               /* Since we don't have a jumbo ring
> +                * copy small packets if mtu > 1500
> +                */
> +               if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
> +                   (len <= RX_COPY_THRESH)) {
> +                       skb = netdev_alloc_skb_ip_align(bp->dev, len);
> +                       if (skb == NULL) {
>                                 DP(NETIF_MSG_RX_ERR,
> -                                  "ERROR  flags %x  rx packet %u\n",
> -                                  cqe_fp_flags, sw_comp_cons);
> -                               fp->eth_q_stats.rx_err_discard_pkt++;
> +                                  "ERROR  packet dropped because of alloc failure\n");
> +                               fp->eth_q_stats.rx_skb_alloc_failed++;
>                                 goto reuse_rx;
>                         }
> -
> -                       /* Since we don't have a jumbo ring
> -                        * copy small packets if mtu > 1500
> -                        */
> -                       if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
> -                           (len <= RX_COPY_THRESH)) {
> -                               struct sk_buff *new_skb;
> -
> -                               new_skb = netdev_alloc_skb(bp->dev, len + pad);
> -                               if (new_skb == NULL) {
> -                                       DP(NETIF_MSG_RX_ERR,
> -                                          "ERROR  packet dropped "
> -                                          "because of alloc failure\n");
> -                                       fp->eth_q_stats.rx_skb_alloc_failed++;
> -                                       goto reuse_rx;
> -                               }
> -
> -                               /* aligned copy */
> -                               skb_copy_from_linear_data_offset(skb, pad,
> -                                                   new_skb->data + pad, len);
> -                               skb_reserve(new_skb, pad);
> -                               skb_put(new_skb, len);
> -
> -                               bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
> -
> -                               skb = new_skb;
> -
> -                       } else
> -                       if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
> +                       memcpy(skb->data, data + pad, len);
> +                       bnx2x_reuse_rx_data(fp, bd_cons, bd_prod);
> +               } else {
> +                       if (likely(bnx2x_alloc_rx_data(bp, fp, bd_prod) == 0)) {
>                                 dma_unmap_single(&bp->pdev->dev,
> -                                       dma_unmap_addr(rx_buf, mapping),
> +                                                dma_unmap_addr(rx_buf, mapping),
>                                                  fp->rx_buf_size,
>                                                  DMA_FROM_DEVICE);
> +                               skb = build_skb(data);
> +                               if (unlikely(!skb)) {
> +                                       kfree(data);
> +                                       fp->eth_q_stats.rx_skb_alloc_failed++;
> +                                       goto next_rx;
> +                               }
>                                 skb_reserve(skb, pad);
> -                               skb_put(skb, len);
> -
>                         } else {
>                                 DP(NETIF_MSG_RX_ERR,
>                                    "ERROR  packet dropped because "
>                                    "of alloc failure\n");
>                                 fp->eth_q_stats.rx_skb_alloc_failed++;
>  reuse_rx:
> -                               bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
> +                               bnx2x_reuse_rx_data(fp, bd_cons, bd_prod);
>                                 goto next_rx;
>                         }
> 
> +                       skb_put(skb, len);
>                         skb->protocol = eth_type_trans(skb, bp->dev);
> 
>                         /* Set Toeplitz hash for a none-LRO skb */
> -                       bnx2x_set_skb_rxhash(bp, cqe, skb);
> +                       skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp);
> 
>                         skb_checksum_none_assert(skb);
> 
> @@ -767,7 +749,7 @@ reuse_rx:
> 
> 
>  next_rx:
> -               rx_buf->skb = NULL;
> +               rx_buf->data = NULL;
> 
>                 bd_cons = NEXT_RX_IDX(bd_cons);
>                 bd_prod = NEXT_RX_IDX(bd_prod);
> @@ -1013,9 +995,9 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
>                                 struct sw_rx_bd *first_buf =
>                                         &tpa_info->first_buf;
> 
> -                               first_buf->skb = netdev_alloc_skb(bp->dev,
> -                                                      fp->rx_buf_size);
> -                               if (!first_buf->skb) {
> +                               first_buf->data = kmalloc(fp->rx_buf_size + NET_SKB_PAD,
> +                                                         GFP_ATOMIC);
> +                               if (!first_buf->data) {
>                                         BNX2X_ERR("Failed to allocate TPA "
>                                                   "skb pool for queue[%d] - "
>                                                   "disabling TPA on this "
> @@ -1118,16 +1100,16 @@ static void bnx2x_free_rx_bds(struct bnx2x_fastpath *fp)
> 
>         for (i = 0; i < NUM_RX_BD; i++) {
>                 struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
> -               struct sk_buff *skb = rx_buf->skb;
> +               u8 *data = rx_buf->data;
> 
> -               if (skb == NULL)
> +               if (data == NULL)
>                         continue;
>                 dma_unmap_single(&bp->pdev->dev,
>                                  dma_unmap_addr(rx_buf, mapping),
>                                  fp->rx_buf_size, DMA_FROM_DEVICE);
> 
> -               rx_buf->skb = NULL;
> -               dev_kfree_skb(skb);
> +               rx_buf->data = NULL;
> +               kfree(data);
>         }
>  }
> 
> @@ -1509,6 +1491,7 @@ static inline void bnx2x_set_rx_buf_size(struct bnx2x *bp)
> 
>         for_each_queue(bp, i) {
>                 struct bnx2x_fastpath *fp = &bp->fp[i];
> +               u32 mtu;
> 
>                 /* Always use a mini-jumbo MTU for the FCoE L2 ring */
>                 if (IS_FCOE_IDX(i))
> @@ -1518,13 +1501,15 @@ static inline void bnx2x_set_rx_buf_size(struct bnx2x *bp)
>                          * IP_HEADER_ALIGNMENT_PADDING to prevent a buffer
>                          * overrun attack.
>                          */
> -                       fp->rx_buf_size =
> -                               BNX2X_FCOE_MINI_JUMBO_MTU + ETH_OVREHEAD +
> -                               BNX2X_FW_RX_ALIGN + IP_HEADER_ALIGNMENT_PADDING;
> +                       mtu = BNX2X_FCOE_MINI_JUMBO_MTU;
>                 else
> -                       fp->rx_buf_size =
> -                               bp->dev->mtu + ETH_OVREHEAD +
> -                               BNX2X_FW_RX_ALIGN + IP_HEADER_ALIGNMENT_PADDING;
> +                       mtu = bp->dev->mtu;
> +               fp->rx_buf_size = BNX2X_FW_RX_ALIGN_START +
> +                                 IP_HEADER_ALIGNMENT_PADDING +
> +                                 ETH_OVREHEAD +
> +                                 mtu +
> +                                 BNX2X_FW_RX_ALIGN_END;
> +               /* Note : rx_buf_size doesnt take into account NET_SKB_PAD */
>         }
>  }
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> index 260226d..41eb17e 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> @@ -910,26 +910,27 @@ static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
>         return 0;
>  }
> 
> -static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
> -                                    struct bnx2x_fastpath *fp, u16 index)
> +static inline int bnx2x_alloc_rx_data(struct bnx2x *bp,
> +                                     struct bnx2x_fastpath *fp, u16 index)
>  {
> -       struct sk_buff *skb;
> +       u8 *data;
>         struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[index];
>         struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
>         dma_addr_t mapping;
> 
> -       skb = netdev_alloc_skb(bp->dev, fp->rx_buf_size);
> -       if (unlikely(skb == NULL))
> +       data = kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
> +       if (unlikely(data == NULL))
>                 return -ENOMEM;
> 
> -       mapping = dma_map_single(&bp->pdev->dev, skb->data, fp->rx_buf_size,
> +       mapping = dma_map_single(&bp->pdev->dev, data + NET_SKB_PAD,
> +                                fp->rx_buf_size,
>                                  DMA_FROM_DEVICE);
>         if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
> -               dev_kfree_skb_any(skb);
> +               kfree(data);
>                 return -ENOMEM;
>         }
> 
> -       rx_buf->skb = skb;
> +       rx_buf->data = data;
>         dma_unmap_addr_set(rx_buf, mapping, mapping);
> 
>         rx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
> @@ -938,12 +939,12 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
>         return 0;
>  }
> 
> -/* note that we are not allocating a new skb,
> +/* note that we are not allocating a new buffer,
>   * we are just moving one from cons to prod
>   * we are not creating a new mapping,
>   * so there is no need to check for dma_mapping_error().
>   */
> -static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
> +static inline void bnx2x_reuse_rx_data(struct bnx2x_fastpath *fp,
>                                       u16 cons, u16 prod)
>  {
>         struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
> @@ -953,7 +954,7 @@ static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
> 
>         dma_unmap_addr_set(prod_rx_buf, mapping,
>                            dma_unmap_addr(cons_rx_buf, mapping));
> -       prod_rx_buf->skb = cons_rx_buf->skb;
> +       prod_rx_buf->data = cons_rx_buf->data;
>         *prod_bd = *cons_bd;
>  }
> 
> @@ -1029,9 +1030,9 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
>         for (i = 0; i < last; i++) {
>                 struct bnx2x_agg_info *tpa_info = &fp->tpa_info[i];
>                 struct sw_rx_bd *first_buf = &tpa_info->first_buf;
> -               struct sk_buff *skb = first_buf->skb;
> +               u8 *data = first_buf->data;
> 
> -               if (skb == NULL) {
> +               if (data == NULL) {
>                         DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
>                         continue;
>                 }
> @@ -1039,8 +1040,8 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
>                         dma_unmap_single(&bp->pdev->dev,
>                                          dma_unmap_addr(first_buf, mapping),
>                                          fp->rx_buf_size, DMA_FROM_DEVICE);
> -               dev_kfree_skb(skb);
> -               first_buf->skb = NULL;
> +               kfree(data);
> +               first_buf->data = NULL;
>         }
>  }
> 
> @@ -1148,7 +1149,7 @@ static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
>          * fp->eth_q_stats.rx_skb_alloc_failed = 0
>          */
>         for (i = 0; i < rx_ring_size; i++) {
> -               if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
> +               if (bnx2x_alloc_rx_data(bp, fp, ring_prod) < 0) {
>                         fp->eth_q_stats.rx_skb_alloc_failed++;
>                         continue;
>                 }
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> index f6402fa..ec31871 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> @@ -1740,6 +1740,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
>         struct sw_rx_bd *rx_buf;
>         u16 len;
>         int rc = -ENODEV;
> +       u8 *data;
> 
>         /* check the loopback mode */
>         switch (loopback_mode) {
> @@ -1865,10 +1866,9 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
>         dma_sync_single_for_cpu(&bp->pdev->dev,
>                                    dma_unmap_addr(rx_buf, mapping),
>                                    fp_rx->rx_buf_size, DMA_FROM_DEVICE);
> -       skb = rx_buf->skb;
> -       skb_reserve(skb, cqe->fast_path_cqe.placement_offset);
> +       data = rx_buf->data + NET_SKB_PAD + cqe->fast_path_cqe.placement_offset;
>         for (i = ETH_HLEN; i < pkt_size; i++)
> -               if (*(skb->data + i) != (unsigned char) (i & 0xff))
> +               if (*(data + i) != (unsigned char) (i & 0xff))
>                         goto test_loopback_rx_exit;
> 
>         rc = 0;
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 33ff60d..80fb9b5 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2789,8 +2789,8 @@ static void bnx2x_pf_rx_q_prep(struct bnx2x *bp,
>         /* This should be a maximum number of data bytes that may be
>          * placed on the BD (not including paddings).
>          */
> -       rxq_init->buf_sz = fp->rx_buf_size - BNX2X_FW_RX_ALIGN -
> -               IP_HEADER_ALIGNMENT_PADDING;
> +       rxq_init->buf_sz = fp->rx_buf_size - BNX2X_FW_RX_ALIGN_START -
> +               BNX2X_FW_RX_ALIGN_END - IP_HEADER_ALIGNMENT_PADDING;
> 
>         rxq_init->cl_qzone_id = fp->cl_qzone_id;
>         rxq_init->tpa_agg_sz = tpa_agg_size;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
