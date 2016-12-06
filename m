From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 1/6] net/mlx5: Verify module parameters
Date: Tue,  6 Dec 2016 17:32:43 +0200
Message-ID: <1481038368-29677-2-git-send-email-saeedm@mellanox.com>
References: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55472 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752989AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
In-Reply-To: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Verify the mlx5_core module parameters by making sure that they are in
the expected range and if they aren't restore them to their default
values.

Fixes: 9603b61de1ee ('mlx5: Move pci device handling from mlx5_ib to mlx5_core')
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 27 +++++++++++++---------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  2 +-
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3b7c6a9f..22eb3be 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -62,13 +62,13 @@ MODULE_DESCRIPTION("Mellanox Connect-IB, ConnectX-4 core driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRIVER_VERSION);
 
-int mlx5_core_debug_mask;
-module_param_named(debug_mask, mlx5_core_debug_mask, int, 0644);
+unsigned int mlx5_core_debug_mask;
+module_param_named(debug_mask, mlx5_core_debug_mask, uint, 0644);
 MODULE_PARM_DESC(debug_mask, "debug mask: 1 = dump cmd data, 2 = dump cmd exec time, 3 = both. Default=0");
 
 #define MLX5_DEFAULT_PROF	2
-static int prof_sel = MLX5_DEFAULT_PROF;
-module_param_named(prof_sel, prof_sel, int, 0444);
+static unsigned int prof_sel = MLX5_DEFAULT_PROF;
+module_param_named(prof_sel, prof_sel, uint, 0444);
 MODULE_PARM_DESC(prof_sel, "profile selector. Valid range 0 - 2");
 
 enum {
@@ -1227,13 +1227,6 @@ static int init_one(struct pci_dev *pdev,
 
 	dev->pdev = pdev;
 	dev->event = mlx5_core_event;
-
-	if (prof_sel < 0 || prof_sel >= ARRAY_SIZE(profile)) {
-		mlx5_core_warn(dev,
-			       "selected profile out of range, selecting default (%d)\n",
-			       MLX5_DEFAULT_PROF);
-		prof_sel = MLX5_DEFAULT_PROF;
-	}
 	dev->profile = &profile[prof_sel];
 
 	INIT_LIST_HEAD(&priv->ctx_list);
@@ -1450,10 +1443,22 @@ static struct pci_driver mlx5_core_driver = {
 	.sriov_configure   = mlx5_core_sriov_configure,
 };
 
+static void mlx5_core_verify_params(void)
+{
+	if (prof_sel >= ARRAY_SIZE(profile)) {
+		pr_warn("mlx5_core: WARNING: Invalid module parameter prof_sel %d, valid range 0-%zu, changing back to default(%d)\n",
+			prof_sel,
+			ARRAY_SIZE(profile) - 1,
+			MLX5_DEFAULT_PROF);
+		prof_sel = MLX5_DEFAULT_PROF;
+	}
+}
+
 static int __init init(void)
 {
 	int err;
 
+	mlx5_core_verify_params();
 	mlx5_register_debugfs();
 
 	err = pci_register_driver(&mlx5_core_driver);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 187662c..20d16b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -44,7 +44,7 @@
 
 #define MLX5_TOTAL_VPORTS(mdev) (1 + pci_sriov_get_totalvfs(mdev->pdev))
 
-extern int mlx5_core_debug_mask;
+extern uint mlx5_core_debug_mask;
 
 #define mlx5_core_dbg(__dev, format, ...)				\
 	dev_dbg(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-- 
2.7.4
