From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Support for configurable RSS
 hash function
Date: Wed, 5 Nov 2014 14:27:46 +0200
Message-ID: <545A17C2.9070609@mellanox.com>
References: <1415188769-19593-1-git-send-email-amirv@mellanox.com> <1415188769-19593-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>, <netdev@vger.kernel.org>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.com>
To: Eyal Perry <eyalpe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog135.obsmtp.com ([207.126.144.213]:54254 "EHLO
	eu1sys200aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbaKEM3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 07:29:40 -0500
In-Reply-To: <1415188769-19593-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2014 1:59 PM, Amir Vadai wrote:
> From: Eyal Perry <eyalpe@mellanox.com>
>
> The ConnectX HW is capable of using one of the following hash functions:
> Toeplitz and an XOR hash function.
> This patch implements ethtool_ops {get,set}_rxfh_func callbacks for the
> mlx4_en driver in order to query and configure the RSS hash function to
> be used by the device.
>
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 40 +++++++++++++++++++++++++
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  9 ++++++
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 ++++---
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +-
>   4 files changed, 58 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 8ea4d5b..f33785a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -973,6 +973,44 @@ static u32 mlx4_en_get_rxfh_indir_size(struct net_device *dev)
>   	return priv->rx_ring_num;
>   }
>   
> +static u32 mlx4_en_get_rxfh_func(struct net_device *dev)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +	return priv->rss_hash_fn;
> +}
> +
> +static int mlx4_en_set_rxfh_func(struct net_device *dev, u32 hfunc)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	u32 prev_rss_hash_fn = priv->rss_hash_fn;
> +	int err = 0;
> +
> +	if (!(hfunc & priv->rss_hash_fn_caps))
> +		return -EINVAL;
> +
> +	priv->rss_hash_fn = hfunc;

Seems that you are blindly setting here priv->rss_hash_fn to the 
function (xor or top) requested
by the user w.o prior checking if the firmware actually supports that 
(e.g test it against priv->rss_hash_fn_caps, right?

> +	if (hfunc == RSS_HASH_TOP && !(dev->features & NETIF_F_RXHASH))
> +		en_warn(priv,
> +			"Toeplitz hash function should be used in conjunction with RX hashing for optimal performance\n");
> +	if (hfunc == RSS_HASH_XOR && (dev->features & NETIF_F_RXHASH))
> +		en_warn(priv,
> +			"Enabling both XOR Hash function and RX Hashing can limit RPS functionality\n");
> +
> +	mutex_lock(&mdev->state_lock);
> +	if (priv->port_up && priv->rss_hash_fn != prev_rss_hash_fn) {
> +		mlx4_en_stop_port(dev, 1);
> +		err = mlx4_en_start_port(dev);
> +	}
> +	mutex_unlock(&mdev->state_lock);
> +
> +	if (err)
> +		en_err(priv, "Failed to restart port %d\n", priv->port);
> +
> +	return err;
> +}
> +
>   static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
>   {
>   	struct mlx4_en_priv *priv = netdev_priv(dev);
> @@ -1799,6 +1837,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
>   	.get_rxnfc = mlx4_en_get_rxnfc,
>   	.set_rxnfc = mlx4_en_set_rxnfc,
>   	.get_rxfh_indir_size = mlx4_en_get_rxfh_indir_size,
> +	.get_rxfh_func = mlx4_en_get_rxfh_func,
> +	.set_rxfh_func = mlx4_en_set_rxfh_func,
>   	.get_rxfh = mlx4_en_get_rxfh,
>   	.set_rxfh = mlx4_en_set_rxfh,
>   	.get_channels = mlx4_en_get_channels,
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 0efbae9..a9e96a6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2585,6 +2585,15 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>   		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
>   	}
>   
> +	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR) {
> +		priv->rss_hash_fn_caps |= RSS_HASH_XOR;
> +		priv->rss_hash_fn = RSS_HASH_XOR;
> +	}
> +	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP) {
> +		priv->rss_hash_fn_caps |= RSS_HASH_TOP;
> +		priv->rss_hash_fn = RSS_HASH_TOP;
> +	}
> +
>   	mdev->pndev[port] = dev;
>   
>   	netif_carrier_off(dev);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index b173a0c..41c1ff9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -1113,10 +1113,13 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
>   	}
>   
>   	rss_context->flags = rss_mask;
> -	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
> -	for (i = 0; i < 10; i++)
> -		rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
> -
> +	if (priv->rss_hash_fn & MLX4_RSS_HASH_XOR) {
> +		rss_context->hash_fn = MLX4_RSS_HASH_XOR;
> +	} else {
> +		rss_context->hash_fn = MLX4_RSS_HASH_TOP;
> +		for (i = 0; i < 10; i++)
> +			rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
> +	}

So this patch effectively changes the default from top to xor, right? is 
that intentional? if yes, spare few words on the change log.


>   	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
>   			       &rss_map->indir_qp, &rss_map->indir_state);
>   	if (err)
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index ef83d12..e1c3364 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -375,7 +375,6 @@ struct mlx4_en_port_profile {
>   };
>   
>   struct mlx4_en_profile {
> -	int rss_xor;
>   	int udp_rss;
>   	u8 rss_mask;
>   	u32 active_ports;
> @@ -615,6 +614,8 @@ struct mlx4_en_priv {
>   	__be16 vxlan_port;
>   
>   	u32 pflags;
> +	u8 rss_hash_fn;
> +	u8 rss_hash_fn_caps;
>   };
>   
>   enum mlx4_en_wol {
