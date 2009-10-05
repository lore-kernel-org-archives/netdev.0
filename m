From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/3] qlge: Fix queueing of firmware handler in ISR.
Date: Mon,  5 Oct 2009 14:46:48 -0700
Message-ID: <1254779209-15174-3-git-send-email-ron.mercer@qlogic.com>
References: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:7750 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbZJEVxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 17:53:51 -0400
In-Reply-To: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check that we are not already polling firmware events before we queue the
firmware event worker, then disable firmware interrupts.
Otherwise we can queue the same event multiple times.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3d0efea..c21eda0 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2001,15 +2001,17 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	/*
 	 * Check MPI processor activity.
 	 */
-	if (var & STS_PI) {
+	if ((var & STS_PI) &&
+		(ql_read32(qdev, INTR_MASK) & INTR_MASK_PI)) {
 		/*
 		 * We've got an async event or mailbox completion.
 		 * Handle it and clear the source of the interrupt.
 		 */
 		QPRINTK(qdev, INTR, ERR, "Got MPI processor interrupt.\n");
 		ql_disable_completion_interrupt(qdev, intr_context->intr);
-		queue_delayed_work_on(smp_processor_id(), qdev->workqueue,
-				      &qdev->mpi_work, 0);
+		ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
+		queue_delayed_work_on(smp_processor_id(),
+				qdev->workqueue, &qdev->mpi_work, 0);
 		work_done++;
 	}
 
-- 
1.6.0.2

