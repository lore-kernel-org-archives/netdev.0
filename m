From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next V2 00/10][pull request] Mellanox 100G mlx5 4K UAR support
Date: Sun,  8 Jan 2017 17:54:41 +0200
Message-ID: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug,

Following the mlx5-odp submission, you can find here the 2nd mlx5
submission for 4.11 as a pull-request including mlx5 4K UAR support from
Eli Cohen (details below).  For you Doug, this pull request will provide 
you with both mlx5 odp and mlx5 4k UAR since it is based on Dave's
net-next mlx5-odp merge commit.

v1->v2:
  - Removed 64BIT arch dependency.

Thank you,
Saeed.

---

The following changes since commit 525dfa2cdce4f5ab76251b5e57ebabf4f2dfc40c:

  Merge branch 'mlx5-odp' (2017-01-02 15:51:21 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git tags/mlx5-4kuar-for-4.11

for you to fetch changes up to ca704520bd370758aec9d70afeeecc9d643fe132:

  net/mlx5: Activate support for 4K UARs (2017-01-08 11:21:27 +0200)

----------------------------------------------------------------
mlx5 4K UAR

The following series of patches optimizes the usage of the UAR area which is
contained within the BAR 0-1. Previous versions of the firmware and the driver
assumed each system page contains a single UAR. This patch set will query the
firmware for a new capability that if published, means that the firmware can
support UARs of fixed 4K regardless of system page size. In the case of
powerpc, where page size equals 64KB, this means we can utilize 16 UARs per
system page. Since user space processes by default consume eight UARs per
context this means that with this change a process will need a single system
page to fulfill that requirement and in fact make use of more UARs which is
better in terms of performance.

In addition to optimizing user-space processes, we introduce an allocator
that can be used by kernel consumers to allocate blue flame registers
(which are areas within a UAR that are used to write doorbells). This provides
further optimization on using the UAR area since the Ethernet driver makes
use of a single blue flame register per system page and now it will use two
blue flame registers per 4K.

The series also makes changes to naming conventions and now the terms used in
the driver code match the terms used in the PRM (programmers reference manual).
Thus, what used to be called UUAR (micro UAR) is now called BFREG (blue flame
register).

In order to support compatibility between different versions of
library/driver/firmware, the library has now means to notify the kernel driver
that it supports the new scheme and the kernel can notify the library if it
supports this extension. So mixed versions of libraries can run concurrently
without any issues.

Thanks,
        Eli and Matan

----------------------------------------------------------------
Eli Cohen (10):
      IB/mlx5: Fix kernel to user leak prevention logic
      IB/mlx5: Fix error handling order in create_kernel_qp
      mlx5: Fix naming convention with respect to UARs
      IB/mlx5: Fix retrieval of index to first hi class bfreg
      net/mlx5: Introduce blue flame register allocator
      net/mlx5: Add interface to get reference to a UAR
      IB/mlx5: Use blue flame register allocator in mlx5_ib
      IB/mlx5: Allow future extension of libmlx5 input data
      IB/mlx5: Support 4k UAR for libmlx5
      net/mlx5: Activate support for 4K UARs

 drivers/infiniband/hw/mlx5/cq.c                    |  10 +-
 drivers/infiniband/hw/mlx5/main.c                  | 278 ++++++++++------
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  32 +-
 drivers/infiniband/hw/mlx5/qp.c                    | 290 +++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  11 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  21 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  26 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      | 351 +++++++++++++--------
 include/linux/mlx5/cq.h                            |   5 +-
 include/linux/mlx5/device.h                        |  23 +-
 include/linux/mlx5/doorbell.h                      |   6 +-
 include/linux/mlx5/driver.h                        |  81 ++---
 include/linux/mlx5/mlx5_ifc.h                      |   7 +-
 include/uapi/rdma/mlx5-abi.h                       |  19 +-
 17 files changed, 672 insertions(+), 516 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
