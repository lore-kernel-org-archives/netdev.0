From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 4/4] xfs: Transmit flow steering
Date: Tue, 30 Aug 2016 17:00:34 -0700
Message-ID: <1472601634-531498-5-git-send-email-tom@herbertland.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58089 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752279AbcHaABI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:01:08 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u7UNwvkI016036
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 255bq9x0x7-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:49 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 f858c2506f0d11e698a324be05956610-45ed7aa0 for <netdev@vger.kernel.org>;        Tue,
 30 Aug 2016 17:00:47 -0700
In-Reply-To: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XFS maintains a per device flow table that is indexed by the skbuff
hash. The XFS table is only consulted when there is no queue saved in
a transmit socket for an skbuff.

Each entry in the flow table contains a queue index and a queue
pointer. The queue pointer is set when a queue is chosen using a
flow table entry. This pointer is set to the head pointer in the
transmit queue (which is maintained by BQL).

The new function get_xfs_index that looks up flows in the XPS table.
The entry returned gives the last queue a matching flow used. The
returned queue is compared against the normal XPS queue. If they
are different, then we only switch if the tail pointer in the TX
queue has advanced past the pointer saved in the entry. In this
way OOO should be avoided when XPS wants to use a different queue.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/Kconfig    |  6 ++++
 net/core/dev.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 84 insertions(+), 15 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 7b6cd34..5e3eddf 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -255,6 +255,12 @@ config XPS
 	depends on SMP
 	default y
 
+config XFS
+	bool
+	depends on XPS
+	depends on BQL
+	default y
+
 config HWBM
        bool
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 1d5c6dd..722e487 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3210,6 +3210,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 }
 #endif /* CONFIG_NET_EGRESS */
 
+/* Must be called with RCU read_lock */
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
@@ -3217,7 +3218,6 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 	struct xps_map *map;
 	int queue_index = -1;
 
-	rcu_read_lock();
 	dev_maps = rcu_dereference(dev->xps_maps);
 	if (dev_maps) {
 		map = rcu_dereference(
@@ -3232,7 +3232,6 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 				queue_index = -1;
 		}
 	}
-	rcu_read_unlock();
 
 	return queue_index;
 #else
@@ -3240,26 +3239,90 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
-static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
+/* Must be called with RCU read_lock */
+static int get_xfs_index(struct net_device *dev, struct sk_buff *skb)
 {
-	struct sock *sk = skb->sk;
-	int queue_index = sk_tx_queue_get(sk);
+#ifdef CONFIG_XFS
+	struct xps_dev_flow_table *flow_table;
+	struct xps_dev_flow ent;
+	int queue_index;
+	struct netdev_queue *txq;
+	u32 hash;
 
-	if (queue_index < 0 || skb->ooo_okay ||
-	    queue_index >= dev->real_num_tx_queues) {
-		int new_index = get_xps_queue(dev, skb);
-		if (new_index < 0)
-			new_index = skb_tx_hash(dev, skb);
+	flow_table = rcu_dereference(dev->xps_flow_table);
+	if (!flow_table)
+		return -1;
 
-		if (queue_index != new_index && sk &&
-		    sk_fullsock(sk) &&
-		    rcu_access_pointer(sk->sk_dst_cache))
-			sk_tx_queue_set(sk, new_index);
+	queue_index = get_xps_queue(dev, skb);
+	if (queue_index < 0)
+		return -1;
 
-		queue_index = new_index;
+	hash = skb_get_hash(skb);
+	if (!hash)
+		return -1;
+
+	ent.v64 = flow_table->flows[hash & flow_table->mask].v64;
+	if (ent.queue_index >= 0 &&
+	    ent.queue_index < dev->real_num_tx_queues) {
+		txq = netdev_get_tx_queue(dev, ent.queue_index);
+		if (queue_index != ent.queue_index) {
+			if ((int)(txq->tail_cnt - ent.queue_ptr) >= 0)  {
+				/* The current queue's tail has advanced
+				 * beyone the last packet that was
+				 * enqueued using the table entry. All
+				 * previous packets sent for this flow
+				 * should have been completed so the
+				 * queue for the flow cna be changed.
+				 */
+				ent.queue_index = queue_index;
+				txq = netdev_get_tx_queue(dev, queue_index);
+			} else {
+				queue_index = ent.queue_index;
+			}
+		}
+	} else {
+		/* Queue from the table was bad, use the new one. */
+		ent.queue_index = queue_index;
+		txq = netdev_get_tx_queue(dev, queue_index);
 	}
 
+	/* Save the updated entry */
+	ent.queue_ptr = txq->head_cnt;
+	flow_table->flows[hash & flow_table->mask].v64 = ent.v64;
+
 	return queue_index;
+#else
+	return = get_xps_queue(dev, skb);
+#endif
+}
+
+static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	int queue_index = sk_tx_queue_get(sk);
+	int new_index;
+
+	if (queue_index < 0) {
+		/* Socket did not provide a queue index, try XFS */
+		new_index = get_xfs_index(dev, skb);
+	} else if (skb->ooo_okay || queue_index >= dev->real_num_tx_queues) {
+		/* Queue index in socket, see if we can find a better one */
+		new_index = get_xps_queue(dev, skb);
+	} else {
+		/* Valid queue in socket and can't send OOO. Just return it */
+		return queue_index;
+	}
+
+	if (new_index < 0) {
+		/* No queue index from flow steering, fallback to hash */
+		new_index = skb_tx_hash(dev, skb);
+	}
+
+	if (queue_index != new_index && sk && sk_fullsock(sk) &&
+	    rcu_access_pointer(sk->sk_dst_cache))
+		sk_tx_queue_set(sk, new_index);
+
+	return new_index;
 }
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-- 
2.8.0.rc2
