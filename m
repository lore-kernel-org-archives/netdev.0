From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Mon, 08 Nov 2004 20:46:18 +0100
Message-ID: <418FCD0A.4040202@trash.net>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net> <418ECE85.9090203@trash.net> <20041108135431.GE31969@postel.suug.ch> <418F9AD0.1040701@trash.net> <20041108183300.GF31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090707000604020204090600"
Cc: Szymon Miotk <spam@crocom.com.pl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041108183300.GF31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090707000604020204090600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:

>* Patrick McHardy <418F9AD0.1040701@trash.net> 2004-11-08 17:12
>  
>
>>There is some optimization possible, I will do this for the final
>>patch. But I don't understand the problem you refer to, can you
>>please explain ?
>>
>
>I don't have the time to verify this at the moment but:
>
>1) qdisc_destroy unlinking all the lists
>2) RTM_NEWQDISC creating a new qdisc with the same major classid as the old one
>   which will suceed since the old one cannot be found anymore.
>3) rcu callback __qdisc_destroy -> qdisc_destroy looking through qdisc_list
>   again and then deleting the new entries because their major classid matches.
>
>I might be missing something though.
>
You're right, thanks. The optimization already fixed this, but I
wasn't aware of the bug :) New patch attached.

Regards
Patrick


--------------090707000604020204090600
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
+++ edited/net/sched/sch_generic.c	2004-11-08 20:41:58 +01:00
@@ -483,10 +483,32 @@
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
+	struct list_head cql = LIST_HEAD_INIT(cql);
+	struct Qdisc *cq, *q, *n;
+
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 		!atomic_dec_and_test(&qdisc->refcnt))
 		return;
-	list_del(&qdisc->list);
+
+	if (!list_empty(&qdisc->list)) {
+		if (qdisc->ops->cl_ops == NULL)
+			list_del(&qdisc->list);
+		else
+			list_move(&qdisc->list, &cql);
+	}
+
+	/* unlink inner qdiscs from dev->qdisc_list immediately */
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
 

--------------090707000604020204090600--
