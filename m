From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RESEND net] net/mlx4_en: Limit the RFS filter IDs to be
 < RPS_NO_FILTER
Date: Wed, 25 Jul 2012 15:57:26 +0100
Message-ID: <1343228246.2694.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343226979-32004-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<oren@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:65356 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030205Ab2GYO5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:57:30 -0400
In-Reply-To: <1343226979-32004-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 17:36 +0300, Or Gerlitz wrote:
> From: Amir Vadai <amirv@mellanox.com>
> 
> RFS filter id can't have the special value RPS_NO_FILTER, 
> need to skip it when allocating id's.
> 
> Also, changed an ifdef into a more elegant IS_DEFINED.
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> 
> Addressing feedback from Ben Hutchings
> 
> resending as of typo in my signature... sorry

--signoff is so much easier than typing it every time :-)

>  drivers/net/ethernet/mellanox/mlx4/en_cq.c     |    8 ++------
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
>  2 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> index aa9c2f6..866829b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> @@ -77,12 +77,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>  	struct mlx4_en_dev *mdev = priv->mdev;
>  	int err = 0;
>  	char name[25];
> -	struct cpu_rmap *rmap =
> -#ifdef CONFIG_RFS_ACCEL
> -		priv->dev->rx_cpu_rmap;
> -#else
> -		NULL;
> -#endif
> +	struct cpu_rmap *rmap = IS_ENABLED(CONFIG_RFS_ACCEL) ?
> +		priv->dev->rx_cpu_rmap : NULL;

This ought to be a separate change really.
 
>  	cq->dev = mdev->pndev[priv->port];
>  	cq->mcq.set_ci_db  = cq->wqres.db.db;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 8864d8b..edd9cb8 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -201,7 +201,7 @@ mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
>  
>  	filter->flow_id = flow_id;
>  
> -	filter->id = priv->last_filter_id++;
> +	filter->id = priv->last_filter_id++ % RPS_NO_FILTER;

This should do for now.

Ideally the filter ID would be based on the index used in hardware.  We
would need to change the API to allow for devices where this cannot be
determined synchronously, as in this driver.  (And the filter ID might
also need to be wider.)

Ben.

>  
>  	list_add_tail(&filter->next, &priv->filters);
>  	hlist_add_head(&filter->filter_chain,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
