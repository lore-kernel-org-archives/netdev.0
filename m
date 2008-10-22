From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] smc911x: Make the driver safer on SMP
Date: Wed, 22 Oct 2008 06:57:31 -0400
Message-ID: <48FF071B.6080705@garzik.org>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com> <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44946 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbYJVK5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 06:57:35 -0400
In-Reply-To: <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Catalin Marinas wrote:
> This patch extends the critical regions covered by lp->lock to make it
> safer on SMP. The main failure point was the smc911x_hard_start_xmit
> function being called from different CPUs. It was tested on the ARM SMP
> platforms.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  drivers/net/smc911x.c |   25 ++++++++-----------------
>  1 files changed, 8 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
> index 0216440..89f1fa6 100644
> --- a/drivers/net/smc911x.c
> +++ b/drivers/net/smc911x.c
> @@ -155,23 +155,17 @@ static void PRINT_PKT(u_char *buf, int length)
>  /* this enables an interrupt in the interrupt mask register */
>  #define SMC_ENABLE_INT(lp, x) do {			\
>  	unsigned int  __mask;				\
> -	unsigned long __flags;				\
> -	spin_lock_irqsave(&lp->lock, __flags);		\
>  	__mask = SMC_GET_INT_EN((lp));			\
>  	__mask |= (x);					\
>  	SMC_SET_INT_EN((lp), __mask);			\
> -	spin_unlock_irqrestore(&lp->lock, __flags);	\
>  } while (0)
>  
>  /* this disables an interrupt from the interrupt mask register */
>  #define SMC_DISABLE_INT(lp, x) do {			\
>  	unsigned int  __mask;				\
> -	unsigned long __flags;				\
> -	spin_lock_irqsave(&lp->lock, __flags);		\
>  	__mask = SMC_GET_INT_EN((lp));			\
>  	__mask &= ~(x);					\
>  	SMC_SET_INT_EN((lp), __mask);			\
> -	spin_unlock_irqrestore(&lp->lock, __flags);	\
>  } while (0)

Very nice... this has the added benefit of making the locking more 
obvious to the reviewer, rather than burying the locking in a macro as 
the previous code did.

	Jeff



