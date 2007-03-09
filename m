From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: netconsole system freeze when cable unplugged
Date: Fri, 09 Mar 2007 23:30:26 +0000
Message-ID: <45F1EE12.2070605@simon.arlott.org.uk>
References: <45F1B6FD.1060902@simon.arlott.org.uk> <20070309204243.GA28441@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:38921 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767646AbXCIXaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 18:30:30 -0500
In-Reply-To: <20070309204243.GA28441@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/03/07 20:42, Francois Romieu wrote:
> Simon Arlott <simon@fire.lp0.eu> :
>> When I unplug the cable the system just stops responding to anything, 
>> at all. No message is printed to the console when the cable is plugged 
>> back in.
> 
> rtl8139_interrupt (spin_lock(&tp->lock))
> -> rtl8139_weird_interrupt
>    -> rtl_check_media
>       -> mii_check_media (printk(KERN_INFO "%s: link down\n", ...))
>          [netpoll stuff here]
>          -> rtl8139_poll_controller
>             -> rtl8139_interrupt
>                *deadlock*
> 
> See below for my random stuff of the day. Feel free to open a PR at
> bugzilla.kernel.org if the issue does not go away.

The patch doesn't fix it, nothing changes. I'm not sure how this can 
be debugged if printk won't work...

> --------8<-----------------------------------------------------------------
> 
> 8139too: netconsole breakage when link changes
> 
> rtl8139_interrupt is not supposed to be reentrant but its link
> management part can emit printk.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index 99304b2..64467ad 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -2215,9 +2215,16 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
>   */
>  static void rtl8139_poll_controller(struct net_device *dev)
>  {
> -	disable_irq(dev->irq);
> +	struct rtl8139_private *tp = netdev_priv(dev);
> +	unsigned long flags;
> +	int rc;
> +
> +	rc = spin_trylock_irqsave(&tp->lock, flags);
> +	if (!rc)
> +		return;
> +	spin_unlock(&tp->lock);
>  	rtl8139_interrupt(dev->irq, dev);
> -	enable_irq(dev->irq);
> +	local_irq_restore(flags);
>  }
>  #endif
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Simon Arlott
