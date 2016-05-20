From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Fri, 20 May 2016 19:38:58 -0400 (EDT)
Message-ID: <20160520.193858.303047987973510057.davem@davemloft.net>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, john.fastabend@gmail.com,
	kda@google.com, xiaotian@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbcETXjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:39:00 -0400
In-Reply-To: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 May 2016 05:35:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Large tc dumps (tc -s {qdisc|class} sh dev ethX) done by Google BwE host
> agent [1] are problematic at scale :
>     
> For each qdisc/class found in the dump, we currently lock the root qdisc
> spinlock in order to get stats. Sampling stats every 5 seconds from
> thousands of HTB classes is a challenge when the root qdisc spinlock is
> under high pressure.
> 
> These stats are using u64 or u32 fields, so reading integral values
> should not prevent writers from doing concurrent updates if the kernel
> arch is a 64bit one.
> 
> Being able to atomically fetch all counters like packets and bytes sent
> at the expense of interfering in fast path (queue and dequeue packets)
> is simply not worth the pain, as the values are generally stale after 1
> usec.
> 
> These lock acquisitions slow down the fast path by 10 to 20 %
> 
> An audit of existing qdiscs showed that sch_fq_codel is the only qdisc
> that might need the qdisc lock in fq_codel_dump_stats() and
> fq_codel_dump_class_stats()
> 
> gnet_dump_force_lock() call is added there and could be added to other
> qdisc stat handlers if needed.
> 
> [1]
> http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43838.pdf
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I guess the off-by-one situations are not a big enough deal to code new
locking or memory barrier for, so I'm fine with this.

Please resubmit when I open net-next back up, thanks.
