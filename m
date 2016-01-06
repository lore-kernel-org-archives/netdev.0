From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 0/8] net: break dependency of drivers on geneve and vxlan
Date: Thu,  7 Jan 2016 00:39:23 +0100
Message-ID: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47664 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196AbcAFXjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:40 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id D2FDF203C9
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:39 -0500 (EST)
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

Hannes Frederic Sowa (8):
  qlcnic: protect qlcnic_82xx_io_slot_reset with rtnl lock
  mlx4: add rtnl lock protection in mlx4_en_restart
  ixgbe: add rtnl locking in service task around vxlan_get_rx_port
  benet: add rtnl lock protection around be_open in be_resume
  fm10k: add rtnl lock protection in fm10k_io_resume
  netdev: add netdevice notifier type to trigger a reprogramming of
    offloads
  vxlan: break dependency to network drivers
  geneve: break dependency to network drivers

 drivers/net/ethernet/emulex/benet/be_main.c      |  9 +++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 ++++++--
 drivers/net/geneve.c                             | 30 +++++++++++++++++++++---
 drivers/net/vxlan.c                              | 17 +++++++++-----
 include/linux/netdevice.h                        |  1 +
 include/net/geneve.h                             |  7 +++---
 include/net/vxlan.h                              |  5 +---
 10 files changed, 62 insertions(+), 23 deletions(-)

-- 
2.5.0
