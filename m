From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/6] cnic: Finetune iSCSI connection reset.
Date: Wed, 24 Feb 2010 16:42:05 -0800
Message-ID: <1267058529-18454-2-git-send-email-mchan@broadcom.com>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3608 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758688Ab0BYAct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:49 -0500
In-Reply-To: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <waie@broadcom.com>

For bnx2 devices, always send notification to bnx2i to let it initiate
the cleanup when RST is received.

For bnx2x devices, add unsolicited RST_COMP handling to start the cleanup.

Signed-off-by: Eddie Wai <waie@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 0fe8371..40865aa 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3108,7 +3108,10 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		break;
 
 	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
-		if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
+		if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+			cnic_cm_upcall(cp, csk, opcode);
+			break;
+		} else if (test_and_clear_bit(SK_F_OFFLD_COMPLETE, &csk->flags))
 			csk->state = opcode;
 		/* fall through */
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
@@ -3172,6 +3175,16 @@ static int cnic_ready_to_close(struct cnic_sock *csk, u32 opcode)
 		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags))
 			return 1;
 	}
+	/* 57710+ only  workaround to handle unsolicited RESET_COMP
+	 * which will be treated like a RESET RCVD notification
+	 * which triggers the clean up procedure
+	 */
+	else if (opcode == L4_KCQE_OPCODE_VALUE_RESET_COMP) {
+		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags)) {
+			csk->state = L4_KCQE_OPCODE_VALUE_RESET_RECEIVED;
+			return 1;
+		}
+	}
 	return 0;
 }
 
@@ -3181,10 +3194,8 @@ static void cnic_close_bnx2_conn(struct cnic_sock *csk, u32 opcode)
 	struct cnic_local *cp = dev->cnic_priv;
 
 	clear_bit(SK_F_CONNECT_START, &csk->flags);
-	if (cnic_ready_to_close(csk, opcode)) {
-		cnic_close_conn(csk);
-		cnic_cm_upcall(cp, csk, opcode);
-	}
+	cnic_close_conn(csk);
+	cnic_cm_upcall(cp, csk, opcode);
 }
 
 static void cnic_cm_stop_bnx2_hw(struct cnic_dev *dev)
-- 
1.6.4.GIT


