From: David Miller <davem@davemloft.net>
Subject: [PATCH 21/31]: pkt_sched: Use per-queue locking in
 shutdown_scheduler_queue.
Date: Thu, 17 Jul 2008 05:17:32 -0700 (PDT)
Message-ID: <20080717.051732.252374750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758545AbYGQMRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This eliminates another qdisc_lock_tree user.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_generic.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 082db8a..efa418a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -757,18 +757,20 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 	struct Qdisc *qdisc_default = _qdisc_default;
 
 	if (qdisc) {
+		spinlock_t *root_lock = qdisc_root_lock(qdisc);
+
 		dev_queue->qdisc = qdisc_default;
 		dev_queue->qdisc_sleeping = qdisc_default;
 
+		spin_lock(root_lock);
 		qdisc_destroy(qdisc);
+		spin_unlock(root_lock);
 	}
 }
 
 void dev_shutdown(struct net_device *dev)
 {
-	qdisc_lock_tree(dev);
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
 	shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
-	qdisc_unlock_tree(dev);
 }
-- 
1.5.6.2.255.gbed62

