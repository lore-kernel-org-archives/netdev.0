From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Tue, 3 May 2005 16:25:50 -0700
Message-ID: <20050503162550.30acf31a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix qlen underrun when doing duplication with netem. If netem is used as 
leaf discipline, then the parent needs to be tweaked when packets  are duplicated.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: netem-2.6.12-rc3/net/sched/sch_api.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_api.c	2005-05-03 11:19:23.000000000 -0700
+++ netem-2.6.12-rc3/net/sched/sch_api.c	2005-05-03 15:20:59.000000000 -0700
@@ -1289,6 +1289,7 @@
 
 subsys_initcall(pktsched_init);
 
+EXPORT_SYMBOL(qdisc_lookup);
 EXPORT_SYMBOL(qdisc_get_rtab);
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
Index: netem-2.6.12-rc3/net/sched/sch_netem.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_netem.c	2005-05-03 11:20:05.000000000 -0700
+++ netem-2.6.12-rc3/net/sched/sch_netem.c	2005-05-03 15:41:14.000000000 -0700
@@ -206,7 +206,6 @@
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	struct sk_buff *skb2;
 	int ret;
 
 	pr_debug("netem_enqueue skb=%p\n", skb);
@@ -220,11 +219,21 @@
 	}
 
 	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)
-	    && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
-		pr_debug("netem_enqueue: dup %p\n", skb2);
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		if (skb2 && netem_delay(sch, skb2) == NET_XMIT_SUCCESS) {
+			struct Qdisc *qp;
+
+			/* Since one packet can generate two packets in the
+			 * queue, the parent's qlen accounting gets confused,
+			 * so fix it.
+			 */
+			qp = qdisc_lookup(sch->dev, TC_H_MAJ(sch->parent));
+			if (qp)
+				qp->q.qlen++;
 
-		if (netem_delay(sch, skb2)) {
 			sch->q.qlen++;
 			sch->bstats.bytes += skb2->len;
 			sch->bstats.packets++;
@@ -253,6 +262,7 @@
 	} else
 		sch->qstats.drops++;
 
+	pr_debug("netem: enqueue ret %d\n", ret);
 	return ret;
 }
 
