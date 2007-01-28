From: Bernhard Walle <bwalle@suse.de>
Subject: Re: r8169: Crash after reloading driver if network hangs
Date: Sun, 28 Jan 2007 20:56:56 +0100
Message-ID: <20070128195656.GA6013@strauss.suse.de>
References: <20070128180221.GB2285@strauss.suse.de> <20070128190448.GA23060@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:35229 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932758AbXA1T45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jan 2007 14:56:57 -0500
Content-Disposition: inline
In-Reply-To: <20070128190448.GA23060@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2007-01-28 20:04]:
> Bernhard Walle <bwalle@suse.de> :
> [...]
> > Simple fix is attached. Although that seems to fix the symptom and not
> > the cause, please apply it if you don't have a better solution.
> 
> What about the patch below ?
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 577babd..4e22af7 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1373,7 +1373,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
>  	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
>  	timer->data = (unsigned long)(dev);
>  	timer->function = rtl8169_phy_timer;
> -	add_timer(timer);
> +	mod_timer(timer);
>  }

Doesn't compile, I think you mean this?

@@ -1371,10 +1371,9 @@ static inline void rtl8169_request_timer
                return;
 
        init_timer(timer);
-       timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
        timer->data = (unsigned long)(dev);
        timer->function = rtl8169_phy_timer;
-       add_timer(timer);
+       mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
 }

But I think _this_ change is unnecessary, ...

>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -1448,7 +1448,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
>  
>  	rtl8169_phy_reset(dev, tp);
>  
> -	rtl8169_set_speed(dev, autoneg, speed, duplex);
> +	tp->set_speed(dev, autoneg, speed, duplex);
>  
>  	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
>  		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);

... but that looks good (better than my patch) and should resolve the issue,
too. I can't test because it's triggered only if the network hangs and you
know, the last one isn't reproducable.



Regards,
Bernhard
