From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/6 net-next v3] VXLAN Group Policy Extension
Date: Mon, 12 Jan 2015 13:26:16 +0100
Message-ID: <cover.1421064100.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44559 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbbALM02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 07:26:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements supports for the Group Policy VXLAN extension [0] to provide
a lightweight and simple security label mechanism across network peers
based on VXLAN. The security context and associated metadata is mapped
to/from skb->mark. This allows further mapping to a SELinux context
using SECMARK, to implement ACLs directly with nftables, iptables, OVS,
tc, etc.

The extension is disabled by default and should be run on a distinct
port in mixed Linux VXLAN VTEP environments. Liberal VXLAN VTEPs
which ignore unknown reserved bits will be able to receive VXLAN-GBP
frames.

Simple usage example:

10.1.1.1:
   # ip link add vxlan0 type vxlan id 10 remote 10.1.1.2 gbp
   # iptables -I OUTPUT -m owner --uid-owner 101 -j MARK --set-mark 0x200

10.1.1.2:
   # ip link add vxlan0 type vxlan id 10 remote 10.1.1.1 gbp
   # iptables -I INPUT -m mark --mark 0x200 -j DROP

iproute2 [1] and OVS [2] support will be provided in separate patches.

[0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
[1] https://github.com/tgraf/iproute2/tree/vxlan-gbp
[2] https://github.com/tgraf/ovs/tree/vxlan-gbp

Thomas Graf (6):
  vxlan: Allow for VXLAN extensions to be implemented
  vxlan: Group Policy extension
  vxlan: Only bind to sockets with correct extensions enabled
  openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
  openvswitch: Allow for any level of nesting in flow attributes
  openvswitch: Support VXLAN Group Policy extension

 drivers/net/vxlan.c              | 225 ++++++++++++++++++++----------
 include/net/ip_tunnels.h         |   5 +-
 include/net/vxlan.h              |  98 +++++++++++++-
 include/uapi/linux/if_link.h     |   8 ++
 include/uapi/linux/openvswitch.h |  11 ++
 net/openvswitch/flow.c           |   2 +-
 net/openvswitch/flow.h           |  14 +-
 net/openvswitch/flow_netlink.c   | 286 ++++++++++++++++++++++++++-------------
 net/openvswitch/vport-geneve.c   |   2 +-
 net/openvswitch/vport-vxlan.c    |  90 +++++++++++-
 net/openvswitch/vport-vxlan.h    |  11 ++
 11 files changed, 569 insertions(+), 183 deletions(-)
 create mode 100644 net/openvswitch/vport-vxlan.h

-- 
1.9.3
