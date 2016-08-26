From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Fri, 26 Aug 2016 14:01:05 -0700
Message-ID: <20160826210104.GA5063@gmail.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33250 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbcHZVBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 17:01:09 -0400
Received: by mail-pf0-f172.google.com with SMTP id y134so31930296pfg.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 14:01:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160826203808.23664-1-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 01:38:08PM -0700, Brenden Blanco wrote:
> Depending on the preempt mode, the bpf_prog stored in xdp_prog may be
> freed despite the use of call_rcu inside bpf_prog_put. The situation is
> possible when running in PREEMPT_RCU=y mode, for instance, since the rcu
> callback for destroying the bpf prog can run even during the bh handling
> in the mlx4 rx path.
> 
> Several options were considered before this patch was settled on:
> 
> Add a napi_synchronize loop in mlx4_xdp_set, which would occur after all
> of the rings are updated with the new program.
> This approach has the disadvantage that as the number of rings
> increases, the speed of udpate will slow down significantly due to
I belatedly ran checkpatch, which pointed out the spelling mistake here.
I will update the udpate after waiting to see what other discussion
happens on this.
> napi_synchronize's msleep(1).
> 
> Add a new rcu_head in bpf_prog_aux, to be used by a new bpf_prog_put_bh.
> The action of the bpf_prog_put_bh would be to then call bpf_prog_put
> later. Those drivers that consume a bpf prog in a bh context (like mlx4)
> would then use the bpf_prog_put_bh instead when the ring is up. This has
> the problem of complexity, in maintaining proper refcnts and rcu lists,
> and would likely be harder to review. In addition, this approach to
> freeing must be exclusive with other frees of the bpf prog, for instance
> a _bh prog must not be referenced from a prog array that is consumed by
> a non-_bh prog.
> 
> The placement of rcu_read_lock in this patch is functionally the same as
> putting an rcu_read_lock in napi_poll. Actually doing so could be a
> potentially controversial change, but would bring the implementation in
> line with sk_busy_loop (though of course the nature of those two paths
> is substantially different), and would also avoid future copy/paste
> problems with future supporters of XDP. Still, this patch does not take
> that opinionated option.
> 
> Testing was done with kernels in either PREEMPT_RCU=y or
> CONFIG_PREEMPT_VOLUNTARY=y+PREEMPT_RCU=n modes, with neither exhibiting
> any drawback. With PREEMPT_RCU=n, the extra call to rcu_read_lock did
> not show up in the perf report whatsoever, and with PREEMPT_RCU=y the
> overhead of rcu_read_lock (according to perf) was the same before/after.
> In the rx path, rcu_read_lock is eventually called for every packet
> from netif_receive_skb_internal, so the napi poll call's rcu_read_lock
> is easily amortized.
> 
> Fixes: d576acf0a22 ("net/mlx4_en: add page recycle to prepare rx ring for tx support")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 2040dad..efed546 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -800,6 +800,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	if (budget <= 0)
>  		return polled;
>  
> +	rcu_read_lock();
>  	xdp_prog = READ_ONCE(ring->xdp_prog);
>  	doorbell_pending = 0;
>  	tx_index = (priv->tx_ring_num - priv->xdp_ring_num) + cq->ring;
> @@ -1077,6 +1078,7 @@ consumed:
>  	}
>  
>  out:
> +	rcu_read_unlock();
>  	if (doorbell_pending)
>  		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
>  
> -- 
> 2.9.3
> 
