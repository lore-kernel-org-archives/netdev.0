From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 00/13] Add basic VLAN support to bridges
Date: Tue, 29 Jan 2013 14:52:47 -0500
Message-ID: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab3A2TxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:53:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is another revision of the VLAN filtering patchset.  It offers
functionality that is similar to what can be found in switches as
far as VLAN configuration and filtering of frames according to VLAN
tags.

Each port on the bridge, as well as the bridge itself, can be configured
with a set of VLANs that they are willing to accept.  One of the vlans
may be chosen as PVID and any untagged traffic will be associated with it.

Changes since v6:
* VLANs are now stored in a VLAN bitmap per port.  This allows for O(1)
lookup at ingress and egress.  We simply check to see if the bit associated
with the vlan id is set in the map.  The drawback to this approach is that
it wastes some space when there is only a small number of VLANs.
* In addition to the build time configuration option, VLAN filtering also has
a configuration paramter in sysfs.  By default the filtering is turned off
and all traffic is permitted.  When the filtring is turned on, we do strict
matching to the filter configured.  Thus, if there is no configuration, all
packets are rejected.  This was done to make the behavior more streight
forward.  Without this (and if egress policy patch is rejected), the
decision for how to forward untagged traffic that was not filtered at ingress
is almost impossible to make.  It would not be right to deliver to every
port that has PVID set as, each port may have a different PVID.
* Separate egress policy bitmap patch has been isolated and is provided last
in the series.  This has been a more contentious piece of functionality and I
wanted to isolate it so that it could easily be dropped and not block the whole
series.

Changes since v5:
 - Pulled VLAN filtering into its own file and made it a configuration options.
 - Made new vlan filtering option dependent on VLAN_8021Q.
 - Got rid of HW filter inlines and moved then vlan_core.c.
   (All of the above suggested by Stephen Hemminger)

Changes since v4:
 - Pull per-port vlan data into its own structures and give it to the bridge
   device thus making bridge device behave like a regular port for vlan
   configuration.
 - Add a per-vlan 'untagged' bitmap that determins egress policy.  If a port
   is part of this bitmap, traffic egresses untagged.
 - PVID is now used for ingress policy only.  Incomming frames without VLAN tag
   are assigned to the PVID vlan.  Egress is determined via bitmap memberships.
 - Allow for incremental config of a vlan.  Now, PVID and untagged memberships
   may be set on existing vlans.  They however can NOT be cleared separately.
 - VLAN deletion is now done via RTM_DELLINK command for PF_BRIDGE family.
   This cleans up the netlink interface.

Changes since v3:
 - Re-integrated compiler problems that got left out last time.  Appologies.
 - checkpatches.pl errors fixed

Changes since v2:
 - Added inline functiosn to manimulate vlan hw filters and re-use in 8021q
   and bridge code.
 - Use rtnl_dereference (Michael Tsirkin)
 - Remove synchronize_net() call (Eric Dumazet)
 - Fix NULL ptr deref bug I introduced in br_ifinfo_notify.

Changes since v1:
 - Fixed some forwarding bugs.
 - Add vlan to local fdb entries.  New local entries are created per vlan
   to facilite correct forwarding to bridge interface.
 - Allow configuration of vlans directly on the bridge master device
   in addition to ports.

Changes since rfc v2:
 - Per-port vlan bitmap is gone and is replaced with a vlan list.
 - Added bridge vlan list, which is referenced by each port.  Entries in
   the birdge vlan list have port bitmap that shows which port are parts
   of which vlan.
 - Netlink API changes.
 - Dropped sysfs support for now.  If people think this is really usefull,
   can add it back.
 - Support for native/untagged vlans.

Changes since rfc v1:
 - Comments addressed regarding formatting and RCU usage
 - iocts have been removed and changed over the netlink interface.
 - Added support of user added ndb entries.
 - changed sysfs interface to export a bitmap.  Also added a write interface.
   I am not sure how much I like it, but it made my testing easier/faster.  I
   might change the write interface to take text instead of binary.

Vlad Yasevich (13):
  vlan: wrap hw-acceleration calls in separate functions.
  bridge: Add vlan filtering infrastructure
  bridge: Validate that vlan is permitted on ingress
  bridge: Verify that a vlan is allowed to egress on give port
  bridge: Add netlink interface to configure vlans on bridge ports
  bridge: Add the ability to configure pvid
  bridge: Implement vlan ingress/egress policy
  bridge: Add vlan to unicast fdb entries
  bridge: Add vlan id to multicast groups
  bridge: Add vlan support to static neighbors
  bridge: Add vlan support for local fdb entries
  bridge: Dump vlan information from a bridge port
  bridge: Separate egress policy bitmap

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 drivers/net/macvlan.c                         |    2 +-
 drivers/net/vxlan.c                           |    3 +-
 include/linux/if_vlan.h                       |   21 ++
 include/linux/netdevice.h                     |    6 +-
 include/uapi/linux/if_bridge.h                |   13 +-
 include/uapi/linux/neighbour.h                |    1 +
 include/uapi/linux/rtnetlink.h                |    1 +
 net/8021q/vlan.c                              |    4 +-
 net/8021q/vlan_core.c                         |   82 ++++-
 net/bridge/Kconfig                            |   14 +
 net/bridge/Makefile                           |    2 +
 net/bridge/br_device.c                        |    7 +-
 net/bridge/br_fdb.c                           |  259 ++++++++++++---
 net/bridge/br_forward.c                       |    9 +
 net/bridge/br_if.c                            |    4 +-
 net/bridge/br_input.c                         |   28 ++-
 net/bridge/br_multicast.c                     |   69 +++--
 net/bridge/br_netlink.c                       |  239 ++++++++++++--
 net/bridge/br_private.h                       |  153 ++++++++-
 net/bridge/br_sysfs_br.c                      |   21 ++
 net/bridge/br_vlan.c                          |  448 +++++++++++++++++++++++++
 net/core/rtnetlink.c                          |  111 ++++++-
 23 files changed, 1354 insertions(+), 148 deletions(-)
 create mode 100644 net/bridge/br_vlan.c

-- 
1.7.7.6
