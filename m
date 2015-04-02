From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 0/12] Remove iflink field from the net_device structure
Date: Thu,  2 Apr 2015 17:06:59 +0200
Message-ID: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56588 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbDBPHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:23 -0400
In-Reply-To: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first goal of this series was to advertise the veth peer via the IFLA_LINK
attribute, but iflink was not ready for network namespaces.

The iflink of an interface should be set to its ifindex for a physical interface
and to another value (0 if not relevant) for a virtual interface.
This was not the case for some interfaces, like vxlan, bond, or bridge for
example.
There is also a risk, if the targeted interface moves to another netns, that the
ifindex changes without updating corresponding iflink fields (eg. vlan).

Moving the management of this property into virtual interface drivers allows to
better handle this last case because most of virtual interface drivers have a
pointer to the link netdevice.
Anyway, dev->iflink value was always a copy of some internal data of the virtual
interface driver, thus let's use these internal data directly.

So, this series removes the iflink field and let the drivers manage it.
Only the last patch was present in the v1, but I fully rework it.

 drivers/infiniband/ulp/ipoib/ipoib_main.c |  8 ++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c |  1 -
 drivers/net/ipvlan/ipvlan_core.c          |  2 +-
 drivers/net/ipvlan/ipvlan_main.c          |  9 ++++++++-
 drivers/net/macvlan.c                     |  9 ++++++++-
 drivers/net/veth.c                        | 15 +++++++++++++++
 include/linux/netdevice.h                 |  7 +++++--
 include/net/ip6_tunnel.h                  |  1 +
 include/net/ip_tunnels.h                  |  1 +
 net/8021q/vlan_dev.c                      |  9 ++++++++-
 net/batman-adv/hard-interface.c           |  5 +++--
 net/bridge/br_netlink.c                   |  4 ++--
 net/core/dev.c                            | 32 +++++++++++++++++++++----------
 net/core/link_watch.c                     |  4 ++--
 net/core/net-sysfs.c                      | 10 +++++++++-
 net/core/rtnetlink.c                      |  8 ++++----
 net/dsa/slave.c                           |  8 +++-----
 net/ipv4/ip_gre.c                         |  2 ++
 net/ipv4/ip_tunnel.c                      |  9 ++++++++-
 net/ipv4/ip_vti.c                         |  2 +-
 net/ipv4/ipip.c                           |  2 +-
 net/ipv4/ipmr.c                           |  9 +++++++--
 net/ipv6/addrconf.c                       |  4 ++--
 net/ipv6/ip6_gre.c                        |  8 ++------
 net/ipv6/ip6_tunnel.c                     | 10 ++++++++--
 net/ipv6/ip6_vti.c                        |  3 +--
 net/ipv6/ip6mr.c                          |  9 +++++++--
 net/ipv6/sit.c                            |  3 +--
 28 files changed, 140 insertions(+), 54 deletions(-)

Comments are welcome.

Regards,
Nicolas
