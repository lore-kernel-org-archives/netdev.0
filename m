From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/7] qlcnic: support quiescent mode
Date: Fri,  8 Oct 2010 02:46:06 -0700
Message-ID: <1286531171-21173-3-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:59297 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754648Ab0JHJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:12 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put device in quiescent mode during internal loopback test.
Before running test, set state to NEED_QUISCENT. After getting
ack from all function, change state to QUISCENT and perform test.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    2 +
 drivers/net/qlcnic/qlcnic_ethtool.c |    6 +++
 drivers/net/qlcnic/qlcnic_main.c    |   83 +++++++++++++++++++++++++++-------
 3 files changed, 74 insertions(+), 17 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index a1fabdc..6909cfc 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1313,6 +1313,8 @@ int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter);
 void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
 
 /* Functions from qlcnic_main.c */
+int qlcnic_request_quiscent_mode(struct qlcnic_adapter *adapter);
+void qlcnic_clear_quiscent_mode(struct qlcnic_adapter *adapter);
 int qlcnic_reset_context(struct qlcnic_adapter *);
 u32 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 6a76014..0181301 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -706,6 +706,11 @@ static int qlcnic_loopback_test(struct net_device *netdev)
 	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		return -EIO;
 
+	if (qlcnic_request_quiscent_mode(adapter)) {
+		clear_bit(__QLCNIC_RESETTING, &adapter->state);
+		return -EIO;
+	}
+
 	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST);
 	if (ret)
 		goto clear_it;
@@ -722,6 +727,7 @@ done:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
 
 clear_it:
+	qlcnic_clear_quiscent_mode(adapter);
 	adapter->max_sds_rings = max_sds_rings;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return ret;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 7503c48..9b0acfb 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2712,7 +2712,8 @@ qlcnic_fwinit_work(struct work_struct *work)
 		goto err_ret;
 
 	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (dev_state ==  QLCNIC_DEV_QUISCENT) {
+	if (dev_state == QLCNIC_DEV_QUISCENT ||
+	    dev_state == QLCNIC_DEV_NEED_QUISCENT) {
 		qlcnic_api_unlock(adapter);
 		qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
 						FW_POLL_DELAY * 2);
@@ -2734,18 +2735,6 @@ qlcnic_fwinit_work(struct work_struct *work)
 skip_ack_check:
 		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
-		if (dev_state == QLCNIC_DEV_NEED_QUISCENT) {
-			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
-						QLCNIC_DEV_QUISCENT);
-			qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
-						FW_POLL_DELAY * 2);
-			QLCDB(adapter, DRV, "Quiscing the driver\n");
-			qlcnic_idc_debug_info(adapter, 0);
-
-			qlcnic_api_unlock(adapter);
-			return;
-		}
-
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
 			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
 						QLCNIC_DEV_INITIALIZING);
@@ -2802,7 +2791,12 @@ qlcnic_detach_work(struct work_struct *work)
 
 	netif_device_detach(netdev);
 
-	qlcnic_down(adapter, netdev);
+	/* Dont grab rtnl lock during Quiscent mode */
+	if (adapter->dev_state == QLCNIC_DEV_NEED_QUISCENT) {
+		if (netif_running(netdev))
+			__qlcnic_down(adapter, netdev);
+	} else
+		qlcnic_down(adapter, netdev);
 
 	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
 
@@ -2844,6 +2838,61 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 	qlcnic_api_unlock(adapter);
 }
 
+/* Caller should held RESETTING bit.
+ * This should be call in sync with qlcnic_request_quiscent_mode.
+ */
+void qlcnic_clear_quiscent_mode(struct qlcnic_adapter *adapter)
+{
+	qlcnic_clr_drv_state(adapter);
+	qlcnic_api_lock(adapter);
+	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	qlcnic_api_unlock(adapter);
+}
+
+/* Caller should held RESETTING bit.
+ */
+int qlcnic_request_quiscent_mode(struct qlcnic_adapter *adapter)
+{
+	u8 timeo = adapter->dev_init_timeo / 2;
+	u32 state;
+
+	if (qlcnic_api_lock(adapter))
+		return -EIO;
+
+	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state != QLCNIC_DEV_READY)
+		return -EIO;
+
+	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_QUISCENT);
+	qlcnic_api_unlock(adapter);
+	QLCDB(adapter, DRV, "NEED QUISCENT state set\n");
+	qlcnic_idc_debug_info(adapter, 0);
+
+	qlcnic_set_drv_state(adapter, QLCNIC_DEV_NEED_QUISCENT);
+
+	do {
+		msleep(2000);
+		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		if (state == QLCNIC_DEV_QUISCENT)
+			return 0;
+		if (!qlcnic_check_drv_state(adapter)) {
+			if (qlcnic_api_lock(adapter))
+				return -EIO;
+			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
+							QLCNIC_DEV_QUISCENT);
+			qlcnic_api_unlock(adapter);
+			QLCDB(adapter, DRV, "QUISCENT mode set\n");
+			return 0;
+		}
+	} while (--timeo);
+
+	dev_err(&adapter->pdev->dev, "Failed to quiesce device, DRV_STATE=%08x"
+		" DRV_ACTIVE=%08x\n", QLCRD32(adapter, QLCNIC_CRB_DRV_STATE),
+		QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE));
+	qlcnic_clear_quiscent_mode(adapter);
+	return -EIO;
+}
+
 /*Transit to RESET state from READY state only */
 static void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
@@ -2951,11 +3000,11 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		qlcnic_dev_request_reset(adapter);
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state == QLCNIC_DEV_NEED_RESET ||
-	    state == QLCNIC_DEV_NEED_QUISCENT) {
+	if (state == QLCNIC_DEV_NEED_RESET) {
 		qlcnic_set_npar_non_operational(adapter);
 		adapter->need_fw_reset = 1;
-	}
+	} else if (state == QLCNIC_DEV_NEED_QUISCENT)
+		goto detach;
 
 	heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	if (heartbeat != adapter->heartbeat) {
-- 
1.6.0.2

