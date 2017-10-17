From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/20] net: sched: add block bind/unbind notif. and extended block_get/put
Date: Tue, 17 Oct 2017 22:05:56 +0200
Message-ID: <20171017200615.4530-2-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:47449 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760166AbdJQUGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:18 -0400
Received: by mail-wr0-f195.google.com with SMTP id y39so2906409wrd.4
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:18 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce new type of ndo_setup_tc message to propage binding/unbinding
of a block to driver. Call this ndo whenever qdisc gets/puts a block.
Alongside with this, there's need to propagate binder type from qdisc
code down to the notifier. So introduce extended variants of
block_get/put in order to pass this info.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h |  1 +
 include/net/pkt_cls.h     | 40 +++++++++++++++++++++++++++++++++
 net/sched/cls_api.c       | 56 ++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 94 insertions(+), 3 deletions(-)

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
index 49a143e..41bc7d7 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -17,13 +17,27 @@ struct tcf_walker {
 int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
+enum tcf_block_binder_type {
+	TCF_BLOCK_BINDER_TYPE_UNSPEC,
+};
+
+struct tcf_block_ext_info {
+	enum tcf_block_binder_type binder_type;
+};
+
 #ifdef CONFIG_NET_CLS
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei);
 void tcf_block_put(struct tcf_block *block);
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		       struct tcf_block_ext_info *ei);
 
 static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
 {
@@ -46,10 +60,25 @@ int tcf_block_get(struct tcf_block **p_block,
 	return 0;
 }
 
+static inline
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei)
+{
+	return 0;
+}
+
 static inline void tcf_block_put(struct tcf_block *block)
 {
 }
 
+static inline
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		       struct tcf_block_ext_info *ei)
+{
+}
+
 static inline struct Qdisc *tcf_block_q(struct tcf_block *block)
 {
 	return NULL;
@@ -434,6 +463,17 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
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
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2e8e87f..92dce26 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -240,8 +240,36 @@ tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
 	chain->p_filter_chain = p_filter_chain;
 }
 
-int tcf_block_get(struct tcf_block **p_block,
-		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
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
+int tcf_block_get_ext(struct tcf_block **p_block,
+		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		      struct tcf_block_ext_info *ei)
 {
 	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
 	struct tcf_chain *chain;
@@ -259,6 +287,7 @@ int tcf_block_get(struct tcf_block **p_block,
 	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
 	block->net = qdisc_net(q);
 	block->q = q;
+	tcf_block_offload_bind(block, q, ei);
 	*p_block = block;
 	return 0;
 
@@ -266,15 +295,28 @@ int tcf_block_get(struct tcf_block **p_block,
 	kfree(block);
 	return err;
 }
+EXPORT_SYMBOL(tcf_block_get_ext);
+
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q)
+{
+	struct tcf_block_ext_info ei = {0, };
+
+	return tcf_block_get_ext(p_block, p_filter_chain, q, &ei);
+}
 EXPORT_SYMBOL(tcf_block_get);
 
-void tcf_block_put(struct tcf_block *block)
+void tcf_block_put_ext(struct tcf_block *block,
+		       struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
+		       struct tcf_block_ext_info *ei)
 {
 	struct tcf_chain *chain, *tmp;
 
 	if (!block)
 		return;
 
+	tcf_block_offload_unbind(block, q, ei);
+
 	/* XXX: Standalone actions are not allowed to jump to any chain, and
 	 * bound actions should be all removed after flushing. However,
 	 * filters are destroyed in RCU callbacks, we have to hold the chains
@@ -302,6 +344,14 @@ void tcf_block_put(struct tcf_block *block)
 		tcf_chain_put(chain);
 	kfree(block);
 }
+EXPORT_SYMBOL(tcf_block_put_ext);
+
+void tcf_block_put(struct tcf_block *block)
+{
+	struct tcf_block_ext_info ei = {0, };
+
+	tcf_block_put_ext(block, NULL, block->q, &ei);
+}
 EXPORT_SYMBOL(tcf_block_put);
 
 /* Main classifier routine: scans classifier chain attached
-- 
2.9.5
