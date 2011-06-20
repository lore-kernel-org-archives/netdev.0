From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/5] niu: fix 64 bit statistics on 32 bit
 platform
Date: Mon, 20 Jun 2011 22:45:56 +0100
Message-ID: <1308606356.2701.199.camel@bwh-desktop>
References: <20110620203506.363818794@vyatta.com>
	 <20110620203602.739916889@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35876 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab1FTVp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:45:59 -0400
In-Reply-To: <20110620203602.739916889@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 13:35 -0700, Stephen Hemminger wrote:

> This resolves issues with NIU driver statistics wrapping on 32 bit SMP.
> Use stats_sync wrapper for bytes and packets, and change error counters
> to natural word size (unsigned long).
[...]
>  static void niu_get_tx_stats(struct niu *np,
>  			     struct rtnl_link_stats64 *stats)
>  {
> -	u64 pkts, errors, bytes;
>  	struct tx_ring_info *tx_rings;
>  	int i;
>  
> -	pkts = errors = bytes = 0;
> -
>  	tx_rings = ACCESS_ONCE(np->tx_rings);
>  	if (!tx_rings)
> -		goto no_rings;
> +		return;
>  
>  	for (i = 0; i < np->num_tx_rings; i++) {
>  		struct tx_ring_info *rp = &tx_rings[i];
> +		unsigned int start;
> +		u64 pkts, bytes;
>  
> -		pkts += rp->tx_packets;
> -		bytes += rp->tx_bytes;
> -		errors += rp->tx_errors;
> +		do {
> +			start = u64_stats_fetch_begin(&rp->syncp);
> +			pkts   = rp->tx_packets;
> +			bytes  = rp->tx_bytes;
> +		} while (u64_stats_fetch_retry(&rp->syncp, start));
> +
> +		stats->tx_packets += pkts;
> +		stats->tx_bytes   += bytes;
> +		stats->tx_errors  += rp->tx_errors;
>  	}
[...]

It looks like you also need to update release_tx_packet() where these
stats are written.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

