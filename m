From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/1] net: fec: report correct hardware stamping info to
 ethtool
Date: Sun, 6 Jan 2013 12:33:50 +0100
Message-ID: <20130106113350.GE1906@pengutronix.de>
References: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, richardcochran@gmail.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.or,
	netdev@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56514 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293Ab3AFLeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 06:34:00 -0500
Content-Disposition: inline
In-Reply-To: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2013 at 09:38:38AM +0800, Frank Li wrote:
> Report correct hardware stamping capibilty by ethtool interface.

s/capibilty/capability/

> The v1.0 ptp4l check it.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.c |   28 +++++++++++++++++++++++++++-
>  1 files changed, 27 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index a379319..c713db5 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1173,12 +1173,38 @@ static void fec_enet_get_drvinfo(struct net_device *ndev,
>  	strcpy(info->bus_info, dev_name(&ndev->dev));
>  }
>  
> +static int fec_enet_get_ts_info(struct net_device *ndev,
> +				struct ethtool_ts_info *info)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	int ret;
> +	ret = ethtool_op_get_ts_info(ndev, info);
> +
> +	if (fep->bufdesc_ex) {
> +
> +		info->so_timestamping |= SOF_TIMESTAMPING_TX_HARDWARE |
> +					 SOF_TIMESTAMPING_RX_HARDWARE |
> +					 SOF_TIMESTAMPING_RAW_HARDWARE;
> +		if (fep->ptp_clock)
> +			info->phc_index = ptp_clock_index(fep->ptp_clock);
> +		else
> +			info->phc_index = -1;
> +
> +		info->tx_types = (1 << HWTSTAMP_TX_OFF) |
> +				 (1 << HWTSTAMP_TX_ON);
> +
> +		info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
> +				   (1 << HWTSTAMP_FILTER_ALL);

		return 0;
	} else {
		return ethtool_op_get_ts_info(ndev, info);
	}

?

Otherwise you call ethtool_op_get_ts_info() and don't use the result
with fep->bufdesc_ex, still you return the return value of
ethtool_op_get_ts_info().

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
