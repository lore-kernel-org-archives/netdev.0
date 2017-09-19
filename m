From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 00/14] gtp: Additional feature support
Date: Mon, 18 Sep 2017 17:38:50 -0700
Message-ID: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:50442 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdISAjX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:23 -0400
Received: by mail-pf0-f177.google.com with SMTP id m63so1102589pfk.7
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set builds upon the initial GTP implementation to make
support closer to that enjoyed by other encapsulation protocols.

The major items are:

  - IPv6 support
  - Configurable networking interfaces so that GTP kernel can be
    used and tested without needing GSN network emulation (i.e. no user
    space daemon needed).
  - GSO,GRO
  - Control of zero UDP checksums
  - Port numbers are configurable
  - Addition of a dst_cache in the GTP structure and other cleanup

Additionally, this patch set also includes a couple of general support
capabilities:

  - A facility that allows application specific GSO callbacks
  - Common functions to get a route fo for an IP tunnel

For IPv6 support, the mobile subscriber needs to allow IPv6 addresses,
and the remote enpoint can be IPv6.

For configurable interfaces, configuration is added to allow an
alterate means to configure a GTP and device. This follows the
typical UDP encapsulation model of specifying a listener port for
receive, and a remote address and port for transmit. 

GRO was straightfoward to implement following the model of other
UDP encapsulations.

Providing GSO support had one wrinkle-- the GTP header includes a
payload length field that needs to be set per GSO segment. In order
to address that in a general way, I create the concept of
application specific GSO.

To implement application layer GSO I reserved the top four bits of
shinfo(skb)->gso_type. The idea is that an application or encapsulation
protocol (like GTP in this case) can register a GSO segment callback.
The facility returns a gso_type with upper four bits set to a value
(index into a table). When the application sets up a packet it includes
the code in the gso_type for the skb. At some point (e.g. from UDP
segment) the gso_type is checked in the skb and if the application
specific GSO is indicated then the callback is called. The
registered callbacks include a set of other gso_types so that
an application callback can be matched to an appropriate instance.
FOr instance, the GTP callback checks for the UDP GSO flags.

Zero UDP checksum, port number configuration, and dst_cache are
straightforwad.

Configuration is performed by iproute2/ip. I will post that
in a subsequent patch set.

Tested:

Configured the matrix of IPv4/IPv6 mobile subscriber, IPv4/IPv6 remote
peer, and GTP version 0 and 1 (eight combinations). Observed
connectivity and proper GSO/GRO. Also, tested VXLAN for
regression.

Tom Herbert (14):
  iptunnel: Add common functions to get a tunnel route
  vxlan: Call common functions to get tunnel routes
  gtp: Call common functions to get tunnel routes and add dst_cache
  gtp: udp recv clean up
  gtp: Remove special mtu handling
  gtp: Eliminate pktinfo and add port configuration
  gtp: Support encapsulation of IPv6 packets
  gtp: Support encpasulating over IPv6
  gtp: Allow configuring GTP interface as standalone
  gtp: Add support for devnet
  net: Add a facility to support application defined GSO
  gtp: Configuration for zero UDP checksum
  gtp: Support for GRO
  gtp: GSO support

 drivers/net/gtp.c            | 1300 ++++++++++++++++++++++++++++++++----------
 drivers/net/vxlan.c          |   84 +--
 include/linux/netdevice.h    |   31 +
 include/linux/skbuff.h       |   25 +
 include/net/ip6_tunnel.h     |   33 ++
 include/net/ip_tunnels.h     |   33 ++
 include/uapi/linux/gtp.h     |    8 +
 include/uapi/linux/if_link.h |    6 +
 net/core/dev.c               |   47 ++
 net/ipv4/ip_tunnel.c         |   41 ++
 net/ipv4/ip_tunnel_core.c    |    6 +
 net/ipv4/udp_offload.c       |   20 +-
 net/ipv6/ip6_tunnel.c        |   43 ++
 13 files changed, 1306 insertions(+), 371 deletions(-)

-- 
2.11.0
