From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/10] net: sched: introduce helpers to work with filter chains
Date: Mon, 15 May 2017 10:38:53 +0200
Message-ID: <20170515083857.3615-7-jiri@resnulli.us>
References: <20170515083857.3615-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36652 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933330AbdEOIjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 04:39:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id u65so26335475wmu.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 01:39:14 -0700 (PDT)
In-Reply-To: <20170515083857.3615-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce struct tcf_chain object and set of helpers around it. Wraps up
insertion, deletion and search in the filter chain.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/sch_generic.h |   7 ++-
 net/sched/cls_api.c       | 148 +++++++++++++++++++++++++++++++++-------------
 2 files changed, 113 insertions(+), 42 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 98cf2f2..52bceed 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -248,10 +248,15 @@ struct qdisc_skb_cb {
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
-struct tcf_block {
+struct tcf_chain {
+	struct tcf_proto __rcu *filter_chain;
 	struct tcf_proto __rcu **p_filter_chain;
 };
 
+struct tcf_block {
+	struct tcf_chain *chain;
+};
+
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
 {
 	struct qdisc_skb_cb *qcb;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 72624fa..6f2ea68 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -106,13 +106,12 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 				 struct nlmsghdr *n,
-				 struct tcf_proto __rcu **chain, int event)
+				 struct tcf_chain *chain, int event)
 {
-	struct tcf_proto __rcu **it_chain;
 	struct tcf_proto *tp;
 
-	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
-	     it_chain = &tp->next)
+	for (tp = rtnl_dereference(chain->filter_chain);
+	     tp; tp = rtnl_dereference(tp->next))
 		tfilter_notify(net, oskb, n, tp, 0, event, false);
 }
 
@@ -187,26 +186,49 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
 	kfree_rcu(tp, rcu);
 }
 
-static void tcf_chain_destroy(struct tcf_proto __rcu **fl)
+static struct tcf_chain *tcf_chain_create(void)
+{
+	return kzalloc(sizeof(struct tcf_chain), GFP_KERNEL);
+}
+
+static void tcf_chain_destroy(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
-	while ((tp = rtnl_dereference(*fl)) != NULL) {
-		RCU_INIT_POINTER(*fl, tp->next);
+	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
+		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_proto_destroy(tp);
 	}
+	kfree(chain);
+}
+
+static void
+tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
+			       struct tcf_proto __rcu **p_filter_chain)
+{
+	chain->p_filter_chain = p_filter_chain;
 }
 
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain)
 {
 	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
+	int err;
 
 	if (!block)
 		return -ENOMEM;
-	block->p_filter_chain = p_filter_chain;
+	block->chain = tcf_chain_create();
+	if (!block->chain) {
+		err = -ENOMEM;
+		goto err_chain_create;
+	}
+	tcf_chain_filter_chain_ptr_set(block->chain, p_filter_chain);
 	*p_block = block;
 	return 0;
+
+err_chain_create:
+	kfree(block);
+	return err;
 }
 EXPORT_SYMBOL(tcf_block_get);
 
@@ -214,7 +236,7 @@ void tcf_block_put(struct tcf_block *block)
 {
 	if (!block)
 		return;
-	tcf_chain_destroy(block->p_filter_chain);
+	tcf_chain_destroy(block->chain);
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
@@ -261,6 +283,65 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tcf_classify);
 
+struct tcf_chain_info {
+	struct tcf_proto __rcu **pprev;
+	struct tcf_proto __rcu *next;
+};
+
+static struct tcf_proto *tcf_chain_tp_prev(struct tcf_chain_info *chain_info)
+{
+	return rtnl_dereference(*chain_info->pprev);
+}
+
+static void tcf_chain_tp_insert(struct tcf_chain *chain,
+				struct tcf_chain_info *chain_info,
+				struct tcf_proto *tp)
+{
+	if (chain->p_filter_chain &&
+	    *chain_info->pprev == chain->filter_chain)
+		*chain->p_filter_chain = tp;
+	RCU_INIT_POINTER(tp->next, rtnl_dereference(*chain_info->pprev));
+	rcu_assign_pointer(*chain_info->pprev, tp);
+}
+
+static void tcf_chain_tp_remove(struct tcf_chain *chain,
+				struct tcf_chain_info *chain_info,
+				struct tcf_proto *tp)
+{
+	struct tcf_proto *next = rtnl_dereference(chain_info->next);
+
+	if (chain->p_filter_chain && tp == chain->filter_chain)
+		*chain->p_filter_chain = next;
+	RCU_INIT_POINTER(*chain_info->pprev, next);
+}
+
+static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
+					   struct tcf_chain_info *chain_info,
+					   u32 protocol, u32 prio,
+					   bool prio_allocate)
+{
+	struct tcf_proto **pprev;
+	struct tcf_proto *tp;
+
+	/* Check the chain for existence of proto-tcf with this priority */
+	for (pprev = &chain->filter_chain;
+	     (tp = rtnl_dereference(*pprev)); pprev = &tp->next) {
+		if (tp->prio >= prio) {
+			if (tp->prio == prio) {
+				if (prio_allocate ||
+				    (tp->protocol != protocol && protocol))
+					return ERR_PTR(-EINVAL);
+			} else {
+				tp = NULL;
+			}
+			break;
+		}
+	}
+	chain_info->pprev = pprev;
+	chain_info->next = tp ? tp->next : NULL;
+	return tp;
+}
+
 /* Add/change/delete/get a filter node */
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
@@ -275,10 +356,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
-	struct tcf_proto __rcu **back;
-	struct tcf_proto __rcu **chain;
+	struct tcf_chain_info chain_info;
+	struct tcf_chain *chain;
 	struct tcf_block *block;
-	struct tcf_proto *next;
 	struct tcf_proto *tp;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
@@ -363,7 +443,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		err = -EINVAL;
 		goto errout;
 	}
-	chain = block->p_filter_chain;
+	chain = block->chain;
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
@@ -372,22 +452,11 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		goto errout;
 	}
 
-	/* Check the chain for existence of proto-tcf with this priority */
-	for (back = chain;
-	     (tp = rtnl_dereference(*back)) != NULL;
-	     back = &tp->next) {
-		if (tp->prio >= prio) {
-			if (tp->prio == prio) {
-				if (prio_allocate ||
-				    (tp->protocol != protocol && protocol)) {
-					err = -EINVAL;
-					goto errout;
-				}
-			} else {
-				tp = NULL;
-			}
-			break;
-		}
+	tp = tcf_chain_tp_find(chain, &chain_info, protocol,
+			       prio, prio_allocate);
+	if (IS_ERR(tp)) {
+		err = PTR_ERR(tp);
+		goto errout;
 	}
 
 	if (tp == NULL) {
@@ -405,7 +474,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		}
 
 		if (prio_allocate)
-			prio = tcf_auto_prio(rtnl_dereference(*back));
+			prio = tcf_auto_prio(tcf_chain_tp_prev(&chain_info));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
 				      protocol, prio, parent, q, block);
@@ -423,8 +492,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			next = rtnl_dereference(tp->next);
-			RCU_INIT_POINTER(*back, next);
+			tcf_chain_tp_remove(chain, &chain_info, tp);
 			tfilter_notify(net, skb, n, tp, fh,
 				       RTM_DELTFILTER, false);
 			tcf_proto_destroy(tp);
@@ -453,11 +521,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			err = tp->ops->delete(tp, fh, &last);
 			if (err)
 				goto errout;
-			next = rtnl_dereference(tp->next);
 			tfilter_notify(net, skb, n, tp, t->tcm_handle,
 				       RTM_DELTFILTER, false);
 			if (last) {
-				RCU_INIT_POINTER(*back, next);
+				tcf_chain_tp_remove(chain, &chain_info, tp);
 				tcf_proto_destroy(tp);
 			}
 			goto errout;
@@ -474,10 +541,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	err = tp->ops->change(net, skb, tp, cl, t->tcm_handle, tca, &fh,
 			      n->nlmsg_flags & NLM_F_CREATE ? TCA_ACT_NOREPLACE : TCA_ACT_REPLACE);
 	if (err == 0) {
-		if (tp_created) {
-			RCU_INIT_POINTER(tp->next, rtnl_dereference(*back));
-			rcu_assign_pointer(*back, tp);
-		}
+		if (tp_created)
+			tcf_chain_tp_insert(chain, &chain_info, tp);
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
@@ -578,7 +643,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct Qdisc *q;
 	struct tcf_block *block;
-	struct tcf_proto *tp, __rcu **chain;
+	struct tcf_proto *tp;
+	struct tcf_chain *chain;
 	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
@@ -609,11 +675,11 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	block = cops->tcf_block(q, cl);
 	if (!block)
 		goto errout;
-	chain = block->p_filter_chain;
+	chain = block->chain;
 
 	s_t = cb->args[0];
 
-	for (tp = rtnl_dereference(*chain), t = 0;
+	for (tp = rtnl_dereference(chain->filter_chain), t = 0;
 	     tp; tp = rtnl_dereference(tp->next), t++) {
 		if (t < s_t)
 			continue;
-- 
2.9.3
