From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH 2.6.29] can: fix slowpath issue in hrtimer callback function
Date: Wed, 14 Jan 2009 08:44:28 +0100
Message-ID: <496D97DC.9020408@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000701080908020201000909"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:44145 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760243AbZANHo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 02:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000701080908020201000909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Due to the loopback functionality in can_send() we can not invoke it 
from hardirq context which was done inside the bcm_tx_timeout_handler() 
hrtimer callback:


[  700.361154]  [<c012228c>] warn_slowpath+0x80/0xb6
[  700.361163]  [<c013d559>] valid_state+0x125/0x136
[  700.361171]  [<c013d858>] mark_lock+0x18e/0x332
[  700.361180]  [<c013e300>] __lock_acquire+0x12e/0xb1e
[  700.361189]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
[  700.361198]  [<c031e20a>] dev_queue_xmit+0x191/0x479
[  700.361206]  [<c01262a7>] __local_bh_disable+0x2b/0x64
[  700.361213]  [<c031e20a>] dev_queue_xmit+0x191/0x479
[  700.361225]  [<f8aa69a1>] can_send+0xd7/0x11a [can]
[  700.361235]  [<f8ab522b>] bcm_can_tx+0x9d/0xd9 [can_bcm]
[  700.361245]  [<f8ab597f>] bcm_tx_timeout_handler+0x6a/0xbc [can_bcm]
[  700.361255]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
[  700.361263]  [<c0134143>] __run_hrtimer+0x5a/0x86
[  700.361273]  [<f8ab5915>] bcm_tx_timeout_handler+0x0/0xbc [can_bcm]
[  700.361282]  [<c0134a50>] hrtimer_interrupt+0xb9/0x110


This patch moves the rest of the functionality from the hrtimer callback 
to the already existing tasklet to fix this slowpath problem.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

Hello Dave,

this patch 'completes' the changes for the hrtimer update of the can-bcm 
in 2.6.29 :-]

Thanks,
Oliver


--------------000701080908020201000909
Content-Type: text/x-patch;
 name="bcm_tx_slowpath.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm_tx_slowpath.patch"

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 1649c8a..b7c7d46 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -347,51 +347,54 @@ static void bcm_tx_timeout_tsklet(unsigned long data)
 	struct bcm_op *op = (struct bcm_op *)data;
 	struct bcm_msg_head msg_head;
 
-	/* create notification to user */
-	msg_head.opcode  = TX_EXPIRED;
-	msg_head.flags   = op->flags;
-	msg_head.count   = op->count;
-	msg_head.ival1   = op->ival1;
-	msg_head.ival2   = op->ival2;
-	msg_head.can_id  = op->can_id;
-	msg_head.nframes = 0;
-
-	bcm_send_to_user(op, &msg_head, NULL, 0);
-}
-
-/*
- * bcm_tx_timeout_handler - performes cyclic CAN frame transmissions
- */
-static enum hrtimer_restart bcm_tx_timeout_handler(struct hrtimer *hrtimer)
-{
-	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
-	enum hrtimer_restart ret = HRTIMER_NORESTART;
-
 	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		op->count--;
-		if (!op->count && (op->flags & TX_COUNTEVT))
-			tasklet_schedule(&op->tsklet);
+		if (!op->count && (op->flags & TX_COUNTEVT)) {
+
+			/* create notification to user */
+			msg_head.opcode  = TX_EXPIRED;
+			msg_head.flags   = op->flags;
+			msg_head.count   = op->count;
+			msg_head.ival1   = op->ival1;
+			msg_head.ival2   = op->ival2;
+			msg_head.can_id  = op->can_id;
+			msg_head.nframes = 0;
+
+			bcm_send_to_user(op, &msg_head, NULL, 0);
+		}
 	}
 
 	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		/* send (next) frame */
 		bcm_can_tx(op);
-		hrtimer_forward(hrtimer, ktime_get(), op->kt_ival1);
-		ret = HRTIMER_RESTART;
+		hrtimer_start(&op->timer,
+			      ktime_add(ktime_get(), op->kt_ival1),
+			      HRTIMER_MODE_ABS);
 
 	} else {
 		if (op->kt_ival2.tv64) {
 
 			/* send (next) frame */
 			bcm_can_tx(op);
-			hrtimer_forward(hrtimer, ktime_get(), op->kt_ival2);
-			ret = HRTIMER_RESTART;
+			hrtimer_start(&op->timer,
+				      ktime_add(ktime_get(), op->kt_ival2),
+				      HRTIMER_MODE_ABS);
 		}
 	}
+}
 
-	return ret;
+/*
+ * bcm_tx_timeout_handler - performes cyclic CAN frame transmissions
+ */
+static enum hrtimer_restart bcm_tx_timeout_handler(struct hrtimer *hrtimer)
+{
+	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
+
+	tasklet_schedule(&op->tsklet);
+
+	return HRTIMER_NORESTART;
 }
 
 /*

--------------000701080908020201000909--
