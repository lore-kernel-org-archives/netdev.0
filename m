From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: avoid too many hrtimer_start() calls
Date: Tue, 24 May 2016 14:49:39 -0700 (PDT)
Message-ID: <20160524.144939.1690436082295084190.davem@davemloft.net>
References: <1463779960.5939.7.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160523115000.40e25fab@redhat.com>
	<1464038696.5939.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
	aduyck@mirantis.com, john.r.fastabend@intel.com, jhs@mojatatu.com,
	brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbcEXVtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 17:49:41 -0400
In-Reply-To: <1464038696.5939.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 May 2016 14:24:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I found a serious performance bug in packet schedulers using hrtimers.
> 
> sch_htb and sch_fq are definitely impacted by this problem.
> 
> We constantly rearm high resolution timers if some packets are throttled
> in one (or more) class, and other packets are flying through qdisc on
> another (non throttled) class.
> 
> hrtimer_start() does not have the mod_timer() trick of doing nothing if
> expires value does not change :
> 
> 	if (timer_pending(timer) &&
>             timer->expires == expires)
>                 return 1;
> 
> This issue is particularly visible when multiple cpus can queue/dequeue
> packets on the same qdisc, as hrtimer code has to lock a remote base.
> 
> I used following fix :
> 
> 1) Change htb to use qdisc_watchdog_schedule_ns() instead of open-coding
> it.
> 
> 2) Cache watchdog prior expiration. hrtimer might provide this, but I
> prefer to not rely on some hrtimer internal.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, applied, thanks Eric.
