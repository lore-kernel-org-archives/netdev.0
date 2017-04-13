From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 00/16] Mellanox, mlx5 RDMA net device support
Date: Thu, 13 Apr 2017 06:36:50 +0300
Message-ID: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug.

This series provides the lower level mlx5 support of RDMA netdevice
creation API [1] suggested and introduced by Intel's HFI OPA VNIC
netdevice driver [2], to enable IPoIB mlx5 RDMA netdevice creation.

mlx5 IPoIB RDMA netdev will serve as an acceleration netdevice for the current
IPoIB ULP generic netdevice, providing:
	- mlx5 RSS support.
	- mlx5 HW RX,TX offloads (checksum, TSO, LRO, etc ..).
	- Full mlx5 HW features transparent to the ULP itself.

The idea here is to reuse and benefit from the already implemented mlx5e netdevice
management and channels API for both etherent and RDMA netdevices, since both IPoIB
and Ethernet netdevices share same common mlx5 HW resources (with some small
exceptions) and share most of the control/data path logic, it is more natural to
have them share the same code.

The differences between IPoIB and Ethernet netdevices can be summarized to:

Steering:
In mlx5, IPoIB traffic is sent and received from an underlay special QP, and in Ethernet
the traffic is handled by vports and vport steering is managed by e-switch or FW.

For IPoIB traffic to get steered correctly the only thing we need to do is to create RSS
HW contexts for RX and TX HW contexts for TX (similar to mlx5e) with the underlay QP attached to
them (underlay QP will be 0 in case of Ethernet).

RX,TX:
Since IPoIB traffic is different, slightly modified RX and TX handlers are required,
still we do some code reuse in data path via common helper functions.

All of the other generic netdevice and mlx5 aspects will be shared between mlx5 Ethernet
and IPoIB netdevices, e.g.
	- Channels creation and handling (RQs,SQs,CQs, NAPI, interrupt moderation, etc..)
	- Offloads, checksum, GRO, LRO, TSO, and more.
        - netdevice logic and non Ethernet specific ndos (open/close, etc..)

In order to achieve what we want:

In patchet 1 to 3, Erez added the supported for underlay QP in mlx5_ifc and refactored 
the mlx5 steering code to accept the underlay QP as a parameter for creating steering
objects and enabled flow steering for IB link.

Then we are going to use the mlx5e netdevice profile, which is already used to separate between
NIC and VF representors netdevices, to create new type of IPoIB netdevice profile.

For that, one small refactoring is required to make mlx5e netdevice profile management
more genetic and agnostic to link type which is done in patch #4.

In patch #5, we introduce ipoib.c to host all of mlx5 IPoIB (mlx5i) specific logic and a 
skeleton for the IPoIB mlx5 netdevice profile, and we will start filling it in next patches,
using mlx5e already existing APIs.

Patch #6 and #7, Implement init/cleanup RX mlx5i netdev profile handlers to create mlx5 RSS
resources, same as mlx5e but without vlan and L2 steering tables.

Patch #8, Implement init/cleanup TX mlx5i netdev profile handlers, to create TX resources
same as mlx5e but with one TC (tc = 0) support.

Patch #9, Implement mlx5i open/close ndos, where we reuese the mlx5e channels API, to start/stop TX/RX channels.

Patch #10, Create the underlay QP and attach it to mlx5i RSS and TX HW contexts.

Patch #11 and #12, Break down the mlx5e xmit flow into smaller helper function and implement the
mlx5i IPoIB xmit routine.

Patch #13 and #14, Have an RX handler per netdevice profile. We already do this before this series
in a non clean way to separate between NIC netdev and VF representor RX handlers, in patch 13 we make
the RX handler generic and bound to a profile and in patch 14 we implement the IPoIB RX handlers.

Patch #15, Small cleanup to avoid e-switch with IPoIB netdev. 


In order to enable mlx5 IPoIB, a merge between the IPoIB RDMA netdev offolad support [3]
- which was alread submitted to the rdma mailing list - and this series is required
plus an extra small patch [4] which will connect between both sides and actually enables the offload.

Once both patch-sets are merged into linux we will have to submit the extra small patch [4], to enable
the feature.

Thanks,
Saeed.

[1] https://patchwork.kernel.org/patch/9676637/

[2] https://lwn.net/Articles/715453/
    https://patchwork.kernel.org/patch/9587815/

[3] https://patchwork.kernel.org/patch/9672069/
[4] https://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git/commit/?id=0141db6a686e32294dee015b7d07706162ba48d8


Erez Shitrit (4):
  net/mlx5: Add IPoIB enhanced offloads bits to mlx5_ifc
  net/mlx5: Refactor create flow table method to accept underlay QP
  net/mlx5: Enable flow-steering for IB link
  hw/mlx5: Add New bit to check over QP creation

Saeed Mahameed (12):
  net/mlx5e: More generic netdev management API
  net/mlx5e: IPoIB, Add netdevice profile skeleton
  net/mlx5e: IPoIB, RX steering RSS RQTs and TIRs
  net/mlx5e: IPoIB, RSS flow steering tables
  net/mlx5e: IPoIB, TX TIS creation
  net/mlx5e: IPoIB, Basic netdev ndos open/close
  net/mlx5e: IPoIB, Underlay QP
  net/mlx5e: Xmit flow break down
  net/mlx5e: IPoIB, Xmit flow
  net/mlx5e: RX handlers per netdev profile
  net/mlx5e: IPoIB, RX handler
  net/mlx5e: E-switch vport manager is valid for ethernet only

 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  10 -
 drivers/infiniband/hw/mlx5/qp.c                    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  53 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  32 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 292 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  33 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  78 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 286 ++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   5 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  16 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   8 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  95 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    | 495 +++++++++++++++++++++
 .../ethernet/mellanox/mlx5/core/ipoib.h}           |  26 +-
 include/linux/mlx5/fs.h                            |  14 +-
 include/linux/mlx5/mlx5_ifc.h                      |  11 +-
 include/linux/mlx5/qp.h                            |  10 +
 22 files changed, 1153 insertions(+), 335 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
 copy drivers/{infiniband/hw/mlx5/cmd.h => net/ethernet/mellanox/mlx5/core/ipoib.h} (70%)

-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
