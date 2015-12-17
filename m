From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V1 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Thu, 17 Dec 2015 21:18:32 +0100
Message-ID: <20151217201832.GB5975@localhost.localdomain>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
 <1450355735-30846-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37927 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086AbbLQUSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:18:38 -0500
Received: by mail-wm0-f47.google.com with SMTP id l126so37884056wml.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 12:18:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450355735-30846-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 02:35:34PM +0200, Saeed Mahameed wrote:
> +static int mlx5e_get_ts_info(struct net_device *dev,
> +			     struct ethtool_ts_info *info)
> +{
> +	struct mlx5e_priv *priv = netdev_priv(dev);
> +	int ret;
> +
> +	ret = ethtool_op_get_ts_info(dev, info);
> +	if (ret)
> +		return ret;
> +
> +	if (MLX5_CAP_GEN(priv->mdev, device_frequency_khz)) {
> +		info->so_timestamping |=
> +				SOF_TIMESTAMPING_TX_HARDWARE |
> +				SOF_TIMESTAMPING_RX_HARDWARE |
> +				SOF_TIMESTAMPING_RAW_HARDWARE;
> +
> +		info->tx_types =
> +				(1 << HWTSTAMP_TX_OFF) |
> +				(1 << HWTSTAMP_TX_ON);
> +
> +		info->rx_filters =
> +				(1 << HWTSTAMP_FILTER_NONE) |
> +				(1 << HWTSTAMP_FILTER_ALL);
> +	}

Here you need:

	info->phc_index = -1;

and then in the next patch, use the PHC index when available.

> +	return 0;
> +}
> +

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index 7c8c408..4ae70cd 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -36,6 +36,10 @@
>  #include <net/busy_poll.h>
>  #include "en.h"
>  
> +#define MLX5E_RX_HW_STAMP(priv)				\
> +	(priv->tstamp.hwtstamp_config.rx_filter ==	\
> +		     HWTSTAMP_FILTER_ALL)

Use an inline function, please.  Also, that line fits in 80 columns
easily.

> +	if (MLX5E_RX_HW_STAMP(priv))
> +		mlx5e_fill_hwstamp(&priv->tstamp, skb_hwtstamps(skb),
> +				   get_cqe_ts(cqe));
> +

> +#define MLX5E_TX_HW_STAMP(priv, skb)					\
> +	(priv->tstamp.hwtstamp_config.tx_type == HWTSTAMP_TX_ON &&	\
> +	skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)

Use inline function.

Thanks,
Richard
