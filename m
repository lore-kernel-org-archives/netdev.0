From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Mon, 1 Oct 2012 16:08:45 +0100
Message-ID: <1349104125.2577.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
	 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eugenia@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21616 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751085Ab2JAPIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 11:08:49 -0400
In-Reply-To: <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-28 at 12:03 +0200, Yevgeny Petrilin wrote:
> From: Eugenia Emantayev <eugenia@mellanox.co.il>
> 
> The patch allows to enable/disable HW timestamping for incoming and/or
> outgoing packets. It adds and initializes all structs and callbacks
> needed by kernel TS API.
> To enable/disable HW timestamping appropriate ioctl should be used.
> Currently HWTSTAMP_FILTER_ALL/NONE and HWTSAMP_TX_ON/OFF only are
> supported.
> When enabling TS on receive flow - VLAN stripping will be disabled.
> Also were made all relevant changes in RX/TX flows to consider TS request
> and plant HW timestamps into relevant structures.
> mlx4_ib was fixed to compile with new mlx4_cq_alloc() signature.
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_timestamp.c
[...]
> +int mlx4_en_timestamp_config(struct net_device *dev, int tx_type, int rx_filter)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
> +	int port_up = 0;
> +	int err = 0;
> +
> +	mutex_lock(&mdev->state_lock);
> +	if (priv->port_up) {
> +		port_up = 1;
> +		mlx4_en_stop_port(dev);
> +	}
> +
> +	mlx4_en_free_resources(priv);
> +
> +	en_err(priv, "Changing Time Stamp configuration\n");
> +
> +	priv->hwtstamp_config.tx_type = tx_type;
> +	priv->hwtstamp_config.rx_filter = rx_filter;
> +
> +	if (rx_filter != HWTSTAMP_FILTER_NONE)
> +		dev->features &= ~NETIF_F_HW_VLAN_RX;
> +	else
> +		dev->features |= NETIF_F_HW_VLAN_RX;
[...]

If you change dev->features you should also call
netdev_features_change(dev) (holding only the RTNL lock, so after you
unlock mdev->state_lock).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
