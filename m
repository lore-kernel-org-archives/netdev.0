From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: increase unres_qlen by one magnitude
Date: Tue, 08 Nov 2011 17:24:48 -0500 (EST)
Message-ID: <20111108.172448.2101648110512252549.davem@davemloft.net>
References: <1320783085.2588.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1KHWYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:24:51 -0500
In-Reply-To: <1320783085.2588.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2011 21:11:25 +0100

> unres_qlen is the number of frames we are able to queue per unresolved
> neighbour. Its default value (3) was never changed and is responsible
> for strange drops, especially if IP fragments are used, or multiple
> sessions start in parallel. TCP initial congestion window is now bigger
> than 3.
> 
> $ arp -d 192.168.20.108 ; ping -c 2 -s 8000 192.168.20.108
> PING 192.168.20.108 (192.168.20.108) 8000(8028) bytes of data.
> 8008 bytes from 192.168.20.108: icmp_seq=2 ttl=64 time=0.322 ms
> 
> --- 192.168.20.108 ping statistics ---
> 2 packets transmitted, 1 received, 50% packet loss, time 1001ms
> rtt min/avg/max/mdev = 0.322/0.322/0.322/0.000 ms
> 
> Since available memory per machine increased quite a lot since 1999, I
> believe its safe to expand unres_qlen to a more reasonable value.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Pretty risky don't you think?

So now we'll allow essentially any remote machine to force us to hold
on to memory on the order of (32 * num_ips_in_subnet) for each IP
address configured.

Just spam UDP or ICMP packets with a source address iterating over
addresses in one of the host's subnets.  If the subnet space is
relatively large, chances are %99 of those IPs won't respond to ARP
and we'll queue up the ICMP replies.

Probably what will trigger first, actually, is we'll hit the per-cpu
ICMP socket send buffer limit.  Because we won't even get to the
point in the TX path where we will early orphan the SKB.

So essentially this will stop ICMP responses completely for all
traffic processed on that cpu.

I realize you're trying to address a very real problem, but I'm just
not sure at all that unilaterally increasing the value like this is
safe.
