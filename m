From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: fix race between napi_complete() and
 interrupt handler
Date: Tue, 25 Mar 2014 14:50:21 +0000
Message-ID: <20140325145021.GF31766@zion.uk.xensource.com>
References: <1395756505-21573-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:28694 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787AbaCYOu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 10:50:28 -0400
Content-Disposition: inline
In-Reply-To: <1395756505-21573-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You forgot to target this patch to "net" tree in subject line.

On Tue, Mar 25, 2014 at 02:08:25PM +0000, David Vrabel wrote:
> When the NAPI budget was not all used, xenvif_poll() would call
> napi_complete() /after/ enabling the interrupt.  This resulted in a
> race between the napi_complete() and the napi_schedule() in the
> interrupt handler.  The use of local_irq_save/restore() avoided by
> race iff the handler is running on the same CPU but not if it was
> running on a different CPU.
> 

OK, I understand this issue now. You mentioned it in the other email
which made me a bit confused.

Just curious, how do you trigger this? By re-binding the interrupt to
another CPU when xenvif_poll is running? I used to run irqbalance (the
one that works with xen virtual interrupt) but could not trigger a race.
Probably the race window is too small to trigger?

> Fix this properly by calling napi_complete() before reenabling
> interrupts (in the xenvif_check_rx_xenvif() call).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   28 ++--------------------------
>  1 files changed, 2 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 7669d49..ee322d9 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -65,32 +65,8 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>  	work_done = xenvif_tx_action(vif, budget);
>  
>  	if (work_done < budget) {
> -		int more_to_do = 0;
> -		unsigned long flags;
> -
> -		/* It is necessary to disable IRQ before calling
> -		 * RING_HAS_UNCONSUMED_REQUESTS. Otherwise we might
> -		 * lose event from the frontend.
> -		 *
> -		 * Consider:
> -		 *   RING_HAS_UNCONSUMED_REQUESTS
> -		 *   <frontend generates event to trigger napi_schedule>
> -		 *   __napi_complete
> -		 *
> -		 * This handler is still in scheduled state so the
> -		 * event has no effect at all. After __napi_complete
> -		 * this handler is descheduled and cannot get
> -		 * scheduled again. We lose event in this case and the ring
> -		 * will be completely stalled.
> -		 */
> -
> -		local_irq_save(flags);
> -
> -		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
> -		if (!more_to_do)
> -			__napi_complete(napi);
> -
> -		local_irq_restore(flags);
> +		napi_complete(napi);

You need to add comment here to say interrupt is in fact "disabled"
before this point, and "enabled" by xenvif_check_rx_xenvif().

> +		xenvif_check_rx_xenvif(vif);

To be honest this function call is not immediately obvious about it's
side effect. I don't mind you copy the code in that function here.

Wei.

>  	}
>  
>  	return work_done;
> -- 
> 1.7.2.5
