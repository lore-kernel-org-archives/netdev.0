From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] cnic: Fix cnic_cm_abort() error handling.
Date: Tue, 15 Jun 2010 11:57:03 -0700
Message-ID: <1276628223-27125-4-git-send-email-mchan@broadcom.com>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
 <1276628223-27125-2-git-send-email-mchan@broadcom.com>
 <1276628223-27125-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1446 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758253Ab0FOSyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 14:54:49 -0400
In-Reply-To: <1276628223-27125-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the code that handles the error case when cnic_cm_abort() cannot
proceed normally.  We cannot just set the csk->state and we must
go through cnic_ready_to_close() to handle all the conditions.  We
also add error return code in cnic_cm_abort().

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 11eeded..e5539f0 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2996,7 +2996,7 @@ err_out:
 static int cnic_cm_abort(struct cnic_sock *csk)
 {
 	struct cnic_local *cp = csk->dev->cnic_priv;
-	u32 opcode;
+	u32 opcode = L4_KCQE_OPCODE_VALUE_RESET_COMP;
 
 	if (!cnic_in_use(csk))
 		return -EINVAL;
@@ -3008,12 +3008,9 @@ static int cnic_cm_abort(struct cnic_sock *csk)
 	 * connect was not successful.
 	 */
 
-	csk->state = L4_KCQE_OPCODE_VALUE_RESET_COMP;
-	if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
-		opcode = csk->state;
-	else
-		opcode = L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD;
 	cp->close_conn(csk, opcode);
+	if (csk->state != opcode)
+		return -EALREADY;
 
 	return 0;
 }
@@ -3206,11 +3203,16 @@ static int cnic_ready_to_close(struct cnic_sock *csk, u32 opcode)
 
 	/* 1. If event opcode matches the expected event in csk->state
 	 * 2. If the expected event is CLOSE_COMP, we accept any event
+	 * 3. If the expected event is 0, meaning the connection was never
+	 *    never established, we accept the opcode from cm_abort.
 	 */
-	if (opcode == csk->state ||
-	     csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP) {
-		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags))
+	if (opcode == csk->state || csk->state == 0 ||
+	    csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP) {
+		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags)) {
+			if (csk->state == 0)
+				csk->state = opcode;
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -3227,6 +3229,7 @@ static void cnic_close_bnx2_conn(struct cnic_sock *csk, u32 opcode)
 
 	clear_bit(SK_F_CONNECT_START, &csk->flags);
 	cnic_close_conn(csk);
+	csk->state = opcode;
 	cnic_cm_upcall(cp, csk, opcode);
 }
 
@@ -3256,8 +3259,12 @@ static void cnic_close_bnx2x_conn(struct cnic_sock *csk, u32 opcode)
 	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
-		if (cnic_ready_to_close(csk, opcode))
-			cmd = L5CM_RAMROD_CMD_ID_SEARCHER_DELETE;
+		if (cnic_ready_to_close(csk, opcode)) {
+			if (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+				cmd = L5CM_RAMROD_CMD_ID_SEARCHER_DELETE;
+			else
+				close_complete = 1;
+		}
 		break;
 	case L5CM_RAMROD_CMD_ID_SEARCHER_DELETE:
 		cmd = L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD;
-- 
1.6.4.GIT


