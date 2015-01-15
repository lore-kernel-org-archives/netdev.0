From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5 net-next v6] VXLAN Group Policy Extension
Date: Thu, 15 Jan 2015 03:53:54 +0100
Message-ID: <cover.1421290198.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35194 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbbAOCyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:54:04 -0500
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

Thomas Graf (5):
  vxlan: Group Policy extension
  vxlan: Only bind to sockets with compatible flags enabled
  openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
  openvswitch: Allow for any level of nesting in flow attributes
  openvswitch: Support VXLAN Group Policy extension

 drivers/net/vxlan.c              | 113 ++++++++++++----
 include/net/ip_tunnels.h         |   5 +-
 include/net/vxlan.h              |  82 ++++++++++-
 include/uapi/linux/if_link.h     |   1 +
 include/uapi/linux/openvswitch.h |  11 ++
 net/openvswitch/flow.c           |   2 +-
 net/openvswitch/flow.h           |  14 +-
 net/openvswitch/flow_netlink.c   | 286 ++++++++++++++++++++++++++-------------
 net/openvswitch/vport-geneve.c   |  15 +-
 net/openvswitch/vport-vxlan.c    |  91 ++++++++++++-
 net/openvswitch/vport-vxlan.h    |  11 ++
 11 files changed, 491 insertions(+), 140 deletions(-)
 create mode 100644 net/openvswitch/vport-vxlan.h

-- 
1.9.3
