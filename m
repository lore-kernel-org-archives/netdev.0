From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net v2 6/8] forcedeth: Fix a race during rmmod of
 forcedeth
Date: Fri, 4 Nov 2011 03:46:26 +0000
Message-ID: <1320378386.3079.56.camel@deadeye>
References: <cover.1320369398.git.david.decotigny@google.com>
	 <267015997eb594f2fd859acd572aa20dfc3e3e63.1320369398.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Salman Qazi <sqazi@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28307 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab1KDDql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 23:46:41 -0400
In-Reply-To: <267015997eb594f2fd859acd572aa20dfc3e3e63.1320369398.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-03 at 18:41 -0700, David Decotigny wrote:
> From: Salman Qazi <sqazi@google.com>
> 
> The race was between del_timer_sync and nv_do_stats_poll called through
> nv_get_ethtool_stats.

I don't think so.  nv_close() and nv_get_ethtool_stats() are both called
with RTNL held.

Calling the timer function from nv_get_ethtool_stats is very likely part
of the problem though, so why don't you stop doing that?

[...]
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index 0af12a8..7996782 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -3937,6 +3937,10 @@ static void nv_poll_controller(struct net_device *dev)
>  }
>  #endif
>  
> +/* No locking is needed as long as this is in the timer
> + * callback.  However, any other callers must call this
> + * function with np->lock held.
> + */

So long as this function is used by all of (1) the timer function (2)
the ndo_get_stats implementation (3) the ethtool get_stats
implementation, it can most certainly be called concurrently on multiple
processors.

You could have (2) and (3) return the last polled stats and not poll the
hardware themselves, but you would need to use the functions from
<linux/u64_stats_sync.h> to avoid word-tearing on 32-bit architectures.

>  static void nv_do_stats_poll(unsigned long data)
>  {
>         struct net_device *dev = (struct net_device *) data;
> @@ -4589,12 +4593,17 @@ static int nv_get_sset_count(struct net_device *dev, int sset)
>  
>  static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *estats, u64 *buffer)
>  {
> +       unsigned long flags;
>         struct fe_priv *np = netdev_priv(dev);
>  
> +       spin_lock_irqsave(&np->lock, flags);
> +
>         /* update stats */
>         nv_do_stats_poll((unsigned long)dev);
>  
>         memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
> +
> +       spin_unlock_irqrestore(&np->lock, flags);

This function is not called from interrupt context.

>  }
>  
>  static int nv_link_test(struct net_device *dev)
> @@ -5189,13 +5198,13 @@ static int nv_close(struct net_device *dev)
>  
>         spin_lock_irq(&np->lock);
>         np->in_shutdown = 1;
> +       del_timer_sync(&np->stats_poll);
>         spin_unlock_irq(&np->lock);
>         nv_napi_disable(dev);
>         synchronize_irq(np->pci_dev->irq);
>  
>         del_timer_sync(&np->oom_kick);
>         del_timer_sync(&np->nic_poll);
> -       del_timer_sync(&np->stats_poll);
>  
>         netif_stop_queue(dev);
>         spin_lock_irq(&np->lock);

I don't believe this code movement is helpful.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
