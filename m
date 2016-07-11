From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Mon, 11 Jul 2016 13:09:22 +0200
Message-ID: <20160711130922.636ee4e6@redhat.com>
References: <20160708172024.4a849b7a@redhat.com>
	<20160708160135.27507.77711.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, daniel@iogearbox.net, tom@herbertland.com,
	bblanco@plumgrid.com, john.fastabend@gmail.com,
	gerlitz.or@gmail.com, hannes@stressinduktion.org,
	rana.shahot@gmail.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	brouer@redhat.com, saeedm@mellanox.com, amira@mellanox.com,
	tzahio@mellanox.com, Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758106AbcGKLJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 07:09:30 -0400
In-Reply-To: <20160708160135.27507.77711.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Jul 2016 18:02:20 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> This patch is about prefetching without being opportunistic.
> The idea is only to start prefetching on packets that are marked as
> ready/completed in the RX ring.
> 
> This is acheived by splitting the napi_poll call mlx4_en_process_rx_cq()
> loop into two.  The first loop extract completed CQEs and start
> prefetching on data and RX descriptors. The second loop process the
> real packets.
> 
> Details: The batching of CQEs are limited to 8 in-order to avoid
> stressing the LFB (Line Fill Buffer) and cache usage.
> 
> I've left some opportunities for prefetching CQE descriptors.
> 
> 
> The performance improvements on my platform are huge, as I tested this
> on a CPU without DDIO.  The performance for XDP is the same as with
> Brendens prefetch hack.

This patch is based on top of Brenden's patch 11/12, and is mean to
replace patch 12/12.

Prefetching is very important for XDP, especially when using a CPU
without DDIO (here i7-4790K CPU @ 4.00GHz).

Program xdp1: touching-data and dropping packets:
 * 11,363,925 pkt/s == no-prefetch
 * 21,031,096 pkt/s == brenden's-prefetch
 * 21,062,728 pkt/s == this-prefetch-patch

Program xdp2: write-data (swap src_dst_mac) TX-bounce out same interface:
 *  6,726,482 pkt/s == no-prefetch
 * 10,378,163 pkt/s == brenden's-prefetch
 * 10,622,350 pkt/s == this-prefetch-patch

This patch also benefits the normal network stack (the XDP specific
prefetch patch does not).

Dropping packets in iptables -t raw:
 * 4,432,519 pps drop == no-prefetch
 * 5,919,690 pps drop == this-prefetch-patch

Dropping packets in iptables -t filter:
 * 2,768,053 pps drop == no-prefetch
 * 4,038,247 pps drop == this-prefetch-patch


To please Eric, I also ran many different variations of netperf and
didn't see any regressions, only small improvements.  The variation
between runs for netperf is too high to be statistically significant.

The worst-case test for this patchset should be netperf TCP_RR as it
should only have single packet in the queue.  When running 32 parallel
TCP_RR (netserver sink have 8 cores), I actually saw a small 2%
improvement (again with high variation, as we also test CPU sched).

Investigating the TCP_RR case, as patch is constructed to not affect
the case of a single packet in the RX queue.  Using my recent
tracepoint change, we can see that with 32 parallel TCP_RR we do have
situations where napi_poll had several packets in the RX ring:

 # perf record -a -e napi:napi_poll sleep 3
 # perf script | awk '{print $5,$14,$15,$16,$17,$18}' | sort -k3n | uniq -c

 521655 napi:napi_poll: mlx4p1 work 0 budget 64
1477872 napi:napi_poll: mlx4p1 work 1 budget 64
 189081 napi:napi_poll: mlx4p1 work 2 budget 64
  12552 napi:napi_poll: mlx4p1 work 3 budget 64
    464 napi:napi_poll: mlx4p1 work 4 budget 64
     16 napi:napi_poll: mlx4p1 work 5 budget 64
      4 napi:napi_poll: mlx4p1 work 6 budget 64

I do find the "work 0" case a little strange... that cause that?


 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |   70 +++++++++++++++++++++++++---
>  1 file changed, 62 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 41c76fe00a7f..c5efe03e31ce 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -782,7 +782,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	int doorbell_pending;
>  	struct sk_buff *skb;
>  	int tx_index;
> -	int index;
> +	int index, saved_index, i;
>  	int nr;
>  	unsigned int length;
>  	int polled = 0;
> @@ -790,6 +790,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	int factor = priv->cqe_factor;
>  	u64 timestamp;
>  	bool l2_tunnel;
> +#define PREFETCH_BATCH 8
> +	struct mlx4_cqe *cqe_array[PREFETCH_BATCH];
> +	int cqe_idx;
> +	bool cqe_more;
>  
>  	if (!priv->port_up)
>  		return 0;
> @@ -801,24 +805,75 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	doorbell_pending = 0;
>  	tx_index = (priv->tx_ring_num - priv->rsv_tx_rings) + cq->ring;
>  
> +next_prefetch_batch:
> +	cqe_idx = 0;
> +	cqe_more = false;
> +
>  	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
>  	 * descriptor offset can be deduced from the CQE index instead of
>  	 * reading 'cqe->index' */
>  	index = cq->mcq.cons_index & ring->size_mask;
> +	saved_index = index;
>  	cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
>  
> -	/* Process all completed CQEs */
> +	/* Extract and prefetch completed CQEs */
>  	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
>  		    cq->mcq.cons_index & cq->size)) {
> +		void *data;
>  
>  		frags = ring->rx_info + (index << priv->log_rx_info);
>  		rx_desc = ring->buf + (index << ring->log_stride);
> +		prefetch(rx_desc);
>  
>  		/*
>  		 * make sure we read the CQE after we read the ownership bit
>  		 */
>  		dma_rmb();
>  
> +		cqe_array[cqe_idx++] = cqe;
> +
> +		/* Base error handling here, free handled in next loop */
> +		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
> +			     MLX4_CQE_OPCODE_ERROR))
> +			goto skip;
> +
> +		data = page_address(frags[0].page) + frags[0].page_offset;
> +		prefetch(data);
> +	skip:
> +		++cq->mcq.cons_index;
> +		index = (cq->mcq.cons_index) & ring->size_mask;
> +		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
> +		/* likely too slow prefetching CQE here ... do look-a-head ? */
> +		//prefetch(cqe + priv->cqe_size * 3);
> +
> +		if (++polled == budget) {
> +			cqe_more = false;
> +			break;
> +		}
> +		if (cqe_idx == PREFETCH_BATCH) {
> +			cqe_more = true;
> +			// IDEA: Opportunistic prefetch CQEs for next_prefetch_batch?
> +			//for (i = 0; i < PREFETCH_BATCH; i++) {
> +			//	prefetch(cqe + priv->cqe_size * i);
> +			//}
> +			break;
> +		}
> +	}
> +	/* Hint: The cqe_idx will be number of packets, it can be used
> +	 * for bulk allocating SKBs
> +	 */
> +
> +	/* Now, index function as index for rx_desc */
> +	index = saved_index;
> +
> +	/* Process completed CQEs in cqe_array */
> +	for (i = 0; i < cqe_idx; i++) {
> +
> +		cqe = cqe_array[i];
> +
> +		frags = ring->rx_info + (index << priv->log_rx_info);
> +		rx_desc = ring->buf + (index << ring->log_stride);
> +
>  		/* Drop packet on bad receive or bad checksum */
>  		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
>  						MLX4_CQE_OPCODE_ERROR)) {
> @@ -1065,14 +1120,13 @@ next:
>  			mlx4_en_free_frag(priv, frags, nr);
>  
>  consumed:
> -		++cq->mcq.cons_index;
> -		index = (cq->mcq.cons_index) & ring->size_mask;
> -		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
> -		if (++polled == budget)
> -			goto out;
> +		++index;
> +		index = index & ring->size_mask;
>  	}
> +	/* Check for more completed CQEs */
> +	if (cqe_more)
> +		goto next_prefetch_batch;
>  
> -out:
>  	if (doorbell_pending)
>  		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
>  
> 

p.s. for achieving 21Mpps drop the mlx4_core need param tuning:
 /etc/modprobe.d/mlx4.conf
 options mlx4_core log_num_mgm_entry_size=-2

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
