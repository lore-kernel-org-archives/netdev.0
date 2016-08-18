From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/10] net/mlx5: Fix pci error recovery flow
Date: Thu, 18 Aug 2016 21:09:04 +0300
Message-ID: <1471543751-24164-4-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41785 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932402AbcHSBnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:15 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

When PCI error is detected we should save the state of the pci prior to
disabling it.

Also when receiving pci slot reset call we need to verify that the
device is responsive.

Fixes: 89d44f0a6c73 ('net/mlx5_core: Add pci error handlers to mlx5_core
driver')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 59 +++++++++++++-------------
 1 file changed, 29 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 4f491d4..2385bae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1420,36 +1420,12 @@ static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
 	dev_info(&pdev->dev, "%s was called\n", __func__);
 	mlx5_enter_error_state(dev);
 	mlx5_unload_one(dev, priv);
+	pci_save_state(pdev);
 	mlx5_pci_disable_device(dev);
 	return state == pci_channel_io_perm_failure ?
 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
 }
 
-static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
-{
-	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
-	int err = 0;
-
-	dev_info(&pdev->dev, "%s was called\n", __func__);
-
-	err = mlx5_pci_enable_device(dev);
-	if (err) {
-		dev_err(&pdev->dev, "%s: mlx5_pci_enable_device failed with error code: %d\n"
-			, __func__, err);
-		return PCI_ERS_RESULT_DISCONNECT;
-	}
-	pci_set_master(pdev);
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-
-	return err ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
-}
-
-void mlx5_disable_device(struct mlx5_core_dev *dev)
-{
-	mlx5_pci_err_detected(dev->pdev, 0);
-}
-
 /* wait for the device to show vital signs by waiting
  * for the health counter to start counting.
  */
@@ -1477,21 +1453,44 @@ static int wait_vital(struct pci_dev *pdev)
 	return -ETIMEDOUT;
 }
 
-static void mlx5_pci_resume(struct pci_dev *pdev)
+static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
 {
 	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
-	struct mlx5_priv *priv = &dev->priv;
 	int err;
 
 	dev_info(&pdev->dev, "%s was called\n", __func__);
 
-	pci_save_state(pdev);
-	err = wait_vital(pdev);
+	err = mlx5_pci_enable_device(dev);
 	if (err) {
+		dev_err(&pdev->dev, "%s: mlx5_pci_enable_device failed with error code: %d\n"
+			, __func__, err);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
+	if (wait_vital(pdev)) {
 		dev_err(&pdev->dev, "%s: wait_vital timed out\n", __func__);
-		return;
+		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+void mlx5_disable_device(struct mlx5_core_dev *dev)
+{
+	mlx5_pci_err_detected(dev->pdev, 0);
+}
+
+static void mlx5_pci_resume(struct pci_dev *pdev)
+{
+	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
+	struct mlx5_priv *priv = &dev->priv;
+	int err;
+
+	dev_info(&pdev->dev, "%s was called\n", __func__);
+
 	err = mlx5_load_one(dev, priv);
 	if (err)
 		dev_err(&pdev->dev, "%s: mlx5_load_one failed with error code: %d\n"
-- 
2.7.4
