From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Fri, 5 Nov 2004 15:16:40 +0100
Message-ID: <20041105141640.GQ19714@rei.reeler.org>
References: <418B4C7C.8000402@crocom.com.pl> <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, spam@crocom.com.pl, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Oct 31 15:02:38 cerber kernel: Unable to handle kernel paging request at
> virtual address 00100100

The conversion to the generic list API was nice, it really helps
in such a case when a poison value shows up in an oops. However
it is not nice if new bugs are introduced with such changes.

-   if (dev) {
-       struct Qdisc *q, **qp;
-       for (qp = &qdisc->dev->qdisc_list; (q=*qp) != NULL; qp = &q->next) {
-           if (q == qdisc) {
-               *qp = q->next;
-               break;
-           }
-       }
-   }
+   list_del(&qdisc->list);

Nice cleanup, although it assumes that everyone calling qdisc_destroy provides a
Qdisc which is actually linked or at least has an initialized list node. This
was not the true for noqueue and noop dummy qdiscs.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk14.orig/net/sched/sch_generic.c	2004-11-05 01:11:17.000000000 +0100
+++ linux-2.6.10-rc1-bk14/net/sched/sch_generic.c	2004-11-05 15:05:54.000000000 +0100
@@ -280,6 +280,7 @@
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,	
+	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 };
 
 struct Qdisc_ops noqueue_qdisc_ops = {
@@ -298,6 +299,7 @@
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
+	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
 };
 
 
