From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Wed, 04 May 2005 03:54:33 +0200
Message-ID: <42782B59.3000500@trash.net>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>	<42780AC1.8040409@trash.net>	<20050503163025.38bb9682.davem@davemloft.net>	<42780DB2.2090201@trash.net> <20050503165937.0c6cac6d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020602040806080405010609"
Cc: shemminger@osdl.org, netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503165937.0c6cac6d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020602040806080405010609
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Wed, 04 May 2005 01:48:02 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>That's what I already suggested, it should be pretty simple to do
>>so. I'll send a patch once your tree appears on kernel.org.

This one should work. It keeps a pointer to the parent qdisc in struct
Qdisc and adjusts q.qlen of all parent qdiscs in netem. The __parent
pointer also used by CBQ is renamed to parentq and is used for this. To
avoid confusion, the parent classid is also renamed to parentcl. It
should work with all currently included classful qdiscs except HFSC.
Statistics are not correctly updated (and can't be without support from
the qdisc since classes are internal to it), we need to keep this in
mind in case a qdisc like RED which uses qstats.backlog for calculations
is converted to a classful one. Fixing HFSC is very low priority, it
could only use netem in work-conserving mode anyway.

My favourite solution would be to avoid this hack and let tc actions
handle duplication, as Jamal suggested. My previous point against this
of not necessarily having an identical classification result for the
duplicated packet as the original one is actually a plus since it
provides more flexibility. Steven, what do you think about it?

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------020602040806080405010609
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

Index: include/net/sch_generic.h
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/include/net/sch_generic.h  (mode:100644 sha1:c57504b3b51819522dc9f868aa9a208d61dd3892)
+++ uncommitted/include/net/sch_generic.h  (mode:100644)
@@ -35,7 +35,7 @@
 	int			padded;
 	struct Qdisc_ops	*ops;
 	u32			handle;
-	u32			parent;
+	u32			parentcl;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct net_device	*dev;
@@ -49,10 +49,11 @@
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
 
-	/* This field is deprecated, but it is still used by CBQ
+	/* This field is deprecated, but it is still used by CBQ and netem
 	 * and it will live until better solution will be invented.
+	 * Valid only while qdisc is grafted to its parent.
 	 */
-	struct Qdisc		*__parent;
+	struct Qdisc		*parentq;
 };
 
 struct Qdisc_class_ops
Index: net/sched/sch_api.c
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/net/sched/sch_api.c  (mode:100644 sha1:07977f8f2679b30cf93808f93fbbcce3c3dbc776)
+++ uncommitted/net/sched/sch_api.c  (mode:100644)
@@ -378,9 +378,11 @@
 		if (cops) {
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
+				if (new) {
+					new->parentcl = classid;
+					new->parentq = parent;
+				}
 				err = cops->graft(parent, cl, new, old);
-				if (new)
-					new->parent = classid;
 				cops->put(parent, cl);
 			}
 		}
@@ -855,7 +857,7 @@
 				q_idx++;
 				continue;
 			}
-			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
+			if (tc_fill_qdisc(skb, q, q->parentcl, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
 				read_unlock_bh(&qdisc_tree_lock);
 				goto done;
@@ -1289,7 +1291,6 @@
 
 subsys_initcall(pktsched_init);
 
-EXPORT_SYMBOL(qdisc_lookup);
 EXPORT_SYMBOL(qdisc_get_rtab);
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
Index: net/sched/sch_cbq.c
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/net/sched/sch_cbq.c  (mode:100644 sha1:d43e3b8cbf6af27a25ab7b9d2aee82a32f8010eb)
+++ uncommitted/net/sched/sch_cbq.c  (mode:100644)
@@ -419,9 +419,6 @@
 		return ret;
 	}
 
-#ifdef CONFIG_NET_CLS_POLICE
-	cl->q->__parent = sch;
-#endif
 	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->bstats.packets++;
@@ -456,7 +453,6 @@
 
 #ifdef CONFIG_NET_CLS_POLICE
 	q->rx_class = cl;
-	cl->q->__parent = sch;
 #endif
 	if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
 		sch->q.qlen++;
@@ -690,7 +686,7 @@
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
 	int len = skb->len;
-	struct Qdisc *sch = child->__parent;
+	struct Qdisc *sch = child->parentq;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
 
@@ -701,7 +697,6 @@
 		cbq_mark_toplevel(q, cl);
 
 		q->rx_class = cl;
-		cl->q->__parent = sch;
 
 		if (cl->q->enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
Index: net/sched/sch_generic.c
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/net/sched/sch_generic.c  (mode:100644 sha1:87e48a4e105133ca3d0407b5c2d84f1b0e3a72c4)
+++ uncommitted/net/sched/sch_generic.c  (mode:100644)
@@ -501,7 +501,7 @@
 	/* unlink inner qdiscs from dev->qdisc_list immediately */
 	list_for_each_entry(cq, &cql, list)
 		list_for_each_entry_safe(q, n, &qdisc->dev->qdisc_list, list)
-			if (TC_H_MAJ(q->parent) == TC_H_MAJ(cq->handle)) {
+			if (TC_H_MAJ(q->parentcl) == TC_H_MAJ(cq->handle)) {
 				if (q->ops->cl_ops == NULL)
 					list_del_init(&q->list);
 				else
Index: net/sched/sch_netem.c
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/net/sched/sch_netem.c  (mode:100644 sha1:e0c9fbe73b15cee32b44f4469e1ac5eeb9849267)
+++ uncommitted/net/sched/sch_netem.c  (mode:100644)
@@ -230,8 +230,7 @@
 			 * queue, the parent's qlen accounting gets confused,
 			 * so fix it.
 			 */
-			qp = qdisc_lookup(sch->dev, TC_H_MAJ(sch->parent));
-			if (qp)
+			for (qp = sch->parentq; qp; qp = qp->parentq)
 				qp->q.qlen++;
 
 			sch->q.qlen++;

--------------020602040806080405010609--
