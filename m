From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/16] mlxsw: Implement IPV4 unicast routing
Date: Tue,  5 Jul 2016 11:27:36 +0200
Message-ID: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35892 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcGEJ1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:27:55 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so27226972wme.3
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:27:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset enables IPv4 unicast routing in the Mellanox Spectrum ASIC
switch driver. This builds upon the work that was done by a couple of
previous patchsets.

Patches 1,2,6 add a couple of dependencies outside the driver. Namely, the
ability to propagate ndo_neigh_construct()/destroy() through stacked devices and
a notification whenever DELAY_PROBE_TIME changes. When propagated down, the
ndos allow drivers to add and remove neighbour entries from their private
neighbour table. The DELAY_PROBE_TIME notification gives drivers the ability to
correctly configure their polling interval for neighbour activity, so that
active neighbour won't be marked as STALE.

Patches 3-5,7-8 add the neighbour offloading infrastructure, where patch 7 uses
the DELAY_PROBE_TIME notification in order to correctly configure the device's
polling interval. Patch 8 finally programs neighbours to the device's table
based on NEIGH_UPDATE notifications, so that directly connected routes can
be used.

Patches 9-16 build upon the previous patches and extend the router with
remote routes (nexthop) support.

Ido Schimmel (1):
  neigh: Send a notification when DELAY_PROBE_TIME changes

Jiri Pirko (8):
  net: add dev arg to ndo_neigh_construct/destroy
  net: introduce default neigh_construct/destroy ndo calls for L2 upper
    devices
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
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  490 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |    6 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   24 +
 .../net/ethernet/mellanox/mlxsw/spectrum_kvdl.c    |   91 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 1006 +++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c          |    3 +-
 drivers/net/team/team.c                            |    2 +
 include/linux/netdevice.h                          |   10 +-
 include/net/netevent.h                             |    1 +
 net/8021q/vlan_dev.c                               |    2 +
 net/atm/clip.c                                     |    2 +-
 net/bridge/br_device.c                             |    2 +
 net/core/dev.c                                     |   44 +
 net/core/neighbour.c                               |    6 +-
 net/ieee802154/6lowpan/core.c                      |    2 +-
 20 files changed, 1747 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c

-- 
2.5.5
