From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/23] mlxsw: Preparation for IPv4 router
Date: Mon, 20 Jun 2016 23:03:58 +0200
Message-ID: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34445 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbcFTWup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:50:45 -0400
Received: by mail-lf0-f45.google.com with SMTP id h129so48967914lfh.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:50:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

This series prepares the driver for IPv4 router support. The router follow-up
patches are available at: https://github.com/jpirko/linux_mlxsw/tree/net-next_queue

Patches 1-9 simplify the netdevice notification block and also add several
checks during PRECHANGEUPPER events against topologies that aren't supported by
the device. This will ensure L3 interfaces are only configured on top of
valid netdevs.

Patches 10-13 contain trivial changes required for the introduction of a generic
FID struct - currently only used for vFIDs - in patch 14. Making the FID
struct generic will allow us to easily associate the underlying FIDs with
their L3-counterparts - Router interfaces (RIFs):

    FID Type        | Used by                         | RIF Type
    --------------------------------------------------------
    FID             | The VLAN-aware bridge           | VLAN
    vFID            | VLAN-unaware bridges            | FID
    rFID            | non-bridged netdevs (follow-up) | Sub-port

Obligatory ASCII art to visualize the above:

                   A.B.C.D
                      +
                      | FID RIF
                      +
                     br0                    E.F.G.H
                      +                        +
                      |                        | VLAN RIF
            +---------+---------+              +
            |                   |            br1.W
            | vFID              |              +
            |                   |              |
 vPort    +-+-+               +-+-+            +
swXpY.Z   |   |               |   |           br1
          +-+-+               +-+-+            +
            |                   |     FID=W    |
            |                   | +------------+------------+
            |                   | |                         |
        +---+---+           +---+-+-+                   +---+---+
        |       |           |       |                   |       |
        |       |           |       |                   |       |
        |       |           |       |                   |       |
        +-------+           +-------+                   +-------+
          swXpY

Patches 15-16 further generalize the struct by exploiting the fact that the
FID is a shared resource among ports. Each FID type is assigned a 'leave'
function that is invoked based on CHANGEUPPER events and takes care of the
necessary clean-up.

Patches 17-22 build upon the previous patches and use the FID struct for the
VLAN-aware bridge and take care of cleaning up FID resources in the 'leave'
functions. For now, these are only FDB records, but later on we'll have to
remove the RIFs associated with these FIDs, which will in turn take care of
routes and neighbours clean-up.

The last patch adds debug prints that proved very useful during the
development of this series.

Tested with the existing L2 recipes:
https://github.com/jpirko/lnst/tree/master/recipes/switchdev

Ido Schimmel (23):
  mlxsw: spectrum: Use notifier_from_errno() in notifier block
  mlxsw: spectrum: Sanitize port netdev upper devices
  mlxsw: spectrum: Forbid LAG slave from having VLAN uppers
  mlxsw: spectrum: Remove unnecessary checks from event processing
  mlxsw: spectrum: Use WARN_ON() return value
  mlxsw: spectrum: Make unlinking functions return void
  mlxsw: spectrum: Remove unnecessary function argument
  mlxsw: spectrum: Centralize VLAN-aware bridge ref counting
  mlxsw: spectrum: Use DECLARE_BITMAP() macro
  mlxsw: spectrum: Remove redundant function argument
  mlxsw: spectrum: Use only one function to create vFIDs
  mlxsw: spectrum: Create a function to map vPort's FID
  mlxsw: spectrum: Use FID instead of vFID to setup flooding
  mlxsw: spectrum: Make vFID struct generic
  mlxsw: spectrum: Use join / leave functions for vFID operations
  mlxsw: spectrum: Remove unused function argument
  mlxsw: spectrum: Use per-FID struct for the VLAN-aware bridge
  mlxsw: spectrum: Check if port is vPort using its VID
  mlxsw: spectrum: Add FID get / set functions
  mlxsw: spectrum: Don't count on FID being present
  mlxsw: spectrum: Refactor FDB flushing logic
  mlxsw: spectrum: Free resources upon vPort destruction
  mlxsw: spectrum: Add debug prints

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 852 ++++++++-------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  62 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 362 +++++----
 3 files changed, 592 insertions(+), 684 deletions(-)

-- 
2.5.5
