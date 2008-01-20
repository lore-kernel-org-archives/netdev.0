From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sch_atm: style cleanup
Date: Sun, 20 Jan 2008 14:03:42 -0800
Message-ID: <20080120140342.13139be7@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39249 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbYATWGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 17:06:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ATM scheduler clean house:
  * get rid of printk and qdisc_priv() wrapper
  * split some assignment in if() statements
  * whitespace and line breaks.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_atm.c	2008-01-20 13:51:58.000000000 -0800
+++ b/net/sched/sch_atm.c	2008-01-20 13:59:16.000000000 -0800
@@ -16,18 +16,6 @@
 
 extern struct socket *sockfd_lookup(int fd, int *err);	/* @@@ fix this */
 
-#if 0 /* control */
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-#if 0 /* data */
-#define D2PRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define D2PRINTK(format,args...)
-#endif
-
 /*
  * The ATM queuing discipline provides a framework for invoking classifiers
  * (aka "filters"), which in turn select classes of this queuing discipline.
@@ -49,7 +37,6 @@ extern struct socket *sockfd_lookup(int 
  *  - should lock the flow while there is data in the queue (?)
  */
 
-#define PRIV(sch) qdisc_priv(sch)
 #define VCC2FLOW(vcc) ((struct atm_flow_data *) ((vcc)->user_back))
 
 struct atm_flow_data {
@@ -57,7 +44,7 @@ struct atm_flow_data {
 	struct tcf_proto	*filter_list;
 	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
 	void			(*old_pop)(struct atm_vcc *vcc,
-					   struct sk_buff * skb); /* chaining */
+					   struct sk_buff *skb); /* chaining */
 	struct atm_qdisc_data	*parent;	/* parent qdisc */
 	struct socket		*sock;		/* for closing */
 	u32			classid;	/* x:y type ID */
@@ -84,17 +71,17 @@ static int find_flow(struct atm_qdisc_da
 {
 	struct atm_flow_data *walk;
 
-	DPRINTK("find_flow(qdisc %p,flow %p)\n", qdisc, flow);
+	pr_debug("find_flow(qdisc %p,flow %p)\n", qdisc, flow);
 	for (walk = qdisc->flows; walk; walk = walk->next)
 		if (walk == flow)
 			return 1;
-	DPRINTK("find_flow: not found\n");
+	pr_debug("find_flow: not found\n");
 	return 0;
 }
 
 static inline struct atm_flow_data *lookup_flow(struct Qdisc *sch, u32 classid)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
 	for (flow = p->flows; flow; flow = flow->next)
@@ -106,10 +93,10 @@ static inline struct atm_flow_data *look
 static int atm_tc_graft(struct Qdisc *sch, unsigned long arg,
 			struct Qdisc *new, struct Qdisc **old)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	DPRINTK("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",
+	pr_debug("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",
 		sch, p, flow, new, old);
 	if (!find_flow(p, flow))
 		return -EINVAL;
@@ -125,20 +112,20 @@ static struct Qdisc *atm_tc_leaf(struct 
 {
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 
-	DPRINTK("atm_tc_leaf(sch %p,flow %p)\n", sch, flow);
+	pr_debug("atm_tc_leaf(sch %p,flow %p)\n", sch, flow);
 	return flow ? flow->q : NULL;
 }
 
 static unsigned long atm_tc_get(struct Qdisc *sch, u32 classid)
 {
-	struct atm_qdisc_data *p __maybe_unused = PRIV(sch);
+	struct atm_qdisc_data *p __maybe_unused = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_get(sch %p,[qdisc %p],classid %x)\n", sch, p, classid);
+	pr_debug("atm_tc_get(sch %p,[qdisc %p],classid %x)\n", sch, p, classid);
 	flow = lookup_flow(sch, classid);
 	if (flow)
 		flow->ref++;
-	DPRINTK("atm_tc_get: flow %p\n", flow);
+	pr_debug("atm_tc_get: flow %p\n", flow);
 	return (unsigned long)flow;
 }
 
@@ -155,14 +142,14 @@ static unsigned long atm_tc_bind_filter(
  */
 static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 	struct atm_flow_data **prev;
 
-	DPRINTK("atm_tc_put(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
+	pr_debug("atm_tc_put(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (--flow->ref)
 		return;
-	DPRINTK("atm_tc_put: destroying\n");
+	pr_debug("atm_tc_put: destroying\n");
 	for (prev = &p->flows; *prev; prev = &(*prev)->next)
 		if (*prev == flow)
 			break;
@@ -171,11 +158,11 @@ static void atm_tc_put(struct Qdisc *sch
 		return;
 	}
 	*prev = flow->next;
-	DPRINTK("atm_tc_put: qdisc %p\n", flow->q);
+	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
 	tcf_destroy_chain(flow->filter_list);
 	if (flow->sock) {
-		DPRINTK("atm_tc_put: f_count %d\n",
+		pr_debug("atm_tc_put: f_count %d\n",
 			file_count(flow->sock->file));
 		flow->vcc->pop = flow->old_pop;
 		sockfd_put(flow->sock);
@@ -194,7 +181,7 @@ static void sch_atm_pop(struct atm_vcc *
 {
 	struct atm_qdisc_data *p = VCC2FLOW(vcc)->parent;
 
-	D2PRINTK("sch_atm_pop(vcc %p,skb %p,[qdisc %p])\n", vcc, skb, p);
+	pr_debug("sch_atm_pop(vcc %p,skb %p,[qdisc %p])\n", vcc, skb, p);
 	VCC2FLOW(vcc)->old_pop(vcc, skb);
 	tasklet_schedule(&p->task);
 }
@@ -211,7 +198,7 @@ static const u8 llc_oui_ip[] = {
 static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			 struct rtattr **tca, unsigned long *arg)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)*arg;
 	struct atm_flow_data *excess = NULL;
 	struct rtattr *opt = tca[TCA_OPTIONS - 1];
@@ -220,7 +207,7 @@ static int atm_tc_change(struct Qdisc *s
 	int fd, error, hdr_len;
 	void *hdr;
 
-	DPRINTK("atm_tc_change(sch %p,[qdisc %p],classid %x,parent %x,"
+	pr_debug("atm_tc_change(sch %p,[qdisc %p],classid %x,parent %x,"
 		"flow %p,opt %p)\n", sch, p, classid, parent, flow, opt);
 	/*
 	 * The concept of parents doesn't apply for this qdisc.
@@ -241,7 +228,7 @@ static int atm_tc_change(struct Qdisc *s
 	if (!tb[TCA_ATM_FD - 1] || RTA_PAYLOAD(tb[TCA_ATM_FD - 1]) < sizeof(fd))
 		return -EINVAL;
 	fd = *(int *)RTA_DATA(tb[TCA_ATM_FD - 1]);
-	DPRINTK("atm_tc_change: fd %d\n", fd);
+	pr_debug("atm_tc_change: fd %d\n", fd);
 	if (tb[TCA_ATM_HDR - 1]) {
 		hdr_len = RTA_PAYLOAD(tb[TCA_ATM_HDR - 1]);
 		hdr = RTA_DATA(tb[TCA_ATM_HDR - 1]);
@@ -259,11 +246,12 @@ static int atm_tc_change(struct Qdisc *s
 		if (!excess)
 			return -ENOENT;
 	}
-	DPRINTK("atm_tc_change: type %d, payload %d, hdr_len %d\n",
-		opt->rta_type, RTA_PAYLOAD(opt), hdr_len);
-	if (!(sock = sockfd_lookup(fd, &error)))
+	pr_debug("atm_tc_change: type %d, payload %lu, hdr_len %d\n",
+		 opt->rta_type, RTA_PAYLOAD(opt), hdr_len);
+	sock = sockfd_lookup(fd, &error);
+	if (!sock)
 		return error;	/* f_count++ */
-	DPRINTK("atm_tc_change: f_count %d\n", file_count(sock->file));
+	pr_debug("atm_tc_change: f_count %d\n", file_count(sock->file));
 	if (sock->ops->family != PF_ATMSVC && sock->ops->family != PF_ATMPVC) {
 		error = -EPROTOTYPE;
 		goto err_out;
@@ -272,7 +260,7 @@ static int atm_tc_change(struct Qdisc *s
 	   on vcc->send */
 	if (classid) {
 		if (TC_H_MAJ(classid ^ sch->handle)) {
-			DPRINTK("atm_tc_change: classid mismatch\n");
+			pr_debug("atm_tc_change: classid mismatch\n");
 			error = -EINVAL;
 			goto err_out;
 		}
@@ -286,26 +274,28 @@ static int atm_tc_change(struct Qdisc *s
 
 		for (i = 1; i < 0x8000; i++) {
 			classid = TC_H_MAKE(sch->handle, 0x8000 | i);
-			if (!(cl = atm_tc_get(sch, classid)))
+			cl = atm_tc_get(sch, classid);
+			if (!cl)
 				break;
 			atm_tc_put(sch, cl);
 		}
 	}
-	DPRINTK("atm_tc_change: new id %x\n", classid);
+	pr_debug("atm_tc_change: new id %x\n", classid);
 	flow = kzalloc(sizeof(struct atm_flow_data) + hdr_len, GFP_KERNEL);
-	DPRINTK("atm_tc_change: flow %p\n", flow);
+	pr_debug("atm_tc_change: flow %p\n", flow);
 	if (!flow) {
 		error = -ENOBUFS;
 		goto err_out;
 	}
 	flow->filter_list = NULL;
-	if (!(flow->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid)))
+	flow->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+	if (!flow->q)
 		flow->q = &noop_qdisc;
-	DPRINTK("atm_tc_change: qdisc %p\n", flow->q);
+	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
 	flow->sock = sock;
 	flow->vcc = ATM_SD(sock);	/* speedup */
 	flow->vcc->user_back = flow;
-	DPRINTK("atm_tc_change: vcc %p\n", flow->vcc);
+	pr_debug("atm_tc_change: vcc %p\n", flow->vcc);
 	flow->old_pop = flow->vcc->pop;
 	flow->parent = p;
 	flow->vcc->pop = sch_atm_pop;
@@ -330,11 +320,11 @@ err_out:
 
 static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	DPRINTK("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
-	if (!find_flow(PRIV(sch), flow))
+	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
+	if (!find_flow(qdisc_priv(sch), flow))
 		return -EINVAL;
 	if (flow->filter_list || flow == &p->link)
 		return -EBUSY;
@@ -354,10 +344,10 @@ static int atm_tc_delete(struct Qdisc *s
 
 static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
+	pr_debug("atm_tc_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
 	if (walker->stop)
 		return;
 	for (flow = p->flows; flow; flow = flow->next) {
@@ -372,10 +362,10 @@ static void atm_tc_walk(struct Qdisc *sc
 
 static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 
-	DPRINTK("atm_tc_find_tcf(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
+	pr_debug("atm_tc_find_tcf(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	return flow ? &flow->filter_list : &p->link.filter_list;
 }
 
@@ -383,13 +373,13 @@ static struct tcf_proto **atm_tc_find_tc
 
 static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = NULL;	/* @@@ */
 	struct tcf_result res;
 	int result;
 	int ret = NET_XMIT_POLICED;
 
-	D2PRINTK("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	pr_debug("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	result = TC_POLICE_OK;	/* be nice to gcc */
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
 	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority)))
@@ -430,7 +420,8 @@ static int atm_tc_enqueue(struct sk_buff
 #endif
 	}
 
-	if ((ret = flow->q->enqueue(skb, flow->q)) != 0) {
+	ret = flow->q->enqueue(skb, flow->q);
+	if (ret != 0) {
 drop: __maybe_unused
 		sch->qstats.drops++;
 		if (flow)
@@ -468,11 +459,11 @@ drop: __maybe_unused
 static void sch_atm_dequeue(unsigned long data)
 {
 	struct Qdisc *sch = (struct Qdisc *)data;
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 	struct sk_buff *skb;
 
-	D2PRINTK("sch_atm_dequeue(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("sch_atm_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	for (flow = p->link.next; flow; flow = flow->next)
 		/*
 		 * If traffic is properly shaped, this won't generate nasty
@@ -483,7 +474,7 @@ static void sch_atm_dequeue(unsigned lon
 				(void)flow->q->ops->requeue(skb, flow->q);
 				break;
 			}
-			D2PRINTK("atm_tc_dequeue: sending on class %p\n", flow);
+			pr_debug("atm_tc_dequeue: sending on class %p\n", flow);
 			/* remove any LL header somebody else has attached */
 			skb_pull(skb, skb_network_offset(skb));
 			if (skb_headroom(skb) < flow->hdr_len) {
@@ -495,7 +486,7 @@ static void sch_atm_dequeue(unsigned lon
 					continue;
 				skb = new;
 			}
-			D2PRINTK("sch_atm_dequeue: ip %p, data %p\n",
+			pr_debug("sch_atm_dequeue: ip %p, data %p\n",
 				 skb_network_header(skb), skb->data);
 			ATM_SKB(skb)->vcc = flow->vcc;
 			memcpy(skb_push(skb, flow->hdr_len), flow->hdr,
@@ -509,10 +500,10 @@ static void sch_atm_dequeue(unsigned lon
 
 static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	D2PRINTK("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
 	skb = p->link.q->dequeue(p->link.q);
 	if (skb)
@@ -522,10 +513,10 @@ static struct sk_buff *atm_tc_dequeue(st
 
 static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	int ret;
 
-	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	pr_debug("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	ret = p->link.q->ops->requeue(skb, p->link.q);
 	if (!ret) {
 		sch->q.qlen++;
@@ -539,11 +530,11 @@ static int atm_tc_requeue(struct sk_buff
 
 static unsigned int atm_tc_drop(struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 	unsigned int len;
 
-	DPRINTK("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
 	for (flow = p->flows; flow; flow = flow->next)
 		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
 			return len;
@@ -552,14 +543,14 @@ static unsigned int atm_tc_drop(struct Q
 
 static int atm_tc_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 
-	DPRINTK("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
+	pr_debug("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->flows = &p->link;
-	if (!(p->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-					    sch->handle)))
+	p->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, sch->handle);
+	if (!p->link.q)
 		p->link.q = &noop_qdisc;
-	DPRINTK("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
+	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
 	p->link.filter_list = NULL;
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
@@ -572,10 +563,10 @@ static int atm_tc_init(struct Qdisc *sch
 
 static void atm_tc_reset(struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_reset(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("atm_tc_reset(sch %p,[qdisc %p])\n", sch, p);
 	for (flow = p->flows; flow; flow = flow->next)
 		qdisc_reset(flow->q);
 	sch->q.qlen = 0;
@@ -583,10 +574,10 @@ static void atm_tc_reset(struct Qdisc *s
 
 static void atm_tc_destroy(struct Qdisc *sch)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
-	DPRINTK("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
 	/* races ? */
 	while ((flow = p->flows)) {
 		tcf_destroy_chain(flow->filter_list);
@@ -608,12 +599,12 @@ static void atm_tc_destroy(struct Qdisc 
 static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 			     struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct rtattr *rta;
 
-	DPRINTK("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
+	pr_debug("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
 		sch, p, flow, skb, tcm);
 	if (!find_flow(p, flow))
 		return -EINVAL;
