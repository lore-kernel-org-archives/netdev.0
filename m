From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 4/5] alx: add alx_get_stats64 operation
Date: Thu, 9 Jan 2014 18:47:05 +0000
Message-ID: <1389293225.2025.11.camel@bwh-desktop.uk.level5networks.com>
References: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
	 <1389258571-10083-5-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52416 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046AbaAISrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:47:11 -0500
In-Reply-To: <1389258571-10083-5-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 10:09 +0100, Sabrina Dubroca wrote:
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
> 
> I've modified the assignements of hw stats to netstats here as Ben asked in v3.
> 
> The other atheros drivers use the same code as v3. Should I modify
> them as well in another patch?

That seems like a good thing to do.

Ben.

> 
>  drivers/net/ethernet/atheros/alx/alx.h  |  3 ++
>  drivers/net/ethernet/atheros/alx/main.c | 50 +++++++++++++++++++++++++++++++++
>  2 files changed, 53 insertions(+)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
> index d71103d..8fc93c5 100644
> --- a/drivers/net/ethernet/atheros/alx/alx.h
> +++ b/drivers/net/ethernet/atheros/alx/alx.h
> @@ -106,6 +106,9 @@ struct alx_priv {
>  	u16 msg_enable;
>  
>  	bool msi;
> +
> +	/* protects hw.stats */
> +	spinlock_t stats_lock;
>  };
>  
>  extern const struct ethtool_ops alx_ethtool_ops;
> diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
> index c3c4c26..e92ffd6 100644
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -1166,10 +1166,60 @@ static void alx_poll_controller(struct net_device *netdev)
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
> +	net_stats->tx_bytes   = hw_stats->tx_byte_cnt;
> +	net_stats->rx_bytes   = hw_stats->rx_byte_cnt;
> +	net_stats->multicast  = hw_stats->rx_mcast;
> +	net_stats->collisions = hw_stats->tx_single_col +
> +				hw_stats->tx_multi_col +
> +				hw_stats->tx_late_col +
> +				hw_stats->tx_abort_col;
> +
> +	net_stats->rx_errors  = hw_stats->rx_frag +
> +				hw_stats->rx_fcs_err +
> +				hw_stats->rx_len_err +
> +				hw_stats->rx_ov_sz +
> +				hw_stats->rx_ov_rrd +
> +				hw_stats->rx_align_err +
> +				hw_stats->rx_ov_rxf;
> +
> +	net_stats->rx_fifo_errors   = hw_stats->rx_ov_rxf;
> +	net_stats->rx_length_errors = hw_stats->rx_len_err;
> +	net_stats->rx_crc_errors    = hw_stats->rx_fcs_err;
> +	net_stats->rx_frame_errors  = hw_stats->rx_align_err;
> +	net_stats->rx_dropped       = hw_stats->rx_ov_rrd;
> +
> +	net_stats->tx_errors = hw_stats->tx_late_col +
> +			       hw_stats->tx_abort_col +
> +			       hw_stats->tx_underrun +
> +			       hw_stats->tx_trunc;
> +
> +	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
> +	net_stats->tx_fifo_errors    = hw_stats->tx_underrun;
> +	net_stats->tx_window_errors  = hw_stats->tx_late_col;
> +
> +	net_stats->tx_packets = hw_stats->tx_ok + net_stats->tx_errors;
> +	net_stats->rx_packets = hw_stats->rx_ok + net_stats->rx_errors;
> +
> +	spin_unlock(&alx->stats_lock);
> +
> +	return net_stats;
> +}
> +
>  static const struct net_device_ops alx_netdev_ops = {
>  	.ndo_open               = alx_open,
>  	.ndo_stop               = alx_stop,
>  	.ndo_start_xmit         = alx_start_xmit,
> +	.ndo_get_stats64        = alx_get_stats64,
>  	.ndo_set_rx_mode        = alx_set_rx_mode,
>  	.ndo_validate_addr      = eth_validate_addr,
>  	.ndo_set_mac_address    = alx_set_mac_address,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
