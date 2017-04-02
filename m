From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 0/6] Automatic affinity settings for nvme over rdma
Date: Sun,  2 Apr 2017 16:41:26 +0300
Message-ID: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:57253 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdDBNlt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 09:41:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is aiming to automatically find the optimal
queue <-> irq multi-queue assignments in storage ULPs (demonstrated
on nvme-rdma) based on the underlying rdma device irq affinity
settings.

First two patches modify mlx5 core driver to use generic API
to allocate array of irq vectors with automatic affinity
settings instead of open-coding exactly what it does (and
slightly worse).

Then, in order to obtain an affinity map for a given completion
vector, we expose a new RDMA core API, and implement it in mlx5.

The third part is addition of a rdma-based queue mapping helper
to blk-mq that maps the tagset hctx's according to the device
affinity mappings.

I'd happily convert some more drivers, but I'll need volunteers
to test as I don't have access to any other devices.

I cc'd @netdev (and Saeed + Or) as this is the place that most of
mlx5 core action takes place, so Saeed, would love to hear your
feedback.

Any feedback is welcome.

Sagi Grimberg (6):
  mlx5: convert to generic pci_alloc_irq_vectors
  mlx5: move affinity hints assignments to generic code
  RDMA/core: expose affinity mappings per completion vector
  mlx5: support ->get_vector_affinity
  block: Add rdma affinity based queue mapping helper
  nvme-rdma: use intelligent affinity based queue mappings

 block/Kconfig                                      |   5 +
 block/Makefile                                     |   1 +
 block/blk-mq-rdma.c                                |  56 +++++++++++
 drivers/infiniband/hw/mlx5/main.c                  |  10 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 106 +++------------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 -
 drivers/nvme/host/rdma.c                           |  13 +++
 include/linux/blk-mq-rdma.h                        |  10 ++
 include/linux/mlx5/driver.h                        |   2 -
 include/rdma/ib_verbs.h                            |  24 +++++
 14 files changed, 138 insertions(+), 108 deletions(-)
 create mode 100644 block/blk-mq-rdma.c
 create mode 100644 include/linux/blk-mq-rdma.h

-- 
2.7.4
