From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/7] net: unify dst caching for tunnel devices
Date: Thu, 11 Feb 2016 11:11:56 +0100
Message-ID: <cover.1455184959.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725AbcBKKNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 05:13:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series try to unify the dst cache implementations currently
present in the kernel, namely in ip_tunnel.c and ip6_tunnel.c, introducing a
new generic implementation, replacing the existing ones, and then using
the new implementation in other tunnel devices which currently lack it.

The new dst implementation is compiled, as built-in, only if any device using
it is enabled.

Caching the dst for the tunnel remote address gives small, but measurable,
performance improvement when tunneling over ipv4 (in the 2%-4% range) and
significant ones when tunneling over ipv6 (roughly 60% when no
fragmentation/segmentation take place and the tunnel local address
is not specified).

Paolo Abeni (7):
  net: add dst_cache support
  net: replace dst_cache ip6_tunnel implementation with the generic one
  ip_tunnel: replace dst_cache with generic implementation
  net: use dst_cache for vxlan device
  net: add dst_cache to ovs vxlan lwtunnel
  geneve: add dst caching support
  net/ipv4: add dst cache support for gre lwtunnels

 drivers/net/geneve.c           |  39 +++++++++++
 drivers/net/vxlan.c            |  85 ++++++++++++++++++------
 include/net/dst_cache.h        |  97 +++++++++++++++++++++++++++
 include/net/ip6_tunnel.h       |  14 +---
 include/net/ip_tunnels.h       |  10 +--
 include/net/vxlan.h            |   1 +
 net/Kconfig                    |   4 ++
 net/core/Makefile              |   1 +
 net/core/dst_cache.c           | 147 +++++++++++++++++++++++++++++++++++++++++
 net/ipv4/Kconfig               |   1 +
 net/ipv4/ip_gre.c              |  17 ++++-
 net/ipv4/ip_tunnel.c           |  78 ++++------------------
 net/ipv6/Kconfig               |   1 +
 net/ipv6/ip6_gre.c             |  12 ++--
 net/ipv6/ip6_tunnel.c          | 103 ++---------------------------
 net/ipv6/ip6_vti.c             |   2 +-
 net/ipv6/sit.c                 |  17 ++---
 net/openvswitch/Kconfig        |   1 +
 net/openvswitch/flow.h         |   1 +
 net/openvswitch/flow_netlink.c |  11 +++
 20 files changed, 423 insertions(+), 219 deletions(-)
 create mode 100644 include/net/dst_cache.h
 create mode 100644 net/core/dst_cache.c

-- 
1.8.3.1
