From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/9] net/mlx4_core: Enforce irq affinity
 changes immediatly
Date: Mon, 12 May 2014 06:57:08 -0700
Message-ID: <1399903028.7973.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
	 <1399880605-28772-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:39722 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaELN5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:57:10 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so8638161pab.28
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 06:57:10 -0700 (PDT)
In-Reply-To: <1399880605-28772-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 10:43 +0300, Amir Vadai wrote:
> From: Yuval Atias <yuvala@mellanox.com>
> 
> During heavy traffic, napi is constatntly polling the complition queue
> and no interrupt is fired. Because of that, changes to irq affinity are
> ignored until traffic is stopped and resumed.
> 
> By registering to the irq notifier mechanism, and forcing interrupt when
> affinity is changed, irq affinity changes will be immediatly enforced.
> 
> Signed-off-by: Yuval Atias <yuvala@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---

Interesting. Its a bit sad it has to be in fast path...

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 89585c6..81b7571 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -474,9 +474,15 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
>  	/* If we used up all the quota - we're probably not done yet... */
>  	if (done < budget) {
>  		/* Done for now */
> +		cq->mcq.irq_affinity_change = 0;


>  		napi_complete(napi);
>  		mlx4_en_arm_cq(priv, cq);
>  		return done;
> +	} else if (unlikely(cq->mcq.irq_affinity_change)) {
> +		cq->mcq.irq_affinity_change = 0;
> +		napi_complete(napi);
> +		mlx4_en_arm_cq(priv, cq);
> +		return 0;
>  	}
>  	return budget;


>  			priv->msix_ctl.pool_bm &= ~(1ULL << i);
> diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
> index ba87bd2..74f5aa8 100644
> --- a/include/linux/mlx4/device.h
> +++ b/include/linux/mlx4/device.h
> @@ -586,6 +586,8 @@ struct mlx4_cq {
>  
>  	atomic_t		refcount;
>  	struct completion	free;
> +	u16                     irq;
> +	bool                    irq_affinity_change;
>  };
>  
>  struct mlx4_qp {

But could you place irq_affinity_change in another cache line ?

It seems there is a 32bit hole between cons_index and set_ci_db

(Both fields can be moved)

Thanks
