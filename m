From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_core: Fixed memory leak and incorrect refcount in mlx4_load_one
Date: Sun, 14 Dec 2014 16:18:04 +0200
Message-ID: <1418566685-9855-2-git-send-email-ogerlitz@mellanox.com>
References: <1418566685-9855-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60989 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752498AbaLNOSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 09:18:20 -0500
In-Reply-To: <1418566685-9855-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The current mlx4_load_one has a memory leak as it always allocates
dev_cap, but frees it only on error.

In addition, even if VFs exist when mlx4_load_one is called,
we still need to notify probed VFs that we're loading (by
incrementing pf_loading).

Fixes: a0eacca948d2 ('net/mlx4_core: Refactor mlx4_load_one')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   61 +++++++++++++++-------------
 1 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e25436b..c2ef266 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2488,41 +2488,42 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
 			     u8 total_vfs, int existing_vfs)
 {
 	u64 dev_flags = dev->flags;
+	int err = 0;
 
-	dev->dev_vfs = kzalloc(
-			total_vfs * sizeof(*dev->dev_vfs),
-			GFP_KERNEL);
+	atomic_inc(&pf_loading);
+	if (dev->flags &  MLX4_FLAG_SRIOV) {
+		if (existing_vfs != total_vfs) {
+			mlx4_err(dev, "SR-IOV was already enabled, but with num_vfs (%d) different than requested (%d)\n",
+				 existing_vfs, total_vfs);
+			total_vfs = existing_vfs;
+		}
+	}
+
+	dev->dev_vfs = kzalloc(total_vfs * sizeof(*dev->dev_vfs), GFP_KERNEL);
 	if (NULL == dev->dev_vfs) {
 		mlx4_err(dev, "Failed to allocate memory for VFs\n");
 		goto disable_sriov;
-	} else if (!(dev->flags &  MLX4_FLAG_SRIOV)) {
-		int err = 0;
-
-		atomic_inc(&pf_loading);
-		if (existing_vfs) {
-			if (existing_vfs != total_vfs)
-				mlx4_err(dev, "SR-IOV was already enabled, but with num_vfs (%d) different than requested (%d)\n",
-					 existing_vfs, total_vfs);
-		} else {
-			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", total_vfs);
-			err = pci_enable_sriov(pdev, total_vfs);
-		}
-		if (err) {
-			mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
-				 err);
-			atomic_dec(&pf_loading);
-			goto disable_sriov;
-		} else {
-			mlx4_warn(dev, "Running in master mode\n");
-			dev_flags |= MLX4_FLAG_SRIOV |
-				MLX4_FLAG_MASTER;
-			dev_flags &= ~MLX4_FLAG_SLAVE;
-			dev->num_vfs = total_vfs;
-		}
+	}
+
+	if (!(dev->flags &  MLX4_FLAG_SRIOV)) {
+		mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", total_vfs);
+		err = pci_enable_sriov(pdev, total_vfs);
+	}
+	if (err) {
+		mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
+			 err);
+		goto disable_sriov;
+	} else {
+		mlx4_warn(dev, "Running in master mode\n");
+		dev_flags |= MLX4_FLAG_SRIOV |
+			MLX4_FLAG_MASTER;
+		dev_flags &= ~MLX4_FLAG_SLAVE;
+		dev->num_vfs = total_vfs;
 	}
 	return dev_flags;
 
 disable_sriov:
+	atomic_dec(&pf_loading);
 	dev->num_vfs = 0;
 	kfree(dev->dev_vfs);
 	return dev_flags & ~MLX4_FLAG_MASTER;
@@ -2606,8 +2607,10 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 		}
 
 		if (total_vfs) {
-			existing_vfs = pci_num_vf(pdev);
 			dev->flags = MLX4_FLAG_MASTER;
+			existing_vfs = pci_num_vf(pdev);
+			if (existing_vfs)
+				dev->flags |= MLX4_FLAG_SRIOV;
 			dev->num_vfs = total_vfs;
 		}
 	}
@@ -2643,6 +2646,7 @@ slave_start:
 	}
 
 	if (mlx4_is_master(dev)) {
+		/* when we hit the goto slave_start below, dev_cap already initialized */
 		if (!dev_cap) {
 			dev_cap = kzalloc(sizeof(*dev_cap), GFP_KERNEL);
 
@@ -2849,6 +2853,7 @@ slave_start:
 	if (mlx4_is_master(dev) && dev->num_vfs)
 		atomic_dec(&pf_loading);
 
+	kfree(dev_cap);
 	return 0;
 
 err_port:
-- 
1.7.1
