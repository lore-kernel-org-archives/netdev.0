From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/8] qlge: Clean up event handler for firmware init.
Date: Tue,  3 Mar 2009 14:10:34 -0800
Message-ID: <1236118237-14483-6-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760417AbZCCWN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:57 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 9f1fe54..3a660f9 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -286,20 +286,21 @@ static int ql_sfp_out(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
+	int status;
+
 	mbcp->out_count = 2;
 
-	if (ql_get_mb_sts(qdev, mbcp)) {
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status) {
 		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
-		goto exit;
+	} else {
+		QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
+			mbcp->mbox_out[1]);
+		status = ql_cam_route_initialize(qdev);
+		if (status)
+			QPRINTK(qdev, IFUP, ERR,
+				"Failed to init CAM/Routing tables.\n");
 	}
-	QPRINTK(qdev, DRV, ERR, "Firmware initialized!\n");
-	QPRINTK(qdev, DRV, ERR, "Firmware status = 0x%.08x.\n",
-		mbcp->mbox_out[0]);
-	QPRINTK(qdev, DRV, ERR, "Firmware Revision  = 0x%.08x.\n",
-		mbcp->mbox_out[1]);
-exit:
-	/* Clear the MPI firmware status. */
-	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
 }
 
 /* Process an async event and clear it unless it's an
@@ -374,6 +375,15 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		break;
 
 	case AEN_FW_INIT_DONE:
+		/* If we're in process on executing the firmware,
+		 * then convert the status to normal mailbox status.
+		 */
+		if (mbcp->mbox_in[0] == MB_CMD_EX_FW) {
+			mbcp->out_count = orig_count;
+			status = ql_get_mb_sts(qdev, mbcp);
+			mbcp->mbox_out[0] = MB_CMD_STS_GOOD;
+			return status;
+		}
 		ql_init_fw_done(qdev, mbcp);
 		break;
 
-- 
1.6.0.2

