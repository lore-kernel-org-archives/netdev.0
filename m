From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/16] mlxsw: Multicast flood update
Date: Wed, 20 Sep 2017 16:15:00 +0200
Message-ID: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36017 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdITOPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id r136so2577218wmf.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Nogah says:

Currently, there are four erroneous flows in MC flood:
1. When MC is disabled it affects only the flood table for unregistered
   MC packets, but packets that match an entry in the MDB are unaffected.
2. When MC is disabled, MC packets are being sent to all the ports in the
   bridge (like BC and link-local MC packets) regardless of the designated
   flag (BR_MCAST_FLAG).
3. When a port is being deleted from a bridge it might remain in the MDB.
4. When MC is enabled packets are flooded to the mrouter ports only if
   they don't match any entry in the MDB, when they should always be
   flooded to them.

What these problems have in common is the discrepancy between how the
hardware handles MDB and mcast flood, and how the driver does it. Each
of these problems needs fixing either in the MDB code, or in mcast flood
code, and some in both.

Patches 1-6 change the way the MDB is handled in the driver to make the
following changes easier.
Patches 7-8 fix problem number 1 by removing the MDB from the HW when MC
is being disabled and restoring it when it is being enabled.
Patches 9-10 fix problem number 2 by offloading the flood table by the
appropriate flag.
Patch 11 fixes problem number 3 by adding MDB flush to the port removal.
Patches 12-14 fix problem number 4 by adding the mrouter ports to every
MDB entry in the HW to mimic the wanted behaviour.

Nogah Frankel (16):
  mlxsw: spectrum_switchdev: Change mc_router to mrouter
  mlxsw: spectrum_switchdev: Add a ports bitmap to the mid db
  mlxsw: spectrum_switchdev: Remove reference count from mid
  mlxsw: spectrum_switchdev: Save mids list per bridge device
  mlxsw: spectrum_switchdev: Break smid write function
  mlxsw: spectrum_switchdev: Attach mid id allocation to HW write
  mlxsw: spectrum_switchdev: Break mid deletion into two function
  mlxsw: spectrum_switchdev: Don't write mids to the HW when mc is
    disabled
  mlxsw: spectrum_switchdev: Disable mdb when mc is disabled
  mlxsw: spectrum_switchdev: Use generic mc flood function
  mlxsw: spectrum_switchdev: Flood mc when mc is disabled by user flag
  mlxsw: spectrum_switchdev: Flush the mdb when a port is being removed
  mlxsw: spectrum_switchdev: Flood all mc packets to mrouter ports
  mlxsw: spectrum_switchdev: Update the mdb of mrouter port change
  mlxsw: spectrum_switchdev: Remove mrouter flood in mdb flush
  mlxsw: spectrum_switchdev: Consider mrouter status for mdb changes

 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   3 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 417 ++++++++++++++++-----
 2 files changed, 323 insertions(+), 97 deletions(-)

-- 
2.9.5
