From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 08:44:45 -0700
Message-ID: <20110524154445.GC2266@linux.vnet.ibm.com>
References: <1306228052.3026.16.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:49795 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab1EXPot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 11:44:49 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4OFMkKB012126
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 11:22:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4OFilwA096772
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 11:44:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4OFiln9013470
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 11:44:47 -0400
Content-Disposition: inline
In-Reply-To: <1306228052.3026.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 11:07:32AM +0200, Eric Dumazet wrote:
> synchronize_rcu() is very slow in various situations (HZ=100,
> CONFIG_NO_HZ=y, CONFIG_PREEMPT=n)
> 
> Extract from my (mostly idle) 8 core machine :
> 
>  synchronize_rcu() in 99985 us
>  synchronize_rcu() in 79982 us
>  synchronize_rcu() in 87612 us
>  synchronize_rcu() in 79827 us
>  synchronize_rcu() in 109860 us
>  synchronize_rcu() in 98039 us
>  synchronize_rcu() in 89841 us
>  synchronize_rcu() in 79842 us
>  synchronize_rcu() in 80151 us
>  synchronize_rcu() in 119833 us
>  synchronize_rcu() in 99858 us
>  synchronize_rcu() in 73999 us
>  synchronize_rcu() in 79855 us
>  synchronize_rcu() in 79853 us
> 
> 
> When we hold RTNL mutex, we would like to spend some cpu cycles but not
> block too long other processes waiting for this mutex.
> 
> We also want to setup/dismantle network features as fast as possible at
> boot/shutdown time.
> 
> This patch makes synchronize_net() call the expedited version if RTNL is
> locked.
> 
> synchronize_rcu_expedited() typical delay is about 20 us on my machine.
> 
>  synchronize_rcu_expedited() in 18 us
>  synchronize_rcu_expedited() in 18 us
>  synchronize_rcu_expedited() in 18 us
>  synchronize_rcu_expedited() in 18 us
>  synchronize_rcu_expedited() in 20 us
>  synchronize_rcu_expedited() in 16 us
>  synchronize_rcu_expedited() in 20 us
>  synchronize_rcu_expedited() in 18 us
>  synchronize_rcu_expedited() in 18 us

Cool!!!

Just out of curiosity, how many CPUs does your system have?

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> CC: Ben Greear <greearb@candelatech.com>
> ---
>  net/core/dev.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bcb05cb..ec11d75 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5954,7 +5954,10 @@ EXPORT_SYMBOL(free_netdev);
>  void synchronize_net(void)
>  {
>  	might_sleep();
> -	synchronize_rcu();
> +	if (rtnl_is_locked())
> +		synchronize_rcu_expedited();
> +	else
> +		synchronize_rcu();
>  }
>  EXPORT_SYMBOL(synchronize_net);
> 
> 
> 
