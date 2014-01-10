From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] atl1e: update statistics code
Date: Fri, 10 Jan 2014 18:20:20 +0000
Message-ID: <1389378020.2025.69.camel@bwh-desktop.uk.level5networks.com>
References: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
	 <1389370103-3009-3-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <chris.snook@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60566 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbaAJSUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:20:24 -0500
In-Reply-To: <1389370103-3009-3-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 17:08 +0100, Sabrina Dubroca wrote:
> As Ben Hutchings pointed out for the stats in alx, some
> hardware-specific stats aren't matched to the right net_device_stats
> field. Also fix the collision field and include errors in the total
> number of RX/TX packets.
> 
> Minor whitespace fixes to match the style in alx.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 30 ++++++++++++++++---------
>  1 file changed, 19 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> index 7a73f3a..d5c2d3e 100644
> --- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> +++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> @@ -1177,32 +1177,40 @@ static struct net_device_stats *atl1e_get_stats(struct net_device *netdev)
>  	struct atl1e_hw_stats  *hw_stats = &adapter->hw_stats;
>  	struct net_device_stats *net_stats = &netdev->stats;
>  
> -	net_stats->rx_packets = hw_stats->rx_ok;
> -	net_stats->tx_packets = hw_stats->tx_ok;
>  	net_stats->rx_bytes   = hw_stats->rx_byte_cnt;
>  	net_stats->tx_bytes   = hw_stats->tx_byte_cnt;
>  	net_stats->multicast  = hw_stats->rx_mcast;
>  	net_stats->collisions = hw_stats->tx_1_col +
> -				hw_stats->tx_2_col * 2 +
> -				hw_stats->tx_late_col + hw_stats->tx_abort_col;
> +				hw_stats->tx_2_col +
> +				hw_stats->tx_late_col +
> +				hw_stats->tx_abort_col;
> +
> +	net_stats->rx_errors  = hw_stats->rx_frag +
> +				hw_stats->rx_fcs_err +
> +				hw_stats->rx_len_err +
> +				hw_stats->rx_sz_ov +
> +				hw_stats->rx_rrd_ov +
> +				hw_stats->rx_align_err +
> +				hw_stats->rx_rxf_ov;
>  
> -	net_stats->rx_errors  = hw_stats->rx_frag + hw_stats->rx_fcs_err +
> -				hw_stats->rx_len_err + hw_stats->rx_sz_ov +
> -				hw_stats->rx_rrd_ov + hw_stats->rx_align_err;
>  	net_stats->rx_fifo_errors   = hw_stats->rx_rxf_ov;
>  	net_stats->rx_length_errors = hw_stats->rx_len_err;
>  	net_stats->rx_crc_errors    = hw_stats->rx_fcs_err;
>  	net_stats->rx_frame_errors  = hw_stats->rx_align_err;
> -	net_stats->rx_over_errors   = hw_stats->rx_rrd_ov + hw_stats->rx_rxf_ov;
> +	net_stats->rx_dropped       = hw_stats->rx_rrd_ov;
>  
> -	net_stats->rx_missed_errors = hw_stats->rx_rrd_ov + hw_stats->rx_rxf_ov;
> +	net_stats->tx_errors = hw_stats->tx_late_col +
> +			       hw_stats->tx_abort_col +
> +			       hw_stats->tx_underrun +
> +			       hw_stats->tx_trunc;
>  
> -	net_stats->tx_errors = hw_stats->tx_late_col + hw_stats->tx_abort_col +
> -			       hw_stats->tx_underrun + hw_stats->tx_trunc;
>  	net_stats->tx_fifo_errors    = hw_stats->tx_underrun;
>  	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
>  	net_stats->tx_window_errors  = hw_stats->tx_late_col;
>  
> +	net_stats->rx_packets = hw_stats->rx_ok + net_stats->rx_errors;
> +	net_stats->tx_packets = hw_stats->tx_ok + net_stats->tx_errors;
> +
>  	return net_stats;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
