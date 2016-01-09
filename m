From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 00/10] net: break dependency of drivers on geneve and vxlan
Date: Sat,  9 Jan 2016 16:07:22 +0100
Message-ID: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41662 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207AbcAIPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 10:07:40 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id CE1F020A68
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 10:07:39 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device drivers which support geneve or vxlan offloading have a dependency
on the correlating tunnel kernel modules. Thus those drivers automatically
load the geneve or vxlan modules. Break this dependency with this
small series.

Additionally this series features a review of the respective ->ndo_open
and other functions around vxlan_get_rx_port and geneve_get_rx_port.

* Result:
$ cd drivers/net/ethernet/
$ find . -name '*.ko' | xargs modinfo | egrep  '^depends:.*(vxlan|geneve)'  | wc -l
0

I also incorporated feedback from Jesse Gross to only use one new
netdevice notifiers type, namely NETDEV_REFRESH_OFFLOADS. Otherwise this
series is very much the same as v1.

This series (v4) incorperates further feedback from Jesse Gross:
* before calling down to the ndo_add_{vxlan,geneve}_port, check if the
  driver has actually installed the function
* provide only one callback function, namely netdev_refresh_offloads
* provide updates to the comments in netdevice.h how driver should handle
  those functions

Hannes Frederic Sowa (10):
  qlcnic: protect qlcnic_82xx_io_slot_reset with rtnl lock
  mlx4: add rtnl lock protection in mlx4_en_restart
  ixgbe: add rtnl locking in service task around vxlan_get_rx_port
  benet: add rtnl lock protection around be_open in be_resume
  fm10k: add rtnl lock protection in fm10k_io_resume
  netdev: add netdevice notifier type to trigger a reprogramming of
    offloads
  vxlan: break dependency to network drivers
  geneve: break dependency to network drivers
  net: harmonize vxlan_get_rx_port and geneve_get_rx_port to
    netdev_refresh_offloads
  netdev: update comments and explain idempotency and rtnl locking

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        | 11 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c       |  2 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  7 +---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 12 ++++--
 drivers/net/geneve.c                               | 37 ++++++++++++++----
 drivers/net/vxlan.c                                | 20 +++++++---
 include/linux/netdevice.h                          | 45 ++++++++++++++--------
 include/net/geneve.h                               | 10 +----
 include/net/vxlan.h                                |  8 ----
 15 files changed, 105 insertions(+), 67 deletions(-)

-- 
2.5.0
