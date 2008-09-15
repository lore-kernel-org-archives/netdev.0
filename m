From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Tue, 16 Sep 2008 02:45:22 +0400
Message-ID: <20080915224522.GA21012@x200.localdomain>
References: <20080821115849.GA2126@x200.localdomain> <20080914181714.34935d9c@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:51281 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbYIOWnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 18:43:23 -0400
Received: by gxk9 with SMTP id 9so26149058gxk.13
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 15:43:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080914181714.34935d9c@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 06:17:14PM -0500, Jay Cliburn wrote:
> On Thu, 21 Aug 2008 15:58:49 +0400
> adobriyan@gmail.com wrote:
> 
> > This message happens more or less every reboot, sometimes cable
> > unplug/plug is needed to restore connectivity, otherwise card is
> > working fine.
> > 
> > 
> > [   22.570010] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> > [   26.570011] NET: Registered protocol family 10
> > [   37.551934] eth0: no IPv6 routers present
> > 
> > 	[rebooted box which is directly connected to a box with atl1]
> > 
> > [ 2078.740004] atl1 0000:03:00.0: eth0 link is down
> > [ 2080.790004] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full
> > duplex [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> > [ 2086.050004] ------------[ cut here ]------------
> > [ 2086.050004] WARNING: at net/sched/sch_generic.c:221
> [...]
> 
> Alexey,
> 
> Can you please try this patch?

Seems to help (no more messages), still sometimes no networking until after
cable replug. Stay tuned.

> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -2642,6 +2642,7 @@ static void atl1_down(struct atl1_adapter *adapter)
>  {
>  	struct net_device *netdev = adapter->netdev;
>  
> +	netif_stop_queue(netdev);
>  	del_timer_sync(&adapter->watchdog_timer);
>  	del_timer_sync(&adapter->phy_config_timer);
>  	adapter->phy_timer_pending = false;
> @@ -2655,7 +2656,6 @@ static void atl1_down(struct atl1_adapter *adapter)
>  	adapter->link_speed = SPEED_0;
>  	adapter->link_duplex = -1;
>  	netif_carrier_off(netdev);
> -	netif_stop_queue(netdev);
>  
>  	atl1_clean_tx_ring(adapter);
>  	atl1_clean_rx_ring(adapter);
> @@ -2724,6 +2724,8 @@ static int atl1_open(struct net_device *netdev)
>  	struct atl1_adapter *adapter = netdev_priv(netdev);
>  	int err;
>  
> +	netif_carrier_off(netdev);
> +
>  	/* allocate transmit descriptors */
>  	err = atl1_setup_ring_resources(adapter);
>  	if (err)
> diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
> index b3e7fcf..3cc9d10 100644
> --- a/drivers/net/atlx/atlx.c
> +++ b/drivers/net/atlx/atlx.c
> @@ -105,7 +105,6 @@ static void atlx_check_for_link(struct atlx_adapter *adapter)
>  				netdev->name);
>  			adapter->link_speed = SPEED_0;
>  			netif_carrier_off(netdev);
> -			netif_stop_queue(netdev);
>  		}
>  	}
>  	schedule_work(&adapter->link_chg_task);
