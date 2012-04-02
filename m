From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 net-next 02/28] ethtool: Introduce a method for
 getting time stamping capabilities.
Date: Mon, 2 Apr 2012 18:32:53 +0100
Message-ID: <1333387973.2623.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
	 <c212a85e0d09c1e6d38db901bcdfb605484984e9.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42539 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752671Ab2DBRc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 13:32:58 -0400
In-Reply-To: <c212a85e0d09c1e6d38db901bcdfb605484984e9.1333289292.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-01 at 17:19 +0200, Richard Cochran wrote:
> This commit adds a new ethtool ioctl that exposes the SO_TIMESTAMPING
> capabilities of a network interface. In addition, user space programs
> can use this ioctl to discover the PTP Hardware Clock (PHC) device
> associated with the interface.
> 
> Since software receive time stamps are handled by the stack, the generic
> ethtool code can answer the query correctly in case the MAC or PHY
> drivers lack special time stamping features.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  include/linux/ethtool.h |   23 +++++++++++++++++++++++
>  include/linux/phy.h     |    3 +++
>  net/core/ethtool.c      |   36 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 62 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e1d9e0e..776b3d0 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -726,6 +726,24 @@ struct ethtool_sfeatures {
>  	struct ethtool_set_features_block features[0];
>  };
>  
> +/**
> + * struct ethtool_ts_info - holds a device's timestamping and PHC association
> + * @cmd: command number = %ETHTOOL_GET_TS_INFO
> + * @so_timestamping: bit mask of SO_TIMESTAMPING modes supported by the device

So that means a sum of SOF_TIMESTAMPING_mode flags

> + * @phc_index: device index of the associated PHC, or -1 if there is none
> + * @tx_types: bit mask of hwtstamp_tx_types modes supported by the device

whereas this is a sum of (1 << HWTSTAMP_TX_mode) flags

> + * @rx_filters: bit mask of hwtstamp_rx_filters modes supported by the device

and this is a sum of (1 << HWTSTAMP_FILTER_mode) flags?

Maybe you should explicitly point out the need for shifting in the
latter two.

[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
[...]
> @@ -1278,6 +1280,37 @@ out:
>  	return ret;
>  }
>  
> +static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
> +{
> +	int err = 0;
> +	struct ethtool_ts_info info;
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> +	struct phy_device *phydev = dev->phydev;
> +
> +	memset(&info, 0, sizeof(info));
> +	info.cmd = ETHTOOL_GET_TS_INFO;
> +
> +	if (phydev && phydev->drv && phydev->drv->ts_info)
> +		err = phydev->drv->ts_info(phydev, &info);
> +
> +	else if (dev->ethtool_ops->get_ts_info)
> +		err = ops->get_ts_info(dev, &info);
> +	else {
> +		info.so_timestamping =
> +			SOF_TIMESTAMPING_RX_SOFTWARE |
> +			SOF_TIMESTAMPING_SOFTWARE;
> +		info.phc_index = -1;
> +	}
[...]

Given that this doesn't require specific support from the driver,
shouldn't it be made to work without dev->ethtool_ops being set at all
(as for ETHTOOL_GDRVINFO)?

Also should it require CAP_NET_ADMIN?  I think it probably shouldn't, in
which case you need to add it to the list of commands for which we don't
check that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
