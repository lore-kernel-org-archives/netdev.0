From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] net: sched: remove cops->tcf_cl_offload
Date: Wed,  9 Aug 2017 14:30:35 +0200
Message-ID: <20170809123035.7663-6-jiri@resnulli.us>
References: <20170809123035.7663-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, oss-drivers@netronome.com,
        ganeshgr@chelsio.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33607 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752775AbdHIMar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so4396700wrd.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:46 -0700 (PDT)
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

cops->tcf_cl_offload is no longer needed, as the drivers check what they
can and cannot offload using the classid identify helpers. So remove this.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     | 14 +++-----------
 include/net/sch_generic.h |  1 -
 net/sched/cls_bpf.c       |  4 ++--
 net/sched/cls_flower.c    |  8 ++++----
 net/sched/cls_matchall.c  |  4 ++--
 net/sched/cls_u32.c       |  8 ++++----
 net/sched/sch_ingress.c   | 12 ------------
 7 files changed, 15 insertions(+), 36 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bd9dd79..e80edd8 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -457,19 +457,12 @@ struct tc_cls_u32_offload {
 	};
 };
 
-static inline bool tc_can_offload(const struct net_device *dev,
-				  const struct tcf_proto *tp)
+static inline bool tc_can_offload(const struct net_device *dev)
 {
-	const struct Qdisc *sch = tp->q;
-	const struct Qdisc_class_ops *cops = sch->ops->cl_ops;
-
 	if (!(dev->features & NETIF_F_HW_TC))
 		return false;
 	if (!dev->netdev_ops->ndo_setup_tc)
 		return false;
-	if (cops && cops->tcf_cl_offload)
-		return cops->tcf_cl_offload(tp->classid);
-
 	return true;
 }
 
@@ -478,12 +471,11 @@ static inline bool tc_skip_hw(u32 flags)
 	return (flags & TCA_CLS_FLAGS_SKIP_HW) ? true : false;
 }
 
-static inline bool tc_should_offload(const struct net_device *dev,
-				     const struct tcf_proto *tp, u32 flags)
+static inline bool tc_should_offload(const struct net_device *dev, u32 flags)
 {
 	if (tc_skip_hw(flags))
 		return false;
-	return tc_can_offload(dev, tp);
+	return tc_can_offload(dev);
 }
 
 static inline bool tc_skip_sw(u32 flags)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e79f5ad..5865db9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -156,7 +156,6 @@ struct Qdisc_class_ops {
 
 	/* Filter manipulation */
 	struct tcf_block *	(*tcf_block)(struct Qdisc *, unsigned long);
-	bool			(*tcf_cl_offload)(u32 classid);
 	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
 					u32 classid);
 	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index db17b68..6f2dffe 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -178,7 +178,7 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 		(oldprog && tc_skip_sw(oldprog->gen_flags));
 
 	if (oldprog && oldprog->offloaded) {
-		if (tc_should_offload(dev, tp, prog->gen_flags)) {
+		if (tc_should_offload(dev, prog->gen_flags)) {
 			cmd = TC_CLSBPF_REPLACE;
 		} else if (!tc_skip_sw(prog->gen_flags)) {
 			obj = oldprog;
@@ -187,7 +187,7 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			return -EINVAL;
 		}
 	} else {
-		if (!tc_should_offload(dev, tp, prog->gen_flags))
+		if (!tc_should_offload(dev, prog->gen_flags))
 			return skip_sw ? -EINVAL : 0;
 		cmd = TC_CLSBPF_ADD;
 	}
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index d2551a0..052e902 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -227,7 +227,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = f->hw_dev;
 
-	if (!tc_can_offload(dev, tp))
+	if (!tc_can_offload(dev))
 		return;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
@@ -246,9 +246,9 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	struct tc_cls_flower_offload cls_flower = {};
 	int err;
 
-	if (!tc_can_offload(dev, tp)) {
+	if (!tc_can_offload(dev)) {
 		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
-		    (f->hw_dev && !tc_can_offload(f->hw_dev, tp))) {
+		    (f->hw_dev && !tc_can_offload(f->hw_dev))) {
 			f->hw_dev = dev;
 			return tc_skip_sw(f->flags) ? -EINVAL : 0;
 		}
@@ -281,7 +281,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = f->hw_dev;
 
-	if (!tc_can_offload(dev, tp))
+	if (!tc_can_offload(dev))
 		return;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index d44e26f..d4dc387 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -92,7 +92,7 @@ static void mall_destroy(struct tcf_proto *tp)
 	if (!head)
 		return;
 
-	if (tc_should_offload(dev, tp, head->flags))
+	if (tc_should_offload(dev, head->flags))
 		mall_destroy_hw_filter(tp, head, (unsigned long) head);
 
 	call_rcu(&head->rcu, mall_destroy_rcu);
@@ -172,7 +172,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto err_set_parms;
 
-	if (tc_should_offload(dev, tp, flags)) {
+	if (tc_should_offload(dev, flags)) {
 		err = mall_replace_hw_filter(tp, new, (unsigned long) new);
 		if (err) {
 			if (tc_skip_sw(flags))
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 5a3f781..af22742 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -433,7 +433,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload cls_u32 = {};
 
-	if (!tc_should_offload(dev, tp, 0))
+	if (!tc_should_offload(dev, 0))
 		return;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
@@ -450,7 +450,7 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	struct tc_cls_u32_offload cls_u32 = {};
 	int err;
 
-	if (!tc_should_offload(dev, tp, flags))
+	if (!tc_should_offload(dev, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
@@ -471,7 +471,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload cls_u32 = {};
 
-	if (!tc_should_offload(dev, tp, 0))
+	if (!tc_should_offload(dev, 0))
 		return;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
@@ -490,7 +490,7 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	struct tc_cls_u32_offload cls_u32 = {};
 	int err;
 
-	if (!tc_should_offload(dev, tp, flags))
+	if (!tc_should_offload(dev, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
 	tc_cls_common_offload_init(&cls_u32.common, tp);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index d8a9beb..a15c543 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -32,11 +32,6 @@ static unsigned long ingress_get(struct Qdisc *sch, u32 classid)
 	return TC_H_MIN(classid) + 1;
 }
 
-static bool ingress_cl_offload(u32 classid)
-{
-	return true;
-}
-
 static unsigned long ingress_bind_filter(struct Qdisc *sch,
 					 unsigned long parent, u32 classid)
 {
@@ -103,7 +98,6 @@ static const struct Qdisc_class_ops ingress_class_ops = {
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
 	.tcf_block	=	ingress_tcf_block,
-	.tcf_cl_offload	=	ingress_cl_offload,
 	.bind_tcf	=	ingress_bind_filter,
 	.unbind_tcf	=	ingress_put,
 };
@@ -134,11 +128,6 @@ static unsigned long clsact_get(struct Qdisc *sch, u32 classid)
 	}
 }
 
-static bool clsact_cl_offload(u32 classid)
-{
-	return TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_INGRESS);
-}
-
 static unsigned long clsact_bind_filter(struct Qdisc *sch,
 					unsigned long parent, u32 classid)
 {
@@ -198,7 +187,6 @@ static const struct Qdisc_class_ops clsact_class_ops = {
 	.put		=	ingress_put,
 	.walk		=	ingress_walk,
 	.tcf_block	=	clsact_tcf_block,
-	.tcf_cl_offload	=	clsact_cl_offload,
 	.bind_tcf	=	clsact_bind_filter,
 	.unbind_tcf	=	ingress_put,
 };
-- 
2.9.3
