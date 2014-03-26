From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 0/6] introduce infrastructure for support of switch chip datapath
Date: Wed, 26 Mar 2014 17:31:06 +0100
Message-ID: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:52359 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755236AbaCZQbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:31:19 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so1881548eei.0
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:31:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is second version of RFC. Here are the main differences from the first one:
-There is no special swdev of swport structure. The switch and its ports are
 now represented only by net_device structures. There are couple of switch-specific
 ndos added (inserting and removing flows).

-Regarding the flows, driver marks skb with "missing flow" flag now. That would
 give indication to a user (OVS datapath of af_packet userspace application).
 On the opposite direction, skb can be xmitted by a port.

-dummyswitch module has now rtnetlink iface for easy creation of dummy switches
 and ports.

The basic idea is to introduce a generic infractructure to support various
switch chips in kernel. Also the idea is to benefit of currently existing
Open vSwitch userspace infrastructure.


The first two patches are just minor skb flag and packet_type modifications.


The third patch does a split of structures which are not specific to OVS
into more generic ones that can be reused.


The fourth patch introduces the "switchdev" API itself. It should serve as
a glue between chip drivers on the one side and the user on the other.
That user might be OVS datapath but in future it might be just userspace
application interacting via af_packet and Netlink iface.

The infrastructure is designed to be similar to for example linux bridge.
There is one netdevice representing a switch chip and one netdevice per every
port. These are bound together in classic slave-master way. The reason
to reuse the netdevices for port representation is that userspace can use
standard tools to get information about the ports, statistics, tcpdump, etc.

Note that the netdevices are just representations of the ports in the switch.
Therefore **no actual data** goes though, only missed flow skbs and, if drivers
supports it, when ETH_P_ALL packet_type is hooked on (tcpdump).


The fifth patch introduces a support for switchdev vports into OVS datapath.
After that, userspace would be able to create a switchdev DP for a switch chip,
to add switchdev ports to it and to use it in the same way as it would be
OVS SW datapath.


The sixth patch adds a dummy switch module. It is just an example of
switchdev driver implementation.


Jiri Pirko (6):
  net: make packet_type->ak_packet_priv generic
  skbuff: add "missed_flow" flag
  openvswitch: split flow structures into ovs specific and generic ones
  net: introduce switchdev API
  openvswitch: Introduce support for switchdev based datapath
  net: introduce dummy switch

 drivers/net/Kconfig                        |   7 +
 drivers/net/Makefile                       |   1 +
 drivers/net/dummyswitch.c                  | 235 +++++++++++++++++++++++++++++
 include/linux/filter.h                     |   1 +
 include/linux/netdevice.h                  |  26 +++-
 include/linux/skbuff.h                     |  13 ++
 include/linux/sw_flow.h                    | 105 +++++++++++++
 include/linux/switchdev.h                  |  30 ++++
 include/uapi/linux/if_link.h               |   9 ++
 include/uapi/linux/openvswitch.h           |   4 +
 net/Kconfig                                |  10 ++
 net/core/Makefile                          |   1 +
 net/core/dev.c                             |   4 +-
 net/core/filter.c                          |   3 +
 net/core/switchdev.c                       | 172 +++++++++++++++++++++
 net/openvswitch/Makefile                   |   4 +
 net/openvswitch/datapath.c                 |  90 +++++++----
 net/openvswitch/datapath.h                 |  12 +-
 net/openvswitch/dp_notify.c                |   3 +-
 net/openvswitch/flow.c                     |  14 +-
 net/openvswitch/flow.h                     | 123 +++------------
 net/openvswitch/flow_netlink.c             |  24 +--
 net/openvswitch/flow_netlink.h             |   4 +-
 net/openvswitch/flow_table.c               | 100 ++++++------
 net/openvswitch/flow_table.h               |  18 +--
 net/openvswitch/vport-gre.c                |   4 +-
 net/openvswitch/vport-internal_switchdev.c | 179 ++++++++++++++++++++++
 net/openvswitch/vport-internal_switchdev.h |  28 ++++
 net/openvswitch/vport-netdev.c             |   4 +-
 net/openvswitch/vport-switchportdev.c      | 205 +++++++++++++++++++++++++
 net/openvswitch/vport-switchportdev.h      |  24 +++
 net/openvswitch/vport-vxlan.c              |   2 +-
 net/openvswitch/vport.c                    |   6 +-
 net/openvswitch/vport.h                    |   4 +-
 net/packet/af_packet.c                     |  22 ++-
 35 files changed, 1269 insertions(+), 222 deletions(-)
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 include/linux/sw_flow.h
 create mode 100644 include/linux/switchdev.h
 create mode 100644 net/core/switchdev.c
 create mode 100644 net/openvswitch/vport-internal_switchdev.c
 create mode 100644 net/openvswitch/vport-internal_switchdev.h
 create mode 100644 net/openvswitch/vport-switchportdev.c
 create mode 100644 net/openvswitch/vport-switchportdev.h

-- 
1.8.5.3
