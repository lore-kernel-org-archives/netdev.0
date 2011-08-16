From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 09/14] bna: Ethtool Enhancements and Fix
Date: Tue, 16 Aug 2011 22:43:19 +0100
Message-ID: <1313530999.2725.58.camel@bwh-desktop>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
	 <1313529591-3718-10-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:2765 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab1HPVnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:43:24 -0400
In-Reply-To: <1313529591-3718-10-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
> Change details:
>  - Set coalescing time out for multiple tx objects.
>  - Use bnad_dim_timer_stop macro in bnad_set_coalesce.
>  - Add tx_skb counters and NAPI debug counters to ethtool stats.
>  - Add rlb stats strings to bnad_net_stats_strings{} array. rlb_stats field
>    was added to struct bfi_enet_stats {} but the corresponding name structure
>    array for ethtool was not initialized with right strings, even though the
>    actual name structure array got expanded. This caused a NULL pointer
>    violation and a crash when doing ehtool -S <if_name>.
>  - While setting the ring parameter restore the rx, vlan configuration and
>    set rx mode
>  - Indentation fix
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  drivers/net/ethernet/brocade/bna/bnad.c         |   21 +++---
>  drivers/net/ethernet/brocade/bna/bnad.h         |   10 ++-
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   88 +++++++++++++++++++----
>  3 files changed, 92 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index 11c058e..76bfa19 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -2008,12 +2008,15 @@ void
>  bnad_tx_coalescing_timeo_set(struct bnad *bnad)
>  {
>  	struct bnad_tx_info *tx_info;
> +	int i;
>  
> -	tx_info = &bnad->tx_info[0];
> -	if (!tx_info->tx)
> -		return;
> -
> -	bna_tx_coalescing_timeo_set(tx_info->tx, bnad->tx_coalescing_timeo);
> +	for (i = 0; i < bnad->num_tx; i++) {
> +		tx_info = &bnad->tx_info[i];
> +		if (!tx_info->tx)
> +			continue;
> +		bna_tx_coalescing_timeo_set(tx_info->tx,
> +				bnad->tx_coalescing_timeo);
> +	}
>  }
[...]

Doesn't this need to be done at the same time as patch 04/14 "bna: Add
Multiple Tx Queue Support"?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

