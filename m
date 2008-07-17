From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/31]: pkt_sched: Make QDISC_RUNNING a qdisc state.
Date: Thu, 17 Jul 2008 05:17:04 -0700 (PDT)
Message-ID: <20080717.051704.146865283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51657
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756411AbYGQMRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently it is associated with a netdev_queue, but when we have
qdisc sharing that no longer makes any sense.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 include/net/pkt_sched.h   |    4 +++-
 include/net/sch_generic.h |    6 ++++++
 net/sched/sch_generic.c   |   18 ++++++++++--------
 4 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0883fcf..9240a95 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -441,7 +441,6 @@ static inline void napi_synchronize(const struct napi_struct *n)
 enum netdev_queue_state_t
 {
 	__QUEUE_STATE_XOFF,
-	__QUEUE_STATE_QDISC_RUNNING,
 };
 
 struct netdev_queue {
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index cb95278..06a442d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -88,8 +88,10 @@ extern void __qdisc_run(struct netdev_queue *txq);
 
 static inline void qdisc_run(struct netdev_queue *txq)
 {
+	struct Qdisc *q = txq->qdisc;
+
 	if (!netif_tx_queue_stopped(txq) &&
-	    !test_and_set_bit(__QUEUE_STATE_QDISC_RUNNING, &txq->state))
+	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(txq);
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b96c3d9..bc2a09d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,6 +23,11 @@ struct qdisc_rate_table
 	int		refcnt;
 };
 
+enum qdisc_state_t
+{
+	__QDISC_STATE_RUNNING,
+};
+
 struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -36,6 +41,7 @@ struct Qdisc
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
+	unsigned long		state;
 	struct sk_buff		*gso_skb;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2bd75be..ac208c2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -130,8 +130,8 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 /*
  * NOTE: Called under queue->lock with locally disabled BH.
  *
- * __QUEUE_STATE_QDISC_RUNNING guarantees only one CPU can process
- * this queue at a time. queue->lock serializes queue accesses for
+ * __QDISC_STATE_RUNNING guarantees only one CPU can process
+ * this qdisc at a time. queue->lock serializes queue accesses for
  * this queue AND txq->qdisc pointer itself.
  *
  *  netif_tx_lock serializes accesses to device driver.
@@ -146,9 +146,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct netdev_queue *txq)
+static inline int qdisc_restart(struct netdev_queue *txq,
+				struct Qdisc *q)
 {
-	struct Qdisc *q = txq->qdisc;
 	int ret = NETDEV_TX_BUSY;
 	struct net_device *dev;
 	struct sk_buff *skb;
@@ -168,7 +168,6 @@ static inline int qdisc_restart(struct netdev_queue *txq)
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(&txq->lock);
-	q = txq->qdisc;
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -197,8 +196,9 @@ static inline int qdisc_restart(struct netdev_queue *txq)
 void __qdisc_run(struct netdev_queue *txq)
 {
 	unsigned long start_time = jiffies;
+	struct Qdisc *q = txq->qdisc;
 
-	while (qdisc_restart(txq)) {
+	while (qdisc_restart(txq, q)) {
 		if (netif_tx_queue_stopped(txq))
 			break;
 
@@ -213,7 +213,7 @@ void __qdisc_run(struct netdev_queue *txq)
 		}
 	}
 
-	clear_bit(__QUEUE_STATE_QDISC_RUNNING, &txq->state);
+	clear_bit(__QDISC_STATE_RUNNING, &q->state);
 }
 
 static void dev_watchdog(unsigned long arg)
@@ -666,14 +666,16 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *dev_queue;
+		struct Qdisc *q;
 		int val;
 
 		dev_queue = netdev_get_tx_queue(dev, i);
+		q = dev_queue->qdisc;
 
 		if (lock)
 			spin_lock_bh(&dev_queue->lock);
 
-		val = test_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state);
+		val = test_bit(__QDISC_STATE_RUNNING, &q->state);
 
 		if (lock)
 			spin_unlock_bh(&dev_queue->lock);
-- 
1.5.6.2.255.gbed62

