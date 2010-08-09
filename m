From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] 3c59x: fix deadlock when using netconsole with 3c59x
Date: Mon, 9 Aug 2010 12:32:10 -0400
Message-ID: <20100809163210.GA1781@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: klassert@mathematik.tu-chemnitz.de, davem@davemloft.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41043 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757121Ab0HIQgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 12:36:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using netpoll, its possible to deadlock the 3c59x driver.  Since it takes
an internal spinlock (vp->lock) that serializes boomerang_interrupt and parts
of boomerang_start_xmit, if we call pr_debug in the former, we can go through
the tx path on the same cpu, and recurse into the same driver again, deadlocking
in the transmit routine.

This patch fixes that problem by stopping the queues during interrupt
processing, so that subsequent transmits will get queued until a later point.
Its not a great solution, but we need to find some way to serialize access to
the register file on the card without enforcing a deadlock.  I think the queue
stop is the best way to do that.  And since we only print things in
boomerang_interrupt when we have debug enabled, we can mitigate the impact of
this change to only stop the queues when debug is on.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/3c59x.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c754d88..e5c8757 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2338,7 +2338,17 @@ boomerang_interrupt(int irq, void *dev_id)
 	/*
 	 * It seems dopey to put the spinlock this early, but we could race against vortex_tx_timeout
 	 * and boomerang_start_xmit
+	 * We also need to disable the tx queue in the event that we print
+	 * anything from this path.  if pr_debug is called, we run the risk of 
+	 * recursing through the transmit path, which also takes the vp->lock,
+	 * and deadlocks us.  This only happens if we're using netpoll
+	 * but we need to be ready for it
+	 * We can mitigate the perf impact here if we only
+	 * do this is vortex_debug is != 0
 	 */
+	if (vortex_debug)
+		netif_stop_queue(dev);
+		
 	spin_lock(&vp->lock);
 
 	status = ioread16(ioaddr + EL3_STATUS);
@@ -2447,6 +2457,8 @@ boomerang_interrupt(int irq, void *dev_id)
 		pr_debug("%s: exiting interrupt, status %4.4x.\n",
 			   dev->name, status);
 handler_exit:
+	if (vortex_debug)
+		netif_start_queue(dev);
 	spin_unlock(&vp->lock);
 	return IRQ_HANDLED;
 }
-- 
1.7.2.1

