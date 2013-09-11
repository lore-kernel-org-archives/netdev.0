From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 0/4] Series short description
Date: Wed, 11 Sep 2013 11:45:51 -0700
Message-ID: <20130911184441.26914.10336.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:46747 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023Ab3IKSqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:46:14 -0400
Received: by mail-oa0-f53.google.com with SMTP id k18so9928448oag.12
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:46:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements virtual station interfaces or VSIs. The
VSI term comes from the IEEE std 802.1Qbg-2012 specification which
should be merged with 802.1Q proper at some point.

	3.18 Virtual Station Interface (VSI): An interface to a
	     virtual station that is attached to a DRP of an edge
	     edge relay.

A DRP (downlink relay port) is the link between an edge relay and
a VSI. An edge relay is basically a simple bridge that does not
need to support learning, flooding, xSTP, etc. Which matches up well
with the ixgbe and I believe other hardware embedded bridge (ebridge)
implementations.

This series adds a new VSI rtnl link type. I chose to do this via
a link type because it allows us to reuse a lot of the existing
infrastructure to bring up a net device and it lets a VSI look
similar to a macvlan. The macvlan link type being the software
equivalent of a VSI. In many cases I can simply replace the
macvlan type with vsi from the ip command line tool and my existing
scripts work but use the ebridge instead of SW.

The usage model looks like this,

# ip link add link p3p2 numtxqueues 2 numrxqueues 2 type vsi
# ip link add link p3p2 numtxqueues 2 numrxqueues 2 type vsi
# ip link add link p3p2 numtxqueues 4 numrxqueues 4 type vsi
# ip link set dev vsi0 addr 00:1b:21:69:9f:15
# ip link set dev vsi1 addr 00:1b:21:69:9f:16
# ip link set dev vsi2 addr 00:1b:21:69:9f:17
# ip link set dev vsi0 up
# ip link set dev vsi1 up
# ip link set dev vsi2 up
# ip link show
16: p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:69:9f:09 brd ff:ff:ff:ff:ff:ff
17: vsi0@p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:69:9f:15 brd ff:ff:ff:ff:ff:ff
18: vsi1@p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:69:9f:16 brd ff:ff:ff:ff:ff:ff
19: vsi2@p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:69:9f:17 brd ff:ff:ff:ff:ff:ff

And creates this topology,

      vsi0      vsi1       vsi2
       |         |          |
     +------------------------+
     |                        |
     |        ebridge         |
     |                        |
     +------------------------+
                 |
               p3p2

At this point each vsi# will receive their assigned MAC addresses.
Using the 'fdb' interfaces additional L2/L3/tunnel entries could be
added to the vsi#. And VSIs can be assigned to net name spaces.

The topology of the ebridge is tracked via the upper and lower dev
lists. After we get Veaceslav Falico's work to expose this via sysfs
then the topology will be visible. Although it can be learned also
via iflink:ifindex to some extent.

PATCH DESCRIPTION:

The first extend rtnl link ops priv_size routine so VSI link types
can set the private space for the netdev being created. This is
required because device drivers will use this space.

The second patch adds some helper routines to traverse the lower dev
list.

The third patch is the interface work to support VSI devices.

And the last patch is an implementation for ixgbe. Notice there are
still a few items I need to clean up on this patch before submitting
but it is working, without DCB/FCoE, now. And I think I can simplify
it some to bring down the line count.

My plan would be to submit this as a real patch after net-next opens
but I wanted to see if there was any initial feedback especially
related to the VSI link type.

phew... sorry that was a bit long winded.

---

John Fastabend (4):
      net: rtnetlink: make priv_size a function for devs with dynamic size
      net: Add lower dev list helpers
      net: VSI: Add virtual station interface support
      ixgbe: Adding VSI support to ixgbe


 drivers/infiniband/ulp/ipoib/ipoib_netlink.c     |    4 
 drivers/net/Kconfig                              |    9 
 drivers/net/Makefile                             |    1 
 drivers/net/bonding/bond_main.c                  |    4 
 drivers/net/caif/caif_hsi.c                      |    4 
 drivers/net/ethernet/intel/ixgbe/Makefile        |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   32 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    4 
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   15 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  307 +++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c     |  428 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h     |   71 ++++
 drivers/net/ifb.c                                |    4 
 drivers/net/macvlan.c                            |    4 
 drivers/net/nlmon.c                              |    4 
 drivers/net/team/team.c                          |    4 
 drivers/net/tun.c                                |    4 
 drivers/net/veth.c                               |    4 
 drivers/net/vsi.c                                |  124 ++++++
 drivers/net/vxlan.c                              |    4 
 include/linux/netdevice.h                        |   35 ++
 include/net/rtnetlink.h                          |   11 +
 include/uapi/linux/if.h                          |    1 
 net/8021q/vlan_netlink.c                         |    4 
 net/bridge/br_netlink.c                          |    4 
 net/core/dev.c                                   |   25 +
 net/core/rtnetlink.c                             |    2 
 net/ieee802154/6lowpan.c                         |    4 
 net/ipv4/ip_gre.c                                |    6 
 net/ipv4/ip_tunnel.c                             |    2 
 net/ipv4/ip_vti.c                                |    4 
 net/ipv4/ipip.c                                  |    4 
 net/ipv6/ip6_tunnel.c                            |    4 
 net/ipv6/sit.c                                   |    4 
 34 files changed, 1028 insertions(+), 116 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h
 create mode 100644 drivers/net/vsi.c

-- 
Signature
