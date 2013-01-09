From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V5 00/14] Add basic VLAN support to bridges
Date: Wed,  9 Jan 2013 12:17:47 -0500
Message-ID: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129Ab3AIRSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches provides an ability to add VLANs to the bridge
ports.  This is similar to what can be found in most switches.  The bridge
port may have any number of VLANs added to it including vlan 0 priority tagged
traffic.  When vlans are added to the port, only traffic tagged with particular
vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
entries and become part of the lookup.  This way we correctly identify the FDB
entry.

A single vlan per port may also be designated as a PVID.  Any untagged
traffic recieved by the port will be assigned to this vlan and all further
processing will be done with this vlan in mind.

Any number for vlans per port may also be designated as untagged.  This
defines their egress policy such that any frame exiting the port with a
VID matching the untagged vlan will exit untagged (the bridge will strip the
vlan header).

Bridge device is trated as just another port for the purposes of vlan
configuration so, users have to configure which vlans are allowed to
enter and exit the bridge master device.

The default behavior of the bridge is unchanged if no vlans have been
configured.  Default behavior of each port is also unchanged if no
vlans are configured on that port (i.e there are no ingress/egress checks
or vlan header manipulation).

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

Vlad Yasevich (14):
  vlan: wrap hw-acceleration calls in separate functions.
  bridge: Add vlan filtering infrastructure
  bridge: Validate that vlan is permitted on ingress
  bridge: Verify that a vlan is allowed to egress on give port
  bridge: Cache vlan in the cb for faster egress lookup.
  bridge: Add vlan to unicast fdb entries
  bridge: Add vlan id to multicast groups
  bridge: Add netlink interface to configure vlans on bridge ports
  bridge: Add vlan support to static neighbors
  bridge: Add the ability to configure pvid
  bridge: API to configure egress policy
  bridge: Implement vlan ingress/egress policy
  bridge: Dump vlan information from a bridge port
  bridge: Add vlan support for local fdb entries

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 drivers/net/macvlan.c                         |    2 +-
 drivers/net/vxlan.c                           |    3 +-
 include/linux/if_vlan.h                       |   57 ++++
 include/linux/netdevice.h                     |    6 +-
 include/uapi/linux/if_bridge.h                |   13 +-
 include/uapi/linux/neighbour.h                |    1 +
 include/uapi/linux/rtnetlink.h                |    1 +
 net/8021q/vlan.c                              |    4 +-
 net/8021q/vlan_core.c                         |   24 +--
 net/bridge/br_device.c                        |   13 +-
 net/bridge/br_fdb.c                           |  254 +++++++++++++++----
 net/bridge/br_forward.c                       |  131 ++++++++++
 net/bridge/br_if.c                            |  347 ++++++++++++++++++++++++-
 net/bridge/br_input.c                         |   69 +++++-
 net/bridge/br_multicast.c                     |   71 ++++--
 net/bridge/br_netlink.c                       |  242 +++++++++++++++--
 net/bridge/br_private.h                       |  101 +++++++-
 net/core/rtnetlink.c                          |  111 +++++++-
 19 files changed, 1307 insertions(+), 148 deletions(-)

-- 
1.7.7.6
