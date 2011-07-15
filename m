From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] [net][bna] Separate handling of irq type flags
 variable from the irq_flags request_irq variable
Date: Fri, 15 Jul 2011 08:35:06 +0200
Message-ID: <1310711706.13634.4.camel@ceranb.intra.cera.cz>
References: <1310691632-22914-1-git-send-email-shyam_iyer@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocade.com,
	huangj@brocade.com, davem@davemloft.net,
	Shyam Iyer <shyam_iyer@dell.com>
To: Shyam Iyer <shyam.iyer.t@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964778Ab1GOGfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 02:35:13 -0400
In-Reply-To: <1310691632-22914-1-git-send-email-shyam_iyer@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-14 at 21:00 -0400, Shyam Iyer wrote:
> Commit 5f77898de17ff983ff0e2988b73a6bdf4b6f9f8b does not completely fix the problem of handling allocations with irqs disabled..
> The below patch on top of it fixes the problem completely.
The commit fixes the issue, but it does not separate enough the
'irq_flags' and the 'flags', so it is a little bit confusing. The patch
below corrects this imprecision and looks fine.

> Based on review by "Ivan Vecera" <ivecera@redhat.com>..
> "
> Small note, the root of the problem was that non-atomic allocation was requested with IRQs disabled. Your patch description does not contain wwhy were the IRQs disabled.
> 
> The function bnad_mbox_irq_alloc incorrectly uses 'flags' var for two different things, 1) to save current CPU flags and 2) for request_irq
> call.
> First the spin_lock_irqsave disables the IRQs and saves _all_ CPU flags (including one that enables/disables interrupts) to 'flags'. Then the 'flags' is overwritten by 0 or 0x80 (IRQF_SHARED). Finally the spin_unlock_irqrestore should restore saved flags, but these flags are now either 0x00 or 0x80. The interrupt bit value in flags register on x86 arch is 0x100.
> This means that the interrupt bit is zero (IRQs disabled) after spin_unlock_irqrestore so the request_irq function is called with disabled interrupts.
> "
> 
> Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>
> ---
>  drivers/net/bna/bnad.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
> index 44e219c..ea13605 100644
> --- a/drivers/net/bna/bnad.c
> +++ b/drivers/net/bna/bnad.c
> @@ -1111,7 +1111,7 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
>  		    struct bna_intr_info *intr_info)
>  {
>  	int 		err = 0;
> -	unsigned long 	irq_flags = 0, flags;
> +	unsigned long 	irq_flags, flags;
>  	u32	irq;
>  	irq_handler_t 	irq_handler;
>  
> @@ -1125,6 +1125,7 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
>  	if (bnad->cfg_flags & BNAD_CF_MSIX) {
>  		irq_handler = (irq_handler_t)bnad_msix_mbox_handler;
>  		irq = bnad->msix_table[bnad->msix_num - 1].vector;
> +		irq_flags = 0;
>  		intr_info->intr_type = BNA_INTR_T_MSIX;
>  		intr_info->idl[0].vector = bnad->msix_num - 1;
>  	} else {
> @@ -1135,7 +1136,6 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
>  		/* intr_info->idl.vector = 0 ? */
>  	}
>  	spin_unlock_irqrestore(&bnad->bna_lock, flags);
> -	flags = irq_flags;
>  	sprintf(bnad->mbox_irq_name, "%s", BNAD_NAME);
>  
>  	/*
> @@ -1146,7 +1146,7 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
>  
>  	BNAD_UPDATE_CTR(bnad, mbox_intr_disabled);
>  
> -	err = request_irq(irq, irq_handler, flags,
> +	err = request_irq(irq, irq_handler, irq_flags,
>  			  bnad->mbox_irq_name, bnad);
>  
>  	if (err) {



