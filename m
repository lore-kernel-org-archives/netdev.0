From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: handle interrupt raised when FW crashes
Date: Thu,  8 Jun 2017 13:43:21 +0530
Message-ID: <1496909601-29370-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:35936 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdFHINq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>

Handle TIMER0INT when FW crashes. Check for PCIE_FW[FW_EVAL]
and if it says "Device FW Crashed", then treat it as fatal.
Else, non-fatal.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c    | 19 ++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h  |  4 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  4 ++++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index da1322d..4fd5010 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4040,6 +4040,7 @@ static void cim_intr_handler(struct adapter *adapter)
 		{ MBHOSTPARERR_F, "CIM mailbox host parity error", -1, 1 },
 		{ TIEQINPARERRINT_F, "CIM TIEQ outgoing parity error", -1, 1 },
 		{ TIEQOUTPARERRINT_F, "CIM TIEQ incoming parity error", -1, 1 },
+		{ TIMER0INT_F, "CIM TIMER0 interrupt", -1, 1 },
 		{ 0 }
 	};
 	static const struct intr_info cim_upintr_info[] = {
@@ -4075,10 +4076,26 @@ static void cim_intr_handler(struct adapter *adapter)
 	};
 
 	int fat;
+	u32 val, fw_err;
 
-	if (t4_read_reg(adapter, PCIE_FW_A) & PCIE_FW_ERR_F)
+	fw_err = t4_read_reg(adapter, PCIE_FW_A);
+	if (fw_err & PCIE_FW_ERR_F)
 		t4_report_fw_error(adapter);
 
+	/* When the Firmware detects an internal error which normally
+	 * wouldn't raise a Host Interrupt, it forces a CIM Timer0 interrupt
+	 * in order to make sure the Host sees the Firmware Crash.  So
+	 * if we have a Timer0 interrupt and don't see a Firmware Crash,
+	 * ignore the Timer0 interrupt.
+	 */
+
+	val = t4_read_reg(adapter, CIM_HOST_INT_CAUSE_A);
+	if (val & TIMER0INT_F)
+		if (!(fw_err & PCIE_FW_ERR_F) ||
+		    (PCIE_FW_EVAL_G(fw_err) != PCIE_FW_EVAL_CRASH))
+			t4_write_reg(adapter, CIM_HOST_INT_CAUSE_A,
+				     TIMER0INT_F);
+
 	fat = t4_handle_intr_status(adapter, CIM_HOST_INT_CAUSE_A,
 				    cim_intr_info) +
 	      t4_handle_intr_status(adapter, CIM_HOST_UPACC_INT_CAUSE_A,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3348d33..3884336 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1077,6 +1077,10 @@
 #define TIEQINPARERRINT_V(x) ((x) << TIEQINPARERRINT_S)
 #define TIEQINPARERRINT_F    TIEQINPARERRINT_V(1U)
 
+#define TIMER0INT_S    2
+#define TIMER0INT_V(x) ((x) << TIMER0INT_S)
+#define TIMER0INT_F    TIMER0INT_V(1U)
+
 #define PREFDROPINT_S    1
 #define PREFDROPINT_V(x) ((x) << PREFDROPINT_S)
 #define PREFDROPINT_F    PREFDROPINT_V(1U)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index c65c33c..f47461a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -3088,6 +3088,10 @@ struct fw_debug_cmd {
 #define FW_DEBUG_CMD_TYPE_G(x)	\
 	(((x) >> FW_DEBUG_CMD_TYPE_S) & FW_DEBUG_CMD_TYPE_M)
 
+enum pcie_fw_eval {
+	PCIE_FW_EVAL_CRASH = 0,
+};
+
 #define PCIE_FW_ERR_S		31
 #define PCIE_FW_ERR_V(x)	((x) << PCIE_FW_ERR_S)
 #define PCIE_FW_ERR_F		PCIE_FW_ERR_V(1U)
-- 
2.1.0
