From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] bonding: cancel_delayed_work() ->
	cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 07:49:31 +0000
Message-ID: <20091217074930.GA6779@ff.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Petri Gynther <pgynther@google.com>
To: Mikhail Markine <markine@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:37328 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbZLQHth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 02:49:37 -0500
Received: by fxm21 with SMTP id 21so1637038fxm.21
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 23:49:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-12-2009 01:28, Mikhail Markine wrote:
> A race condition was observed with bond_mii_monitor() attempting to
> process an interface already closed by bond_close() in response to
> 'ifconfig bond<x> down'.
> 
> Change all instances of cancel_delayed_work() to cancel_delayed_work_sync().

I think you can't do it at places which hold rtnl_lock with works
taking this lock too. Did you test it with CONFIG_PROVE_LOCKING btw?

Jarek P.

> 
> Signed-off-by: Mikhail Markine <markine@google.com>
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/bonding/bond_main.c  |   16 ++++++++--------
>  drivers/net/bonding/bond_sysfs.c |    4 ++--
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index af9b9c4..2bdacb6 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3786,20 +3786,20 @@ static int bond_close(struct net_device *bond_dev)
>  	write_unlock_bh(&bond->lock);
>  
>  	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
> -		cancel_delayed_work(&bond->mii_work);
> +		cancel_delayed_work_sync(&bond->mii_work);
>  	}
>  
>  	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
> -		cancel_delayed_work(&bond->arp_work);
> +		cancel_delayed_work_sync(&bond->arp_work);
>  	}
>  
>  	switch (bond->params.mode) {
>  	case BOND_MODE_8023AD:
> -		cancel_delayed_work(&bond->ad_work);
> +		cancel_delayed_work_sync(&bond->ad_work);
>  		break;
>  	case BOND_MODE_TLB:
>  	case BOND_MODE_ALB:
> -		cancel_delayed_work(&bond->alb_work);
> +		cancel_delayed_work_sync(&bond->alb_work);
>  		break;
>  	default:
>  		break;
> @@ -4566,18 +4566,18 @@ static void bond_work_cancel_all(struct bonding *bond)
>  	write_unlock_bh(&bond->lock);
>  
>  	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
> -		cancel_delayed_work(&bond->mii_work);
> +		cancel_delayed_work_sync(&bond->mii_work);
>  
>  	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
> -		cancel_delayed_work(&bond->arp_work);
> +		cancel_delayed_work_sync(&bond->arp_work);
>  
>  	if (bond->params.mode == BOND_MODE_ALB &&
>  	    delayed_work_pending(&bond->alb_work))
> -		cancel_delayed_work(&bond->alb_work);
> +		cancel_delayed_work_sync(&bond->alb_work);
>  
>  	if (bond->params.mode == BOND_MODE_8023AD &&
>  	    delayed_work_pending(&bond->ad_work))
> -		cancel_delayed_work(&bond->ad_work);
> +		cancel_delayed_work_sync(&bond->ad_work);
>  }
>  
>  /*
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 4e00b4f..d951939 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -598,7 +598,7 @@ static ssize_t bonding_store_arp_interval(struct device *d,
>  		       bond->dev->name, bond->dev->name);
>  		bond->params.miimon = 0;
>  		if (delayed_work_pending(&bond->mii_work)) {
> -			cancel_delayed_work(&bond->mii_work);
> +			cancel_delayed_work_sync(&bond->mii_work);
>  			flush_workqueue(bond->wq);
>  		}
>  	}
> @@ -1117,7 +1117,7 @@ static ssize_t bonding_store_miimon(struct device *d,
>  					BOND_ARP_VALIDATE_NONE;
>  			}
>  			if (delayed_work_pending(&bond->arp_work)) {
> -				cancel_delayed_work(&bond->arp_work);
> +				cancel_delayed_work_sync(&bond->arp_work);
>  				flush_workqueue(bond->wq);
>  			}
>  		}
