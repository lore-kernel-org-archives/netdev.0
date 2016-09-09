From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/11] net/mlx5: Skip waiting for vf pages in internal error
Date: Fri,  9 Sep 2016 17:35:17 +0300
Message-ID: <1473431727-20150-2-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35485 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752797AbcIIOhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:00 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

In case of device in internal error state there is no need to wait for
vf pages since they will be reclaimed manually later in the unload flow.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 673a7c9..d458515 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -326,6 +326,7 @@ static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
 {
 	struct fw_page *fwp;
 	struct rb_node *p;
+	u32 func_id;
 	u32 npages;
 	u32 i = 0;
 
@@ -334,12 +335,16 @@ static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
 
 	/* No hard feelings, we want our pages back! */
 	npages = MLX5_GET(manage_pages_in, in, input_num_entries);
+	func_id = MLX5_GET(manage_pages_in, in, function_id);
 
 	p = rb_first(&dev->priv.page_root);
 	while (p && i < npages) {
 		fwp = rb_entry(p, struct fw_page, rb_node);
-		MLX5_SET64(manage_pages_out, out, pas[i], fwp->addr);
 		p = rb_next(p);
+		if (fwp->func_id != func_id)
+			continue;
+
+		MLX5_SET64(manage_pages_out, out, pas[i], fwp->addr);
 		i++;
 	}
 
@@ -540,6 +545,12 @@ int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev)
 	unsigned long end = jiffies + msecs_to_jiffies(MAX_RECLAIM_VFS_PAGES_TIME_MSECS);
 	int prev_vfs_pages = dev->priv.vfs_pages;
 
+	/* In case of internal error we will free the pages manually later */
+	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+		mlx5_core_warn(dev, "Skipping wait for vf pages stage");
+		return 0;
+	}
+
 	mlx5_core_dbg(dev, "Waiting for %d pages from %s\n", prev_vfs_pages,
 		      dev->priv.name);
 	while (dev->priv.vfs_pages) {
-- 
2.7.4
