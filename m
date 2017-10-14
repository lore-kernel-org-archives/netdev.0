From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][for-next 00/12] Mellanox, mlx5 IPoIB Muli Pkey support 2017-10-11
Date: Sat, 14 Oct 2017 11:48:15 -0700
Message-ID: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43142 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751337AbdJNSsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and Doug,

This series includes updates for mlx5 IPoIB offloading driver from Alex
and Feras to add the support for Muli Pkey in the mlx5i ipoib offloading netdev,
to be merged into net-next and rdma-next trees.

Doug, I am sorry I couldn't base this on rc2 since the series needs and conflicts
with a fix that was submitted to rc3, so to keep things simple I based it on rc4,
I hope this is ok with you..

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f:

  Linux 4.14-rc4 (2017-10-08 20:53:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-updates-2017-10-11

for you to fetch changes up to b5ae577741bec22b584fa704076ccd8221cad19d:

  net/mlx5e: IPoIB, Modify rdma netdev allocate and free to support PKEY (2017-10-14 11:22:12 -0700)

----------------------------------------------------------------
mlx5-updates-2017-10-11: IPoIB Muli Pkey support

This series provides the support for IPoIB Multi Pkey.
InfiniBand Pkeys are the equivalent of Ethernet vlans.
Currently IPoIB device driver supports only default Pkey and IPoIB Pkey child
interfaces are not supported with IPoIB offloads mode, this series will add
the support for that by allowing creating mlx5 multiple IPoIB netdevices with
a non-default Pkey.

mlx5 IPoIB Pkey child interface is smaller version of mlx5i IPoIB interfaces and shares
most of its resources with the parent IPoIB interface, namely RX steering and ring
queue resources.

The only mlx5 resources a child Pkey interface will be creating are the TX rings,
since they should be assigned to a specific Pkey.

mlx5i Pkey netdev is implemented via new mlx5e netdev profile implemented in
mlx5/core/ipoib/ipoib_vlan.c.

The series starts with a refactoring of mlx5e PTP and mlx5 clock implementation
to move the code to be part of mlx5 core rather than mlx5e netdevice, in order to
make mlx5 clock and PTP registration part of the core to be shared with mlx5e
master Ethernet netdev/IPoIB parent netdev and mlx5_ib in the near future.

Add the support for attaching multiple underlay QPs for the different Pkeys
in mlx5 core RX steering.

Add Pkey index to rdma_netdev to add the ability to set PKEY index to lower
IPoIB offload netdev.

Use hash-table to map between DQPN (Destination QP number) to child netdev
for the IPoIB parent netdev to forward RX packets to the corresponding
child Pkey netdev, since the RX rings are shared.

The reset of the series adds the ipoib child Pkey: mlx5e netdev profile,
netdev nods implementation and minimal set of ethtool callbacks.

Thanks,
Saeed.

----------------------------------------------------------------
Alex Vesker (10):
      net/mlx5e: IPoIB, Move underlay QP init/uninit to separate functions
      net/mlx5: Support for attaching multiple underlay QPs to root flow table
      IB/ipoib: Grab rtnl lock on heavy flush when calling ndo_open/stop
      IB/ipoib: Add ability to set PKEY index to lower device driver
      net/mlx5e: IPoIB, Support for setting PKEY index to underlay QP
      net/mlx5e: IPoIB, Use hash-table to map between QPN to child netdev
      net/mlx5e: IPoIB, Add PKEY child interface nic profile
      net/mlx5e: IPoIB, Add PKEY child interface ndos
      net/mlx5e: IPoIB, Add PKEY child interface ethtool ops
      net/mlx5e: IPoIB, Modify rdma netdev allocate and free to support PKEY

Feras Daoud (2):
      net/mlx5: File renaming towards ptp core implementation
      net/mlx5: PTP code migration to driver core section

 drivers/infiniband/ulp/ipoib/ipoib_ib.c            |  15 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  39 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 619 ---------------------
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   1 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  95 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  37 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 123 +++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   7 +-
 .../ethernet/mellanox/mlx5/core/ipoib/ethtool.c    |   5 +
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  | 260 ++++++---
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h  |  36 ++
 .../ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c | 350 ++++++++++++
 .../net/ethernet/mellanox/mlx5/core/lib/clock.c    | 525 +++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/lib/clock.h    |  51 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   4 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 +
 include/linux/mlx5/driver.h                        |  24 +
 24 files changed, 1437 insertions(+), 796 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/clock.h
