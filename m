From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net v2 1/2] qlcnic: Remove unnecessary usage of atomic_t
Date: Tue, 8 Mar 2016 02:39:57 -0500
Message-ID: <1457422798-17981-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1871 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753842AbcCHIU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 03:20:28 -0500
In-Reply-To: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o atomic_t usage is incorrect as we are not implementing
any atomicity.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 9 ++++-----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 46bbea8..d18667b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1099,7 +1099,7 @@ struct qlcnic_mailbox {
 	unsigned long		status;
 	spinlock_t		queue_lock;	/* Mailbox queue lock */
 	spinlock_t		aen_lock;	/* Mailbox response/AEN lock */
-	atomic_t		rsp_status;
+	u32			rsp_status;
 	u32			num_cmds;
 };
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 37a731b..e3d1bb7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -491,7 +491,7 @@ irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 
 static inline void qlcnic_83xx_notify_mbx_response(struct qlcnic_mailbox *mbx)
 {
-	atomic_set(&mbx->rsp_status, QLC_83XX_MBX_RESPONSE_ARRIVED);
+	mbx->rsp_status = QLC_83XX_MBX_RESPONSE_ARRIVED;
 	complete(&mbx->completion);
 }
 
@@ -510,7 +510,7 @@ static void qlcnic_83xx_poll_process_aen(struct qlcnic_adapter *adapter)
 	if (event &  QLCNIC_MBX_ASYNC_EVENT) {
 		__qlcnic_83xx_process_aen(adapter);
 	} else {
-		if (atomic_read(&mbx->rsp_status) != rsp_status)
+		if (mbx->rsp_status != rsp_status)
 			qlcnic_83xx_notify_mbx_response(mbx);
 	}
 out:
@@ -1023,7 +1023,7 @@ static void qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 		if (event &  QLCNIC_MBX_ASYNC_EVENT) {
 			__qlcnic_83xx_process_aen(adapter);
 		} else {
-			if (atomic_read(&mbx->rsp_status) != rsp_status)
+			if (mbx->rsp_status != rsp_status)
 				qlcnic_83xx_notify_mbx_response(mbx);
 		}
 	}
@@ -4050,7 +4050,6 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 	struct qlcnic_adapter *adapter = mbx->adapter;
 	const struct qlcnic_mbx_ops *mbx_ops = mbx->ops;
 	struct device *dev = &adapter->pdev->dev;
-	atomic_t *rsp_status = &mbx->rsp_status;
 	struct list_head *head = &mbx->cmd_q;
 	struct qlcnic_hardware_context *ahw;
 	struct qlcnic_cmd_args *cmd = NULL;
@@ -4063,7 +4062,7 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 			return;
 		}
 
-		atomic_set(rsp_status, QLC_83XX_MBX_RESPONSE_WAIT);
+		mbx->rsp_status = QLC_83XX_MBX_RESPONSE_WAIT;
 
 		spin_lock(&mbx->queue_lock);
 
-- 
1.8.3.1
