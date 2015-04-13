From: sfeldma@gmail.com
Subject: [PATCH net-next v4 00/24] switchdev: spring cleanup
Date: Sun, 12 Apr 2015 23:16:54 -0700
Message-ID: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34656 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbbDMGQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:32 -0400
Received: by pacyx8 with SMTP id yx8so91982354pac.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v4:

Well, it was a lot of work, but now prepare-commit transaction model is how
davem advises: if prepare fails, abort the transaction.  The driver must do
resource reservations up front in prepare phase and return those resources if
aborting.  Commit phase would use reserved resources.  The good news is the
driver code (for rocker) now handles resource allocation failures better by not
leaving partially device or driver states.  This is a side-effect of the
prepare phase where state isn't modified; only validation of inputs and
resource reservations happen in the prepare phase.  Since we're supporting
setting attrs and add objs across lower devs in the stacked case, we need to
hold rtnl_lock (or ensure rtnl_lock is held) so lower devs don't move on us
during the prepare-commit transaction.  DSA driver code skips the prepare phase
and goes straight for the commit phase since no up-front allocations are done
and no device failures (that could be detected in the prepare phase) can
happen.

Remove NETIF_F_HW_SWITCH_OFFLOAD from rocker and the swdev_attr_set/get
wrappers.  DSA doesn't set NETIF_F_HW_SWITCH_OFFLOAD, so it can't be in
swdev_attr_set/get.  rocker doesn't need it; or rather can't support
NETIF_F_HW_SWITCH_OFFLOAD being set/cleared at run-time after the device
port is already up and offloading L2/L3.  NETIF_F_HW_SWITCH_OFFLOAD is still
left as a feature flag for drivers that can use it.

Drop the renaming patch for netdev_switch_notifier.  Other renames are a
result of moving to the attr get/set or obj add/del model.  Everything
but the netdev_switch_notifier is still prefixed with "swdev_".

v3:

Move to two-phase prepare-commit transaction model for attr set and obj add.
Driver gets a change in prepare phase to NACK transaction if lack of resources
or support in device.

v2:

Address review comments:

 - [Jiri] squash a few related patches
 - [Roopa] don't remove NETIF_F_HW_SWITCH_OFFLOAD
 - [Roopa] address VLAN setlink/dellink
 - [Ronen] print warning is attr set revert fails

Not address:

 - Using something other than "swdev_" prefix
 - Vendor extentions

The patch set grew a bit to not only support port attr get/set but also add
support for port obj add/del.  Example of port objs are VLAN, FDB entries, and
FIB entries.  The VLAN support now allows the swdev driver to get VLAN ranges
and flags like PVID and "untagged".  Sridhar will be adding FDB obj support
in follow-on patch.


v1:

The main theme of this patch set is to cleanup swdev in preparation for
new features or fixes to be added soon.  We have a pretty good idea now how
to handle stacked drivers in swdev, but there where some loose ends.  For
example, if a set failed in the middle of walking the lower devs, we would
leave the system in an undefined state...there was no way to recover back to
the previous state.  Speaking of sets, also recognize a pattern that most
swdev API accesses are gets or sets of port attributes, so go ahead and make
port attr get/set the central swdev API, and convert everything that is
set-ish/get-ish to this new API.

Features/fixes that should follow from this cleanup:

 - solve the duplicate pkt forwarding issue
 - get/set bridge attrs, like ageing_time, from/to device
 - get/set more bridge port attrs from/to device

There are some rename cleanups tagging along at the end, to give swdev
consistent naming.

And finally, some much needed updates to the switchdev.txt documentation to
hopefully capture the state-of-the-art of swdev.  Hopefully, we can do a better
job keeping this document up-to-date.

Tested with rocker, of course, to make sure nothing functional broke.  There
are a couple minor tweaks to DSA code for getting switch ID and setting STP
updates to use new API, but not expecting amy breakage there.



Scott Feldman (24):
  switchdev: introduce get/set attrs ops
  switchdev: convert parent_id_get to swdev attr get
  switchdev: convert STP update to swdev attr set
  switchdev: add bridge port flags attr
  rocker: use swdev get/set attr for bridge port flags
  switchdev: introduce swdev add/del obj ops
  switchdev: add port vlan obj
  rocker: use swdev add/del obj for bridge port vlans
  switchdev: add new swdev bridge setlink
  rocker: cut over to new swdev_port_bridge_setlink
  bonding: cut over to new swdev_port_bridge_setlink
  team: cut over to new swdev_port_bridge_setlink
  switchdev: remove old netdev_switch_port_bridge_setlink
  switchdev: add new swdev_port_bridge_dellink
  rocker: cut over to new swdev_port_bridge_dellink
  bonding: cut over to new swdev_port_bridge_dellink
  team: cut over to new swdev_port_bridge_dellink
  switchdev: remove unused netdev_switch_port_bridge_dellink
  switchdev: add new swdev_port_bridge_getlink
  rocker: cut over to new swdev_port_bridge_getlink
  bonding: cut over to new swdev_port_bridge_getlink
  team: cut over to new swdev_port_bridge_getlink
  switchdev: convert fib_ipv4_add/del over to swdev_port_obj_add/del
  switchdev: bring documentation up-to-date

 Documentation/networking/switchdev.txt |  414 ++++++++++++++++++---
 drivers/net/bonding/bond_main.c        |    5 +-
 drivers/net/ethernet/rocker/rocker.c   |  497 ++++++++++++++++++-------
 drivers/net/team/team.c                |    5 +-
 include/net/switchdev.h                |  177 +++++----
 net/bridge/br_netlink.c                |   24 +-
 net/bridge/br_stp.c                    |    6 +-
 net/core/net-sysfs.c                   |   10 +-
 net/core/rtnetlink.c                   |    9 +-
 net/dsa/slave.c                        |   36 +-
 net/ipv4/fib_trie.c                    |   38 +-
 net/switchdev/switchdev.c              |  623 +++++++++++++++++++++++++-------
 12 files changed, 1386 insertions(+), 458 deletions(-)

-- 
1.7.10.4
