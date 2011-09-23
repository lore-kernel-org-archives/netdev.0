From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Fri, 23 Sep 2011 20:23:47 +0200
Message-ID: <4E7CCEB3.4050408@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org,
	Andre Naujoks <nautsch@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:49940 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab1IWS21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 14:28:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two off-by-one errors that canceled each other out.
Checking for the same condition two times in bcm_tx_timeout_tsklet() reduced
the count of frames to be sent by one. This did not show up the first time
tx_setup is invoked as an additional frame is sent due to TX_ANNONCE.
Invoking a second tx_setup on the same item led to a reduced (by 1) number of
sent frames.

Reported-by: Andre Naujoks <nautsch@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/bcm.c b/net/can/bcm.c
index d6c8ae5..c9cdb8d 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -365,9 +365,6 @@ static void bcm_tx_timeout_tsklet(unsigned long data)
 
 			bcm_send_to_user(op, &msg_head, NULL, 0);
 		}
-	}
-
-	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		/* send (next) frame */
 		bcm_can_tx(op);
@@ -970,8 +967,9 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		/* spec: send can_frame when starting timer */
 		op->flags |= TX_ANNOUNCE;
 
-		if (op->kt_ival1.tv64 && (op->count > 0)) {
-			/* op->count-- is done in bcm_tx_timeout_handler */
+		/* only start timer when having more frames than sent below */
+		if (op->kt_ival1.tv64 && (op->count > 1)) {
+			/* op->count-- is done in bcm_tx_timeout_tsklet */
 			hrtimer_start(&op->timer, op->kt_ival1,
 				      HRTIMER_MODE_REL);
 		} else
@@ -979,8 +977,11 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 				      HRTIMER_MODE_REL);
 	}
 
-	if (op->flags & TX_ANNOUNCE)
+	if (op->flags & TX_ANNOUNCE) {
 		bcm_can_tx(op);
+		if (op->kt_ival1.tv64 && (op->count > 0))
+			op->count--;
+	}
 
 	return msg_head->nframes * CFSIZ + MHSIZ;
 }
