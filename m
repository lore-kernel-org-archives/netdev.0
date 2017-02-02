From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net v2 1/2] mlx4: Fix memory leak after
 mlx4_en_update_priv()
Date: Thu, 2 Feb 2017 19:10:29 +0200
Message-ID: <c87f2ad7-655e-771a-4c09-ba7d7005a18a@mellanox.com>
References: <1485930933-4159518-1-git-send-email-kafai@fb.com>
 <1485930933-4159518-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Eugenia Emantayev <eugenia@mellanox.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0066.outbound.protection.outlook.com ([104.47.1.66]:49516
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751316AbdBBRKh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 12:10:37 -0500
In-Reply-To: <1485930933-4159518-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

Thanks for your fix!

On 01/02/2017 8:35 AM, Martin KaFai Lau wrote:
> In mlx4_en_update_priv(), dst->tx_ring[t] and dst->tx_cq[t]
> are over-written by src->tx_ring[t] and src->tx_cq[t] without
> first calling kfree.
>
> One of the reproducible code paths is by doing 'ethtool -L'.
>
> The fix is to do the kfree in mlx4_en_free_resources().
>
...
> Fixes: ec25bc04ed8e ("net/mlx4_en: Add resilience in low memory systems")
> Cc: Eugenia Emantayev <eugenia@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 761f8b12399c..3abcead208d2 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2042,6 +2042,8 @@ static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
>   			if (priv->tx_cq[t] && priv->tx_cq[t][i])
>   				mlx4_en_destroy_cq(priv, &priv->tx_cq[t][i]);
>   		}
> +		kfree(priv->tx_ring[t]);
> +		kfree(priv->tx_cq[t]);
>   	}
>   
>   	for (i = 0; i < priv->rx_ring_num; i++) {
> @@ -2214,7 +2216,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
>   {
>   	struct mlx4_en_priv *priv = netdev_priv(dev);
>   	struct mlx4_en_dev *mdev = priv->mdev;
> -	int t;
>   
>   	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
>   
> @@ -2248,11 +2249,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
>   	mlx4_en_free_resources(priv);
>   	mutex_unlock(&mdev->state_lock);
>   
> -	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
> -		kfree(priv->tx_ring[t]);
> -		kfree(priv->tx_cq[t]);
> -	}
> -
>   	free_netdev(dev);
>   }
>   
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
