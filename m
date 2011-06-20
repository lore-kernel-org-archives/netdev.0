From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 3/5] e100:  Support receiving errored frames.
Date: Mon, 20 Jun 2011 18:57:52 +0100
Message-ID: <1308592672.2701.146.camel@bwh-desktop>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
	 <1308430045-24816-4-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16794 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab1FTR5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 13:57:55 -0400
In-Reply-To: <1308430045-24816-4-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-18 at 13:47 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This can be helpful when sniffing dodgy networks.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 647d8c6... aad303d... M	drivers/net/e100.c
>  drivers/net/e100.c |   42 ++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 647d8c6..aad303d 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -588,6 +588,7 @@ struct nic {
>  		wol_magic          = (1 << 3),
>  		ich_10h_workaround = (1 << 4),
>  		save_rxfcs         = (1 << 5),
> +		save_rxerr         = (1 << 6),
>  	} flags					____cacheline_aligned;
>  
>  	enum mac mac;
> @@ -1126,9 +1127,13 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
>  		config->full_duplex_force = 0x1;	/* 1=force, 0=auto */
>  
>  	if (nic->flags & promiscuous || nic->loopback) {
> +		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
> +	}
> +
> +	if (nic->flags & save_rxerr) {
> +		config->rx_discard_overruns = 0x1;	/* 1=save, 0=discard */
>  		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
>  		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */

Any idea why these were previously set in promiscuous or loopback mode?

> -		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
>  	}
>  
>  	if (nic->flags & save_rxfcs)
> @@ -1983,7 +1988,18 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
>  	skb_put(skb, actual_size);
>  	skb->protocol = eth_type_trans(skb, nic->netdev);
>  
> -	if (unlikely(!(rfd_status & cb_ok))) {
> +	if (unlikely(nic->flags & save_rxerr)) {
> +		if (!(rfd_status & cb_ok)) {
> +			skb->pkt_type = PACKET_INVALID;
> +		} else if (actual_size >
> +			   ETH_DATA_LEN + VLAN_ETH_HLEN + rxfcs_pad) {
> +			nic->rx_over_length_errors++;
> +			skb->pkt_type = PACKET_INVALID;
> +		}
> +		goto process_skb;
> +	}
> +
> +	if (unlikely((nic->flags & save_rxerr) && !(rfd_status & cb_ok))) {
[...]

You're adding an if-statement to cover the save_rxerr case, and the
existing if-else-statement should cover the !save_rxerr case - so you
are missing a '!'.  But since the new if-statement's body ends with a
goto, there should be no need to change the condition for the existing
if-else statement at all.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

