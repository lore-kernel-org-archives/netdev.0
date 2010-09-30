From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next2.6] net: dynamic ingress_queue allocation
Date: Fri, 01 Oct 2010 00:58:29 +0200
Message-ID: <1285887509.2705.33.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local>  <1285757817.3561.2.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37771 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab0I3W6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 18:58:36 -0400
Received: by fxm14 with SMTP id 14so299551fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 15:58:35 -0700 (PDT)
In-Reply-To: <1285757817.3561.2.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal

Here is the dynamic allocation I promised. I lightly tested it, could
you review it please ?

Thanks !

[PATCH net-next2.6] net: dynamic ingress_queue allocation

ingress being not used very much, and net_device->ingress_queue being
quite a big object (128 or 256 bytes), use a dynamic allocation if
needed (tc qdisc add dev eth0 ingress ...)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |   17 +++++++++++-
 net/core/dev.c            |   48 +++++++++++++++++++++++++++---------
 net/sched/sch_api.c       |   40 ++++++++++++++++++++----------
 net/sched/sch_generic.c   |   36 +++++++++++++++------------
 4 files changed, 98 insertions(+), 43 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ceed347..7a21a91 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -986,8 +986,9 @@ struct net_device {
 	rx_handler_func_t	*rx_handler;
 	void			*rx_handler_data;
 
-	struct netdev_queue	ingress_queue; /* use two cache lines */
-
+#ifdef CONFIG_NET_CLS_ACT
+	struct netdev_queue	*ingress_queue;
+#endif
 /*
  * Cache lines mostly used on transmit path
  */
@@ -1115,6 +1116,18 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+
+static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	return dev->ingress_queue;
+#else
+	return NULL;
+#endif
+}
+
+extern struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
+
 /*
  * Net namespace inlines
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index a313bab..1e68259 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2702,11 +2702,10 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
  * the ingress scheduler, you just cant add policies on ingress.
  *
  */
-static int ing_filter(struct sk_buff *skb)
+static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 {
 	struct net_device *dev = skb->dev;
 	u32 ttl = G_TC_RTTL(skb->tc_verd);
-	struct netdev_queue *rxq;
 	int result = TC_ACT_OK;
 	struct Qdisc *q;
 
@@ -2720,8 +2719,6 @@ static int ing_filter(struct sk_buff *skb)
 	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	rxq = &dev->ingress_queue;
-
 	q = rxq->qdisc;
 	if (q != &noop_qdisc) {
 		spin_lock(qdisc_lock(q));
@@ -2737,7 +2734,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	if (skb->dev->ingress_queue.qdisc == &noop_qdisc)
+	struct netdev_queue *rxq = dev_ingress_queue(skb->dev);
+
+	if (!rxq || rxq->qdisc == &noop_qdisc)
 		goto out;
 
 	if (*pt_prev) {
@@ -2745,7 +2744,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb)) {
+	switch (ing_filter(skb, rxq)) {
 	case TC_ACT_SHOT:
 	case TC_ACT_STOLEN:
 		kfree_skb(skb);
@@ -4932,15 +4931,17 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  struct netdev_queue *dev_queue,
 					  void *_unused)
 {
-	spin_lock_init(&dev_queue->_xmit_lock);
-	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
-	dev_queue->xmit_lock_owner = -1;
+	if (dev_queue) {
+		spin_lock_init(&dev_queue->_xmit_lock);
+		netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
+		dev_queue->xmit_lock_owner = -1;
+	}
 }
 
 static void netdev_init_queue_locks(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
-	__netdev_init_queue_locks_one(dev, &dev->ingress_queue, NULL);
+	__netdev_init_queue_locks_one(dev, dev_ingress_queue(dev), NULL);
 }
 
 unsigned long netdev_fix_features(unsigned long features, const char *name)
@@ -5447,16 +5448,37 @@ static void netdev_init_one_queue(struct net_device *dev,
 				  struct netdev_queue *queue,
 				  void *_unused)
 {
-	queue->dev = dev;
+	if (queue)
+		queue->dev = dev;
 }
 
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->ingress_queue, NULL);
+	netdev_init_one_queue(dev, dev_ingress_queue(dev), NULL);
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
 }
 
+struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
+{
+	struct netdev_queue *queue = NULL;
+
+#ifdef CONFIG_NET_CLS_ACT
+	if (dev->ingress_queue)
+		return dev->ingress_queue;
+	queue = kzalloc(sizeof(*queue), GFP_KERNEL);
+	if (!queue)
+		return NULL;
+	netdev_init_one_queue(dev, queue, NULL);
+	__netdev_init_queue_locks_one(dev, queue, NULL);
+	queue->qdisc = &noop_qdisc;
+	queue->qdisc_sleeping = &noop_qdisc;
+	smp_wmb();
+	dev->ingress_queue = queue;
+#endif
+	return queue;
+}
+
 /**
  *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -5559,6 +5581,8 @@ void free_netdev(struct net_device *dev)
 
 	kfree(dev->_tx);
 
+	kfree(dev_ingress_queue(dev));
+
 	/* Flush device addresses */
 	dev_addr_flush(dev);
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b802078..8635110 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -240,7 +240,10 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 	if (q)
 		goto out;
 
-	q = qdisc_match_from_root(dev->ingress_queue.qdisc_sleeping, handle);
+	if (!dev_ingress_queue(dev))
+		goto out;
+	q = qdisc_match_from_root(dev_ingress_queue(dev)->qdisc_sleeping,
+				  handle);
 out:
 	return q;
 }
@@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		    (new && new->flags & TCQ_F_INGRESS)) {
 			num_q = 1;
 			ingress = 1;
+			if (!dev_ingress_queue(dev))
+				return -ENOENT;
 		}
 
 		if (dev->flags & IFF_UP)
@@ -701,7 +706,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		}
 
 		for (i = 0; i < num_q; i++) {
-			struct netdev_queue *dev_queue = &dev->ingress_queue;
+			struct netdev_queue *dev_queue = dev_ingress_queue(dev);
 
 			if (!ingress)
 				dev_queue = netdev_get_tx_queue(dev, i);
@@ -979,7 +984,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /* ingress */
-				q = dev->ingress_queue.qdisc_sleeping;
+				if (dev_ingress_queue(dev))
+					q = dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -1044,7 +1050,8 @@ replay:
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /*ingress */
-				q = dev->ingress_queue.qdisc_sleeping;
+				if (dev_ingress_queue_create(dev))
+					q = dev_ingress_queue(dev)->qdisc_sleeping;
 			}
 		} else {
 			q = dev->qdisc;
@@ -1123,11 +1130,14 @@ replay:
 create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
-	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, &dev->ingress_queue, p,
-				 tcm->tcm_parent, tcm->tcm_parent,
-				 tca, &err);
-	else {
+	if (clid == TC_H_INGRESS) {
+		if (dev_ingress_queue(dev))
+			q = qdisc_create(dev, dev_ingress_queue(dev), p,
+					 tcm->tcm_parent, tcm->tcm_parent,
+					 tca, &err);
+		else
+			err = -ENOENT;
+	} else {
 		struct netdev_queue *dev_queue;
 
 		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
@@ -1304,8 +1314,10 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
-		dev_queue = &dev->ingress_queue;
-		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s_q_idx) < 0)
+		dev_queue = dev_ingress_queue(dev);
+		if (dev_queue &&
+		    tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
+				       &q_idx, s_q_idx) < 0)
 			goto done;
 
 cont:
@@ -1595,8 +1607,10 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	if (tc_dump_tclass_root(dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
-	dev_queue = &dev->ingress_queue;
-	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, s_t) < 0)
+	dev_queue = dev_ingress_queue(dev);
+	if (dev_queue &&
+	    tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb,
+				&t, s_t) < 0)
 		goto done;
 
 done:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 545278a..c42dec5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -721,16 +721,18 @@ static void transition_one_qdisc(struct net_device *dev,
 				 struct netdev_queue *dev_queue,
 				 void *_need_watchdog)
 {
-	struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
-	int *need_watchdog_p = _need_watchdog;
+	if (dev_queue) {
+		struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
+		int *need_watchdog_p = _need_watchdog;
 
-	if (!(new_qdisc->flags & TCQ_F_BUILTIN))
-		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
+		if (!(new_qdisc->flags & TCQ_F_BUILTIN))
+			clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
 
-	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
-	if (need_watchdog_p && new_qdisc != &noqueue_qdisc) {
-		dev_queue->trans_start = 0;
-		*need_watchdog_p = 1;
+		rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
+		if (need_watchdog_p && new_qdisc != &noqueue_qdisc) {
+			dev_queue->trans_start = 0;
+			*need_watchdog_p = 1;
+		}
 	}
 }
 
@@ -753,7 +755,7 @@ void dev_activate(struct net_device *dev)
 
 	need_watchdog = 0;
 	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
-	transition_one_qdisc(dev, &dev->ingress_queue, NULL);
+	transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
 
 	if (need_watchdog) {
 		dev->trans_start = jiffies;
@@ -768,7 +770,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	struct Qdisc *qdisc_default = _qdisc_default;
 	struct Qdisc *qdisc;
 
-	qdisc = dev_queue->qdisc;
+	qdisc = dev_queue ? dev_queue->qdisc : NULL;
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
 
@@ -812,7 +814,7 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 void dev_deactivate(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	dev_deactivate_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	dev_deactivate_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
@@ -830,15 +832,17 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 {
 	struct Qdisc *qdisc = _qdisc;
 
-	dev_queue->qdisc = qdisc;
-	dev_queue->qdisc_sleeping = qdisc;
+	if (dev_queue) {
+		dev_queue->qdisc = qdisc;
+		dev_queue->qdisc_sleeping = qdisc;
+	}
 }
 
 void dev_init_scheduler(struct net_device *dev)
 {
 	dev->qdisc = &noop_qdisc;
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
-	dev_init_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	dev_init_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
@@ -847,7 +851,7 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_qdisc_default)
 {
-	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+	struct Qdisc *qdisc = dev_queue ? dev_queue->qdisc_sleeping : NULL;
 	struct Qdisc *qdisc_default = _qdisc_default;
 
 	if (qdisc) {
@@ -861,7 +865,7 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
-	shutdown_scheduler_queue(dev, &dev->ingress_queue, &noop_qdisc);
+	shutdown_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 	qdisc_destroy(dev->qdisc);
 	dev->qdisc = &noop_qdisc;
 


