From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] net: sched: fix tc_should_offload for specific clsact classes
Date: Mon,  6 Jun 2016 22:50:39 +0200
Message-ID: <6eb47dcc252d843d7338ce2c9b98f667b45c8450.1465245985.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56541 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbcFFUuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 16:50:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When offloading classifiers such as u32 or flower to hardware, and the
qdisc is clsact (TC_H_CLSACT), then we need to differentiate its classes,
since not all of them handle ingress, therefore we must leave those in
software path. Add a .tcf_cl_offload() callback, so we can generically
handle them, tested on ixgbe.

Fixes: 10cbc6843446 ("net/sched: cls_flower: Hardware offloaded filters statistics support")
Fixes: 5b33f48842fa ("net/flower: Introduce hardware offload support")
Fixes: a1b7c5fd7fe9 ("net: sched: add cls_u32 offload hooks for netdevs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/pkt_cls.h     | 10 +++++++---
 include/net/sch_generic.h |  1 +
 net/sched/cls_flower.c    |  6 +++---
 net/sched/cls_u32.c       |  8 ++++----
 net/sched/sch_ingress.c   | 12 ++++++++++++
 5 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 0f7efa8..3722dda 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -392,16 +392,20 @@ struct tc_cls_u32_offload {
 	};
 };
 
-static inline bool tc_should_offload(struct net_device *dev, u32 flags)
+static inline bool tc_should_offload(const struct net_device *dev,
+				     const struct tcf_proto *tp, u32 flags)
 {
+	const struct Qdisc *sch = tp->q;
+	const struct Qdisc_class_ops *cops = sch->ops->cl_ops;
+
 	if (!(dev->features & NETIF_F_HW_TC))
 		return false;
-
 	if (flags & TCA_CLS_FLAGS_SKIP_HW)
 		return false;
-
 	if (!dev->netdev_ops->ndo_setup_tc)
 		return false;
+	if (cops && cops->tcf_cl_offload)
+		return cops->tcf_cl_offload(tp->classid);
 
 	return true;
 }
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1fd76c..6a01fc5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -168,6 +168,7 @@ struct Qdisc_class_ops {
 
 	/* Filter manipulation */
 	struct tcf_proto __rcu ** (*tcf_chain)(struct Qdisc *, unsigned long);
+	bool			(*tcf_cl_offload)(u32 classid);
 	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
 					u32 classid);
 	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 730aaca..b3b7978 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -171,7 +171,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
 
-	if (!tc_should_offload(dev, 0))
+	if (!tc_should_offload(dev, tp, 0))
 		return;
 
 	offload.command = TC_CLSFLOWER_DESTROY;
@@ -194,7 +194,7 @@ static void fl_hw_replace_filter(struct tcf_proto *tp,
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
 
-	if (!tc_should_offload(dev, flags))
+	if (!tc_should_offload(dev, tp, flags))
 		return;
 
 	offload.command = TC_CLSFLOWER_REPLACE;
@@ -216,7 +216,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
 
-	if (!tc_should_offload(dev, 0))
+	if (!tc_should_offload(dev, tp, 0))
 		return;
 
 	offload.command = TC_CLSFLOWER_STATS;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 079b43b..a63272c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -440,7 +440,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, 0)) {
+	if (tc_should_offload(dev, tp, 0)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
@@ -460,7 +460,7 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp,
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, flags)) {
+	if (tc_should_offload(dev, tp, flags)) {
 		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -484,7 +484,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, 0)) {
+	if (tc_should_offload(dev, tp, 0)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -507,7 +507,7 @@ static int u32_replace_hw_knode(struct tcf_proto *tp,
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (tc_should_offload(dev, flags)) {
+	if (tc_should_offload(dev, tp, flags)) {
 		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 		offload.cls_u32->knode.handle = n->handle;
 		offload.cls_u32->knode.fshift = n->fshift;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 10adbc6..8fe6999 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -27,6 +27,11 @@ static unsigned long ingress_get(struct Qdisc *sch, u32 classid)
 	return TC_H_MIN(classid) + 1;
 }
 
+static bool ingress_cl_offload(u32 classid)
+{
+	return true;
+}
+
 static unsigned long ingress_bind_filter(struct Qdisc *sch,
 					 unsigned long parent, u32 classid)
 {
@@ -86,6 +91,7 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
 	.tcf_chain	=	ingress_find_tcf,
+	.tcf_cl_offload	=	ingress_cl_offload,
 	.bind_tcf	=	ingress_bind_filter,
 	.unbind_tcf	=	ingress_put,
 };
@@ -110,6 +116,11 @@ static unsigned long clsact_get(struct Qdisc *sch, u32 classid)
 	}
 }
 
+static bool clsact_cl_offload(u32 classid)
+{
+	return TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_INGRESS);
+}
+
 static unsigned long clsact_bind_filter(struct Qdisc *sch,
 					unsigned long parent, u32 classid)
 {
@@ -158,6 +169,7 @@ static const struct Qdisc_class_ops clsact_class_ops = {
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
 	.tcf_chain	=	clsact_find_tcf,
+	.tcf_cl_offload	=	clsact_cl_offload,
 	.bind_tcf	=	clsact_bind_filter,
 	.unbind_tcf	=	ingress_put,
 };
-- 
1.9.3
