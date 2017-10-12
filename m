From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/34] net: sched: introduce shared filter blocks infrastructure
Date: Thu, 12 Oct 2017 19:17:52 +0200
Message-ID: <20171012171823.1431-4-jiri@resnulli.us>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:48677 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdJLRS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:28 -0400
Received: by mail-wm0-f67.google.com with SMTP id i124so14948123wmf.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:28 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow qdiscs to share filter blocks among them. Each qdisc type has to
use block get/put modifications that enable sharing. Shared blocks are
tracked within each net namespace and identified by u32 value. This
value is auto-generated in case user did not pass it from userspace. If
user passes value that is not used, new block is created. If user passes
value that is already used, the existing block will be re-used.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     |  57 ++++++++++++++-
 include/net/sch_generic.h |   2 +
 net/sched/cls_api.c       | 183 +++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 222 insertions(+), 20 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 772dfa8..0cf520b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -17,13 +17,42 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+struct tcf_block_ext_info {
+	bool shareable;
+	u32 block_index;
+};
+
 #ifdef CONFIG_NET_CLS
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
 void tcf_chain_put(struct tcf_chain *chain);
+
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei);
 void tcf_block_put(struct tcf_block *block);
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_block_ext_info *ei);
+
+static inline bool tcf_is_block_shared(const struct tcf_block *block)
+{
+	return block->refcnt != 1;
+}
+
+static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
+{
+	WARN_ON(tcf_is_block_shared(block));
+	return block->q;
+}
+
+static inline struct net_device *tcf_block_dev(struct tcf_block *block)
+{
+	return tcf_block_q(block)->dev_queue->dev;
+}
+
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
@@ -35,8 +64,34 @@ int tcf_block_get(struct tcf_block **p_block,
 	return 0;
 }
 
-static inline void tcf_block_put(struct tcf_block *block)
+static inline
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei)
 {
+	return 0;
+}
+
+static inline
+void tcf_block_put(struct tcf_block *block)
+{
+}
+
+static inline
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_block_ext_info *ei)
+{
+}
+
+static inline struct net_device *tcf_block_dev(struct tcf_block *block)
+{
+	return NULL;
+}
+
+static inline bool tcf_is_block_shared(const struct tcf_block *block)
+{
+	return false;
 }
 
 static inline int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6583c59..0b2ba3b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -270,6 +270,8 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	u32 index; /* block index for shared blocks */
+	unsigned int refcnt;
 	struct net *net;
 	struct Qdisc *q;
 };
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0ffd79a..2d0f18f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -25,6 +25,7 @@
 #include <linux/kmod.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/idr.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/netlink.h>
@@ -272,48 +273,70 @@ tcf_chain_filter_chain_ptr_del(struct tcf_chain *chain,
 	WARN_ON(1);
 }
 
-static struct tcf_chain *tcf_block_chain_zero(struct tcf_block *block)
+struct tcf_net {
+	struct idr idr;
+};
+
+static unsigned int tcf_net_id;
+
+static int tcf_block_insert(struct tcf_block *block, struct net *net,
+			    u32 block_index)
 {
-	return list_first_entry(&block->chain_list, struct tcf_chain, list);
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+	int idr_start;
+	int idr_end;
+	int index;
+
+	if (block_index >= INT_MAX)
+		return -EINVAL;
+	idr_start = block_index ? block_index : 1;
+	idr_end = block_index ? block_index + 1 : INT_MAX;
+
+	index = idr_alloc(&tn->idr, block, idr_start, idr_end, GFP_KERNEL);
+	if (index < 0)
+		return index;
+	block->index = index;
+	return 0;
 }
 
-int tcf_block_get(struct tcf_block **p_block,
-		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
+static void tcf_block_remove(struct tcf_block *block, struct net *net)
+{
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+
+	idr_remove(&tn->idr, block->index);
+}
+
+static struct tcf_block *tcf_block_create(struct net *net, struct Qdisc *q)
 {
-	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
+	struct tcf_block *block;
 	struct tcf_chain *chain;
 	int err;
 
+	block = kzalloc(sizeof(*block), GFP_KERNEL);
 	if (!block)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	INIT_LIST_HEAD(&block->chain_list);
+	block->refcnt = 1;
+	block->net = net;
+	block->q = q;
+
 	/* Create chain 0 by default, it has to be always present. */
 	chain = tcf_chain_create(block, 0);
 	if (!chain) {
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_add(chain, p_filter_chain);
-	block->net = qdisc_net(q);
-	block->q = q;
-	*p_block = block;
-	return 0;
+	return block;
 
 err_chain_create:
 	kfree(block);
-	return err;
+	return ERR_PTR(err);
 }
-EXPORT_SYMBOL(tcf_block_get);
 
-void tcf_block_put(struct tcf_block *block)
+static void tcf_block_destroy(struct tcf_block *block)
 {
 	struct tcf_chain *chain, *tmp;
 
-	if (!block)
-		return;
-
-	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block), NULL);
-
 	/* XXX: Standalone actions are not allowed to jump to any chain, and
 	 * bound actions should be all removed after flushing. However,
 	 * filters are destroyed in RCU callbacks, we have to hold the chains
@@ -341,6 +364,100 @@ void tcf_block_put(struct tcf_block *block)
 		tcf_chain_put(chain);
 	kfree(block);
 }
+
+static struct tcf_block *tcf_block_lookup(struct net *net, u32 block_index)
+{
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+
+	return idr_find(&tn->idr, block_index);
+}
+
+static struct tcf_chain *tcf_block_chain_zero(struct tcf_block *block)
+{
+	return list_first_entry(&block->chain_list, struct tcf_chain, list);
+}
+
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei)
+{
+	struct net *net = qdisc_net(q);
+	struct tcf_block *block = NULL;
+	bool created = false;
+	int err;
+
+	if (ei->shareable) {
+		block = tcf_block_lookup(net, ei->block_index);
+		if (block)
+			block->refcnt++;
+	}
+
+	if (!block) {
+		block = tcf_block_create(net, q);
+		if (IS_ERR(block))
+			return PTR_ERR(block);
+		created = true;
+		if (ei->shareable) {
+			err = tcf_block_insert(block, net, ei->block_index);
+			if (err)
+				goto err_block_insert;
+		}
+	}
+
+	err = tcf_chain_filter_chain_ptr_add(tcf_block_chain_zero(block),
+					     p_filter_chain);
+	if (err)
+		goto err_chain_filter_chain_ptr_add;
+
+	*p_block = block;
+	return 0;
+
+err_chain_filter_chain_ptr_add:
+	if (created) {
+		if (ei->shareable)
+			tcf_block_remove(block, net);
+err_block_insert:
+		tcf_block_destroy(block);
+	} else {
+		block->refcnt--;
+	}
+	return err;
+}
+EXPORT_SYMBOL(tcf_block_get_ext);
+
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
+{
+	struct tcf_block_ext_info ei = {0, };
+
+	return tcf_block_get_ext(p_block, p_filter_chain, q, &ei);
+}
+EXPORT_SYMBOL(tcf_block_get);
+
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_block_ext_info *ei)
+{
+	if (!block)
+		return;
+
+	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block),
+				       p_filter_chain);
+
+	if (--block->refcnt == 0) {
+		if (ei->shareable)
+			tcf_block_remove(block, block->net);
+		tcf_block_destroy(block);
+	}
+}
+EXPORT_SYMBOL(tcf_block_put_ext);
+
+void tcf_block_put(struct tcf_block *block)
+{
+	struct tcf_block_ext_info ei = {0, };
+
+	tcf_block_put_ext(block, NULL, &ei);
+}
 EXPORT_SYMBOL(tcf_block_put);
 
 /* Main classifier routine: scans classifier chain attached
@@ -1090,8 +1207,36 @@ int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
 }
 EXPORT_SYMBOL(tc_setup_cb_call);
 
+static __net_init int tcf_net_init(struct net *net)
+{
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+
+	idr_init(&tn->idr);
+	return 0;
+}
+
+static void __net_exit tcf_net_exit(struct net *net)
+{
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+
+	idr_destroy(&tn->idr);
+}
+
+static struct pernet_operations tcf_net_ops = {
+	.init = tcf_net_init,
+	.exit = tcf_net_exit,
+	.id   = &tcf_net_id,
+	.size = sizeof(struct tcf_net),
+};
+
 static int __init tc_filter_init(void)
 {
+	int err;
+
+	err = register_pernet_subsys(&tcf_net_ops);
+	if (err)
+		return err;
+
 	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
-- 
2.9.5
