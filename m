From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: Fri, 10 Nov 2006 21:30:09 +0100
Message-ID: <20061110203009.GA9851@electric-eye.fr.zoreil.com>
References: <20061110191745.GA13783@codepoet.org> <20061110115444.07f58e40@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50083 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1424405AbWKJUcg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 15:32:36 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061110115444.07f58e40@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 9997081..4052bfe 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -1191,25 +1191,23 @@ static int mv643xx_eth_start_xmit(struct
>  	struct net_device_stats *stats = &mp->stats;
>  	unsigned long flags;
>  
> -	BUG_ON(netif_queue_stopped(dev));
> -	BUG_ON(skb == NULL);
> -
> -	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
> -		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
> -		netif_stop_queue(dev);
> -		return 1;
> -	}
> -
> -	if (has_tiny_unaligned_frags(skb)) {
> -		if (__skb_linearize(skb)) {
> -			stats->tx_dropped++;
> +	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
> +		stats->tx_dropped++;
> +		if (net_ratelimit())
>  			printk(KERN_DEBUG "%s: failed to linearize tiny "
> -					"unaligned fragment\n", dev->name);
> -			return 1;
> -		}
> +			       "unaligned fragment\n", dev->name);
> +		return NETDEV_TX_OK;
>  	}

It seems to propagate a leak from the initial codebase.

-- 
Ueimor
