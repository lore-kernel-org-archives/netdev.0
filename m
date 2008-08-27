From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Use rcu_assign_pointer() to change
	dev_queue->qdisc
Date: Wed, 27 Aug 2008 08:59:27 +0000
Message-ID: <20080827085927.GA7060@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:39111 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbYH0I7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 04:59:34 -0400
Received: by ey-out-2122.google.com with SMTP id 6so457389eyi.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 01:59:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Use rcu_assign_pointer() to change dev_queue->qdisc

These pointers are RCU protected, so proper primitives should be used.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_api.c     |    2 +-
 net/sched/sch_generic.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e7fb9e0..27604e5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -635,7 +635,7 @@ static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	if (qdisc == NULL)
 		qdisc = &noop_qdisc;
 	dev_queue->qdisc_sleeping = qdisc;
-	dev_queue->qdisc = &noop_qdisc;
+	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
 
 	spin_unlock_bh(root_lock);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5f0ade7..9634091 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -634,7 +634,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 		if (!(qdisc->flags & TCQ_F_BUILTIN))
 			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
 
-		dev_queue->qdisc = qdisc_default;
+		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
 		qdisc_reset(qdisc);
 
 		spin_unlock_bh(qdisc_lock(qdisc));
@@ -709,7 +709,7 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 	struct Qdisc *qdisc_default = _qdisc_default;
 
 	if (qdisc) {
-		dev_queue->qdisc = qdisc_default;
+		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
 		dev_queue->qdisc_sleeping = qdisc_default;
 
 		qdisc_destroy(qdisc);
