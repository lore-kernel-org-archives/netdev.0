From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/5] qdisc: avoid transmit softirq on watchdog wakeup
Date: Wed, 21 Mar 2007 10:42:36 -0700
Message-ID: <20070321174422.812295327@linux-foundation.org>
References: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46921 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752973AbXCUR6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:58:49 -0400
Content-Disposition: inline; filename=qdisc-avoid-softirq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If possible, avoid having to do a transmit softirq when a qdisc
watchdog decides to re-enable.  The watchdog routine runs off
a timer, so it is already in the same effective context as
the softirq.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/sched/sch_api.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- net-2.6.22.orig/net/sched/sch_api.c
+++ net-2.6.22/net/sched/sch_api.c
@@ -296,10 +296,16 @@ static enum hrtimer_restart qdisc_watchd
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
+	struct net_device *dev = wd->qdisc->dev;
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
-	netif_schedule(wd->qdisc->dev);
+	if (spin_trylock(&dev->queue_lock)) {
+		qdisc_run(dev);
+		spin_unlock(&dev->queue_lock);
+	} else
+		netif_schedule(dev);
+
 	return HRTIMER_NORESTART;
 }
 

-- 

