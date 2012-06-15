From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next patch 9/12] bnx2x: Add support for ethtool -L
Date: Fri, 15 Jun 2012 18:03:18 +0100
Message-ID: <1339779798.2555.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
	 <1339591464-10554-10-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eilong@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13040 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751081Ab2FORDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 13:03:21 -0400
In-Reply-To: <1339591464-10554-10-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> Add support for ethtool -L/-l for setting and getting the number of RSS queues.
> The 'combined' field is used as we don't support separate IRQ for Rx and Tx.
[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> @@ -2809,6 +2809,85 @@ static int bnx2x_set_rxfh_indir(struct net_device *dev, const u32 *indir)
>  	return bnx2x_config_rss_eth(bp, false);
>  }
>  
> +/**
> + * bnx2x_get_channels - gets the number of RSS queues.
> + *
> + * @dev:		net device
> + * @channels:		returns the number of max / current queues
> + */
> +static void bnx2x_get_channels(struct net_device *dev,
> +			       struct ethtool_channels *channels)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +
> +	channels->max_rx = channels->max_tx = channels->max_other = 0;
> +	channels->max_combined = BNX2X_MAX_RSS_COUNT(bp);
> +	channels->rx_count = channels->tx_count = channels->other_count = 0;
> +	channels->combined_count = BNX2X_NUM_ETH_QUEUES(bp);

Don't bother setting fields to 0; you can assume the ethtool core does
that for you.

> +}
> +
> +/**
> + * bnx2x_change_num_queues - change the number of RSS queues.
> + *
> + * @bp:			bnx2x private structure
> + *
> + * Re-configure interrupt mode to get the new number of MSI-X
> + * vectors and re-add NAPI objects.
> + */
> +static void bnx2x_change_num_queues(struct bnx2x *bp, int num_rss)
> +{
> +	bnx2x_del_all_napi(bp);
> +	bnx2x_disable_msi(bp);
> +	BNX2X_NUM_QUEUES(bp) = num_rss + NON_ETH_CONTEXT_USE;

The NON_ETH_CONTEXT_USE queues could possibly be counted as 'other'.
Depends on how closely they are associated with the net device.

> +	bnx2x_set_int_mode(bp);
> +	bnx2x_add_all_napi(bp);
> +}
> +
> +/**
> + * bnx2x_set_channels - sets the number of RSS queues.
> + *
> + * @dev:		net device
> + * @channels:		includes the number of queues requested
> + */
> +static int bnx2x_set_channels(struct net_device *dev,
> +			      struct ethtool_channels *channels)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +
> +
> +	DP(BNX2X_MSG_ETHTOOL,
> +	   "set-channels command parameters: rx = %d, tx = %d, other = %d, combined = %d\n",
> +	   channels->rx_count, channels->tx_count, channels->other_count,
> +	   channels->combined_count);
> +
> +	/* We don't support separate rx / tx channels.
> +	 * We don't allow setting 'other' channels.
> +	 */
> +	if (channels->rx_count || channels->tx_count || channels->other_count
> +	    || (channels->combined_count > BNX2X_MAX_RSS_COUNT(bp))) {

Missing a check for combined_count == 0.

Ben.

> +		DP(BNX2X_MSG_ETHTOOL, "command parameters not supported\n");
> +		return -EINVAL;
> +	}
> +
> +	/* Check if there was a change in the active parameters */
> +	if (channels->combined_count == BNX2X_NUM_ETH_QUEUES(bp)) {
> +		DP(BNX2X_MSG_ETHTOOL, "No change in active parameters\n");
> +		return 0;
> +	}
> +
> +	/* Set the requested number of queues in bp context.
> +	 * Note that the actual number of queues created during load may be
> +	 * less than requested if memory is low.
> +	 */
> +	if (unlikely(!netif_running(dev))) {
> +		bnx2x_change_num_queues(bp, channels->combined_count);
> +		return 0;
> +	}
> +	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> +	bnx2x_change_num_queues(bp, channels->combined_count);
> +	return bnx2x_nic_load(bp, LOAD_NORMAL);
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
