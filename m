From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] d44: the poll handler b44_poll must not enable IRQ unconditionally
Date: Thu, 17 Sep 2009 11:45:52 -0500
Message-ID: <20090917164552.GH8789@waste.org>
References: <1253153447.24160.12.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: DDD <Dongdong.deng@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:51602 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbZIQQza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 12:55:30 -0400
Content-Disposition: inline
In-Reply-To: <1253153447.24160.12.camel@dengdd-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2009 at 10:10:47AM +0800, DDD wrote:
> net/core/netpoll.c::netpoll_send_skb() calls the poll handler when
> it is available. As netconsole can be used from almost any context,
> IRQ must not be enabled blindly in the NAPI handler of the driver
> which supports netpoll.
> 
> Call trace:
> netpoll_send_skb()
> {
> local_irq_save(flags)
>   -> netpoll_poll()
>     -> poll_napi()
>       -> poll_one_napi()
>         -> napi->poll()
>             -> b44_poll()
> local_irq_restore(flags)
> }
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>

Acked-by: Matt Mackall <mpm@selenic.com>

> ---
>  drivers/net/b44.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 0189dcd..e046943 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -847,23 +847,22 @@ static int b44_poll(struct napi_struct *napi, int budget)
>  {
>  	struct b44 *bp = container_of(napi, struct b44, napi);
>  	int work_done;
> +	unsigned long flags;
>  
> -	spin_lock_irq(&bp->lock);
> +	spin_lock_irqsave(&bp->lock, flags);
>  
>  	if (bp->istat & (ISTAT_TX | ISTAT_TO)) {
>  		/* spin_lock(&bp->tx_lock); */
>  		b44_tx(bp);
>  		/* spin_unlock(&bp->tx_lock); */
>  	}
> -	spin_unlock_irq(&bp->lock);
> +	spin_unlock_irqrestore(&bp->lock, flags);
>  
>  	work_done = 0;
>  	if (bp->istat & ISTAT_RX)
>  		work_done += b44_rx(bp, budget);
>  
>  	if (bp->istat & ISTAT_ERRORS) {
> -		unsigned long flags;
> -
>  		spin_lock_irqsave(&bp->lock, flags);
>  		b44_halt(bp);
>  		b44_init_rings(bp);
> -- 
> 1.6.0.4
> 

-- 
Mathematics is the supreme nostalgia of our time.
