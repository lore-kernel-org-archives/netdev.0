From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V4 00/13] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 12:48:11 -0500
Message-ID: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab2LSSRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 13:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches provides an ability to add VLANs to the bridge
ports.  This is similar to what can be found in most switches.  The bridge
port may have any number of VLANs added to it including vlan 0 priority tagged
traffic.  When vlans are added to the port, only traffic tagged with particular
vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
entries and become part of the lookup.  This way we correctly identify the FDB
entry.

A single vlan per port may also be designated as untagged.  Any untagged
traffic recieved by the port will be assigned to this vlan.  Any traffic
exiting the port with a VID matching the untagged vlan will exit untagged (the
bridge will strip the vlan header).  This is similar to "Native Vlan" support
available in most switches.  This is also configurable on the bridge master
interface as well.

The default behavior of the bridge is unchanged if no vlans have been
configured.  Default behavior of each port is also unchanged if no
vlans are configured on that port (i.e there are no ingress/egress checks
or vlan header manipulation).

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


Vlad Yasevich (12):
  bridge: Add vlan filtering infrastructure
  bridge: Validate that vlan is permitted on ingress
  bridge: Verify that a vlan is allowed to egress on give port
  bridge: Cache vlan in the cb for faster egress lookup.
  bridge: Add vlan to unicast fdb entries
  bridge: Add vlan id to multicast groups
  bridge: Add netlink interface to configure vlans on bridge ports
  bridge: Add vlan support to static neighbors
  bridge: Add the ability to configure untagged vlans
  bridge: Implement untagged vlan handling
  bridge: Dump vlan information from a bridge port
  bridge: Add vlan support for local fdb entries

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
 drivers/net/macvlan.c                         |    2 +-
 drivers/net/vxlan.c                           |    3 +-
 include/linux/netdevice.h                     |    4 +-
 include/uapi/linux/if_bridge.h                |   23 ++-
 include/uapi/linux/neighbour.h                |    1 +
 include/uapi/linux/rtnetlink.h                |    1 +
 net/bridge/br_device.c                        |   34 ++-
 net/bridge/br_fdb.c                           |  253 ++++++++++++---
 net/bridge/br_forward.c                       |  160 ++++++++++
 net/bridge/br_if.c                            |  404 ++++++++++++++++++++++++-
 net/bridge/br_input.c                         |   65 ++++-
 net/bridge/br_multicast.c                     |   71 +++--
 net/bridge/br_netlink.c                       |  178 ++++++++++--
 net/bridge/br_private.h                       |   71 ++++-
 net/core/rtnetlink.c                          |   40 ++-
 16 files changed, 1190 insertions(+), 125 deletions(-)

-- 
1.7.7.6
