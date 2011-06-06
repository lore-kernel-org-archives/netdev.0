From: Simon Kirby <sim@hostway.ca>
Subject: ipv6 hitting route max_size
Date: Mon, 6 Jun 2011 14:37:27 -0700
Message-ID: <20110606213727.GB11757@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:55596 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757423Ab1FFV44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 17:56:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

/proc/sys/net/ipv4/route/max_size is the maximum size of the ipv4 route
_cache_, which is based on hash table size which is based on ram size.
The route _cache_ (eg: ip -4 route show cache) is not allowed to grow
beyond this size. gc_min_interval_ms was added to allow garbage
collection to happen often enough that this would not be reached even
under spoofed-address attacks (which we used to see happen before).

/proc/sys/net/ipv6/route/max_size and a number of similar GC knobs exist,
but max_size seems to limit the size of the v6 route table, not the v6
route cache. net/ipv6/route.c:2829 just sets this to 4096:

	net->ipv6.sysctl.ip6_rt_max_size = 4096;

If I set up quagga and ipv6 bgp peering to the Internets, I get about
6075 routes today, exceeding this limit. This cases zebra to log errors
such as this when it tries to add the routes to the kernel:

netlink-cmd error: Cannot allocate memory, type=RTM_NEWROUTE(24), seq=27089196, pid=0

This goes away if I increase /proc/sys/net/ipv6/route/max_size.

Is this cache limit somehow tied to route entries by some (un)intentional
IPv6 feature?

Reproduce with something like this (bash, 2.6.32 or 2.6.39 or similar):

for ((i = 0;i < 4200;i++)); do ip route add unreachable 2000::$i; done

Note that 4100 succeeds on my box, so something else is also happening.

Simon-
 
