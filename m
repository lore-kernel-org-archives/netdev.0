From: Eli Cohen <eli@mellanox.com>
Subject: [PATCH net-next] net/mlx4_core: Fix backward compatibility on VFs
Date: Thu, 17 Mar 2016 18:49:42 +0200
Message-ID: <1458233382-12871-1-git-send-email-eli@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org, aik@ozlabs.ru,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34561 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932875AbcCQQvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 12:51:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 85743f1eb345 ("net/mlx4_core: Set UAR page size to 4KB regardless
of system page size") introduced dependency where old VF drivers without
this fix fail to load if the PF driver runs with this commit.

To resolve this add a module parameter which disables that functionality
by default.  If both the PF and VFs are running with a driver with that
commit the administrator may set the module param to true.

The module parameter is called enable_4k_uar.

Fixes: 85743f1eb345 ('net/mlx4_core: Set UAR page size to 4KB ...')
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 503ec23e84cc..358f7230da58 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -105,6 +105,11 @@ module_param(enable_64b_cqe_eqe, bool, 0444);
 MODULE_PARM_DESC(enable_64b_cqe_eqe,
 		 "Enable 64 byte CQEs/EQEs when the FW supports this (default: True)");
 
+static bool enable_4k_uar;
+module_param(enable_4k_uar, bool, 0444);
+MODULE_PARM_DESC(enable_4k_uar,
+		 "Enable using 4K UAR. Should not be enabled if have VFs which do not support 4K UARs (default: false)");
+
 #define PF_CONTEXT_BEHAVIOUR_MASK	(MLX4_FUNC_CAP_64B_EQE_CQE | \
 					 MLX4_FUNC_CAP_EQE_CQE_STRIDE | \
 					 MLX4_FUNC_CAP_DMFS_A0_STATIC)
@@ -423,7 +428,11 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		/* Virtual PCI function needs to determine UAR page size from
 		 * firmware. Only master PCI function can set the uar page size
 		 */
-		dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
+		if (enable_4k_uar)
+			dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
+		else
+			dev->uar_page_shift = PAGE_SHIFT;
+
 		mlx4_set_num_reserved_uars(dev, dev_cap);
 	}
 
@@ -2233,11 +2242,14 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 		dev->caps.max_fmr_maps = (1 << (32 - ilog2(dev->caps.num_mpts))) - 1;
 
-		/* Always set UAR page size 4KB, set log_uar_sz accordingly */
-		init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
-				      PAGE_SHIFT -
-				      DEFAULT_UAR_PAGE_SHIFT;
-		init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
+		if (enable_4k_uar) {
+			init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
+						    PAGE_SHIFT - DEFAULT_UAR_PAGE_SHIFT;
+			init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
+		} else {
+			init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
+			init_hca.uar_page_sz = PAGE_SHIFT - 12;
+		}
 
 		init_hca.mw_enabled = 0;
 		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_MEM_WINDOW ||
-- 
1.8.3.1
