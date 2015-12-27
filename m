From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 01/12] bnxt_en: support hwrm_func_drv_unrgtr command
Date: Sun, 27 Dec 2015 18:19:18 -0500
Message-ID: <1451258369-21543-2-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:39628 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbbL0XTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:32 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

During remove_one, the driver should issue hwrm_func_drv_unrgtr
command to inform firmware that this function has been unloaded.
This is to let firmware keep track of driver present/absent state
when driver is gracefully unloaded. A keep alive timer is needed
later to keep track of driver state during abnormal shutdown.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 443ef92..8d401e8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2710,6 +2710,14 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
+static int bnxt_hwrm_func_drv_unrgtr(struct bnxt *bp)
+{
+	struct hwrm_func_drv_unrgtr_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_DRV_UNRGTR, -1, -1);
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
 static int bnxt_hwrm_tunnel_dst_port_free(struct bnxt *bp, u8 tunnel_type)
 {
 	u32 rc = 0;
@@ -5549,6 +5557,7 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	cancel_work_sync(&bp->sp_task);
 	bp->sp_event = 0;
 
+	bnxt_hwrm_func_drv_unrgtr(bp);
 	bnxt_free_hwrm_resources(bp);
 	pci_iounmap(pdev, bp->bar2);
 	pci_iounmap(pdev, bp->bar1);
-- 
1.8.3.1
