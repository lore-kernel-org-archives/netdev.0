From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Mon, 08 Nov 2004 02:40:21 +0100
Message-ID: <418ECE85.9090203@trash.net>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090809090908010403070105"
Cc: netdev@oss.sgi.com, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: Szymon Miotk <spam@crocom.com.pl>
In-Reply-To: <418EA032.7050507@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090809090908010403070105
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:

> Szymon Miotk wrote:
>
>> This mail was posted 02-11-2004 to linux-net@vger.kernel.org, but I 
>> got no response at all, so I am resending it.
>>
>> [1.] One line summary of the problem:
>> IProute hangs after running traffic shaping scripts
>
>
> Can you test if this patch helps please ? It immediately removes all
> inner qdiscs of classful qdiscs from dev->qdisc_list, making it
> impossible for anyone to look up an inner qdisc that is about to get
> destroyed. Taking qdisc_tree_lock in qdisc_lookup is not really
> necessary with this patch anymore, since all changes to dev->qdisc_list
> happen under the rtnl again (which is also relied on for memory). I put
> it in anyways for now until I have fully analyzed locking.

Please test this patch, the last one had a bug.

>
> Regards
> Patrick
>

--------------090809090908010403070105
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/sched/sch_api.c 1.42 vs edited =====
--- 1.42/net/sched/sch_api.c	2004-11-07 05:03:04 +01:00
+++ edited/net/sched/sch_api.c	2004-11-08 02:38:04 +01:00
@@ -196,10 +196,14 @@
 {
 	struct Qdisc *q;
 
+	read_lock_bh(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
-		if (q->handle == handle)
+		if (q->handle == handle) {
+			read_unlock_bh(&qdisc_tree_lock);
 			return q;
+		}
 	}
+	read_unlock_bh(&qdisc_tree_lock);
 	return NULL;
 }
 
===== net/sched/sch_generic.c 1.30 vs edited =====
--- 1.30/net/sched/sch_generic.c	2004-11-06 01:34:45 +01:00
+++ edited/net/sched/sch_generic.c	2004-11-08 00:08:28 +01:00
@@ -483,10 +483,29 @@
 
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
+	list_for_each_entry(cq, &cql, list)
+		list_for_each_entry_safe(q, n, &qdisc->dev->qdisc_list, list)
+			if (TC_H_MAJ(q->parent) == TC_H_MAJ(cq->handle)) {
+				if (q->ops->cl_ops != NULL)
+					list_move_tail(&q->list, &cql);
+				else
+					list_del_init(&q->list);
+			}
+	list_for_each_entry_safe(cq, n, &cql, list)
+		list_del_init(&cq->list);
+
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 

--------------090809090908010403070105--
