From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Wed, 23 Jan 2013 20:39:44 +0000
Message-ID: <1358973584.2658.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <s.hauer@pengutronix.de>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41853 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3AWUjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 15:39:48 -0500
In-Reply-To: <1358391358-27977-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 10:55 +0800, Frank Li wrote:
> The limition of imx6 internal bus cause fec can't achieve 1G perfomance.
> There will be many packages lost because FIFO over run.
> 
> This patch enable pause frame flow control.
[...]
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
[...]
> +static int fec_enet_set_pauseparam(struct net_device *ndev,
> +				   struct ethtool_pauseparam *pause)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +
> +	if (pause->tx_pause != pause->rx_pause) {
> +		netdev_info(ndev,
> +			"hardware only support enable/disable both tx and rx");
> +		return -EINVAL;
> +	}
> +
> +	fep->pause_flag = 0;
> +
> +	/* tx pause must be same as rx pause */
> +	fep->pause_flag |= pause->rx_pause ? FEC_PAUSE_FLAG_ENABLE : 0;
> +	fep->pause_flag |= pause->autoneg ? FEC_PAUSE_FLAG_AUTONEG : 0;
> +
> +	if (pause->rx_pause || pause->autoneg) {
> +		fep->phy_dev->supported |= ADVERTISED_Pause;
> +		fep->phy_dev->advertising |= ADVERTISED_Pause;
> +	} else {
> +		fep->phy_dev->supported &= ~ADVERTISED_Pause;
> +		fep->phy_dev->advertising &= ~ADVERTISED_Pause;
> +	}
[...]

Why is this changing the supported flags, i.e. device capabilities?  You
need to leave those flags alone and reject an attempt to enable pause
frames on a device that doesn't support them.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
