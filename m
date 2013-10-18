From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v4 3/8] qlcnic: Firmware dump collection when auto recovery is disabled.
Date: Fri, 18 Oct 2013 12:22:30 -0400
Message-ID: <2d006c733f4e529fe8f40be671e59d407faf442d.1382090311.git.himanshu.madhani@qlogic.com>
References: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12258 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756529Ab3JRQxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 12:53:14 -0400
In-Reply-To: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

o Allow collecting the firmware dump of halted firmware when auto
  recovery is disabled.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 11 +++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  7 ++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index f09e787..d303fab 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -818,6 +818,7 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_mailbox *mbx = ahw->mailbox;
 	int ret = 0;
+	u32 owner;
 	u32 val;
 
 	/* Perform NIC configuration based ready state entry actions */
@@ -846,6 +847,10 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
 			clear_bit(QLC_83XX_MBX_READY, &mbx->status);
 			set_bit(__QLCNIC_RESETTING, &adapter->state);
 			qlcnic_83xx_idc_enter_need_reset_state(adapter, 1);
+		}  else {
+			owner = qlcnic_83xx_idc_find_reset_owner_id(adapter);
+			if (ahw->pci_func == owner)
+				qlcnic_dump_fw(adapter);
 		}
 		return -EIO;
 	}
@@ -1058,6 +1063,12 @@ void qlcnic_83xx_idc_poll_dev_state(struct work_struct *work)
 	adapter->ahw->idc.prev_state = adapter->ahw->idc.curr_state;
 	qlcnic_83xx_periodic_tasks(adapter);
 
+	/* Do not reschedule if firmaware is in hanged state and auto
+	 * recovery is disabled
+	 */
+	if ((adapter->flags & QLCNIC_FW_HANG) && !qlcnic_auto_fw_reset)
+		return;
+
 	/* Re-schedule the function */
 	if (test_bit(QLC_83XX_MODULE_LOADED, &adapter->ahw->idc.status))
 		qlcnic_schedule_work(adapter, qlcnic_83xx_idc_poll_dev_state,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 55e8b23..5195972 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3353,6 +3353,8 @@ done:
 static int
 qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
 	u32 state = 0, heartbeat;
 	u32 peg_status;
 	int err = 0;
@@ -3377,7 +3379,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->ahw->reset_context && qlcnic_auto_fw_reset)
+		if (ahw->reset_context && qlcnic_auto_fw_reset)
 			qlcnic_reset_hw_context(adapter);
 
 		return 0;
@@ -3420,6 +3422,9 @@ detach:
 
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
 		QLCDB(adapter, DRV, "fw recovery scheduled.\n");
+	} else if (!qlcnic_auto_fw_reset && fw_dump->enable &&
+		   adapter->flags & QLCNIC_FW_RESET_OWNER) {
+		qlcnic_dump_fw(adapter);
 	}
 
 	return 1;
-- 
1.8.1.4
