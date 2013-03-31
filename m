From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Sun, 31 Mar 2013 17:31:32 +0100
Message-ID: <1364747492.3557.62.camel@deadeye.wl.decadent.org.uk>
References: <1364729701-18855-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ariele@broadcom.com>, Eilon Greenstein <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27191 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532Ab3CaQbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 12:31:41 -0400
In-Reply-To: <1364729701-18855-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-31 at 14:35 +0300, Yuval Mintz wrote:
> In scenarios in which a previous driver was removed without proper cleanup
> (e.g., kdump), it is possible for the chip to generate an interrupt without
> any apparent reason once interrupts are requested.
> 
> This patch introduces 2 changes:
> 
>   - It changes bnx2x's interrupt request scheme so that bnx2x would only
>     request interrupts from the kernel after it has finished initializing
>     all the inner structs required for those interrupts' handling.
> 
>   - The driver ignores any interrupt which arrives in an inappropriate time,
>     i.e., when the HW generates interrupts without being configured to do so.
>     Acking the HW for such an interrupt will prevent HW from generating further
>     interrupts, thus ignoring them is necessary.
>    
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
[...]

The flag changes can still race with the interrupt handler, so I think
you need to add:

> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -866,6 +866,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
>  		bnx2x_hc_int_disable(bp);
>  	else
>  		bnx2x_igu_int_disable(bp);

for (each interrupt vector)
	synchronize_irq(irq);

> +	bp->flags &= ~INTERRUPTS_ENABLED_FLAG;
>  }
>  
>  void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
> @@ -1605,6 +1606,8 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
>  
>  void bnx2x_int_enable(struct bnx2x *bp)
>  {
> +	bp->flags |= INTERRUPTS_ENABLED_FLAG;
> +

wmb();

>  	if (bp->common.int_block == INT_BLOCK_HC)
>  		bnx2x_hc_int_enable(bp);
>  	else
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
