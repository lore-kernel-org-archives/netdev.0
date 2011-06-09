From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/5 net-next] cnic: Fix race conditions with firmware
Date: Wed, 8 Jun 2011 22:29:33 -0700
Message-ID: <1307597376-5379-2-git-send-email-mchan@broadcom.com>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1235 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509Ab1FIGVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:21:06 -0400
In-Reply-To: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During iSCSI connection terminations, if the target is also terminating
at about the same time, the firmware may not complete the driver's
request to close or reset the connection.  This is fixed by handling
other events (instead of the expected completion event) as an indication
that the driver's request has been rejected.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 5c0a669..ea7245c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3767,7 +3767,13 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		break;
 
 	case L4_KCQE_OPCODE_VALUE_CLOSE_RECEIVED:
-		cnic_cm_upcall(cp, csk, opcode);
+		/* after we already sent CLOSE_REQ */
+		if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags) &&
+		    !test_bit(SK_F_OFFLD_COMPLETE, &csk->flags) &&
+		    csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP)
+			cp->close_conn(csk, L4_KCQE_OPCODE_VALUE_RESET_COMP);
+		else
+			cnic_cm_upcall(cp, csk, opcode);
 		break;
 	}
 	csk_put(csk);
@@ -3821,12 +3827,14 @@ static int cnic_ready_to_close(struct cnic_sock *csk, u32 opcode)
 	}
 
 	/* 1. If event opcode matches the expected event in csk->state
-	 * 2. If the expected event is CLOSE_COMP, we accept any event
+	 * 2. If the expected event is CLOSE_COMP or RESET_COMP, we accept any
+	 *    event
 	 * 3. If the expected event is 0, meaning the connection was never
 	 *    never established, we accept the opcode from cm_abort.
 	 */
 	if (opcode == csk->state || csk->state == 0 ||
-	    csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP) {
+	    csk->state == L4_KCQE_OPCODE_VALUE_CLOSE_COMP ||
+	    csk->state == L4_KCQE_OPCODE_VALUE_RESET_COMP) {
 		if (!test_and_set_bit(SK_F_CLOSING, &csk->flags)) {
 			if (csk->state == 0)
 				csk->state = opcode;
-- 
1.6.4.GIT


