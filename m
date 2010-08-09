From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] net:  Provide details on watchdog timeout.
Date: Mon,  9 Aug 2010 12:59:14 -0700
Message-ID: <1281383954-23765-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40269 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab0HIT7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:59:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This keeps the WARN_ON but will also log normal kernel messages
after the WARN_ON logic has happened once.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 2aeb3a4... 66e6154... M	net/sched/sch_generic.c
 net/sched/sch_generic.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2aeb3a4..66e6154 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -253,9 +253,26 @@ static void dev_watchdog(unsigned long arg)
 			}
 
 			if (some_queue_timedout) {
-				char drivername[64];
-				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				static bool do_once = true;
+				if (do_once || net_ratelimit()) {
+					char drivername[64];
+					if (unlikely(do_once)) {
+						WARN(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): "
+						     "transmit queue %u timed out"
+						     " trans-start: %lu  jiffies: %lu\n",
+						     dev->name,
+						     netdev_drivername(dev, drivername, 64),
+						     i, trans_start, jiffies);
+						do_once = false;
+					}
+					else
+						printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): "
+						       "transmit queue %u timed out"
+						       " trans-start: %lu  jiffies: %lu\n",
+						       dev->name,
+						       netdev_drivername(dev, drivername, 64),
+						       i, trans_start, jiffies);
+				}
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
-- 
1.6.2.5

