From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 00/11] Mellanox mlx5 core and ODP updates 2017-01-01
Date: Sun,  1 Jan 2017 23:10:16 +0200
Message-ID: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42836 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932485AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and Doug,

The following eleven patches mainly come from Artemy Kovalyov
who expanded mlx5 on-demand-paging (ODP) support. In addition
there are three cleanup patches which don't change any functionality,
but are needed to align codebase prior accepting other patches.

Memory region (MR) in IB can be huge and ODP (on-demand paging)
technique allows to use unpinned memory, which can be consumed and
released on demand. This allows to applications do not pin down
the underlying physical pages of the address space, and save from them
need to track the validity of the mappings.

Rather, the HCA requests the latest translations from the OS when pages
are not present, and the OS invalidates translations which are no longer
valid due to either non-present pages or mapping changes.

In existing ODP implementation applications is needed to register
memory buffers for communication, though registered memory regions
need not have valid mappings at registration time.

This patch set performs the following steps to expand
current ODP implementation:

1. It refactors UMR to support large regions, by introducing generic
   function to perform HCA translation table modifications. This
   function supports both atomic and process contexts and is not limited
   by number of modified entries.

   This function allows to enable reallocated memory regions of
   arbitrary size, so adding MR cache buckets to support up to 16GB MRs.

2. It changes page fault event format and refactor page faults logic
   together with addition of atomic support.

3. It prepares mlx5 core code to support implicit registration with
   simplified and relaxed semantics.

   Implicit ODP semantics allows to applications provide special memory
   key that represents their complete address space. Thus all IO accesses
   referencing to this key (with proper access rights associated with the key)
   wouldn't need not register any virtual address range.

Thanks,
        Artemy, Ilya and Leon

The following changes since commit 7ce7d89f48834cefece7804d38fc5d85382edf77
    Linux 4.10-rc1

are available in the git repository at:
    git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-odp-for-4.11

for you to fetch changes up to 4ca4c0713ca3097f1be94355d9a36bd1fc7243a2
    IB/mlx5: Improve MR check

Regards,
Saeed.

Artemy Kovalyov (8):
  net/mlx5: Support new MR features
  IB/mlx5: Refactor UMR post send format
  IB/mlx5: Add support for big MRs
  IB/mlx5: Add MR cache for large UMR regions
  net/mlx5: Update PAGE_FAULT_RESUME layout
  {net,IB}/mlx5: Refactor page fault handling
  IB/mlx5: Add ODP atomics support
  IB/mlx5: Improve MR check

Binoy Jayan (1):
  IB/mlx5: Add helper mlx5_ib_post_send_wait

Leon Romanovsky (1):
  IB/mlx5: Reorder code in query device command

Max Gurtovoy (1):
  net/mlx5: Fix offset naming for reserved fields in hca_cap_bits

 drivers/infiniband/hw/mlx5/main.c                  |  50 +-
 drivers/infiniband/hw/mlx5/mem.c                   |  32 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  89 ++--
 drivers/infiniband/hw/mlx5/mr.c                    | 518 ++++++++-------------
 drivers/infiniband/hw/mlx5/odp.c                   | 424 ++++++++---------
 drivers/infiniband/hw/mlx5/qp.c                    | 154 ++----
 drivers/net/ethernet/mellanox/mlx5/core/dev.c      |  33 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       | 290 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  41 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       | 114 -----
 include/linux/mlx5/device.h                        |   6 +-
 include/linux/mlx5/driver.h                        | 105 ++++-
 include/linux/mlx5/mlx5_ifc.h                      |  31 +-
 include/linux/mlx5/qp.h                            |  76 ++-
 16 files changed, 1000 insertions(+), 967 deletions(-)

-- 
2.7.4
