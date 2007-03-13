From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Tue, 13 Mar 2007 16:45:58 +0300
Message-ID: <45F6AB16.1090300@ru.mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5A48A.8040903@mvista.com> <20070313001442.GD21302@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:5094 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965719AbXCMNqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 09:46:18 -0400
In-Reply-To: <20070313001442.GD21302@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Mark Brown wrote:

> Subject: natsemi: Fix NAPI for interrupt sharing

> The interrupt status register for the natsemi chips is clear on read and
> was read unconditionally from both the interrupt and from the NAPI poll
> routine, meaning that if the interrupt service routine was called (for 
> example, due to a shared interrupt) while a NAPI poll was scheduled
> interrupts could be missed.  This patch fixes that by ensuring that the
> interrupt status register is only read by the interrupt handler when
> interrupts are enabled from the chip.
> 
> It also reverts a workaround for this problem from the netpoll hook and
> improves the trace for interrupt events.
> 
> Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the
> issue, Mark Huth <mhuth@mvista.com> for a simpler method and Simon
> Blake <simon@citylink.co.nz> for testing resources.

> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

> Index: linux-2.6/drivers/net/natsemi.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/natsemi.c	2007-03-11 02:32:43.000000000 +0000
> +++ linux-2.6/drivers/net/natsemi.c	2007-03-13 00:12:29.000000000 +0000
[...]
> @@ -2131,17 +2133,23 @@
>  		       dev->name, np->intr_status,
>  		       readl(ioaddr + IntrMask));
>  
> -	if (!np->intr_status)
> -		return IRQ_NONE;
> -
> -	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
> +	if (np->intr_status) {
> +		prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
>  
> -	if (netif_rx_schedule_prep(dev)) {
>  		/* Disable interrupts and register for poll */
> -		natsemi_irq_disable(dev);
> -		__netif_rx_schedule(dev);
> +		if (netif_rx_schedule_prep(dev)) {
> +			natsemi_irq_disable(dev);
> +			__netif_rx_schedule(dev);
> +		} else
> +			printk(KERN_WARNING
> +		       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
> +			       dev->name, np->intr_status,
> +			       readl(ioaddr + IntrMask));
> +
> +		return IRQ_HANDLED;
>  	}
> -	return IRQ_HANDLED;
> +
> +	return IRQ_NONE;
>  }

    The only "complaint" I have is that this "restructuring" seems 
unnecessary: the only real change it does is an addition of else to the if 
statement.

WBR, Sergei
