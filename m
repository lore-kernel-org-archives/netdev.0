From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] dsmark: get rid of wrappers
Date: Sun, 20 Jan 2008 13:10:08 -0800
Message-ID: <20080120131008.2039a35d@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38682 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbYATVad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 16:30:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove extraneous macro wrappers for printk and qdisc_priv.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_dsmark.c	2008-01-20 08:36:10.000000000 -0800
+++ b/net/sched/sch_dsmark.c	2008-01-20 08:47:26.000000000 -0800
@@ -15,23 +15,6 @@
 #include <net/inet_ecn.h>
 #include <asm/byteorder.h>
 
-
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
-
-#define PRIV(sch) ((struct dsmark_qdisc_data *) qdisc_priv(sch))
-
-
 /*
  * classid	class		marking
  * -------	-----		-------
@@ -81,9 +64,9 @@ static inline int dsmark_valid_index(str
 static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 			struct Qdisc *new, struct Qdisc **old)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	DPRINTK("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",
+	pr_debug("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",
 		sch, p, new, old);
 
 	if (new == NULL) {
@@ -104,13 +87,14 @@ static int dsmark_graft(struct Qdisc *sc
 
 static struct Qdisc *dsmark_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	return PRIV(sch)->q;
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+	return p->q;
 }
 
 static unsigned long dsmark_get(struct Qdisc *sch, u32 classid)
 {
-	DPRINTK("dsmark_get(sch %p,[qdisc %p],classid %x)\n",
-		sch, PRIV(sch), classid);
+	pr_debug("dsmark_get(sch %p,[qdisc %p],classid %x)\n",
+		sch, qdisc_priv(sch), classid);
 
 	return TC_H_MIN(classid) + 1;
 }
@@ -128,13 +112,13 @@ static void dsmark_put(struct Qdisc *sch
 static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 			 struct rtattr **tca, unsigned long *arg)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_DSMARK_MAX];
 	int err = -EINVAL;
 	u8 mask = 0;
 
-	DPRINTK("dsmark_change(sch %p,[qdisc %p],classid %x,parent %x),"
+	pr_debug("dsmark_change(sch %p,[qdisc %p],classid %x,parent %x),"
 		"arg 0x%lx\n", sch, p, classid, parent, *arg);
 
 	if (!dsmark_valid_index(p, *arg)) {
@@ -162,7 +146,7 @@ rtattr_failure:
 
 static int dsmark_delete(struct Qdisc *sch, unsigned long arg)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
 	if (!dsmark_valid_index(p, arg))
 		return -EINVAL;
@@ -175,10 +159,10 @@ static int dsmark_delete(struct Qdisc *s
 
 static void dsmark_walk(struct Qdisc *sch,struct qdisc_walker *walker)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int i;
 
-	DPRINTK("dsmark_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
+	pr_debug("dsmark_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
 
 	if (walker->stop)
 		return;
@@ -197,19 +181,20 @@ ignore:
 	}
 }
 
-static struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,unsigned long cl)
+static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,unsigned long cl)
 {
-	return &PRIV(sch)->filter_list;
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+	return &p->filter_list;
 }
 
 /* --------------------------- Qdisc operations ---------------------------- */
 
 static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
 
-	D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	pr_debug("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 
 	if (p->set_tc_index) {
 		/* FIXME: Safe with non-linear skbs? --RR */
@@ -234,7 +219,7 @@ static int dsmark_enqueue(struct sk_buff
 		struct tcf_result res;
 		int result = tc_classify(skb, p->filter_list, &res);
 
-		D2PRINTK("result %d class 0x%04x\n", result, res.classid);
+		pr_debug("result %d class 0x%04x\n", result, res.classid);
 
 		switch (result) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -272,11 +257,11 @@ static int dsmark_enqueue(struct sk_buff
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct sk_buff *skb;
 	u32 index;
 
-	D2PRINTK("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
 
 	skb = p->q->ops->dequeue(p->q);
 	if (skb == NULL)
@@ -285,7 +270,7 @@ static struct sk_buff *dsmark_dequeue(st
 	sch->q.qlen--;
 
 	index = skb->tc_index & (p->indices - 1);
-	D2PRINTK("index %d->%d\n", skb->tc_index, index);
+	pr_debug("index %d->%d\n", skb->tc_index, index);
 
 	switch (skb->protocol) {
 		case __constant_htons(ETH_P_IP):
@@ -314,10 +299,10 @@ static struct sk_buff *dsmark_dequeue(st
 
 static int dsmark_requeue(struct sk_buff *skb,struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
 
-	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	pr_debug("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 
 	err = p->q->ops->requeue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
@@ -333,10 +318,10 @@ static int dsmark_requeue(struct sk_buff
 
 static unsigned int dsmark_drop(struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	unsigned int len;
 
-	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
 
 	if (p->q->ops->drop == NULL)
 		return 0;
@@ -350,14 +335,14 @@ static unsigned int dsmark_drop(struct Q
 
 static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct rtattr *tb[TCA_DSMARK_MAX];
 	int err = -EINVAL;
 	u32 default_index = NO_DEFAULT_INDEX;
 	u16 indices;
 	u8 *mask;
 
-	DPRINTK("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
+	pr_debug("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 
 	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt) < 0)
 		goto errout;
@@ -389,7 +374,7 @@ static int dsmark_init(struct Qdisc *sch
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
-	DPRINTK("dsmark_init: qdisc %p\n", p->q);
+	pr_debug("dsmark_init: qdisc %p\n", p->q);
 
 	err = 0;
 errout:
@@ -399,18 +384,18 @@ rtattr_failure:
 
 static void dsmark_reset(struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
 	qdisc_reset(p->q);
 	sch->q.qlen = 0;
 }
 
 static void dsmark_destroy(struct Qdisc *sch)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	DPRINTK("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
 
 	tcf_destroy_chain(p->filter_list);
 	qdisc_destroy(p->q);
@@ -420,10 +405,10 @@ static void dsmark_destroy(struct Qdisc 
 static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 			     struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct rtattr *opts = NULL;
 
-	DPRINTK("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n", sch, p, cl);
+	pr_debug("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n", sch, p, cl);
 
 	if (!dsmark_valid_index(p, cl))
 		return -EINVAL;
@@ -443,7 +428,7 @@ rtattr_failure:
 
 static int dsmark_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct rtattr *opts = NULL;
 
 	opts = RTA_NEST(skb, TCA_OPTIONS);
