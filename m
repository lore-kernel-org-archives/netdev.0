From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 00/28] bonding/team offload + mlxsw implementation
Date: Thu,  3 Dec 2015 12:12:02 +0100
Message-ID: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37223 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759665AbbLCLMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:38 -0500
Received: by wmww144 with SMTP id w144so17294839wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:37 -0800 (PST)
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

---
v2->v3:
- one small fix in patch 1
v1->v2:
- added patch 1 and 2 per Andy's request
- couple of more or less cosmetic changes described in couple other patches

Ido Schimmel (2):
  net: Check CHANGEUPPER notifier return value
  net: Add support for CHANGEUPPER notifier error injection

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

 .../fault-injection/notifier-error-inject.txt      |   1 +
 drivers/net/bonding/bond_3ad.c                     |  11 +-
 drivers/net/bonding/bond_main.c                    | 111 ++++--
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  79 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  14 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |  17 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.h          |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 394 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 370 ++++++++++++++++++-
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
 lib/netdev-notifier-error-inject.c                 |   1 +
 net/batman-adv/hard-interface.c                    |   3 +-
 net/bridge/br_if.c                                 |   2 +-
 net/core/dev.c                                     |  51 ++-
 net/openvswitch/vport-netdev.c                     |   2 +-
 26 files changed, 1288 insertions(+), 147 deletions(-)

-- 
1.9.3
