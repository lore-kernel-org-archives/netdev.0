From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 8/8] qlge: Add support for lost firmware events.
Date: Tue,  3 Mar 2009 14:10:37 -0800
Message-ID: <1236118237-14483-9-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449AbZCCWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:14:05 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the firmware is issuing events to the driver the events
must be removed from the queue.  If the queue overflows, the
firmware will build and special event that captures those that
are lost.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index f9a2371..9f81b79 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -284,6 +284,27 @@ static int ql_sfp_out(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	return status;
 }
 
+static int ql_aen_lost(struct ql_adapter *qdev, struct mbox_params *mbcp)
+{
+	int status;
+
+	mbcp->out_count = 6;
+
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status)
+		QPRINTK(qdev, DRV, ERR, "Lost AEN broken!\n");
+	else {
+		int i;
+		QPRINTK(qdev, DRV, ERR, "Lost AEN detected.\n");
+		for (i = 0; i < mbcp->out_count; i++)
+			QPRINTK(qdev, DRV, ERR, "mbox_out[%d] = 0x%.08x.\n",
+					i, mbcp->mbox_out[i]);
+
+	}
+
+	return status;
+}
+
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status;
@@ -421,6 +442,10 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		status = -EIO;
 		break;
 
+	case AEN_AEN_LOST:
+		ql_aen_lost(qdev, mbcp);
+		break;
+
 	default:
 		QPRINTK(qdev, DRV, ERR,
 			"Unsupported AE %.08x.\n", mbcp->mbox_out[0]);
-- 
1.6.0.2

