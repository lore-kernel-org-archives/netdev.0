From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: avoid unnecessary dirtying of critical
 fields
Date: Mon, 21 Nov 2016 11:09:50 +0200
Message-ID: <32f9297d-96d2-c755-c150-a61dbb721f28@gmail.com>
References: <1479500133.8455.295.camel@edumazet-glaptop3.roam.corp.google.com>
 <62f9c9ee-d710-7493-1094-e8ffe8aaa1ca@gmail.com>
 <1479662102.8455.361.camel@edumazet-glaptop3.roam.corp.google.com>
 <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34886 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753357AbcKUJJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 04:09:53 -0500
Received: by mail-wj0-f193.google.com with SMTP id f8so3434483wje.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 01:09:53 -0800 (PST)
In-Reply-To: <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20/11/2016 7:24 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While stressing a 40Gbit mlx4 NIC with busy polling, I found false
> sharing in mlx4 driver that can be easily avoided.
>
> This patch brings an additional 7 % performance improvement in UDP_RR
> workload.
>
> 1) If we received no frame during one mlx4_en_process_rx_cq()
>     invocation, no need to call mlx4_cq_set_ci() and/or dirty ring->cons
>
> 2) Do not refill rx buffers if we have plenty of them.
>     This avoids false sharing and allows some bulk/batch optimizations.
>     Page allocator and its locks will thank us.
>
> Finally, mlx4_en_poll_rx_cq() should not return 0 if it determined
> cpu handling NIC IRQ should be changed. We should return budget-1
> instead, to not fool net_rx_action() and its netdev_budget.
>
>
> v2: keep AVG_PERF_COUNTER(... polled) even if polled is 0
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c |   47 ++++++++++++-------
>   1 file changed, 30 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 22f08f9ef4645869359783823127c0432fc7a591..6562f78b07f4370b5c1ea2c5e3a4221d7ebaeba8 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -688,18 +688,23 @@ static void validate_loopback(struct mlx4_en_priv *priv, struct sk_buff *skb)
>   	dev_kfree_skb_any(skb);
>   }
>   
> -static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
> -				     struct mlx4_en_rx_ring *ring)
> +static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
> +				      struct mlx4_en_rx_ring *ring)
>   {
> -	int index = ring->prod & ring->size_mask;
> +	u32 missing = ring->actual_size - (ring->prod - ring->cons);
>   
> -	while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
> -		if (mlx4_en_prepare_rx_desc(priv, ring, index,
> +	/* Try to batch allocations, but not too much. */
> +	if (missing < 8)
> +		return false;
> +	do {
> +		if (mlx4_en_prepare_rx_desc(priv, ring,
> +					    ring->prod & ring->size_mask,
>   					    GFP_ATOMIC | __GFP_COLD))
>   			break;
>   		ring->prod++;
> -		index = ring->prod & ring->size_mask;
> -	}
> +	} while (--missing);
> +
> +	return true;
>   }
>   
>   /* When hardware doesn't strip the vlan, we need to calculate the checksum
> @@ -1081,15 +1086,20 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   
>   out:
>   	rcu_read_unlock();
> -	if (doorbell_pending)
> -		mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
>   
> +	if (polled) {
> +		if (doorbell_pending)
> +			mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
> +
> +		mlx4_cq_set_ci(&cq->mcq);
> +		wmb(); /* ensure HW sees CQ consumer before we post new buffers */
> +		ring->cons = cq->mcq.cons_index;
> +	}
>   	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
> -	mlx4_cq_set_ci(&cq->mcq);
> -	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
> -	ring->cons = cq->mcq.cons_index;
> -	mlx4_en_refill_rx_buffers(priv, ring);
> -	mlx4_en_update_rx_prod_db(ring);
> +
> +	if (mlx4_en_refill_rx_buffers(priv, ring))
> +		mlx4_en_update_rx_prod_db(ring);
> +
>   	return polled;
>   }
>   
> @@ -1131,10 +1141,13 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
>   			return budget;
>   
>   		/* Current cpu is not according to smp_irq_affinity -
> -		 * probably affinity changed. need to stop this NAPI
> -		 * poll, and restart it on the right CPU
> +		 * probably affinity changed. Need to stop this NAPI
> +		 * poll, and restart it on the right CPU.
> +		 * Try to avoid returning a too small value (like 0),
> +		 * to not fool net_rx_action() and its netdev_budget
>   		 */
> -		done = 0;
> +		if (done)
> +			done--;
>   	}
>   	/* Done for now */
>   	if (napi_complete_done(napi, done))
>
>
Thanks Eric.
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
