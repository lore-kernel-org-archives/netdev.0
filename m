From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/10] mlxsw: Offload MC flood for unregister MC
Date: Thu,  9 Feb 2017 14:54:39 +0100
Message-ID: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:35346 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753063AbdBIO1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:27:32 -0500
Received: by mail-wr0-f169.google.com with SMTP id 89so84938166wrr.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:27:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Nogah says:

When multicast is enabled, the Linux bridge floods unregistered multicast
packets only to ports connected to a multicast router. Devices capable of
offloading the Linux bridge need to be made aware of such ports, for
proper flooding behavior.
On the other hand, when multicast is disabled, such packets should be
flooded to all ports. This patchset aims to fix that, by offloading
the multicast state and the list of multicast router ports.

The first 3 patches adds switchdev attributes to offload this data.
The rest of the patchset add implementation for handling this data in the
mlxsw driver.

The effects this data has on the MDB (namely, when the multicast is
disabled the MDB should be considered as invalid, and when it is enabled, a
packet that is flooded by it should also be flooded to the multicast
routers ports) is subject of future work.

Testing of this patchset included:
Sending 3 mc packets streams, LL, register and unregistered, and checking
that they reached only to the ports that should have received them.
The configs were:
mc disabled, mc without mc router ports and mc with fixed router port.
It was checked for vlan aware bridge, vlan unaware bridge and vlan unaware
bridge with another vlan unaware bridge on the same machine

Nogah Frankel (10):
  switchdev: bridge: Offload multicast disabled
  bridge: mcast: Merge the mc router ports deletions to one function
  switchdev: bridge: Offload mc router ports
  mlxsw: spectrum: Break flood set func to be per table
  mlxsw: spectrum: Make port flood update more generic
  mlxsw: spectrum: Change max vfid
  mlxsw: spectrum: Separate bc and mc floods
  mlxsw: spectrum: Add an option to flood mc by mc_router_port
  mlxsw: spectrum: Extend port_orig_get for bridge devices
  mlxsw: spectrum: Update mc_disabled flag by switchdev attr

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  29 +++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  10 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 154 +++++++++++++++++----
 include/net/switchdev.h                            |   4 +
 net/bridge/br_multicast.c                          |  55 ++++++--
 5 files changed, 198 insertions(+), 54 deletions(-)

-- 
2.7.4
