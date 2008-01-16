From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 4/4] bonding: Fix some RTNL taking
Date: Wed, 16 Jan 2008 13:44:50 +0100
Message-ID: <20080116124450.GD2307@ff.dom.local>
References: <20080115063650.236883000@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:5780 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756233AbYAPMif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 07:38:35 -0500
Received: by fk-out-0910.google.com with SMTP id z23so38820fkz.5
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 04:38:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080115063650.236883000@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-01-2008 07:36, Makito SHIOKAWA wrote:
> Fix some RTNL lock taking:
> 
> * RTNL (mutex; may sleep) must not be taken under read_lock (spinlock; must be
> atomic). However, RTNL is taken under read_lock in bond_loadbalance_arp_mon()
> and bond_activebackup_arp_mon(). So change code to take RTNL outside of read_lock.
> 
> * rtnl_unlock() calls netdev_run_todo() which takes net_todo_run_mutex, and
> rtnl_unlock() is called under read_lock in bond_mii_monitor(). So for the same
> reason as above, change code to call rtnl_unlock() outside of read_lock.
> 
> Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
> ---
>  drivers/net/bonding/bond_main.c |   24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2372,6 +2372,7 @@ void bond_mii_monitor(struct work_struct
>  	struct bonding *bond = container_of(work, struct bonding,
>  					    mii_work.work);
>  	unsigned long delay;
> +	int need_unlock = 0;
>  
>  	read_lock(&bond->lock);
>  	if (bond->kill_timers) {
> @@ -2383,13 +2384,16 @@ void bond_mii_monitor(struct work_struct
>  		rtnl_lock();
>  		read_lock(&bond->lock);
>  		__bond_mii_monitor(bond, 1);
> -		rtnl_unlock();
> +		need_unlock = 1;

Maybe I'm wrong, but since this read_lock() is given and taken anyway,
it seems this looks a bit better to me (why hold this rtnl longer
than needed?):
		read_unlock(&bond->lock);
		rtnl_unlock();
		read_lock(&bond->lock);

On the other hand, probably 'if (bond->kill_timers)' could be repeated
after this read_lock() retaking.

>  	}
>  
>  	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
> -	read_unlock(&bond->lock);
>  	if (bond->params.miimon)
>  		queue_delayed_work(bond->wq, &bond->mii_work, delay);

If this if () is really necessary here, then this should be better
before "delay = ..." with a block.

> +	read_unlock(&bond->lock);
> +	/* rtnl_unlock() may sleep, so call it after read_unlock() */
> +	if (need_unlock)
> +		rtnl_unlock();
>  }

Regards,
Jarek P.
