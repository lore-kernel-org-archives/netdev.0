From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/34] net: sched: add block bind/unbind notification to drivers
Date: Thu, 12 Oct 2017 19:18:01 +0200
Message-ID: <20171012171823.1431-13-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:44263 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753573AbdJLRSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:37 -0400
Received: by mail-wm0-f68.google.com with SMTP id 196so24797076wma.1
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:36 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce new type of ndo_setup_tc message to propage binding/unbinding
of a block to binder.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h |  1 +
 include/net/pkt_cls.h     | 21 +++++++++++++++++++--
 include/net/sch_generic.h |  1 +
 net/sched/cls_api.c       | 33 +++++++++++++++++++++++++++++++--
 4 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 31bb301..062a4f5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -771,6 +771,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 
 enum tc_setup_type {
 	TC_SETUP_MQPRIO,
+	TC_SETUP_BLOCK,
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
 	TC_SETUP_CLSMATCHALL,
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 05bc999..104326fc 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -17,9 +17,15 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+enum tcf_block_binder_type {
+	TCF_BLOCK_BINDER_TYPE_UNSPEC,
+};
+
 struct tcf_block_ext_info {
 	bool shareable;
 	u32 block_index;
+	enum tcf_block_binder_type binder_type;
+	bool bound;
 };
 
 #ifdef CONFIG_NET_CLS
@@ -34,7 +40,7 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 		      struct tcf_block_ext_info *ei);
 void tcf_block_put(struct tcf_block *block);
 void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei);
 
 static inline bool tcf_is_block_shared(const struct tcf_block *block)
@@ -79,7 +85,7 @@ void tcf_block_put(struct tcf_block *block)
 
 static inline
 void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei)
 {
 }
@@ -468,6 +474,17 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
 		     void *type_data, bool err_stop);
 
+enum tc_block_command {
+	TC_BLOCK_BIND,
+	TC_BLOCK_UNBIND,
+};
+
+struct tc_block_offload {
+	enum tc_block_command command;
+	enum tcf_block_binder_type binder_type;
+	struct tcf_block *block;
+};
+
 struct tc_cls_common_offload {
 	u32 chain_index;
 	__be16 protocol;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a4926c9..e210452 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -69,6 +69,7 @@ struct Qdisc {
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
 #define TCQ_F_INVISIBLE		0x80 /* invisible by default in dump */
+#define TCQ_F_BOUNDOFFLOAD	0x100 /* bound to the offload driver */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 908b38a..8f6e2c9 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -377,6 +377,33 @@ static struct tcf_chain *tcf_block_chain_zero(struct tcf_block *block)
 	return list_first_entry(&block->chain_list, struct tcf_chain, list);
 }
 
+static void tcf_block_offload_cmd(struct tcf_block *block, struct Qdisc *q,
+				  struct tcf_block_ext_info *ei,
+				  enum tc_block_command command)
+{
+	struct net_device *dev = q->dev_queue->dev;
+	struct tc_block_offload bo = {};
+
+	if (!tc_can_offload(dev))
+		return;
+	bo.command = command;
+	bo.binder_type = ei->binder_type;
+	bo.block = block;
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_BLOCK, &bo);
+}
+
+static void tcf_block_offload_bind(struct tcf_block *block, struct Qdisc *q,
+				   struct tcf_block_ext_info *ei)
+{
+	tcf_block_offload_cmd(block, q, ei, TC_BLOCK_BIND);
+}
+
+static void tcf_block_offload_unbind(struct tcf_block *block, struct Qdisc *q,
+				     struct tcf_block_ext_info *ei)
+{
+	tcf_block_offload_cmd(block, q, ei, TC_BLOCK_UNBIND);
+}
+
 int tcf_block_get_ext(struct tcf_block **p_block,
 		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
 		      struct tcf_block_ext_info *ei)
@@ -409,6 +436,7 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 	if (err)
 		goto err_chain_filter_chain_ptr_add;
 
+	tcf_block_offload_bind(block, q, ei);
 	*p_block = block;
 	return 0;
 
@@ -435,12 +463,13 @@ int tcf_block_get(struct tcf_block **p_block,
 EXPORT_SYMBOL(tcf_block_get);
 
 void tcf_block_put_ext(struct tcf_block *block,
-		       struct tcf_proto __rcu **p_filter_chain,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
 		       struct tcf_block_ext_info *ei)
 {
 	if (!block)
 		return;
 
+	tcf_block_offload_unbind(block, q, ei);
 	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block),
 				       p_filter_chain);
 
@@ -456,7 +485,7 @@ void tcf_block_put(struct tcf_block *block)
 {
 	struct tcf_block_ext_info ei = {0, };
 
-	tcf_block_put_ext(block, NULL, &ei);
+	tcf_block_put_ext(block, NULL, block->q, &ei);
 }
 EXPORT_SYMBOL(tcf_block_put);
 
-- 
2.9.5
