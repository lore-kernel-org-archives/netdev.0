From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 1/6] qlcnic: fix chip reset logic
Date: Thu, 14 Jul 2011 06:16:50 -0700
Message-ID: <1310649415-14787-2-git-send-email-amit.salecha@qlogic.com>
References: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:44909 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754883Ab1GNNZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:25:49 -0400
In-Reply-To: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Chip reset logic (IDC logic) has changed with fw dump support.
This broked compatibility with driver using older IDC logic.
Changes to make it compatible with drivers using older IDC logic.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 357436b..6b646c6 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2811,6 +2811,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 	struct qlcnic_adapter *adapter = container_of(work,
 			struct qlcnic_adapter, fw_work.work);
 	u32 dev_state = 0xf;
+	u32 val;
 
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
@@ -2837,11 +2838,6 @@ qlcnic_fwinit_work(struct work_struct *work)
 
 	if (!qlcnic_check_drv_state(adapter)) {
 skip_ack_check:
-		if (!(adapter->flags & QLCNIC_FW_RESET_OWNER)) {
-			qlcnic_api_unlock(adapter);
-			goto wait_npar;
-		}
-
 		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
@@ -2850,17 +2846,22 @@ skip_ack_check:
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
+			val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+			QLC_DEV_SET_RST_RDY(val, adapter->portnum);
+			QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
 		}
 
 		qlcnic_api_unlock(adapter);
 
 		rtnl_lock();
-		if (adapter->ahw->fw_dump.enable) {
+		if (adapter->ahw->fw_dump.enable &&
+		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
 			QLCDB(adapter, DRV, "Take FW dump\n");
 			qlcnic_dump_fw(adapter);
-			adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		}
 		rtnl_unlock();
+
+		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			adapter->fw_wait_cnt = 0;
-- 
1.7.3.3

