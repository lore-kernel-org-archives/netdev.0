From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: use pinned timers
Date: Fri, 26 Sep 2014 00:27:10 -0400 (EDT)
Message-ID: <20140926.002710.1595423408687413602.davem@davemloft.net>
References: <1411261290.26859.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbaIZE1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 00:27:12 -0400
In-Reply-To: <1411261290.26859.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 20 Sep 2014 18:01:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While using a MQ + NETEM setup, I had confirmation that the default
> timer migration ( /proc/sys/kernel/timer_migration ) is killing us.
> 
> Installing this on a receiver side of a TCP_STREAM test, (NIC has 8 TX
> queues) :
 ...
> We can see that timers get migrated into a single cpu, presumably idle
> at the time timers are set up.
> Then all qdisc dequeues run from this cpu and huge lock contention
> happens. This single cpu is stuck in softirq mode and cannot dequeue
> fast enough.
> 
>     39.24%  [kernel]          [k] _raw_spin_lock
>      2.65%  [kernel]          [k] netem_enqueue
>      1.80%  [kernel]          [k] netem_dequeue                         
>      1.63%  [kernel]          [k] copy_user_enhanced_fast_string
>      1.45%  [kernel]          [k] _raw_spin_lock_bh        
> 
> By pinning qdisc timers on the cpu running the qdisc, we respect proper
> XPS setting and remove this lock contention.
> 
>      5.84%  [kernel]          [k] netem_enqueue                      
>      4.83%  [kernel]          [k] _raw_spin_lock
>      2.92%  [kernel]          [k] copy_user_enhanced_fast_string
> 
> Current Qdiscs that benefit from this change are :
> 
> 	netem, cbq, fq, hfsc, tbf, htb.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric.
