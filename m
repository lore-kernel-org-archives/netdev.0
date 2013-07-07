From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V3 0/9] Add Mellanox mlx5 driver for Connect-IB devices
Date: Sun,  7 Jul 2013 17:25:48 +0300
Message-ID: <1373207157-13914-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jackm@dev.mellanox.co.il,
	eli@dev.mellanox.co.il, moshel@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38402 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752447Ab3GGO0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jul 2013 10:26:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland,

Here's V3 of the mlx5 driver, with Dave's, Joe's and yours comments addressed.

Hoping that would be all for getting this into 3.11

Jack, Moshe and Or.

changes from V2:
 
- Addressed feedback from Joe Perches:
 * Added parentheses around sizeof
 * Removed unnecessary do-while for driver pr_debug envelope (done for mlx5_core.h as well)
 * Removed unneeded log output on memory allocation failures
 * Fixed some typos
 * Used snprintf instead of strcpy/strcat (safer and shorter)
 * Removed unnecessary local variable sgi from ib_create_ah()
 * Reduced vzalloc usage by trying to do kzalloc first and vzalloc only 
   if kzalloc fails

- Addressed Roland's feedback:
 * Removed unneeded "active" flag from health polling -- no need for "active" 
   flag for re-scheduling from within timer handler when using del_timer_sync.

- Also removed some calls to mlx5_ib_dbg() which had newline char only, and therefore 
  only did execution tracing.

changes from V1:

- Addreessed Dave Miller's comments:
   * Local variables in functions listed from longest to shortest
   * --i/++i changed to i--/i++ in all for-loops
   * Removed leading /* empty line from all comments
   * magic constants given names
   * endianness code moved to driver.h, and defined an endianness-dependent macro 
     for use in assignment.
   * destroy_msg_cache() duplicated code removed

- Addressed Roland's comments:

   * Renamed foo_spl to foo_lock for spinlocks.
   * Eliminated magic number from mlx5_cmd_stats field declaration in struct mlx5_cmd.
   * Eliminated unused procedure mlx5_ib_umem_populate_pas()
     command execution times, but all file-name-based mask bits removed.

   * Cleaned up mlx5_ib.h:
   * Added new patch for ib_verbs.h, adding reserved values to several enums
   * For several ib-core enums, added reserved values for use by low-level drivers. 
     By defining macros at the low level (i.e., renaming the reserved values, in effect), the 
     ll drivers may use these enums without needing to duplicate the ib-core enums while adding 
     extra values. This fixes compilation problems such as:
	/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:975:2:
        error: case value 4671 not in enumerated type enum ib_qp_type

   * Changed ib_latency_class to mlx5_ib_latency_class, visible only in low-level driver
   * Eliminated the unused IB_WR_xxx_PSV enums
   * Defined macros MLX5_IB_SEND_UMR_UNREG, MLX5_IB_QPT_REG_UMR, and MLX5_IB_WR_UMR, 
     taking advantage of the reserved values added to the ib_core enums.

   * debug-mask removed from mlx5_ib
   * Regarding mlx5_core, still have a debug mask to enable printouts of command data and 
   * Removed forced -Wall -Werror -DDEBUG settings in the mlx5 core/ib makefiles

changes from V0:
 - Per Dave's request, cross posting to both netdev and linux-rdma, to see 
   if there are comments from netdev on the core driver.

The patches that follow constitute the driver for Mellanox's 5th generation
of HCAs named Connect-IB.

The driver is comprised of two kernel modules: mlx5_ib and mlx5_core. This
partitioning resembles what we have for mlx4 with the substantial difference
that mlx5_ib is the pci device driver and not mlx5_core.

mlx5_core provides general functionality that is intended to be used by
other Mellanox devices that will be introduced in the future. In this sense,
it can be perceived as a library. mlx5_ib has a similar role as any hardware
device under drivers/infiniband/hw.

The patches are partitioned to avoid exceeding the 100KB vger.kernel.org
limitation. They are divided such that the first three ones have the code
of the mlx5_core driver, and the last five the code of the mlx5_ib driver.

Only the last patch per driver adds the Makefiles and Kconfigs, to make
things robust for future bisections.

PPC is not yet supported but support will be included in the near future.

Eli Cohen (8):
  net/mlx5: Mellanox Connect-IB, core driver part 1/3
  net/mlx5: Mellanox Connect-IB, core driver part 2/3
  net/mlx5: Mellanox Connect-IB, core driver part 3/3
  IB/mlx5: Mellanox Connect-IB, IB driver part 1/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 2/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 3/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 4/5
  IB/mlx5: Mellanox Connect-IB, IB driver part 5/5

Jack Morgenstein (1):
  IB/core: Add reserved values to enums for low-level drivers use

 MAINTAINERS                                        |   22 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/Makefile                        |    1 +
 drivers/infiniband/hw/mlx5/Kconfig                 |   10 +
 drivers/infiniband/hw/mlx5/Makefile                |    3 +
 drivers/infiniband/hw/mlx5/ah.c                    |   92 +
 drivers/infiniband/hw/mlx5/cq.c                    |  843 +++++++
 drivers/infiniband/hw/mlx5/doorbell.c              |  100 +
 drivers/infiniband/hw/mlx5/mad.c                   |  139 ++
 drivers/infiniband/hw/mlx5/main.c                  | 1504 ++++++++++++
 drivers/infiniband/hw/mlx5/mem.c                   |  162 ++
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  545 +++++
 drivers/infiniband/hw/mlx5/mr.c                    | 1014 ++++++++
 drivers/infiniband/hw/mlx5/qp.c                    | 2524 ++++++++++++++++++++
 drivers/infiniband/hw/mlx5/srq.c                   |  473 ++++
 drivers/infiniband/hw/mlx5/user.h                  |  121 +
 drivers/net/ethernet/mellanox/Kconfig              |    1 +
 drivers/net/ethernet/mellanox/Makefile             |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    5 +
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  238 ++
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 1522 ++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |  224 ++
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  598 +++++
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  521 ++++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  185 ++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  217 ++
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |   78 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  475 ++++
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |  106 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   73 +
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |  136 ++
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  435 ++++
 drivers/net/ethernet/mellanox/mlx5/core/pd.c       |  101 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  104 +
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |  301 +++
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  223 ++
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |  223 ++
 include/linux/mlx5/cmd.h                           |   51 +
 include/linux/mlx5/cq.h                            |  165 ++
 include/linux/mlx5/device.h                        |  893 +++++++
 include/linux/mlx5/doorbell.h                      |   79 +
 include/linux/mlx5/driver.h                        |  769 ++++++
 include/linux/mlx5/qp.h                            |  467 ++++
 include/linux/mlx5/srq.h                           |   41 +
 include/rdma/ib_verbs.h                            |   35 +-
 46 files changed, 15837 insertions(+), 2 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/Kconfig
 create mode 100644 drivers/infiniband/hw/mlx5/Makefile
 create mode 100644 drivers/infiniband/hw/mlx5/ah.c
 create mode 100644 drivers/infiniband/hw/mlx5/cq.c
 create mode 100644 drivers/infiniband/hw/mlx5/doorbell.c
 create mode 100644 drivers/infiniband/hw/mlx5/mad.c
 create mode 100644 drivers/infiniband/hw/mlx5/main.c
 create mode 100644 drivers/infiniband/hw/mlx5/mem.c
 create mode 100644 drivers/infiniband/hw/mlx5/mlx5_ib.h
 create mode 100644 drivers/infiniband/hw/mlx5/mr.c
 create mode 100644 drivers/infiniband/hw/mlx5/qp.c
 create mode 100644 drivers/infiniband/hw/mlx5/srq.c
 create mode 100644 drivers/infiniband/hw/mlx5/user.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/alloc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/cmd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/cq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fw.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/health.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mad.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mcg.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mr.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/port.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/qp.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/srq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/uar.c
 create mode 100644 include/linux/mlx5/cmd.h
 create mode 100644 include/linux/mlx5/cq.h
 create mode 100644 include/linux/mlx5/device.h
 create mode 100644 include/linux/mlx5/doorbell.h
 create mode 100644 include/linux/mlx5/driver.h
 create mode 100644 include/linux/mlx5/qp.h
 create mode 100644 include/linux/mlx5/srq.h
