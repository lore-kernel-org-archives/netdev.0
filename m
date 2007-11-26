From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] sungem: fix napi regression with reset work
Date: Mon, 26 Nov 2007 21:02:08 +0100
Message-ID: <1196107328.8459.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59231 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbXK0NGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 08:06:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sungem's gem_reset_task() will unconditionally try to disable NAPI even
when it's called while the interface is not operating and hence the NAPI
struct isn't enabled. Make napi_disable() depend on gp->running.

Also removes a superfluous test of gp->running in the same function.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Not exactly sure how I got there but I did get stuck in there (sysrq-W)
when I plugged in the network cable and booted the computer on the other
end of it... while the interface was down. I would've thought that the
driver wouldn't even notice the fact that I plugged in the cable while
the interface is down, but maybe it does. Or it sets up the device
wrongly at resume time when the interface was down at suspend.

In any case, this should fix the issue.

 drivers/net/sungem.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

--- everything.orig/drivers/net/sungem.c	2007-11-26 20:48:11.489044815 +0100
+++ everything/drivers/net/sungem.c	2007-11-26 21:01:28.519045736 +0100
@@ -2279,34 +2279,33 @@ static void gem_reset_task(struct work_s
 {
 	struct gem *gp = container_of(work, struct gem, reset_task);
 
 	mutex_lock(&gp->pm_mutex);
 
-	napi_disable(&gp->napi);
+	if (gp->opened)
+		napi_disable(&gp->napi);
 
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
 
-	if (gp->running == 0)
-		goto not_running;
-
 	if (gp->running) {
 		netif_stop_queue(gp->dev);
 
 		/* Reset the chip & rings */
 		gem_reinit_chip(gp);
 		if (gp->lstate == link_up)
 			gem_set_link_modes(gp);
 		netif_wake_queue(gp->dev);
 	}
- not_running:
+
 	gp->reset_task_pending = 0;
 
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
 
-	napi_enable(&gp->napi);
+	if (gp->opened)
+		napi_enable(&gp->napi);
 
 	mutex_unlock(&gp->pm_mutex);
 }
 
 


