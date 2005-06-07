From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/7] [PKT_SCHED]: Cleanup pfifo_fast qdisc and remove unnecessary code
Date: Tue, 07 Jun 2005 16:08:48 +0200
Message-ID: <20050607140901.469224000@axs>
References: <20050607140842.778143000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=sch_pfifo_fast_cleanup
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removes the skb trimming code which is not needed since we never
touch the skb upon failure. Removes unnecessary initializers,
and simplifies the code a bit.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.13/net/sched/sch_generic.c
===================================================================
--- net-2.6.13.orig/net/sched/sch_generic.c
+++ net-2.6.13/net/sched/sch_generic.c
@@ -311,6 +311,8 @@ static const u8 prio2band[TC_PRIO_MAX+1]
    generic prio+fifo combination.
  */
 
+#define PFIFO_FAST_BANDS 3
+
 static inline struct sk_buff_head *prio2list(struct sk_buff *skb,
 					     struct Qdisc *qdisc)
 {
@@ -318,8 +320,7 @@ static inline struct sk_buff_head *prio2
 	return list + prio2band[skb->priority & TC_PRIO_MAX];
 }
 
-static int
-pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
+static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	struct sk_buff_head *list = prio2list(skb, qdisc);
 
@@ -331,36 +332,34 @@ pfifo_fast_enqueue(struct sk_buff *skb, 
 	return qdisc_drop(skb, qdisc);
 }
 
-static struct sk_buff *
-pfifo_fast_dequeue(struct Qdisc* qdisc)
+static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
 	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	for (prio = 0; prio < 3; prio++, list++) {
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++, list++) {
 		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
 		if (skb) {
 			qdisc->q.qlen--;
 			return skb;
 		}
 	}
+
 	return NULL;
 }
 
-static int
-pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
+static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	qdisc->q.qlen++;
 	return __qdisc_requeue(skb, qdisc, prio2list(skb, qdisc));
 }
 
-static void
-pfifo_fast_reset(struct Qdisc* qdisc)
+static void pfifo_fast_reset(struct Qdisc* qdisc)
 {
 	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	for (prio=0; prio < 3; prio++)
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
 		__qdisc_reset_queue(qdisc, list + prio);
 
 	qdisc->qstats.backlog = 0;
@@ -369,35 +368,30 @@ pfifo_fast_reset(struct Qdisc* qdisc)
 
 static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
 {
-	unsigned char	 *b = skb->tail;
-	struct tc_prio_qopt opt;
+	struct tc_prio_qopt opt = { .bands = PFIFO_FAST_BANDS };
 
-	opt.bands = 3; 
 	memcpy(&opt.priomap, prio2band, TC_PRIO_MAX+1);
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
 	return -1;
 }
 
 static int pfifo_fast_init(struct Qdisc *qdisc, struct rtattr *opt)
 {
-	int i;
+	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	for (i=0; i<3; i++)
-		skb_queue_head_init(list+i);
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
+		skb_queue_head_init(list + prio);
 
 	return 0;
 }
 
 static struct Qdisc_ops pfifo_fast_ops = {
-	.next		=	NULL,
-	.cl_ops		=	NULL,
 	.id		=	"pfifo_fast",
-	.priv_size	=	3 * sizeof(struct sk_buff_head),
+	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.requeue	=	pfifo_fast_requeue,
