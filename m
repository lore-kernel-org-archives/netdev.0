From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] atl1: update statistics code
Date: Fri, 10 Jan 2014 18:29:26 +0000
Message-ID: <1389378566.2025.78.camel@bwh-desktop.uk.level5networks.com>
References: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
	 <1389370103-3009-4-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <chris.snook@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60687 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbaAJS3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:29:30 -0500
In-Reply-To: <1389370103-3009-4-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 17:08 +0100, Sabrina Dubroca wrote:
> As Ben Hutchings pointed out for the stats in alx, some
> hardware-specific stats aren't matched to the right net_device_stats
> field. Also fix the collision field and include errors in the total
> number of RX/TX packets.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  drivers/net/ethernet/atheros/atlx/atl1.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
> index 538211d..31d460a 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl1.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl1.c
[...]
> @@ -1718,23 +1718,18 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
>  	adapter->soft_stats.tx_trunc += smb->tx_trunc;
>  	adapter->soft_stats.tx_pause += smb->tx_pause;
>  
> -	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
> -	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
>  	netdev->stats.rx_bytes = adapter->soft_stats.rx_bytes;
>  	netdev->stats.tx_bytes = adapter->soft_stats.tx_bytes;
>  	netdev->stats.multicast = adapter->soft_stats.multicast;
>  	netdev->stats.collisions = adapter->soft_stats.collisions;
>  	netdev->stats.rx_errors = adapter->soft_stats.rx_errors;
> -	netdev->stats.rx_over_errors =
> -		adapter->soft_stats.rx_missed_errors;
>  	netdev->stats.rx_length_errors =
>  		adapter->soft_stats.rx_length_errors;
>  	netdev->stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
>  	netdev->stats.rx_frame_errors =
>  		adapter->soft_stats.rx_frame_errors;
>  	netdev->stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
> -	netdev->stats.rx_missed_errors =
> -		adapter->soft_stats.rx_missed_errors;

So adapter->soft_stats.rx_missed_errors is set (to something silly) and
then ignored...

> +	netdev->stats.rx_dropped = adapter->soft_stats.rx_rrd_ov;
>  	netdev->stats.tx_errors = adapter->soft_stats.tx_errors;
>  	netdev->stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
>  	netdev->stats.tx_aborted_errors =
> @@ -1743,6 +1738,11 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
>  		adapter->soft_stats.tx_window_errors;
>  	netdev->stats.tx_carrier_errors =
>  		adapter->soft_stats.tx_carrier_errors;
> +
> +	netdev->stats.rx_packets = adapter->soft_stats.rx_packets +
> +				   netdev->stats.rx_errors;
> +	netdev->stats.tx_packets = adapter->soft_stats.tx_packets +
> +				   netdev->stats.tx_errors;

Given that adapter->soft_stats largely mirrors struct net_device_stats,
would it not make sense to do these additions there so that
adapter->soft_stats.{rx,tx}_packets include all packets?

I.e. you could do something like:

	delta_rx_errors = (smb->rx_frag + smb->rx_fcs_err +
			   smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
			   smb->rx_rrd_ov + smb->rx_align_err);
	adapter->soft_stats.rx_errors += delta_rx_errors;
	adapter->soft_stats.rx_packets += delta_rx_errors;

(and similarly for TX).

Basically I think these changes belong further up the function.

Ben.

>  }
>  
>  static void atl1_update_mailbox(struct atl1_adapter *adapter)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
