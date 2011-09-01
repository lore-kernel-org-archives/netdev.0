From: David Madore <david+ml@madore.org>
Subject: possible routing table cache bug for mtu/advmss attributes in
 Linux 3.0.4
Date: Thu, 1 Sep 2011 23:46:43 +0200
Message-ID: <20110901214643.GA16989@aldebaran.gro-tsen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Netdev Mailing-List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aldebaran.gro-tsen.net ([88.191.60.176]:51765 "EHLO
	aldebaran.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab1IAV43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 17:56:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I believe I've found a bug in the routing cache (perhaps only for
IPv6) in Linux 3.0.4.  Since I'm uncertain about the diagnosis, I'm
posting here for guidance as to how to proceed.

In a nutshell, the problem is this: my (manually entered) routing
tables specify an explicit MTU/MSS for certain IPv6 routes, and after
upgrading from 2.6.38.7 to 3.0.4, I found that this MTU/MSS setting is
sometimes ignored.  More precisely, it seems that connecting to a host
through the route in question causes a routing cache entry to be
created, and it is when this cache entry expires that the route
forgets the MTU/MSS setting.  (It may also be relevant that in my case
the route belongs to a routing table other than "main".)

In more details: my routing tables contains the following:

vega david ~ $ sudo ip -6 rule show 
0:      from all lookup local 
32766:  from all lookup main 
40000:  from 2002::/16 lookup 2002 
40100:  from all lookup 2001 
vega david ~ $ sudo ip -6 route show table 2001
2002::/16 via ::192.88.99.1 dev tun6to4  metric 512  mtu 1466 advmss 1406
2000::/3 dev ppp0  metric 64  mtu 1466 advmss 1406

Initially, trying to get the route to 2001:41d0:1:a431::1 correctly
returns route with the mtu and advmss values I entered:

vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0  src 2001:7a8:78ae::1  metric 0 
    cache  mtu 1466 advmss 1406

Now I start an ssh connection to 2001:41d0:1:a431::1, close it
immediately, and fetch the route again:

vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0  src 2001:7a8:78ae::1  metric 0 
    cache  mtu 1466 rtt 37ms rttvar 37ms cwnd 10 advmss 1406

This is still correct.  But if I wait a few seconds (doing nothing)
for these data to expire, they seems to take the mtu and advmss values
away with them:

vega david ~ $ sudo ip route get 2001:41d0:1:a431::1
2001:41d0:1:a431::1 from :: via 2001:41d0:1:a431::1 dev ppp0  src 2001:7a8:78ae::1  metric 0 
    cache 

(note the empty "cache" line and the absence of mtu/advmss settings).

This is not just wrongly reported: the route really is wrong, and
opening a TCP connection at this stage will use a wrong MSS (and
freeze on large packets, because my Internet provider is worthless,
but that's another story).  At some point the route seems to return to
normal, but I couldn't figure out what causes this exactly.

In case it's uesful, my kernel config is on <URL:
http://www.madore.org/~david/.tmp/config-3.0.4-vega
 >.

Any thoughts?

-- 
     David A. Madore
   ( http://www.madore.org/~david/ )
