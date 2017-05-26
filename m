From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/18] mlxsw: Improve extensibility
Date: Fri, 26 May 2017 08:37:22 +0200
Message-ID: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35095 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762092AbdEZGhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so1683391wmc.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Since the initial introduction of the bridge offload in commit
56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
the per-port struct was used to store both physical properties of the
port as well as logical bridge properties such as learning and active
VLANs in the VLAN-aware bridge.

The above resulted in a bloated struct and code that is getting
increasingly difficult to extend when stacked devices are taken into
account as well as more advanced use cases such as IGMP snooping.

Due to the incremental development nature of this driver as well as the
complexity of the underlying hardware, subsequent design decisions failed
to generalize the FID and RIF resources, which could've benefited from
a more generic design, resulting in consolidated code paths and better
extensibility with regards to future ASICs and use cases.

This patchset tries to solve both of these design problems, as they're
tightly coupled. To ease the code review, the changes are done in a
bottom-up manner, in which the port struct is the first to be patched,
then the FIDs the ports are mapped to and finally the RIFs configured on
top.

The first half of the patchset gradually moves away from the previous
design to a design that is more in sync with the underlying hardware and
which clearly separates between hardware-specific structs and logical
ones such as a bridge port.

All the bridge-specific information is removed from the port struct, as
well as the list of VLAN devices ("vPorts") configured on top of it.
Instead, a linked list of VLANs is introduced, which allows each VLAN
to hold a state, such as mapping to a particular FID and membership in
a bridge. The data structures are depicted in the following figure:
 
                                  mlxsw_sp_bridge_device
                                       +----------+
                                       |          |
                                  +----+          |
                                  |    |          |
                                  |    +----------+
                                  |
             mlxsw_sp_bridge_port |
                 +----------+     |
                 |          |     |
              +-->          +-----+--> ..
              |  |          |
              |  +----+-----+
              |       |
              |       v
              | mlxsw_sp_bridge_vlan
              |  +----------+
              |  | vid X    |
              |  |          +--> ..
              |  |          |
              |  +----+-----+
              |       |
              +--+----v-----+
                 | vid X    |
              +--+          +--> ..
              |  |          |
mlxsw_sp_port |  +----------+
+----------+  | mlxsw_sp_port_vlan
|          |  |
|          +--+
|          |
+----------+

This model allows us to consolidate many of the code paths relating to
VLAN-aware and VLAN-unaware bridges, as the latter is simply represented
using a bridge port with a VLAN list size of one. Another advantage of
the model is that it's easy to extend it with future per-VLAN
attributes - such as mrouter indication - by merely pushing these down
from the bridge port struct to the bridge VLAN one.

The second half of the patchset builds on top of previous work and
prepares the driver for the common FID and RIF cores, which are finally
implemented in the last two patches. These exploit the fact that despite
the different kinds of FIDs and RIFs, they do share a common object on
which the core operations can operate on.

By hiding both objects from the rest of the driver and modeling their
operations using a VFT, it'll be easier to extend the driver for future
use cases such as VXLAN.

Tested using following LNST recipes:
https://github.com/jpirko/lnst/tree/master/recipes/switchdev

Ido Schimmel (18):
  bridge: Export VLAN filtering state
  bridge: Export multicast enabled state
  mlxsw: spectrum: Set port's mode according to FID mappings
  mlxsw: spectrum: Introduce Port-VLAN structure
  mlxsw: spectrum: Change signature of FID leave function
  mlxsw: spectrum_router: Replace vPorts with Port-VLAN
  mlxsw: spectrum: Don't lose bridge port device during enslavement
  mlxsw: spectrum: Don't create FIDs upon creation of VLAN uppers
  mlxsw: spectrum: Replace vPorts with Port-VLAN
  mlxsw: spectrum_router: Allocate FID prior to RIF configuration
  mlxsw: spectrum_router: Allocate RIF prior to its configuration
  mlxsw: spectrum_router: Extend the RIF struct
  mlxsw: spectrum_router: Configure RIFs based on RIF struct
  mlxsw: spectrum_router: Destroy RIF only based on its struct
  mlxsw: spectrum_router: Flood packets to router after RIF creation
  mlxsw: spectrum_router: Determine VR first when creating RIF
  mlxsw: spectrum: Implement common FID core
  mlxsw: spectrum_router: Implement common RIF core

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    3 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  974 ++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  240 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |   17 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  992 ++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |    6 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  746 +++++----
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 1662 +++++++++++++-------
 include/linux/if_bridge.h                          |   14 +
 net/bridge/br_if.c                                 |    2 +-
 net/bridge/br_mdb.c                                |    4 +-
 net/bridge/br_multicast.c                          |    8 +
 net/bridge/br_netlink.c                            |    2 +-
 net/bridge/br_private.h                            |    9 -
 net/bridge/br_vlan.c                               |    8 +
 15 files changed, 2787 insertions(+), 1900 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c

-- 
2.9.3
