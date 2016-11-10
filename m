From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 0/8] openvswitch: support for layer 3 encapsulated packets
Date: Thu, 10 Nov 2016 16:28:16 +0100
Message-ID: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933482AbcKJP2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the core of this patch set is removing the assumption in Open vSwitch
datapath that all packets have Ethernet header.

The implementation relies on the presence of pop_eth and push_eth actions
in datapath flows to facilitate adding and removing Ethernet headers as
appropriate. The construction of such flows is left up to user-space.

This series is based on work by Simon Horman, Lorand Jakab, Thomas Morin and
others. I kept Lorand's and Simon's s-o-b in the patches that are derived
from v11 to record their authorship of parts of the code.

Changes from v12 to v13:

* Addressed Pravin's feedback.
* Removed the GRE vport conversion patch; L3 GRE ports should be created by
  rtnetlink instead.

Main changes from v11 to v12:

* The patches were restructured and split differently for easier review.
* They were rebased and adjusted to the current net-next. Especially MPLS
  handling is different (and easier) thanks to the recent MPLS GSO rework.
* Several bugs were discovered and fixed. The most notable is fragment
  handling: header adjustment for ARPHRD_NONE devices on tx needs to be done
  after refragmentation, not before it. This required significant changes in
  the patchset. Another one is stricter checking of attributes (match on L2
  vs. L3 packet) at the kernel level.
* Instead of is_layer3 bool, a mac_proto field is used.

Jiri Benc (8):
  openvswitch: use hard_header_len instead of hardcoded ETH_HLEN
  openvswitch: add mac_proto field to the flow key
  openvswitch: pass mac_proto to ovs_vport_send
  openvswitch: support MPLS push and pop for L3 packets
  openvswitch: add processing of L3 packets
  openvswitch: netlink: support L3 packets
  openvswitch: add Ethernet push and pop actions
  openvswitch: allow L3 netdev ports

 include/uapi/linux/openvswitch.h |  15 ++++
 net/openvswitch/actions.c        | 111 +++++++++++++++++-------
 net/openvswitch/datapath.c       |  13 +--
 net/openvswitch/flow.c           | 105 +++++++++++++++++------
 net/openvswitch/flow.h           |  22 +++++
 net/openvswitch/flow_netlink.c   | 179 ++++++++++++++++++++++++++-------------
 net/openvswitch/vport-netdev.c   |   9 +-
 net/openvswitch/vport.c          |  31 +++++--
 net/openvswitch/vport.h          |   2 +-
 9 files changed, 353 insertions(+), 134 deletions(-)

-- 
1.8.3.1
