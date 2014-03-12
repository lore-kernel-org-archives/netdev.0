From: clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [Patch 2/2] IB/mlx5: Free resources during PCI error
Date: Tue, 11 Mar 2014 22:42:21 -0500
Message-ID: <20140312034512.232925284@linux.vnet.ibm.com>
References: <20140312034219.637916521@linux.vnet.ibm.com>
Cc: brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=ib_mlx5_free_resources_during_pci_error.patch
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is to make sure that during a pci error, the remove_one
function frees the resources even though the hardware command failed
to avoid memory leaks when the adapter recovers.  Also make sure that
remove_one function goes thru all the functions like disable all irqs
and disable pci so when the remove_one function is done then the eehd
daemon will continue the recovery process.

Signed-off-by: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/mr.c                |    9 ++++++---
 drivers/infiniband/hw/mlx5/qp.c                |    6 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |    8 +++-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    1 -
 include/linux/mlx5/driver.h                    |    2 +-
 5 files changed, 15 insertions(+), 11 deletions(-)

Index: b/drivers/infiniband/hw/mlx5/mr.c
===================================================================
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -471,9 +471,12 @@ static void clean_keys(struct mlx5_ib_de
 		ent->size--;
 		spin_unlock_irq(&ent->lock);
 		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
-		if (err)
-			mlx5_ib_warn(dev, "failed destroy mkey\n");
-		else
+		if (err) {
+			if (pci_channel_offline(dev->mdev.pdev))
+				kfree(mr);
+			else
+				mlx5_ib_warn(dev, "failed destroy mkey\n");
+		} else
 			kfree(mr);
 	}
 }
Index: b/drivers/infiniband/hw/mlx5/qp.c
===================================================================
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -2564,7 +2564,11 @@ int mlx5_ib_dealloc_xrcd(struct ib_xrcd 
 
 	err = mlx5_core_xrcd_dealloc(&dev->mdev, xrcdn);
 	if (err) {
-		mlx5_ib_warn(dev, "failed to dealloc xrcdn 0x%x\n", xrcdn);
+		if (pci_channel_offline(dev->mdev.pdev))
+			kfree(xrcd);
+		else
+			mlx5_ib_warn(dev, "failed to dealloc xrcdn 0x%x\n",
+				     xrcdn);
 		return err;
 	}
 
Index: b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
===================================================================
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -482,14 +482,12 @@ err1:
 	return err;
 }
 
-int mlx5_stop_eqs(struct mlx5_core_dev *dev)
+void mlx5_stop_eqs(struct mlx5_core_dev *dev)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
 	int err;
 
-	err = mlx5_destroy_unmap_eq(dev, &table->pages_eq);
-	if (err)
-		return err;
+	mlx5_destroy_unmap_eq(dev, &table->pages_eq);
 
 	mlx5_destroy_unmap_eq(dev, &table->async_eq);
 	mlx5_cmd_use_polling(dev);
@@ -498,7 +496,7 @@ int mlx5_stop_eqs(struct mlx5_core_dev *
 	if (err)
 		mlx5_cmd_use_events(dev);
 
-	return err;
+	return;
 }
 
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
Index: b/drivers/net/ethernet/mellanox/mlx5/core/main.c
===================================================================
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -508,7 +508,6 @@ void mlx5_dev_cleanup(struct mlx5_core_d
 	mlx5_stop_health_poll(dev);
 	if (mlx5_cmd_teardown_hca(dev)) {
 		dev_err(&dev->pdev->dev, "tear_down_hca failed, skip cleanup\n");
-		return;
 	}
 	mlx5_pagealloc_stop(dev);
 	mlx5_reclaim_startup_pages(dev);
Index: b/include/linux/mlx5/driver.h
===================================================================
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -721,7 +721,7 @@ int mlx5_create_map_eq(struct mlx5_core_
 		       int nent, u64 mask, const char *name, struct mlx5_uar *uar);
 int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_start_eqs(struct mlx5_core_dev *dev);
-int mlx5_stop_eqs(struct mlx5_core_dev *dev);
+void mlx5_stop_eqs(struct mlx5_core_dev *dev);
 int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
 int mlx5_core_detach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
 

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
