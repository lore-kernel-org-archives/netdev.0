From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/8] qlcnic: device state management fixes for virtual func
Date: Wed, 11 Aug 2010 05:05:23 -0700
Message-ID: <1281528329-8812-3-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9643 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751370Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o NPAR state should be set to operationl by Mangement function only.
o NPAR state should be set to non operational before device reset.
o VF function should wait for NPAR state to be operational.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hdr.h  |    5 +-
 drivers/net/qlcnic/qlcnic_main.c |   80 +++++++++++++++++++++++---------------
 2 files changed, 51 insertions(+), 34 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 15fc320..bd346d9 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -718,8 +718,9 @@ enum {
 #define QLCNIC_DEV_FAILED		0x6
 #define QLCNIC_DEV_QUISCENT		0x7
 
-#define QLCNIC_DEV_NPAR_NOT_RDY	0
-#define QLCNIC_DEV_NPAR_RDY		1
+#define QLCNIC_DEV_NPAR_NON_OPER	0 /* NON Operational */
+#define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
+#define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
 #define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) &= (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9cc8732..bac2371 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2388,7 +2388,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 {
 	struct qlcnic_adapter *adapter = container_of(work,
 			struct qlcnic_adapter, fw_work.work);
-	u32 dev_state = 0xf, npar_state;
+	u32 dev_state = 0xf;
 
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
@@ -2402,16 +2402,8 @@ qlcnic_fwinit_work(struct work_struct *work)
 	}
 
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
-		if (npar_state == QLCNIC_DEV_NPAR_RDY) {
-			qlcnic_api_unlock(adapter);
-			goto wait_npar;
-		} else {
-			qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
-				FW_POLL_DELAY);
-			qlcnic_api_unlock(adapter);
-			return;
-		}
+		qlcnic_api_unlock(adapter);
+		goto wait_npar;
 	}
 
 	if (adapter->fw_wait_cnt++ > adapter->reset_ack_timeo) {
@@ -2460,20 +2452,17 @@ wait_npar:
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
-	case QLCNIC_DEV_QUISCENT:
-	case QLCNIC_DEV_NEED_QUISCENT:
-	case QLCNIC_DEV_NEED_RESET:
-		qlcnic_schedule_work(adapter,
-			qlcnic_fwinit_work, FW_POLL_DELAY);
-		return;
-	case QLCNIC_DEV_FAILED:
-		break;
-
-	default:
+	case QLCNIC_DEV_READY:
 		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			return;
 		}
+	case QLCNIC_DEV_FAILED:
+		break;
+	default:
+		qlcnic_schedule_work(adapter,
+			qlcnic_fwinit_work, FW_POLL_DELAY);
+		return;
 	}
 
 err_ret:
@@ -2520,6 +2509,22 @@ err_ret:
 
 }
 
+/*Transit NPAR state to NON Operational */
+static void
+qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
+{
+	u32 state;
+
+	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	if (state == QLCNIC_DEV_NPAR_NON_OPER)
+		return;
+
+	if (qlcnic_api_lock(adapter))
+		return;
+	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	qlcnic_api_unlock(adapter);
+}
+
 /*Transit to RESET state from READY state only */
 static void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
@@ -2538,6 +2543,7 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
+	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -2545,21 +2551,14 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 static void
 qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 {
-	u32 state;
-
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-		adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+		adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
-
-	if (state != QLCNIC_DEV_NPAR_RDY) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
-			QLCNIC_DEV_NPAR_RDY);
-		QLCDB(adapter, DRV, "NPAR READY state set\n");
-	}
+	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
+	QLCDB(adapter, DRV, "NPAR operational state set\n");
 
 	qlcnic_api_unlock(adapter);
 }
@@ -2621,8 +2620,11 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		qlcnic_dev_request_reset(adapter);
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state == QLCNIC_DEV_NEED_RESET || state == QLCNIC_DEV_NEED_QUISCENT)
+	if (state == QLCNIC_DEV_NEED_RESET ||
+	    state == QLCNIC_DEV_NEED_QUISCENT) {
+		qlcnic_set_npar_non_operational(adapter);
 		adapter->need_fw_reset = 1;
+	}
 
 	heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	if (heartbit != adapter->heartbit) {
@@ -2812,11 +2814,25 @@ static int
 qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
+	u8 npar_opt_timeo = QLCNIC_DEV_NPAR_OPER_TIMEO;
+	u32 npar_state;
 
 	err = qlcnic_can_start_firmware(adapter);
 	if (err)
 		return err;
 
+	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
+		msleep(1000);
+		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	}
+
+	if (!npar_opt_timeo) {
+		dev_err(&adapter->pdev->dev,
+			"Waiting for NPAR state to opertional timeout\n");
+		return -EIO;
+	}
+
 	qlcnic_check_options(adapter);
 
 	adapter->need_fw_reset = 0;
-- 
1.6.0.2

