From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/6 net-next] cnic: Add missing error checking for
 RAMROD_CMD_ID_CLOSE
Date: Sun, 28 Jul 2013 19:03:59 -0700
Message-ID: <1375063440-4016-5-git-send-email-mchan@broadcom.com>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
 <1375063440-4016-2-git-send-email-mchan@broadcom.com>
 <1375063440-4016-3-git-send-email-mchan@broadcom.com>
 <1375063440-4016-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4318 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab3G2BmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:13 -0400
In-Reply-To: <1375063440-4016-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

Completion status field should also be checked for non-zero error
condition.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 24f2a09..07ec4ce 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -4022,15 +4022,18 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		cnic_cm_upcall(cp, csk, opcode);
 		break;
 
-	case L5CM_RAMROD_CMD_ID_CLOSE:
-		if (l4kcqe->status != 0) {
-			netdev_warn(dev->netdev, "RAMROD CLOSE compl with "
-				    "status 0x%x\n", l4kcqe->status);
+	case L5CM_RAMROD_CMD_ID_CLOSE: {
+		struct iscsi_kcqe *l5kcqe = (struct iscsi_kcqe *) kcqe;
+
+		if (l4kcqe->status != 0 || l5kcqe->completion_status != 0) {
+			netdev_warn(dev->netdev, "RAMROD CLOSE compl with status 0x%x completion status 0x%x\n",
+				    l4kcqe->status, l5kcqe->completion_status);
 			opcode = L4_KCQE_OPCODE_VALUE_CLOSE_COMP;
 			/* Fall through */
 		} else {
 			break;
 		}
+	}
 	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
-- 
1.7.1
