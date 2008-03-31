From: "Zhang, Sonic" <Sonic.Zhang@analog.com>
Subject: RE: [patch (for 2.6.25?) 1/1] smc91x driver: fix bug: print warning only in interrupt mode
Date: Mon, 31 Mar 2008 11:53:25 +0800
Message-ID: <0F1B54C89D5F954D8535DB252AF412FA01B55940@chinexm1.ad.analog.com>
References: <200803282152.m2SLqfmg012431@imap1.linux-foundation.org> <47ED9F1E.8000102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <sonic.zhang@analog.com>,
	<cooloney@kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>, <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:28583 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbYCaDxR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 23:53:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47ED9F1E.8000102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netpoll mode,  smc_interrupt() is invoked repeatedly till a net
packet is received. Timeout is meaning less here.

Sonic

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Saturday, March 29, 2008 9:45 AM
To: akpm@linux-foundation.org
Cc: netdev@vger.kernel.org; sonic.zhang@analog.com; cooloney@kernel.org
Subject: Re: [patch (for 2.6.25?) 1/1] smc91x driver: fix bug: print
warning only in interrupt mode

akpm@linux-foundation.org wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=Tr
> ackerItemEdit&tracker_item_id=3956
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/smc91x.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN 
> drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-inter
> rupt-mode drivers/net/smc91x.c
> --- 
> a/drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-int
> errupt-mode
> +++ a/drivers/net/smc91x.c
> @@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq
>  	SMC_SET_INT_MASK(lp, mask);
>  	spin_unlock(&lp->lock);
>  
> +#ifndef CONFIG_NET_POLL_CONTROLLER
>  	if (timeout == MAX_IRQ_LOOPS)
>  		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
>  		       dev->name, mask);
> +#endif
>  	DBG(3, "%s: Interrupt done (%d loops)\n",
>  	       dev->name, MAX_IRQ_LOOPS - timeout);

NAK

Either this code is OK or it isn't.  This patch simply hides a problem
inside a configuration the developer probably doesn't use.

What's the _real_ problem?  Looking at the tracker, I'd guess that some
events need to be masked, but are not?

If the hardware is asserting events continually, the current code does
the right thing -- keep processing interrupt events flagged, until (a)
no more events asserted or (b) max loop count reached.

So the question is to find out why you are hitting the timeout, and what
to do about it.
