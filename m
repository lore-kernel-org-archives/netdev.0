From: alex@pilosoft.com
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.
Date: Thu, 8 Apr 2004 14:34:39 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0404081415420.21692-100000@paix.pilosoft.com>
References: <012201c41d94$cee1b400$0348858e@D4SF2B21>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <012201c41d94$cee1b400$0348858e@D4SF2B21>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Why we need a routing cache?  A patricia tree or radix tree is not fast
> enough with the kind of memory speed we have in PC technologies now???
I absolutely agree. Rephasing Linus, "solution to slow route lookup is 
fast route lookup, not another kernel abstraction". 

> The main goal to remove the routing cache is to avoid to have 4096
> routes limitation + all problem of the cache is not flush correclty when
> default route/next-hop for a particular route are change in the middle
> of a TCP connection and are not consider at all.  Also, when the routing
> cache is finally flush, all the information about the PMTU of the other
> entries are lost and must be rebuild.  So it's a lot of rebuilding of
> information for nothing when you have a lot of peer to talk with.
Well, there is no limitation of 4096 routes in route-cache or RIB. If you 
change the hash size, you can have 32k routes in route-cache easily. And I 
have >100k routes in the RIB.

> It's may look like overkill for a home user, but for commercial server,
> 4k routes can be really fast exhauted.  For us, we talking more about
> million of routes in the system.  Also, the patch I provide exploit
> already the plug/and/pray of the fib.  But doesn't give at all the
> flexibility to remove the _unclean_ hack: the routing cache.
> 
> What is dirty form the current implementation, quick example spagetti code
> with goto going back at the beginning of the function in route.c in IPV6.
> All the mtu/pmtu put in the cache entries instead in the fib himself.  Just
> to name few examples.
Unfortunately, bunch of things in linux depend on existence of per-flow
route-cache to store transient flow information. Just do 'ip -s -o route
list cache'. You get arp-unreachable info, mtu, , etc. 

It isn't as easy as just disable out route-cache and recomputing route
from RIB (even if RIB lookup was O(1)).

Removal (or making route-cache optional) is extremely important to those 
who are running internet-connected routers. It simply does not matter that 
you can handle 300kpps in a single flow, when 50kpps flood of 1 
packet-per-flow will kill you. Unfortunately, there's no easy solution...
