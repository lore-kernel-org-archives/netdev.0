From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: get rid of spin_trylock() in
 net_tx_action()
Date: Tue, 07 Jun 2016 15:38:55 -0700 (PDT)
Message-ID: <20160607.153855.854539552647659208.davem@davemloft.net>
References: <1465095748.2968.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422669AbcFGWi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:38:57 -0400
In-Reply-To: <1465095748.2968.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Jun 2016 20:02:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Note: Tom Herbert posted almost same patch 3 months back, but for
> different reasons.
> 
> The reasons we want to get rid of this spin_trylock() are :
> 
> 1) Under high qdisc pressure, the spin_trylock() has almost no
> chance to succeed.
> 
> 2) We loop multiple times in softirq handler, eventually reaching
> the max retry count (10), and we schedule ksoftirqd.
> 
> Since we want to adhere more strictly to ksoftirqd being waked up in
> the future (https://lwn.net/Articles/687617/), better avoid spurious
> wakeups.
> 
> 3) calls to __netif_reschedule() dirty the cache line containing
> q->next_sched, slowing down the owner of qdisc.
> 
> 4) RT kernels can not use the spin_trylock() here.
> 
> With help of busylock, we get the qdisc spinlock fast enough, and
> the trylock trick brings only performance penalty.
> 
> Depending on qdisc setup, I observed a gain of up to 19 % in qdisc
> performance (1016600 pps instead of 853400 pps, using prio+tbf+fq_codel)
> 
> ("mpstat -I SCPU 1" is much happier now)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
