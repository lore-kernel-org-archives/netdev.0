From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2] mlx4_en: Fix BQL reset TX queue call point
Date: Thu, 7 Feb 2013 08:52:35 +0200
Message-ID: <51134F33.1030007@mellanox.com>
References: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:45902 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751162Ab3BGGwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 01:52:41 -0500
In-Reply-To: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2013 19:58, Tom Herbert wrote:
> Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
> was not being called in certain situations where the device was
> being start and stopped.  Moved netdev_tx_reset_queue from the reset
> device path to mlx4_en_free_tx_buf which is where the rings are
> cleaned in a reset (specifically from device being stopped).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 3 ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 2 ++
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index ac1c14f..94042f6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1323,15 +1323,12 @@ static void mlx4_en_restart(struct work_struct *work)
>  						 watchdog_task);
>  	struct mlx4_en_dev *mdev = priv->mdev;
>  	struct net_device *dev = priv->dev;
> -	int i;
>  
>  	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
>  
>  	mutex_lock(&mdev->state_lock);
>  	if (priv->port_up) {
>  		mlx4_en_stop_port(dev, 1);
> -		for (i = 0; i < priv->tx_ring_num; i++)
> -			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
>  		if (mlx4_en_start_port(dev))
>  			en_err(priv, "Failed restarting port %d\n", priv->port);
>  	}
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 30724d8..e06fce7 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -294,6 +294,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>  		cnt++;
>  	}
>  
> +	netdev_tx_reset_queue(ring->tx_queue);
> +
>  	if (cnt)
>  		en_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);
>  
> 

Acked-By: Amir Vadai <amirv@mellanox.com>
