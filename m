From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] CBQ: Destroy filters before destroying classes
Date: Thu, 7 Oct 2004 19:56:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007175636.GB19628@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Note: Only compile tested.

CBQ destroys its classes by traversing the hashtable and thus classes
are not destroyed from root to leafs which means that class Y being
a subclass of class X may be destroyed before X. This is a problem
if a filter is attached to class X (parent) classifying into class Y
(result). In case Y gets deleted before X the filter references an
already deleted class while trying to unbind (cbq_unbind_filter).
Therefore all filters must be destroyed before destroying classes. An
additional BUG_TRAP has been added to document this not so obvious case.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-pre3-bk7.orig/net/sched/sch_cbq.c	2004-10-04 23:00:50.000000000 +0200
+++ linux-2.4.28-pre3-bk7/net/sched/sch_cbq.c	2004-10-07 18:52:52.000000000 +0200
@@ -1716,6 +1716,8 @@
 {
 	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
 
+	BUG_TRAP(!cl->filters);
+
 	cbq_destroy_filters(cl);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
@@ -1736,6 +1738,14 @@
 #ifdef CONFIG_NET_CLS_POLICE
 	q->rx_class = NULL;
 #endif
+	/*
+	 * Filters must be destroyed first because we don't destroy the
+	 * classes from root to leafs which means that filters can still
+	 * be bound to classes which have been destroyed already. --TGR '04
+	 */
+	for (h = 0; h < 16; h++)
+		for (cl = q->classes[h]; cl; cl = cl->next)
+			cbq_destroy_filters(cl);
 
 	for (h = 0; h < 16; h++) {
 		struct cbq_class *next;
