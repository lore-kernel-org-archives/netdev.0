From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V0 00/21] net/mlx4: SRIOV support
Date: Fri, 2 Dec 2011 12:16:20 +0200
Message-ID: <4ED8A574.30408@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello David,

This patch set adds SRIOV support for ConnectX2 and ConnectX3 HW for Ethernet Link layer.
Infiniband and RoCE SRIOV support will be added at later stage

In ConnectX, nearly all device resources can be associated with any function.
Once allocated, these resources can be manipulated exclusively by their
associated functions in the same manner as in the single-function case.
The same driver acts both as pf and vf driver.
mlx4_en module (Ethernet specific code) remains virtualization unaware and all the multifunction logic is
implemented in mlx4_core module.
To keep that separation, some code (mainly port management) moved from mlx4_en to mlx4_core module.

The device continues to use a single HCA Command Register (HCR), which is owned by the pf.
Thus, the pf is given the role of allocating resources to vfs, and controlling shared resource (such as ports).

A dedicated HW communication channel is used to transfer resource allocation and
modification requests from vfs to the pf, and events from the pf to the vfs.
Consequently, no hypervisor-specific services are required for pf-vf communication.
All vfs resources are tracked by the pf and cleaned up in case the vf doesn't close gracefully.
The resource tracker also prevents untrusted vfs to manipulate resources that belong to othe functions.

mlx4_en: updated driver version to 2.0
mlx4_core: updated driver version to 1.1
mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet.
mlx4_core: adjust catas operation for SRIOV mode.
mlx4_core: mtts resources units changed to offset
mlx4_en: Allow communication between functions on same host
mlx4: Ethernet port management modifications
mlx4: Traffic steering management support for SRIOV
mlx4_ib: disable SRIOV mode for IB ports (not yet supported).
mlx4_core:  resource tracking for HCA resources used by guests.
mlx4_core: Add wrapper functions and comm channel and slave event support to EQs
mlx4_core: mtt modifications for SRIOV
mlx4_core: cq modifications for SRIOV
mlx4_core: qp modifications for SRIOV
mlx4_core: srq modifications for SRIOV
mlx4_core: Added FW commands and their wrappers for supporting SRIOV.
mlx4_core: Implement the master-slave communication channel.
mlx4_core: Reduce number of PD bits to 17.
mlx4_core:  Add "native" argument to mlx4_cmd and its callers (where needed)
mlx4: Extanding port_mask functionality
mlx4_core:  initial header-file changes for SRIOV support.

 drivers/infiniband/hw/mlx4/mad.c                      |    4
 drivers/infiniband/hw/mlx4/main.c                     |   13
 drivers/net/ethernet/mellanox/mlx4/Makefile           |    2
 drivers/net/ethernet/mellanox/mlx4/catas.c            |    7
 drivers/net/ethernet/mellanox/mlx4/cmd.c              | 1301 +++++++
 drivers/net/ethernet/mellanox/mlx4/cq.c               |  140
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |   32
 drivers/net/ethernet/mellanox/mlx4/en_port.c          |   81
 drivers/net/ethernet/mellanox/mlx4/en_port.h          |   43
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |   15
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c      |    2
 drivers/net/ethernet/mellanox/mlx4/en_tx.c            |   20
 drivers/net/ethernet/mellanox/mlx4/eq.c               |  426 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c               |  389 ++
 drivers/net/ethernet/mellanox/mlx4/fw.h               |   25
 drivers/net/ethernet/mellanox/mlx4/icm.c              |    5
 drivers/net/ethernet/mellanox/mlx4/intf.c             |    6
 drivers/net/ethernet/mellanox/mlx4/main.c             |  869 ++++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c              |  224 -
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |  670 +++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h          |    4
 drivers/net/ethernet/mellanox/mlx4/mr.c               |  483 ++
 drivers/net/ethernet/mellanox/mlx4/pd.c               |   19
 drivers/net/ethernet/mellanox/mlx4/port.c             |  610 ++-
 drivers/net/ethernet/mellanox/mlx4/profile.c          |    9
 drivers/net/ethernet/mellanox/mlx4/qp.c               |  236 +
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 3125 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/sense.c            |    2
 drivers/net/ethernet/mellanox/mlx4/srq.c              |  144
 include/linux/mlx4/cmd.h                              |   46
 include/linux/mlx4/device.h                           |   72
 31 files changed, 8097 insertions(+), 927 deletions(-)



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
