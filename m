From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 2/6] qlcnic: fix mailbox interrupt.
Date: Mon, 18 Feb 2013 17:06:14 -0500
Message-ID: <1361225178-4363-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361225178-4363-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19333 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757272Ab3BRW2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 17:28:18 -0500
In-Reply-To: <1361225178-4363-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Config interrupt is not needed for mailbox interrupts.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   27 +++++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   17 +++---------
 3 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index f7b39d1..e92cc52 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -497,8 +497,6 @@ int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *adapter)
 
 	/* Enable mailbox interrupt */
 	qlcnic_83xx_enable_mbx_intrpt(adapter);
-	if (adapter->flags & QLCNIC_MSIX_ENABLED)
-		err = qlcnic_83xx_config_intrpt(adapter, 1);
 
 	return err;
 }
@@ -1915,7 +1913,7 @@ int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *adapter, bool op_type)
 	u32 val, temp;
 	struct qlcnic_cmd_args cmd;
 
-	max_ints = adapter->ahw->num_msix;
+	max_ints = adapter->ahw->num_msix - 1;
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_INTRPT);
 	cmd.req.arg[1] = max_ints;
 	for (i = 0, index = 2; i < max_ints; i++) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 6308d4d..a69097c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -599,9 +599,17 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *dev)
 		dev->flags &= ~QLCNIC_NEED_FLR;
 	}
 
+	if (qlcnic_83xx_check(dev) && (dev->flags & QLCNIC_MSIX_ENABLED)) {
+		if (dev->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+			err = qlcnic_83xx_config_intrpt(dev, 1);
+			if (err)
+				return err;
+		}
+	}
+
 	err = qlcnic_fw_cmd_create_rx_ctx(dev);
 	if (err)
-		return err;
+		goto err_out;
 
 	for (ring = 0; ring < dev->max_drv_tx_rings; ring++) {
 		err = qlcnic_fw_cmd_create_tx_ctx(dev,
@@ -610,18 +618,25 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *dev)
 		if (err) {
 			qlcnic_fw_cmd_destroy_rx_ctx(dev);
 			if (ring == 0)
-				return err;
+				goto err_out;
 
 			for (i = 0; i < ring; i++)
 				qlcnic_fw_cmd_destroy_tx_ctx(dev,
 							     &dev->tx_ring[i]);
 
-			return err;
+			goto err_out;
 		}
 	}
 
 	set_bit(__QLCNIC_FW_ATTACHED, &dev->state);
 	return 0;
+
+err_out:
+	if (qlcnic_83xx_check(dev) && (dev->flags & QLCNIC_MSIX_ENABLED)) {
+		if (dev->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
+			qlcnic_83xx_config_intrpt(dev, 0);
+	}
+	return err;
 }
 
 void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
@@ -633,6 +648,12 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
 			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
 						     &adapter->tx_ring[ring]);
+
+		if (qlcnic_83xx_check(adapter) &&
+		    (adapter->flags & QLCNIC_MSIX_ENABLED)) {
+			if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
+				qlcnic_83xx_config_intrpt(adapter, 0);
+		}
 		/* Allow dma queues to drain after context reset */
 		mdelay(20);
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b953168..f084dc1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1965,11 +1965,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_out_disable_mbx_intr:
-	if (qlcnic_83xx_check(adapter)) {
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			qlcnic_83xx_config_intrpt(adapter, 0);
+	if (qlcnic_83xx_check(adapter))
 		qlcnic_83xx_free_mbx_intr(adapter);
-	}
 
 err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
@@ -2015,8 +2012,6 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	unregister_netdev(netdev);
 
 	if (qlcnic_83xx_check(adapter)) {
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			qlcnic_83xx_config_intrpt(adapter, 0);
 		qlcnic_83xx_free_mbx_intr(adapter);
 		qlcnic_83xx_register_nic_idc_func(adapter, 0);
 		cancel_delayed_work_sync(&adapter->idc_aen_work);
@@ -3107,8 +3102,6 @@ static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
 		qlcnic_down(adapter, netdev);
 
 	if (qlcnic_83xx_check(adapter)) {
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			qlcnic_83xx_config_intrpt(adapter, 0);
 		qlcnic_83xx_free_mbx_intr(adapter);
 		qlcnic_83xx_register_nic_idc_func(adapter, 0);
 		cancel_delayed_work_sync(&adapter->idc_aen_work);
@@ -3203,13 +3196,11 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
-	if (qlcnic_83xx_check(adapter)) {
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			qlcnic_83xx_config_intrpt(adapter, 0);
+	qlcnic_detach(adapter);
+
+	if (qlcnic_83xx_check(adapter))
 		qlcnic_83xx_free_mbx_intr(adapter);
-	}
 
-	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
 	err = qlcnic_setup_intr(adapter, data);
 	if (err) {
-- 
1.7.1
