From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: About caching unreachable routes when not forwarding
Date: Fri, 12 Sep 2014 16:14:19 +0200
Message-ID: <1410531260-13794-1-git-send-email-nicolas.cavallari@green-communications.fr>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:49457 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbaILOPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 10:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have some weird routing problem on a seemingly simple setup on a
3.12-3.16 kernel and I suspect that net-next is also affected.

I have two interfaces: A, B, with forwarding disabled on A and
enabled on B.  I also have another interface V.

Both interfaces receive a packet that must be routed though V:
- A receives the packet first, do some fib lookup and cache a "route
unreachable" rt_iif=0 because forwarding is disabled.
- B receives the packet, do some fib lookup (and reverse path filtering, whatever) and succeeds, then finds the recently cached rth and use it. This cached rth is of course "route unreachable" and forwarding is broken.

This simple script in a network namespace is enough to show it:

#!/bin/sh -eu
setup_iface () {
        ip link add name "$1" type dummy
        ip link set dev "$1" up
        [ -n "${2:-}" ] && ip route add "$2" dev "$1"
        ip4conf="/proc/sys/net/ipv4/conf/$1"
        echo "$3" > "$ip4conf/forwarding"
        echo "$4" > "$ip4conf/rp_filter"
}
ip link set lo up
setup_iface "A" ""              0       0
setup_iface "B" "10.0.0.2/32"   1       1
setup_iface "C" "10.0.0.1/32"   1       0
set -x +e
ip route get 10.0.0.1 from 10.0.0.2 iif A
# unreachable
ip route get 10.0.0.1 from 10.0.0.2 iif B
# unreachable, but should be reachable

ip route flush cache
ip route get 10.0.0.1 from 10.0.0.2 iif B
# reachable
ip route get 10.0.0.1 from 10.0.0.2 iif A
# reachable, but should be unreachable

I would suggest that we shouldn't cache unreachable results due to
forwarding being disabled, but I'm not aware of all use-case of this
code nor what should actually be cached.  The following patch fix
my use case.  I don't know if it breaks others.
