From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/13] net/mlx5: Fix incorrect page count when in internal error
Date: Thu, 30 Jun 2016 17:34:40 +0300
Message-ID: <1467297290-11443-4-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37675 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751973AbcF3OhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:21 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Change page cleanup flow when in internal error to properly decrement
the page counts when reclaiming pages.  The prevents timing out waiting
for extra pages that were actually cleaned up previously.

fixes: 89d44f0a6c73 ('net/mlx5_core: Add pci error handlers to mlx5_core driver')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 63 +++++++++++++++-------
 1 file changed, 44 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 9eeee05..32dea35 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -345,7 +345,6 @@ retry:
 			       func_id, npages, err);
 		goto out_4k;
 	}
-	dev->priv.fw_pages += npages;
 
 	err = mlx5_cmd_status_to_err(&out.hdr);
 	if (err) {
@@ -373,6 +372,33 @@ out_free:
 	return err;
 }
 
+static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
+			     struct mlx5_manage_pages_inbox *in, int in_size,
+			     struct mlx5_manage_pages_outbox *out, int out_size)
+{
+	struct fw_page *fwp;
+	struct rb_node *p;
+	u32 npages;
+	u32 i = 0;
+
+	if (dev->state != MLX5_DEVICE_STATE_INTERNAL_ERROR)
+		return mlx5_cmd_exec_check_status(dev, (u32 *)in, in_size,
+						  (u32 *)out, out_size);
+
+	npages = be32_to_cpu(in->num_entries);
+
+	p = rb_first(&dev->priv.page_root);
+	while (p && i < npages) {
+		fwp = rb_entry(p, struct fw_page, rb_node);
+		out->pas[i] = cpu_to_be64(fwp->addr);
+		p = rb_next(p);
+		i++;
+	}
+
+	out->num_entries = cpu_to_be32(i);
+	return 0;
+}
+
 static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 			 int *nclaimed)
 {
@@ -398,15 +424,9 @@ static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 	in.func_id = cpu_to_be16(func_id);
 	in.num_entries = cpu_to_be32(npages);
 	mlx5_core_dbg(dev, "npages %d, outlen %d\n", npages, outlen);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
+	err = reclaim_pages_cmd(dev, &in, sizeof(in), out, outlen);
 	if (err) {
-		mlx5_core_err(dev, "failed reclaiming pages\n");
-		goto out_free;
-	}
-	dev->priv.fw_pages -= npages;
-
-	if (out->hdr.status) {
-		err = mlx5_cmd_status_to_err(&out->hdr);
+		mlx5_core_err(dev, "failed reclaiming pages: err %d\n", err);
 		goto out_free;
 	}
 
@@ -417,13 +437,15 @@ static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 		err = -EINVAL;
 		goto out_free;
 	}
-	if (nclaimed)
-		*nclaimed = num_claimed;
 
 	for (i = 0; i < num_claimed; i++) {
 		addr = be64_to_cpu(out->pas[i]);
 		free_4k(dev, addr);
 	}
+
+	if (nclaimed)
+		*nclaimed = num_claimed;
+
 	dev->priv.fw_pages -= num_claimed;
 	if (func_id)
 		dev->priv.vfs_pages -= num_claimed;
@@ -514,14 +536,10 @@ int mlx5_reclaim_startup_pages(struct mlx5_core_dev *dev)
 		p = rb_first(&dev->priv.page_root);
 		if (p) {
 			fwp = rb_entry(p, struct fw_page, rb_node);
-			if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
-				free_4k(dev, fwp->addr);
-				nclaimed = 1;
-			} else {
-				err = reclaim_pages(dev, fwp->func_id,
-						    optimal_reclaimed_pages(),
-						    &nclaimed);
-			}
+			err = reclaim_pages(dev, fwp->func_id,
+					    optimal_reclaimed_pages(),
+					    &nclaimed);
+
 			if (err) {
 				mlx5_core_warn(dev, "failed reclaiming pages (%d)\n",
 					       err);
@@ -536,6 +554,13 @@ int mlx5_reclaim_startup_pages(struct mlx5_core_dev *dev)
 		}
 	} while (p);
 
+	WARN(dev->priv.fw_pages,
+	     "FW pages counter is %d after reclaiming all pages\n",
+	     dev->priv.fw_pages);
+	WARN(dev->priv.vfs_pages,
+	     "VFs FW pages counter is %d after reclaiming all pages\n",
+	     dev->priv.vfs_pages);
+
 	return 0;
 }
 
-- 
2.8.0
