From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/6 net-next] VXLAN Group Policy Extension
Date: Wed,  7 Jan 2015 03:05:35 +0100
Message-ID: <cover.1420594925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42655 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbbAGCFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:05:48 -0500
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
  vxlan: Fail build if VXLAN header is misdefined
  openvswitch: Rename GENEVE_TUN_OPTS() to TUN_METADATA_OPTS()
  openvswitch: Support VXLAN Group Policy extension

 drivers/net/vxlan.c              | 221 +++++++++++++++++++++++++++------------
 include/net/vxlan.h              | 104 ++++++++++++++++--
 include/uapi/linux/if_link.h     |   8 ++
 include/uapi/linux/openvswitch.h |  19 ++++
 net/openvswitch/flow.c           |   2 +-
 net/openvswitch/flow.h           |  14 +--
 net/openvswitch/flow_netlink.c   | 111 ++++++++++++--------
 net/openvswitch/vport-vxlan.c    |  89 +++++++++++++++-
 8 files changed, 435 insertions(+), 133 deletions(-)

-- 
1.9.3
