From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 00/13] Always build GSO/GRO functionality into the kernel
Date: Tue, 13 Nov 2012 20:24:01 -0500
Message-ID: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932315Ab2KNBYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a revision suggested by Eric to solve the problem where
a host without IPv6 support drops GSO frames from the guest.

The problem is that GSO/GRO support is per protocol, and when said protocol
is not loaded or is disabled, packets attempting to go through GSO/GRO code paths
are dropped.  This causes retransmissions and a two orders of magnitude drop in
performance.

Prior attempt to solve the problem simply enabled enough GSO/GRO functionality
for IPv6 protocol when IPv6 was diabled.  This did not solve the problem when
the protocol was not build in or was blacklisted.
To solve the problem, it was suggested that we separate GSO/GRO callback
registration from packet processing registrations.  That way
GSO/GRO callbacks can be built into the kernel and always be there.
This patch series attempts to do just that.
* Patches 1 and 2 split the GSO/GRO handlers from packet_type and convert
  to the new structure.
* Patches 3, 4 and 5 do the same thing for net_protocol structure.
* The rest of the patches try to incrementally move the IPv6 GSO/GRO
  code out of the module and into the static kernel build.  Some IPv6
  helper functions also had to move as well.

I am currently testing the patches, but if folks could look this over
and send me any comments, I'd appreciate it.

Thanks
-vlad

Vlad Yasevich (13):
  net:  Add generic packet offload infrastructure.
  net:  Switch to using the new packet offload infrustructure
  net: Add net protocol offload registration infrustructure
  ipv6: Add new offload registration infrastructure.
  ipv4: Switch to using the new offload infrastructure.
  ipv6: Switch to using new offload infrastructure.
  ipv6: Separate ipv6 offload support
  ipv6: Separate tcp offload functionality
  ipv6: Separate out UDP offload functionality
  ipv6: Move exthdr offload support into separate file
  ipv6: Update ipv6 static library with newly needed functions
  ipv4: Pull GSO registration out of inet_init()
  ipv6: Pull IPv6 GSO registration out of the module

 include/linux/netdevice.h  |   15 ++-
 include/net/ip6_checksum.h |   33 +++++
 include/net/protocol.h     |   35 +++---
 net/core/dev.c             |   93 ++++++++++++++-
 net/ipv4/af_inet.c         |   53 ++++++---
 net/ipv4/protocol.c        |   22 ++++-
 net/ipv6/Makefile          |    7 +-
 net/ipv6/af_inet6.c        |  240 -------------------------------------
 net/ipv6/exthdrs.c         |    8 +-
 net/ipv6/exthdrs_offload.c |   41 +++++++
 net/ipv6/ip6_offload.c     |  280 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_offload.h     |   18 +++
 net/ipv6/ip6_output.c      |   65 ----------
 net/ipv6/output_core.c     |   76 ++++++++++++
 net/ipv6/protocol.c        |   21 ++++
 net/ipv6/tcp_ipv6.c        |  107 +-----------------
 net/ipv6/tcpv6_offload.c   |   93 +++++++++++++++
 net/ipv6/udp.c             |   94 ---------------
 net/ipv6/udp_offload.c     |  117 ++++++++++++++++++
 19 files changed, 867 insertions(+), 551 deletions(-)
 create mode 100644 net/ipv6/exthdrs_offload.c
 create mode 100644 net/ipv6/ip6_offload.c
 create mode 100644 net/ipv6/ip6_offload.h
 create mode 100644 net/ipv6/output_core.c
 create mode 100644 net/ipv6/tcpv6_offload.c
 create mode 100644 net/ipv6/udp_offload.c

-- 
1.7.7.6
