From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 08/12] qlcnic: mark device state as failed
Date: Thu, 19 Aug 2010 08:08:29 -0700
Message-ID: <1282230513-25286-9-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58144 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753853Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark device state failed in error path.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6a8e970..6e246c8 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -94,7 +94,7 @@ static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
 
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
-static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter);
+static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
 static int qlcnic_can_start_firmware(struct qlcnic_adapter *adapter);
 
 static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
@@ -1561,7 +1561,7 @@ err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
 
 err_out_decr_ref:
-	qlcnic_clr_all_drv_state(adapter);
+	qlcnic_clr_all_drv_state(adapter, 0);
 
 err_out_iounmap:
 	qlcnic_cleanup_pci_map(adapter);
@@ -1600,7 +1600,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	if (adapter->eswitch != NULL)
 		kfree(adapter->eswitch);
 
-	qlcnic_clr_all_drv_state(adapter);
+	qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1632,7 +1632,7 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	qlcnic_clr_all_drv_state(adapter);
+	qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -2379,7 +2379,7 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 }
 
 static void
-qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter)
+qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 {
 	u32  val;
 
@@ -2390,7 +2390,11 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter)
 	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
 	QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
 
-	if (!(val & 0x11111111))
+	if (failed) {
+		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+		dev_info(&adapter->pdev->dev,
+				"Device state set to Failed. Please Reboot\n");
+	} else if (!(val & 0x11111111))
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
 
 	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
@@ -2605,7 +2609,7 @@ err_ret:
 	dev_err(&adapter->pdev->dev, "Fwinit work failed state=%u "
 		"fw_wait_cnt=%u\n", dev_state, adapter->fw_wait_cnt);
 	netif_device_attach(adapter->netdev);
-	qlcnic_clr_all_drv_state(adapter);
+	qlcnic_clr_all_drv_state(adapter, 0);
 }
 
 static void
@@ -2641,8 +2645,7 @@ err_ret:
 	dev_err(&adapter->pdev->dev, "detach failed; status=%d temp=%d\n",
 			status, adapter->temp);
 	netif_device_attach(netdev);
-	qlcnic_clr_all_drv_state(adapter);
-
+	qlcnic_clr_all_drv_state(adapter, 1);
 }
 
 /*Transit NPAR state to NON Operational */
@@ -2879,7 +2882,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
 		if (err) {
-			qlcnic_clr_all_drv_state(adapter);
+			qlcnic_clr_all_drv_state(adapter, 1);
 			clear_bit(__QLCNIC_AER, &adapter->state);
 			netif_device_attach(netdev);
 			return err;
-- 
1.6.0.2

