From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 00/13] net: Various VRF patches
Date: Wed,  4 May 2016 20:33:17 -0700
Message-ID: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36786 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbcEEDeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:07 -0400
Received: by mail-pa0-f46.google.com with SMTP id bt5so30788087pac.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various fixes and features for VRF over the past few months.

Patch 1 creates the FIB tables when VRF device is created.

Patch 2 is a prep for 3 which allow sends via cmsg/IP-PKTINFO on interfaces
enslaved to a VRF device.

Patch 4 fixes missing TCP reset / ECONNREFUSED packets in response to
packets to unused ports.

Patch 5 moves the packet hook to L3. It simplifies the overhead of VRFs,
removing a lot of packet path code from VRF driver and is the foundation
for the patches after it.

Patch 6 fixes IP{6}_PKTINFO to returned the index of the enslaved
interface rather than the VRF device. A required feature for proper
VRF support.

Patches 7 and 8 provide support for locally originated traffic to local
addresses.

Patch 9 accommdates a change to the IP6 route lookups - passing flags
to l3mdev/vrf route lookups.

Patch 10 provides support for IPv6 multicast and link local addresses.

Patch 11 protects access to the cached vrf dst entries which can be
deleted on 1 cpu while processing packets on another cpu.

Patches 12 and 13 fix up IPv6 source address selections.

David Ahern (13):
  net: vrf: Create FIB tables on link create
  net: l3mdev: Move get_saddr and rt6_dst
  net: l3mdev: Allow send on enslaved interface
  net: ipv6: tcp reset, icmp need to consider L3 domain
  net: l3mdev: Add hook in ip and ipv6
  net: original ingress device index in PKTINFO
  net: vrf: ipv4 support for local traffic to local addresses
  net: vrf: ipv6 support for local traffic to local addresses
  net: l3mdev: Propagate route lookup flags for IPv6
  net: vrf: Handle ipv6 multicast and link-local addresses
  net: vrf: rcu protect changes to private data
  net: vrf: Implement get_saddr for IPv6
  net: ipv6: address selection should only consider devices in L3 domain

 drivers/net/vrf.c         | 632 ++++++++++++++++++++++++++++++++++------------
 include/linux/ipv6.h      |   2 +-
 include/linux/netdevice.h |   2 +
 include/net/ip.h          |   1 +
 include/net/ip6_route.h   |  24 +-
 include/net/l3mdev.h      |  85 ++++---
 include/net/tcp.h         |   2 +-
 net/core/dev.c            |   3 +-
 net/ipv4/fib_frontend.c   |   1 +
 net/ipv4/ip_input.c       |   8 +
 net/ipv4/ip_sockglue.c    |   9 +-
 net/ipv4/route.c          |   4 +
 net/ipv6/addrconf.c       |   9 +-
 net/ipv6/icmp.c           |   7 +-
 net/ipv6/ip6_fib.c        |   1 +
 net/ipv6/ip6_input.c      |   8 +
 net/ipv6/ip6_output.c     |  12 +-
 net/ipv6/route.c          |  24 +-
 net/ipv6/tcp_ipv6.c       |   7 +-
 net/l3mdev/l3mdev.c       |  92 +++++++
 20 files changed, 701 insertions(+), 232 deletions(-)

-- 
2.1.4
