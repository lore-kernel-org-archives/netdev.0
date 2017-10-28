From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v7 net-next 00/13] gtp: Additional feature support - Part I
Date: Fri, 27 Oct 2017 17:09:24 -0700
Message-ID: <20171028000937.2631-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:54498 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdJ1AJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:09:51 -0400
Received: by mail-pf0-f195.google.com with SMTP id n89so5997688pfk.11
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:09:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set builds upon the initial GTP implementation to make
support closer to that enjoyed by other encapsulation protocols.

The major items are:

  - Experimental IPv6 support
  - Configurable networking interfaces so that GTP kernel can be
    used and tested without needing GSN network emulation (i.e. no user
    space daemon needed).
  - Addition of a dst_cache in the GTP structure and other cleanup

Additionally, this patch set also includes:

  - Common functions to get a route fo for an IP tunnel
  - Fix VXLAN gro cells initialization

For IPv6 support, the mobile subscriber needs to allow IPv6 addresses,
and the remote endpoint can be IPv6.

For configurable interfaces, configuration is added to allow an
alternate means to configure a GTP and device. This follows the
typical UDP encapsulation model of specifying a listener port for
receive, and a remote address and port for transmit.

Configuration is performed by iproute2/ip. I will post that
in a subsequent patch set.

Tested:

Configured the matrix of IPv4/IPv6 mobile subscriber, IPv4/IPv6 remote
peer, and GTP version 0 and 1 (eight combinations). Observed
connectivity and functional netperf. Also, tested VXLAN for
regression.

Test using openggs with ggsn and kernel module on one side and
emulated sgsn on the other. Observed connectivity and
functional netperf.

v2:
  - Split the original patch to post in parts in order to make
    review more manageable
  - Make IPv6 support experimental with a configuration option for it
  - Prepend hash functions with gtp
  - Generalize iptunnel update path MTU function and call it from gtp
    instead using custom code
  - Split original patch cleaning up udp_recv into several for easier
    review

v3: Properly include netdev on cc

v4:
  - Move __ip6_tnl_get_route to ipv6/route.c to avoid creting dependency
    on ip6_tunnel
  - Add "select GRO_CELLS" fo Kconfig for GTP

v5:
  - Rebase to current next-net and repost

v6:
  - Move __ip6_tnl_get_route from net/ipv6/route.c to
    net/ipv6/ip6_tunnel.c. This addresses the issue pointed out by
    kbuild that the function is not defined when CONFIG_DST_CACHE is
    not set

v7:
  - Fixed GRO cell initialization in GTP to be in ndo_init and check
    return value. Credit to Subash Abhinov Kasiviswanathan for
    pointing out this issue.
  - Fixed GRO cell initialization in VXLAN to also be in ndo_init and
    check return value

Tom Herbert (13):
  vxlan: Move gro_cells_init to ndo_init
  iptunnel: Add common functions to get a tunnel route
  vxlan: Call common functions to get tunnel routes
  gtp: Call common functions to get tunnel routes and add dst_cache
  iptunnel: Generalize tunnel update pmtu
  gtp: Change to use gro_cells
  gtp: Use goto for exceptions in gtp_udp_encap_recv funcs
  gtp: udp recv clean up
  gtp: Call function to update path mtu
  gtp: Eliminate pktinfo and add port configuration
  gtp: Experimental encapsulation of IPv6 packets
  gtp: Experimental support encpasulating over IPv6
  gtp: Allow configuring GTP interface as standalone

 drivers/net/Kconfig          |   13 +-
 drivers/net/gtp.c            | 1046 ++++++++++++++++++++++++++++++------------
 drivers/net/vxlan.c          |   95 +---
 include/net/ip6_tunnel.h     |   31 ++
 include/net/ip_tunnels.h     |   36 ++
 include/uapi/linux/gtp.h     |    8 +
 include/uapi/linux/if_link.h |    3 +
 net/ipv4/ip_tunnel.c         |   70 ++-
 net/ipv6/ip6_tunnel.c        |   42 ++
 9 files changed, 959 insertions(+), 385 deletions(-)

-- 
2.11.0
