From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Sun, 07 Nov 2004 23:22:42 +0100
Message-ID: <418EA032.7050507@trash.net>
References: <418B4C7C.8000402@crocom.com.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090005050602060004080505"
Cc: netdev@oss.sgi.com, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: Szymon Miotk <spam@crocom.com.pl>
In-Reply-To: <418B4C7C.8000402@crocom.com.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090005050602060004080505
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Szymon Miotk wrote:

> This mail was posted 02-11-2004 to linux-net@vger.kernel.org, but I 
> got no response at all, so I am resending it.
>
> [1.] One line summary of the problem:
> IProute hangs after running traffic shaping scripts

Can you test if this patch helps please ? It immediately removes all
inner qdiscs of classful qdiscs from dev->qdisc_list, making it
impossible for anyone to look up an inner qdisc that is about to get
destroyed. Taking qdisc_tree_lock in qdisc_lookup is not really
necessary with this patch anymore, since all changes to dev->qdisc_list
happen under the rtnl again (which is also relied on for memory). I put
it in anyways for now until I have fully analyzed locking.

Regards
Patrick


--------------090005050602060004080505
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/sched/sch_api.c 1.42 vs edited =====
--- 1.42/net/sched/sch_api.c	2004-11-07 05:03:04 +01:00
+++ edited/net/sched/sch_api.c	2004-11-07 22:59:52 +01:00
@@ -194,13 +194,15 @@
 
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
-	struct Qdisc *q;
+	struct Qdisc *q = NULL;
 
+	read_lock_bh(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle == handle)
-			return q;
+			break;
 	}
-	return NULL;
+	read_unlock_bh(&qdisc_tree_lock);
+	return q;
 }
 
 struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
===== net/sched/sch_generic.c 1.30 vs edited =====
--- 1.30/net/sched/sch_generic.c	2004-11-06 01:34:45 +01:00
+++ edited/net/sched/sch_generic.c	2004-11-07 22:37:55 +01:00
@@ -483,10 +483,30 @@
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
+	struct list_head cql = LIST_HEAD_INIT(cql);
+	struct Qdisc *cq, *q, *n;
+
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 		!atomic_dec_and_test(&qdisc->refcnt))
 		return;
+
 	list_del(&qdisc->list);
+
+	/* unlink inner qdiscs from dev->qdisc_list immediately */
+	if (qdisc->ops->cl_ops != NULL)
+		list_add(&qdisc->list, &cql);
+	list_for_each_entry(cq, &cql, list) {
+		list_for_each_entry_safe(q, n, &qdisc->dev->qdisc_list, list)
+		if (TC_H_MAJ(q->parent) == TC_H_MAJ(cq->handle)) {
+			if (q->ops->cl_ops != NULL)
+				list_move_tail(&q->list, &cql);
+			else
+				list_del_init(&q->list);
+		}
+	}
+	list_for_each_entry_safe(cq, n, &cql, list)
+		list_del_init(&cq->list);
+
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 

--------------090005050602060004080505--
