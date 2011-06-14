From: greearb@candelatech.com
Subject: [PATCH] net:  Ensure tx watchdog failures always print.
Date: Tue, 14 Jun 2011 09:50:13 -0700
Message-ID: <1308070213-13244-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46996 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab1FNQuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 12:50:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

These are too important to not have some log message
generated.  But, keep the logic that only prints
a single stack dump.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 90939ba... fce5558... M	net/sched/sch_generic.c
 net/sched/sch_generic.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 90939ba..fce5558 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -252,8 +252,20 @@ static void dev_watchdog(unsigned long arg)
 
 			if (some_queue_timedout) {
 				char drivername[64];
-				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				static bool do_once = true;
+				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s):"
+				       " transmit queue %u timed out,"
+				       " trans_start: %lu, wd-timeout: %i"
+				       " jiffies: %lu tx-queues: %i\n",
+				       dev->name,
+				       netdev_drivername(dev, drivername, 64),
+				       i,
+				       trans_start, dev->watchdog_timeo,
+				       jiffies, dev->num_tx_queues);
+				if (do_once) {
+					do_once = false;
+					WARN_ON(1);
+				}
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
-- 
1.7.3.4

