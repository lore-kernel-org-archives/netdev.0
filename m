From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/5] sky2: add fake idle irq timer
Date: Tue, 25 Apr 2006 23:23:29 +0200
Message-ID: <20060425212329.GA18035@electric-eye.fr.zoreil.com>
References: <20060425175849.372221000@localhost.localdomain> <20060425175951.444629000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:25550 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751317AbWDYV1l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 17:27:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060425175951.444629000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> --- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:48:47.000000000 -0700
> +++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:53:32.000000000 -0700
> @@ -2086,6 +2086,20 @@
>  	}
>  }
>  
> +/* If idle then force a fake soft NAPI poll once a second
> + * to work around cases where sharing an edge triggered interrupt.
> + */
> +static void sky2_idle(unsigned long arg)
> +{
> +	struct net_device *dev = (struct net_device *) arg;
> +
> +	local_irq_disable();
> +	if (__netif_rx_schedule_prep(dev))
> +		__netif_rx_schedule(dev);
> +	local_irq_enable();
> +}
> +
> +
>  static int sky2_poll(struct net_device *dev0, int *budget)
>  {
>  	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
> @@ -2134,6 +2148,8 @@
>  		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
>  	}
>  
> +	mod_timer(&hw->idle_timer, jiffies + HZ);
> +
>  	local_irq_disable();
>  	__netif_rx_complete(dev0);


Any objection against moving mod_timer() from sky2_poll() to sky2_idle()
so as to keep poll() path unmodified ?

-- 
Ueimor
