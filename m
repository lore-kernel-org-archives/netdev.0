From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 1/2] net: sched: introduce chain_head_change callback
Date: Tue, 31 Oct 2017 16:12:21 +0100
Message-ID: <20171031151222.5021-2-jiri@resnulli.us>
References: <20171031151222.5021-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:51415 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751952AbdJaPMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:12:25 -0400
Received: by mail-wm0-f66.google.com with SMTP id b9so23961555wmh.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 08:12:24 -0700 (PDT)
In-Reply-To: <20171031151222.5021-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add a callback that is to be called whenever head of the chain changes.
Also provide a callback for the default case when the caller gets a
block using non-extended getter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     | 14 ++++++------
 include/net/sch_generic.h |  5 ++++-
 net/sched/cls_api.c       | 54 ++++++++++++++++++++++++++++-------------------
 net/sched/sch_ingress.c   | 36 +++++++++++++++++--------------
 4 files changed, 62 insertions(+), 47 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bf73e16..0f99cbc 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -26,6 +26,8 @@ enum tcf_block_binder_type {
 
 struct tcf_block_ext_info {
 	enum tcf_block_binder_type binder_type;
+	tcf_chain_head_change_t *chain_head_change;
+	void *chain_head_change_priv;
 };
 
 struct tcf_block_cb;
@@ -37,12 +39,10 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
-int tcf_block_get_ext(struct tcf_block **p_block,
-		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+int tcf_block_get_ext(struct tcf_block **p_block, struct Qdisc *q,
 		      struct tcf_block_ext_info *ei);
 void tcf_block_put(struct tcf_block *block);
-void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+void tcf_block_put_ext(struct tcf_block *block, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei);
 
 static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
@@ -82,8 +82,7 @@ int tcf_block_get(struct tcf_block **p_block,
 }
 
 static inline
-int tcf_block_get_ext(struct tcf_block **p_block,
-		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+int tcf_block_get_ext(struct tcf_block **p_block, struct Qdisc *q,
 		      struct tcf_block_ext_info *ei)
 {
 	return 0;
@@ -94,8 +93,7 @@ static inline void tcf_block_put(struct tcf_block *block)
 }
 
 static inline
-void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+void tcf_block_put_ext(struct tcf_block *block, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei)
 {
 }
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 07c179d..16d0f8f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -260,9 +260,12 @@ struct qdisc_skb_cb {
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
+typedef void tcf_chain_head_change_t(struct tcf_proto *tp_head, void *priv);
+
 struct tcf_chain {
 	struct tcf_proto __rcu *filter_chain;
-	struct tcf_proto __rcu **p_filter_chain;
+	tcf_chain_head_change_t *chain_head_change;
+	void *chain_head_change_priv;
 	struct list_head list;
 	struct tcf_block *block;
 	u32 index; /* chain index */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d9d54b3..dfb015a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -195,12 +195,19 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 	return chain;
 }
 
+static void tcf_chain_head_change(struct tcf_chain *chain,
+				  struct tcf_proto *tp_head)
+{
+	if (chain->chain_head_change)
+		chain->chain_head_change(tp_head,
+					 chain->chain_head_change_priv);
+}
+
 static void tcf_chain_flush(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
-	if (chain->p_filter_chain)
-		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
+	tcf_chain_head_change(chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_chain_put(chain);
@@ -242,13 +249,6 @@ void tcf_chain_put(struct tcf_chain *chain)
 }
 EXPORT_SYMBOL(tcf_chain_put);
 
-static void
-tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
-			       struct tcf_proto __rcu **p_filter_chain)
-{
-	chain->p_filter_chain = p_filter_chain;
-}
-
 static void tcf_block_offload_cmd(struct tcf_block *block, struct Qdisc *q,
 				  struct tcf_block_ext_info *ei,
 				  enum tc_block_command command)
@@ -276,8 +276,7 @@ static void tcf_block_offload_unbind(struct tcf_block *block, struct Qdisc *q,
 	tcf_block_offload_cmd(block, q, ei, TC_BLOCK_UNBIND);
 }
 
-int tcf_block_get_ext(struct tcf_block **p_block,
-		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+int tcf_block_get_ext(struct tcf_block **p_block, struct Qdisc *q,
 		      struct tcf_block_ext_info *ei)
 {
 	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
@@ -295,7 +294,9 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	WARN_ON(!ei->chain_head_change);
+	chain->chain_head_change = ei->chain_head_change;
+	chain->chain_head_change_priv = ei->chain_head_change_priv;
 	block->net = qdisc_net(q);
 	block->q = q;
 	tcf_block_offload_bind(block, q, ei);
@@ -308,12 +309,23 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 }
 EXPORT_SYMBOL(tcf_block_get_ext);
 
+static void tcf_chain_head_change_dflt(struct tcf_proto *tp_head, void *priv)
+{
+	struct tcf_proto __rcu **p_filter_chain = priv;
+
+	rcu_assign_pointer(*p_filter_chain, tp_head);
+}
+
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
 {
-	struct tcf_block_ext_info ei = {0, };
+	struct tcf_block_ext_info ei = {
+		.chain_head_change = tcf_chain_head_change_dflt,
+		.chain_head_change_priv = p_filter_chain,
+	};
 
-	return tcf_block_get_ext(p_block, p_filter_chain, q, &ei);
+	WARN_ON(!p_filter_chain);
+	return tcf_block_get_ext(p_block, q, &ei);
 }
 EXPORT_SYMBOL(tcf_block_get);
 
@@ -359,8 +371,7 @@ static void tcf_block_put_deferred(struct work_struct *work)
 	rtnl_unlock();
 }
 
-void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+void tcf_block_put_ext(struct tcf_block *block, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei)
 {
 	if (!block)
@@ -382,7 +393,7 @@ void tcf_block_put(struct tcf_block *block)
 {
 	struct tcf_block_ext_info ei = {0, };
 
-	tcf_block_put_ext(block, NULL, block->q, &ei);
+	tcf_block_put_ext(block, block->q, &ei);
 }
 
 EXPORT_SYMBOL(tcf_block_put);
@@ -558,9 +569,8 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
 				struct tcf_chain_info *chain_info,
 				struct tcf_proto *tp)
 {
-	if (chain->p_filter_chain &&
-	    *chain_info->pprev == chain->filter_chain)
-		rcu_assign_pointer(*chain->p_filter_chain, tp);
+	if (*chain_info->pprev == chain->filter_chain)
+		tcf_chain_head_change(chain, tp);
 	RCU_INIT_POINTER(tp->next, tcf_chain_tp_prev(chain_info));
 	rcu_assign_pointer(*chain_info->pprev, tp);
 	tcf_chain_hold(chain);
@@ -572,8 +582,8 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
 {
 	struct tcf_proto *next = rtnl_dereference(chain_info->next);
 
-	if (chain->p_filter_chain && tp == chain->filter_chain)
-		RCU_INIT_POINTER(*chain->p_filter_chain, next);
+	if (tp == chain->filter_chain)
+		tcf_chain_head_change(chain, next);
 	RCU_INIT_POINTER(*chain_info->pprev, next);
 	tcf_chain_put(chain);
 }
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index b599db2..8118458 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -54,6 +54,13 @@ static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
 	return q->block;
 }
 
+static void clsact_chain_head_change(struct tcf_proto *tp_head, void *priv)
+{
+	struct tcf_proto __rcu **p_filter_chain = priv;
+
+	rcu_assign_pointer(*p_filter_chain, tp_head);
+}
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
@@ -61,9 +68,10 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 
 	q->block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+	q->block_info.chain_head_change = clsact_chain_head_change;
+	q->block_info.chain_head_change_priv = &dev->ingress_cl_list;
 
-	err = tcf_block_get_ext(&q->block, &dev->ingress_cl_list,
-				sch, &q->block_info);
+	err = tcf_block_get_ext(&q->block, sch, &q->block_info);
 	if (err)
 		return err;
 
@@ -76,10 +84,8 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put_ext(q->block, &dev->ingress_cl_list,
-			  sch, &q->block_info);
+	tcf_block_put_ext(q->block, sch, &q->block_info);
 	net_dec_ingress_queue();
 }
 
@@ -162,16 +168,18 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 
 	q->ingress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+	q->ingress_block_info.chain_head_change = clsact_chain_head_change;
+	q->ingress_block_info.chain_head_change_priv = &dev->ingress_cl_list;
 
-	err = tcf_block_get_ext(&q->ingress_block, &dev->ingress_cl_list,
-				sch, &q->ingress_block_info);
+	err = tcf_block_get_ext(&q->ingress_block, sch, &q->ingress_block_info);
 	if (err)
 		return err;
 
 	q->egress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS;
+	q->egress_block_info.chain_head_change = clsact_chain_head_change;
+	q->egress_block_info.chain_head_change_priv = &dev->egress_cl_list;
 
-	err = tcf_block_get_ext(&q->egress_block, &dev->egress_cl_list,
-				sch, &q->egress_block_info);
+	err = tcf_block_get_ext(&q->egress_block, sch, &q->egress_block_info);
 	if (err)
 		goto err_egress_block_get;
 
@@ -183,20 +191,16 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 
 err_egress_block_get:
-	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
-			  sch, &q->ingress_block_info);
+	tcf_block_put_ext(q->ingress_block, sch, &q->ingress_block_info);
 	return err;
 }
 
 static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put_ext(q->egress_block, &dev->egress_cl_list,
-			  sch, &q->egress_block_info);
-	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
-			  sch, &q->ingress_block_info);
+	tcf_block_put_ext(q->egress_block, sch, &q->egress_block_info);
+	tcf_block_put_ext(q->ingress_block, sch, &q->ingress_block_info);
 
 	net_dec_ingress_queue();
 	net_dec_egress_queue();
-- 
2.9.5
