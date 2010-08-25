From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/4] qlcnic: fix fw recovery for PF
Date: Wed, 25 Aug 2010 07:03:04 -0700
Message-ID: <1282744985-31540-4-git-send-email-amit.salecha@qlogic.com>
References: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56386 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753946Ab0HYODG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 10:03:06 -0400
In-Reply-To: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Privilege function should wait for npar state to be operational
before creating context.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 0892122..26d9e10 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -997,11 +997,7 @@ check_fw_status:
 set_dev_ready:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-	err = qlcnic_check_npar_opertional(adapter);
-	if (err) {
-		qlcnic_release_firmware(adapter);
-		return err;
-	}
+
 	if (qlcnic_set_default_offload_settings(adapter))
 		goto err_out;
 	if (qlcnic_reset_npar_config(adapter))
@@ -2602,6 +2598,7 @@ skip_ack_check:
 
 		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
+			adapter->fw_wait_cnt = 0;
 			return;
 		}
 		goto err_ret;
@@ -2617,6 +2614,7 @@ wait_npar:
 	case QLCNIC_DEV_READY:
 		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
+			adapter->fw_wait_cnt = 0;
 			return;
 		}
 	case QLCNIC_DEV_FAILED:
@@ -2750,7 +2748,21 @@ qlcnic_attach_work(struct work_struct *work)
 	struct qlcnic_adapter *adapter = container_of(work,
 				struct qlcnic_adapter, fw_work.work);
 	struct net_device *netdev = adapter->netdev;
+	u32 npar_state;
 
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC) {
+		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
+			qlcnic_clr_all_drv_state(adapter, 0);
+		else if (npar_state != QLCNIC_DEV_NPAR_OPER)
+			qlcnic_schedule_work(adapter, qlcnic_attach_work,
+							FW_POLL_DELAY);
+		else
+			goto attach;
+		QLCDB(adapter, DRV, "Waiting for NPAR state to operational\n");
+		return;
+	}
+attach:
 	if (netif_running(netdev)) {
 		if (qlcnic_up(adapter, netdev))
 			goto done;
-- 
1.6.0.2

