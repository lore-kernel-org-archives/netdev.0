From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: user of the jiffies rounding code: Networking
Date: Thu, 12 Oct 2006 13:06:29 -0700
Message-ID: <452EA045.4080907@intel.com>
References: <1160679363.3000.461.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45185 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1750699AbWJLUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 16:08:22 -0400
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1160679363.3000.461.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> From: Arjan van de Ven <arjan@linux.intel.com>
> Subject: round_jiffies users
> CC: jgarzik@pobox.com
> CC: netdev@vger.kernel.org
> 
> This patch introduces users of the round_jiffies() function in the networking code.
> 
> These timers all were of the "about once a second" or "about once every X seconds" 
> variety and several showed up in the "what wakes the cpu up" profiles that
> the tickless patches provide. Some timers are highly dynamic based on network load; but 
> even on low activity systems they still show up so the rounding is done only in cases of
> low activity, allowing higher frequency timers in the high activity case.
> 
> The various hardware watchdogs are an obvious case; they run every 2 seconds but aren't otherwise
> specific of exactly when they need to run.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> 
> Index: linux-2.6.19-rc1-git6/net/core/dst.c
> ===================================================================
> --- linux-2.6.19-rc1-git6.orig/net/core/dst.c
> +++ linux-2.6.19-rc1-git6/net/core/dst.c
> @@ -99,7 +99,14 @@ static void dst_run_gc(unsigned long dum
>  	printk("dst_total: %d/%d %ld\n",
>  	       atomic_read(&dst_total), delayed,  dst_gc_timer_expires);
>  #endif
> -	mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
> +	/* if the next desired timer is more than 4 seconds in the future
> +	 * then round the timer to whole seconds
> +	 */
> +	if (dst_gc_timer_expires > 4*HZ)
> +		mod_timer(&dst_gc_timer,
> +			round_jiffies(jiffies + dst_gc_timer_expires));
> +	else
> +		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
>  
>  out:
>  	spin_unlock(&dst_lock);
> Index: linux-2.6.19-rc1-git6/net/core/neighbour.c
> ===================================================================
> --- linux-2.6.19-rc1-git6.orig/net/core/neighbour.c
> +++ linux-2.6.19-rc1-git6/net/core/neighbour.c
> @@ -695,7 +695,10 @@ next_elt:
>  	if (!expire)
>  		expire = 1;
>  
> - 	mod_timer(&tbl->gc_timer, now + expire);
> +	if (expire>HZ)
> +		mod_timer(&tbl->gc_timer, round_jiffies(now + expire));
> +	else
> +	 	mod_timer(&tbl->gc_timer, now + expire);
>  
>  	write_unlock(&tbl->lock);
>  }
> Index: linux-2.6.19-rc1-git6/net/sched/sch_generic.c
> ===================================================================
> --- linux-2.6.19-rc1-git6.orig/net/sched/sch_generic.c
> +++ linux-2.6.19-rc1-git6/net/sched/sch_generic.c
> @@ -209,7 +209,7 @@ static void dev_watchdog(unsigned long a
>  				       dev->name);
>  				dev->tx_timeout(dev);
>  			}
> -			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> +			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
>  				dev_hold(dev);
>  		}
>  	}
> Index: linux-2.6.19-rc1-git6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.19-rc1-git6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6.19-rc1-git6/drivers/net/e1000/e1000_main.c
> @@ -483,7 +483,7 @@ e1000_up(struct e1000_adapter *adapter)
>  
>  	clear_bit(__E1000_DOWN, &adapter->flags);
>  
> -	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
> +	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
>  	return 0;
>  }
>  
> @@ -2493,7 +2493,7 @@ e1000_watchdog(unsigned long data)
>  
>  			netif_carrier_on(netdev);
>  			netif_wake_queue(netdev);
> -			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
> +			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
>  			adapter->smartspeed = 0;
>  		}
>  	} else {
> @@ -2503,7 +2503,7 @@ e1000_watchdog(unsigned long data)
>  			DPRINTK(LINK, INFO, "NIC Link is Down\n");
>  			netif_carrier_off(netdev);
>  			netif_stop_queue(netdev);
> -			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
> +			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
>  
>  			/* 80003ES2LAN workaround--
>  			 * For packet buffer work-around on link down event;
> @@ -2568,7 +2568,7 @@ e1000_watchdog(unsigned long data)
>  		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
>  
>  	/* Reset the timer */
> -	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
> +	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
>  }
>  
>  #define E1000_TX_FLAGS_CSUM		0x00000001
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


For the e1000 parts, but in general too:

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Cheers
