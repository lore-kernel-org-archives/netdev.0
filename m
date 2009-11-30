From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/20] Batch network namespace cleanup
Date: Sun, 29 Nov 2009 17:46:03 -0800
Message-ID: <m1ljhodbtw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42708 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbZK3BqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Recently Jamal and Daniel perform some experiments and found that
large numbers of network namespace exiting simultaneously is very
inefficient.  24+ minutes in some configurations.  The cpu overhead
was negligible but it results in long hold times of net_mutex, and
memory being consumed a long time after the last user has gone away.

I looked into it and discovered that by batching network namespace
cleanups I can reduce the time for 4k network namespaces exiting from
5-7 minutes in my configuration to 44 seconds.

This patch series is my set of changes to the network namespace core
and associated cleanups to allow for network namespace batching.

Eric


 drivers/net/bonding/bond_main.c         |   32 +---
 drivers/net/loopback.c                  |    8 -
 drivers/net/ppp_generic.c               |   30 +---
 drivers/net/pppoe.c                     |   38 +----
 drivers/net/pppol2tp.c                  |   36 +----
 include/linux/netdevice.h               |    2 +
 include/linux/notifier.h                |    2 +-
 include/net/net_namespace.h             |    8 +-
 include/net/netns/generic.h             |    8 +-
 include/net/route.h                     |    1 +
 net/8021q/vlan.c                        |   33 +---
 net/core/dev.c                          |   52 ++-----
 net/core/net_namespace.c                |  254 +++++++++++++++++++------------
 net/ipv4/fib_frontend.c                 |    4 +-
 net/ipv4/ip_gre.c                       |   24 +---
 net/ipv4/ipip.c                         |   24 +---
 net/ipv4/route.c                        |    6 +
 net/ipv6/ip6_tunnel.c                   |   25 +---
 net/ipv6/sit.c                          |   25 +---
 net/key/af_key.c                        |   25 +---
 net/netfilter/nf_conntrack_proto_dccp.c |   31 +---
 net/netfilter/nf_conntrack_proto_gre.c  |   20 +--
 net/phonet/pn_dev.c                     |   16 +--
 23 files changed, 284 insertions(+), 420 deletions(-)

Eric W. Biederman (20):
      net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
      net: Implement for_each_netdev_reverse.
      net: Batch network namespace destruction.
      net: Automatically allocate per namespace data.
      net: Simplify loopback and improve batching.
      net: Simplfy default_device_exit and improve batching.
      net: Simplify the bond drivers pernet operations.
      net: Simplify vlan pernet operations.
      net: Simplify af_key pernet operations.
      net: Simplify conntrack_proto_dccp pernet operations.
      net: Simplify conntrack_proto_gre pernet operations.
      net: Simplify ppp_generic pernet operations.
      net: Simplify pppoe pernet operations.
      net: Simplify pppol2tp pernet operations.
      net: Simplify phonet pernet operations.
      net: Simplify ip_gre pernet operations.
      net: Simplify ipip pernet operations.
      net: Simplify ip6_tunnel pernet operations.
      net: Simplify ipip6 aka sit pernet operations.
      net: remove [un]register_pernet_gen_... and update the docs.

