From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6] CBQ: Destroy filters before destroying classes
Date: Thu, 7 Oct 2004 19:53:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007175313.GA19628@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

CBQ destroys its classes by traversing the hashtable and thus classes
are not destroyed from root to leafs which means that class Y being
a subclass of class X may be destroyed before X. This is a problem
if a filter is attached to class X (parent) classifying into class Y
(result). In case Y gets deleted before X the filter references an
already deleted class while trying to unbind (cbq_unbind_filter).
Therefore all filters must be destroyed before destroying classes. An
additional BUG_TRAP has been added to document this not so obvious case.

Patch is relative to  "Convert Qdiscs to use generic network
statistics/estimator" patchset.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

The BUG can be triggered with the following commands:
$TC qdisc add dev $DEV root handle 10:0 cbq bandwidth 100Mbit avpkt 1400 mpu 64
$TC class add dev $DEV parent 10:0  classid 10:12 cbq bandwidth 100mbit \
       rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
$TC class add dev $DEV parent 10:12  classid 10:13 cbq bandwidth 100mbit \
       rate 100mbit allot 1514 prio 3 maxburst 1 avpkt  500 bounded
$TC filter add dev $DEV parent 10:12 protocol ip prio 10 u32 match ip protocol 6 0xff flowid 10:13
$TC qdisc del dev $DEV root

The deletion ordering in the above case is: 10:0 -> 10:13 -> 10:12

diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_cbq.c linux-2.6.9-rc3-bk6/net/sched/sch_cbq.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_cbq.c	2004-10-07 00:32:25.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_cbq.c	2004-10-07 18:44:44.000000000 +0200
@@ -1749,6 +1749,8 @@
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 
+	BUG_TRAP(!cl->filters);
+
 	cbq_destroy_filters(cl);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
@@ -1769,6 +1771,14 @@
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
