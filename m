From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net/stable] can bcm: fix incomplete tx_setup fix
Date: Thu, 29 Sep 2011 21:19:21 +0200
Message-ID: <4E84C4B9.7020706@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org,
	Andre Naujoks <nautsch@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:52262 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab1I2TXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 15:23:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit aabdcb0b553b9c9547b1a506b34d55a764745870 ("can bcm: fix tx_setup
off-by-one errors") fixed only a part of the original problem reported by
Andre Naujoks. It turned out that the original code needed to be re-ordered
to reduce complexity and to finally fix the reported frame counting issues.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

@Andre: I checked the changes (which make the code much clearer now) against
your test program and some of mine i modified to test all flags like
STARTTIMER, SETTIMER, TX_ANNOUNCE in different configurations. Please double
check with your setup and send a Tested-by: if it is ok for you.

@Dave: Again sorry for this second patch. The first patch looked sane and
fixed the reported issue - but obviously not the whole problem :-(

 bcm.c |   48 +++++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 27 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index c9cdb8d..c84963d 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -344,6 +344,18 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 	}
 }
 
+static void bcm_tx_start_timer(struct bcm_op *op)
+{
+	if (op->kt_ival1.tv64 && op->count)
+		hrtimer_start(&op->timer,
+			      ktime_add(ktime_get(), op->kt_ival1),
+			      HRTIMER_MODE_ABS);
+	else if (op->kt_ival2.tv64)
+		hrtimer_start(&op->timer,
+			      ktime_add(ktime_get(), op->kt_ival2),
+			      HRTIMER_MODE_ABS);
+}
+
 static void bcm_tx_timeout_tsklet(unsigned long data)
 {
 	struct bcm_op *op = (struct bcm_op *)data;
@@ -365,23 +377,12 @@ static void bcm_tx_timeout_tsklet(unsigned long data)
 
 			bcm_send_to_user(op, &msg_head, NULL, 0);
 		}
-
-		/* send (next) frame */
 		bcm_can_tx(op);
-		hrtimer_start(&op->timer,
-			      ktime_add(ktime_get(), op->kt_ival1),
-			      HRTIMER_MODE_ABS);
 
-	} else {
-		if (op->kt_ival2.tv64) {
+	} else if (op->kt_ival2.tv64)
+		bcm_can_tx(op);
 
-			/* send (next) frame */
-			bcm_can_tx(op);
-			hrtimer_start(&op->timer,
-				      ktime_add(ktime_get(), op->kt_ival2),
-				      HRTIMER_MODE_ABS);
-		}
-	}
+	bcm_tx_start_timer(op);
 }
 
 /*
@@ -961,28 +962,21 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			hrtimer_cancel(&op->timer);
 	}
 
-	if ((op->flags & STARTTIMER) &&
-	    ((op->kt_ival1.tv64 && op->count) || op->kt_ival2.tv64)) {
-
+	if (op->flags & STARTTIMER) {
+		hrtimer_cancel(&op->timer);
 		/* spec: send can_frame when starting timer */
 		op->flags |= TX_ANNOUNCE;
-
-		/* only start timer when having more frames than sent below */
-		if (op->kt_ival1.tv64 && (op->count > 1)) {
-			/* op->count-- is done in bcm_tx_timeout_tsklet */
-			hrtimer_start(&op->timer, op->kt_ival1,
-				      HRTIMER_MODE_REL);
-		} else
-			hrtimer_start(&op->timer, op->kt_ival2,
-				      HRTIMER_MODE_REL);
 	}
 
 	if (op->flags & TX_ANNOUNCE) {
 		bcm_can_tx(op);
-		if (op->kt_ival1.tv64 && (op->count > 0))
+		if (op->count)
 			op->count--;
 	}
 
+	if (op->flags & STARTTIMER)
+		bcm_tx_start_timer(op);
+
 	return msg_head->nframes * CFSIZ + MHSIZ;
 }
 
