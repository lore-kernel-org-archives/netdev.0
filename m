From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 0/7] switchdev offload flags
Date: Thu, 29 Jan 2015 22:40:10 -0800
Message-ID: <1422600017-42393-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55298 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbA3GkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:23 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so48724476pad.7
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series introduces new offload flags for switchdev.
Kernel network subsystems can use this flag to accelerate
network functions by offloading to hw.

I expect that there will be need for subsystem specific feature
flag in the future.

This patch series currently only addresses bridge driver link
attribute offloads to hardware.

Looking at the current state of bridge l2 offload in the kernel,
    - flag 'self' is the way to directly manage the bridge device in hw via
      the ndo_bridge_setlink/ndo_bridge_getlink calls

    - flag 'master' is always used to manage the in kernel bridge devices
      via the same ndo_bridge_setlink/ndo_bridge_getlink calls

Today these are used separately. The nic offloads use hwmode "vepa/veb" to go
directly to hw with the "self" flag.

At this point i am trying not to introduce any new user facing flags/attributes.
In the model where we want the kernel bridging to be accelerated with
hardware, we very much want the bridge driver to be involved.

In this proposal,
- The offload flag/bit helps switch asic drivers to indicate that they
  accelerate the kernel networking objects/functions
- The user does not have to specify a new flag to do so. A bridge created with
  switch asic ports will be accelerated if the switch driver supports it.
- The user can continue to directly manage l2 in nics (ixgbe) using the
  existing hwmode/self flags
- It also does not stop users from using the 'self' flag to talk to the
  switch asic driver directly
- Involving the bridge driver makes sure the add/del notifications to user
  space go out after both kernel and hardware are programmed

(To selectively offload bridge port attributes,
example learning in hw only etc, we can introduce offload bits for
per bridge port flag attribute as in my previous patch
https://patchwork.ozlabs.org/patch/413211/. I have not included that in this
series)

v2
   - try a different name for the offload flag/bit
   - tries to solve the stacked netdev case by traversing the lowerdev
     list to reach the switch port

v3 -
    - Tested with bond as bridge port for the stacked device case.
      Includes a bond_fix_features change to not ignore the
      NETIF_F_HW_NETFUNC_OFFLOAD flag
    - Some checkpatch fixes

v4 -
    - rename flag to NETIF_F_HW_SWITCH_OFFLOAD
    - add ndo_bridge_setlink/dellink handlers in bond and team drivers as
      suggested by jiri.
    - introduce default ndo_dflt_netdev_switch_port_bridge_setlink/dellink
    handlers that masters can use to call offload api on lowerdevs.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (7):
  netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature flag for
    switch device offloads
  bridge: add flags argument to ndo_bridge_setlink and
    ndo_bridge_dellink
  swdevice: add new apis to set and del bridge port attributes
  bridge: offload bridge port attributes to switch asic if feature flag
    set
  rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
  bonding: handle NETIF_F_HW_SWITCH_OFFLOAD flag and add
    ndo_bridge_setlink/dellink handlers
  team: handle NETIF_F_HW_SWITCH_OFFLOAD flag and add
    ndo_bridge_setlink/dellink handlers

 drivers/net/bonding/bond_main.c               |    9 +-
 drivers/net/ethernet/emulex/benet/be_main.c   |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ethernet/rocker/rocker.c          |    5 +-
 drivers/net/team/team.c                       |    5 +-
 include/linux/netdev_features.h               |    6 +-
 include/linux/netdevice.h                     |    6 +-
 include/net/switchdev.h                       |   37 ++++++++-
 net/bridge/br_netlink.c                       |   30 +++++--
 net/bridge/br_private.h                       |    4 +-
 net/core/rtnetlink.c                          |   10 ++-
 net/switchdev/switchdev.c                     |  110 +++++++++++++++++++++++++
 12 files changed, 206 insertions(+), 21 deletions(-)

-- 
1.7.10.4
