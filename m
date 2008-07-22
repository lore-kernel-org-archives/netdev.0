From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 2/6] netns: dont alloc ipv6 fib timer list
Date: Tue, 22 Jul 2008 04:20:56 +0200
Message-ID: <48854408.9050804@fr.ibm.com>
References: <20080721192834.221648982@vyatta.com> <20080721192920.058840619@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:56990 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbYGVCVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 22:21:03 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6M2L2it373616
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 02:21:02 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6M2L2Sk3702876
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 04:21:02 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6M2L1iJ020864
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 04:21:02 +0200
In-Reply-To: <20080721192920.058840619@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/ipv6/ip6_fib.c	2008-07-21 11:57:29.000000000 -0700
> +++ b/net/ipv6/ip6_fib.c	2008-07-21 12:02:07.000000000 -0700
> @@ -661,16 +661,16 @@ static int fib6_add_rt2node(struct fib6_
> 
>  static void fib6_start_gc(struct net *net, struct rt6_info *rt)
>  {
> -	if (!timer_pending(net->ipv6.ip6_fib_timer) &&
> +	if (!timer_pending(&net->ipv6.ip6_fib_timer) &&
>  	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
> -		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
> +		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
>  			  net->ipv6.sysctl.ip6_rt_gc_interval);
>  }
> 
>  void fib6_force_start_gc(struct net *net)
>  {
> -	if (!timer_pending(net->ipv6.ip6_fib_timer))
> -		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
> +	if (!timer_pending(&net->ipv6.ip6_fib_timer))
> +		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
>  			  net->ipv6.sysctl.ip6_rt_gc_interval);
>  }
> 
> @@ -1449,7 +1449,7 @@ void fib6_run_gc(unsigned long expires, 
>  	} else {
>  		local_bh_disable();
>  		if (!spin_trylock(&fib6_gc_lock)) {
> -			mod_timer(net->ipv6.ip6_fib_timer, jiffies + HZ);
> +			mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
>  			local_bh_enable();
>  			return;
>  		}
> @@ -1462,10 +1462,10 @@ void fib6_run_gc(unsigned long expires, 
>  	fib6_clean_all(net, fib6_age, 0, NULL);
> 
>  	if (gc_args.more)
> -		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
> +		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
>  			  net->ipv6.sysctl.ip6_rt_gc_interval);
>  	else
> -		del_timer(net->ipv6.ip6_fib_timer);
> +		del_timer(&net->ipv6.ip6_fib_timer);
>  	spin_unlock_bh(&fib6_gc_lock);
>  }
> 
> @@ -1476,16 +1476,7 @@ static void fib6_gc_timer_cb(unsigned lo
> 
>  static int fib6_net_init(struct net *net)
>  {
> -	int ret;
> -	struct timer_list *timer;
> -
> -	ret = -ENOMEM;
> -	timer = kzalloc(sizeof(*timer), GFP_KERNEL);
> -	if (!timer)
> -		goto out;
> -
> -	setup_timer(timer, fib6_gc_timer_cb, (unsigned long)net);
> -	net->ipv6.ip6_fib_timer = timer;
> +	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);

Perhaps I missed it, but I don't see in the patchset where is 
ip6_fib_timer changed to be no longer a pointer in the netns ipv6 structure.

>  	net->ipv6.rt6_stats = kzalloc(sizeof(*net->ipv6.rt6_stats), GFP_KERNEL);
>  	if (!net->ipv6.rt6_stats)
> @@ -1519,9 +1510,7 @@ static int fib6_net_init(struct net *net
>  #endif
>  	fib6_tables_init(net);
> 
> -	ret = 0;
> -out:
> -	return ret;
> +	return 0;
> 
>  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>  out_fib6_main_tbl:
> @@ -1532,15 +1521,14 @@ out_fib_table_hash:
>  out_rt6_stats:
>  	kfree(net->ipv6.rt6_stats);
>  out_timer:
> -	kfree(timer);
> -	goto out;
> +	return -ENOMEM;
>   }
> 
>  static void fib6_net_exit(struct net *net)
>  {
>  	rt6_ifdown(net, NULL);
> -	del_timer_sync(net->ipv6.ip6_fib_timer);
> -	kfree(net->ipv6.ip6_fib_timer);
> +	del_timer_sync(&net->ipv6.ip6_fib_timer);
> +
>  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>  	kfree(net->ipv6.fib6_local_tbl);
>  #endif

