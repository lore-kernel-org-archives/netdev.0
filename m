From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/13] Mellanox 100G mlx5 driver receive path optimizations
Date: Fri, 11 Mar 2016 15:39:41 +0200
Message-ID: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33137 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753190AbcCKNk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:40:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This series includes Some RX modifications and optimizations for
the mlx5 Ethernet driver. 

>From Rana, we have one patch that adds the support for Connectx-4
queue counters.

>From Tariq, several patches that are centralized around improving
RX path message rate, CPU and Memory utilization, in each patch
commit message you will find the performance improvements numbers
related to that specific patch.

In the 3rd patch we used a queue counter to report "out of buffer" 
dropped packet count, "Dropped packets due to lack of software resources"

4th patch modifies the driver's to RSS default value to be spread along the
close NUMA node cores only for better out of the box experience.

In the 5th and 6th patches we utilized the use of RX multi-packet WQE
(Striding RQ) for better memory utilization especially in case of hardware
LRO is enabled and for better message rate for small packets.

In the 7th and 8th patches we added a fallback mechanism to use fragmented
memory when allocating large WQE strides fails, using UMR
(User Memory Registration) and ICO (Internal Control Operations) SQs.

In 9th patch To reduce the interrupt count we change the RX moderation
period to be based on the last generated CQE rather than the last generated
interrupt.

In the 10th to 13th patches we did some small modification which show some small
extra improvements.

Note: The patch from Matan "net/mlx5: Refactor mlx5_core_mr to mkey"
included in this series is already submitted and applied into Doug Ledford's 
rdma tree a606b0f6691d ("net/mlx5: Refactor mlx5_core_mr to mkey").

This series is generated against net-next commit e8ab563f4b2e ("Merge branch 'flower-offload'")

Thanks,
Saeed

Matan Barak (1):
  net/mlx5: Refactor mlx5_core_mr to mkey

Rana Shahout (1):
  net/mlx5e: Allocate set of queue counters per netdev

Tariq Toukan (11):
  net/mlx5: Introduce device queue counters
  net/mlx5e: Use only close NUMA node for default RSS
  net/mlx5e: Use function pointers for RX data path handling
  net/mlx5e: Support RX multi-packet WQE (Striding RQ)
  net/mlx5e: Added ICO SQs
  net/mlx5e: Add fragmented memory support for RX multi packet WQE
  net/mlx5e: Change RX moderation period to be based on CQE
  net/mlx5e: Use napi_alloc_skb for RX SKB allocations
  net/mlx5e: Prefetch next RX CQE
  net/mlx5e: Remove redundant barrier
  net/mlx5e: Add ethtool counter for RX SKB allocation failures

 drivers/infiniband/hw/mlx5/cq.c                    |   16 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    6 +-
 drivers/infiniband/hw/mlx5/mr.c                    |   50 +-
 drivers/infiniband/hw/mlx5/odp.c                   |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  196 +++++++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   28 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  386 +++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  498 ++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   59 +++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |   54 ++-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   68 +++
 include/linux/mlx5/device.h                        |   39 ++-
 include/linux/mlx5/driver.h                        |   24 +-
 include/linux/mlx5/mlx5_ifc.h                      |   32 +-
 include/linux/mlx5/qp.h                            |   10 +-
 17 files changed, 1263 insertions(+), 225 deletions(-)
