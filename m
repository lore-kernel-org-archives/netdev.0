From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 4/7] bnx2x: access cfc_del_event only if the opcode is CFC_DEL
Date: Wed,  2 Mar 2016 13:47:08 +0100
Message-ID: <1456922831-15071-5-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:24 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not really a bug, but it was odd that bnx2x_eq_int() read the
message data as if it were a cfc_del_event regardless of the event type.
It's cleaner to access only the appropriate member of union event_data
after checking the event opcode.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b707ba8..0e0bcbd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5477,9 +5477,6 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			goto next_spqe;
 		}
 
-		/* elem CID originates from FW; actually LE */
-		cid = SW_CID((__force __le32)
-			     elem->message.data.cfc_del_event.cid);
 		opcode = elem->message.opcode;
 
 		/* handle eq element */
@@ -5502,6 +5499,11 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			 * we may want to verify here that the bp state is
 			 * HALTING
 			 */
+
+			/* elem CID originates from FW; actually LE */
+			cid = SW_CID((__force __le32)
+				     elem->message.data.cfc_del_event.cid);
+
 			DP(BNX2X_MSG_SP,
 			   "got delete ramrod for MULTI[%d]\n", cid);
 
-- 
2.5.0
