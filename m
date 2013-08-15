From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Flush mailbox command list when mailbox is not available
Date: Thu, 15 Aug 2013 08:27:26 -0400
Message-ID: <1376569649-565-3-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41496 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753248Ab3HONJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:09:29 -0400
In-Reply-To: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Driver was hitting a panic at the time of adapter reset due to invalid command
  access from the list which had been already freed by the queuing thread.
  Flush all the pending commands from the list before proceeding with adapter reset

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 55a5977..43b51a0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3515,6 +3515,8 @@ static inline void qlcnic_83xx_flush_mbx_queue(struct qlcnic_adapter *adapter)
 
 	while (!list_empty(head)) {
 		cmd = list_entry(head->next, struct qlcnic_cmd_args, list);
+		dev_info(&adapter->pdev->dev, "%s: Mailbox command 0x%x\n",
+			 __func__, cmd->cmd_op);
 		list_del(&cmd->list);
 		mbx->num_cmds--;
 		qlcnic_83xx_notify_cmd_completion(adapter, cmd);
@@ -3534,6 +3536,7 @@ static inline int qlcnic_83xx_check_mbx_status(struct qlcnic_adapter *adapter)
 
 	host_mbx_ctrl = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
 	if (host_mbx_ctrl) {
+		clear_bit(QLC_83XX_MBX_READY, &mbx->status);
 		ahw->idc.collect_dump = 1;
 		return -EIO;
 	}
@@ -3704,8 +3707,10 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 	ahw = adapter->ahw;
 
 	while (true) {
-		if (qlcnic_83xx_check_mbx_status(adapter))
+		if (qlcnic_83xx_check_mbx_status(adapter)) {
+			qlcnic_83xx_flush_mbx_queue(adapter);
 			return;
+		}
 
 		atomic_set(rsp_status, QLC_83XX_MBX_RESPONSE_WAIT);
 
-- 
1.8.1.4
