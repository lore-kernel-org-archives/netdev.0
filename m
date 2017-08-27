From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/4] SRIOV VF VGT+ and violation counters support
Date: Sun, 27 Aug 2017 14:06:14 +0300
Message-ID: <20170827110618.20599-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37292 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751116AbdH0LV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 07:21:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

This series provides two security SRIOV related features (VGT+ and VF violation counters).

VGT+ is a security feature that gives the administrator the ability of controlling
the allowed VGT vlan IDs list that can be transmitted/received from/to the VF.
The allowed VGT vlan IDs list is called "trunk".

Admin can add/remove a range of allowed vlan-ids via iptool:
ip link set { DEVICE } [ vf NUM [ trunk { add | rem } START-VLAN-ID [ END-VLAN-ID ] [ proto VLAN-PROTO ] ] ]

Example:
After this series of configuration :
1) ip link set eth3 vf 0 trunk add 10 100 (allow vlan-id 10-100, default tpid 0x8100)
2) ip link set eth3 vf 0 trunk add 105 proto 802.1q (allow vlan-id 105 tpid 0x8100)
3) ip link set eth3 vf 0 trunk add 105 proto 802.1ad (allow vlan-id 105 tpid 0x88a8)
4) ip link set eth3 vf 0 trunk rem 90 (block vlan-id 90)
5) ip link set eth3 vf 0 trunk rem 50 60 (block vlan-ids 50-60)

VF 0 can only communicate on vlan-ids: 10-49,61-89,91-100,105 with tpid 0x8100 and vlan-id 105 with tpid 0x88a8.

For this purpose following net_device callbacks were added:
int (*ndo_add_vf_vlan_trunk_range)(struct net_device *dev, int vf, u16 start_vid, u16 end_vid, __be16 proto);
int (*ndo_del_vf_vlan_trunk_range)(struct net_device *dev, int vf, u16 start_vid, u16 end_vid, __be16 proto);

This feature is implemented and demonstrated in mlx5 via ACL steering tables and vlan rules attached to the VF's
corresponding E-Switch vport.

I addition to VGT+ we introduce new set of counter to VF statistics, to collect counters for traffic violating
VF ACL rules (such as VGT+ violation), for that we extend the current ifla_vf_stats to include rx_dropped/tx_dropped
to be reported per VF.

Example:
> ip link set eth3 vf 0 trunk add 10 100
VF 0 transmits 2412 packets on a vlan id not in [10,100] range will be dropped and reported in hypervisor
via:
> ip -s link show dev enp5s0f0"
      6: enp5s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
        [...]
	vf 0 MAC 00:00:ca:fe:ca:fe, vlan 5, spoof checking off, link-state auto, trust off, query_rss off
        RX: bytes  packets  mcast   bcast   dropped
        1666       29       14         32      0
        TX: bytes  packets   dropped
        2880       44       2412

Thanks,
Saeed.

Eugenia Emantayev (2):
  net/core: Add violation counters to VF statisctics
  net/mlx5e: E-switch, Add steering drop counters

Mohamad Haj Yahia (2):
  net: Add SRIOV VGT+ support
  net/mlx5: Add SRIOV VGT+ support

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  28 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 589 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  31 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   2 +
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  19 +-
 include/linux/if_link.h                            |   4 +
 include/linux/mlx5/vport.h                         |   6 +-
 include/linux/netdevice.h                          |  12 +
 include/uapi/linux/if_link.h                       |  22 +
 net/core/rtnetlink.c                               | 119 +++--
 11 files changed, 681 insertions(+), 157 deletions(-)

-- 
2.13.0
