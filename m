From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 4/5] alx: add alx_get_stats64 operation
Date: Mon, 6 Jan 2014 19:07:33 +0000
Message-ID: <1389035253.9947.93.camel@bwh-desktop.uk.level5networks.com>
References: <1389026023-18743-1-git-send-email-sd@queasysnail.net>
	 <1389026023-18743-5-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49886 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbaAFTHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 14:07:37 -0500
In-Reply-To: <1389026023-18743-5-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 17:33 +0100, Sabrina Dubroca wrote:
[...]
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -1166,10 +1166,54 @@ static void alx_poll_controller(struct net_device *netdev)
>  }
>  #endif
>  
> +static struct rtnl_link_stats64 *alx_get_stats64(struct net_device *dev,
> +					struct rtnl_link_stats64 *net_stats)
> +{
> +	struct alx_priv *alx = netdev_priv(dev);
> +	struct alx_hw_stats *hw_stats = &alx->hw.stats;
> +
> +	spin_lock(&alx->stats_lock);
> +
> +	alx_update_hw_stats(&alx->hw);
> +
> +	net_stats->tx_packets = hw_stats->tx_ok;

I think this should be set to hw_stats->tx_ok + net_stats->tx_errors
(after you set tx_errors).

> +	net_stats->tx_bytes   = hw_stats->tx_byte_cnt;
> +	net_stats->rx_packets = hw_stats->rx_ok;

Similarly, I think this should be hw_stats->rx_ok +
net_stats->rx_errors.

> +	net_stats->rx_bytes   = hw_stats->rx_byte_cnt;
> +	net_stats->multicast  = hw_stats->rx_mcast;
> +	net_stats->collisions = hw_stats->tx_single_col +
> +				hw_stats->tx_multi_col * 2 +

I would expect this to count the number of packets that had collisions
rather than total number of collisions (which you're only guessing at by
using * 2).

> +				hw_stats->tx_late_col + hw_stats->tx_abort_col;
> +
> +	net_stats->rx_errors  = hw_stats->rx_frag + hw_stats->rx_fcs_err +
> +				hw_stats->rx_len_err + hw_stats->rx_ov_sz +
> +				hw_stats->rx_ov_rrd + hw_stats->rx_align_err;
> +
> +	net_stats->rx_fifo_errors   = hw_stats->rx_ov_rxf;
> +	net_stats->rx_length_errors = hw_stats->rx_len_err;
> +	net_stats->rx_crc_errors    = hw_stats->rx_fcs_err;
> +	net_stats->rx_frame_errors  = hw_stats->rx_align_err;
> +	net_stats->rx_over_errors   = hw_stats->rx_ov_rrd + hw_stats->rx_ov_rxf;

rx_over_errors is commented as 'receiver ring buff overflow' and
ifconfig includes it in the 'frame' error count.  I think it is intended
to count frames which are too large for on-chip RX buffers and should
always be 0 for devices that do RX DMA.

Each error should contribute to at most one specific error stat, so
don't count rx_ov_rxf in both rx_fifo_errors and rx_over_errors.  I
would guess rx_fifo_errors is the right counter.

I don't know what rx_ov_rrd represents, but if it's the number of
packets dropped because the RX descriptor ring was empty then it should
be counted in rx_dropped not rx_over_errors.

> +	net_stats->rx_missed_errors = hw_stats->rx_ov_rrd + hw_stats->rx_ov_rxf;
[...]

This counter is commented as 'receiver missed packet'.  I think this
means the MAC detected SOF but was somehow too busy to receive the
packet, but I'm not sure.  I don't think these hardware counters match
the description, and certainly they shouldn't be counted here as well as
the other specific error stats.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
