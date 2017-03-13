From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 00/25] Enhanced mode for IPoIB driver
Date: Mon, 13 Mar 2017 20:31:11 +0200
Message-ID: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49627 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752385AbdCMSb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:31:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    The IPoIB protocol encapsulates IP packets over Infiniband datagrams.
    As a direct RDMA Upper Layer Protocol (ULP), IPoIB cannot support HW
    features that are specific to the IP protocol stack.

    Nevertheless, RDMA interfaces have been extended to support some of the
    prominent IP offload features, such as TCP/UDP checksum and TSO.
    This provided reasonable performance gain for IPoIB but is still
    insufficient to cope with the increasing network bandwidth demand.

    However, New features are exisiting in common network interfaces that
    are very hard to implement in IPoIB interfaces while it uses the RDMA
    layer, examples include TSS and RSS, tunneling offloads, and XDP.
    Rather than continuously porting IP network interface developments into
    the RDMA stack, we propose adding an abstract network data-path interfaces
    to RDMA devices.

    In order to present a consistent interface to users, the IPoIB ULP
    continues to represent the network device to the IP stack.
    The common code also manages the IPoIB control plane, such as resolving
    path queries and registering to multicast groups.
    Data path operations are forwarded to devices that implement the new
    API, or fallback to the standard implementation otherwise.
    Using the forgoing approach, we show how IPoIB closes the performance
    gap compared to state-of-the-art Ethernet network interfaces.

    The implementation idea is to expose a struct that has data members and set
    of functions that are used for network interfaces, like create, delete, init hw
    resources, send, and attach/detach multicast to qp.
    That set of functions encapsulates in new struct, and this struct can or
    can't be given by the specific HW layer.

    The IPoIB code will be adapted to enable the option of accelerating the
    network interface, but the code will work as before if the HW below
    doesn't support the acceleration.
    Each HW vendor can supply the acceleration for the IPoIB or to leave
    IPoIB to work as before.

    TBD:
	1. Few functions in the API might be changed, at least send functions that is not going to use the ipoib_ah struct.
	2. Currently I used functions for init/cleanup, perhaps later it will be pushed into the ndo_ops struct.
	3. The low-level-functions will have a new design that will reduce the use of exported function from the mlx5_core layer to the ib layer.

Changes fron v0:
---------------
1. Use the vnic/hfi API as a base for the new design/impl.
2. Change the low level driver to support the new struct. 


Erez Shitrit (25):
  IB/ipoib: Separate control and data related initializations
  IB/ipoib: separate control from HW operation on ipoib_open/stop ndo
  IB/ipoib: Rename qpn to dqpn in ipoib_send and post_send functions
  IB/verb: Add ipoib_options struct and API
  IB/ipoib: Support ipoib acceleration options callbacks
  hw/mlx5: Add New bit to check over QP creation
  linux/mlx5/mlx5_ifc.h: Add underlay_qpn field to PRM objects
  net/mlx5e: Refactor EN code to support IB link
  net/mlx5e: Creating and Destroying flow-steering tables for IB link
  net/mlx5e: Support netdevice creation for IB link type
  net/mlx5e: Refactor attach_netdev API
  net/mlx5e: Use underlay_qpn in tis creation
  net/mlx5e: Export resource creation function to be used in IB link
  net/mlx5: Enable flow-steering for IB link
  net/mlx5e: Enhanced flow table creation to support ETH and IB links.
  net/mlx5e: Change cleanup API in order to enable IB link
  net/mlx5e: Change mlx5e_open_locked and mlx5e_close_locked api
  net/mlx5e: Export open/close api for IB link
  include/linux/mlx5: Add mlx5_wqe_eth_pad and enhanced-ipoib-qp-mode
  net/mlx5e: Refactor TX send flow
  net/mlx5e: Export send function for IB link type
  net/mlx5e: New function pointer for build_rx_skb is
  net/mlx5e: Change the function that checks the packet type
  net/mlx5e: Add support for build_rx_skb for packet from IB type
  mlx5_ib: skeleton for mlx5_ib to support ipoib_ops

 drivers/infiniband/hw/mlx5/Makefile                |   2 +-
 drivers/infiniband/hw/mlx5/main.c                  |  10 +
 drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c        | 289 ++++++++++++++
 drivers/infiniband/hw/mlx5/qp.c                    |   5 +-
 drivers/infiniband/ulp/ipoib/ipoib.h               |  35 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |  66 ++--
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c       |   6 +-
 drivers/infiniband/ulp/ipoib/ipoib_fs.c            |   4 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c            | 316 +++++++--------
 drivers/infiniband/ulp/ipoib/ipoib_main.c          | 299 ++++++++++----
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c     |  39 +-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c       |  12 +-
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c         |  62 +--
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c          |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  23 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  12 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  24 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  66 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 432 ++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  21 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  70 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 292 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   9 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   8 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  77 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   3 +-
 include/linux/mlx5/driver.h                        |  18 +
 include/linux/mlx5/fs.h                            |  16 +-
 include/linux/mlx5/mlx5_ifc.h                      |  11 +-
 include/linux/mlx5/qp.h                            |   8 +
 include/rdma/ib_ipoib_accel_ops.h                  |  59 +++
 include/rdma/ib_verbs.h                            |  36 ++
 34 files changed, 1720 insertions(+), 639 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/mlx5_ipoib_ops.c
 create mode 100644 include/rdma/ib_ipoib_accel_ops.h

-- 
1.8.3.1
