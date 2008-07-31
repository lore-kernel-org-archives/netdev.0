From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net_sched: Add qdisc __NET_XMIT_STOLEN flag
Date: Thu, 31 Jul 2008 19:14:31 +0200
Message-ID: <20080731171431.GA9464@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:17155 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYGaRN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 13:13:58 -0400
Received: by ug-out-1314.google.com with SMTP id h2so412065ugf.16
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 10:13:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is a complete, I hope,  version of the patch to not linger this
all to much, but of course any redoing is possible.

Thanks,
Jarek P.

----------------->

Subject: net_sched: Add qdisc __NET_XMIT_STOLEN flag

Patrick McHardy <kaber@trash.net> noticed:
"The other problem that affects all qdiscs supporting actions is
TC_ACT_QUEUED/TC_ACT_STOLEN getting mapped to NET_XMIT_SUCCESS
even though the packet is not queued, corrupting upper qdiscs'
qlen counters."

and later explained:
"The reason why it translates it at all seems to be to not increase
the drops counter. Within a single qdisc this could be avoided by
other means easily, upper qdiscs would still increase the counter
when we return anything besides NET_XMIT_SUCCESS though.

This means we need a new NET_XMIT return value to indicate this to
the upper qdiscs. So I'd suggest to introduce NET_XMIT_STOLEN,
return that to upper qdiscs and translate it to NET_XMIT_SUCCESS
in dev_queue_xmit, similar to NET_XMIT_BYPASS."

David Miller <davem@davemloft.net> noticed:
"Maybe these NET_XMIT_* values being passed around should be a set of
bits. They could be composed of base meanings, combined with specific
attributes.

So you could say "NET_XMIT_DROP | __NET_XMIT_NO_DROP_COUNT"

The attributes get masked out by the top-level ->enqueue() caller,
such that the base meanings are the only thing that make their
way up into the stack. If it's only about communication within the
qdisc tree, let's simply code it that way."

This patch is trying to realize these ideas.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/linux/netdevice.h |    1 +
 include/net/sch_generic.h |   14 +++++++++++++-
 net/sched/sch_atm.c       |   12 +++++++-----
 net/sched/sch_cbq.c       |   23 +++++++++++++++--------
 net/sched/sch_dsmark.c    |    8 +++++---
 net/sched/sch_hfsc.c      |    8 +++++---
 net/sched/sch_htb.c       |   18 +++++++++++-------
 net/sched/sch_netem.c     |    3 ++-
 net/sched/sch_prio.c      |    8 +++++---
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |    2 +-
 net/sched/sch_tbf.c       |    3 ++-
 12 files changed, 68 insertions(+), 34 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b4d056c..188e4e4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -64,6 +64,7 @@ struct wireless_dev;
 #define NET_XMIT_BYPASS		4	/* packet does not leave via dequeue;
 					   (TC use only - dev_queue_xmit
 					   returns this as NET_XMIT_SUCCESS) */
+#define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b5f40d7..f139009 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -331,6 +331,18 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 	return qdisc_skb_cb(skb)->pkt_len;
 }
 
+#ifdef CONFIG_NET_CLS_ACT
+/* additional qdisc xmit flags */
+enum net_xmit_qdisc_t {
+	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
+};
+
+#define net_xmit_drop_count(e)	((e) & __NET_XMIT_STOLEN ? 0 : 1)
+
+#else
+#define net_xmit_drop_count(e)	(1)
+#endif
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
@@ -343,7 +355,7 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	return qdisc_enqueue(skb, sch);
+	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 6b517b9..27dd773 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -415,7 +415,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
-			return NET_XMIT_SUCCESS;
+			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			kfree_skb(skb);
 			goto drop;
@@ -432,9 +432,11 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret = qdisc_enqueue(skb, flow->q);
 	if (ret != 0) {
 drop: __maybe_unused
-		sch->qstats.drops++;
-		if (flow)
-			flow->qstats.drops++;
+		if (net_xmit_drop_count(ret)) {
+			sch->qstats.drops++;
+			if (flow)
+				flow->qstats.drops++;
+		}
 		return ret;
 	}
 	sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -530,7 +532,7 @@ static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	if (!ret) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
-	} else {
+	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
 		p->link.qstats.drops++;
 	}
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 14954bf..765ae56 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -256,7 +256,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		case TC_ACT_RECLASSIFY:
@@ -397,9 +397,11 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
-	sch->qstats.drops++;
-	cbq_mark_toplevel(q, cl);
-	cl->qstats.drops++;
+	if (net_xmit_drop_count(ret)) {
+		sch->qstats.drops++;
+		cbq_mark_toplevel(q, cl);
+		cl->qstats.drops++;
+	}
 	return ret;
 }
 
@@ -430,8 +432,10 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 			cbq_activate_class(cl);
 		return 0;
 	}
-	sch->qstats.drops++;
-	cl->qstats.drops++;
+	if (net_xmit_drop_count(ret)) {
+		sch->qstats.drops++;
+		cl->qstats.drops++;
+	}
 	return ret;
 }
 
@@ -664,13 +668,15 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 	q->rx_class = NULL;
 
 	if (cl && (cl = cbq_reclassify(skb, cl)) != NULL) {
+		int ret;
 
 		cbq_mark_toplevel(q, cl);
 
 		q->rx_class = cl;
 		cl->q->__parent = sch;
 
-		if (qdisc_enqueue(skb, cl->q) == 0) {
+		ret = qdisc_enqueue(skb, cl->q);
+		if (ret == NET_XMIT_SUCCESS) {
 			sch->q.qlen++;
 			sch->bstats.packets++;
 			sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -678,7 +684,8 @@ static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 				cbq_activate_class(cl);
 			return 0;
 		}
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(ret))
+			sch->qstats.drops++;
 		return 0;
 	}
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index a935676..7170275 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -236,7 +236,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
-			return NET_XMIT_SUCCESS;
+			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 
 		case TC_ACT_SHOT:
 			goto drop;
@@ -254,7 +254,8 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err))
+			sch->qstats.drops++;
 		return err;
 	}
 
@@ -321,7 +322,8 @@ static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = p->q->ops->requeue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err))
+			sch->qstats.drops++;
 		return err;
 	}
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0ae7d19..5cf9ae7 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1166,7 +1166,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
@@ -1586,8 +1586,10 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
-		cl->qstats.drops++;
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err)) {
+			cl->qstats.drops++;
+			sch->qstats.drops++;
+		}
 		return err;
 	}
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 75a4095..538d79b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -221,7 +221,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
@@ -572,9 +572,11 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (qdisc_enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
+	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q)) != NET_XMIT_SUCCESS) {
+		if (net_xmit_drop_count(ret)) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		}
 		return NET_XMIT_DROP;
 	} else {
 		cl->bstats.packets +=
@@ -615,10 +617,12 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
+	} else if ((ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q)) !=
 		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
+		if (net_xmit_drop_count(ret)) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		}
 		return NET_XMIT_DROP;
 	} else
 		htb_activate(q, cl);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a590857..6cd6f2b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -240,8 +240,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->q.qlen++;
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
-	} else
+	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
+	}
 
 	pr_debug("netem: enqueue ret %d\n", ret);
 	return ret;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index f849243..adb1a52 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -45,7 +45,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (err) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
@@ -88,7 +88,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
-	sch->qstats.drops++;
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
 	return ret;
 }
 
@@ -114,7 +115,8 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 		sch->qstats.requeues++;
 		return 0;
 	}
-	sch->qstats.drops++;
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
 	return NET_XMIT_DROP;
 }
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 3f2d1d7..5da0583 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -97,7 +97,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		sch->bstats.bytes += qdisc_pkt_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
-	} else {
+	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
 		sch->qstats.drops++;
 	}
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8589da6..3a456e1 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -178,7 +178,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
 		}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b296672..7d3b7ff 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -135,7 +135,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	ret = qdisc_enqueue(skb, q->qdisc);
 	if (ret != 0) {
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(ret))
+			sch->qstats.drops++;
 		return ret;
 	}
 
