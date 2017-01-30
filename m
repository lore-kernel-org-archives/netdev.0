From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: bcm: fix hrtimer/tasklet termination in bcm op removal
Date: Mon, 30 Jan 2017 11:11:01 +0100
Message-ID: <20170130101101.14150-2-mkl@pengutronix.de>
References: <20170130101101.14150-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37439 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752873AbdA3Kaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 05:30:39 -0500
In-Reply-To: <20170130101101.14150-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

When removing a bcm tx operation either a hrtimer or a tasklet might run.
As the hrtimer triggers its associated tasklet and vice versa we need to
take care to mutually terminate both handlers.

Reported-by: Michael Josenhans <michael.josenhans@web.de>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Tested-by: Michael Josenhans <michael.josenhans@web.de>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/bcm.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 5c9407181918..95d13b233c65 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -734,14 +734,23 @@ static struct bcm_op *bcm_find_op(struct list_head *ops,
 
 static void bcm_remove_op(struct bcm_op *op)
 {
-	hrtimer_cancel(&op->timer);
-	hrtimer_cancel(&op->thrtimer);
-
-	if (op->tsklet.func)
-		tasklet_kill(&op->tsklet);
+	if (op->tsklet.func) {
+		while (test_bit(TASKLET_STATE_SCHED, &op->tsklet.state) ||
+		       test_bit(TASKLET_STATE_RUN, &op->tsklet.state) ||
+		       hrtimer_active(&op->timer)) {
+			hrtimer_cancel(&op->timer);
+			tasklet_kill(&op->tsklet);
+		}
+	}
 
-	if (op->thrtsklet.func)
-		tasklet_kill(&op->thrtsklet);
+	if (op->thrtsklet.func) {
+		while (test_bit(TASKLET_STATE_SCHED, &op->thrtsklet.state) ||
+		       test_bit(TASKLET_STATE_RUN, &op->thrtsklet.state) ||
+		       hrtimer_active(&op->thrtimer)) {
+			hrtimer_cancel(&op->thrtimer);
+			tasklet_kill(&op->thrtsklet);
+		}
+	}
 
 	if ((op->frames) && (op->frames != &op->sframe))
 		kfree(op->frames);
-- 
2.11.0
