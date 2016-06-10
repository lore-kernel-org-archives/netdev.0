From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/7] mlx4: protect mlx4_en_start_port in
 mlx4_en_restart with rtnl_lock
Date: Fri, 10 Jun 2016 13:55:01 -0700
Message-ID: <1465592101.7945.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
	 <1461007188-1603-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35734 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbcFJUzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 16:55:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id t190so5700224pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 13:55:03 -0700 (PDT)
In-Reply-To: <1461007188-1603-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 21:19 +0200, Hannes Frederic Sowa wrote:
> mlx4_en_start_port requires rtnl_lock to be held.
> 
> Cc: Eugenia Emantayev <eugenia@mellanox.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index b4b258c8ca47d4..8bd143dda95d11 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1856,6 +1856,7 @@ static void mlx4_en_restart(struct work_struct *work)
>  
>  	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
>  
> +	rtnl_lock();
>  	mutex_lock(&mdev->state_lock);
>  	if (priv->port_up) {
>  		mlx4_en_stop_port(dev, 1);
> @@ -1863,6 +1864,7 @@ static void mlx4_en_restart(struct work_struct *work)
>  			en_err(priv, "Failed restarting port %d\n", priv->port);
>  	}
>  	mutex_unlock(&mdev->state_lock);
> +	rtnl_unlock();
>  }
>  
>  static void mlx4_en_clear_stats(struct net_device *dev)

It looks that this work queue is not canceled at device dismantle.

I suspect a use after free is possible.
