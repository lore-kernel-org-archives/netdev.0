From: Fan Du <fan.du@intel.com>
Subject: [PATCHv3 net-next 0/4] Improvements for TCP PMTU
Date: Sat, 28 Feb 2015 11:23:01 +0800
Message-ID: <1425093785-27380-1-git-send-email-fan.du@intel.com>
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31145 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542AbbB1D1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 22:27:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset performs some improvements and enhancement
for current TCP PMTU as per RFC4821 with the aim to find
optimal mms size quickly, and also be adaptive to route
changes like enlarged path MTU. Then TCP PMTU could be
used to probe a effective pmtu in absence of ICMP message
for tunnels(e.g. vxlan) across different networking stack.

Patch1/4: Set probe mss base to 1024 Bytes per RFC4821
Patch2/4: Do not double probe_size for each probing,
          use a simple binary search to gain maximum performance.
Patch3/4: When it comes to blackhole detection, shrink current
	  mss for next probing.
Patch4/4: Create a probe timer to detect enlarged path MTU.

Changelog:
v3:
   - Update commit message for patch2
   - Fix pseudo timer delta caculation in patch4
v2:
   - Introduce sysctl_tcp_probe_threshold to control when
     probing will stop, as suggested by John Heffner.
   - Add patch3 to shrink current mss value for search low boundary.
   - Drop cannonical timer usages, implements pseudo timer based on
     32bits jiffies tcp_time_stamp, as suggested by Eric Dumazet.

Fan Du (4):
  ipv4: Raise tcp PMTU probe mss base size
  ipv4: Use binary search to choose tcp PMTU probe_size
  ipv4: shrink current mss for tcp PMTU blackhole detection
  ipv4: Create probe timer for tcp PMTU as per RFC4821

 include/net/inet_connection_sock.h |    2 +
 include/net/netns/ipv4.h           |    2 +
 include/net/tcp.h                  |    8 +++++-
 net/ipv4/sysctl_net_ipv4.c         |   14 +++++++++++
 net/ipv4/tcp_ipv4.c                |    2 +
 net/ipv4/tcp_output.c              |   46 ++++++++++++++++++++++++++++++++---
 net/ipv4/tcp_timer.c               |    9 ++++--
 7 files changed, 75 insertions(+), 8 deletions(-)
