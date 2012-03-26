From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V2 0/7] net/mlx4_en: DCB QoS support
Date: Mon, 26 Mar 2012 11:07:47 +0200
Message-ID: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:36412 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753254Ab2CZJIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 05:08:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBX version 802.1qaz is supported.
User Priority (UP) is set in QP context instead of in WQE (QP Work Queue
Element), which means that all traffic from a queue will have the same UP.
UP is also set for untagged traffic to be able to classify such traffic too.

Mapping from sk_prio to User Priority is done by sch_mqprio mapping. Although
confusingly sch_mqprio maps sk_prio to something called TC, it is not related
to DCBX's TC, and is interpreted by mlx4_en driver as UP.

CC: John Fastabend <john.r.fastabend@intel.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

---
Changes from V1:
- Patch 1/7 - Force user priority by QP attribute
  - removed unneeded comment
- Patch 2/7 - set port QoS attributes
  - ratelimit is given in Mbps instead of 100Mbps units.
- Patch 3/7 - DCB QoS support
  - Split mlx4_en_config_port_scheduler from mlx4_en_dcbnl_ieee_setets - enable
    setting ratelimit only, without setting up to tc mapping
- Patch 4/7 - Set max rate-limit for a TC
  - Rewritten patch according to comment from Eric D.
  - setting ratelimit is through sysfs files:
    /sys/class/net/<intf>/ratelimit/tc0
    /sys/class/net/<intf>/ratelimit/tc1
    ...
    /sys/class/net/<intf>/ratelimit/tc7
- Patch 5/7 - sk_prio <=> UP for untagged traffic  
  - Using skb_tx_hash for queue selection of untagged traffic
- Added Patch 6/7 - export symbol ip_tos2prio
  - Fixed patch according to comment from Eric D.
- Patch 7/7 - TOS <=> UP mapping for IBoE
  - No need to clone code from route.c anymore - removed it
    
Changes from V0:
- Removed patches 6 and 7 who deal with the interaction between the kernel HW
  QoS constructs to the queue selection logic are still under discussion with
  John and some changes might be needed there.

Amir Vadai (7):
  net/mlx4_en: Force user priority by QP attribute
  net/mlx4_core: set port QoS attributes
  net/mlx4_en: DCB QoS support
  net/mlx4_en: Set max rate-limit for a TC
  net/mlx4_en: sk_prio <=> UP for untagged traffic
  net/route: export symbol ip_tos2prio
  IB/rdma_cm: TOS <=> UP mapping for IBoE

 drivers/infiniband/core/cma.c                     |    6 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig        |   12 ++
 drivers/net/ethernet/mellanox/mlx4/Makefile       |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c    |  212 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   50 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.h      |    2 +
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c     |   99 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   10 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |   21 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   40 ++++-
 drivers/net/ethernet/mellanox/mlx4/port.c         |   64 ++++++
 include/linux/mlx4/cmd.h                          |    4 +
 include/linux/mlx4/device.h                       |    3 +
 include/linux/mlx4/qp.h                           |    3 +-
 net/ipv4/route.c                                  |    2 +-
 18 files changed, 523 insertions(+), 18 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_sysfs.c

-- 
1.7.8.2
