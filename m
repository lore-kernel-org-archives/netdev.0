From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/9] net/mlx4_core: Handle AER flow properly
Date: Wed, 21 Jan 2015 16:45:55 +0200
Message-ID: <1421851557-12084-8-git-send-email-ogerlitz@mellanox.com>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43121 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752390AbbAUOri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 09:47:38 -0500
In-Reply-To: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

Fix AER callbacks to work properly, it includes:
- Refractoring AER to be aligned with Reset flow support.
- Sync with concurrent catas flow.

In addition, fix the shutdown PCI callback to sync with
concurrent catas flow.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   66 +++++++++++++++++++++++++++--
 1 files changed, 62 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d59cae5..01d12f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3120,7 +3120,10 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (ret) {
 		kfree(dev->persist);
 		kfree(priv);
+	} else {
+		pci_save_state(pdev);
 	}
+
 	return ret;
 }
 
@@ -3351,7 +3354,17 @@ MODULE_DEVICE_TABLE(pci, mlx4_pci_table);
 static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 					      pci_channel_state_t state)
 {
-	mlx4_unload_one(pdev);
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
+
+	mlx4_err(persist->dev, "mlx4_pci_err_detected was called\n");
+	mlx4_enter_error_state(persist);
+
+	mutex_lock(&persist->interface_state_mutex);
+	if (persist->interface_state & MLX4_INTERFACE_STATE_UP)
+		mlx4_unload_one(pdev);
+
+	mutex_unlock(&persist->interface_state_mutex);
+	pci_disable_device(pdev);
 
 	return state == pci_channel_io_perm_failure ?
 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
@@ -3359,15 +3372,60 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 {
-	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
+	struct mlx4_dev	 *dev  = persist->dev;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int               ret;
+	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	int total_vfs;
 
-	ret = __mlx4_init_one(pdev, priv->pci_dev_data, priv);
+	mlx4_err(dev, "mlx4_pci_slot_reset was called\n");
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		mlx4_err(dev, "Can not re-enable device, ret=%d\n", ret);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+	pci_save_state(pdev);
+
+	total_vfs = dev->persist->num_vfs;
+	memcpy(nvfs, dev->persist->nvfs, sizeof(dev->persist->nvfs));
+
+	mutex_lock(&persist->interface_state_mutex);
+	if (!(persist->interface_state & MLX4_INTERFACE_STATE_UP)) {
+		ret = mlx4_load_one(pdev, priv->pci_dev_data, total_vfs, nvfs,
+				    priv);
+		if (ret) {
+			mlx4_err(dev, "%s: mlx4_load_one failed, ret=%d\n",
+				 __func__,  ret);
+			goto end;
+		}
+
+		ret = restore_current_port_types(dev, dev->persist->
+						 curr_port_type, dev->persist->
+						 curr_port_poss_type);
+		if (ret)
+			mlx4_err(dev, "could not restore original port types (%d)\n", ret);
+	}
+end:
+	mutex_unlock(&persist->interface_state_mutex);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
 
+static void mlx4_shutdown(struct pci_dev *pdev)
+{
+	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
+
+	mlx4_info(persist->dev, "mlx4_shutdown was called\n");
+	mutex_lock(&persist->interface_state_mutex);
+	if (persist->interface_state & MLX4_INTERFACE_STATE_UP)
+		mlx4_unload_one(pdev);
+	mutex_unlock(&persist->interface_state_mutex);
+}
+
 static const struct pci_error_handlers mlx4_err_handler = {
 	.error_detected = mlx4_pci_err_detected,
 	.slot_reset     = mlx4_pci_slot_reset,
@@ -3377,7 +3435,7 @@ static struct pci_driver mlx4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= mlx4_pci_table,
 	.probe		= mlx4_init_one,
-	.shutdown	= mlx4_unload_one,
+	.shutdown	= mlx4_shutdown,
 	.remove		= mlx4_remove_one,
 	.err_handler    = &mlx4_err_handler,
 };
-- 
1.7.1
