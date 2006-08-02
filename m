From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/6] htb: use hlist for hash lists.
Date: Wed, 2 Aug 2006 15:03:40 -0700
Message-ID: <20060802150340.7faabd1d@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51149 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932272AbWHBWMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:21 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use hlist instead of list for the hash list. This saves
space, and we can check for double delete better.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c |   49 +++++++++++++++++++++++++++----------------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 528d5c5..7853c6f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -104,7 +104,7 @@ #endif
 	/* topology */
 	int level;		/* our level (see above) */
 	struct htb_class *parent;	/* parent class */
-	struct list_head hlist;	/* classid hash list item */
+	struct hlist_node hlist;	/* classid hash list item */
 	struct list_head sibling;	/* sibling list item */
 	struct list_head children;	/* children list */
 
@@ -163,8 +163,8 @@ static inline long L2T(struct htb_class 
 
 struct htb_sched {
 	struct list_head root;	/* root classes list */
-	struct list_head hash[HTB_HSIZE];	/* hashed by classid */
-	struct list_head drops[TC_HTB_NUMPRIO];	/* active leaves (for drops) */
+	struct hlist_head hash[HTB_HSIZE];	/* hashed by classid */
+	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
 	/* self list - roots of self generating tree */
 	struct rb_root row[TC_HTB_MAXDEPTH][TC_HTB_NUMPRIO];
@@ -220,12 +220,13 @@ #endif
 static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct list_head *p;
+	struct hlist_node *p;
+	struct htb_class *cl;
+
 	if (TC_H_MAJ(handle) != sch->handle)
 		return NULL;
 
-	list_for_each(p, q->hash + htb_hash(handle)) {
-		struct htb_class *cl = list_entry(p, struct htb_class, hlist);
+	hlist_for_each_entry(cl, p, q->hash + htb_hash(handle), hlist) {
 		if (cl->classid == handle)
 			return cl;
 	}
@@ -675,7 +676,9 @@ static void htb_rate_timer(unsigned long
 {
 	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct htb_sched *q = qdisc_priv(sch);
-	struct list_head *p;
+	struct hlist_node *p;
+	struct htb_class *cl;
+
 
 	/* lock queue so that we can muck with it */
 	spin_lock_bh(&sch->dev->queue_lock);
@@ -686,9 +689,8 @@ static void htb_rate_timer(unsigned long
 	/* scan and recompute one bucket at time */
 	if (++q->recmp_bucket >= HTB_HSIZE)
 		q->recmp_bucket = 0;
-	list_for_each(p, q->hash + q->recmp_bucket) {
-		struct htb_class *cl = list_entry(p, struct htb_class, hlist);
 
+	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist) {
 		RT_GEN(cl->sum_bytes, cl->rate_bytes);
 		RT_GEN(cl->sum_packets, cl->rate_packets);
 	}
@@ -1041,10 +1043,10 @@ static void htb_reset(struct Qdisc *sch)
 	int i;
 
 	for (i = 0; i < HTB_HSIZE; i++) {
-		struct list_head *p;
-		list_for_each(p, q->hash + i) {
-			struct htb_class *cl =
-			    list_entry(p, struct htb_class, hlist);
+		struct hlist_node *p;
+		struct htb_class *cl;
+
+		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
 			if (cl->level)
 				memset(&cl->un.inner, 0, sizeof(cl->un.inner));
 			else {
@@ -1091,7 +1093,7 @@ static int htb_init(struct Qdisc *sch, s
 
 	INIT_LIST_HEAD(&q->root);
 	for (i = 0; i < HTB_HSIZE; i++)
-		INIT_LIST_HEAD(q->hash + i);
+		INIT_HLIST_HEAD(q->hash + i);
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
 		INIT_LIST_HEAD(q->drops + i);
 
@@ -1269,7 +1271,8 @@ static void htb_destroy_class(struct Qdi
 						  struct htb_class, sibling));
 
 	/* note: this delete may happen twice (see htb_delete) */
-	list_del(&cl->hlist);
+	if (!hlist_unhashed(&cl->hlist))
+		hlist_del(&cl->hlist);
 	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
@@ -1317,7 +1320,9 @@ static int htb_delete(struct Qdisc *sch,
 	sch_tree_lock(sch);
 
 	/* delete from hash and active; remainder in destroy_class */
-	list_del_init(&cl->hlist);
+	if (!hlist_unhashed(&cl->hlist))
+		hlist_del(&cl->hlist);
+
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
 
@@ -1381,7 +1386,7 @@ static int htb_change_class(struct Qdisc
 
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
-		INIT_LIST_HEAD(&cl->hlist);
+		INIT_HLIST_NODE(&cl->hlist);
 		INIT_LIST_HEAD(&cl->children);
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 
@@ -1420,7 +1425,7 @@ static int htb_change_class(struct Qdisc
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
-		list_add_tail(&cl->hlist, q->hash + htb_hash(classid));
+		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
 	} else
@@ -1520,10 +1525,10 @@ static void htb_walk(struct Qdisc *sch, 
 		return;
 
 	for (i = 0; i < HTB_HSIZE; i++) {
-		struct list_head *p;
-		list_for_each(p, q->hash + i) {
-			struct htb_class *cl =
-			    list_entry(p, struct htb_class, hlist);
+		struct hlist_node *p;
+		struct htb_class *cl;
+
+		hlist_for_each_entry(cl, p, q->hash + i, hlist) {
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
-- 
1.4.0

