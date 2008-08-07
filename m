From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] net: trap attempts to modify noop qdisc
Date: Wed, 6 Aug 2008 23:08:50 -0700
Message-ID: <20080806230850.41435290@extreme>
References: <20080806180237.4912a677@extreme>
	<20080806.181327.139395860.davem@davemloft.net>
	<20080806202029.63f25c81@extreme>
	<20080806.202210.92821768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57294 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbYHGGIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:08:52 -0400
In-Reply-To: <20080806.202210.92821768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since noop qdisc is a singleton, it shouldn't end up with any other
qdisc's on it's list, and it shouldn't be deleted.

Dave, this should help you find the bug.  Any change to root qdisc causes
this to trigger.  I.e doing:
  tc qdisc add dev eth0 root pfifo
causes pfifo to end up on the noop_qdisc->list, which later causes problems.

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4840aff..57b778f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -792,8 +792,10 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out3;
 			}
 		}
-		if (parent && !(sch->flags & TCQ_F_INGRESS))
+		if (parent && !(sch->flags & TCQ_F_INGRESS)) {
+			BUG_ON(dev_queue->qdisc == &noop_qdisc);
 			list_add_tail(&sch->list, &dev_queue->qdisc->list);
+		}
 
 		return sch;
 	}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7cf83b3..5988863 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -547,6 +547,8 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
+	BUG_ON(qdisc == &noop_qdisc);
+
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
-- 
1.5.4.3

