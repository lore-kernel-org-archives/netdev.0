From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 00/14] Move vlan acceleration into networking core.
Date: Wed, 20 Oct 2010 16:56:00 -0700
Message-ID: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:59370 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab0JTX4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:21 -0400
Received: by qyk12 with SMTP id 12so1775911qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware vlan acceleration behaves fairly differently from other types of
offloading, which limits its usefulness.  This patch series aims to bring
it more in line with other common forms of acceleration, such as checksum
offloading and TSO.  In doing this it eliminates common driver bugs, increases
flexibility, and improves performance, while reducing the number of lines of
code.

The first eleven patches can be applied immediately, while the last three need
to wait until all drivers that support vlan acceleration are updated.  If
people agree that this patch set makes sense I will go ahead and switch over
the dozen or so drivers that would need to change.

Changes since v1:
 * Break apart patches and use temporary variables for better readibility.
 * Use rcu_dereference_rtnl() in vlan_find_dev().
 * Restructure netif_needs_gso() for better common case performance.
 * Make ebtables consistently use the outer vlan tag if two are present.
 * Drop check for vlan group on transmit in all drivers.
 * Send vlan traffic through __netif_receive_skb both tagged and untagged for
   consistent results between accelerated and non-acclerated traffic.
 * Add support for Ethtool.
 * Enable vlan accleration on bridge devices.
 * Convert bnx2x driver.

Hao Zheng (1):
  bnx2x: Update bnx2x to use new vlan accleration.

Jesse Gross (13):
  ebtables: Allow filtering of hardware accelerated vlan frames.
  vlan: Rename VLAN_GROUP_ARRAY_LEN to VLAN_N_VID.
  vlan: Don't check for vlan group before vlan_tx_tag_present.
  vlan: Enable software emulation for vlan accleration.
  vlan: Avoid hash table lookup to find group.
  vlan: Centralize handling of hardware acceleration.
  ethtool: Add support for vlan accleration.
  bridge: Add support for TX vlan offload.
  bnx2: Update bnx2 to use new vlan accleration.
  ixgbe: Update ixgbe to use new vlan accleration.
  lro: Remove explicit vlan support.
  bonding: Update bonding for new vlan model.
  vlan: Remove accleration legacy functions.

 drivers/net/8139cp.c               |    2 +-
 drivers/net/amd8111e.c             |    2 +-
 drivers/net/atl1c/atl1c_main.c     |    2 +-
 drivers/net/atl1e/atl1e_main.c     |    2 +-
 drivers/net/atlx/atl1.c            |    2 +-
 drivers/net/atlx/atl2.c            |    2 +-
 drivers/net/benet/be.h             |    2 +-
 drivers/net/benet/be_main.c        |    9 +-
 drivers/net/bna/bnad.c             |    2 +-
 drivers/net/bnx2.c                 |   99 +++++++------------------
 drivers/net/bnx2.h                 |    4 -
 drivers/net/bnx2x/bnx2x.h          |   10 ---
 drivers/net/bnx2x/bnx2x_cmn.c      |   63 +++-------------
 drivers/net/bnx2x/bnx2x_ethtool.c  |   33 ++++----
 drivers/net/bnx2x/bnx2x_main.c     |    8 --
 drivers/net/bonding/bond_alb.c     |    8 +-
 drivers/net/bonding/bond_ipv6.c    |    5 +-
 drivers/net/bonding/bond_main.c    |  143 +++++++-----------------------------
 drivers/net/bonding/bonding.h      |    1 -
 drivers/net/chelsio/sge.c          |    2 +-
 drivers/net/cxgb3/sge.c            |    4 +-
 drivers/net/e1000/e1000_main.c     |    4 +-
 drivers/net/e1000e/netdev.c        |    4 +-
 drivers/net/ehea/ehea_main.c       |    2 +-
 drivers/net/enic/enic_main.c       |    2 +-
 drivers/net/forcedeth.c            |   11 +--
 drivers/net/gianfar.c              |    4 +-
 drivers/net/igb/igb_main.c         |    4 +-
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbe/ixgbe.h          |    4 +-
 drivers/net/ixgbe/ixgbe_ethtool.c  |   12 +++-
 drivers/net/ixgbe/ixgbe_main.c     |  139 +++++++++++++++-------------------
 drivers/net/ixgbevf/ixgbevf_main.c |    4 +-
 drivers/net/mlx4/en_tx.c           |    4 +-
 drivers/net/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/qlge/qlge_main.c       |    2 +-
 drivers/net/r8169.c                |    2 +-
 drivers/net/s2io.c                 |    2 +-
 drivers/net/sky2.c                 |    2 +-
 drivers/net/tg3.c                  |    4 +-
 drivers/net/via-velocity.c         |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c  |    2 +-
 drivers/net/vxge/vxge-main.c       |    4 +-
 drivers/s390/net/qeth_l3_main.c    |    6 +-
 include/linux/ethtool.h            |    2 +
 include/linux/if_vlan.h            |   88 +++++++---------------
 include/linux/inet_lro.h           |   20 -----
 include/linux/netdevice.h          |   28 ++++---
 net/8021q/vlan.c                   |   84 ++++-----------------
 net/8021q/vlan.h                   |   17 ----
 net/8021q/vlan_core.c              |  132 +++++----------------------------
 net/8021q/vlan_dev.c               |    2 +-
 net/bridge/br_device.c             |    8 ++-
 net/bridge/br_netfilter.c          |   16 ++--
 net/bridge/netfilter/ebt_vlan.c    |   25 ++++--
 net/bridge/netfilter/ebtables.c    |   15 +++-
 net/core/dev.c                     |   83 ++++++++++++---------
 net/core/ethtool.c                 |    3 +-
 net/ipv4/inet_lro.c                |   74 +++----------------
 60 files changed, 395 insertions(+), 833 deletions(-)

