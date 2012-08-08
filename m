From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [RFC net-next 2/4] gianfar: Clear ievent from interrupt handler for [RT]x int
Date: Wed, 8 Aug 2012 15:26:48 +0300
Message-ID: <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:12624
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab2HHM1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 08:27:03 -0400
In-Reply-To: <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's the interrupt handler's job to clear ievent for the Tx/Rx paths, as soon
as the corresponding interrupt sources have been masked.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index e9feeb9..ddd350a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2568,12 +2568,13 @@ static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
 	if (napi_schedule_prep(&gfargrp->napi)) {
 		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
 		__napi_schedule(&gfargrp->napi);
-	} else {
-		/* Clear IEVENT, so interrupts aren't called again
-		 * because of the packets that have already arrived.
-		 */
-		gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
 	}
+
+	/* Clear IEVENT, so interrupts aren't called again
+	 * because of the packets that have already arrived.
+	 */
+	gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
+
 	spin_unlock_irqrestore(&gfargrp->grplock, flags);
 
 }
@@ -2837,11 +2838,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	num_queues = gfargrp->num_rx_queues;
 	budget_per_queue = budget/num_queues;
 
-	/* Clear IEVENT, so interrupts aren't called again
-	 * because of the packets that have already arrived
-	 */
-	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
-
 	while (num_queues && left_over_budget) {
 		budget_per_queue = left_over_budget/num_queues;
 		left_over_budget = 0;
-- 
1.6.6
