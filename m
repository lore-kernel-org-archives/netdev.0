From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 6/8] qlcnic: Allow firmware dump collection when auto firmware recovery is disabled
Date: Mon, 16 Dec 2013 15:37:01 -0500
Message-ID: <755d854e3c6b4563801591fc7bd83ed5ded5f497.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:19952 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113Ab3LPVJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:52 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Allow driver to collect firmware dump, during a forced firmware dump
  operation, when auto firmware recovery is disabled. Also, during this
  operation, driver should not allow reset recovery to be performed.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 53 ++++++++++++++--------
 2 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 4cae6ca..a6a3350 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -662,4 +662,5 @@ pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *,
 					       pci_channel_state_t);
 pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *);
 void qlcnic_83xx_io_resume(struct pci_dev *);
+void qlcnic_83xx_stop_hw(struct qlcnic_adapter *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index cac0503..918e18d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -740,6 +740,7 @@ static int qlcnic_83xx_idc_unknown_state(struct qlcnic_adapter *adapter)
 	adapter->ahw->idc.err_code = -EIO;
 	dev_err(&adapter->pdev->dev,
 		"%s: Device in unknown state\n", __func__);
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return 0;
 }
 
@@ -818,7 +819,6 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_mailbox *mbx = ahw->mailbox;
 	int ret = 0;
-	u32 owner;
 	u32 val;
 
 	/* Perform NIC configuration based ready state entry actions */
@@ -848,9 +848,9 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
 			set_bit(__QLCNIC_RESETTING, &adapter->state);
 			qlcnic_83xx_idc_enter_need_reset_state(adapter, 1);
 		}  else {
-			owner = qlcnic_83xx_idc_find_reset_owner_id(adapter);
-			if (ahw->pci_func == owner)
-				qlcnic_dump_fw(adapter);
+			netdev_info(adapter->netdev, "%s: Auto firmware recovery is disabled\n",
+				    __func__);
+			qlcnic_83xx_idc_enter_failed_state(adapter, 1);
 		}
 		return -EIO;
 	}
@@ -948,13 +948,26 @@ static int qlcnic_83xx_idc_need_quiesce_state(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-static int qlcnic_83xx_idc_failed_state(struct qlcnic_adapter *adapter)
+static void qlcnic_83xx_idc_failed_state(struct qlcnic_adapter *adapter)
 {
-	dev_err(&adapter->pdev->dev, "%s: please restart!!\n", __func__);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u32 val, owner;
+
+	val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
+	if (val & QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY) {
+		owner = qlcnic_83xx_idc_find_reset_owner_id(adapter);
+		if (ahw->pci_func == owner) {
+			qlcnic_83xx_stop_hw(adapter);
+			qlcnic_dump_fw(adapter);
+		}
+	}
+
+	netdev_warn(adapter->netdev, "%s: Reboot will be required to recover the adapter!!\n",
+		    __func__);
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	adapter->ahw->idc.err_code = -EIO;
+	ahw->idc.err_code = -EIO;
 
-	return 0;
+	return;
 }
 
 static int qlcnic_83xx_idc_quiesce_state(struct qlcnic_adapter *adapter)
@@ -1063,12 +1076,6 @@ void qlcnic_83xx_idc_poll_dev_state(struct work_struct *work)
 	adapter->ahw->idc.prev_state = adapter->ahw->idc.curr_state;
 	qlcnic_83xx_periodic_tasks(adapter);
 
-	/* Do not reschedule if firmaware is in hanged state and auto
-	 * recovery is disabled
-	 */
-	if ((adapter->flags & QLCNIC_FW_HANG) && !qlcnic_auto_fw_reset)
-		return;
-
 	/* Re-schedule the function */
 	if (test_bit(QLC_83XX_MODULE_LOADED, &adapter->ahw->idc.status))
 		qlcnic_schedule_work(adapter, qlcnic_83xx_idc_poll_dev_state,
@@ -1219,10 +1226,10 @@ void qlcnic_83xx_idc_request_reset(struct qlcnic_adapter *adapter, u32 key)
 	}
 
 	val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
-	if ((val & QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY) ||
-	    !qlcnic_auto_fw_reset) {
-		dev_err(&adapter->pdev->dev,
-			"%s:failed, device in non reset mode\n", __func__);
+	if (val & QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY) {
+		netdev_info(adapter->netdev, "%s: Auto firmware recovery is disabled\n",
+			    __func__);
+		qlcnic_83xx_idc_enter_failed_state(adapter, 0);
 		qlcnic_83xx_unlock_driver(adapter);
 		return;
 	}
@@ -1939,7 +1946,7 @@ static void qlcnic_83xx_exec_template_cmd(struct qlcnic_adapter *p_dev,
 	p_dev->ahw->reset.seq_index = index;
 }
 
-static void qlcnic_83xx_stop_hw(struct qlcnic_adapter *p_dev)
+void qlcnic_83xx_stop_hw(struct qlcnic_adapter *p_dev)
 {
 	p_dev->ahw->reset.seq_index = 0;
 
@@ -1994,6 +2001,14 @@ static int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 	val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
 	if (!(val & QLC_83XX_IDC_GRACEFULL_RESET))
 		qlcnic_dump_fw(adapter);
+
+	if (val & QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY) {
+		netdev_info(adapter->netdev, "%s: Auto firmware recovery is disabled\n",
+			    __func__);
+		qlcnic_83xx_idc_enter_failed_state(adapter, 1);
+		return err;
+	}
+
 	qlcnic_83xx_init_hw(adapter);
 
 	if (qlcnic_83xx_copy_bootloader(adapter))
-- 
1.8.1.4
