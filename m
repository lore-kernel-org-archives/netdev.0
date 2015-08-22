From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v2 3/3] net: sched: fall back to noqueue when removing root qdisc
Date: Sat, 22 Aug 2015 02:20:56 +0200
Message-ID: <1440202856-1645-4-git-send-email-phil@nwl.cc>
References: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38777 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbbHVAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 20:20:58 -0400
In-Reply-To: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When removing the root qdisc, the interface should fall back to noqueue
as the 'real' minimal qdisc instead of the default one. Therefore
dev_graft_qdisc() has to be adjusted to assign noqueue if NULL was
passed as new qdisc, and qdisc_graft() needs to assign noqueue to
dev->qdisc instead of noop to prevent dev_activate() from attaching
default qdiscs to the interface.

Note that it is also necessary to have dev_graft_qdisc() set
dev_queue->qdisc to the new qdisc instead of (unconditionally) noop. I
don't know why this was there at all (originates from pre-git time), but
it seems wrong to me.  It could be worked around by droping the extra
check for noqueue in transition_one_qdisc(), maybe with unintended
side-effects.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_api.c     | 2 +-
 net/sched/sch_generic.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 224374c..3b2cf30 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -839,7 +839,7 @@ skip:
 					   dev->qdisc, new);
 			if (new && !new->ops->attach)
 				atomic_inc(&new->refcnt);
-			dev->qdisc = new ? : &noop_qdisc;
+			dev->qdisc = new ? : &noqueue_qdisc;
 
 			if (new && new->ops->attach)
 				new->ops->attach(new);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 68df721..ecc369b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -718,9 +718,9 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 
 	/* ... and graft new one */
 	if (qdisc == NULL)
-		qdisc = &noop_qdisc;
+		qdisc = &noqueue_qdisc;
 	dev_queue->qdisc_sleeping = qdisc;
-	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
+	rcu_assign_pointer(dev_queue->qdisc, qdisc);
 
 	spin_unlock_bh(root_lock);
 
-- 
2.1.2
