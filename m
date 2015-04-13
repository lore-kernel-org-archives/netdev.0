From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp/dccp: get rid of central timewait timer
Date: Mon, 13 Apr 2015 16:40:50 -0400 (EDT)
Message-ID: <20150413.164050.281703475037013729.davem@davemloft.net>
References: <1428693574.25985.326.camel@edumazet-glaptop2.roam.corp.google.com>
	<1428889869.25985.375.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbbDMUkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 16:40:51 -0400
In-Reply-To: <1428889869.25985.375.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Apr 2015 18:51:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Using a timer wheel for timewait sockets was nice ~15 years ago when
> memory was expensive and machines had a single processor.
> 
> This does not scale, code is ugly and source of huge latencies
> (Typically 30 ms have been seen, cpus spinning on death_lock spinlock.)
> 
> We can afford to use an extra 64 bytes per timewait sock and spread
> timewait load to all cpus to have better behavior.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  v2: removed last inet_twsk_schedule() argument
>      restored original SNMP counters : TW / TWKill
>      fixed a compilation error reported by David
>      Removed the problematic --- markers from ping in changelog

Applied, but:

> @@ -367,115 +269,15 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
>  	 * is greater than TS tick!) and detect old duplicates with help
>  	 * of PAWS.
>  	 */
> -	slot = (timeo + (1 << INET_TWDR_RECYCLE_TICK) - 1) >> INET_TWDR_RECYCLE_TICK;
>  
> -	spin_lock(&twdr->death_lock);
> -
> -	/* Unlink it, if it was scheduled */
> -	if (inet_twsk_del_dead_node(tw))
> -		twdr->tw_count--;
> -	else
> +	tw->tw_kill = timeo <= 4*HZ;	

That last line has trailing whitespace which I removed.
