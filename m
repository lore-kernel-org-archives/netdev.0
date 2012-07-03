From: David Miller <davem@davemloft.net>
Subject: [PATCH 06/19] sch_teql: Convert over to dev_neigh_lookup_skb().
Date: Tue, 03 Jul 2012 02:46:17 -0700 (PDT)
Message-ID: <20120703.024617.1895786139124903203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932420Ab2GCJqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:18 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8E2F658411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_teql.c |   39 +++++++++++++--------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index ca0c296..6cd7174 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -67,7 +67,6 @@ struct teql_master {
 struct teql_sched_data {
 	struct Qdisc *next;
 	struct teql_master *m;
-	struct neighbour *ncache;
 	struct sk_buff_head q;
 };
 
@@ -134,7 +133,6 @@ teql_reset(struct Qdisc *sch)
 
 	skb_queue_purge(&dat->q);
 	sch->q.qlen = 0;
-	teql_neigh_release(xchg(&dat->ncache, NULL));
 }
 
 static void
@@ -166,7 +164,6 @@ teql_destroy(struct Qdisc *sch)
 					}
 				}
 				skb_queue_purge(&dat->q);
-				teql_neigh_release(xchg(&dat->ncache, NULL));
 				break;
 			}
 
@@ -225,21 +222,15 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 static int
 __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res,
 	       struct net_device *dev, struct netdev_queue *txq,
-	       struct neighbour *mn)
+	       struct dst_entry *dst)
 {
-	struct teql_sched_data *q = qdisc_priv(txq->qdisc);
-	struct neighbour *n = q->ncache;
+	struct neighbour *n;
+	int err = 0;
+
+	n = dst_neigh_lookup_skb(dst, skb);
+	if (!n)
+		return -ENOENT;
 
-	if (mn->tbl == NULL)
-		return -EINVAL;
-	if (n && n->tbl == mn->tbl &&
-	    memcmp(n->primary_key, mn->primary_key, mn->tbl->key_len) == 0) {
-		atomic_inc(&n->refcnt);
-	} else {
-		n = __neigh_lookup_errno(mn->tbl, mn->primary_key, dev);
-		if (IS_ERR(n))
-			return PTR_ERR(n);
-	}
 	if (neigh_event_send(n, skb_res) == 0) {
 		int err;
 		char haddr[MAX_ADDR_LEN];
@@ -248,15 +239,13 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res,
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol), haddr,
 				      NULL, skb->len);
 
-		if (err < 0) {
-			neigh_release(n);
-			return -EINVAL;
-		}
-		teql_neigh_release(xchg(&q->ncache, n));
-		return 0;
+		if (err < 0)
+			err = -EINVAL;
+	} else {
+		err = (skb_res == NULL) ? -EAGAIN : 1;
 	}
 	neigh_release(n);
-	return (skb_res == NULL) ? -EAGAIN : 1;
+	return err;
 }
 
 static inline int teql_resolve(struct sk_buff *skb,
@@ -265,7 +254,6 @@ static inline int teql_resolve(struct sk_buff *skb,
 			       struct netdev_queue *txq)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *mn;
 	int res;
 
 	if (txq->qdisc == &noop_qdisc)
@@ -275,8 +263,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 		return 0;
 
 	rcu_read_lock();
-	mn = dst_get_neighbour_noref(dst);
-	res = mn ? __teql_resolve(skb, skb_res, dev, txq, mn) : 0;
+	res = __teql_resolve(skb, skb_res, dev, txq, dst);
 	rcu_read_unlock();
 
 	return res;
-- 
1.7.10
