From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] cnic: Refactor code in
 cnic_cm_process_kcqe().
Date: Tue, 15 Jun 2010 11:57:01 -0700
Message-ID: <1276628223-27125-2-git-send-email-mchan@broadcom.com>
References: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2834 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754624Ab0FOSzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 14:55:01 -0400
In-Reply-To: <1276628223-27125-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move chip-specific code to the respective chip's ->close_conn() functions
for better code organization.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index b20e11c..48fdbce 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3143,12 +3143,6 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		break;
 
 	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
-		if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
-			cnic_cm_upcall(cp, csk, opcode);
-			break;
-		} else if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
-			csk->state = opcode;
-		/* fall through */
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
 	case L5CM_RAMROD_CMD_ID_SEARCHER_DELETE:
@@ -3204,6 +3198,10 @@ static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 
 static int cnic_ready_to_close(struct cnic_sock *csk, u32 opcode)
 {
+	if (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED) {
+		if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
+			csk->state = opcode;
+	}
 	if ((opcode == csk->state) ||
 	    (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED &&
 	     csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP)) {
@@ -3228,6 +3226,11 @@ static void cnic_close_bnx2_conn(struct cnic_sock *csk, u32 opcode)
 	struct cnic_dev *dev = csk->dev;
 	struct cnic_local *cp = dev->cnic_priv;
 
+	if (opcode == L4_KCQE_OPCODE_VALUE_RESET_RECEIVED) {
+		cnic_cm_upcall(cp, csk, opcode);
+		return;
+	}
+
 	clear_bit(SK_F_CONNECT_START, &csk->flags);
 	cnic_close_conn(csk);
 	cnic_cm_upcall(cp, csk, opcode);
-- 
1.6.4.GIT


