From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [v2 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Wed, 9 Jun 2010 13:05:57 +0200
Message-ID: <20100609110556.GC2599@dhcp-lab-161.englab.brq.redhat.com>
References: <20100609100928.6573.14199.sendpatchset@localhost.localdomain> <20100609100938.6573.73536.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, herbert.xu@redhat.com,
	bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com,
	davem@davemloft.net
To: Amerigo Wang <amwang@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966Ab0FILHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 07:07:20 -0400
Content-Disposition: inline
In-Reply-To: <20100609100938.6573.73536.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 06:05:34AM -0400, Amerigo Wang wrote:
> diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
> index d5afd03..2c77805 100644
> --- a/drivers/net/mlx4/en_ethtool.c
> +++ b/drivers/net/mlx4/en_ethtool.c
> @@ -387,6 +387,37 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
>  	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
>  }
>  
> +static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (!(dev->features & NETIF_F_LRO)) {
> +			dev->features |= NETIF_F_LRO;
> +			changed = 1;
> +			mdev->profile.num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);

I do not understand why you override mdev->profile.num_lro in v2 patch.
If in Rx patch NETIF_F_LRO flag is used we do not need this IMHO.

> +		}
> +	} else if (dev->features & NETIF_F_LRO) {
> +		dev->features &= ~NETIF_F_LRO;
> +		changed = 1;
> +		mdev->profile.num_lro = 0;
> +	}
[snip]
>  const struct ethtool_ops mlx4_en_ethtool_ops = {
>  	.get_drvinfo = mlx4_en_get_drvinfo,
>  	.get_settings = mlx4_en_get_settings,
> @@ -415,7 +446,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
>  	.get_ringparam = mlx4_en_get_ringparam,
>  	.set_ringparam = mlx4_en_set_ringparam,
>  	.get_flags = ethtool_op_get_flags,
> -	.set_flags = ethtool_op_set_flags,
> +	.set_flags = mlx4_ethtool_op_set_flags,
>  };

Since we modify .set_flags, please assure we return -EOPNOTSUPP
if someone will try to setup ETH_FLAG_NTUPLE and ETH_FLAG_RXHASH.

BTW: seems default ethtool_op_set_flags introduce a bug on many
devices regarding ETH_FLAG_RXHASH. I think default should
be EOPNOTSUPP, and these few devices that actually support RXHASH
should have custom ethtool_ops->set_flags

Stanislaw
