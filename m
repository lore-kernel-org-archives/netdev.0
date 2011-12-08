From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/6] vlan: introduce per-device vlan id list
Date: Thu,  8 Dec 2011 15:11:14 +0100
Message-ID: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab1LHOLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many drivers store vlan ids in their private structures.
They are maintaining the private lists in vlan_add_vid and vlan_kill_vid.

This patchset creates an infrastructure of storing vlan ids in one place,
vlan core. Another benefit of this is that it allows to keep track of vlan
ids needed. For example if eth0 has vlan id 10 on it, then it enters bonding,
bonding gets added 10 as well, then eth0 leaves bonding. Final step would
remove vlan id 10 from eth1 vlan filter resulting in potentially unfunction
vlan device. This patchset fixes this.

Jiri Pirko (6):
  vlan: rename vlan_dev_info to vlan_dev_priv
  net: make vlan ndo_vlan_rx_[add/kill]_vid return error value
  net: introduce vlan_vid_[add/del] and use them instead of direct
    [add/kill]_vid ndo calls
  vlan: introduce vid list with reference counting
  vlan: introduce functions to do mass addition/deletion of vids by
    another device
  team: use vlan_vids_[addr/del]_by_dev

 drivers/net/bonding/bond_main.c                   |   63 +++---
 drivers/net/ethernet/adaptec/starfire.c           |    8 +-
 drivers/net/ethernet/brocade/bna/bnad.c           |   12 +-
 drivers/net/ethernet/cisco/enic/enic_dev.c        |   14 +-
 drivers/net/ethernet/cisco/enic/enic_dev.h        |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c       |   12 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c         |   21 ++-
 drivers/net/ethernet/intel/e1000/e1000_main.c     |   14 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        |   12 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |   12 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |   20 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |   12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    7 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |    6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |   10 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |   38 ++--
 drivers/net/ethernet/tehuti/tehuti.c              |    6 +-
 drivers/net/ethernet/via/via-rhine.c              |   10 +-
 drivers/net/ethernet/via/via-velocity.c           |    6 +-
 drivers/net/macvlan.c                             |   14 +-
 drivers/net/team/team.c                           |   53 ++++--
 drivers/net/virtio_net.c                          |    6 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                 |    8 +-
 drivers/s390/net/qeth_l2_main.c                   |   18 +-
 drivers/s390/net/qeth_l3_main.c                   |    9 +-
 include/linux/if_vlan.h                           |   46 +++--
 include/linux/netdevice.h                         |   11 +-
 net/8021q/vlan.c                                  |  126 ++++-------
 net/8021q/vlan.h                                  |   38 +++-
 net/8021q/vlan_core.c                             |  233 ++++++++++++++++++++-
 net/8021q/vlan_dev.c                              |   72 ++++----
 net/8021q/vlan_gvrp.c                             |    4 +-
 net/8021q/vlan_netlink.c                          |   10 +-
 net/8021q/vlanproc.c                              |   42 ++--
 36 files changed, 662 insertions(+), 331 deletions(-)

-- 
1.7.6
