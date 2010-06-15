From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] cnic: Refactor and fix
 cnic_ready_to_close().
Date: Tue, 15 Jun 2010 11:57:02 -0700
Message-ID: <1276628223-27125-3-git-send-email-mchan@broadcom.com>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
 <1276628223-27125-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1449 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758250Ab0FOSyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 14:54:49 -0400
In-Reply-To: <1276628223-27125-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combine RESET_RECEIVED and RESET_COMP logic and fix race condition
between these 2 events and cnic_cm_close().  In particular, we need
to (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags)) before we
update csk->state.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 48fdbce..11eeded 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3198,25 +3198,19 @@ static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 
 static int cnic_ready_to_close(struct cnic_sock *csk, u32 opcode)
 {
-	if (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED) {
-		if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
-			csk->state = opcode;
-	}
-	if ((opcode == csk->state) ||
-	    (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED &&
-	     csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP)) {
-		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags))
-			return 1;
+	if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags)) {
+		/* Unsolicited RESET_COMP or RESET_RECEIVED */
+		opcode = L4_KCQE_OPCODE_VALUE_RESET_RECEIVED;
+		csk->state = opcode;
 	}
-	/* 57710+ only  workaround to handle unsolicited RESET_COMP
-	 * which will be treated like a RESET RCVD notification
-	 * which triggers the clean up procedure
+
+	/* 1. If event opcode matches the expected event in csk->state
+	 * 2. If the expected event is CLOSE_COMP, we accept any event
 	 */
-	else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP) {
-		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags)) {
-			csk->state = L4_KCQE_OPCODE_VALUE_RESET_RECEIVED;
+	if (opcode == csk->state ||
+	     csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP) {
+		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags))
 			return 1;
-		}
 	}
 	return 0;
 }
-- 
1.6.4.GIT


