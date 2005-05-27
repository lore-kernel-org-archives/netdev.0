From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/7] [PKT_SCHED] Logic simplifications and codingstyle/whitespace cleanups
Date: Fri, 27 May 2005 16:56:11 +0200
Message-ID: <20050527145611.GY15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit fde09d4989b6c7b5183ffb3ec2076ff53dd6fa78
tree b032d0d440d93aac252e656bd41df32ff5461e3a
parent 36b5fe1b0094ab6d6ba2589076bec1975d5769ed
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 16:25:41 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 16:25:41 +0200

 net/sched/sch_dsmark.c |  174 ++++++++++++++++++++++++-------------------------
 1 files changed, 88 insertions(+), 86 deletions(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- ff95a30a27c52aef9561f2ed04e9950d0afcae6a/net/sched/sch_dsmark.c  (mode:100644)
+++ b032d0d440d93aac252e656bd41df32ff5461e3a/net/sched/sch_dsmark.c  (mode:100644)
@@ -31,7 +31,7 @@
 #endif
 
 
-#define PRIV(sch) qdisc_priv(sch)
+#define PRIV(sch) ((struct dsmark_qdisc_data *) qdisc_priv(sch))
 
 
 /*
@@ -55,10 +55,10 @@
 struct dsmark_qdisc_data {
 	struct Qdisc		*q;
 	struct tcf_proto	*filter_list;
-	__u8			*mask;	/* "owns" the array */
-	__u8			*value;
-	__u16			indices;
-	__u32			default_index;	/* index range is 0...0xffff */
+	u8			*mask;	/* "owns" the array */
+	u8			*value;
+	u16			indices;
+	u32			default_index;	/* index range is 0...0xffff */
 	int			set_tc_index;
 };
 
@@ -80,14 +80,13 @@
 
 /* ------------------------- Class/flow operations ------------------------- */
 
-
-static int dsmark_graft(struct Qdisc *sch,unsigned long arg,
-    struct Qdisc *new,struct Qdisc **old)
+static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
+			struct Qdisc *new, struct Qdisc **old)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 
-	DPRINTK("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",sch,p,new,
-	    old);
+	DPRINTK("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",
+		sch, p, new, old);
 
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
@@ -96,44 +95,37 @@
 	}
 
 	sch_tree_lock(sch);
-	*old = xchg(&p->q,new);
-	if (*old)
-		qdisc_reset(*old);
+	*old = xchg(&p->q, new);
+	qdisc_reset(*old);
 	sch->q.qlen = 0;
-	sch_tree_unlock(sch); /* @@@ move up ? */
+	sch_tree_unlock(sch);
+
         return 0;
 }
 
-
 static struct Qdisc *dsmark_leaf(struct Qdisc *sch, unsigned long arg)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
-
-	return p->q;
+	return PRIV(sch)->q;
 }
 
-
-static unsigned long dsmark_get(struct Qdisc *sch,u32 classid)
+static unsigned long dsmark_get(struct Qdisc *sch, u32 classid)
 {
-	struct dsmark_qdisc_data *p __attribute__((unused)) = PRIV(sch);
+	DPRINTK("dsmark_get(sch %p,[qdisc %p],classid %x)\n",
+		sch, PRIV(sch), classid);
 
-	DPRINTK("dsmark_get(sch %p,[qdisc %p],classid %x)\n",sch,p,classid);
-	return TC_H_MIN(classid)+1;
+	return TC_H_MIN(classid) + 1;
 }
 
-
 static unsigned long dsmark_bind_filter(struct Qdisc *sch,
-    unsigned long parent, u32 classid)
+					unsigned long parent, u32 classid)
 {
-	return dsmark_get(sch,classid);
+	return dsmark_get(sch, classid);
 }
 
-
 static void dsmark_put(struct Qdisc *sch, unsigned long cl)
 {
 }
 
-
 static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 			 struct rtattr **tca, unsigned long *arg)
 {
@@ -169,26 +161,29 @@
 	return err;
 }
 
-static int dsmark_delete(struct Qdisc *sch,unsigned long arg)
+static int dsmark_delete(struct Qdisc *sch, unsigned long arg)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 
-	if (!arg || arg > p->indices)
+	if (!dsmark_valid_index(p, arg))
 		return -EINVAL;
+	
 	p->mask[arg-1] = 0xff;
 	p->value[arg-1] = 0;
+
 	return 0;
 }
 
-
 static void dsmark_walk(struct Qdisc *sch,struct qdisc_walker *walker)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	int i;
 
-	DPRINTK("dsmark_walk(sch %p,[qdisc %p],walker %p)\n",sch,p,walker);
+	DPRINTK("dsmark_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
+
 	if (walker->stop)
 		return;
+
 	for (i = 0; i < p->indices; i++) {
 		if (p->mask[i] == 0xff && !p->value[i])
 			goto ignore;
@@ -203,26 +198,20 @@
         }
 }
 
-
 static struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,unsigned long cl)
 {
-	struct dsmark_qdisc_data *p = PRIV(sch);
-
-	return &p->filter_list;
+	return &PRIV(sch)->filter_list;
 }
 
-
 /* --------------------------- Qdisc operations ---------------------------- */
 
-
 static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
-	struct tcf_result res;
-	int result;
-	int ret = NET_XMIT_POLICED;
+	int err;
+
+	D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 
-	D2PRINTK("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
 	if (p->set_tc_index) {
 		/* FIXME: Safe with non-linear skbs? --RR */
 		switch (skb->protocol) {
@@ -239,17 +228,21 @@
 				break;
 		};
 	}
-	result = TC_POLICE_OK; /* be nice to gcc */
-	if (TC_H_MAJ(skb->priority) == sch->handle) {
+
+	if (TC_H_MAJ(skb->priority) == sch->handle)
 		skb->tc_index = TC_H_MIN(skb->priority);
-	} else {
-		result = tc_classify(skb,p->filter_list,&res);
-		D2PRINTK("result %d class 0x%04x\n",result,res.classid);
+	else {
+		struct tcf_result res;
+		int result = tc_classify(skb, p->filter_list, &res);
+
+		D2PRINTK("result %d class 0x%04x\n", result, res.classid);
+
 		switch (result) {
 #ifdef CONFIG_NET_CLS_POLICE
 			case TC_POLICE_SHOT:
 				kfree_skb(skb);
-				break;
+				sch->qstats.drops++;
+				return NET_XMIT_POLICED;
 #if 0
 			case TC_POLICE_RECLASSIFY:
 				/* FIXME: what to do here ??? */
@@ -266,43 +259,45 @@
 				break;
 		};
 	}
-	if (
-#ifdef CONFIG_NET_CLS_POLICE
-	    result == TC_POLICE_SHOT ||
-#endif
 
-	    ((ret = p->q->enqueue(skb,p->q)) != 0)) {
+	err = p->q->enqueue(skb,p->q);
+	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
-		return ret;
+		return err;
 	}
+
 	sch->bstats.bytes += skb->len;
 	sch->bstats.packets++;
 	sch->q.qlen++;
-	return ret;
-}
 
+	return NET_XMIT_SUCCESS;
+}
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	struct sk_buff *skb;
-	int index;
+	u32 index;
+
+	D2PRINTK("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
 
-	D2PRINTK("dsmark_dequeue(sch %p,[qdisc %p])\n",sch,p);
 	skb = p->q->ops->dequeue(p->q);
-	if (!skb)
+	if (skb == NULL)
 		return NULL;
+
 	sch->q.qlen--;
-	index = skb->tc_index & (p->indices-1);
-	D2PRINTK("index %d->%d\n",skb->tc_index,index);
+
+	index = skb->tc_index & (p->indices - 1);
+	D2PRINTK("index %d->%d\n", skb->tc_index, index);
+
 	switch (skb->protocol) {
 		case __constant_htons(ETH_P_IP):
-			ipv4_change_dsfield(skb->nh.iph,
-			    p->mask[index],p->value[index]);
+			ipv4_change_dsfield(skb->nh.iph, p->mask[index],
+					    p->value[index]);
 			break;
 		case __constant_htons(ETH_P_IPV6):
-			ipv6_change_dsfield(skb->nh.ipv6h,
-			    p->mask[index],p->value[index]);
+			ipv6_change_dsfield(skb->nh.ipv6h, p->mask[index],
+					    p->value[index]);
 			break;
 		default:
 			/*
@@ -316,41 +311,46 @@
 				       htons(skb->protocol));
 			break;
 	};
+
 	return skb;
 }
 
-
 static int dsmark_requeue(struct sk_buff *skb,struct Qdisc *sch)
 {
-	int ret;
 	struct dsmark_qdisc_data *p = PRIV(sch);
+	int err;
 
-	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
-        if ((ret = p->q->ops->requeue(skb, p->q)) == 0) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-		return 0;
+	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+
+	err = p->q->ops->requeue(skb, p->q);
+	if (err != NET_XMIT_SUCCESS) {
+		sch->qstats.drops++;
+		return err;
 	}
-	sch->qstats.drops++;
-	return ret;
-}
 
+	sch->q.qlen++;
+	sch->qstats.requeues++;
+
+	return NET_XMIT_SUCCESS;
+}
 
 static unsigned int dsmark_drop(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	unsigned int len;
 	
-	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n",sch,p);
-	if (!p->q->ops->drop)
-		return 0;
-	if (!(len = p->q->ops->drop(p->q)))
+	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
+
+	if (p->q->ops->drop == NULL)
 		return 0;
-	sch->q.qlen--;
+
+	len = p->q->ops->drop(p->q);
+	if (len)
+		sch->q.qlen--;
+
 	return len;
 }
 
-
 static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
@@ -400,33 +400,32 @@
 	return err;
 }
 
-
 static void dsmark_reset(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 
-	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n",sch,p);
+	DPRINTK("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
 	qdisc_reset(p->q);
 	sch->q.qlen = 0;
 }
 
-
 static void dsmark_destroy(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
 	struct tcf_proto *tp;
 
-	DPRINTK("dsmark_destroy(sch %p,[qdisc %p])\n",sch,p);
+	DPRINTK("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
+
 	while (p->filter_list) {
 		tp = p->filter_list;
 		p->filter_list = tp->next;
 		tcf_destroy(tp);
 	}
+
 	qdisc_destroy(p->q);
 	kfree(p->mask);
 }
 
-
 static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 			     struct sk_buff *skb, struct tcmsg *tcm)
 {
@@ -505,10 +504,13 @@
 {
 	return register_qdisc(&dsmark_qdisc_ops);
 }
+
 static void __exit dsmark_module_exit(void) 
 {
 	unregister_qdisc(&dsmark_qdisc_ops);
 }
+
 module_init(dsmark_module_init)
 module_exit(dsmark_module_exit)
+
 MODULE_LICENSE("GPL");
