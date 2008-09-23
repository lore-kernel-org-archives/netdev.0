From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 10/21] driver/net/skge.c: restart the interface when
 it's options or pauseparam is set
Date: Tue, 23 Sep 2008 16:47:18 -0700
Message-ID: <20080923164718.787237e2@extreme>
References: <200809222152.m8MLqHXf031966@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	Xiaoming.Zhang@resilience.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46918 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbYIWXrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 19:47:23 -0400
In-Reply-To: <200809222152.m8MLqHXf031966@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Sep 2008 14:52:17 -0700
akpm@linux-foundation.org wrote:

> From: "Xiaoming.Zhang" <Xiaoming.Zhang@resilience.com>
> 
> We have an issue of the skge driver: The card won't work when it's options
> are changed.  Here's the hardware info:
> 
> # lspci -v
> 05:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit Ethernet Controller (rev 13)
>         Subsystem: Marvell Technology Group Ltd. Marvell RDK-8001
>         Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 16
>         Memory at d042c000 (32-bit, non-prefetchable) [size=16K]
>         I/O ports at d000 [size=256]
>         [virtual] Expansion ROM at 20400000 [disabled] [size=128K]
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
> 
> The happens in both Linux-2.6.26(skge version 1.23) and RHEL5.2(skge
> version 1.6).
> 
> For example, at first it is set to "speed 1000 duplex full auto-neg on" and
> it works, then run
> 
>        ethtool -s <ethx> autoneg off
> or     ethtool -s <ethx> speed 100 duplex full autoneg off
> 
> Then it will stop working. After that if we restart the interface:
> 
> 	ifconifg <ethx> down
> 	ifconfig <ethx> up
> 
> It will work again. And `ethtool -A' has the same issue.
> 
> So we think after setting the options, the interface should be restarted. 
> 
> Signed-off-by: Zhang Xiaoming <xiaoming.zhang@resilience.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/skge.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff -puN drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-options-or-pauseparam-is-set drivers/net/skge.c
> --- a/drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-options-or-pauseparam-is-set
> +++ a/drivers/net/skge.c
> @@ -353,8 +353,10 @@ static int skge_set_settings(struct net_
>  	skge->autoneg = ecmd->autoneg;
>  	skge->advertising = ecmd->advertising;
>  
> -	if (netif_running(dev))
> -		skge_phy_reset(skge);
> +	if (netif_running(dev)) {
> +		skge_down(dev);
> +		skge_up(dev);
> +	}
>  
>  	return (0);
>  }
> @@ -595,8 +597,10 @@ static int skge_set_pauseparam(struct ne
>  			skge->flow_control = FLOW_MODE_NONE;
>  	}
>  
> -	if (netif_running(dev))
> -		skge_phy_reset(skge);
> +	if (netif_running(dev)) {
> +		skge_down(dev);
> +		skge_up(dev);
> +	}
>  
>  	return 0;
>  }

Since skge_up can fail because of out of memory, this code needs to
check the return value. And then if it fails the "limbo state" needs
to be handled in skge_down.


