From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] mlx4_en: Change BQL reset TX queue call point
Date: Sun, 3 Feb 2013 08:39:22 +0200
Message-ID: <510E061A.2070401@mellanox.com>
References: <alpine.DEB.2.00.1302011659200.14247@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <yevgenyp@mellanox.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:45728 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751381Ab3BCGjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 01:39:31 -0500
In-Reply-To: <alpine.DEB.2.00.1302011659200.14247@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2013 03:02, Tom Herbert wrote:
> Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
> was not being called in certain situations where the device was
> being start and stopped.  Moved netdev_tx_reset_queue from the reset
> device path to mlx4_en_free_tx_buf which is where the rings are
> cleaned in a reset (specifically from device being stopped).
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 3 ---
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 2 ++
>   2 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index b467513..075fdff 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1284,15 +1284,12 @@ static void mlx4_en_restart(struct work_struct *work)
>   						 watchdog_task);
>   	struct mlx4_en_dev *mdev = priv->mdev;
>   	struct net_device *dev = priv->dev;
> -	int i;
>
>   	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
>
>   	mutex_lock(&mdev->state_lock);
>   	if (priv->port_up) {
>   		mlx4_en_stop_port(dev);
> -		for (i = 0; i < priv->tx_ring_num; i++)
> -			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
>   		if (mlx4_en_start_port(dev))
>   			en_err(priv, "Failed restarting port %d\n", priv->port);
>   	}
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index c579311..3c17732 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -294,6 +294,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>   		cnt++;
>   	}
>
> +	netdev_tx_reset_queue(ring->tx_queue);
> +
>   	if (cnt)
>   		en_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);
>
>

Acked-by: Amir Vadai <amirv@mellanox.com>
