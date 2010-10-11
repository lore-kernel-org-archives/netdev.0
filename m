From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-2.6] tg3: restore rx_dropped accounting
Date: Mon, 11 Oct 2010 15:26:57 -0700
Message-ID: <20101011222657.GA7307@mcarlson.broadcom.com>
References: <1286776552.2692.232.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2432 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756875Ab0JKW2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 18:28:32 -0400
In-Reply-To: <1286776552.2692.232.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 10, 2010 at 10:55:52PM -0700, Eric Dumazet wrote:
> commit 511d22247be7 (tg3: 64 bit stats on all arches), overlooked the
> rx_dropped accounting.
> 
> We use a full "struct rtnl_link_stats64" to hold rx_dropped value, but
> forgot to report it in tg3_get_stats64().
> 
> Use an "unsigned long" instead to shrink "struct tg3" by 176 bytes, and
> report this value to stats readers.
> 
> Increment rx_dropped counter for oversized frames.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Matt Carlson <mcarlson@broadcom.com>

> CC: Michael Chan <mchan@broadcom.com>
> CC: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/tg3.c |    6 ++++--
>  drivers/net/tg3.h |    2 +-
>  2 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index bc3af78..1ec4b9e 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -4666,7 +4666,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
>  				       desc_idx, *post_ptr);
>  		drop_it_no_recycle:
>  			/* Other statistics kept track of by card. */
> -			tp->net_stats.rx_dropped++;
> +			tp->rx_dropped++;
>  			goto next_pkt;
>  		}
>  
> @@ -4726,7 +4726,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
>  		if (len > (tp->dev->mtu + ETH_HLEN) &&
>  		    skb->protocol != htons(ETH_P_8021Q)) {
>  			dev_kfree_skb(skb);
> -			goto next_pkt;
> +			goto drop_it_no_recycle;
>  		}
>  
>  		if (desc->type_flags & RXD_FLAG_VLAN &&
> @@ -9240,6 +9240,8 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
>  	stats->rx_missed_errors = old_stats->rx_missed_errors +
>  		get_stat64(&hw_stats->rx_discards);
>  
> +	stats->rx_dropped = tp->rx_dropped;
> +
>  	return stats;
>  }
>  
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index 4937bd1..be7ff13 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2759,7 +2759,7 @@ struct tg3 {
>  
>  
>  	/* begin "everything else" cacheline(s) section */
> -	struct rtnl_link_stats64	net_stats;
> +	unsigned long			rx_dropped;
>  	struct rtnl_link_stats64	net_stats_prev;
>  	struct tg3_ethtool_stats	estats;
>  	struct tg3_ethtool_stats	estats_prev;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

