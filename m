From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/42] mlxsw: Implement IPV4 unicast routing
Date: Fri,  1 Jul 2016 16:04:28 +0200
Message-ID: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33787 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbcGAORl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:17:41 -0400
Received: by mail-wm0-f67.google.com with SMTP id r201so5660746wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:17:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset enables IPv4 unicast routing in the Mellanox Spectrum ASIC
switch driver. The basic dependencies are already present in the kernel and
used by rocker.

Patches 1-3 add a couple of dependencies outside the driver. Namely, the
ability to propagate ndo_neigh_construct()/destroy() through stacked devices and
a notification whenever DELAY_PROBE_TIME changes. When propagated down, the
ndos allow drivers to add and remove neighbour entries from their private
neighbour table. The DELAY_PROBE_TIME notification gives drivers the ability to
correctly configure their polling interval for neighbour activity, so that
active neighbour won't be marked as STALE.

Patches 4-25 add missing infrastructure in the driver for the router,
initialize it and lay the groundwork for the introduction of router
interfaces. These are introduced in patches 26-29. At this point the router
still operates in slowpath, but that's needed in order not to introduce a
regression.

Patches 30-33 add the neighbour offloading infrastructure, where patch 33 uses
the DELAY_PROBE_TIME notification in order to correctly configure the device's
polling interval. Patch 34 finally programs neighbours to the device's table
based on NEIGH_UPDATE notifications, so that directly connected routes can
be used.

Patches 35-42 build upon the previous patches and extend the router with
remote routes (nexthop) support.

Ido Schimmel (17):
  neigh: Send a notification when DELAY_PROBE_TIME changes
  mlxsw: spectrum: Send untagged packets through a port netdev
  mlxsw: spectrum: Remove VLANs configuration via SELF flag
  mlxsw: spectrum: Sync PVID vPort LAG status
  mlxsw: spectrum: Remove RIF from PVID vPort when joining / leaving LAG
  mlxsw: reg: Add Router General Configuration Register
  mlxsw: spectrum: Initialize ports at the end of init sequence
  mlxsw: spectrum_router: Add basic ipv4 router initialization
  mlxsw: spectrum: Add router interface struct
  mlxsw: reg: Add FDB action to forward to router
  mlxsw: reg: Add Router Interface Table Register
  mlxsw: spectrum: Use action 'discard' when removing traps
  mlxsw: spectrum: Edit RIF properties based on netdev events
  mlxsw: spectrum: Introduce support for router interfaces
  mlxsw: spectrum: Unsplit the vFID range
  mlxsw: spectrum: Configure FIDs based on bridge events
  mlxsw: spectrum: Enable L3 interfaces on top of bridge devices

Jiri Pirko (18):
  net: add dev arg to ndo_neigh_construct/destroy
  net: introduce default neigh_construct/destroy ndo calls for L2 upper
    devices
  mlxsw: spectrum: Add traps needed for router implementation
  mlxsw: spectrum_router: Implement private fib
  mlxsw: reg: Add Router Algorithmic LPM Tree Allocation Register
    definition
  mlxsw: reg: Add Router Algorithmic LPM Structure Tree Register
    definition
  mlxsw: reg: Add Router Algorithmic LPM Tree Binding Register
    definition
  mlxsw: spectrum_router: Implement LPM trees management
  mlxsw: spectrum_router: Add virtual router management
  mlxsw: reg: Add Router Algorithmic LPM Unicast Entry Register
    definition
  mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops
  mlxsw: spectrum: Add couple of lower device helper functions
  mlxsw: spectrum_router: Add private neigh table
  mlxsw: Add KVD sizes configuration into profile
  mlxsw: spectrum: Define sizes of KVD areas
  mlxsw: Introduce simplistic KVD linear area manager
  mlxsw: reg: Add Router Algorithmic LPM ECMP Update Register
  mlxsw: spectrum_router: Implement next-hop routing

Yotam Gigi (7):
  mlxsw: reg: Add Router Algorithmic LPM Unicast Host Table register
  mlxsw: reg: Add Router Algorithmic LPM Unicast Host Table Dump
    register
  mlxsw: spectrum_router: Periodically update the kernel's neigh table
  mlxsw: spectrum_router: Offload neighbours based on NUD state change
  mlxsw: reg: Add Router Adjacency Table register
  mlxsw: spectrum_router: Add the nexthop neigh activity update
  mlxsw: Add the unresolved next-hops probes

 drivers/net/bonding/bond_main.c                    |    2 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    3 +-
 drivers/net/ethernet/mellanox/mlxsw/cmd.h          |   43 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |    6 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |   14 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 1206 ++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 1164 +++++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  164 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_kvdl.c    |   91 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 1814 ++++++++++++++++++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  116 +-
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |    5 +
 drivers/net/ethernet/rocker/rocker_main.c          |    3 +-
 drivers/net/team/team.c                            |    2 +
 include/linux/netdevice.h                          |   28 +-
 include/net/netevent.h                             |    1 +
 net/8021q/vlan_dev.c                               |    2 +
 net/atm/clip.c                                     |    2 +-
 net/bridge/br_device.c                             |    2 +
 net/core/dev.c                                     |   78 +
 net/core/neighbour.c                               |    6 +-
 net/ieee802154/6lowpan/core.c                      |    2 +-
 22 files changed, 4330 insertions(+), 424 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c

-- 
2.5.5
