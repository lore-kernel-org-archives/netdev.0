From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Wed, 02 Jul 2008 16:21:03 +0200
Message-ID: <486B8ECF.3070604@trash.net>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain> <20080701.195050.177373433.davem@davemloft.net> <486B262F.2040108@cdi.cz> <486B54B7.2060100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050904080206040601080604"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbYGBOVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 10:21:06 -0400
In-Reply-To: <486B54B7.2060100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050904080206040601080604
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Martin Devera wrote:
>> Interestingly, once you do this patch then children/siblings list-heads
>> are used only in htb_parent_last_child and to detect empty class.
>> Thus we could remove children/siblings lists altogether ane keep only
>> children counter.
>> I can't believe it is so simple, what do you think, Patrick ?
> 
> Yes, it looks like that would work. I'll give it a try :)

How about this, on top of my previous patches?



--------------050904080206040601080604
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 4fc866d..bb1c210 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -81,9 +81,8 @@ struct htb_class {
 
 	/* topology */
 	int level;		/* our level (see above) */
+	unsigned int children;
 	struct htb_class *parent;	/* parent class */
-	struct list_head sibling;	/* sibling list item */
-	struct list_head children;	/* children list */
 
 	union {
 		struct htb_class_leaf {
@@ -138,7 +137,6 @@ static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 }
 
 struct htb_sched {
-	struct list_head root;	/* root classes list */
 	struct Qdisc_class_hash clhash;
 	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
 
@@ -1022,7 +1020,6 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 		return -EINVAL;
 	}
 
-	INIT_LIST_HEAD(&q->root);
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
 		return err;
@@ -1177,12 +1174,9 @@ static inline int htb_parent_last_child(struct htb_class *cl)
 	if (!cl->parent)
 		/* the root class */
 		return 0;
-
-	if (!(cl->parent->children.next == &cl->sibling &&
-		cl->parent->children.prev == &cl->sibling))
+	if (cl->parent->children > 1)
 		/* not the last child */
 		return 0;
-
 	return 1;
 }
 
@@ -1266,7 +1260,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	// TODO: why don't allow to delete subtree ? references ? does
 	// tc subsys quarantee us that in htb_destroy it holds no class
 	// refs so that we can remove children safely there ?
-	if (!list_empty(&cl->children) || cl->filter_cnt)
+	if (cl->children || cl->filter_cnt)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
@@ -1285,7 +1279,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 
 	/* delete from hash and active; remainder in destroy_class */
 	qdisc_class_hash_remove(&q->clhash, &cl->common);
-	list_del(&cl->sibling);
+	cl->parent->children--;
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
@@ -1380,8 +1374,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 				  &sch->dev->queue_lock,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
-		INIT_LIST_HEAD(&cl->sibling);
-		INIT_LIST_HEAD(&cl->children);
+		cl->children = 0;
 		INIT_LIST_HEAD(&cl->un.leaf.drop_list);
 		RB_CLEAR_NODE(&cl->pq_node);
 
@@ -1427,8 +1420,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 		/* attach to the hash list and parent's family */
 		qdisc_class_hash_insert(&q->clhash, &cl->common);
-		list_add_tail(&cl->sibling,
-			      parent ? &parent->children : &q->root);
+		if (parent)
+			parent->children++;
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,

--------------050904080206040601080604--
