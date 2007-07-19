From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [8/8]
Date: Thu, 19 Jul 2007 07:45:02 -0700
Message-ID: <20070719144502.GG12892@xyzzy.farnsworth.org>
References: <469EF04C.1020505@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4937 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756027AbXGSOpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:45:03 -0400
Content-Disposition: inline
In-Reply-To: <469EF04C.1020505@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 05:02:04AM +0000, Steven J. Hill wrote:
> Fix long standing panic with regards to descriptors and locking.
> 
> Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
> ---
> 
> diff -ur linux-2.6.22.1/drivers/net/mv643xx_eth.c linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c
> --- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 22:55:11.000000000 -0500
> +++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 22:39:37.000000000 -0500
> @@ -350,13 +350,6 @@
>  
>  	while (mp->tx_desc_count > 0) {
>  		spin_lock_irqsave(&mp->lock, flags);
> -
> -		/* tx_desc_count might have changed before acquiring the lock */
> -		if (mp->tx_desc_count <= 0) {
> -			spin_unlock_irqrestore(&mp->lock, flags);
> -			return released;
> -		}
> -

The code you remove above is needed to protect against a nasty bug.
It was added in January and needs to stay in.

> @@ -367,7 +360,7 @@
>  
>  		if (!force && (cmd_sts & ETH_BUFFER_OWNED_BY_DMA)) {
>  			spin_unlock_irqrestore(&mp->lock, flags);
> -			return released;
> +			continue;
>  		}

No.  Continuing at that point results in the driver spinning, wasting
cpu while polling for the hardware to release the DMA descriptor.

> @@ -1488,7 +1481,19 @@
>  	BUG_ON(netif_queue_stopped(dev));
>  	BUG_ON(skb == NULL);
>  
> -	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
> +	if (mp->tx_ring_size - mp->tx_desc_count <= MAX_DESCS_PER_SKB) {
> +		/*
> +		 * We are completely out of TX descriptors, however,
> +		 * if 'tx_used_desc_q' is zero, most likely the port
> +		 * has been configured and is up, but there is no link.
> +		 * We attempt to free a single descriptor to keep the
> +		 * 'sendto' call and rest of the stack happy. If this
> +		 * check is taken out, expect an error and kernel panic
> +		 * from 'kernel/softirq.c:141' inside 'local_bh_enable'.
> +		 */
> +		if (mp->tx_used_desc_q == 0)
> +			mv643xx_eth_free_all_tx_descs(dev);

I don't understand the bug, but regardless, we need a better fix.
Freeing all the descriptors when the HW xmit queue is full is not
a solution.

-Dale
