From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_teql: fix lockdep splat
Date: Wed, 30 Nov 2011 15:08:58 +0100
Message-ID: <1322662138.2403.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64004 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751741Ab1K3OJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 09:09:03 -0500
Received: by lagw12 with SMTP id w12so110535lag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 06:09:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need rcu_read_lock() protection before using dst_get_neighbour(), and
we must cache its value (pass it to __teql_resolve())

teql_master_xmit() is called under rcu_read_lock_bh() protection, its
not enough.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_teql.c |   31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

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
