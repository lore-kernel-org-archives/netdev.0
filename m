From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] neigh: optimize neigh_parms_release()
Date: Wed, 29 Oct 2014 19:29:31 +0100
Message-ID: <1414607371-4246-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52741 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaJ2SaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:30:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In neigh_parms_release() we loop over all entries to find the entry given in
argument and being able to remove it from the list. By using a double linked
list, we can avoid this loop.

Here are some numbers with 30 000 dummy interfaces configured:

Before the patch:
$ time rmmod dummy
real	2m0.118s
user	0m0.000s
sys	1m50.048s

After the patch:
$ time rmmod dummy
real	1m9.970s
user	0m0.000s
sys	0m47.976s

Suggested-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/neighbour.h |  3 ++-
 net/core/neighbour.c    | 32 +++++++++++++-------------------
 2 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index f60558d0254c..dedfb188b1a7 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -69,7 +69,7 @@ struct neigh_parms {
 	struct net *net;
 #endif
 	struct net_device *dev;
-	struct neigh_parms *next;
+	struct list_head list;
 	int	(*neigh_setup)(struct neighbour *);
 	void	(*neigh_cleanup)(struct neighbour *);
 	struct neigh_table *tbl;
@@ -203,6 +203,7 @@ struct neigh_table {
 	void			(*proxy_redo)(struct sk_buff *skb);
 	char			*id;
 	struct neigh_parms	parms;
+	struct list_head	parms_list;
 	int			gc_interval;
 	int			gc_thresh1;
 	int			gc_thresh2;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ef31fef25e5a..edd04116ecb7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -773,7 +773,7 @@ static void neigh_periodic_work(struct work_struct *work)
 	if (time_after(jiffies, tbl->last_rand + 300 * HZ)) {
 		struct neigh_parms *p;
 		tbl->last_rand = jiffies;
-		for (p = &tbl->parms; p; p = p->next)
+		list_for_each_entry(p, &tbl->parms_list, list)
 			p->reachable_time =
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 	}
@@ -1446,7 +1446,7 @@ static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
 {
 	struct neigh_parms *p;
 
-	for (p = &tbl->parms; p; p = p->next) {
+	list_for_each_entry(p, &tbl->parms_list, list) {
 		if ((p->dev && p->dev->ifindex == ifindex && net_eq(neigh_parms_net(p), net)) ||
 		    (!p->dev && !ifindex && net_eq(net, &init_net)))
 			return p;
@@ -1481,8 +1481,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		}
 
 		write_lock_bh(&tbl->lock);
-		p->next		= tbl->parms.next;
-		tbl->parms.next = p;
+		list_add(&p->list, &tbl->parms.list);
 		write_unlock_bh(&tbl->lock);
 
 		neigh_parms_data_state_cleanall(p);
@@ -1501,24 +1500,15 @@ static void neigh_rcu_free_parms(struct rcu_head *head)
 
 void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 {
-	struct neigh_parms **p;
-
 	if (!parms || parms == &tbl->parms)
 		return;
 	write_lock_bh(&tbl->lock);
-	for (p = &tbl->parms.next; *p; p = &(*p)->next) {
-		if (*p == parms) {
-			*p = parms->next;
-			parms->dead = 1;
-			write_unlock_bh(&tbl->lock);
-			if (parms->dev)
-				dev_put(parms->dev);
-			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
-			return;
-		}
-	}
+	list_del(&parms->list);
+	parms->dead = 1;
 	write_unlock_bh(&tbl->lock);
-	neigh_dbg(1, "%s: not found\n", __func__);
+	if (parms->dev)
+		dev_put(parms->dev);
+	call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 }
 EXPORT_SYMBOL(neigh_parms_release);
 
@@ -1535,6 +1525,8 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	unsigned long now = jiffies;
 	unsigned long phsize;
 
+	INIT_LIST_HEAD(&tbl->parms_list);
+	list_add(&tbl->parms.list, &tbl->parms_list);
 	write_pnet(&tbl->parms.net, &init_net);
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
@@ -2154,7 +2146,9 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 				       NLM_F_MULTI) <= 0)
 			break;
 
-		for (nidx = 0, p = tbl->parms.next; p; p = p->next) {
+		nidx = 0;
+		p = list_next_entry(&tbl->parms, list);
+		list_for_each_entry_from(p, &tbl->parms_list, list) {
 			if (!net_eq(neigh_parms_net(p), net))
 				continue;
 
-- 
2.1.0
