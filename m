From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Sun, 15 Jul 2012 09:26:05 +0200
Message-ID: <1342337165.3265.10640.camel@edumazet-glaptop>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63913 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab2GOH0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 03:26:09 -0400
Received: by wibhm11 with SMTP id hm11so1829945wib.1
        for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 00:26:07 -0700 (PDT)
In-Reply-To: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-14 at 21:51 -0400, Kevin Groeneveld wrote:
> From: Kevin Groeneveld <kgroeneveld@gmail.com>
> 
> Add support for 64 bit stats to Broadcom b44 ethernet driver.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/b44.c |   96 ++++++++++++++++++++---------------
>  drivers/net/ethernet/broadcom/b44.h |    3 +-
>  2 files changed, 58 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/b44.c
> b/drivers/net/ethernet/broadcom/b44.c
> index 46b8b7d..c799b5c 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -483,9 +483,11 @@ out:

b44_stats_update() is run from timer, (softirq), check b44_timer()

>  static void b44_stats_update(struct b44 *bp)
>  {
>  	unsigned long reg;
> -	u32 *val;
> +	u64 *val;
> 
>  	val = &bp->hw_stats.tx_good_octets;
> +	u64_stats_update_begin(&bp->hw_stats.syncp);
> +
>  	for (reg = B44_TX_GOOD_O; reg <= B44_TX_PAUSE; reg += 4UL) {
>  		*val++ += br32(bp, reg);
>  	}
> @@ -496,6 +498,8 @@ static void b44_stats_update(struct b44 *bp)
>  	for (reg = B44_RX_GOOD_O; reg <= B44_RX_NPAUSE; reg += 4UL) {
>  		*val++ += br32(bp, reg);
>  	}
> +
> +	u64_stats_update_end(&bp->hw_stats.syncp);
>  }
> 
>  static void b44_link_report(struct b44 *bp)
> @@ -1635,44 +1639,49 @@ static int b44_close(struct net_device *dev)
>  	return 0;
>  }
> 
> -static struct net_device_stats *b44_get_stats(struct net_device *dev)
> +static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
> +					struct rtnl_link_stats64 *nstat)
>  {
>  
> -	nstat->tx_aborted_errors = hwstat->tx_underruns;
> +	unsigned int start;
> +
> +	do {
> +		start = u64_stats_fetch_begin(&hwstat->syncp);

So you must use u64_stats_fetch_begin_bh()


Because on 32bit, uniprocessor, u64_stats_fetch_begin() only disables
preemption. (there is no seqlock in syncp)

So softirq are allowed to interrupt you and corrupt your stats while you
read them, and you dont notice you have to retry.

> +
> +		/* Convert HW stats into rtnl_link_stats64 stats. */
> +		nstat->rx_packets = hwstat->rx_pkts;
> +		nstat->tx_packets = hwstat->tx_pkts;
> +		nstat->rx_bytes   = hwstat->rx_octets;
> +		nstat->tx_bytes   = hwstat->tx_octets;
> +		nstat->tx_errors  = (hwstat->tx_jabber_pkts +
> +				     hwstat->tx_oversize_pkts +
> +				     hwstat->tx_underruns +
> +				     hwstat->tx_excessive_cols +
> +				     hwstat->tx_late_cols);
> +		nstat->multicast  = hwstat->tx_multicast_pkts;
> +		nstat->collisions = hwstat->tx_total_cols;
> +
> +		nstat->rx_length_errors = (hwstat->rx_oversize_pkts +
> +					   hwstat->rx_undersize);
> +		nstat->rx_over_errors   = hwstat->rx_missed_pkts;
> +		nstat->rx_frame_errors  = hwstat->rx_align_errs;
> +		nstat->rx_crc_errors    = hwstat->rx_crc_errs;
> +		nstat->rx_errors        = (hwstat->rx_jabber_pkts +
> +					   hwstat->rx_oversize_pkts +
> +					   hwstat->rx_missed_pkts +
> +					   hwstat->rx_crc_align_errs +
> +					   hwstat->rx_undersize +
> +					   hwstat->rx_crc_errs +
> +					   hwstat->rx_align_errs +
> +					   hwstat->rx_symbol_errs);
> +
> +		nstat->tx_aborted_errors = hwstat->tx_underruns;
>  #if 0
> -	/* Carrier lost counter seems to be broken for some devices */
> -	nstat->tx_carrier_errors = hwstat->tx_carrier_lost;
> +		/* Carrier lost counter seems to be broken for some devices */
> +		nstat->tx_carrier_errors = hwstat->tx_carrier_lost;
>  #endif
> +	} while (u64_stats_fetch_retry(&hwstat->syncp, start));


u64_stats_fetch_retry_bh()
