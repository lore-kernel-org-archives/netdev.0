From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] net/mlx5e: Support bpf_xdp_adjust_head()
Date: Fri, 13 Jan 2017 14:31:41 -0800
Message-ID: <20170113223141.GA87089@kafai-mba.local>
References: <1484186975-1862468-1-git-send-email-kafai@fb.com>
 <CALzJLG-fj3LHEuZ78tRS8OL-x0rPRgKnsoxtJFon4Fw8-WK1AA@mail.gmail.com>
 <20170112232546.GA1595@kafai-mba.local>
 <CALzJLG_9MTsTV4Y=+BgT7MXO+x-rq526fntxLdAOt=nLD6j9mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36643 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751232AbdAMWcb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:32:31 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG_9MTsTV4Y=+BgT7MXO+x-rq526fntxLdAOt=nLD6j9mA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 03:58:46PM +0200, Saeed Mahameed wrote:
> >> > @@ -680,7 +687,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >> >         memset(wqe, 0, sizeof(*wqe));
> >> >
> >> >         /* copy the inline part */
> >> > -       memcpy(eseg->inline_hdr_start, data, MLX5E_XDP_MIN_INLINE);
> >> > +       memcpy(eseg->inline_hdr_start, xdp->data, MLX5E_XDP_MIN_INLINE);
> >> >         eseg->inline_hdr_sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
> >> >
> >> >         dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
> >> > @@ -706,22 +713,16 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
> >> >  static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
> >> >                                     const struct bpf_prog *prog,
> >> >                                     struct mlx5e_dma_info *di,
> >> > -                                   void *data, u16 len)
> >> > +                                   struct xdp_buff *xdp)
> >> >  {
> >> > -       struct xdp_buff xdp;
> >> >         u32 act;
> >> >
> >> > -       if (!prog)
> >> > -               return false;
> >> > -
> >> > -       xdp.data = data;
> >> > -       xdp.data_end = xdp.data + len;
> >> > -       act = bpf_prog_run_xdp(prog, &xdp);
> >> > +       act = bpf_prog_run_xdp(prog, xdp);
> >> >         switch (act) {
> >> >         case XDP_PASS:
> >> >                 return false;
> >> >         case XDP_TX:
> >> > -               mlx5e_xmit_xdp_frame(rq, di, MLX5_RX_HEADROOM, len);
> >> > +               mlx5e_xmit_xdp_frame(rq, di, xdp);
> >> >                 return true;
> >> >         default:
> >> >                 bpf_warn_invalid_xdp_action(act);
> >> > @@ -737,18 +738,19 @@ static inline
> >> >  struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> >> >                              u16 wqe_counter, u32 cqe_bcnt)
> >> >  {
> >> > +       const struct bpf_prog *xdp_prog;
> >> >         struct mlx5e_dma_info *di;
> >> >         struct sk_buff *skb;
> >> >         void *va, *data;
> >> > -       bool consumed;
> >> > +       u16 rx_headroom = rq->rx_headroom;
> >> >
> >> >         di             = &rq->dma_info[wqe_counter];
> >> >         va             = page_address(di->page);
> >> > -       data           = va + MLX5_RX_HEADROOM;
> >> > +       data           = va + rx_headroom;
> >> >
> >> >         dma_sync_single_range_for_cpu(rq->pdev,
> >> >                                       di->addr,
> >> > -                                     MLX5_RX_HEADROOM,
> >> > +                                     rx_headroom,
> >> >                                       rq->buff.wqe_sz,
> >> >                                       DMA_FROM_DEVICE);
> >> >         prefetch(data);
> >> > @@ -760,11 +762,26 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> >> >         }
> >> >
> >> >         rcu_read_lock();
> >> > -       consumed = mlx5e_xdp_handle(rq, READ_ONCE(rq->xdp_prog), di, data,
> >> > -                                   cqe_bcnt);
> >> > +       xdp_prog = READ_ONCE(rq->xdp_prog);
> >> > +       if (xdp_prog) {
> >> > +               struct xdp_buff xdp;
> >> > +               bool consumed;
> >> > +
> >> > +               xdp.data = data;
> >> > +               xdp.data_end = xdp.data + cqe_bcnt;
> >> > +               xdp.data_hard_start = va;
> >> > +
> >> > +               consumed = mlx5e_xdp_handle(rq, xdp_prog, di, &xdp);
> >> > +
> >> > +               if (consumed) {
> >> > +                       rcu_read_unlock();
> >> > +                       return NULL; /* page/packet was consumed by XDP */
> >> > +               }
> >> > +
> >> > +               rx_headroom = xdp.data - xdp.data_hard_start;
> >> > +               cqe_bcnt = xdp.data_end - xdp.data;
> >> > +       }
> >>
> >> This whole new logic belongs to mlx5e_xdp_handle, I would like to keep
> >> xdp related code in one place.
> >>
> >> move the xdp_buff initialization back to there and keep the xdp_prog
> >> check in mlx5e_xdp_handle;
> >> +      xdp_prog = READ_ONCE(rq->xdp_prog);
> >> +       if (!xdp_prog)
> >> +                    return false
> >>
> >> you can remove "const struct bpf_prog *prog" parameter from
> >> mlx5e_xdp_handle and take it directly from rq.
> >>
> >> if you need va for xdp_buff you can pass it as a paramter to
> >> mlx5e_xdp_handle  as well:
> >> mlx5e_xdp_handle(rq, di, va, data, cqe_bcnt);
> >> Make sense ?
> > I moved them because xdp.data could be adjusted which then
> > rx_headroom and cqe_bcnt have to be adjusted accordingly
> > in skb_from_cqe() also.
> >
> > I understand your point.  After another quick thought,
> > the adjusted xdp.data is the only one that we want in skb_from_cqe().
> > I will try to make mlx5e_xdp_handle() to return the adjusted xdp.data
> > instead of bool.
> >
>
> hmm, You also need the adjusted cqe_bcnt! this will make
> mlx5e_xdp_handle stuffed with parameters,
>
> what if, in skb_from_cqe we warp data, rx_headroom and cqe_bcnt in one struct.
>
> struct mlx5e_rx_buff {
> void *data;
> u6 headroom;
> u32 bcnt;
> }
>
> initialize it at the start of skb_from_cqe:
>
> struct mlx5e_rx_buff rxb;
>
> rxb.headroom = rq->headroom;
> rxb.data = va + rxb.headroom;
> rxb.bcnt = cqe_bcnt;
>
> pass it to mlx5e_xdp_handle(rq, di, va, &rxb) in case xdp_prog is ON
> and rxb needs adjustment.
>
> At the end use it to build the SKB:
> skb = build_skb(va, RQ_PAGE_SIZE(rq));
> skb_reserve(skb, rxb.headroom);
> skb_put(skb, rxb.bcnt);
How about something like this without introducing a new struct?

-static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
-				    const struct bpf_prog *prog,
-				    struct mlx5e_dma_info *di,
-				    void *data, u16 len)
+static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
+				   struct mlx5e_dma_info *di,
+				   void *va, u16 *rx_headroom, u32 *len)
 {
+	const struct bpf_prog *prog = READ_ONCE(rq->xdp_prog);
 	struct xdp_buff xdp;
 	u32 act;

 	if (!prog)
 		return false;

-	xdp.data = data;
-	xdp.data_end = xdp.data + len;
+	xdp.data = va + *rx_headroom;
+	xdp.data_end = xdp.data + *len;
+	xdp.data_hard_start = va;
+
 	act = bpf_prog_run_xdp(prog, &xdp);
 	switch (act) {
 	case XDP_PASS:
+		*rx_headroom = xdp.data - xdp.data_hard_start;
+		*len = xdp.data_end - xdp.data;
 		return false;
 	case XDP_TX:
-		mlx5e_xmit_xdp_frame(rq, di, MLX5_RX_HEADROOM, len);
+		mlx5e_xmit_xdp_frame(rq, di, &xdp);
 		return true;
 	default:
 		bpf_warn_invalid_xdp_action(act);
@@ -740,15 +751,16 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	struct mlx5e_dma_info *di;
 	struct sk_buff *skb;
 	void *va, *data;
+	u16 rx_headroom = rq->rx_headroom;
 	bool consumed;

 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
-	data           = va + MLX5_RX_HEADROOM;
+	data           = va + rx_headroom;

 	dma_sync_single_range_for_cpu(rq->pdev,
 				      di->addr,
-				      MLX5_RX_HEADROOM,
+				      rx_headroom,
 				      rq->buff.wqe_sz,
 				      DMA_FROM_DEVICE);
 	prefetch(data);
@@ -760,8 +772,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	}

 	rcu_read_lock();
-	consumed = mlx5e_xdp_handle(rq, READ_ONCE(rq->xdp_prog), di, data,
-				    cqe_bcnt);
+	consumed = mlx5e_xdp_handle(rq, di, va, &rx_headroom, &cqe_bcnt);
 	rcu_read_unlock();
 	if (consumed)
 		return NULL; /* page/packet was consumed by XDP */
@@ -777,7 +788,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	page_ref_inc(di->page);
 	mlx5e_page_release(rq, di, true);

-	skb_reserve(skb, MLX5_RX_HEADROOM);
+	skb_reserve(skb, rx_headroom);
 	skb_put(skb, cqe_bcnt);

 	return skb;
