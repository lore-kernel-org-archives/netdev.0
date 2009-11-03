From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Add firmware/driver sub-command support.
Date: Tue,  3 Nov 2009 15:49:30 -0800
Message-ID: <1257292171-11683-3-git-send-email-ron.mercer@qlogic.com>
References: <1257292171-11683-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:59731 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbZKCXzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 18:55:52 -0500
In-Reply-To: <1257292171-11683-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These sub-commands are issued by another (FCoE) function requesting
an operation on a shared resource.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |   12 +++++++++
 drivers/net/qlge/qlge_mpi.c |   56 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 872e95e..5e4d343 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -816,6 +816,18 @@ enum {
 	MB_CMD_GET_MGMNT_TFK_CTL = 0x00000161, /* Get Mgmnt Traffic Control */
 	MB_GET_MPI_TFK_STOPPED = (1 << 0),
 	MB_GET_MPI_TFK_FIFO_EMPTY = (1 << 1),
+	/* Sub-commands for IDC request.
+	 * This describes the reason for the
+	 * IDC request.
+	 */
+	MB_CMD_IOP_NONE = 0x0000,
+	MB_CMD_IOP_PREP_UPDATE_MPI	= 0x0001,
+	MB_CMD_IOP_COMP_UPDATE_MPI	= 0x0002,
+	MB_CMD_IOP_PREP_LINK_DOWN	= 0x0010,
+	MB_CMD_IOP_DVR_START	 = 0x0100,
+	MB_CMD_IOP_FLASH_ACC	 = 0x0101,
+	MB_CMD_IOP_RESTART_MPI	= 0x0102,
+	MB_CMD_IOP_CORE_DUMP_MPI	= 0x0103,
 
 	/* Mailbox Command Status. */
 	MB_CMD_STS_GOOD = 0x00004000,	/* Success. */
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index bac7b86..f5619fe 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -1038,8 +1038,11 @@ void ql_mpi_idc_work(struct work_struct *work)
 	int status;
 	struct mbox_params *mbcp = &qdev->idc_mbc;
 	u32 aen;
+	int timeout;
 
+	rtnl_lock();
 	aen = mbcp->mbox_out[1] >> 16;
+	timeout = (mbcp->mbox_out[1] >> 8) & 0xf;
 
 	switch (aen) {
 	default:
@@ -1047,22 +1050,61 @@ void ql_mpi_idc_work(struct work_struct *work)
 			"Bug: Unhandled IDC action.\n");
 		break;
 	case MB_CMD_PORT_RESET:
-	case MB_CMD_SET_PORT_CFG:
 	case MB_CMD_STOP_FW:
 		ql_link_off(qdev);
+	case MB_CMD_SET_PORT_CFG:
 		/* Signal the resulting link up AEN
 		 * that the frame routing and mac addr
 		 * needs to be set.
 		 * */
 		set_bit(QL_CAM_RT_SET, &qdev->flags);
-		rtnl_lock();
-		status = ql_mb_idc_ack(qdev);
-		rtnl_unlock();
-		if (status) {
-			QPRINTK(qdev, DRV, ERR,
-			"Bug: No pending IDC!\n");
+		/* Do ACK if required */
+		if (timeout) {
+			status = ql_mb_idc_ack(qdev);
+			if (status)
+				QPRINTK(qdev, DRV, ERR,
+					"Bug: No pending IDC!\n");
+		} else {
+			QPRINTK(qdev, DRV, DEBUG,
+				    "IDC ACK not required\n");
+			status = 0; /* success */
+		}
+		break;
+
+	/* These sub-commands issued by another (FCoE)
+	 * function are requesting to do an operation
+	 * on the shared resource (MPI environment).
+	 * We currently don't issue these so we just
+	 * ACK the request.
+	 */
+	case MB_CMD_IOP_RESTART_MPI:
+	case MB_CMD_IOP_PREP_LINK_DOWN:
+		/* Drop the link, reload the routing
+		 * table when link comes up.
+		 */
+		ql_link_off(qdev);
+		set_bit(QL_CAM_RT_SET, &qdev->flags);
+		/* Fall through. */
+	case MB_CMD_IOP_DVR_START:
+	case MB_CMD_IOP_FLASH_ACC:
+	case MB_CMD_IOP_CORE_DUMP_MPI:
+	case MB_CMD_IOP_PREP_UPDATE_MPI:
+	case MB_CMD_IOP_COMP_UPDATE_MPI:
+	case MB_CMD_IOP_NONE:	/*  an IDC without params */
+		/* Do ACK if required */
+		if (timeout) {
+			status = ql_mb_idc_ack(qdev);
+			if (status)
+				QPRINTK(qdev, DRV, ERR,
+				    "Bug: No pending IDC!\n");
+		} else {
+			QPRINTK(qdev, DRV, DEBUG,
+			    "IDC ACK not required\n");
+			status = 0; /* success */
 		}
+		break;
 	}
+	rtnl_unlock();
 }
 
 void ql_mpi_work(struct work_struct *work)
-- 
1.6.0.2

