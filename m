From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] 3c59x: Fix shared IRQ handling
Date: Tue,  7 Jul 2015 20:48:55 +0200
Message-ID: <1436294935-21777-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934296AbbGGSs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 14:48:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As its first order of business, boomerang_interrupt() checks whether
the device really has any pending interrupts. If it does not,
it does nothing and returns, but it still returns IRQ_HANDLED.

This is wrong: interrupt was not handled, IRQ handlers of other
devices sharing this IRQ line need to be called.

vortex_interrupt() has it right: it returns IRQ_NONE in this case
via IRQ_RETVAL(0).

Do the same in boomerang_interrupt().

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: David S. Miller <davem@davemloft.net>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/3com/3c59x.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 41095eb..c11d6fc 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2382,6 +2384,7 @@ boomerang_interrupt(int irq, void *dev_id)
 	void __iomem *ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
+	int handled = 0;
 
 	ioaddr = vp->ioaddr;
 
@@ -2400,6 +2403,7 @@ boomerang_interrupt(int irq, void *dev_id)
 
 	if ((status & IntLatch) == 0)
 		goto handler_exit;		/* No interrupt: shared IRQs can cause this */
+	handled = 1;
 
 	if (status == 0xffff) {		/* h/w no longer present (hotplug)? */
 		if (vortex_debug > 1)
@@ -2501,7 +2505,7 @@ boomerang_interrupt(int irq, void *dev_id)
 handler_exit:
 	vp->handling_irq = 0;
 	spin_unlock(&vp->lock);
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(handled);
 }
 
 static int vortex_rx(struct net_device *dev)
-- 
1.8.1.4
