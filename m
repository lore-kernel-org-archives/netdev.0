From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH 0/8] net/mlx4_en: DCB QoS support
Date: Tue, 13 Mar 2012 19:21:55 +0200
Message-ID: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:32888 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758545Ab2CMRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:22:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBX version 802.1qaz is supported.
User Priority (UP) is set in QP context instead of in WQE (QP Work Queue
Element), which means that all traffic from a queue will have the same UP.
UP is also set for untagged traffic to be able to classify such traffic too.

Mapping from sk_prio to User Priority is done by sch_mqprio mapping. Although
confusingly sch_mqprio maps sk_prio to something called TC, it is not related
to DCBX's TC, and is interpreted by mlx4_en driver as UP.

The Current HW based QoS mechanism which was introduced in commit 4f57c087de9
"net: implement mechanism for HW based QOS" is in orientation to ETS traffic
class. Patch 7/8 introduces an approach which allow to use this mechanism also
with hardware who has queues per user priority (UP). After the change,
__skb_tx_hash() will direct a flow to a tx ring from a range of tx rings. This
range is defined by the caller function by the specific HW. If TC based queues,
the range is by TC number and for UP based queues, the range is by UP. 

Amir Vadai (8):
  net/mlx4_en: Force user priority by QP attribute
  net/mlx4_core: set port QoS attributes
  net/mlx4_en: DCB QoS support
  net/mlx4_en: Set max rate-limit for a TC
  net/mlx4_en: sk_prio <=> UP for untagged traffic
  IB/rdma_cm: TOS <=> UP mapping for IBoE
  net: support tx_ring per UP in HW based QoS mechanism
  net/mlx4_en: num cores tx rings for every UP

 drivers/infiniband/core/cma.c                     |   35 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |   11 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig        |   12 ++
 drivers/net/ethernet/mellanox/mlx4/Makefile       |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c    |  215 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   64 ++++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.h      |    2 +
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c     |  120 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   20 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |   20 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   38 +++-
 drivers/net/ethernet/mellanox/mlx4/port.c         |   62 ++++++
 include/linux/mlx4/cmd.h                          |    4 +
 include/linux/mlx4/device.h                       |    3 +
 include/linux/mlx4/qp.h                           |    3 +-
 include/linux/netdevice.h                         |   12 +-
 include/linux/skbuff.h                            |    3 +-
 net/core/dev.c                                    |   10 +-
 21 files changed, 615 insertions(+), 36 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c

-- 
1.7.8.2
