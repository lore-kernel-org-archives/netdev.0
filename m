From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 08/10] net: sched: introduce multichain support for filters
Date: Wed, 17 May 2017 11:08:01 +0200
Message-ID: <20170517090803.4461-9-jiri@resnulli.us>
References: <20170517090803.4461-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35121 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753625AbdEQJIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 05:08:18 -0400
Received: by mail-wr0-f194.google.com with SMTP id g12so759490wrg.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 02:08:18 -0700 (PDT)
In-Reply-To: <20170517090803.4461-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Instead of having only one filter per block, introduce a list of chains
for every block. Create chain 0 by default. UAPI is extended so the user
can specify which chain he wants to change. If the new attribute is not
specified, chain 0 is used. That allows to maintain backward
compatibility. If chain does not exist and user wants to manipulate with
it, new chain is created with specified index. Also, when last filter is
removed from the chain, the chain is destroyed.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h          |   2 +
 include/net/sch_generic.h      |   9 +++-
 include/uapi/linux/rtnetlink.h |   1 +
 net/sched/cls_api.c            | 104 ++++++++++++++++++++++++++++++++++-------
 4 files changed, 98 insertions(+), 18 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e56e715..2c213a6 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -18,6 +18,8 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 #ifdef CONFIG_NET_CLS
+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index);
+void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain);
 void tcf_block_put(struct tcf_block *block);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 52bceed..569b565 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -8,6 +8,7 @@
 #include <linux/pkt_cls.h>
 #include <linux/percpu.h>
 #include <linux/dynamic_queue_limits.h>
+#include <linux/list.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -236,7 +237,7 @@ struct tcf_proto {
 	struct Qdisc		*q;
 	void			*data;
 	const struct tcf_proto_ops	*ops;
-	struct tcf_block	*block;
+	struct tcf_chain	*chain;
 	struct rcu_head		rcu;
 };
 
@@ -251,10 +252,14 @@ struct qdisc_skb_cb {
 struct tcf_chain {
 	struct tcf_proto __rcu *filter_chain;
 	struct tcf_proto __rcu **p_filter_chain;
+	struct list_head list;
+	struct tcf_block *block;
+	u32 index; /* chain index */
+	unsigned int refcnt;
 };
 
 struct tcf_block {
-	struct tcf_chain *chain;
+	struct list_head chain_list;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index cce0613..6487b21 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -549,6 +549,7 @@ enum {
 	TCA_STAB,
 	TCA_PAD,
 	TCA_DUMP_INVISIBLE,
+	TCA_CHAIN,
 	__TCA_MAX
 };
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 63aa2ea..adacaf2 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -129,7 +129,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 
 static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
 					  u32 prio, u32 parent, struct Qdisc *q,
-					  struct tcf_block *block)
+					  struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 	int err;
@@ -165,7 +165,7 @@ static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
 	tp->prio = prio;
 	tp->classid = parent;
 	tp->q = q;
-	tp->block = block;
+	tp->chain = chain;
 
 	err = tp->ops->init(tp);
 	if (err) {
@@ -186,15 +186,26 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
 	kfree_rcu(tp, rcu);
 }
 
-static struct tcf_chain *tcf_chain_create(void)
+static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
+					  u32 chain_index)
 {
-	return kzalloc(sizeof(struct tcf_chain), GFP_KERNEL);
+	struct tcf_chain *chain;
+
+	chain = kzalloc(sizeof(*chain), GFP_KERNEL);
+	if (!chain)
+		return NULL;
+	list_add_tail(&chain->list, &block->chain_list);
+	chain->block = block;
+	chain->index = chain_index;
+	chain->refcnt = 1;
+	return chain;
 }
 
 static void tcf_chain_destroy(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
+	list_del(&chain->list);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_proto_destroy(tp);
@@ -202,6 +213,30 @@ static void tcf_chain_destroy(struct tcf_chain *chain)
 	kfree(chain);
 }
 
+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
+{
+	struct tcf_chain *chain;
+
+	list_for_each_entry(chain, &block->chain_list, list) {
+		if (chain->index == chain_index) {
+			chain->refcnt++;
+			return chain;
+		}
+	}
+	return tcf_chain_create(block, chain_index);
+}
+EXPORT_SYMBOL(tcf_chain_get);
+
+void tcf_chain_put(struct tcf_chain *chain)
+{
+	/* Destroy unused chain, with exception of chain 0, which is the
+	 * default one and has to be always present.
+	 */
+	if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
+		tcf_chain_destroy(chain);
+}
+EXPORT_SYMBOL(tcf_chain_put);
+
 static void
 tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
 			       struct tcf_proto __rcu **p_filter_chain)
@@ -213,16 +248,19 @@ int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain)
 {
 	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
+	struct tcf_chain *chain;
 	int err;
 
 	if (!block)
 		return -ENOMEM;
-	block->chain = tcf_chain_create();
-	if (!block->chain) {
+	INIT_LIST_HEAD(&block->chain_list);
+	/* Create chain 0 by default, it has to be always present. */
+	chain = tcf_chain_create(block, 0);
+	if (!chain) {
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_set(block->chain, p_filter_chain);
+	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
 	*p_block = block;
 	return 0;
 
@@ -234,9 +272,13 @@ EXPORT_SYMBOL(tcf_block_get);
 
 void tcf_block_put(struct tcf_block *block)
 {
+	struct tcf_chain *chain, *tmp;
+
 	if (!block)
 		return;
-	tcf_chain_destroy(block->chain);
+
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+		tcf_chain_destroy(chain);
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
@@ -360,10 +402,11 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	u32 prio;
 	bool prio_allocate;
 	u32 parent;
+	u32 chain_index;
 	struct net_device *dev;
 	struct Qdisc  *q;
 	struct tcf_chain_info chain_info;
-	struct tcf_chain *chain;
+	struct tcf_chain *chain = NULL;
 	struct tcf_block *block;
 	struct tcf_proto *tp;
 	const struct Qdisc_class_ops *cops;
@@ -449,7 +492,17 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		err = -EINVAL;
 		goto errout;
 	}
-	chain = block->chain;
+
+	chain_index = tca[TCA_CHAIN] ? nla_get_u32(tca[TCA_CHAIN]) : 0;
+	if (chain_index > TC_ACT_EXT_VAL_MASK) {
+		err = -EINVAL;
+		goto errout;
+	}
+	chain = tcf_chain_get(block, chain_index);
+	if (!chain) {
+		err = -ENOMEM;
+		goto errout;
+	}
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
@@ -483,7 +536,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			prio = tcf_auto_prio(tcf_chain_tp_prev(&chain_info));
 
 		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
-				      protocol, prio, parent, q, block);
+				      protocol, prio, parent, q, chain);
 		if (IS_ERR(tp)) {
 			err = PTR_ERR(tp);
 			goto errout;
@@ -556,6 +609,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	}
 
 errout:
+	if (chain)
+		tcf_chain_put(chain);
 	if (cl)
 		cops->put(q, cl);
 	if (err == -EAGAIN)
@@ -584,6 +639,8 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
 	if (nla_put_string(skb, TCA_KIND, tp->ops->kind))
 		goto nla_put_failure;
+	if (nla_put_u32(skb, TCA_CHAIN, tp->chain->index))
+		goto nla_put_failure;
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
@@ -640,7 +697,7 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 			     RTM_NEWTFILTER);
 }
 
-static void tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
+static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 			   struct netlink_callback *cb,
 			   long index_start, long *p_index)
 {
@@ -667,7 +724,7 @@ static void tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
-				break;
+				return false;
 
 			cb->args[1] = 1;
 		}
@@ -682,14 +739,16 @@ static void tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 		tp->ops->walk(tp, &arg.w);
 		cb->args[1] = arg.w.count + 1;
 		if (arg.w.stop)
-			break;
+			return false;
 	}
+	return true;
 }
 
 /* called with RTNL */
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	struct Qdisc *q;
 	struct tcf_block *block;
@@ -699,9 +758,15 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	long index_start;
 	long index;
+	int err;
 
 	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
 		return skb->len;
+
+	err = nlmsg_parse(cb->nlh, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
+	if (err)
+		return err;
+
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
 		return skb->len;
@@ -725,11 +790,18 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	block = cops->tcf_block(q, cl);
 	if (!block)
 		goto errout;
-	chain = block->chain;
 
 	index_start = cb->args[0];
 	index = 0;
-	tcf_chain_dump(chain, skb, cb, index_start, &index);
+
+	list_for_each_entry(chain, &block->chain_list, list) {
+		if (tca[TCA_CHAIN] &&
+		    nla_get_u32(tca[TCA_CHAIN]) != chain->index)
+			continue;
+		if (!tcf_chain_dump(chain, skb, cb, index_start, &index))
+			break;
+	}
+
 	cb->args[0] = index;
 
 errout:
-- 
2.9.3
