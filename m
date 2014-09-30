From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx4_core: Don't disable SRIOV if there are active VFs
Date: Tue, 30 Sep 2014 12:03:47 +0300
Message-ID: <1412067830-30438-2-git-send-email-ogerlitz@mellanox.com>
References: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50222 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751869AbaI3JD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:59 -0400
In-Reply-To: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When unloading the host driver while there are VFs active on VMs,
the PF driver disabled sriov anyway, causing kernel crashes.

We now leave SRIOV enabled, to avoid that.

When the driver is reloaded, __mlx4_init_one is invoked on the PF.
It now checks to see if SRIOV is already enabled on the PF -- and
if so does not enable sriov again.

Signed-off-by: Tal Alon <talal@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 1f10023..4e9857b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2272,6 +2272,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 	unsigned total_vfs = 0;
 	int sriov_initialized = 0;
 	unsigned int i;
+	int existing_vfs = 0;
 
 	pr_info(DRV_NAME ": Initializing %s\n", pci_name(pdev));
 
@@ -2431,7 +2432,15 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 				err = 0;
 			} else {
 				atomic_inc(&pf_loading);
-				err = pci_enable_sriov(pdev, total_vfs);
+				existing_vfs = pci_num_vf(pdev);
+				if (existing_vfs) {
+					err = 0;
+					if (existing_vfs != total_vfs)
+						mlx4_err(dev, "SR-IOV was already enabled, but with num_vfs (%d) different than requested (%d)\n",
+							 existing_vfs, total_vfs);
+				} else {
+					err = pci_enable_sriov(pdev, total_vfs);
+				}
 				if (err) {
 					mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
 						 err);
@@ -2645,7 +2654,7 @@ err_cmd:
 	mlx4_cmd_cleanup(dev);
 
 err_sriov:
-	if (dev->flags & MLX4_FLAG_SRIOV)
+	if (dev->flags & MLX4_FLAG_SRIOV && !existing_vfs)
 		pci_disable_sriov(pdev);
 
 err_rel_own:
@@ -2693,16 +2702,21 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int               pci_dev_data;
 	int p;
+	int active_vfs = 0;
 
 	if (priv->removed)
 		return;
 
 	pci_dev_data = priv->pci_dev_data;
 
-	/* in SRIOV it is not allowed to unload the pf's
-	 * driver while there are alive vf's */
-	if (mlx4_is_master(dev) && mlx4_how_many_lives_vf(dev))
-		pr_warn("Removing PF when there are assigned VF's !!!\n");
+	/* Disabling SR-IOV is not allowed while there are active vf's */
+	if (mlx4_is_master(dev)) {
+		active_vfs = mlx4_how_many_lives_vf(dev);
+		if (active_vfs) {
+			pr_warn("Removing PF when there are active VF's !!\n");
+			pr_warn("Will not disable SR-IOV.\n");
+		}
+	}
 	mlx4_stop_sense(dev);
 	mlx4_unregister_device(dev);
 
@@ -2745,7 +2759,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
 
 	if (dev->flags & MLX4_FLAG_MSI_X)
 		pci_disable_msix(pdev);
-	if (dev->flags & MLX4_FLAG_SRIOV) {
+	if (dev->flags & MLX4_FLAG_SRIOV && !active_vfs) {
 		mlx4_warn(dev, "Disabling SR-IOV\n");
 		pci_disable_sriov(pdev);
 		dev->num_vfs = 0;
-- 
1.7.1
