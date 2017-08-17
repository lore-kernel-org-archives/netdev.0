From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/1] net/mlx4_core: Enable 4K UAR if SRIOV module parameter is not enabled
Date: Thu, 17 Aug 2017 18:29:52 +0300
Message-ID: <20170817152952.21592-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36723 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753018AbdHQPaN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:30:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

enable_4k_uar module parameter was added in patch cited below to
address the backward compatibility issue in SRIOV when the VM has
system's PAGE_SIZE uar implementation and the Hypervisor has 4k uar
implementation.

The above compatibility issue does not exist in the non SRIOV case.
In this patch, we always enable 4k uar implementation if SRIOV
is not enabled on mlx4's supported cards.

Fixes: 76e39ccf9c36 ("net/mlx4_core: Fix backward compatibility on VFs")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 09b9bc17bce9..5fe5cdc51357 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -432,7 +432,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		/* Virtual PCI function needs to determine UAR page size from
 		 * firmware. Only master PCI function can set the uar page size
 		 */
-		if (enable_4k_uar)
+		if (enable_4k_uar || !dev->persist->num_vfs)
 			dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
 		else
 			dev->uar_page_shift = PAGE_SHIFT;
@@ -2277,7 +2277,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 		dev->caps.max_fmr_maps = (1 << (32 - ilog2(dev->caps.num_mpts))) - 1;
 
-		if (enable_4k_uar) {
+		if (enable_4k_uar || !dev->persist->num_vfs) {
 			init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
 						    PAGE_SHIFT - DEFAULT_UAR_PAGE_SHIFT;
 			init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
-- 
2.13.0
