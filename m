From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v2 0/3] Improve UDP multicast receive latency
Date: Fri,  4 Oct 2013 14:28:13 -0500
Message-ID: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
Cc: netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:42633 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab3JDT2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 15:28:48 -0400
Received: by mail-oa0-f47.google.com with SMTP id i1so4468995oag.34
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 12:28:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

The removal of the routing cache in 3.6 had impacted the latency of our
UDP multicast workload.  This patch series brings down the latency to
what we were seeing with 3.4.

Patch 1 "udp: Only allow busy read/poll on connected sockets" is mostly
done for correctness and because it allows unifying the unicast and
multicast paths when a socket is found in early demux.  It can also
improve latency for a connected multicast socket if busy read/poll is
used.

Patches 2&3 remove the fib lookups and restore latency for our workload
to the pre 3.6 levels.

Benchmark results from a netperf UDP_RR test:
v3.12-rc3-447-g40dc9ab kernel   87961.22 transactions/s
v3.12-rc3-447-g40dc9ab + series 90587.62 transactions/s

Benchmark results from a fio 1 byte UDP multicast pingpong test
(Multicast one way unicast response):
v3.12-rc3-447-g40dc9ab kernel   12.97us RTT
v3.12-rc3-447-g40dc9ab + series 12.48us RTT

v2 Changes:

* Unicast UDP early demux now requires an exact socket match and only
tests first socket in UDP hash chain.
* ipv4_pktinfo_prepare() now takes a const struct sock*

Shawn Bohrer (3):
  udp: Only allow busy read/poll on connected sockets
  udp: Add udp early demux
  net: ipv4 only populate IP_PKTINFO when needed

 include/net/ip.h       |    2 +-
 include/net/sock.h     |    2 +-
 include/net/udp.h      |    1 +
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/ip_sockglue.c |    5 +-
 net/ipv4/raw.c         |    2 +-
 net/ipv4/udp.c         |  195 ++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/udp.c         |    5 +-
 8 files changed, 185 insertions(+), 28 deletions(-)

-- 
1.7.7.6
