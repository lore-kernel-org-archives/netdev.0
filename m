From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) netem - reinsert for duplication
Date: Thu, 19 May 2005 15:12:50 -0700
Message-ID: <20050519151250.17ab5c81@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netem@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Handle duplication of packets in netem by re-inserting at top of qdisc tree.
This avoid problems with qlen accounting with nested qdisc. This recursion
requires no additional locking but will potentially increase stack depth.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: netem-2.6.12-rc4/net/sched/sch_netem.c
===================================================================
--- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
+++ netem-2.6.12-rc4/net/sched/sch_netem.c
@@ -203,42 +203,47 @@ static int netem_run(struct Qdisc *sch)
 	return 0;
 }
 
+/*
+ * Insert one skb into qdisc.
+ * Note: parent depends on return value to account for queue length.
+ * 	NET_XMIT_DROP: queue length didn't change.
+ *      NET_XMIT_SUCCESS: one skb was queued.
+ */
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb2;
 	int ret;
+	int count = 1;
 
 	pr_debug("netem_enqueue skb=%p\n", skb);
 
+	/* Random duplication */
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
+		++count;
+
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
-		pr_debug("netem_enqueue: random loss\n");
+	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
+		--count;
+
+	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
-		return 0;	/* lie about loss so TCP doesn't know */
+		return NET_XMIT_DROP;
 	}
 
-	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
-		struct sk_buff *skb2;
+	/*
+	 * If we need to duplicate packet, then re-insert at top of the
+	 * qdisc tree, since parent queuer expects that only one
+	 * skb will be queued.
+	 */
+	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
+		struct Qdisc *rootq = sch->dev->qdisc;
+		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
+		q->duplicate = 0;
 
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-		if (skb2 && netem_delay(sch, skb2) == NET_XMIT_SUCCESS) {
-			struct Qdisc *qp;
-
-			/* Since one packet can generate two packets in the
-			 * queue, the parent's qlen accounting gets confused,
-			 * so fix it.
-			 */
-			qp = qdisc_lookup(sch->dev, TC_H_MAJ(sch->parent));
-			if (qp)
-				qp->q.qlen++;
-
-			sch->q.qlen++;
-			sch->bstats.bytes += skb2->len;
-			sch->bstats.packets++;
-		} else
-			sch->qstats.drops++;
+		rootq->enqueue(skb2, rootq);
+		q->duplicate = dupsave;
 	}
 
 	/* If doing simple delay then gap == 0 so all packets
