From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] cache align qdisc data
Date: Tue, 3 Aug 2004 14:05:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803140538.7c40f961@dell_ss3.pdx.osdl.net>
References: <410FAE42.2050909@trash.net>
	<20040803083820.711c917c@dell_ss3.pdx.osdl.net>
	<410FE4DD.5000306@trash.net>
	<20040803133139.43107fd3@dell_ss3.pdx.osdl.net>
	<410FF8C4.7010705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <410FF8C4.7010705@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ugh, here it is without the hfsc messup.

diff -urN -X dontdiff linux-2.6/include/net/pkt_sched.h qdisc-2.6/include/net/pkt_sched.h
--- linux-2.6/include/net/pkt_sched.h	2004-07-30 12:17:02.000000000 -0700
+++ qdisc-2.6/include/net/pkt_sched.h	2004-08-03 12:50:52.324952264 -0700
@@ -77,6 +77,7 @@
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRES	4
+	int			padded;
 	struct Qdisc_ops	*ops;
 	struct Qdisc		*next;
 	u32			handle;
@@ -93,10 +94,17 @@
 	 * and it will live until better solution will be invented.
 	 */
 	struct Qdisc		*__parent;
-
-	char			data[0];
 };
 
+#define	QDISC_ALIGN		32
+#define	QDISC_ALIGN_CONST	(QDISC_ALIGN - 1)
+
+static inline void *qdisc_priv(struct Qdisc *q)
+{
+	return (char *)q + ((sizeof(struct Qdisc) + QDISC_ALIGN_CONST)
+			      & ~QDISC_ALIGN_CONST);
+}
+
 struct qdisc_rate_table
 {
 	struct tc_ratespec rate;
diff -urN -X dontdiff linux-2.6/net/sched/sch_cbq.c qdisc-2.6/net/sched/sch_cbq.c
--- linux-2.6/net/sched/sch_cbq.c	2004-07-07 10:14:26.000000000 -0700
+++ qdisc-2.6/net/sched/sch_cbq.c	2004-07-27 09:17:28.000000000 -0700
@@ -241,7 +241,7 @@
 static struct cbq_class *
 cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *head = &q->link;
 	struct cbq_class **defmap;
 	struct cbq_class *cl = NULL;
@@ -344,7 +344,7 @@
 
 static __inline__ void cbq_activate_class(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	int prio = cl->cpriority;
 	struct cbq_class *cl_tail;
 
@@ -368,7 +368,7 @@
 
 static void cbq_deactivate_class(struct cbq_class *this)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)this->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(this->qdisc);
 	int prio = this->cpriority;
 	struct cbq_class *cl;
 	struct cbq_class *cl_prev = q->active[prio];
@@ -419,7 +419,7 @@
 static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	int len = skb->len;
 	int ret = NET_XMIT_SUCCESS;
 	struct cbq_class *cl = cbq_classify(skb, sch,&ret);
@@ -466,7 +466,7 @@
 static int
 cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
 	int ret;
 
@@ -500,7 +500,7 @@
 
 static void cbq_ovl_classic(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	psched_tdiff_t delay = PSCHED_TDIFF(cl->undertime, q->now);
 
 	if (!cl->delayed) {
@@ -554,7 +554,7 @@
 
 static void cbq_ovl_rclassic(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	struct cbq_class *this = cl;
 
 	do {
@@ -573,7 +573,7 @@
 
 static void cbq_ovl_delay(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	psched_tdiff_t delay = PSCHED_TDIFF(cl->undertime, q->now);
 
 	if (!cl->delayed) {
@@ -609,7 +609,7 @@
 
 static void cbq_ovl_lowprio(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 
 	cl->penalized = jiffies + cl->penalty;
 
@@ -678,7 +678,7 @@
 static void cbq_undelay(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc*)arg;
-	struct cbq_sched_data *q = (struct cbq_sched_data*)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	long delay = 0;
 	unsigned pmask;
 
@@ -715,7 +715,7 @@
 {
 	int len = skb->len;
 	struct Qdisc *sch = child->__parent;
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
 
 	q->rx_class = NULL;
@@ -863,7 +863,7 @@
 static __inline__ struct cbq_class *
 cbq_under_limit(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	struct cbq_class *this_cl = cl;
 
 	if (cl->tparent == NULL)
@@ -903,7 +903,7 @@
 static __inline__ struct sk_buff *
 cbq_dequeue_prio(struct Qdisc *sch, int prio)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl_tail, *cl_prev, *cl;
 	struct sk_buff *skb;
 	int deficit;
@@ -1006,7 +1006,7 @@
 static __inline__ struct sk_buff *
 cbq_dequeue_1(struct Qdisc *sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	unsigned activemask;
 
@@ -1025,7 +1025,7 @@
 cbq_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	psched_time_t now;
 	psched_tdiff_t incr;
 
@@ -1150,7 +1150,7 @@
 
 static void cbq_sync_defmap(struct cbq_class *cl)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 	struct cbq_class *split = cl->split;
 	unsigned h;
 	int i;
@@ -1216,7 +1216,7 @@
 static void cbq_unlink_class(struct cbq_class *this)
 {
 	struct cbq_class *cl, **clp;
-	struct cbq_sched_data *q = (struct cbq_sched_data*)this->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(this->qdisc);
 
 	for (clp = &q->classes[cbq_hash(this->classid)]; (cl = *clp) != NULL; clp = &cl->next) {
 		if (cl == this) {
@@ -1249,7 +1249,7 @@
 
 static void cbq_link_class(struct cbq_class *this)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)this->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(this->qdisc);
 	unsigned h = cbq_hash(this->classid);
 	struct cbq_class *parent = this->tparent;
 
@@ -1270,7 +1270,7 @@
 
 static unsigned int cbq_drop(struct Qdisc* sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl, *cl_head;
 	int prio;
 	unsigned int len;
@@ -1293,7 +1293,7 @@
 static void
 cbq_reset(struct Qdisc* sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
 	int prio;
 	unsigned h;
@@ -1363,7 +1363,7 @@
 
 static int cbq_set_wrr(struct cbq_class *cl, struct tc_cbq_wrropt *wrr)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)cl->qdisc->data;
+	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 
 	if (wrr->allot)
 		cl->allot = wrr->allot;
@@ -1432,7 +1432,7 @@
 
 static int cbq_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct rtattr *tb[TCA_CBQ_MAX];
 	struct tc_ratespec *r;
 
@@ -1623,7 +1623,7 @@
 
 static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 
@@ -1650,7 +1650,7 @@
 cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data*)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)arg;
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
@@ -1726,7 +1726,7 @@
 
 static unsigned long cbq_get(struct Qdisc *sch, u32 classid)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = cbq_class_lookup(q, classid);
 
 	if (cl) {
@@ -1760,7 +1760,7 @@
 static void
 cbq_destroy(struct Qdisc* sch)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl;
 	unsigned h;
 
@@ -1791,7 +1791,7 @@
 
 	if (--cl->refcnt == 0) {
 #ifdef CONFIG_NET_CLS_POLICE
-		struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+		struct cbq_sched_data *q = qdisc_priv(sch);
 
 		spin_lock_bh(&sch->dev->queue_lock);
 		if (q->rx_class == cl)
@@ -1808,7 +1808,7 @@
 		 unsigned long *arg)
 {
 	int err;
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)*arg;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_CBQ_MAX];
@@ -2004,7 +2004,7 @@
 
 static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
 	if (cl->filters || cl->children || cl == &q->link)
@@ -2042,7 +2042,7 @@
 
 static struct tcf_proto **cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class *)arg;
 
 	if (cl == NULL)
@@ -2054,7 +2054,7 @@
 static unsigned long cbq_bind_filter(struct Qdisc *sch, unsigned long parent,
 				     u32 classid)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *p = (struct cbq_class*)parent;
 	struct cbq_class *cl = cbq_class_lookup(q, classid);
 
@@ -2076,7 +2076,7 @@
 
 static void cbq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	struct cbq_sched_data *q = (struct cbq_sched_data *)sch->data;
+	struct cbq_sched_data *q = qdisc_priv(sch);
 	unsigned h;
 
 	if (arg->stop)
diff -urN -X dontdiff linux-2.6/net/sched/sch_dsmark.c qdisc-2.6/net/sched/sch_dsmark.c
--- linux-2.6/net/sched/sch_dsmark.c	2004-04-19 10:03:23.000000000 -0700
+++ qdisc-2.6/net/sched/sch_dsmark.c	2004-07-27 09:17:28.000000000 -0700
@@ -30,7 +30,7 @@
 #endif
 
 
-#define PRIV(sch) ((struct dsmark_qdisc_data *) (sch)->data)
+#define PRIV(sch) qdisc_priv(sch)
 
 
 /*
diff -urN -X dontdiff linux-2.6/net/sched/sch_fifo.c qdisc-2.6/net/sched/sch_fifo.c
--- linux-2.6/net/sched/sch_fifo.c	2004-02-19 10:28:27.000000000 -0800
+++ qdisc-2.6/net/sched/sch_fifo.c	2004-07-27 09:17:28.000000000 -0700
@@ -45,7 +45,7 @@
 static int
 bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct fifo_sched_data *q = (struct fifo_sched_data *)sch->data;
+	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (sch->stats.backlog + skb->len <= q->limit) {
 		__skb_queue_tail(&sch->q, skb);
@@ -106,7 +106,7 @@
 static int
 pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct fifo_sched_data *q = (struct fifo_sched_data *)sch->data;
+	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (sch->q.qlen < q->limit) {
 		__skb_queue_tail(&sch->q, skb);
@@ -138,7 +138,7 @@
 
 static int fifo_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct fifo_sched_data *q = (void*)sch->data;
+	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (opt == NULL) {
 		unsigned int limit = sch->dev->tx_queue_len ? : 1;
@@ -158,7 +158,7 @@
 
 static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct fifo_sched_data *q = (void*)sch->data;
+	struct fifo_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct tc_fifo_qopt opt;
 
diff -urN -X dontdiff linux-2.6/net/sched/sch_generic.c qdisc-2.6/net/sched/sch_generic.c
--- linux-2.6/net/sched/sch_generic.c	2004-07-30 12:17:03.000000000 -0700
+++ qdisc-2.6/net/sched/sch_generic.c	2004-08-03 12:50:53.071838720 -0700
@@ -283,10 +283,9 @@
 static int
 pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
-	struct sk_buff_head *list;
+	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	list = ((struct sk_buff_head*)qdisc->data) +
-		prio2band[skb->priority&TC_PRIO_MAX];
+	list += prio2band[skb->priority&TC_PRIO_MAX];
 
 	if (list->qlen < qdisc->dev->tx_queue_len) {
 		__skb_queue_tail(list, skb);
@@ -304,7 +303,7 @@
 pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
 	int prio;
-	struct sk_buff_head *list = ((struct sk_buff_head*)qdisc->data);
+	struct sk_buff_head *list = qdisc_priv(qdisc);
 	struct sk_buff *skb;
 
 	for (prio = 0; prio < 3; prio++, list++) {
@@ -320,10 +319,9 @@
 static int
 pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
-	struct sk_buff_head *list;
+	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	list = ((struct sk_buff_head*)qdisc->data) +
-		prio2band[skb->priority&TC_PRIO_MAX];
+	list += prio2band[skb->priority&TC_PRIO_MAX];
 
 	__skb_queue_head(list, skb);
 	qdisc->q.qlen++;
@@ -334,7 +332,7 @@
 pfifo_fast_reset(struct Qdisc* qdisc)
 {
 	int prio;
-	struct sk_buff_head *list = ((struct sk_buff_head*)qdisc->data);
+	struct sk_buff_head *list = qdisc_priv(qdisc);
 
 	for (prio=0; prio < 3; prio++)
 		skb_queue_purge(list+prio);
@@ -359,9 +357,7 @@
 static int pfifo_fast_init(struct Qdisc *qdisc, struct rtattr *opt)
 {
 	int i;
-	struct sk_buff_head *list;
-
-	list = ((struct sk_buff_head*)qdisc->data);
+	struct sk_buff_head *list = qdisc_priv(qdisc);
 
 	for (i=0; i<3; i++)
 		skb_queue_head_init(list+i);
@@ -385,13 +381,22 @@
 
 struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops)
 {
+	void *p;
 	struct Qdisc *sch;
-	int size = sizeof(*sch) + ops->priv_size;
+	int size;
+
+	/* ensure that the Qdisc and the private data are 32-byte aligned */
+	size = ((sizeof(*sch) + QDISC_ALIGN_CONST) & ~QDISC_ALIGN_CONST);
+	size += ops->priv_size + QDISC_ALIGN_CONST;
 
-	sch = kmalloc(size, GFP_KERNEL);
-	if (!sch)
+	p = kmalloc(size, GFP_KERNEL);
+	if (!p)
 		return NULL;
-	memset(sch, 0, size);
+	memset(p, 0, size);
+
+	sch = (struct Qdisc *)(((unsigned long)p + QDISC_ALIGN_CONST) 
+			       & ~QDISC_ALIGN_CONST);
+	sch->padded = (char *)sch - (char *)p;
 
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
@@ -406,7 +411,7 @@
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
 
-	kfree(sch);
+	kfree(p);
 	return NULL;
 }
 
@@ -438,7 +443,7 @@
 	module_put(ops->owner);
 
 	if (!(qdisc->flags&TCQ_F_BUILTIN))
-		kfree(qdisc);
+		kfree((char *) qdisc - qdisc->padded);
 }
 
 /* Under dev->queue_lock and BH! */
diff -urN -X dontdiff linux-2.6/net/sched/sch_gred.c qdisc-2.6/net/sched/sch_gred.c
--- linux-2.6/net/sched/sch_gred.c	2004-06-30 13:42:31.000000000 -0700
+++ qdisc-2.6/net/sched/sch_gred.c	2004-07-27 09:17:28.000000000 -0700
@@ -106,7 +106,7 @@
 {
 	psched_time_t now;
 	struct gred_sched_data *q=NULL;
-	struct gred_sched *t= (struct gred_sched *)sch->data;
+	struct gred_sched *t= qdisc_priv(sch);
 	unsigned long	qave=0;	
 	int i=0;
 
@@ -215,7 +215,7 @@
 gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct gred_sched_data *q;
-	struct gred_sched *t= (struct gred_sched *)sch->data;
+	struct gred_sched *t= qdisc_priv(sch);
 	q= t->tab[(skb->tc_index&0xf)];
 /* error checking here -- probably unnecessary */
 	PSCHED_SET_PASTPERFECT(q->qidlestart);
@@ -231,7 +231,7 @@
 {
 	struct sk_buff *skb;
 	struct gred_sched_data *q;
-	struct gred_sched *t= (struct gred_sched *)sch->data;
+	struct gred_sched *t= qdisc_priv(sch);
 
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
@@ -264,7 +264,7 @@
 	struct sk_buff *skb;
 
 	struct gred_sched_data *q;
-	struct gred_sched *t= (struct gred_sched *)sch->data;
+	struct gred_sched *t= qdisc_priv(sch);
 
 	skb = __skb_dequeue_tail(&sch->q);
 	if (skb) {
@@ -300,7 +300,7 @@
 {
 	int i;
 	struct gred_sched_data *q;
-	struct gred_sched *t= (struct gred_sched *)sch->data;
+	struct gred_sched *t= qdisc_priv(sch);
 
 	__skb_queue_purge(&sch->q);
 
@@ -323,7 +323,7 @@
 
 static int gred_change(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct gred_sched *table = (struct gred_sched *)sch->data;
+	struct gred_sched *table = qdisc_priv(sch);
 	struct gred_sched_data *q;
 	struct tc_gred_qopt *ctl;
 	struct tc_gred_sopt *sopt;
@@ -469,7 +469,7 @@
 
 static int gred_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct gred_sched *table = (struct gred_sched *)sch->data;
+	struct gred_sched *table = qdisc_priv(sch);
 	struct tc_gred_sopt *sopt;
 	struct rtattr *tb[TCA_GRED_STAB];
 	struct rtattr *tb2[TCA_GRED_DPS];
@@ -502,7 +502,7 @@
 	struct rtattr *rta;
 	struct tc_gred_qopt *opt = NULL ;
 	struct tc_gred_qopt *dst;
-	struct gred_sched *table = (struct gred_sched *)sch->data;
+	struct gred_sched *table = qdisc_priv(sch);
 	struct gred_sched_data *q;
 	int i;
 	unsigned char	 *b = skb->tail;
@@ -593,7 +593,7 @@
 
 static void gred_destroy(struct Qdisc *sch)
 {
-	struct gred_sched *table = (struct gred_sched *)sch->data;
+	struct gred_sched *table = qdisc_priv(sch);
 	int i;
 
 	for (i = 0;i < table->DPs; i++) {
diff -urN -X dontdiff linux-2.6/net/sched/sch_hfsc.c qdisc-2.6/net/sched/sch_hfsc.c
--- linux-2.6/net/sched/sch_hfsc.c	2004-07-26 09:20:38.000000000 -0700
+++ qdisc-2.6/net/sched/sch_hfsc.c	2004-08-03 13:58:10.829006328 -0700
@@ -1016,7 +1016,7 @@
 static inline struct hfsc_class *
 hfsc_find_class(u32 classid, struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 
 	list_for_each_entry(cl, &q->clhash[hfsc_hash(classid)], hlist) {
@@ -1061,7 +1061,7 @@
 hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
                   struct rtattr **tca, unsigned long *arg)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl = (struct hfsc_class *)*arg;
 	struct hfsc_class *parent = NULL;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
@@ -1204,7 +1204,7 @@
 static void
 hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 
 	hfsc_destroy_filters(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
@@ -1218,7 +1218,7 @@
 static int
 hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
 	if (cl->level > 0 || cl->filter_cnt > 0 || cl == &q->root)
@@ -1240,7 +1240,7 @@
 static struct hfsc_class *
 hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	struct tcf_result res;
 	struct tcf_proto *tcf;
@@ -1381,7 +1381,7 @@
 static struct tcf_proto **
 hfsc_tcf_chain(struct Qdisc *sch, unsigned long arg)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
 	if (cl == NULL)
@@ -1489,7 +1489,7 @@
 static void
 hfsc_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	unsigned int i;
 
@@ -1523,7 +1523,7 @@
 static void
 hfsc_schedule_watchdog(struct Qdisc *sch, u64 cur_time)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	u64 next_time = 0;
 	long delay;
@@ -1545,7 +1545,7 @@
 static int
 hfsc_init_qdisc(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct tc_hfsc_qopt *qopt;
 	unsigned int i;
 
@@ -1585,7 +1585,7 @@
 static int
 hfsc_change_qdisc(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct tc_hfsc_qopt *qopt;
 
 	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(*qopt))
@@ -1632,7 +1632,7 @@
 static void
 hfsc_reset_qdisc(struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	unsigned int i;
 
@@ -1651,7 +1651,7 @@
 static void
 hfsc_destroy_qdisc(struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl, *next;
 	unsigned int i;
 
@@ -1666,7 +1666,7 @@
 static int
 hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb->tail;
 	struct tc_hfsc_qopt qopt;
 
@@ -1730,7 +1730,7 @@
 static struct sk_buff *
 hfsc_dequeue(struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	struct sk_buff *skb;
 	u64 cur_time;
@@ -1799,7 +1799,7 @@
 static int
 hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 
 	__skb_queue_head(&q->requeue, skb);
 	sch->q.qlen++;
@@ -1809,7 +1809,7 @@
 static unsigned int
 hfsc_drop(struct Qdisc *sch)
 {
-	struct hfsc_sched *q = (struct hfsc_sched *)sch->data;
+	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
 	unsigned int len;
 
diff -urN -X dontdiff linux-2.6/net/sched/sch_htb.c qdisc-2.6/net/sched/sch_htb.c
--- linux-2.6/net/sched/sch_htb.c	2004-07-26 09:20:38.000000000 -0700
+++ qdisc-2.6/net/sched/sch_htb.c	2004-07-27 09:17:28.000000000 -0700
@@ -267,7 +267,7 @@
 /* find class in global hash table using given handle */
 static __inline__ struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct list_head *p;
 	if (TC_H_MAJ(handle) != sch->handle) 
 		return NULL;
@@ -300,7 +300,7 @@
 
 static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl;
 	struct tcf_result res;
 	struct tcf_proto *tcf;
@@ -712,7 +712,7 @@
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
     int ret = NET_XMIT_SUCCESS;
-    struct htb_sched *q = (struct htb_sched *)sch->data;
+    struct htb_sched *q = qdisc_priv(sch);
     struct htb_class *cl = htb_classify(skb,sch,&ret);
 
 
@@ -759,7 +759,7 @@
 /* TODO: requeuing packet charges it to policers again !! */
 static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-    struct htb_sched *q = (struct htb_sched *)sch->data;
+    struct htb_sched *q = qdisc_priv(sch);
     int ret =  NET_XMIT_SUCCESS;
     struct htb_class *cl = htb_classify(skb,sch, &ret);
     struct sk_buff *tskb;
@@ -800,7 +800,7 @@
 static void htb_rate_timer(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc*)arg;
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct list_head *p;
 
 	/* lock queue so that we can muck with it */
@@ -1060,7 +1060,7 @@
 
 static void htb_delay_by(struct Qdisc *sch,long delay)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	if (delay <= 0) delay = 1;
 	if (unlikely(delay > 5*HZ)) {
 		if (net_ratelimit())
@@ -1077,7 +1077,7 @@
 static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb = NULL;
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	int level;
 	long min_delay;
 #ifdef HTB_DEBUG
@@ -1147,7 +1147,7 @@
 /* try to drop from each class (by prio) until one succeed */
 static unsigned int htb_drop(struct Qdisc* sch)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	int prio;
 
 	for (prio = TC_HTB_NUMPRIO - 1; prio >= 0; prio--) {
@@ -1172,7 +1172,7 @@
 /* always caled under BH & queue lock */
 static void htb_reset(struct Qdisc* sch)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	int i;
 	HTB_DBG(0,1,"htb_reset sch=%p, handle=%X\n",sch,sch->handle);
 
@@ -1210,7 +1210,7 @@
 
 static int htb_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct htb_sched *q = (struct htb_sched*)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct rtattr *tb[TCA_HTB_INIT];
 	struct tc_htb_glob *gopt;
 	int i;
@@ -1265,7 +1265,7 @@
 
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct htb_sched *q = (struct htb_sched*)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_glob gopt;
@@ -1300,7 +1300,7 @@
 	struct sk_buff *skb, struct tcmsg *tcm)
 {
 #ifdef HTB_DEBUG
-	struct htb_sched *q = (struct htb_sched*)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 #endif
 	struct htb_class *cl = (struct htb_class*)arg;
 	unsigned char	 *b = skb->tail;
@@ -1358,7 +1358,7 @@
 		sch_tree_lock(sch);
 		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
 			if (cl->prio_activity)
-				htb_deactivate ((struct htb_sched*)sch->data,cl);
+				htb_deactivate (qdisc_priv(sch),cl);
 
 			/* TODO: is it correct ? Why CBQ doesn't do it ? */
 			sch->q.qlen -= (*old)->q.qlen;	
@@ -1379,7 +1379,7 @@
 static unsigned long htb_get(struct Qdisc *sch, u32 classid)
 {
 #ifdef HTB_DEBUG
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 #endif
 	struct htb_class *cl = htb_find(classid,sch);
 	HTB_DBG(0,1,"htb_get clid=%X q=%p cl=%p ref=%d\n",classid,q,cl,cl?cl->refcnt:0);
@@ -1400,7 +1400,7 @@
 
 static void htb_destroy_class(struct Qdisc* sch,struct htb_class *cl)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	HTB_DBG(0,1,"htb_destrycls clid=%X ref=%d\n", cl?cl->classid:0,cl?cl->refcnt:0);
 	if (!cl->level) {
 		BUG_TRAP(cl->un.leaf.q);
@@ -1435,7 +1435,7 @@
 /* always caled under BH & queue lock */
 static void htb_destroy(struct Qdisc* sch)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	HTB_DBG(0,1,"htb_destroy q=%p\n",q);
 
 	del_timer_sync (&q->timer);
@@ -1457,7 +1457,7 @@
 
 static int htb_delete(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class*)arg;
 	HTB_DBG(0,1,"htb_delete q=%p cl=%X ref=%d\n",q,cl?cl->classid:0,cl?cl->refcnt:0);
 
@@ -1484,7 +1484,7 @@
 static void htb_put(struct Qdisc *sch, unsigned long arg)
 {
 #ifdef HTB_DEBUG
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 #endif
 	struct htb_class *cl = (struct htb_class*)arg;
 	HTB_DBG(0,1,"htb_put q=%p cl=%X ref=%d\n",q,cl?cl->classid:0,cl?cl->refcnt:0);
@@ -1497,7 +1497,7 @@
 		u32 parentid, struct rtattr **tca, unsigned long *arg)
 {
 	int err = -EINVAL;
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class*)*arg,*parent;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
@@ -1623,7 +1623,7 @@
 
 static struct tcf_proto **htb_find_tcf(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 	struct tcf_proto **fl = cl ? &cl->filter_list : &q->filter_list;
 	HTB_DBG(0,2,"htb_tcf q=%p clid=%X fref=%d fl=%p\n",q,cl?cl->classid:0,cl?cl->filter_cnt:q->filter_cnt,*fl);
@@ -1633,7 +1633,7 @@
 static unsigned long htb_bind_filter(struct Qdisc *sch, unsigned long parent,
 	u32 classid)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_find (classid,sch);
 	HTB_DBG(0,2,"htb_bind q=%p clid=%X cl=%p fref=%d\n",q,classid,cl,cl?cl->filter_cnt:q->filter_cnt);
 	/*if (cl && !cl->level) return 0;
@@ -1654,7 +1654,7 @@
 
 static void htb_unbind_filter(struct Qdisc *sch, unsigned long arg)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)arg;
 	HTB_DBG(0,2,"htb_unbind q=%p cl=%p fref=%d\n",q,cl,cl?cl->filter_cnt:q->filter_cnt);
 	if (cl) 
@@ -1665,7 +1665,7 @@
 
 static void htb_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	struct htb_sched *q = (struct htb_sched *)sch->data;
+	struct htb_sched *q = qdisc_priv(sch);
 	int i;
 
 	if (arg->stop)
diff -urN -X dontdiff linux-2.6/net/sched/sch_ingress.c qdisc-2.6/net/sched/sch_ingress.c
--- linux-2.6/net/sched/sch_ingress.c	2004-06-24 08:52:58.000000000 -0700
+++ qdisc-2.6/net/sched/sch_ingress.c	2004-07-27 09:17:28.000000000 -0700
@@ -40,7 +40,7 @@
 #endif
 
 
-#define PRIV(sch) ((struct ingress_qdisc_data *) (sch)->data)
+#define PRIV(sch) qdisc_priv(sch)
 
 
 /* Thanks to Doron Oz for this hack
diff -urN -X dontdiff linux-2.6/net/sched/sch_netem.c qdisc-2.6/net/sched/sch_netem.c
--- linux-2.6/net/sched/sch_netem.c	2004-07-23 09:36:18.000000000 -0700
+++ qdisc-2.6/net/sched/sch_netem.c	2004-07-27 09:17:28.000000000 -0700
@@ -603,7 +603,7 @@
  */
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
 	psched_time_t now;
 	long delay;
@@ -659,7 +659,7 @@
 /* Requeue packets but don't change time stamp */
 static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
 
 	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
@@ -670,7 +670,7 @@
 
 static unsigned int netem_drop(struct Qdisc* sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned int len;
 
 	if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
@@ -686,7 +686,7 @@
  */
 static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	psched_time_t now;
 
@@ -726,7 +726,7 @@
 
 static void netem_reset(struct Qdisc *sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
 	skb_queue_purge(&q->delayed);
@@ -754,7 +754,7 @@
 
 static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	struct tc_netem_qopt *qopt = RTA_DATA(opt);
 	struct Qdisc *child;
 	int ret;
@@ -791,7 +791,7 @@
 
 static int netem_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 
 	if (!opt)
 		return -EINVAL;
@@ -809,7 +809,7 @@
 
 static void netem_destroy(struct Qdisc *sch)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 
 	del_timer_sync(&q->timer);
 
@@ -819,7 +819,7 @@
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct tc_netem_qopt qopt;
 
@@ -841,7 +841,7 @@
 static int netem_dump_class(struct Qdisc *sch, unsigned long cl,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct netem_sched_data *q = (struct netem_sched_data*)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 
 	if (cl != 1) 	/* only one class */
 		return -ENOENT;
@@ -855,7 +855,7 @@
 static int netem_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 		     struct Qdisc **old)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 
 	if (new == NULL)
 		new = &noop_qdisc;
@@ -871,7 +871,7 @@
 
 static struct Qdisc *netem_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_sched_data *q = qdisc_priv(sch);
 	return q->qdisc;
 }
 
diff -urN -X dontdiff linux-2.6/net/sched/sch_prio.c qdisc-2.6/net/sched/sch_prio.c
--- linux-2.6/net/sched/sch_prio.c	2004-07-07 10:14:26.000000000 -0700
+++ qdisc-2.6/net/sched/sch_prio.c	2004-07-27 09:17:28.000000000 -0700
@@ -49,7 +49,7 @@
 
 struct Qdisc *prio_classify(struct sk_buff *skb, struct Qdisc *sch,int *r)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
 
@@ -151,7 +151,7 @@
 prio_dequeue(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
 	struct Qdisc *qdisc;
 
@@ -169,7 +169,7 @@
 
 static unsigned int prio_drop(struct Qdisc* sch)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
 	unsigned int len;
 	struct Qdisc *qdisc;
@@ -189,7 +189,7 @@
 prio_reset(struct Qdisc* sch)
 {
 	int prio;
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 
 	for (prio=0; prio<q->bands; prio++)
 		qdisc_reset(q->queues[prio]);
@@ -200,7 +200,7 @@
 prio_destroy(struct Qdisc* sch)
 {
 	int prio;
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tcf_proto *tp;
 
 	while ((tp = q->filter_list) != NULL) {
@@ -216,7 +216,7 @@
 
 static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt = RTA_DATA(opt);
 	int i;
 
@@ -261,7 +261,7 @@
 
 static int prio_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	int i;
 
 	for (i=0; i<TCQ_PRIO_BANDS; i++)
@@ -280,7 +280,7 @@
 
 static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct tc_prio_qopt opt;
 
@@ -297,7 +297,7 @@
 static int prio_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 		      struct Qdisc **old)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
 	if (band >= q->bands)
@@ -319,7 +319,7 @@
 static struct Qdisc *
 prio_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = arg - 1;
 
 	if (band >= q->bands)
@@ -330,7 +330,7 @@
 
 static unsigned long prio_get(struct Qdisc *sch, u32 classid)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned long band = TC_H_MIN(classid);
 
 	if (band - 1 >= q->bands)
@@ -352,7 +352,7 @@
 static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct rtattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 
 	if (cl - 1 > q->bands)
 		return -ENOENT;
@@ -361,7 +361,7 @@
 
 static int prio_delete(struct Qdisc *sch, unsigned long cl)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	if (cl - 1 > q->bands)
 		return -ENOENT;
 	return 0;
@@ -371,7 +371,7 @@
 static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *skb,
 			   struct tcmsg *tcm)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 
 	if (cl - 1 > q->bands)
 		return -ENOENT;
@@ -383,7 +383,7 @@
 
 static void prio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
 
 	if (arg->stop)
@@ -404,7 +404,7 @@
 
 static struct tcf_proto ** prio_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
-	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
+	struct prio_sched_data *q = qdisc_priv(sch);
 
 	if (cl)
 		return NULL;
diff -urN -X dontdiff linux-2.6/net/sched/sch_red.c qdisc-2.6/net/sched/sch_red.c
--- linux-2.6/net/sched/sch_red.c	2004-06-30 13:42:31.000000000 -0700
+++ qdisc-2.6/net/sched/sch_red.c	2004-07-27 09:17:28.000000000 -0700
@@ -180,7 +180,7 @@
 static int
 red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 
 	psched_time_t now;
 
@@ -303,7 +303,7 @@
 static int
 red_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 
 	PSCHED_SET_PASTPERFECT(q->qidlestart);
 
@@ -316,7 +316,7 @@
 red_dequeue(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
@@ -330,7 +330,7 @@
 static unsigned int red_drop(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 
 	skb = __skb_dequeue_tail(&sch->q);
 	if (skb) {
@@ -347,7 +347,7 @@
 
 static void red_reset(struct Qdisc* sch)
 {
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_purge(&sch->q);
 	sch->stats.backlog = 0;
@@ -358,7 +358,7 @@
 
 static int red_change(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 	struct rtattr *tb[TCA_RED_STAB];
 	struct tc_red_qopt *ctl;
 
@@ -407,7 +407,7 @@
 
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct red_sched_data *q = (struct red_sched_data *)sch->data;
+	struct red_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_red_qopt opt;
diff -urN -X dontdiff linux-2.6/net/sched/sch_sfq.c qdisc-2.6/net/sched/sch_sfq.c
--- linux-2.6/net/sched/sch_sfq.c	2004-02-23 08:31:40.000000000 -0800
+++ qdisc-2.6/net/sched/sch_sfq.c	2004-07-27 09:17:28.000000000 -0700
@@ -211,7 +211,7 @@
 
 static unsigned int sfq_drop(struct Qdisc *sch)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	sfq_index d = q->max_depth;
 	struct sk_buff *skb;
 	unsigned int len;
@@ -253,7 +253,7 @@
 static int
 sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
 	sfq_index x;
 
@@ -288,7 +288,7 @@
 static int
 sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
 	sfq_index x;
 
@@ -324,7 +324,7 @@
 static struct sk_buff *
 sfq_dequeue(struct Qdisc* sch)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	sfq_index a, old_a;
 
@@ -369,7 +369,7 @@
 static void sfq_perturbation(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc*)arg;
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 
 	q->perturbation = net_random()&0x1F;
 	q->perturb_timer.expires = jiffies + q->perturb_period;
@@ -382,7 +382,7 @@
 
 static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
@@ -408,7 +408,7 @@
 
 static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
 
 	init_timer(&q->perturb_timer);
@@ -440,13 +440,13 @@
 
 static void sfq_destroy(struct Qdisc *sch)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	del_timer(&q->perturb_timer);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct sfq_sched_data *q = (struct sfq_sched_data *)sch->data;
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct tc_sfq_qopt opt;
 
diff -urN -X dontdiff linux-2.6/net/sched/sch_tbf.c qdisc-2.6/net/sched/sch_tbf.c
--- linux-2.6/net/sched/sch_tbf.c	2004-06-30 13:42:31.000000000 -0700
+++ qdisc-2.6/net/sched/sch_tbf.c	2004-07-27 09:17:28.000000000 -0700
@@ -137,7 +137,7 @@
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
 	if (skb->len > q->max_size) {
@@ -163,7 +163,7 @@
 
 static int tbf_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
 	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
@@ -174,7 +174,7 @@
 
 static unsigned int tbf_drop(struct Qdisc* sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned int len;
 
 	if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
@@ -194,7 +194,7 @@
 
 static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
 	skb = q->qdisc->dequeue(q->qdisc);
@@ -261,7 +261,7 @@
 
 static void tbf_reset(struct Qdisc* sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
@@ -300,7 +300,7 @@
 static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
 {
 	int err = -EINVAL;
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct rtattr *tb[TCA_TBF_PTAB];
 	struct tc_tbf_qopt *qopt;
 	struct qdisc_rate_table *rtab = NULL;
@@ -366,7 +366,7 @@
 
 static int tbf_init(struct Qdisc* sch, struct rtattr *opt)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -383,7 +383,7 @@
 
 static void tbf_destroy(struct Qdisc *sch)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	del_timer(&q->wd_timer);
 
@@ -398,7 +398,7 @@
 
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_tbf_qopt opt;
@@ -427,7 +427,7 @@
 static int tbf_dump_class(struct Qdisc *sch, unsigned long cl,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data*)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	if (cl != 1) 	/* only one class */
 		return -ENOENT;
@@ -441,7 +441,7 @@
 static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 		     struct Qdisc **old)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	if (new == NULL)
 		new = &noop_qdisc;
@@ -457,7 +457,7 @@
 
 static struct Qdisc *tbf_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
+	struct tbf_sched_data *q = qdisc_priv(sch);
 	return q->qdisc;
 }
 
diff -urN -X dontdiff linux-2.6/net/sched/sch_teql.c qdisc-2.6/net/sched/sch_teql.c
--- linux-2.6/net/sched/sch_teql.c	2004-02-23 08:31:40.000000000 -0800
+++ qdisc-2.6/net/sched/sch_teql.c	2004-07-27 09:17:28.000000000 -0700
@@ -81,7 +81,7 @@
 	struct sk_buff_head q;
 };
 
-#define NEXT_SLAVE(q) (((struct teql_sched_data*)((q)->data))->next)
+#define NEXT_SLAVE(q) (((struct teql_sched_data*)qdisc_priv(q))->next)
 
 #define FMASK (IFF_BROADCAST|IFF_POINTOPOINT|IFF_BROADCAST)
 
@@ -91,7 +91,7 @@
 teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct net_device *dev = sch->dev;
-	struct teql_sched_data *q = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_tail(&q->q, skb);
 	if (q->q.qlen <= dev->tx_queue_len) {
@@ -109,7 +109,7 @@
 static int
 teql_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct teql_sched_data *q = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_head(&q->q, skb);
 	return 0;
@@ -118,7 +118,7 @@
 static struct sk_buff *
 teql_dequeue(struct Qdisc* sch)
 {
-	struct teql_sched_data *dat = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *dat = qdisc_priv(sch);
 	struct sk_buff *skb;
 
 	skb = __skb_dequeue(&dat->q);
@@ -143,7 +143,7 @@
 static void
 teql_reset(struct Qdisc* sch)
 {
-	struct teql_sched_data *dat = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *dat = qdisc_priv(sch);
 
 	skb_queue_purge(&dat->q);
 	sch->q.qlen = 0;
@@ -154,7 +154,7 @@
 teql_destroy(struct Qdisc* sch)
 {
 	struct Qdisc *q, *prev;
-	struct teql_sched_data *dat = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *dat = qdisc_priv(sch);
 	struct teql_master *master = dat->m;
 
 	if ((prev = master->slaves) != NULL) {
@@ -184,7 +184,7 @@
 {
 	struct net_device *dev = sch->dev;
 	struct teql_master *m = (struct teql_master*)sch->ops;
-	struct teql_sched_data *q = (struct teql_sched_data *)sch->data;
+	struct teql_sched_data *q = qdisc_priv(sch);
 
 	if (dev->hard_header_len > m->dev->hard_header_len)
 		return -EINVAL;
@@ -229,7 +229,7 @@
 static int
 __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
 {
-	struct teql_sched_data *q = (void*)dev->qdisc->data;
+	struct teql_sched_data *q = qdisc_priv(dev->qdisc);
 	struct neighbour *mn = skb->dst->neighbour;
 	struct neighbour *n = q->ncache;
 
