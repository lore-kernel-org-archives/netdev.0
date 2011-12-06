From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/13 net-3.1-stable] sch_teql: fix lockdep splat
Date: Tue, 06 Dec 2011 16:33:30 -0500 (EST)
Message-ID: <20111206.163330.336716281635144016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1LFVdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:31 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXUr0024185
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:31 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Eric Dumazet <eric.dumazet@gmail.com>

[ Upstream commit f7e57044eeb1841847c24aa06766c8290c202583 ]

We need rcu_read_lock() protection before using dst_get_neighbour(), and
we must cache its value (pass it to __teql_resolve())

teql_master_xmit() is called under rcu_read_lock_bh() protection, its
not enough.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_teql.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index a3b7120..4f4c52c 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -225,11 +225,11 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 
 
 static int
-__teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
+__teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res,
+	       struct net_device *dev, struct netdev_queue *txq,
+	       struct neighbour *mn)
 {
-	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
-	struct teql_sched_data *q = qdisc_priv(dev_queue->qdisc);
-	struct neighbour *mn = dst_get_neighbour(skb_dst(skb));
+	struct teql_sched_data *q = qdisc_priv(txq->qdisc);
 	struct neighbour *n = q->ncache;
 
 	if (mn->tbl == NULL)
@@ -262,17 +262,26 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 }
 
 static inline int teql_resolve(struct sk_buff *skb,
-			       struct sk_buff *skb_res, struct net_device *dev)
+			       struct sk_buff *skb_res,
+			       struct net_device *dev,
+			       struct netdev_queue *txq)
 {
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	struct dst_entry *dst = skb_dst(skb);
+	struct neighbour *mn;
+	int res;
+
 	if (txq->qdisc == &noop_qdisc)
 		return -ENODEV;
 
-	if (dev->header_ops == NULL ||
-	    skb_dst(skb) == NULL ||
-	    dst_get_neighbour(skb_dst(skb)) == NULL)
+	if (!dev->header_ops || !dst)
 		return 0;
-	return __teql_resolve(skb, skb_res, dev);
+
+	rcu_read_lock();
+	mn = dst_get_neighbour(dst);
+	res = mn ? __teql_resolve(skb, skb_res, dev, txq, mn) : 0;
+	rcu_read_unlock();
+
+	return res;
 }
 
 static netdev_tx_t teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -307,7 +316,7 @@ restart:
 			continue;
 		}
 
-		switch (teql_resolve(skb, skb_res, slave)) {
+		switch (teql_resolve(skb, skb_res, slave, slave_txq)) {
 		case 0:
 			if (__netif_tx_trylock(slave_txq)) {
 				unsigned int length = qdisc_pkt_len(skb);
-- 
1.7.7.3
