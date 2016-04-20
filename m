From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_core: Implement pci_resume callback
Date: Wed, 20 Apr 2016 16:01:15 +0300
Message-ID: <1461157278-18528-2-git-send-email-ogerlitz@mellanox.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51101 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751650AbcDTNCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:02:04 -0400
In-Reply-To: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Move resume related activities to a new pci_resume function instead of
performing them in mlx4_pci_slot_reset.  This change is needed to avoid
a hotplug during EEH recovery due to commit f2da4ccf8bd4 ("powerpc/eeh:
More relaxed hotplug criterion").

Fixes: 2ba5fbd62b25 ('net/mlx4_core: Handle AER flow properly')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 39 +++++++++++++++++++------------
 1 file changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 358f723..5d45aa3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -4050,45 +4050,53 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 {
 	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
 	struct mlx4_dev	 *dev  = persist->dev;
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	int               ret;
-	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
-	int total_vfs;
+	int err;
 
 	mlx4_err(dev, "mlx4_pci_slot_reset was called\n");
-	ret = pci_enable_device(pdev);
-	if (ret) {
-		mlx4_err(dev, "Can not re-enable device, ret=%d\n", ret);
+	err = pci_enable_device(pdev);
+	if (err) {
+		mlx4_err(dev, "Can not re-enable device, err=%d\n", err);
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 	pci_save_state(pdev);
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+static void mlx4_pci_resume(struct pci_dev *pdev)
+{
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
+	struct mlx4_dev	 *dev  = persist->dev;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	int total_vfs;
+	int err;
 
+	mlx4_err(dev, "%s was called\n", __func__);
 	total_vfs = dev->persist->num_vfs;
 	memcpy(nvfs, dev->persist->nvfs, sizeof(dev->persist->nvfs));
 
 	mutex_lock(&persist->interface_state_mutex);
 	if (!(persist->interface_state & MLX4_INTERFACE_STATE_UP)) {
-		ret = mlx4_load_one(pdev, priv->pci_dev_data, total_vfs, nvfs,
+		err = mlx4_load_one(pdev, priv->pci_dev_data, total_vfs, nvfs,
 				    priv, 1);
-		if (ret) {
-			mlx4_err(dev, "%s: mlx4_load_one failed, ret=%d\n",
-				 __func__,  ret);
+		if (err) {
+			mlx4_err(dev, "%s: mlx4_load_one failed, err=%d\n",
+				 __func__,  err);
 			goto end;
 		}
 
-		ret = restore_current_port_types(dev, dev->persist->
+		err = restore_current_port_types(dev, dev->persist->
 						 curr_port_type, dev->persist->
 						 curr_port_poss_type);
-		if (ret)
-			mlx4_err(dev, "could not restore original port types (%d)\n", ret);
+		if (err)
+			mlx4_err(dev, "could not restore original port types (%d)\n", err);
 	}
 end:
 	mutex_unlock(&persist->interface_state_mutex);
 
-	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
 
 static void mlx4_shutdown(struct pci_dev *pdev)
@@ -4105,6 +4113,7 @@ static void mlx4_shutdown(struct pci_dev *pdev)
 static const struct pci_error_handlers mlx4_err_handler = {
 	.error_detected = mlx4_pci_err_detected,
 	.slot_reset     = mlx4_pci_slot_reset,
+	.resume		= mlx4_pci_resume,
 };
 
 static struct pci_driver mlx4_driver = {
-- 
2.3.7
