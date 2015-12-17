From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/4] net/mlx5e: Restore the skb data
 pointer after xmit is finished
Date: Thu, 17 Dec 2015 15:21:04 -0500 (EST)
Message-ID: <20151217.152104.2240043588504838923.davem@davemloft.net>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
	<1450355735-30846-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, eranbe@mellanox.com,
	talal@mellanox.com, richardcochran@gmail.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018AbbLQUVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:21:06 -0500
In-Reply-To: <1450355735-30846-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 17 Dec 2015 14:35:32 +0200

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> index 1341b1d..0fcfe64 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> @@ -165,6 +165,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
>  	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
>  	struct mlx5_wqe_data_seg *dseg;
>  
> +	unsigned char *skb_data_orig = skb->data;
>  	u8  opcode = MLX5_OPCODE_SEND;
>  	dma_addr_t dma_addr = 0;
>  	bool bf = false;
> @@ -263,6 +264,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
>  	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
>  	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
>  
> +	skb_push(skb, skb->data - skb_data_orig);
>  	sq->skb[pi] = skb;
>  
>  	MLX5E_TX_SKB_CB(skb)->num_wqebbs = DIV_ROUND_UP(ds_cnt,

And in the middle of this we have:

		skb_pull_inline(skb, ihs);

This is looks illegal.

You must not modify the data pointers of any SKB that you receive for
sending via ->ndo_start_xmit() unless you know that absolutely you are
the one and only reference that exists to that SKB.

And exactly for the case you are trying to "fix" here, you do not.  If
the SKB is cloned, or has an elevated users count, someone else can be
looking at it exactly at the same time you are messing with the data
pointers.

I bet mlx4 has this bug too.

You must fix this properly, by keeping track of an offset or similar
internally to your driver, rather than changing the SKB data pointers.

Thanks.
