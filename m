From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 6/6] htb: rbtree cleanup
Date: Wed, 2 Aug 2006 15:09:29 -0700
Message-ID: <20060802150929.2e1ba806@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52173 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932270AbWHBWMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:23 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add code to initialize rb tree nodes, and check for double deletion.
This is not a real fix, but I can make it trap sometimes and may
be a bandaid for: http://bugzilla.kernel.org/show_bug.cgi?id=6681

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c |   34 +++++++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 7853c6f..3f3e9df 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -366,7 +366,7 @@ static void htb_add_to_wait_tree(struct 
  * When we are past last key we return NULL.
  * Average complexity is 2 steps per call.
  */
-static void htb_next_rb_node(struct rb_node **n)
+static inline void htb_next_rb_node(struct rb_node **n)
 {
 	*n = rb_next(*n);
 }
@@ -388,6 +388,18 @@ static inline void htb_add_class_to_row(
 	}
 }
 
+/* If this triggers, it is a bug in this code, but it need not be fatal */
+static void htb_safe_rb_erase(struct rb_node *rb, struct rb_root *root)
+{
+	if (RB_EMPTY_NODE(rb)) {
+		WARN_ON(1);
+	} else {
+		rb_erase(rb, root);
+		RB_CLEAR_NODE(rb);
+	}
+}
+
+
 /**
  * htb_remove_class_from_row - removes class from its row
  *
@@ -401,10 +413,12 @@ static inline void htb_remove_class_from
 
 	while (mask) {
 		int prio = ffz(~mask);
+
 		mask &= ~(1 << prio);
 		if (q->ptr[cl->level][prio] == cl->node + prio)
 			htb_next_rb_node(q->ptr[cl->level] + prio);
-		rb_erase(cl->node + prio, q->row[cl->level] + prio);
+
+		htb_safe_rb_erase(cl->node + prio, q->row[cl->level] + prio);
 		if (!q->row[cl->level][prio].rb_node)
 			m |= 1 << prio;
 	}
@@ -472,7 +486,7 @@ static void htb_deactivate_prios(struct 
 				p->un.inner.ptr[prio] = NULL;
 			}
 
-			rb_erase(cl->node + prio, p->un.inner.feed + prio);
+			htb_safe_rb_erase(cl->node + prio, p->un.inner.feed + prio);
 
 			if (!p->un.inner.feed[prio].rb_node)
 				mask |= 1 << prio;
@@ -739,7 +753,7 @@ #define HTB_ACCNT(T,B,R) toks = diff + c
 		htb_change_class_mode(q, cl, &diff);
 		if (old_mode != cl->cmode) {
 			if (old_mode != HTB_CAN_SEND)
-				rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+				htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
 			if (cl->cmode != HTB_CAN_SEND)
 				htb_add_to_wait_tree(q, cl, diff);
 		}
@@ -782,7 +796,7 @@ static long htb_do_events(struct htb_sch
 		if (time_after(cl->pq_key, q->jiffies)) {
 			return cl->pq_key - q->jiffies;
 		}
-		rb_erase(p, q->wait_pq + level);
+		htb_safe_rb_erase(p, q->wait_pq + level);
 		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32) cl->mbuffer);
 		htb_change_class_mode(q, cl, &diff);
 		if (cl->cmode != HTB_CAN_SEND)
@@ -1279,7 +1293,7 @@ static void htb_destroy_class(struct Qdi
 		htb_deactivate(q, cl);
 
 	if (cl->cmode != HTB_CAN_SEND)
-		rb_erase(&cl->pq_node, q->wait_pq + cl->level);
+		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
 
 	kfree(cl);
 }
@@ -1370,6 +1384,8 @@ static int htb_change_class(struct Qdisc
 
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
+		int prio;
+
 		/* check for valid classid */
 		if (!classid || TC_H_MAJ(classid ^ sch->handle)
 		    || htb_find(classid, sch))
@@ -1389,6 +1405,10 @@ static int htb_change_class(struct Qdisc
 		INIT_HLIST_NODE(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
+		RB_CLEAR_NODE(&cl->pq_node);
+
+		for (prio = 0; prio < TC_HTB_NUMPRIO; prio++)
+			RB_CLEAR_NODE(&cl->node[prio]);
 
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
@@ -1404,7 +1424,7 @@ static int htb_change_class(struct Qdisc
 
 			/* remove from evt list because of level change */
 			if (parent->cmode != HTB_CAN_SEND) {
-				rb_erase(&parent->pq_node, q->wait_pq);
+				htb_safe_rb_erase(&parent->pq_node, q->wait_pq);
 				parent->cmode = HTB_CAN_SEND;
 			}
 			parent->level = (parent->parent ? parent->parent->level
-- 
1.4.0

