From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/18] mlx5 RoCE/RDMA packet sniffer
Date: Fri, 17 Jun 2016 17:43:41 +0300
Message-ID: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57386 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754070AbcFQOrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set introduces mlx5 RoCE/RDMA packet sniffer, it allows
mlx5e netdevice to receive RoCE/RDMA or RAW ETH traffic which isn't
supposed to be passed to the kernel stack, for sniffing and diagnostics
purposes.  This traffic is still not supposed to go through the whole 
network stack processing and should only go to the non-protocol specific 
handlers (ptype_all). e.g: tcpdump, etc ..

In order to achieve this, when RoCE/RDMA sniffer is enabled, all RoCE/RDMA
steering rules which are forwarded to user space QPs will be duplicated
and marked with "OFFLOAD" flow tag, then forwarded to mlx5e netdevice receive path.
mlx5e receive path will detect sniffer packets by looking at the receive
completion flow tag, and in case it matches the "OFFLOAD" tag, skb->pkt_type is
set to (PACKET_OFFLOAD_KERNEL) so it will go to non-protocol specific handlers
(ptype_all) only.

To duplicate specific steering rules, a new notification mechanism is added.
It allows a consumer to request add/del rule notification on specific steering
namespaces.  Once a consumer registers, it will be notified on all existing rules.
Asynchronously, notifications on a dynamically added/deleted rules will be generated.

To achieve RoCE/RDMA sniffer, a new steering namespace is introduced (SNIFFER_NAMESPACE),
which will host all the duplicated steering rules to be forwarded to mlx5e netdevice
receive path.

RoCE sniffer module:
RoCE sniffer module will register to (RoCE/RDMA) user space traffic steering namespaces add/del
rules notification.
    - On rule add it will generated an identical rule and inject it into the SNIFFER_NAMESPACE 
	flow table with flow tag = "OFFLOAD" and destination = "mlx5e netdevice"
    - On rule delete it will remove the duplicated corresponding sniffer rule.

Thanks,
Saeed.

Huy Nguyen (3):
  net/mlx5e: Set sniffer skbs packet type to offload kernel
  net/mlx5e: Sniffer support for kernel offload (RoCE) traffic
  net/mlx5e: Add netdev hw feature flag offload-sniffer

Maor Gottlieb (15):
  net/mlx5: Refactor mlx5_add_flow_rule
  net/mlx5: Introduce mlx5_flow_steering structure
  net/mlx5: Properly remove all steering objects
  net/mlx5: Add hold/put rules refcount API
  net/mlx5: Add support to add/del flow rule notifiers
  net/mlx5: Introduce table of function pointer steering commands
  net/mlx5: Introduce nop steering commands
  if_ether.h: Add RoCE Ethertype
  IB/mlx5: Create RoCE root namespace
  net/mlx5: Introduce get flow rule match API
  net/mlx5: Add sniffer namespaces
  IB/mlx5: Add kernel offload flow-tag
  net: Add offload kernel net stack packet type
  net/mlx5: Introduce sniffer steering hardware capabilities
  net/mlx5e: Lock device state in set features

 drivers/infiniband/hw/mlx4/qp.c                    |   6 +-
 drivers/infiniband/hw/mlx5/main.c                  | 143 +++-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  15 +-
 drivers/infiniband/hw/ocrdma/ocrdma_ah.c           |   4 +-
 drivers/infiniband/hw/ocrdma/ocrdma_hw.c           |   2 +-
 drivers/infiniband/hw/ocrdma/ocrdma_sli.h          |   4 -
 drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h |   1 -
 drivers/infiniband/hw/usnic/usnic_fwd.h            |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  26 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  28 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  44 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   4 +
 .../net/ethernet/mellanox/mlx5/core/en_sniffer.c   | 574 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  51 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 161 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  71 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 746 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  31 +
 include/linux/mlx5/device.h                        |  17 +
 include/linux/mlx5/driver.h                        |   6 +-
 include/linux/mlx5/fs.h                            |  62 +-
 include/linux/netdev_features.h                    |   2 +
 include/linux/skbuff.h                             |   6 +-
 include/uapi/linux/if_ether.h                      |   1 +
 include/uapi/linux/if_packet.h                     |   1 +
 net/core/dev.c                                     |   4 +
 net/core/ethtool.c                                 |   1 +
 30 files changed, 1626 insertions(+), 408 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_sniffer.c

-- 
2.8.0
