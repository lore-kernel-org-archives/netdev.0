From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Thu, 8 Sep 2016 10:11:47 +0200
Message-ID: <20160908101147.1b351432@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <1473252152-11379-12-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org


I'm sorry but I have a problem with this patch!

Looking at this patch, I want to bring up a fundamental architectural
concern with the development direction of XDP transmit.


What you are trying to implement, with delaying the doorbell, is
basically TX bulking for TX_XDP.

 Why not implement a TX bulking interface directly instead?!?

Yes, the tailptr/doorbell is the most costly operation, but why not
also take advantage of the benefits of bulking for other parts of the
code? (benefit is smaller, by every cycles counts in this area)

This hole XDP exercise is about avoiding having a transaction cost per
packet, that reads "bulking" or "bundling" of packets, where possible.

 Lets do bundling/bulking from the start!

The reason behind the xmit_more API is that we could not change the
API of all the drivers.  And we found that calling an explicit NDO
flush came at a cost (only approx 7 ns IIRC), but it still a cost that
would hit the common single packet use-case.

It should be really easy to build a bundle of packets that need XDP_TX
action, especially given you only have a single destination "port".
And then you XDP_TX send this bundle before mlx5_cqwq_update_db_record.

In the future, XDP need to support XDP_FWD forwarding of packets/pages
out other interfaces.  I also want bulk transmit from day-1 here.  It
is slightly more tricky to sort packets for multiple outgoing
interfaces efficiently in the pool loop.

But the mSwitch[1] article actually already solved this destination
sorting.  Please read[1] section 3.3 "Switch Fabric Algorithm" for
understanding the next steps, for a smarter data structure, when
starting to have more TX "ports".  And perhaps align your single
XDP_TX destination data structure to this future development.

[1] http://info.iet.unipi.it/~luigi/papers/20150617-mswitch-paper.pdf

--Jesper
(top post)


On Wed,  7 Sep 2016 15:42:32 +0300 Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:

> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> 
> Here we introduce a xmit more like mechanism that will queue up more
> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> 
> Once RX napi budget is consumed and we exit napi RX loop, we will
> flush (doorbell) all XDP looped packets in case there are such.
> 
> XDP forward packet rate:
> 
> Comparing XDP with and w/o xmit more (bulk transmit):
> 
> Streams     XDP TX       XDP TX (xmit more)
> ---------------------------------------------------
> 1           4.90Mpps      7.50Mpps
> 2           9.50Mpps      14.8Mpps
> 4           16.5Mpps      25.1Mpps
> 8           21.5Mpps      27.5Mpps*
> 16          24.1Mpps      27.5Mpps*
> 
> *It seems we hit a wall of 27.5Mpps, for 8 and 16 streams,
> we will be working on the analysis and will publish the conclusions
> later.
> 
> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en.h    |  9 ++--
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 57 +++++++++++++++++++------
>  2 files changed, 49 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index df2c9e0..6846208 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -265,7 +265,8 @@ struct mlx5e_cq {
>  
>  struct mlx5e_rq;
>  typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq *rq,
> -				       struct mlx5_cqe64 *cqe);
> +				       struct mlx5_cqe64 *cqe,
> +				       bool *xdp_doorbell);
>  typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
>  				  u16 ix);
>  
> @@ -742,8 +743,10 @@ void mlx5e_free_sq_descs(struct mlx5e_sq *sq);
>  
>  void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
>  			bool recycle);
> -void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
> -void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
> +void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> +			 bool *xdp_doorbell);
> +void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> +			       bool *xdp_doorbell);
>  bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
>  int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
>  int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,	u16 ix);
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index 912a0e2..ed93251 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -117,7 +117,8 @@ static inline void mlx5e_decompress_cqe_no_hash(struct mlx5e_rq *rq,
>  static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
>  					     struct mlx5e_cq *cq,
>  					     int update_owner_only,
> -					     int budget_rem)
> +					     int budget_rem,
> +					     bool *xdp_doorbell)
>  {
>  	u32 cqcc = cq->wq.cc + update_owner_only;
>  	u32 cqe_count;
> @@ -131,7 +132,7 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
>  			mlx5e_read_mini_arr_slot(cq, cqcc);
>  
>  		mlx5e_decompress_cqe_no_hash(rq, cq, cqcc);
> -		rq->handle_rx_cqe(rq, &cq->title);
> +		rq->handle_rx_cqe(rq, &cq->title, xdp_doorbell);
>  	}
>  	mlx5e_cqes_update_owner(cq, cq->wq.cc, cqcc - cq->wq.cc);
>  	cq->wq.cc = cqcc;
> @@ -143,15 +144,16 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
>  
>  static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
>  					      struct mlx5e_cq *cq,
> -					      int budget_rem)
> +					      int budget_rem,
> +					      bool *xdp_doorbell)
>  {
>  	mlx5e_read_title_slot(rq, cq, cq->wq.cc);
>  	mlx5e_read_mini_arr_slot(cq, cq->wq.cc + 1);
>  	mlx5e_decompress_cqe(rq, cq, cq->wq.cc);
> -	rq->handle_rx_cqe(rq, &cq->title);
> +	rq->handle_rx_cqe(rq, &cq->title, xdp_doorbell);
>  	cq->mini_arr_idx++;
>  
> -	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem) - 1;
> +	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem, xdp_doorbell) - 1;
>  }
>  
>  void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
> @@ -670,23 +672,36 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_sq *sq,
>  	wi->num_wqebbs = MLX5E_XDP_TX_WQEBBS;
>  	sq->pc += MLX5E_XDP_TX_WQEBBS;
>  
> -	/* TODO: xmit more */
> +	/* mlx5e_sq_xmit_doorbel will be called after RX napi loop */
> +	return true;
> +}
> +
> +static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
> +{
> +	struct mlx5_wq_cyc *wq = &sq->wq;
> +	struct mlx5e_tx_wqe *wqe;
> +	u16 pi = (sq->pc - MLX5E_XDP_TX_WQEBBS) & wq->sz_m1; /* last pi */
> +
> +	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
> +
>  	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
>  	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
>  
> +#if 0 /* enable this code only if MLX5E_XDP_TX_WQEBBS > 1 */
>  	/* fill sq edge with nops to avoid wqe wrap around */
>  	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
>  		sq->db.xdp.wqe_info[pi].opcode = MLX5_OPCODE_NOP;
>  		mlx5e_send_nop(sq, false);
>  	}
> -	return true;
> +#endif
>  }
>  
>  /* returns true if packet was consumed by xdp */
>  static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
>  				    const struct bpf_prog *prog,
>  				    struct mlx5e_dma_info *di,
> -				    void *data, u16 len)
> +				    void *data, u16 len,
> +				    bool *xdp_doorbell)
>  {
>  	bool consumed = false;
>  	struct xdp_buff xdp;
> @@ -705,7 +720,13 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
>  		consumed = mlx5e_xmit_xdp_frame(&rq->channel->xdp_sq, di,
>  						MLX5_RX_HEADROOM,
>  						len);
> +		if (unlikely(!consumed) && (*xdp_doorbell)) {
> +			/* SQ is full, ring doorbell */
> +			mlx5e_xmit_xdp_doorbell(&rq->channel->xdp_sq);
> +			*xdp_doorbell = false;
> +		}
>  		rq->stats.xdp_tx += consumed;
> +		*xdp_doorbell |= consumed;
>  		return consumed;
>  	default:
>  		bpf_warn_invalid_xdp_action(act);
> @@ -720,7 +741,8 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
>  	return false;
>  }
>  
> -void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
> +void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> +			 bool *xdp_doorbell)
>  {
>  	struct bpf_prog *xdp_prog = READ_ONCE(rq->xdp_prog);
>  	struct mlx5e_dma_info *di;
> @@ -752,7 +774,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>  		goto wq_ll_pop;
>  	}
>  
> -	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt))
> +	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt, xdp_doorbell))
>  		goto wq_ll_pop; /* page/packet was consumed by XDP */
>  
>  	skb = build_skb(va, RQ_PAGE_SIZE(rq));
> @@ -814,7 +836,8 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
>  	skb->len  += headlen;
>  }
>  
> -void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
> +void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
> +			       bool *xdp_doorbell)
>  {
>  	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
>  	u16 wqe_id         = be16_to_cpu(cqe->wqe_id);
> @@ -860,13 +883,15 @@ mpwrq_cqe_out:
>  int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>  {
>  	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
> +	bool xdp_doorbell = false;
>  	int work_done = 0;
>  
>  	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state)))
>  		return 0;
>  
>  	if (cq->decmprs_left)
> -		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
> +		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget,
> +							&xdp_doorbell);
>  
>  	for (; work_done < budget; work_done++) {
>  		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
> @@ -877,15 +902,19 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>  		if (mlx5_get_cqe_format(cqe) == MLX5_COMPRESSED) {
>  			work_done +=
>  				mlx5e_decompress_cqes_start(rq, cq,
> -							    budget - work_done);
> +							    budget - work_done,
> +							    &xdp_doorbell);
>  			continue;
>  		}
>  
>  		mlx5_cqwq_pop(&cq->wq);
>  
> -		rq->handle_rx_cqe(rq, cqe);
> +		rq->handle_rx_cqe(rq, cqe, &xdp_doorbell);
>  	}
>  
> +	if (xdp_doorbell)
> +		mlx5e_xmit_xdp_doorbell(&rq->channel->xdp_sq);
> +
>  	mlx5_cqwq_update_db_record(&cq->wq);
>  
>  	/* ensure cq space is freed before enabling more cqes */



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
