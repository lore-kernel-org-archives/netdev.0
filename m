From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] BUG_ON() bad input to request_irq
Date: Wed, 23 Jan 2008 14:04:14 -0800
Message-ID: <20080123140414.e1ff2263.akpm@linux-foundation.org>
References: <200801171757.59026.rusty@rustcorp.com.au>
	<200801171759.59029.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754471AbYAWWEs@vger.kernel.org>
In-Reply-To: <200801171759.59029.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 17 Jan 2008 17:59:58 +1100 Rusty Russell <rusty@rustcorp.com.au> wrote:
> Is there any reason why these bugs should be treated gently?  The
> caller might not want to check NR_IRQS and IRQ_NOREQUEST cases, but
> a NULL handler or NULL dev_id w/ shared are coding bugs.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  kernel/irq/manage.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff -r c2eb8ef5a0be kernel/irq/manage.c
> --- a/kernel/irq/manage.c	Thu Jan 17 15:48:03 2008 +1100
> +++ b/kernel/irq/manage.c	Thu Jan 17 15:49:33 2008 +1100
> @@ -532,13 +532,12 @@ int request_irq(unsigned int irq, irq_ha
>  	 * which interrupt is which (messes up the interrupt freeing
>  	 * logic etc).
>  	 */
> -	if ((irqflags & IRQF_SHARED) && !dev_id)
> -		return -EINVAL;
> +	BUG_ON((irqflags & IRQF_SHARED) && !dev_id);
> +	BUG_ON(!handler);
> +
>  	if (irq >= NR_IRQS)
>  		return -EINVAL;
>  	if (irq_desc[irq].status & IRQ_NOREQUEST)
> -		return -EINVAL;
> -	if (!handler)
>  		return -EINVAL;
>  
>  	action = kmalloc(sizeof(struct irqaction), GFP_ATOMIC);

If no driver is passing in args which will trigger this BUG, we presumably
don't need the patch.

If some driver _is_ passing in ags which will trigger these BUGs then it is
presumably working OK anyway.  Taking a working system and making it go BUG
is likely to upset people.

IOW: WARN_ON, please.
