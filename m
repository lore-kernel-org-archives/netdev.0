From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC net-next 2/4] gianfar: Clear ievent from interrupt handler
 for [RT]x int
Date: Wed, 8 Aug 2012 12:11:56 -0400
Message-ID: <20120808161156.GB11043@windriver.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:63849 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030391Ab2HHQMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 12:12:01 -0400
Content-Disposition: inline
In-Reply-To: <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[RFC net-next 2/4] gianfar: Clear ievent from interrupt handler for [RT]x int] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:

> It's the interrupt handler's job to clear ievent for the Tx/Rx paths, as soon
> as the corresponding interrupt sources have been masked.

What wasn't clear to me was whether we'd ever have an instance of
gfar_poll run without RTX_MASK being cleared (in less normal conditions,
like netconsole, KGDBoE etc), since the gfar_schedule_cleanup is only
called from rx/tx IRQ threads, and neither of those are used by
gfar_poll, it seems.

Paul.
--
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |   16 ++++++----------
>  1 files changed, 6 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index e9feeb9..ddd350a 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2568,12 +2568,13 @@ static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
>  	if (napi_schedule_prep(&gfargrp->napi)) {
>  		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
>  		__napi_schedule(&gfargrp->napi);
> -	} else {
> -		/* Clear IEVENT, so interrupts aren't called again
> -		 * because of the packets that have already arrived.
> -		 */
> -		gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
>  	}
> +
> +	/* Clear IEVENT, so interrupts aren't called again
> +	 * because of the packets that have already arrived.
> +	 */
> +	gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
> +
>  	spin_unlock_irqrestore(&gfargrp->grplock, flags);
>  
>  }
> @@ -2837,11 +2838,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
>  	num_queues = gfargrp->num_rx_queues;
>  	budget_per_queue = budget/num_queues;
>  
> -	/* Clear IEVENT, so interrupts aren't called again
> -	 * because of the packets that have already arrived
> -	 */
> -	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
> -
>  	while (num_queues && left_over_budget) {
>  		budget_per_queue = left_over_budget/num_queues;
>  		left_over_budget = 0;
> -- 
> 1.6.6
> 
> 
