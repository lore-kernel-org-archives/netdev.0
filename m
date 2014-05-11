From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected mode TX path
Date: Sun, 11 May 2014 15:15:09 +0300
Message-ID: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Roland,

This series is a refactored form of the one posted by Jiri Kosina 
to LKML and netdev according to the discussion that followed
and the guidelines you provided here https://lkml.org/lkml/2014/3/5/250

Basically, the functionality changes introduced by this series fully 
reside on the IB side of things, so I am only posting the actual patches 
to linux-rdma with CC on the cover-letter to the lists that were on V0.

Or.

As described in the change log of patch #2 this series comes to address 
a problem whereby NFS client writes would enter uninterruptible sleep 
forever. The issue happened when using NFS over IPoIB connected mode.

The problem encountered was described as follows: it's not memory
reclamation that is the problem as such. There is an indirect dependency
between network filesystems writing back pages and ipoib_cm_tx_init()
due to how a kworker is used. Page reclaim cannot make forward progress
until ipoib_cm_tx_init() succeeds and it is stuck in page reclaim itself
waiting for network transmission. Ordinarily this situation may be
avoided by having the caller use GFP_NOFS but ipoib_cm_tx_init()
does not have that information.

To address this, we take a more general approach vs. V0 and generalize 
the solution such that when the new QP creation flag is provided, the
HW driver should use a GFP_NOIO for the memory allocations related
to the new QP.

changes from V0:
 - removed the module param for IPoIB, the connected mode code would
   attempt to use GFP_NOIO for the QP creation and fallback to GFP_KERNEL
   (as before) if the HW driver doesn't support that. This approach will let
   

Jiri Kosina (1):
  mlx4: Enhance the QP creation path to use a given GFP directive

Or Gerlitz (2):
  IB: Return error when QP creation are provided for driver not supporting that
  IB: Add a QP creation flag to allow specifying a NOIO allocation directive

 drivers/infiniband/hw/mlx4/cq.c                    |    6 ++--
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |    1 +
 drivers/infiniband/hw/mlx4/qp.c                    |   30 +++++++++++--------
 drivers/infiniband/hw/mlx4/srq.c                   |    7 ++--
 drivers/infiniband/hw/qib/qib_qp.c                 |    3 +-
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c       |    3 ++
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |   19 ++++++++++--
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |   27 +++++++++--------
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    6 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |    2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.c           |    7 ++--
 drivers/net/ethernet/mellanox/mlx4/icm.h           |    3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |   17 ++++++-----
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   20 ++++++------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 +-
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    4 +-
 include/linux/mlx4/device.h                        |   10 ++++--
 include/rdma/ib_verbs.h                            |    1 +
 20 files changed, 104 insertions(+), 74 deletions(-)

Cc: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Cc: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
