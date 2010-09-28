From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next2.6] net: rename netdev rx_queue to ingress_queue
Date: Tue, 28 Sep 2010 17:58:37 +0200
Message-ID: <1285689517.3154.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33922 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab0I1P6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 11:58:42 -0400
Received: by fxm14 with SMTP id 14so78372fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 08:58:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is some confusion with rx_queue name after RPS, and net drivers
private rx_queue fields.

I suggest to rename "struct net_device"->rx_queue to ingress_queue.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

My plan is to make this structure dynamically allocated, in the rare
case ingress is setup, to shrink net_device.

 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    8 ++++----
 net/sched/sch_api.c       |   14 +++++++-------
 net/sched/sch_generic.c   |    8 ++++----
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83de0eb..1ae0d65 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -983,7 +983,7 @@ struct net_device {
 	rx_handler_func_t	*rx_handler;
 	void			*rx_handler_data;
 
-	struct netdev_queue	rx_queue; /* use two cache lines */
+	struct netdev_queue	ingress_queue; /* use two cache lines */
 
 /*
  * Cache lines mostly used on transmit path
diff --git a/net/core/dev.c b/net/core/dev.c
index 42b200f..0ed0669 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2674,7 +2674,7 @@ static int ing_filter(struct sk_buff *skb)
 	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	rxq = &dev->rx_queue;
+	rxq = &dev->ingress_queue;
 
 	q = rxq->qdisc;
 	if (q != &noop_qdisc) {
@@ -2691,7 +2691,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	if (skb->dev->rx_queue.qdisc == &noop_qdisc)
+	if (skb->dev->ingress_queue.qdisc == &noop_qdisc)
 		goto out;
 
 	if (*pt_prev) {
@@ -4894,7 +4894,7 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 static void netdev_init_queue_locks(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
-	__netdev_init_queue_locks_one(dev, &dev->rx_queue, NULL);
+	__netdev_init_queue_locks_one(dev, &dev->ingress_queue, NULL);
 }
 
 unsigned long netdev_fix_features(unsigned long features, const char *name)
@@ -5406,7 +5406,7 @@ static void netdev_init_one_queue(struct net_device *dev,
 
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
+	netdev_init_one_queue(dev, &dev->ingress_queue, NULL);
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6fb3d41..b802078 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -240,7 +240,7 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 	if (q)
 		goto out;
 
-	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
+	q = qdisc_match_from_root(dev->ingress_queue.qdisc_sleeping, handle);
 out:
 	return q;
 }
@@ -701,7 +701,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		}
 
 		for (i = 0; i < num_q; i++) {
-			struct netdev_queue *dev_queue = &dev->rx_queue;
+			struct netdev_queue *dev_queue = &dev->ingress_queue;
 
 			if (!ingress)
 				dev_queue = netdev_get_tx_queue(dev, i);
@@ -979,7 +979,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /* ingress */
-				q = dev->rx_queue.qdisc_sleeping;
+				q = dev->ingress_queue.qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -1044,7 +1044,7 @@ replay:
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /*ingress */
-				q = dev->rx_queue.qdisc_sleeping;
+				q = dev->ingress_queue.qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -1124,7 +1124,7 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, &dev->rx_queue, p,
+		q = qdisc_create(dev, &dev->ingress_queue, p,
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else {
@@ -1304,7 +1304,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
-		dev_queue = &dev->rx_queue;
+		dev_queue = &dev->ingress_queue;
 		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
@@ -1595,7 +1595,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	if (tc_dump_tclass_root(dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
-	dev_queue = &dev->rx_queue;
+	dev_queue = &dev->ingress_queue;
 	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2aeb3a4..545278a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -753,7 +753,7 @@ void dev_activate(struct net_device *dev)
 
 	need_watchdog = 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
-	transition_one_qdisc(dev, &dev->rx_queue, NULL);
+	transition_one_qdisc(dev, &dev->ingress_queue, NULL);
 
 	if (need_watchdog) {
 		dev->trans_start = jiffies;
@@ -812,7 +812,7 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 void dev_deactivate(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
+	dev_deactivate_queue(dev, &dev->ingress_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
@@ -838,7 +838,7 @@ void dev_init_scheduler(struct net_device *dev)
 {
 	dev->qdisc = &noop_qdisc;
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
-	dev_init_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
+	dev_init_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
@@ -861,7 +861,7 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
-	shutdown_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
+	shutdown_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
 	qdisc_destroy(dev->qdisc);
 	dev->qdisc = &noop_qdisc;
 


