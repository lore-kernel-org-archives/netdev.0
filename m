From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V3 00/11] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Sun, 10 May 2015 12:38:55 +0300
Message-ID: <1431250746-11941-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:44828 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752323AbbEJJkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 05:40:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset extends the mlx5_core driver to support Ethernet
functionality. The Ethernet functionality in the mlx5 driver is
integrated into the core driver and not as separated driver. The
IB functionality remains in the mlx5_ib driver as before.

This functionality will enable the Ethernet capability of Mellanox's new
famility of cards - ConnectX-4. Due to the fact that backword
compatability is being kept, existing Connect-IB cards that are using
this driver are fully working with the modified driver, and no issues
with current deployments should be seen.

Like the ConnectX-3 cards, ConnectX-4 is a VPI (Virtual Port Interface -
every port can be configured as Infiniband or Ethernet) card.
Unlike previous generations, the ConnectX-4 has a separate PCI function
per port.

The current code has a limitation that Infiniband and Ethernet port types
are mutually exclusive. When the driver is compiled with Ethernet
support, the Infiniband functionality is disabled and vice versa. To
control that we added the CONFIG_MLX5_CORE_EN config directive
which is 'n' by default, but can be changed by the user.

This limitation is short-lived and would be addressed soon.

As part of this patchset, mlx5_ifc.h was heavily modified [1]. This file
is now generated automatically from the device specification document.
Since this patch is too big for the mail server, it might be missing in
the mailing list, but could be pulled from an external git repository [2].

Patchset was applied and tested on top of commit 239fb79 ("vxlan: Correctly set
flow*i_mark and flow4i_proto in route lookups")

[1] - Patch 4/11 ("net/mlx5_core: HW data structs/types definitions preparation for mlx5 ehternet driver")
[2] - http://git.openfabrics.org/?p=~amirv/linux.git;a=shortlog;h=refs/heads/mlx5e_v1

Thanks to Achiad, Saeed, Yevheny, Or and the whole team for making this happen,
Amir

Changes from V2:
- Improved changelogs and cover-letter
- Added CONFIG_MLX5_EN to disable/enable the Ethernet functionality
- Moved en.h and wq.[ch] into the patch with data-path related code

Changes from V1:
- Added patch 1/12 ("net/mlx5_core,mlx5_ib: Do not use vmap() on coherent
  memory")

Changes from V0:
- Removed V0 Patch 1/11 ("net/mlx5_core: Virtually extend work/completion queue
  buffers by one page") due to misuse of DMA API. Thanks Dave.
- Patch 1/11 ("net/mlx5_core: Set irq affinity hints"):
  - Use kcalloc instead of kzalloc
  - Fix build error when CONFIG_CPUMASK_OFFSTACK=n. Driver loading will fail
    now if cpumask allocation is failing.
  - Using dev_to_node helper. Thanks, Ido.
- Patch 3/11 ("net/mlx5_core: HW data structs/types definitions preparation for
  mlx5 ehternet driver")
  - Removed Mellanox internal comment at the head of the file. Thanks Joe
- Patch 6/11 ("net/mlx5_core: Implement get/set port status")
  - Use direct return of function's result. Thanks Sergei.
- Added Patch 8/11 ("net/mlx5_core: Set/Query port MTU commands")
- Patch 9/11 ("net/mlx5: Ethernet Datapath files")
  - Use rq->wqe_sz instead of skb_end_offset. Thanks Ido.
  - Use dma_wmb() when possible instead of wmb(). Thanks Alex.
  - Fix checkpatch issues
- Patch 10/11 ("net/mlx5: ethernet resources handling")
  - checkpatch issues
  - Added missing include
- Patch 11/11 ("net/mlx5: Ethernet driver")
  - checkpatch issues
  - fixed typo
  - Modified use of affinity hint
  - Using dev_to_node helper. Thanks, Ido.
  - Use new hardware commands from Patch 8/11 ("net/mlx5_core: Set/Query port
    MTU commands") to get/set port MTU in hardware.
  - Removed NETIF_F_SG since hardware ring wraparound is not supported
  - Use dma_wmb() when possible instead of wmb(). Thanks Alex.

Amir Vadai (3):
  net/mlx5: Ethernet Datapath files
  net/mlx5: Ethernet resource handling files
  net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet
    functionality

Rana Shahout (2):
  net/mlx5_core: Implement get/set port status
  net/mlx5_core: Modify CQ moderation parameters

Saeed Mahameed (6):
  net/mlx5_core: Set irq affinity hints
  net/mlx5_core: Add EQ renaming mechanism
  net/mlx5_core: HW data structs/types definitions cleanup
  net/mlx5_core: New device capabilities handling
  net/mlx5_core: Implement access functions of ptys register fields
  net/mlx5_core: Set/Query port MTU commands

 drivers/infiniband/hw/mlx5/Kconfig                 |    4 +-
 drivers/infiniband/hw/mlx5/cq.c                    |    8 +-
 drivers/infiniband/hw/mlx5/mad.c                   |    2 +-
 drivers/infiniband/hw/mlx5/main.c                  |  113 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    6 +-
 drivers/infiniband/hw/mlx5/mr.c                    |    3 +-
 drivers/infiniband/hw/mlx5/odp.c                   |   47 +-
 drivers/infiniband/hw/mlx5/qp.c                    |   84 +-
 drivers/infiniband/hw/mlx5/srq.c                   |    7 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   14 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   36 +-
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  520 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  679 ++
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |  858 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1915 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  249 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  344 +
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  107 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   20 +-
 .../net/ethernet/mellanox/mlx5/core/flow_table.c   |  422 ++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   90 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  365 +-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |    2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   20 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  165 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  169 +
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   47 +
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   44 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |   84 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.h    |   41 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |  189 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |  171 +
 include/linux/mlx5/cq.h                            |    3 +
 include/linux/mlx5/device.h                        |  198 +-
 include/linux/mlx5/driver.h                        |  100 +-
 include/linux/mlx5/flow_table.h                    |   54 +
 include/linux/mlx5/mlx5_ifc.h                      | 6608 +++++++++++++++++++-
 include/linux/mlx5/qp.h                            |   25 +
 40 files changed, 13328 insertions(+), 506 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.h
 create mode 100644 include/linux/mlx5/flow_table.h

-- 
1.9.3
