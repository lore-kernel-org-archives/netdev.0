From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/7] mlx4: use napi_consume_skb API to get
 bulk free operations
Date: Tue, 08 Mar 2016 14:24:22 -0500 (EST)
Message-ID: <20160308.142422.1791364638495761357.davem@davemloft.net>
References: <20160304130054.32651.51776.stgit@firesoul>
	<20160304130133.32651.55278.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	saeedm@mellanox.com, gerlitz.or@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcCHTYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:24:25 -0500
In-Reply-To: <20160304130133.32651.55278.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Mar 2016 14:01:33 +0100

> @@ -276,7 +276,8 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
>  
>  static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
>  				struct mlx4_en_tx_ring *ring,
> -				int index, u8 owner, u64 timestamp)
> +				int index, u8 owner, u64 timestamp,
> +				int napi_mode)
>  {
>  	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
>  	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
> @@ -347,7 +348,11 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
>  			}
>  		}
>  	}
> -	dev_consume_skb_any(skb);
> +	if (unlikely(napi_mode < 0))
> +		dev_consume_skb_any(skb); /* none-NAPI via mlx4_en_stop_port */
> +	else
> +		napi_consume_skb(skb, napi_mode);
> +
>  	return tx_info->nr_txbb;
>  }

If '0' is the signal that napi_consume_skb() uses to detect the case where we
can't bulk, just pass that instead of having a special test here on yet another
special value "-1".

If it makes any nicer, you can define a NAPI_BUDGET_FROM_NETPOLL macro
or similar.

I also wonder if passing the budget around all the way down to
napi_consume_skb() is the cleanest thing to do, as we just want to
know if bulk freeing is possible or not.
