From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/8] qlcnic: fix fw initialization responsibility
Date: Thu, 22 Apr 2010 05:51:37 -0700
Message-ID: <1271940702-17064-4-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:35209 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754563Ab0DVMvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:45 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now any pci-func can start fw, whoever sees the reset ack first.
Before this, pci-func which sets the RESET state has the responsibility
to start fw.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   66 +++++++++++++++++++++----------------
 1 files changed, 37 insertions(+), 29 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index ff7705b..0634990 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2015,6 +2015,7 @@ err:
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 }
 
+/* Grab api lock, before checking state */
 static int
 qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 {
@@ -2037,6 +2038,9 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	u8 dev_init_timeo = adapter->dev_init_timeo;
 	int portnum = adapter->portnum;
 
+	if (test_and_clear_bit(__QLCNIC_START_FW, &adapter->state))
+		return 1;
+
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
@@ -2044,8 +2048,6 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (!(val & ((int)0x1 << (portnum * 4)))) {
 		val |= ((u32)0x1 << (portnum * 4));
 		QLCWR32(adapter, QLCNIC_CRB_DEV_REF_COUNT, val);
-	} else if (test_and_clear_bit(__QLCNIC_START_FW, &adapter->state)) {
-		goto start_fw;
 	}
 
 	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
@@ -2053,7 +2055,6 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
-start_fw:
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		qlcnic_api_unlock(adapter);
 		return 1;
@@ -2113,51 +2114,59 @@ qlcnic_fwinit_work(struct work_struct *work)
 {
 	struct qlcnic_adapter *adapter = container_of(work,
 			struct qlcnic_adapter, fw_work.work);
-	int dev_state;
+	u32 dev_state = 0xf;
 
-	if (test_bit(__QLCNIC_START_FW, &adapter->state)) {
+	if (qlcnic_api_lock(adapter))
+		goto err_ret;
 
-		if (qlcnic_check_drv_state(adapter) &&
-			(adapter->fw_wait_cnt++ < adapter->reset_ack_timeo)) {
-			qlcnic_schedule_work(adapter,
-					qlcnic_fwinit_work, FW_POLL_DELAY);
-			return;
+	if (adapter->fw_wait_cnt++ > adapter->reset_ack_timeo) {
+		dev_err(&adapter->pdev->dev, "Reset:Failed to get ack %d sec\n",
+					adapter->reset_ack_timeo);
+		goto skip_ack_check;
+	}
+
+	if (!qlcnic_check_drv_state(adapter)) {
+skip_ack_check:
+		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		if (dev_state == QLCNIC_DEV_NEED_RESET) {
+			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
+						QLCNIC_DEV_INITIALIZING);
+			set_bit(__QLCNIC_START_FW, &adapter->state);
+			QLCDB(adapter, DRV, "Restarting fw\n");
 		}
 
-		QLCDB(adapter, DRV, "Resetting FW\n");
+		qlcnic_api_unlock(adapter);
+
 		if (!qlcnic_start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			return;
 		}
-
 		goto err_ret;
 	}
 
-	if (adapter->fw_wait_cnt++ > (adapter->dev_init_timeo / 2)) {
-		dev_err(&adapter->pdev->dev,
-				"Waiting for device to reset timeout\n");
-		goto err_ret;
-	}
+	qlcnic_api_unlock(adapter);
 
 	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	QLCDB(adapter, HW, "Func waiting: Device state=%d\n", dev_state);
+	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
-	case QLCNIC_DEV_READY:
-		if (!qlcnic_start_firmware(adapter)) {
-			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
-			return;
-		}
+	case QLCNIC_DEV_NEED_RESET:
+		qlcnic_schedule_work(adapter,
+			qlcnic_fwinit_work, FW_POLL_DELAY);
+		return;
 	case QLCNIC_DEV_FAILED:
 		break;
 
 	default:
-		qlcnic_schedule_work(adapter,
-			qlcnic_fwinit_work, 2 * FW_POLL_DELAY);
-		return;
+		if (!qlcnic_start_firmware(adapter)) {
+			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
+			return;
+		}
 	}
 
 err_ret:
+	dev_err(&adapter->pdev->dev, "Fwinit work failed state=%u "
+		"fw_wait_cnt=%u\n", dev_state, adapter->fw_wait_cnt);
 	netif_device_attach(adapter->netdev);
 	qlcnic_clr_all_drv_state(adapter);
 }
@@ -2202,6 +2211,7 @@ err_ret:
 
 }
 
+/*Transit to RESET state from READY state only */
 static void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 {
@@ -2212,10 +2222,8 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
-	if (state != QLCNIC_DEV_INITIALIZING &&
-					state != QLCNIC_DEV_NEED_RESET) {
+	if (state == QLCNIC_DEV_READY) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
-		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
 	}
 
-- 
1.6.0.2

