From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/12] Mellanox mlx5e XDP performance optimization
Date: Sat, 25 Mar 2017 00:52:02 +0300
Message-ID: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35711 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936474AbdCXVw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides some preformancee optimizations for mlx5e
driver, especially for XDP TX flows.

1st patch is a simple change of rmb to dma_rmb in CQE fetch routine
which shows a huge gain for both RX and TX packet rates.

2nd patch removes write combining logic from the driver TX handler
and simplifies the TX logic while improving TX CPU utilization.

All other patches combined provide some refactoring to the driver TX
flows to allow some significant XDP TX improvements.

More details and performance numbers per patch can be found in each patch
commit message compared to the preceding patch.

Overall performance improvemnets
  System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz
    
Test case                   Baseline      Now      improvement
---------------------------------------------------------------
TX packets (24 threads)     45Mpps        54Mpps      20%
TC stack Drop (1 core)      3.45Mpps      3.6Mpps     5%
XDP Drop      (1 core)      14Mpps        16.9Mpps    20%
XDP TX        (1 core)      10.4Mpps      13.7Mpps    31%

Thanks,
Saeed.

Saeed Mahameed (12):
  net/mlx5e: Use dma_rmb rather than rmb in CQE fetch routine
  net/mlx5e: Xmit, no write combining
  net/mlx5e: Single bfreg (UAR) for all mlx5e SQs and netdevs
  net/mlx5e: Move XDP completion functions to rx file
  net/mlx5e: Move mlx5e_rq struct declaration
  net/mlx5e: Move XDP SQ instance into RQ
  net/mlx5e: Poll XDP TX CQ before RX CQ
  net/mlx5e: Optimize XDP frame xmit
  net/mlx5e: Generalize tx helper functions for different SQ types
  net/mlx5e: Proper names for SQ/RQ/CQ functions
  net/mlx5e: Generalize SQ create/modify/destroy functions
  net/mlx5e: Different SQ types

 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 319 +++++-----
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 644 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 124 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 147 +----
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  70 +--
 include/linux/mlx5/driver.h                        |   1 +
 7 files changed, 716 insertions(+), 598 deletions(-)

-- 
2.11.0
