From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Wed, 10 Nov 2004 01:55:37 +0100
Message-ID: <41916709.8020402@trash.net>
References: <418B4C7C.8000402@crocom.com.pl>	<418EA032.7050507@trash.net>	<418ECE85.9090203@trash.net>	<20041108135431.GE31969@postel.suug.ch>	<418F9AD0.1040701@trash.net>	<20041108183300.GF31969@postel.suug.ch>	<418FCD0A.4040202@trash.net> <20041109161816.425ad7d6.davem@davemloft.net> <41916369.7020901@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408030203090309070206"
Cc: tgraf@suug.ch, spam@crocom.com.pl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <41916369.7020901@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030408030203090309070206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:

> David S. Miller wrote:
>
>> How do these child qdiscs get destroyed at all if you just
>> remove them from the lists they are on?  How will the rest
>> of destroy processing find them and clean them up?
>>
>>  
>
> The RCU-callback calls ops->destroy. The qdisc knows about it's inner
> structure and destroys all classes and the inner qdiscs. dev->qdisc_list
> is just a flat list containing all qdiscs of the tree for lookups.


This is the final patch:

#   [PKT_SCHED]: Unlink inner qdiscs immediately in qdisc_destroy
#
#   Before the RCU change distruction of the qdisc and all inner
#   qdiscs happend immediately and under the rtnl semaphore. This
#   made sure nothing holding the rtnl semaphore could end up with
#   invalid memory. This is not true anymore, inner qdiscs found on
#   dev->qdisc_list can be suddenly destroyed by the RCU callback.
#   Unlink them immediately when the outer qdisc is destroyed so
#   nothing can find them until they get destroyed.

This also makes semantics sane again, an inner qdiscs should not
be user-visible once the containing qdisc has been destroyed. The
second part (locking in qdisc_lookup) is not really required, but
currently the only purpose of qdisc_tree_lock seems to be to protect
dev->qdisc_list, which is also protected by the rtnl. The rtnl is
especially relied on for making sure nobody frees a qdisc while it
is used in user-context, so qdisc_tree_lock looks unnecessary. I'm
currently reviewing all qdisc locking, if this turns out to be right
I will remove qdisc_tree_lock entirely in a follow-up patch, but for
now I left it in for consistency.

Regards
Patrick


--------------030408030203090309070206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/09 07:46:48+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Unlink inner qdiscs immediately in qdisc_destroy
#   
#   Before the RCU change distruction of the qdisc and all inner
#   qdiscs happend immediately and under the rtnl semaphore. This
#   made sure nothing holding the rtnl semaphore could end up with
#   invalid memory. This is not true anymore, inner qdiscs found on
#   dev->qdisc_list can be suddenly destroyed by the RCU callback.
#   Unlink them immediately when the outer qdisc is destroyed so
#   nothing can find them until they get destroyed.
#   
#   With help from Thomas Graf <tgraf@suug.ch>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/11/09 07:46:39+01:00 kaber@coreworks.de +23 -1
#   [PKT_SCHED]: Unlink inner qdiscs immediately in qdisc_destroy
#   
#   Before the RCU change distruction of the qdisc and all inner
#   qdiscs happend immediately and under the rtnl semaphore. This
#   made sure nothing holding the rtnl semaphore could end up with
#   invalid memory. This is not true anymore, inner qdiscs found on
#   dev->qdisc_list can be suddenly destroyed by the RCU callback.
#   Unlink them immediately when the outer qdisc is destroyed so
#   nothing can find them until they get destroyed.
#   
#   With help from Thomas Graf <tgraf@suug.ch>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2004/11/09 07:46:39+01:00 kaber@coreworks.de +5 -1
#   [PKT_SCHED]: Unlink inner qdiscs immediately in qdisc_destroy
#   
#   Before the RCU change distruction of the qdisc and all inner
#   qdiscs happend immediately and under the rtnl semaphore. This
#   made sure nothing holding the rtnl semaphore could end up with
#   invalid memory. This is not true anymore, inner qdiscs found on
#   dev->qdisc_list can be suddenly destroyed by the RCU callback.
#   Unlink them immediately when the outer qdisc is destroyed so
#   nothing can find them until they get destroyed.
#   
#   With help from Thomas Graf <tgraf@suug.ch>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-11-10 01:45:31 +01:00
+++ b/net/sched/sch_api.c	2004-11-10 01:45:31 +01:00
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
 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-11-10 01:45:31 +01:00
+++ b/net/sched/sch_generic.c	2004-11-10 01:45:31 +01:00
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
+				if (q->ops->cl_ops == NULL)
+					list_del_init(&q->list);
+				else
+					list_move_tail(&q->list, &cql);
+			}
+	list_for_each_entry_safe(cq, n, &cql, list)
+		list_del_init(&cq->list);
+
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 

--------------030408030203090309070206--
