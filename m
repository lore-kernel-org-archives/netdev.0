From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V4 8/8] net/mlx4_en: Set max rate-limit for a TC
Date: Thu, 29 Mar 2012 17:21:10 +0200
Message-ID: <1333034470.2325.751.camel@edumazet-glaptop>
References: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
	 <1333033418-1669-9-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51754 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933532Ab2C2PVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 11:21:14 -0400
Received: by eekc41 with SMTP id c41so1094219eek.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 08:21:13 -0700 (PDT)
In-Reply-To: <1333033418-1669-9-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 17:03 +0200, Amir Vadai wrote:
> This patch is using the DCB netlink to set rate limit per ETS TC
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   31 ++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    7 +++++
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 +-
>  3 files changed, 39 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> index 5bf0106..0f92b2e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> @@ -100,6 +100,7 @@ static int mlx4_en_config_port_scheduler(struct mlx4_en_priv *priv,
>  	__u8 pg[IEEE_8021QAZ_MAX_TCS] = { 0 };
>  
>  	ets = ets ?: priv->mlx4_en_ieee_ets;
> +	ratelimit = ratelimit ?: priv->maxrate->tc_maxrate;
>  
>  	/* higher TC means higher priority => lower pg */
>  	for (i = IEEE_8021QAZ_MAX_TCS - 1; i >= 0; i--) {
> @@ -200,9 +201,39 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
>  	return 0;
>  }
>  
> +static int mlx4_en_dcbnl_ieee_getmaxrate(struct net_device *dev,
> +				   struct ieee_maxrate *maxrate)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->maxrate)
> +		return -EINVAL;
> +
> +	memcpy(maxrate, priv->maxrate, sizeof(maxrate));

sizeof(*maxrate) is probably what you wanted ?

> +
> +	return 0;
> +}
> +
> +static int mlx4_en_dcbnl_ieee_setmaxrate(struct net_device *dev,
> +		struct ieee_maxrate *maxrate)
> +{
> +	int err;
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +	err = mlx4_en_config_port_scheduler(priv, NULL, maxrate->tc_maxrate);
> +	if (err)
> +		return err;
> +
> +	memcpy(priv->maxrate, maxrate, sizeof(priv->maxrate));

Really ?

sizeof(priv->maxrate) seems to be 8/4 (sizeof a pointer)



> +
> +	return 0;
> +}
> +
>  const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
>  	.ieee_getets	= mlx4_en_dcbnl_ieee_getets,
>  	.ieee_setets	= mlx4_en_dcbnl_ieee_setets,
> +	.ieee_getmaxrate = mlx4_en_dcbnl_ieee_getmaxrate,
> +	.ieee_setmaxrate = mlx4_en_dcbnl_ieee_setmaxrate,
>  	.ieee_getpfc	= mlx4_en_dcbnl_ieee_getpfc,
>  	.ieee_setpfc	= mlx4_en_dcbnl_ieee_setpfc,
>  
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 44dbe1f..be7ffbf 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -978,6 +978,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
>  
>  #ifdef CONFIG_MLX4_EN_DCB
>  	vfree(priv->mlx4_en_ieee_ets);
> +	vfree(priv->maxrate);
>  #endif
>  
>  	free_netdev(dev);
> @@ -1103,6 +1104,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>  			err = -ENOMEM;
>  			goto out;
>  		}
> +
> +		priv->maxrate = vzalloc(sizeof(struct ieee_maxrate));

vzalloc() ? What is the size of struct ieee_maxrate ?

> +		if (!priv->maxrate) {
> +			err = -ENOMEM;
> +			goto out;
> +		}
>  	}
>  #endif
>  
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index fa09792..d1f5ac2 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -420,7 +420,6 @@ struct mlx4_en_frag_info {
>  #define MLX4_EN_BW_MAX 100 /* Utilize 100% of the line */
>  
>  #define MLX4_EN_TC_ETS 7
> -
>  #endif
>  
>  struct mlx4_en_priv {
> @@ -499,6 +498,7 @@ struct mlx4_en_priv {
>  
>  #ifdef CONFIG_MLX4_EN_DCB
>  	struct ieee_ets *mlx4_en_ieee_ets;
> +	struct ieee_maxrate *maxrate;
>  #endif
>  };
>  
