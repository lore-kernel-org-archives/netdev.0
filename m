From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sat, 6 Nov 2004 15:50:36 +0100
Message-ID: <20041106145036.GB28715@postel.suug.ch>
References: <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20041106015931.GA28715@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below transforms qdisc_list into a RCU protected list.
However, this does not really fix the problem. The below
example shows what can happen in case a qdisc is deleted
which is classful and calls qdisc_destroy in its destroy
handler.

--->        RTM_DELQDISC message
            ...
            qdisc_destroy() sets up rcu callback __qdisc_destroy
<---        ...
--->        RCU callback __qdisc_destroy
            qdisc_destroy() sets up rcu callback __qdisc_destroy
<---        ...
--->        continueing RTM_DELQDISC message
            ...
<---        message finished
--->        RTM_GETQDISC
            ...
<---        p = qdisc_lookup() (qdisc_lookup itself is not interrupted)
--->        RCU callback __qdisc_destroy
<---        May free p 
--->        continueing RTM_GETQDISC message
            use of p references freed memory --> oops

So using the RCU protected list only enforces the unlinking
to be safe while within a list walk  and the rcu callback
to be deferred until the list walk is complete but may
be executed right after qdisc_lookup and then may free the
entry that was returned.

So we must either rcu_read_lock all codeblocks that use
a result of a qdisc_lookup which is not trivial or ensure
that all rcu callbacks have finished before the next rtnetlink
message is processed.

Maybe the easiest would be to have a refcnt which is
incremented when a rcu callback is set up and decremented
when it finishs and sleep on it after processing a
rtnetlink message until it reaches 0 again.

Thoughts?

Anyway, here's the patch. It's relative to my earlier patch
and Patrick's rcu_assign_ptr patch.

Transform qdisc_list into a RCU protected list to
avoid qdisc_destroy, which might be called from softirq context, to
overwrite the next pointer while a user context list walking is
taking place.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk14.orig/net/sched/sch_api.c linux-2.6.10-rc1-bk14/net/sched/sch_api.c
--- linux-2.6.10-rc1-bk14.orig/net/sched/sch_api.c	2004-11-06 14:57:44.000000000 +0100
+++ linux-2.6.10-rc1-bk14/net/sched/sch_api.c	2004-11-06 14:52:22.000000000 +0100
@@ -196,10 +196,14 @@
 {
 	struct Qdisc *q;
 
-	list_for_each_entry(q, &dev->qdisc_list, list) {
-		if (q->handle == handle)
+	rcu_read_lock();
+	list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
+		if (q->handle == handle) {
+			rcu_read_unlock();
 			return q;
+		}
 	}
+	rcu_read_unlock();
 	return NULL;
 }
 
@@ -453,7 +457,7 @@
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		qdisc_lock_tree(dev);
-		list_add_tail(&sch->list, &dev->qdisc_list);
+		list_add_tail_rcu(&sch->list, &dev->qdisc_list);
 		qdisc_unlock_tree(dev);
 
 #ifdef CONFIG_NET_ESTIMATOR
@@ -817,7 +821,7 @@
 			s_q_idx = 0;
 		read_lock_bh(&qdisc_tree_lock);
 		q_idx = 0;
-		list_for_each_entry(q, &dev->qdisc_list, list) {
+		list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
 				q_idx++;
 				continue;
@@ -1054,7 +1058,7 @@
 	t = 0;
 
 	read_lock_bh(&qdisc_tree_lock);
-	list_for_each_entry(q, &dev->qdisc_list, list) {
+	list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
 		     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
diff -Nru linux-2.6.10-rc1-bk14.orig/net/sched/sch_generic.c linux-2.6.10-rc1-bk14/net/sched/sch_generic.c
--- linux-2.6.10-rc1-bk14.orig/net/sched/sch_generic.c	2004-11-06 14:57:44.000000000 +0100
+++ linux-2.6.10-rc1-bk14/net/sched/sch_generic.c	2004-11-06 15:16:16.000000000 +0100
@@ -486,7 +486,7 @@
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 		!atomic_dec_and_test(&qdisc->refcnt))
 		return;
-	list_del(&qdisc->list);
+	list_del_rcu(&qdisc->list);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 
@@ -507,7 +507,7 @@
 				return;
 			}
 			write_lock_bh(&qdisc_tree_lock);
-			list_add_tail(&qdisc->list, &dev->qdisc_list);
+			list_add_tail_rcu(&qdisc->list, &dev->qdisc_list);
 			write_unlock_bh(&qdisc_tree_lock);
 		} else {
 			qdisc =  &noqueue_qdisc;
