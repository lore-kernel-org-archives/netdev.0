From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] request_irq() always returns -EINVAL with a NULL
 handler.
Date: Thu, 17 Jan 2008 08:22:55 -0800
Message-ID: <20080117082255.49e7a656@speedy>
References: <200801171757.59026.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kerne@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48542 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbYAQQW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 11:22:57 -0500
In-Reply-To: <200801171757.59026.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 17:57:58 +1100
Rusty Russell <rusty@rustcorp.com.au> wrote:

> I assume that these ancient network drivers were trying to find out if
> an irq is available.  eepro.c expecting +EBUSY was doubly wrong.
> 
> I'm not sure that can_request_irq() is the right thing, but these drivers
> are definitely wrong.
> 
> request_irq should BUG() on bad input, and these would have been found
> earlier.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/3c503.c |    2 +-
>  drivers/net/e2100.c |    2 +-
>  drivers/net/eepro.c |    2 +-
>  drivers/net/hp.c    |    2 +-
>  kernel/irq/manage.c |    1 +
>  5 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff -r 0b7e4fbb6238 drivers/net/3c503.c
> --- a/drivers/net/3c503.c	Thu Jan 17 15:49:34 2008 +1100
> +++ b/drivers/net/3c503.c	Thu Jan 17 16:40:28 2008 +1100
> @@ -379,7 +379,7 @@ el2_open(struct net_device *dev)
>  
>  	outb(EGACFR_NORM, E33G_GACFR);	/* Enable RAM and interrupts. */
>  	do {
> -	    if (request_irq (*irqp, NULL, 0, "bogus", dev) != -EBUSY) {
> +	    if (can_request_irq(*irqp, 0)) {
>  		/* Twinkle the interrupt, and check if it's seen. */
>  		unsigned long cookie = probe_irq_on();
>  		outb_p(0x04 << ((*irqp == 9) ? 2 : *irqp), E33G_IDCFR);
> diff -r 0b7e4fbb6238 drivers/net/e2100.c
> --- a/drivers/net/e2100.c	Thu Jan 17 15:49:34 2008 +1100
> +++ b/drivers/net/e2100.c	Thu Jan 17 16:40:28 2008 +1100
> @@ -202,7 +202,7 @@ static int __init e21_probe1(struct net_
>  	if (dev->irq < 2) {
>  		int irqlist[] = {15,11,10,12,5,9,3,4}, i;
>  		for (i = 0; i < 8; i++)
> -			if (request_irq (irqlist[i], NULL, 0, "bogus", NULL) != -EBUSY) {
> +			if (can_request_irq(irqlist[i], 0)) {
>  				dev->irq = irqlist[i];
>  				break;
>  			}
> diff -r 0b7e4fbb6238 drivers/net/eepro.c
> --- a/drivers/net/eepro.c	Thu Jan 17 15:49:34 2008 +1100
> +++ b/drivers/net/eepro.c	Thu Jan 17 16:40:28 2008 +1100
> @@ -914,7 +914,7 @@ static int	eepro_grab_irq(struct net_dev
>  
>  		eepro_sw2bank0(ioaddr); /* Switch back to Bank 0 */
>  
> -		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) != EBUSY) {
> +		if (can_request_irq(*irqp, IRQF_SHARED)) {
>  			unsigned long irq_mask;
>  			/* Twinkle the interrupt, and check if it's seen */
>  			irq_mask = probe_irq_on();
> diff -r 0b7e4fbb6238 drivers/net/hp.c
> --- a/drivers/net/hp.c	Thu Jan 17 15:49:34 2008 +1100
> +++ b/drivers/net/hp.c	Thu Jan 17 16:40:28 2008 +1100
> @@ -170,7 +170,7 @@ static int __init hp_probe1(struct net_d
>  		int *irqp = wordmode ? irq_16list : irq_8list;
>  		do {
>  			int irq = *irqp;
> -			if (request_irq (irq, NULL, 0, "bogus", NULL) != -EBUSY) {
> +			if (can_request_irq(irq, 0)) {
>  				unsigned long cookie = probe_irq_on();
>  				/* Twinkle the interrupt, and check if it's seen. */
>  				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
> diff -r 0b7e4fbb6238 kernel/irq/manage.c
> --- a/kernel/irq/manage.c	Thu Jan 17 15:49:34 2008 +1100
> +++ b/kernel/irq/manage.c	Thu Jan 17 16:40:28 2008 +1100
> @@ -252,6 +252,7 @@ int can_request_irq(unsigned int irq, un
>  
>  	return !action;
>  }
> +EXPORT_SYMBOL(can_request_irq);
>  
>  void compat_irq_chip_set_default_handler(struct irq_desc *desc)
>  {

Isn't this just inherently racy, like the old check_resource stuff that got pulled
out 2.5?
