From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 6/8] qlge: Improve handling for firmware init failure.
Date: Tue,  3 Mar 2009 14:10:35 -0800
Message-ID: <1236118237-14483-7-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761763AbZCCWN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:59 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This event will arrive at boot time or after an
MPI processor reset if the firmware failed to initialize.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 3a660f9..2c1d220 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -395,7 +395,25 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		ql_sfp_out(qdev, mbcp);
 		break;
 
+	/* This event can arrive at boot time or after an
+	 * MPI reset if the firmware failed to initialize.
+	 */
 	case AEN_FW_INIT_FAIL:
+		/* If we're in process on executing the firmware,
+		 * then convert the status to normal mailbox status.
+		 */
+		if (mbcp->mbox_in[0] == MB_CMD_EX_FW) {
+			mbcp->out_count = orig_count;
+			status = ql_get_mb_sts(qdev, mbcp);
+			mbcp->mbox_out[0] = MB_CMD_STS_ERR;
+			return status;
+		}
+		QPRINTK(qdev, DRV, ERR,
+			"Firmware initialization failed.\n");
+		status = -EIO;
+		ql_queue_fw_error(qdev);
+		break;
+
 	case AEN_SYS_ERR:
 		ql_queue_fw_error(qdev);
 		break;
-- 
1.6.0.2

