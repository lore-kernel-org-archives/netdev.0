From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Mon, 21 Jan 2008 14:33:38 +0100
Message-ID: <20080121133338.GH1789@ff.dom.local>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com> <20080117111822.GB1710@ff.dom.local> <4790ACF2.1090207@miraclelinux.com> <479127C6.1080701@gmail.com> <47912B83.5010407@gmail.com> <479419B6.9000000@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:42968 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbYAUN1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 08:27:05 -0500
Received: by ug-out-1314.google.com with SMTP id z38so874836ugc.16
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 05:27:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <479419B6.9000000@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 01:04:06PM +0900, Makito SHIOKAWA wrote:
> > (But new_value = 0 seems needed - just like from module_param()?)
> Do you mean to initialize new_value before sscanf()? (There is a check 'if (sscanf(buf, "%d", &new_value) != 1)', so is it necesarry?)

No: you mentioned about treating new_value == 0 like new_value < 0
with 'if (new_value <= 0)', and I didn't understand this idea...

>
> > - maybe to test if the value has changed at all,
> Tested.
>
> For now, patch will be like below. Any slight comment for this will be helpful, regards.

I think cancelling of delayed works in bond_sysfs is OK now.

Alas I don't understand the reason of this change in bond_main()...
Some comment?

Thanks,
Jarek P.

>
>
> Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
> ---
>  drivers/net/bonding/bond_main.c  |   11 ++++-------
>  drivers/net/bonding/bond_sysfs.c |   19 +++++++++++++++++--
>  2 files changed, 21 insertions(+), 9 deletions(-)
>
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2699,7 +2699,7 @@ void bond_loadbalance_arp_mon(struct wor
>
>  	read_lock(&bond->lock);
>
> -	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
> +	delta_in_ticks = ((bond->params.arp_interval * HZ) / 1000) ? : 1;
>
>  	if (bond->kill_timers) {
>  		goto out;
> @@ -2801,8 +2801,7 @@ void bond_loadbalance_arp_mon(struct wor
>  	}
>
>  re_arm:
> -	if (bond->params.arp_interval)
> -		queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
> +	queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
>  out:
>  	read_unlock(&bond->lock);
>  }
> @@ -2832,7 +2831,7 @@ void bond_activebackup_arp_mon(struct wo
>
>  	read_lock(&bond->lock);
>
> -	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
> +	delta_in_ticks = ((bond->params.arp_interval * HZ) / 1000) ? : 1;
>
>  	if (bond->kill_timers) {
>  		goto out;
> @@ -3058,9 +3057,7 @@ void bond_activebackup_arp_mon(struct wo
>  	}
>
>  re_arm:
> -	if (bond->params.arp_interval) {
> -		queue_delayed_work(bond->wq, &bond->ab_arp_work, delta_in_ticks);
> -	}
> +	queue_delayed_work(bond->wq, &bond->ab_arp_work, delta_in_ticks);
>  out:
>  	read_unlock(&bond->lock);
>  }
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -644,6 +644,15 @@ static ssize_t bonding_store_arp_interva
>  	       ": %s: Setting ARP monitoring interval to %d.\n",
>  	       bond->dev->name, new_value);
>  	bond->params.arp_interval = new_value;
> +	if (bond->params.arp_interval == 0 && (bond->dev->flags & IFF_UP)) {
> +		printk(KERN_INFO DRV_NAME
> +		       ": %s: Disabling ARP monitoring.\n",
> +		       bond->dev->name);
> +		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
> +			cancel_delayed_work_sync(&bond->ab_arp_work);
> +		else
> +			cancel_delayed_work_sync(&bond->lb_arp_work);
> +	}
>  	if (bond->params.miimon) {
>  		printk(KERN_INFO DRV_NAME
>  		       ": %s: ARP monitoring cannot be used with MII monitoring. "
> @@ -658,7 +667,7 @@ static ssize_t bonding_store_arp_interva
>  		       "but no ARP targets have been specified.\n",
>  		       bond->dev->name);
>  	}
> -	if (bond->dev->flags & IFF_UP) {
> +	if (bond->params.arp_interval && (bond->dev->flags & IFF_UP)) {
>  		/* If the interface is up, we may need to fire off
>  		 * the ARP timer.  If the interface is down, the
>  		 * timer will get fired off when the open function
> @@ -997,6 +1006,12 @@ static ssize_t bonding_store_miimon(stru
>  		       ": %s: Setting MII monitoring interval to %d.\n",
>  		       bond->dev->name, new_value);
>  		bond->params.miimon = new_value;
> +		if (bond->params.miimon == 0 && (bond->dev->flags & IFF_UP)) {
> +			printk(KERN_INFO DRV_NAME
> +			       ": %s: Disabling MII monitoring...\n",
> +			       bond->dev->name);
> +			cancel_delayed_work_sync(&bond->mii_work);
> +		}
>  		if(bond->params.updelay)
>  			printk(KERN_INFO DRV_NAME
>  			      ": %s: Note: Updating updelay (to %d) "
> @@ -1026,7 +1041,7 @@ static ssize_t bonding_store_miimon(stru
>  				cancel_delayed_work_sync(&bond->lb_arp_work);
>  		}
>
> -		if (bond->dev->flags & IFF_UP) {
> +		if (bond->params.miimon && (bond->dev->flags & IFF_UP)) {
>  			/* If the interface is up, we may need to fire off
>  			 * the MII timer. If the interface is down, the
>  			 * timer will get fired off when the open function
>
>
> -- 
> Makito SHIOKAWA
> MIRACLE LINUX CORPORATION
