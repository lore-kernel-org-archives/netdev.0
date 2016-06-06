From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] net_sched: transform qdisc running bit into a seqcount
Date: Mon,  6 Jun 2016 09:37:15 -0700
Message-ID: <1465231036-10674-2-git-send-email-edumazet@google.com>
References: <1465231036-10674-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35472 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbcFFQhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 12:37:23 -0400
Received: by mail-pf0-f180.google.com with SMTP id g64so68479054pfb.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 09:37:23 -0700 (PDT)
In-Reply-To: <1465231036-10674-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a single bit (__QDISC___STATE_RUNNING)
in sch->__state, use a seqcount.

This adds lockdep support, but more importantly it will allow us
to sample qdisc/class statistics without having to grab qdisc root lock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/bonding/bond_main.c |  2 ++
 drivers/net/ppp/ppp_generic.c   |  3 +++
 drivers/net/team/team.c         |  2 ++
 include/linux/netdevice.h       |  1 +
 include/net/sch_generic.h       | 15 ++++-----------
 net/bluetooth/6lowpan.c         |  2 ++
 net/core/dev.c                  |  2 +-
 net/ieee802154/6lowpan/core.c   |  3 +++
 net/l2tp/l2tp_eth.c             |  4 ++++
 net/sched/sch_generic.c         | 14 ++++++++++----
 10 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99cd3b6..681af31a60ed 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4610,6 +4610,7 @@ static int bond_check_params(struct bond_params *params)
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 static struct lock_class_key bonding_netdev_addr_lock_key;
 static struct lock_class_key bonding_tx_busylock_key;
+static struct lock_class_key bonding_qdisc_running_key;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -4625,6 +4626,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
+	dev->qdisc_running_key = &bonding_qdisc_running_key;
 }
 
 /* Called from registration process */
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 8dedafa1a95d..aeabaa42317f 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1313,9 +1313,12 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 }
 
 static struct lock_class_key ppp_tx_busylock;
+static struct lock_class_key ppp_qdisc_running_key;
+
 static int ppp_dev_init(struct net_device *dev)
 {
 	dev->qdisc_tx_busylock = &ppp_tx_busylock;
+	dev->qdisc_running_key = &ppp_qdisc_running_key;
 	return 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2ace126533cd..00eb38956a2c 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1577,6 +1577,7 @@ static const struct team_option team_options[] = {
 static struct lock_class_key team_netdev_xmit_lock_key;
 static struct lock_class_key team_netdev_addr_lock_key;
 static struct lock_class_key team_tx_busylock_key;
+static struct lock_class_key team_qdisc_running_key;
 
 static void team_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -1590,6 +1591,7 @@ static void team_set_lockdep_class(struct net_device *dev)
 	lockdep_set_class(&dev->addr_list_lock, &team_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, team_set_lockdep_class_one, NULL);
 	dev->qdisc_tx_busylock = &team_tx_busylock_key;
+	dev->qdisc_running_key = &team_qdisc_running_key;
 }
 
 static int team_init(struct net_device *dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa6df2699532..59d7e06d88d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1862,6 +1862,7 @@ struct net_device {
 #endif
 	struct phy_device	*phydev;
 	struct lock_class_key	*qdisc_tx_busylock;
+	struct lock_class_key	*qdisc_running_key;
 	bool			proto_down;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1fd76c22a59..bff8d895ef8a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -29,13 +29,6 @@ enum qdisc_state_t {
 	__QDISC_STATE_THROTTLED,
 };
 
-/*
- * following bits are only changed while qdisc lock is held
- */
-enum qdisc___state_t {
-	__QDISC___STATE_RUNNING = 1,
-};
-
 struct qdisc_size_table {
 	struct rcu_head		rcu;
 	struct list_head	list;
@@ -93,7 +86,7 @@ struct Qdisc {
 	unsigned long		state;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
-	unsigned int		__state;
+	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
 	int			padded;
@@ -104,20 +97,20 @@ struct Qdisc {
 
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
 {
-	return (qdisc->__state & __QDISC___STATE_RUNNING) ? true : false;
+	return (raw_read_seqcount(&qdisc->running) & 1) ? true : false;
 }
 
 static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
 	if (qdisc_is_running(qdisc))
 		return false;
-	qdisc->__state |= __QDISC___STATE_RUNNING;
+	write_seqcount_begin(&qdisc->running);
 	return true;
 }
 
 static inline void qdisc_run_end(struct Qdisc *qdisc)
 {
-	qdisc->__state &= ~__QDISC___STATE_RUNNING;
+	write_seqcount_end(&qdisc->running);
 }
 
 static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 780089d75915..977a11e418d0 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -629,6 +629,7 @@ static netdev_tx_t bt_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 static struct lock_class_key bt_tx_busylock;
 static struct lock_class_key bt_netdev_xmit_lock_key;
+static struct lock_class_key bt_qdisc_running_key;
 
 static void bt_set_lockdep_class_one(struct net_device *dev,
 				     struct netdev_queue *txq,
@@ -641,6 +642,7 @@ static int bt_dev_init(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, bt_set_lockdep_class_one, NULL);
 	dev->qdisc_tx_busylock = &bt_tx_busylock;
+	dev->qdisc_running_key = &bt_qdisc_running_key;
 
 	return 0;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff431d570..55b414dead29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3075,7 +3075,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
-	 * This permits __QDISC___STATE_RUNNING owner to get the lock more
+	 * This permits qdisc->running owner to get the lock more
 	 * often and dequeue packets faster.
 	 */
 	contended = qdisc_is_running(q);
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index dd085db8580e..14aa5effd29a 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -60,6 +60,7 @@ static struct header_ops lowpan_header_ops = {
 
 static struct lock_class_key lowpan_tx_busylock;
 static struct lock_class_key lowpan_netdev_xmit_lock_key;
+static struct lock_class_key lowpan_qdisc_running_key;
 
 static void lowpan_set_lockdep_class_one(struct net_device *ldev,
 					 struct netdev_queue *txq,
@@ -73,6 +74,8 @@ static int lowpan_dev_init(struct net_device *ldev)
 {
 	netdev_for_each_tx_queue(ldev, lowpan_set_lockdep_class_one, NULL);
 	ldev->qdisc_tx_busylock = &lowpan_tx_busylock;
+	ldev->qdisc_running_key = &lowpan_qdisc_running_key;
+
 	return 0;
 }
 
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index e253c26f31ac..c00d72d182fa 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -68,6 +68,8 @@ static inline struct l2tp_eth_net *l2tp_eth_pernet(struct net *net)
 }
 
 static struct lock_class_key l2tp_eth_tx_busylock;
+static struct lock_class_key l2tp_qdisc_running_key;
+
 static int l2tp_eth_dev_init(struct net_device *dev)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
@@ -76,6 +78,8 @@ static int l2tp_eth_dev_init(struct net_device *dev)
 	eth_hw_addr_random(dev);
 	eth_broadcast_addr(dev->broadcast);
 	dev->qdisc_tx_busylock = &l2tp_eth_tx_busylock;
+	dev->qdisc_running_key = &l2tp_qdisc_running_key;
+
 	return 0;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 269dd71b3828..cebea73e70ac 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -110,7 +110,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 
 /*
  * Transmit possibly several skbs, and handle the return status as
- * required. Holding the __QDISC___STATE_RUNNING bit guarantees that
+ * required. Owning running seqcount bit guarantees that
  * only one CPU can execute this function.
  *
  * Returns to the caller:
@@ -137,10 +137,10 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 		HARD_TX_UNLOCK(dev, txq);
 	} else {
-		spin_lock(root_lock);
+		spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
 		return qdisc_qlen(q);
 	}
-	spin_lock(root_lock);
+	spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
@@ -163,7 +163,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 /*
  * NOTE: Called under qdisc_lock(q) with locally disabled BH.
  *
- * __QDISC___STATE_RUNNING guarantees only one CPU can process
+ * running seqcount guarantees only one CPU can process
  * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
  * this queue.
  *
@@ -379,6 +379,7 @@ struct Qdisc noop_qdisc = {
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
+	.running	=	SEQCNT_ZERO(noop_qdisc.running),
 	.busylock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.busylock),
 };
 EXPORT_SYMBOL(noop_qdisc);
@@ -537,6 +538,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 EXPORT_SYMBOL(pfifo_fast_ops);
 
 static struct lock_class_key qdisc_tx_busylock;
+static struct lock_class_key qdisc_running_key;
 
 struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 			  const struct Qdisc_ops *ops)
@@ -570,6 +572,10 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	lockdep_set_class(&sch->busylock,
 			  dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
 
+	seqcount_init(&sch->running);
+	lockdep_set_class(&sch->running,
+			  dev->qdisc_running_key ?: &qdisc_running_key);
+
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
-- 
2.8.0.rc3.226.g39d4020
