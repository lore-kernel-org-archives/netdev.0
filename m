From: David Miller <davem@davemloft.net>
Subject: [ANNOUNCE] NET Test Tools
Date: Fri, 18 Feb 2011 21:36:43 -0800 (PST)
Message-ID: <20110218.213643.193700084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pablo@netfilter.org,
	robert.olsson@its.uu.se
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750846Ab1BSFgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 00:36:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've made a GIT repository at:

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git

that contains little tools like the udpflood program I posted the other
day.

It requires libmnl be installed.  I'm happy to take patches with the
strict rule that adding autoconf is not allowed.

Also in there is a new tool, "route_bench" that allows benchmarking
the ipv4 route lookup path.  Amusingly it's slower than udpflood
because we have to recvmsg() sink the rtnetlink replies, maybe there
is some way to optimize that?

The tool allows all kinds of iteration through the various keys of a
routing lookup.

davem@maramba:~/src/GIT/route_bench$ route_bench -h
usage: route_bench [ -o ] [ -l count ]
                [ -s src_ip ] [ -a src_ip_stride ] [ -b src_ip_limit ]
                [ -d dst_ip ] [ -e dst_ip_stride ] [ -f dst_ip_limit ]
                [ -i iif ] [ -x iif_stride ] [ -y iif_limit ]
                [ -m mark ] [ -n mark_stride ] [ -p mark_limit ]
                [ -t tos ] [ -q tos_stride ] [ -r tos_limit ]

For example, the following does 100000 lookups, iterating over destination
addresses 10.8.0.2 to 10.8.0.254 in increments of 7.

davem@maramba:~/src/GIT/route_bench$ route_bench -l 100000 -d 10.8.0.2 -a 7 -b 10.8.0.254
Bench: count(100000) saddr[0x00000000] daddr[0x0a080002] mark[0x0] iif[0x0]
Result: 0m2.342s
davem@maramba:~/src/GIT/route_bench$ 

That is with the routing cache removed on a Niagara 2+ machine.

You can use the "-o" option to control how the program handles the case where
it has been asked to iterate over several keys.  By default, all keys iterate
at the same time.  With "-o" specified we iterate only the highest priority
key until it wraps, then we iterate over the next key, and so on and so
forth.  The priority is src --> dst --> iif --> mark --> tos.

Note that if "iif" is zero (it's default value) we do an output lookup,
else we do an input route lookup.

I want to add randomization to the iteration, as well as threading support.

Enjoy.
