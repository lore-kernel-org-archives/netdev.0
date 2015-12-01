From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/26] bonding/team offload + mlxsw implementation
Date: Tue,  1 Dec 2015 14:48:38 +0100
Message-ID: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33840 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbbLANtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:08 -0500
Received: by wmvv187 with SMTP id v187so207528879wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces needed infrastructure for link aggregation
offload - for both team and bonding. It also implements the offload
in mlxsw driver.

Particulary, this patchset introduces possibility for upper driver
(bond/team/bridge/..) to pass type-specific info down to notifier listeners.
Info is passed along with NETDEV_CHANGEUPPER/NETDEV_PRECHANGEUPPER
notifiers. Listeners (drivers of netdevs being enslaved) can react
accordingly.

Other extension is for run-time use. This patchset introduces
new netdev notifier type - NETDEV_CHANGELOWERSTATE. Along with this
notification, the upper driver (bond/team/bridge/..) can pass some
information about lower device change, particulary link-up and
TX-enabled states. Listeners (drivers of netdevs being enslaved)
can react accordingly.

The last part of the patchset is implementation of LAG offload in mlxsw,
using both previously introduced infrastructre extensions.

Note that bond-speficic (and ugly) NETDEV_BONDING_INFO used by mlx4
can be removed and mlx4 can use the extensions this patchset adds.
I plan to convert it and get rid of NETDEV_BONDING_INFO in
a follow-up patchset.

Jiri Pirko (26):
  bonding: add 802.3ad support for 100G speeds
  net: add netif_is_team_master helper
  net: add netif_is_team_port helper
  net: add netif_is_lag_master helper
  net: add netif_is_lag_port helper
  net: propagate upper priv via netdev_master_upper_dev_link
  net: add possibility to pass information about upper device via
    notifier
  net: add info struct for LAG changeupper
  team: fill-up LAG changeupper info struct and pass it along
  bonding: fill-up LAG changeupper info struct and pass it along
  net: introduce change lower state notifier
  net: introduce lower state changed info structure for LAG lowers
  team: rtnl_lock for options set
  team: implement lower state change propagation
  bonding: allow notifications for bond_set_slave_link_state
  bonding: implement lower state change propagation
  bonding: set inactive flags on release
  mlxsw: spectrum: Add set_rx_mode ndo stub
  mlxsw: core: Add support for packets received from LAG port
  mlxsw: pci: Implement LAG processing for received packets
  mlxsw: reg: Add link aggregation configuration registers definitions
  mlxsw: reg: Add definition of LAG unicast record for SFD register
  mlxsw: reg: Add definition of LAG unicast record for SFN register
  mlxsw: spectrum: Implement LAG port join/leave
  mlxsw: spectrum: Implement FDB add/remove/dump for LAG
  mlxsw: spectrum: Implement LAG tx enabled lower state change

 drivers/net/bonding/bond_3ad.c                     |  11 +-
 drivers/net/bonding/bond_main.c                    | 109 ++++--
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  79 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  14 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |  17 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.h          |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 394 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 366 ++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  35 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 182 ++++++++--
 drivers/net/team/team.c                            |  55 ++-
 drivers/net/team/team_mode_activebackup.c          |   1 +
 drivers/net/team/team_mode_broadcast.c             |   1 +
 drivers/net/team/team_mode_loadbalance.c           |   1 +
 drivers/net/team/team_mode_random.c                |   1 +
 drivers/net/team/team_mode_roundrobin.c            |   1 +
 drivers/net/vrf.c                                  |   2 +-
 include/linux/if_team.h                            |   1 +
 include/linux/netdevice.h                          |  56 ++-
 include/net/bonding.h                              |  39 +-
 net/batman-adv/hard-interface.c                    |   3 +-
 net/bridge/br_if.c                                 |   2 +-
 net/core/dev.c                                     |  43 ++-
 net/openvswitch/vport-netdev.c                     |   2 +-
 24 files changed, 1274 insertions(+), 145 deletions(-)

-- 
1.9.3
