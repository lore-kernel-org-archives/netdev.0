From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/34] net: sched: store Qdisc pointer in struct block
Date: Thu, 12 Oct 2017 19:17:50 +0200
Message-ID: <20171012171823.1431-2-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:49173 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbdJLRS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so14955327wmd.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:26 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Prepare for removal of tp->q and store Qdisc pointer in the block
structure.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     | 4 ++--
 include/net/sch_generic.h | 1 +
 net/sched/cls_api.c       | 3 ++-
 net/sched/sch_atm.c       | 4 ++--
 net/sched/sch_cbq.c       | 2 +-
 net/sched/sch_drr.c       | 2 +-
 net/sched/sch_dsmark.c    | 2 +-
 net/sched/sch_fq_codel.c  | 2 +-
 net/sched/sch_hfsc.c      | 4 ++--
 net/sched/sch_htb.c       | 4 ++--
 net/sched/sch_ingress.c   | 6 +++---
 net/sched/sch_multiq.c    | 2 +-
 net/sched/sch_prio.c      | 2 +-
 net/sched/sch_qfq.c       | 2 +-
 net/sched/sch_sfb.c       | 2 +-
 net/sched/sch_sfq.c       | 2 +-
 16 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f526374..772dfa8 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -22,7 +22,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
-		  struct tcf_proto __rcu **p_filter_chain);
+		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
 void tcf_block_put(struct tcf_block *block);
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
@@ -30,7 +30,7 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 #else
 static inline
 int tcf_block_get(struct tcf_block **p_block,
-		  struct tcf_proto __rcu **p_filter_chain)
+		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
 {
 	return 0;
 }
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 684d8ed..df4032c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -270,6 +270,7 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	struct Qdisc *q;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2977b8a..f7d3f1f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -241,7 +241,7 @@ tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
 }
 
 int tcf_block_get(struct tcf_block **p_block,
-		  struct tcf_proto __rcu **p_filter_chain)
+		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
 {
 	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
 	struct tcf_chain *chain;
@@ -257,6 +257,7 @@ int tcf_block_get(struct tcf_block **p_block,
 		goto err_chain_create;
 	}
 	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	block->q = q;
 	*p_block = block;
 	return 0;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c5fcdf1..2dbd249 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -281,7 +281,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto err_out;
 	}
 
-	error = tcf_block_get(&flow->block, &flow->filter_list);
+	error = tcf_block_get(&flow->block, &flow->filter_list, sch);
 	if (error) {
 		kfree(flow);
 		goto err_out;
@@ -546,7 +546,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
 
-	err = tcf_block_get(&p->link.block, &p->link.filter_list);
+	err = tcf_block_get(&p->link.block, &p->link.filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index dcef97f..c3b92d6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1566,7 +1566,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (cl == NULL)
 		goto failure;
 
-	err = tcf_block_get(&cl->block, &cl->filter_list);
+	err = tcf_block_get(&cl->block, &cl->filter_list, sch);
 	if (err) {
 		kfree(cl);
 		return err;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 2d0e8d4..753dc7a 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -412,7 +412,7 @@ static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	struct drr_sched *q = qdisc_priv(sch);
 	int err;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 	err = qdisc_class_hash_init(&q->clhash);
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 2836c80..fb4fb71 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -344,7 +344,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		goto errout;
 
-	err = tcf_block_get(&p->block, &p->filter_list);
+	err = tcf_block_get(&p->block, &p->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index de3b57c..3c40ede 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -481,7 +481,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 3f88b75..a692184 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1033,7 +1033,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (cl == NULL)
 		return -ENOBUFS;
 
-	err = tcf_block_get(&cl->block, &cl->filter_list);
+	err = tcf_block_get(&cl->block, &cl->filter_list, sch);
 	if (err) {
 		kfree(cl);
 		return err;
@@ -1405,7 +1405,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 		return err;
 	q->eligible = RB_ROOT;
 
-	err = tcf_block_get(&q->root.block, &q->root.filter_list);
+	err = tcf_block_get(&q->root.block, &q->root.filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c6d7ae8..57be73c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1030,7 +1030,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
@@ -1393,7 +1393,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if (!cl)
 			goto failure;
 
-		err = tcf_block_get(&cl->block, &cl->filter_list);
+		err = tcf_block_get(&cl->block, &cl->filter_list, sch);
 		if (err) {
 			kfree(cl);
 			goto failure;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 44de4ee..9ccc1b8 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -59,7 +59,7 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
-	err = tcf_block_get(&q->block, &dev->ingress_cl_list);
+	err = tcf_block_get(&q->block, &dev->ingress_cl_list, sch);
 	if (err)
 		return err;
 
@@ -153,11 +153,11 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
-	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list);
+	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list, sch);
 	if (err)
 		return err;
 
-	err = tcf_block_get(&q->egress_block, &dev->egress_cl_list);
+	err = tcf_block_get(&q->egress_block, &dev->egress_cl_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index ff4fc3e..31e0a28 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -245,7 +245,7 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2dd6c68..95fad34 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -212,7 +212,7 @@ static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 6ddfd49..8694c7b 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1419,7 +1419,7 @@ static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	int i, j, err;
 	u32 max_cl_shift, maxbudg_shift, max_classes;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index cc39e17..487d375 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -553,7 +553,7 @@ static int sfb_init(struct Qdisc *sch, struct nlattr *opt)
 	struct sfb_sched_data *q = qdisc_priv(sch);
 	int err;
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 74ea863..123a53a 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -725,7 +725,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
 			       (unsigned long)sch);
 
-	err = tcf_block_get(&q->block, &q->filter_list);
+	err = tcf_block_get(&q->block, &q->filter_list, sch);
 	if (err)
 		return err;
 
-- 
2.9.5
