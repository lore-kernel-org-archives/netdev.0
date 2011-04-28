From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [NEXT PATCH 2/3] qlcnic: support rcv ring configuration
 through ethtool
Date: Thu, 28 Apr 2011 01:02:42 +0100
Message-ID: <1303948962.2875.178.camel@bwh-desktop>
References: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
	 <1303951426-4341-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53405 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab1D1ACp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 20:02:45 -0400
In-Reply-To: <1303951426-4341-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-27 at 17:43 -0700, Amit Kumar Salecha wrote:
> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> o Support ethtool command ETHTOOL_GCHANNELS and ETHTOOL_SCHANNELS.
> o Number of rcv rings configuration depend upon number of msix vector.
[...]
> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
> @@ -474,6 +474,49 @@ qlcnic_set_ringparam(struct net_device *dev,
>  	return qlcnic_reset_context(adapter);
>  }
>  
> +static void qlcnic_get_channels(struct net_device *dev,
> +		struct ethtool_channels *channel)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +
> +	channel->max_rx = rounddown_pow_of_two(min_t(int,
> +			adapter->max_rx_ques, num_online_cpus()));
> +	channel->max_tx = adapter->max_tx_ques;
> +
> +	channel->rx_count = adapter->max_sds_rings;
> +	channel->tx_count = QLCNIC_MIN_NUM_TX_DESC_RINGS;
> +}
> +
> +static int qlcnic_set_channels(struct net_device *dev,
> +		struct ethtool_channels *channel)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(dev);
> +	int err;
> +
> +	if (channel->other_count || channel->combined_count)
> +		return -EOPNOTSUPP;

Should be -EINVAL.

> +	if (channel->tx_count &&
> +		(channel->tx_count != QLCNIC_MIN_NUM_TX_DESC_RINGS)) {
> +		netdev_info(dev, "valid value for tx_count 0x%x\n",
> +				QLCNIC_MIN_NUM_TX_DESC_RINGS);
> +		return -EINVAL;
> +	}
[...]

If tx_count cannot be changed, why does qlcnic_get_channels() set
tx_count and max_tx to different values?

Also I don't think you should treat tx_count == 0 as a special case; it
should be rejected as invalid.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

