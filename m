From: Fan Du <fan.du@intel.com>
Subject: [PATCHv5 net-next 0/4] Improvements for TCP PMTU
Date: Fri,  6 Mar 2015 11:18:21 +0800
Message-ID: <1425611905-28503-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38531 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbbCFDXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 22:23:18 -0500
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
	  mss for next probing.
Patch3/4: Create a probe timer to detect enlarged path MTU.
Patch4/4: Update ip-sysctl.txt for new sysctl knobs.

Changelog:
v5:
  - Zero probe_size before resetting search range.
  - Update ip-sysctl.txt for new sysctl knobs.
v4:
  - Convert probe_size to mss, not directly from search_low/high
  - Clamp probe_threshold
  - Don't adjust search_high in blackhole probe, so drop orignal patch3
v3:
  - Update commit message for patch2
  - Fix pseudo timer delta calculation in patch4
v2:
  - Introduce sysctl_tcp_probe_threshold to control when
    probing will stop, as suggested by John Heffner.
  - Add patch3 to shrink current mss value for search low boundary.
  - Drop cannonical timer usages, implements pseudo timer based on
    32bits jiffies tcp_time_stamp, as suggested by Eric Dumazet.


Fan Du (4):
  ipv4: Raise tcp PMTU probe mss base size
  ipv4: Use binary search to choose tcp PMTU probe_size
  ipv4: Create probe timer for tcp PMTU as per RFC4821
  ipv4: Documenting two sysctls for tcp PMTU probe

 Documentation/networking/ip-sysctl.txt |   10 ++++++
 include/net/inet_connection_sock.h     |    2 +
 include/net/netns/ipv4.h               |    2 +
 include/net/tcp.h                      |    8 ++++-
 net/ipv4/sysctl_net_ipv4.c             |   14 +++++++++
 net/ipv4/tcp_ipv4.c                    |    2 +
 net/ipv4/tcp_output.c                  |   50 +++++++++++++++++++++++++++++--
 net/ipv4/tcp_timer.c                   |    1 +
 8 files changed, 84 insertions(+), 5 deletions(-)
