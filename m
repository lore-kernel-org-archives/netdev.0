From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH RFC 3/3] mlx4: Call skb_csum_offload_check to check
 offloadability
Date: Mon, 5 Oct 2015 21:03:30 -0700
Message-ID: <56134812.3000303@gmail.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
 <1444088364-2839440-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, dwmw2@infradead.org, ogerlitz@mellanox.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35823 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbJFEDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:03:32 -0400
Received: by pacfv12 with SMTP id fv12so200645597pac.2
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 21:03:31 -0700 (PDT)
In-Reply-To: <1444088364-2839440-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2015 04:39 PM, Tom Herbert wrote:
> This provides an example of a driver calling the skb_csum_offload_check.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  6 +++---
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 20 +++++++++++++++-----
>   2 files changed, 18 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 4726122..f2ed8d0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2360,7 +2360,7 @@ out:
>   	}
>   
>   	/* set offloads */
> -	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> +	priv->dev->hw_enc_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
>   				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
>   	priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
>   	priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
> @@ -2372,7 +2372,7 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
>   	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
>   						 vxlan_del_task);
>   	/* unset offloads */
> -	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> +	priv->dev->hw_enc_features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
>   				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
>   	priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
>   	priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
> @@ -2943,7 +2943,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>   	/*
>   	 * Set driver features
>   	 */
> -	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
>   	if (mdev->LSO_support)
>   		dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
>   
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 494e776..f364ffd 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -702,6 +702,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
>   	__iowrite64_copy(dst, src, bytecnt / 8);
>   }
>   
> +static const struct skb_csum_offl_spec csum_offl_spec = {
> +	.ipv4_okay = 1,
> +	.ipv6_okay = 1,
> +	.encap_okay = 1,
> +	.tcp_okay = 1,
> +	.udp_okay = 1,
> +};
> +

The question I would have is if inner IPv6 checksum is supported by this 
driver.  The code before didn't seem to indicate it was, and after the 
csum_offl_spec would seem to indicate it is.  One of my concerns about a 
change like this is that it is likely prone to introduce regressions as 
features are going to be toggling due to interpretations of flags and 
assumptions about what is good for the outer headers is good for the 
inner ones.
