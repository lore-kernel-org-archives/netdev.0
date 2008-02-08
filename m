From: Yashpal Dutta <yashpal.dutta@freescale.com>
Subject: [NET_SCHED] Traffic Control subsystem Notifier for Kernel Modules
Date: Fri,  8 Feb 2008 12:49:42 +0530
Message-ID: <1202455182-13379-1-git-send-email-yashpal.dutta@freescale.com>
Cc: Yashpal Dutta <yashpal.dutta@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:46285 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831AbYBHIM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 03:12:58 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id m188A0Xv020448
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 01:12:50 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds raw notifiers in Traffic Control subsystem for communicating
Queue Disciplines and Classifiers added by user via TC application.
Interested kernel modules will have to register to the TC subsystem
to be able to get new QDisc notifys asynchronously.

Signed-off-by: Yashpal Dutta <yashpal.dutta@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 include/net/sch_generic.h |   11 ++++++-
 include/net/sch_notify.h  |   66 +++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_api.c       |   42 +++++++++++++++++++++++++++
 net/sched/cls_fw.c        |   16 ++++++++++
 net/sched/sch_api.c       |   34 ++++++++++++++++++++++
 net/sched/sch_cbq.c       |   68 +++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_prio.c      |   22 ++++++++++++++-
 net/sched/sch_red.c       |   29 ++++++++++++++++++-
 net/sched/sch_sfq.c       |   15 ++++++++++
 net/sched/sch_tbf.c       |   29 ++++++++++++++++++-
 10 files changed, 328 insertions(+), 4 deletions(-)
 create mode 100644 include/net/sch_notify.h

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ab502ec..7e31279 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -9,6 +9,7 @@
 #include <linux/pkt_cls.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
+#include <net/sch_notify.h>
 
 struct Qdisc_ops;
 struct qdisc_walker;
@@ -79,6 +80,9 @@ struct Qdisc_class_ops
 	/* rtnetlink specific */
 	int			(*dump)(struct Qdisc *, unsigned long,
 					struct sk_buff *skb, struct tcmsg*);
+	/* CLS Notifier */
+	void 			(*notify_cls)(struct Qdisc *, unsigned long,
+					struct tc_cls_notify_s *);
 	int			(*dump_stats)(struct Qdisc *, unsigned long,
 					struct gnet_dump *);
 };
@@ -101,6 +105,9 @@ struct Qdisc_ops
 	int			(*change)(struct Qdisc *, struct nlattr *arg);
 
 	int			(*dump)(struct Qdisc *, struct sk_buff *);
+	/* QDISC Notifier */
+	void 			(*notify_qdisc)(struct Qdisc *,
+					struct qdisc_notify_s *);
 	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
 
 	struct module		*owner;
@@ -134,7 +141,9 @@ struct tcf_proto_ops
 	/* rtnetlink specific */
 	int			(*dump)(struct tcf_proto*, unsigned long,
 					struct sk_buff *skb, struct tcmsg*);
-
+	/*  Classifier Notifier */
+	void 			(*notify_tcf)(struct tcf_proto *,
+					unsigned long, struct qdisc_notify_s *);
 	struct module		*owner;
 };
 
diff --git a/include/net/sch_notify.h b/include/net/sch_notify.h
new file mode 100644
index 0000000..cffdf0c
--- /dev/null
+++ b/include/net/sch_notify.h
@@ -0,0 +1,66 @@
+#ifndef __SCH_NOTIFY_H__
+#define __SCH_NOTIFY_H__
+
+#include <linux/types.h>
+#include <linux/rtnetlink.h>
+
+/*CBQ Notification structure */
+struct tc_cbq_notify_s {
+	struct tc_cbq_lssopt lssopt;
+	struct tc_cbq_wrropt wrropt;
+	struct tc_cbq_ovl ovlopt;
+#ifdef CONFIG_NET_CLS_ACT
+	struct tc_cbq_police policeopt;
+#endif
+	struct tc_cbq_fopt fopt;
+};
+
+/* Classifier Notification Structure */
+struct tc_cls_notify_s {
+	uint32_t type;
+	struct tcmsg tcm;
+	union {
+		struct tc_cbq_notify_s tc_cbq_notifier;
+	} u;
+};
+
+/* Traffic Actions notify Structure */
+struct tc_fw_notify_s {
+	uint32_t classid;
+	uint32_t mask;
+	uint32_t handle;
+	struct tc_action *action;
+};
+
+/* TC Main Notification Structure */
+struct qdisc_notify_s {
+	uint32_t type;
+	uint32_t parent;
+	uint32_t handle;
+	uint32_t ifindex;
+	union {
+		struct tc_fw_notify_s tc_fw_notifier;
+		struct tc_cbq_notify_s tc_cbq_notifier;
+		struct tc_tbf_qopt tbf_qdisc_opt;
+		struct tc_red_qopt red_qdisc_opt;
+		struct tc_sfq_qopt sfq_qdisc_opt;
+		struct tc_prio_qopt prio_qdisc_opt; /* Prio Qdisc Options */
+	} u;
+};
+
+/*Notifier Register(unregister) function for Qdisc*/
+extern uint32_t register_qdisc_notifier(struct notifier_block *nb);
+extern uint32_t unregister_qdisc_notifier(struct notifier_block *nb);
+
+/* Notifier Register(unregister) functions for TC Filters */
+extern uint32_t register_tcf_notifier(struct notifier_block *nb);
+extern uint32_t unregister_tcf_notifier(struct notifier_block *nb);
+
+/* Traffic Control Notify Event Types */
+#define	TC_EVENT_PRIO 0x00000001
+#define	TC_EVENT_CBQ  0x00000002
+#define	TC_EVENT_RED  0x00000003
+#define	TC_EVENT_SFQ  0x00000004
+#define	TC_EVENT_TBF  0x00000005
+#define	TC_EVENT_FW   0x00000006
+#endif
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0fbedca..a2dc1c1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -29,6 +29,7 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
+#include <net/sch_notify.h>
 
 /* The list of all installed classifier types */
 
@@ -37,6 +38,9 @@ static struct tcf_proto_ops *tcf_proto_base __read_mostly;
 /* Protects list of registered TC modules. It is pure SMP lock. */
 static DEFINE_RWLOCK(cls_mod_lock);
 
+/* Traffic Classifier Notifier Chain Head */
+static RAW_NOTIFIER_HEAD(tcf_notifier);
+
 /* Find classifier type by string name */
 
 static struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
@@ -57,6 +61,19 @@ static struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 	return t;
 }
 
+/* Register(Unregister) Traffic Classifier notifier */
+uint32_t register_tcf_notifier(struct notifier_block *nb)
+{
+	return raw_notifier_chain_register(&tcf_notifier, nb);
+}
+EXPORT_SYMBOL(register_tcf_notifier);
+
+uint32_t unregister_tcf_notifier(struct notifier_block *nb)
+{
+	return raw_notifier_chain_unregister(&tcf_notifier, nb);
+}
+EXPORT_SYMBOL(unregister_tcf_notifier);
+
 /* Register(unregister) new classifier type */
 
 int register_tcf_proto_ops(struct tcf_proto_ops *ops)
@@ -114,6 +131,29 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	return first;
 }
 
+/* Traffic  Filter notify function */
+static void tfilter_notifier(struct tcf_proto *tp, unsigned long fh, int event)
+{
+	struct qdisc_notify_s qdisc_notify;
+
+	switch (event) {
+	case RTM_NEWTFILTER:
+	case RTM_DELTFILTER:
+	case RTM_GETTFILTER:
+		if (tp->ops->notify_tcf) {
+			tp->ops->notify_tcf(tp, fh, &qdisc_notify);
+			qdisc_notify.parent = tp->classid;
+			qdisc_notify.handle = fh;
+			qdisc_notify.ifindex = tp->q->dev->ifindex;
+			raw_notifier_call_chain(&tcf_notifier, event,
+						&qdisc_notify);
+		} else {
+		printk(KERN_DEBUG "%s : TF Notification for %s Not supported\n"
+			, __FUNCTION__, tp->ops->kind);
+		}
+	}
+}
+
 /* Add/change/delete/get a filter node */
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
@@ -316,6 +356,8 @@ replay:
 errout:
 	if (cl)
 		cops->put(q, cl);
+	if (err == 0)
+		tfilter_notifier(tp, fh, n->nlmsg_type);
 	if (err == -EAGAIN)
 		/* Replay the request. */
 		goto replay;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index b0f90e5..39c775a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -27,6 +27,7 @@
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <net/sch_notify.h>
 
 #define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
 
@@ -327,6 +328,20 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
+/* FW  Mark/Action Notifier */
+static void fw_notifier(struct tcf_proto *tp, unsigned long fh,
+				struct qdisc_notify_s *qdisc_notify)
+{
+	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_filter *f = (struct fw_filter *)fh;
+
+	qdisc_notify->type = TC_EVENT_FW;
+	qdisc_notify->u.tc_fw_notifier.classid = f->res.classid;
+	qdisc_notify->u.tc_fw_notifier.mask = head->mask;
+	qdisc_notify->u.tc_fw_notifier.handle = f->id;
+	qdisc_notify->u.tc_fw_notifier.action = f->exts.action;
+}
+
 static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
@@ -382,6 +397,7 @@ static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.delete		=	fw_delete,
 	.walk		=	fw_walk,
 	.dump		=	fw_dump,
+	.notify_tcf	=	fw_notifier,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7e3c048..674301d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -32,12 +32,15 @@
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/sch_notify.h>
 
 static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n, u32 clid,
 			struct Qdisc *old, struct Qdisc *new);
 static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 			 struct Qdisc *q, unsigned long cl, int event);
 
+/* QDisc Notifier Head */
+static RAW_NOTIFIER_HEAD(qdisc_notifier);
 /*
 
    Short review.
@@ -818,6 +821,19 @@ graft:
 	return 0;
 }
 
+/* Registers(Unregister) QDisc Notifier */
+uint32_t register_qdisc_notifier(struct notifier_block *nb)
+{
+	return raw_notifier_chain_register(&qdisc_notifier, nb);
+}
+EXPORT_SYMBOL(register_qdisc_notifier);
+
+uint32_t unregister_qdisc_notifier(struct notifier_block *nb)
+{
+	return raw_notifier_chain_unregister(&qdisc_notifier, nb);
+}
+EXPORT_SYMBOL(unregister_qdisc_notifier);
+
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 			 u32 pid, u32 seq, u16 flags, int event)
 {
@@ -825,6 +841,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct gnet_dump d;
+	struct qdisc_notify_s qdisc_notify;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
@@ -838,6 +855,16 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
+	/* Send QDisc Notification */
+	if (q->ops->notify_qdisc) {
+		q->ops->notify_qdisc(q, &qdisc_notify);
+		qdisc_notify.parent = clid;
+		qdisc_notify.handle = q->handle;
+		qdisc_notify.ifindex = q->dev->ifindex;
+		raw_notifier_call_chain(&qdisc_notifier, event,
+					&qdisc_notifier);
+	}
+
 	q->qstats.qlen = q->q.qlen;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
@@ -1073,6 +1100,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct gnet_dump d;
 	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
+	struct tc_cls_notify_s tc_cls_notify;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
@@ -1084,6 +1112,12 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
 	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
 		goto nla_put_failure;
+	/* Notify Classifier */
+	if (cl_ops->notify_cls) {
+		cl_ops->notify_cls(q, cl, &tc_cls_notify);
+		memcpy(&tc_cls_notify.tcm, tcm, sizeof(struct tcmsg));
+		raw_notifier_call_chain(&qdisc_notifier, event, &tc_cls_notify);
+	}
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 			TCA_XSTATS, q->stats_lock, &d) < 0)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 09969c1..4d9855e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -18,6 +18,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/sch_notify.h>
 
 
 /*	Class-Based Queueing (CBQ) algorithm.
@@ -1567,6 +1568,50 @@ static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 	return 0;
 }
 
+/* CBQ QDISC Notification fill */
+static void cbq_notify_qdisc(struct Qdisc *sch,
+			struct qdisc_notify_s *qdisc_notify)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct cbq_class *cl = &q->link;
+	struct tc_cbq_notify_s *cbq_notify = &qdisc_notify->u.tc_cbq_notifier;
+
+	qdisc_notify->type  = TC_EVENT_CBQ;
+	cbq_notify->lssopt.flags = 0;
+	if (cl->borrow == NULL)
+		cbq_notify->lssopt.flags |= TCF_CBQ_LSS_BOUNDED;
+	if (cl->share == NULL)
+		cbq_notify->lssopt.flags |= TCF_CBQ_LSS_ISOLATED;
+	cbq_notify->lssopt.ewma_log = cl->ewma_log;
+	cbq_notify->lssopt.level = cl->level;
+	cbq_notify->lssopt.avpkt = cl->avpkt;
+	cbq_notify->lssopt.maxidle = cl->maxidle;
+	cbq_notify->lssopt.minidle = (u32)(-cl->minidle);
+	cbq_notify->lssopt.offtime = cl->offtime;
+	cbq_notify->lssopt.change = ~0;
+	cbq_notify->wrropt.flags = 0;
+	cbq_notify->wrropt.allot = cl->allot;
+	cbq_notify->wrropt.priority = cl->priority+1;
+	cbq_notify->wrropt.cpriority = cl->cpriority+1;
+	cbq_notify->wrropt.weight = cl->weight;
+	cbq_notify->ovlopt.strategy = cl->ovl_strategy;
+	cbq_notify->ovlopt.priority2 = cl->priority2+1;
+	cbq_notify->ovlopt.pad = 0;
+	cbq_notify->ovlopt.penalty = cl->penalty;
+#ifdef CONFIG_NET_CLS_ACT
+	if (cl->police) {
+		cbq_notify->policeopt.police = cl->police;
+		cbq_notify->policeopt.__res1 = 0;
+		cbq_notify->policeopt.__res2 = 0;
+	}
+#endif
+	if (cl->split || cl->defmap) {
+		cbq_notify->fopt.split = cl->split ? cl->split->classid : 0;
+		cbq_notify->fopt.defmap = cl->defmap;
+		cbq_notify->fopt.defchange = ~0;
+	}
+}
+
 static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -1594,6 +1639,27 @@ cbq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	return gnet_stats_copy_app(d, &q->link.xstats, sizeof(q->link.xstats));
 }
 
+static void cbq_notify_cls(struct Qdisc *sch, unsigned long arg,
+				struct tc_cls_notify_s *cls_notify)
+{
+	struct cbq_class *cl = (struct cbq_class *)arg;
+	struct tc_cbq_notify_s *cbq_notify = &cls_notify->u.tc_cbq_notifier;
+
+	cls_notify->type  = TC_EVENT_CBQ;
+	cbq_notify->lssopt.flags = 0;
+	if (cl->borrow == NULL)
+		cbq_notify->lssopt.flags |= TCF_CBQ_LSS_BOUNDED;
+	if (cl->share == NULL)
+		cbq_notify->lssopt.flags |= TCF_CBQ_LSS_ISOLATED;
+	cbq_notify->lssopt.ewma_log = cl->ewma_log;
+	cbq_notify->lssopt.level = cl->level;
+	cbq_notify->lssopt.avpkt = cl->avpkt;
+	cbq_notify->lssopt.maxidle = cl->maxidle;
+	cbq_notify->lssopt.minidle = (u32)(-cl->minidle);
+	cbq_notify->lssopt.offtime = cl->offtime;
+	cbq_notify->lssopt.change = ~0;
+}
+
 static int
 cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
@@ -2045,6 +2111,7 @@ static const struct Qdisc_class_ops cbq_class_ops = {
 	.bind_tcf	=	cbq_bind_filter,
 	.unbind_tcf	=	cbq_unbind_filter,
 	.dump		=	cbq_dump_class,
+	.notify_cls	=	cbq_notify_cls,
 	.dump_stats	=	cbq_dump_class_stats,
 };
 
@@ -2062,6 +2129,7 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.destroy	=	cbq_destroy,
 	.change		=	NULL,
 	.dump		=	cbq_dump,
+	.notify_qdisc	=	cbq_notify_qdisc,
 	.dump_stats	=	cbq_dump_stats,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4aa2b45..4dadf0e 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -19,7 +19,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-
+#include <net/sch_notify.h>
 
 struct prio_sched_data
 {
@@ -318,6 +318,18 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
+/* Prio Qdisc Notifier dump */
+static void prio_notify_qdisc(struct Qdisc *sch,
+			struct qdisc_notify_s *qdisc_notify)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+
+	qdisc_notify->type  = TC_EVENT_PRIO;
+	qdisc_notify->u.prio_qdisc_opt.bands = q->bands;
+	memcpy(&qdisc_notify->u.prio_qdisc_opt.priomap, q->prio2band,
+		TC_PRIO_MAX+1);
+}
+
 static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -417,6 +429,12 @@ static int prio_delete(struct Qdisc *sch, unsigned long cl)
 	return 0;
 }
 
+/* Prio Classifier Notifier */
+static void prio_notify_cls(struct Qdisc *sch, unsigned long cl,
+				struct tc_cls_notify_s *cls_notify)
+{
+	cls_notify->type  = TC_EVENT_PRIO;
+}
 
 static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *skb,
 			   struct tcmsg *tcm)
@@ -488,6 +506,7 @@ static const struct Qdisc_class_ops prio_class_ops = {
 	.unbind_tcf	=	prio_put,
 	.dump		=	prio_dump_class,
 	.dump_stats	=	prio_dump_class_stats,
+	.notify_cls	=	prio_notify_cls,
 };
 
 static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
@@ -504,6 +523,7 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.destroy	=	prio_destroy,
 	.change		=	prio_tune,
 	.dump		=	prio_dump,
+	.notify_qdisc	=	prio_notify_qdisc,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 3dcd493..4542f88 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -21,7 +21,7 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
-
+#include <net/sch_notify.h>
 
 /*	Parameters, settable by user:
 	-----------------------------
@@ -297,6 +297,31 @@ static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
 
+/* RED QDisc Notifier Dump */
+static void red_notify_qdisc(struct Qdisc *sch,
+		struct qdisc_notify_s *qdisc_notify)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+
+	qdisc_notify->type = TC_EVENT_RED;
+	qdisc_notify->u.red_qdisc_opt.limit = q->limit;
+	qdisc_notify->u.red_qdisc_opt.flags = q->flags;
+	qdisc_notify->u.red_qdisc_opt.qth_min =
+				q->parms.qth_min >> q->parms.Wlog;
+	qdisc_notify->u.red_qdisc_opt.qth_max =
+				q->parms.qth_max >> q->parms.Wlog;
+	qdisc_notify->u.red_qdisc_opt.Wlog = q->parms.Wlog;
+	qdisc_notify->u.red_qdisc_opt.Plog = q->parms.Plog;
+	qdisc_notify->u.red_qdisc_opt.Scell_log = q->parms.Scell_log;
+}
+
+/* RED Classifier Notifier dump */
+static void red_notify_cls(struct Qdisc *sch, unsigned long cl,
+				struct tc_cls_notify_s *cls_notify)
+{
+	cls_notify->type  = TC_EVENT_RED;
+}
+
 static int red_dump_class(struct Qdisc *sch, unsigned long cl,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
@@ -379,6 +404,7 @@ static const struct Qdisc_class_ops red_class_ops = {
 	.walk		=	red_walk,
 	.tcf_chain	=	red_find_tcf,
 	.dump		=	red_dump_class,
+	.notify_cls	=	red_notify_cls,
 };
 
 static struct Qdisc_ops red_qdisc_ops __read_mostly = {
@@ -394,6 +420,7 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.destroy	=	red_destroy,
 	.change		=	red_change,
 	.dump		=	red_dump,
+	.notify_qdisc	=	red_notify_qdisc,
 	.dump_stats	=	red_dump_stats,
 	.owner		=	THIS_MODULE,
 };
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a20e2ef..b7c4df7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -23,6 +23,7 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/sch_notify.h>
 
 
 /*	Stochastic Fairness Queuing algorithm.
@@ -524,6 +525,19 @@ static void sfq_destroy(struct Qdisc *sch)
 	del_timer(&q->perturb_timer);
 }
 
+static void sfq_notify_qdisc(struct Qdisc *sch,
+		struct qdisc_notify_s *qdisc_notify)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	qdisc_notify->type  = TC_EVENT_SFQ;
+	qdisc_notify->u.sfq_qdisc_opt.quantum = q->quantum;
+	qdisc_notify->u.sfq_qdisc_opt.perturb_period = q->perturb_period/HZ;
+	qdisc_notify->u.sfq_qdisc_opt.limit = q->limit;
+	qdisc_notify->u.sfq_qdisc_opt.divisor = SFQ_HASH_DIVISOR;
+	qdisc_notify->u.sfq_qdisc_opt.flows = q->limit;
+}
+
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -630,6 +644,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.destroy	=	sfq_destroy,
 	.change		=	NULL,
 	.dump		=	sfq_dump,
+	.notify_qdisc	=	sfq_notify_qdisc,
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 0b7d78f..0d1d2d6 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -20,7 +20,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-
+#include <net/sch_notify.h>
 
 /*	Simple Token Bucket Filter.
 	=======================================
@@ -377,6 +377,31 @@ static void tbf_destroy(struct Qdisc *sch)
 	qdisc_destroy(q->qdisc);
 }
 
+static void tbf_notify_cls(struct Qdisc *sch, unsigned long cl,
+				struct tc_cls_notify_s *cls_notify)
+{
+	cls_notify->type  = TC_EVENT_TBF;
+}
+
+static void tbf_notify_qdisc(struct Qdisc *sch,
+			struct qdisc_notify_s *qdisc_notify)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+
+	qdisc_notify->type  = TC_EVENT_TBF;
+	qdisc_notify->u.tbf_qdisc_opt.limit = q->limit;
+	qdisc_notify->u.tbf_qdisc_opt.rate = q->R_tab->rate;
+
+	if (q->P_tab)
+		qdisc_notify->u.tbf_qdisc_opt.peakrate = q->P_tab->rate;
+	else
+		memset(&qdisc_notify->u.tbf_qdisc_opt.peakrate, 0,
+			sizeof(qdisc_notify->u.tbf_qdisc_opt.peakrate));
+
+	qdisc_notify->u.tbf_qdisc_opt.mtu = q->mtu;
+	qdisc_notify->u.tbf_qdisc_opt.buffer = q->buffer;
+}
+
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -490,6 +515,7 @@ static const struct Qdisc_class_ops tbf_class_ops =
 	.walk		=	tbf_walk,
 	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
+	.notify_cls	=	tbf_notify_cls,
 };
 
 static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
@@ -506,6 +532,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.destroy	=	tbf_destroy,
 	.change		=	tbf_change,
 	.dump		=	tbf_dump,
+	.notify_qdisc	=	tbf_notify_qdisc,
 	.owner		=	THIS_MODULE,
 };
 
-- 
1.5.3.3

