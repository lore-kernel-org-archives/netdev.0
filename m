From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] net/mlx5e: Support bpf_xdp_adjust_head()
Date: Thu, 12 Jan 2017 15:25:46 -0800
Message-ID: <20170112232546.GA1595@kafai-mba.local>
References: <1484186975-1862468-1-git-send-email-kafai@fb.com>
 <CALzJLG-fj3LHEuZ78tRS8OL-x0rPRgKnsoxtJFon4Fw8-WK1AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59408 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750779AbdALXZ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 18:25:59 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG-fj3LHEuZ78tRS8OL-x0rPRgKnsoxtJFon4Fw8-WK1AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 03:10:30PM +0200, Saeed Mahameed wrote:
> On Thu, Jan 12, 2017 at 4:09 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > This patch adds bpf_xdp_adjust_head() support to mlx5e.
>
> Hi Martin, Thanks for the patch !
>
> you can find some comments below.
>
> >
> > 1. rx_headroom is added to struct mlx5e_rq.  It uses
> >    an existing 4 byte hole in the struct.
> > 2. The adjusted data length is checked against
> >    MLX5E_XDP_MIN_INLINE and MLX5E_SW2HW_MTU(rq->netdev->mtu).
> > 3. The macro MLX5E_SW2HW_MTU is moved from en_main.c to en.h.
> >    MLX5E_HW2SW_MTU is also moved to en.h for symmetric reason
> >    but it is not a must.
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 ++
> >  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 +++----
> >  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 63 ++++++++++++++---------
> >  3 files changed, 51 insertions(+), 34 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> > index a473cea10c16..0d9dd860a295 100644
> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> > @@ -51,6 +51,9 @@
> >
> >  #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
> >
> > +#define MLX5E_HW2SW_MTU(hwmtu) ((hwmtu) - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
> > +#define MLX5E_SW2HW_MTU(swmtu) ((swmtu) + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
> > +
> >  #define MLX5E_MAX_NUM_TC       8
> >
> >  #define MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE                0x6
> > @@ -369,6 +372,7 @@ struct mlx5e_rq {
> >
> >         unsigned long          state;
> >         int                    ix;
> > +       u16                    rx_headroom;
> >
> >         struct mlx5e_rx_am     am; /* Adaptive Moderation */
> >         struct bpf_prog       *xdp_prog;
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > index f74ba73c55c7..aba3691e0919 100644
> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> > @@ -343,9 +343,6 @@ static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
> >         synchronize_irq(mlx5_get_msix_vec(priv->mdev, MLX5_EQ_VEC_ASYNC));
> >  }
> >
> > -#define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
> > -#define MLX5E_SW2HW_MTU(swmtu) (swmtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
> > -
> >  static inline int mlx5e_get_wqe_mtt_sz(void)
> >  {
> >         /* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
> > @@ -534,9 +531,13 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
> >                 goto err_rq_wq_destroy;
> >         }
> >
> > -       rq->buff.map_dir = DMA_FROM_DEVICE;
> > -       if (rq->xdp_prog)
> > +       if (rq->xdp_prog) {
> >                 rq->buff.map_dir = DMA_BIDIRECTIONAL;
> > +               rq->rx_headroom = XDP_PACKET_HEADROOM;
> > +       } else {
> > +               rq->buff.map_dir = DMA_FROM_DEVICE;
> > +               rq->rx_headroom = MLX5_RX_HEADROOM;
> > +       }
> >
> >         switch (priv->params.rq_wq_type) {
> >         case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
> > @@ -586,7 +587,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
> >                 byte_count = rq->buff.wqe_sz;
> >
> >                 /* calc the required page order */
> > -               frag_sz = MLX5_RX_HEADROOM +
> > +               frag_sz = rq->rx_headroom +
> >                           byte_count /* packet data */ +
> >                           SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> >                 frag_sz = SKB_DATA_ALIGN(frag_sz);
> > @@ -3153,11 +3154,6 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
> >         bool reset, was_opened;
> >         int i;
> >
> > -       if (prog && prog->xdp_adjust_head) {
> > -               netdev_err(netdev, "Does not support bpf_xdp_adjust_head()\n");
> > -               return -EOPNOTSUPP;
> > -       }
> > -
> >         mutex_lock(&priv->state_lock);
> >
> >         if ((netdev->features & NETIF_F_LRO) && prog) {
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> > index 0e2fb3ed1790..914e00132e08 100644
> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> > @@ -264,7 +264,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
> >         if (unlikely(mlx5e_page_alloc_mapped(rq, di)))
> >                 return -ENOMEM;
> >
> > -       wqe->data.addr = cpu_to_be64(di->addr + MLX5_RX_HEADROOM);
> > +       wqe->data.addr = cpu_to_be64(di->addr + rq->rx_headroom);
> >         return 0;
> >  }
> >
> > @@ -646,8 +646,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
> >
> >  static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >                                         struct mlx5e_dma_info *di,
> > -                                       unsigned int data_offset,
> > -                                       int len)
> > +                                       const struct xdp_buff *xdp)
> >  {
> >         struct mlx5e_sq          *sq   = &rq->channel->xdp_sq;
> >         struct mlx5_wq_cyc       *wq   = &sq->wq;
> > @@ -659,9 +658,17 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >         struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
> >         struct mlx5_wqe_data_seg *dseg;
> >
> > +       ptrdiff_t data_offset = xdp->data - xdp->data_hard_start;
> >         dma_addr_t dma_addr  = di->addr + data_offset + MLX5E_XDP_MIN_INLINE;
> > -       unsigned int dma_len = len - MLX5E_XDP_MIN_INLINE;
> > -       void *data           = page_address(di->page) + data_offset;
> > +       unsigned int dma_len = xdp->data_end - xdp->data;
> > +
> > +       if (unlikely(dma_len < MLX5E_XDP_MIN_INLINE ||
>
> I don't think this can happen, MLX5E_XDP_MIN_INLINE is 18 bytes and
> should not get bigger in the future,
> Also i don't think it is possible for XDP prog to xmit packets smaller
> than 18 bytes, let's remove this
The bpf_xdp_adjust_head() only checks for a min of ETH_HLEN which is 14.
Hence, <18 bytes is still possible here.

>
> > +                    MLX5E_SW2HW_MTU(rq->netdev->mtu) < dma_len)) {
> > +               rq->stats.xdp_drop++;
> > +               mlx5e_page_release(rq, di, true);
> > +               return;
> > +       }
> > +       dma_len -= MLX5E_XDP_MIN_INLINE;
>
> Move this to after the below sanity check, it is better to separate
> logic from pre-conditions
Will do.

>
> >
> >         if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
> >                 if (sq->db.xdp.doorbell) {
> > @@ -680,7 +687,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >         memset(wqe, 0, sizeof(*wqe));
> >
> >         /* copy the inline part */
> > -       memcpy(eseg->inline_hdr_start, data, MLX5E_XDP_MIN_INLINE);
> > +       memcpy(eseg->inline_hdr_start, xdp->data, MLX5E_XDP_MIN_INLINE);
> >         eseg->inline_hdr_sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
> >
> >         dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
> > @@ -706,22 +713,16 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >  static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
> >                                     const struct bpf_prog *prog,
> >                                     struct mlx5e_dma_info *di,
> > -                                   void *data, u16 len)
> > +                                   struct xdp_buff *xdp)
> >  {
> > -       struct xdp_buff xdp;
> >         u32 act;
> >
> > -       if (!prog)
> > -               return false;
> > -
> > -       xdp.data = data;
> > -       xdp.data_end = xdp.data + len;
> > -       act = bpf_prog_run_xdp(prog, &xdp);
> > +       act = bpf_prog_run_xdp(prog, xdp);
> >         switch (act) {
> >         case XDP_PASS:
> >                 return false;
> >         case XDP_TX:
> > -               mlx5e_xmit_xdp_frame(rq, di, MLX5_RX_HEADROOM, len);
> > +               mlx5e_xmit_xdp_frame(rq, di, xdp);
> >                 return true;
> >         default:
> >                 bpf_warn_invalid_xdp_action(act);
> > @@ -737,18 +738,19 @@ static inline
> >  struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> >                              u16 wqe_counter, u32 cqe_bcnt)
> >  {
> > +       const struct bpf_prog *xdp_prog;
> >         struct mlx5e_dma_info *di;
> >         struct sk_buff *skb;
> >         void *va, *data;
> > -       bool consumed;
> > +       u16 rx_headroom = rq->rx_headroom;
> >
> >         di             = &rq->dma_info[wqe_counter];
> >         va             = page_address(di->page);
> > -       data           = va + MLX5_RX_HEADROOM;
> > +       data           = va + rx_headroom;
> >
> >         dma_sync_single_range_for_cpu(rq->pdev,
> >                                       di->addr,
> > -                                     MLX5_RX_HEADROOM,
> > +                                     rx_headroom,
> >                                       rq->buff.wqe_sz,
> >                                       DMA_FROM_DEVICE);
> >         prefetch(data);
> > @@ -760,11 +762,26 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> >         }
> >
> >         rcu_read_lock();
> > -       consumed = mlx5e_xdp_handle(rq, READ_ONCE(rq->xdp_prog), di, data,
> > -                                   cqe_bcnt);
> > +       xdp_prog = READ_ONCE(rq->xdp_prog);
> > +       if (xdp_prog) {
> > +               struct xdp_buff xdp;
> > +               bool consumed;
> > +
> > +               xdp.data = data;
> > +               xdp.data_end = xdp.data + cqe_bcnt;
> > +               xdp.data_hard_start = va;
> > +
> > +               consumed = mlx5e_xdp_handle(rq, xdp_prog, di, &xdp);
> > +
> > +               if (consumed) {
> > +                       rcu_read_unlock();
> > +                       return NULL; /* page/packet was consumed by XDP */
> > +               }
> > +
> > +               rx_headroom = xdp.data - xdp.data_hard_start;
> > +               cqe_bcnt = xdp.data_end - xdp.data;
> > +       }
>
> This whole new logic belongs to mlx5e_xdp_handle, I would like to keep
> xdp related code in one place.
>
> move the xdp_buff initialization back to there and keep the xdp_prog
> check in mlx5e_xdp_handle;
> +      xdp_prog = READ_ONCE(rq->xdp_prog);
> +       if (!xdp_prog)
> +                    return false
>
> you can remove "const struct bpf_prog *prog" parameter from
> mlx5e_xdp_handle and take it directly from rq.
>
> if you need va for xdp_buff you can pass it as a paramter to
> mlx5e_xdp_handle  as well:
> mlx5e_xdp_handle(rq, di, va, data, cqe_bcnt);
> Make sense ?
I moved them because xdp.data could be adjusted which then
rx_headroom and cqe_bcnt have to be adjusted accordingly
in skb_from_cqe() also.

I understand your point.  After another quick thought,
the adjusted xdp.data is the only one that we want in skb_from_cqe().
I will try to make mlx5e_xdp_handle() to return the adjusted xdp.data
instead of bool.

Thanks,
--Martin

>
> >         rcu_read_unlock();
> > -       if (consumed)
> > -               return NULL; /* page/packet was consumed by XDP */
> >
> >         skb = build_skb(va, RQ_PAGE_SIZE(rq));
> >         if (unlikely(!skb)) {
> > @@ -777,7 +794,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> >         page_ref_inc(di->page);
> >         mlx5e_page_release(rq, di, true);
> >
> > -       skb_reserve(skb, MLX5_RX_HEADROOM);
> > +       skb_reserve(skb, rx_headroom);
> >         skb_put(skb, cqe_bcnt);
> >
> >         return skb;
> > --
> > 2.5.1
> >
