From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: avoid synchronize_rcu() in
 dev_deactivate_many
Date: Fri, 20 May 2011 11:42:09 +0200
Message-ID: <1305884529.3173.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35289 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935479Ab1ETJmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 05:42:13 -0400
Received: by wya21 with SMTP id 21so2583374wya.19
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 02:42:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_deactivate_many() issues one synchronize_rcu() call after qdiscs set
to noop_qdisc.

This call is here to make sure they are no outstanding qdisc-less
dev_queue_xmit calls before returning to caller.

But in dismantle phase, we dont have to wait, because we wont activate
again the device, and we are going to wait one rcu grace period later in
rollback_registered_many().

After this patch, device dismantle uses one synchronize_net() and one
rcu_barrier() call only, so we have a ~30% speedup and a smaller RTNL
latency.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>,
CC: Ben Greear <greearb@candelatech.com>
---
 net/sched/sch_generic.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c84b659..b1721d7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -815,9 +815,17 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
+/**
+ * 	dev_deactivate_many - deactivate transmissions on several devices
+ * 	@head: list of devices to deactivate
+ *
+ *	This function returns only when all outstanding transmissions
+ *	have completed, unless all devices are in dismantle phase.
+ */
 void dev_deactivate_many(struct list_head *head)
 {
 	struct net_device *dev;
+	bool sync_needed = false;
 
 	list_for_each_entry(dev, head, unreg_list) {
 		netdev_for_each_tx_queue(dev, dev_deactivate_queue,
@@ -827,10 +835,15 @@ void dev_deactivate_many(struct list_head *head)
 					     &noop_qdisc);
 
 		dev_watchdog_down(dev);
+		sync_needed |= !dev->dismantle;
 	}
 
-	/* Wait for outstanding qdisc-less dev_queue_xmit calls. */
-	synchronize_rcu();
+	/* Wait for outstanding qdisc-less dev_queue_xmit calls.
+	 * This is avoided if all devices are in dismantle phase :
+	 * Caller will call synchronize_net() for us
+	 */
+	if (sync_needed)
+		synchronize_net();
 
 	/* Wait for outstanding qdisc_run calls. */
 	list_for_each_entry(dev, head, unreg_list)


