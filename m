From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 00/11] udp: full early demux for unconnected sockets
Date: Fri, 22 Sep 2017 23:06:24 +0200
Message-ID: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33858 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752115AbdIVVG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:06:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series refactor the UDP early demux code so that:

* full socket lookup is performed for unicast packets
* a sk is grabbed even for unconnected socket match
* a dst cache is used even in such scenario

To perform this tasks a couple of facilities are added:

* noref socket references, scoped inside the current RCU section, to be
  explicitly cleared before leaving such section
* a dst cache inside the inet and inet6 local addresses tables, caching the
  related local dst entry

The measured performance gain under small packet UDP flood is as follow:

ingress NIC	vanilla		patched		delta
rx queues	(kpps)		(kpps)		(%)
[ipv4]
1		2177		2414		10
2		2527		2892		14
3		3050		3733		22
4		3918		4643		18
5		5074		5699		12
6		5654		6869		21

[ipv6]
1		2002		2821		40
2		2087		3148		50
3		2583		4008		55
4		3072		4963		61
5		3719		5992		61
6		4314		6910		60

The number of user space process in use is equal to the number of
NIC rx queue; when multiple user space processes the SO_REUSEPORT 
options is used, as described below:

ethtool  -L em2 combined $n
MASK=1
for I in `seq 0 $((n - 1))`; do
        udp_sink  --reuse-port --recvfrom --count 1000000000 --port 9 $1 &
        taskset -p $((MASK << ($I + $n) )) $!
done

Paolo Abeni (11):
  net: add support for noref skb->sk
  net: allow early demux to fetch noref socket
  udp: do not touch socket refcount in early demux
  net: add simple socket-like dst cache helpers
  udp: perform full socket lookup in early demux
  ip/route: factor out helper for local route creation
  ipv6/addrconf: add an helper for inet6 address lookup
  net: implement local route cache inside ifaddr
  route: add ipv4/6 helpers to do partial route lookup vs local dst
  IP: early demux can return an error code
  udp: dst lookup in early demux for unconnected sockets

 include/linux/inetdevice.h       |   4 ++
 include/linux/skbuff.h           |  31 +++++++++++
 include/linux/udp.h              |   2 +
 include/net/addrconf.h           |   3 ++
 include/net/dst.h                |  20 +++++++
 include/net/if_inet6.h           |   4 ++
 include/net/ip6_route.h          |   1 +
 include/net/protocol.h           |   4 +-
 include/net/route.h              |   4 ++
 include/net/tcp.h                |   2 +-
 include/net/udp.h                |   2 +-
 net/core/dst.c                   |  12 +++++
 net/core/sock.c                  |   7 +++
 net/ipv4/devinet.c               |  29 ++++++++++-
 net/ipv4/ip_input.c              |  33 ++++++++----
 net/ipv4/netfilter/nf_dup_ipv4.c |   3 ++
 net/ipv4/route.c                 |  73 +++++++++++++++++++++++---
 net/ipv4/tcp_ipv4.c              |   9 ++--
 net/ipv4/udp.c                   |  95 +++++++++++++++-------------------
 net/ipv6/addrconf.c              | 109 +++++++++++++++++++++++++++------------
 net/ipv6/ip6_input.c             |   4 ++
 net/ipv6/netfilter/nf_dup_ipv6.c |   3 ++
 net/ipv6/route.c                 |  13 +++++
 net/ipv6/udp.c                   |  72 ++++++++++----------------
 net/netfilter/nf_queue.c         |   3 ++
 25 files changed, 383 insertions(+), 159 deletions(-)

-- 
2.13.5
