From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/34] net: sched: introduce per-block callbacks
Date: Thu, 12 Oct 2017 19:18:02 +0200
Message-ID: <20171012171823.1431-14-jiri@resnulli.us>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37754 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbdJLRSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:37 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so4346558wmr.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:37 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce infrastructure that allows drivers to register callbacks that
are called whenever tc would offload inserted rule for a specific block.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     |  81 ++++++++++++++++++++++++++++++++++++
 include/net/sch_generic.h |   1 +
 net/sched/cls_api.c       | 104 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 186 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 104326fc..febd52e 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -28,6 +28,8 @@ struct tcf_block_ext_info {
 	bool bound;
 };
 
+struct tcf_block_cb;
+
 #ifdef CONFIG_NET_CLS
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
@@ -59,6 +61,21 @@ static inline struct net_device *tcf_block_dev(struct tcf_block *block)
 	return tcf_block_q(block)->dev_queue->dev;
 }
 
+void *tcf_block_cb_priv(struct tcf_block_cb *block_cb);
+struct tcf_block_cb *tcf_block_cb_lookup(struct tcf_block *block,
+					 tc_setup_cb_t *cb, void *cb_ident);
+void tcf_block_cb_incref(struct tcf_block_cb *block_cb);
+unsigned int tcf_block_cb_decref(struct tcf_block_cb *block_cb);
+struct tcf_block_cb *__tcf_block_cb_register(struct tcf_block *block,
+					     tc_setup_cb_t *cb, void *cb_ident,
+					     void *cb_priv);
+int tcf_block_cb_register(struct tcf_block *block,
+			  tc_setup_cb_t *cb, void *cb_ident,
+			  void *cb_priv);
+void __tcf_block_cb_unregister(struct tcf_block_cb *block_cb);
+void tcf_block_cb_unregister(struct tcf_block *block,
+			     tc_setup_cb_t *cb, void *cb_ident);
+
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
@@ -100,6 +117,70 @@ static inline bool tcf_is_block_shared(const struct tcf_block *block)
 	return false;
 }
 
+static inline
+int tc_setup_cb_block_register(struct tcf_block *block, tc_setup_cb_t *cb,
+			       void *cb_priv)
+{
+	return 0;
+}
+
+static inline
+void tc_setup_cb_block_unregister(struct tcf_block *block, tc_setup_cb_t *cb,
+				  void *cb_priv)
+{
+}
+
+static inline
+void *tcf_block_cb_priv(struct tcf_block_cb *block_cb)
+{
+	return NULL;
+}
+
+static inline
+struct tcf_block_cb *tcf_block_cb_lookup(struct tcf_block *block,
+					 tc_setup_cb_t *cb, void *cb_ident)
+{
+	return NULL;
+}
+
+static inline
+void tcf_block_cb_incref(struct tcf_block_cb *block_cb)
+{
+}
+
+static inline
+unsigned int tcf_block_cb_decref(struct tcf_block_cb *block_cb)
+{
+	return 0;
+}
+
+static inline
+struct tcf_block_cb *__tcf_block_cb_register(struct tcf_block *block,
+					     tc_setup_cb_t *cb, void *cb_ident,
+					     void *cb_priv)
+{
+	return NULL;
+}
+
+static inline
+int tcf_block_cb_register(struct tcf_block *block,
+			  tc_setup_cb_t *cb, void *cb_ident,
+			  void *cb_priv)
+{
+	return 0;
+}
+
+static inline
+void __tcf_block_cb_unregister(struct tcf_block_cb *block_cb)
+{
+}
+
+static inline
+void tcf_block_cb_unregister(struct tcf_block *block,
+			     tc_setup_cb_t *cb, void *cb_ident)
+{
+}
+
 static inline int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			       struct tcf_result *res, bool compat_mode)
 {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e210452..dfa9617 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -275,6 +275,7 @@ struct tcf_block {
 	unsigned int refcnt;
 	struct net *net;
 	struct Qdisc *q;
+	struct list_head cb_list;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8f6e2c9..7837c8a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -319,6 +319,7 @@ static struct tcf_block *tcf_block_create(struct net *net, struct Qdisc *q)
 	block->refcnt = 1;
 	block->net = net;
 	block->q = q;
+	INIT_LIST_HEAD(&block->cb_list);
 
 	/* Create chain 0 by default, it has to be always present. */
 	chain = tcf_chain_create(block, 0);
@@ -489,6 +490,109 @@ void tcf_block_put(struct tcf_block *block)
 }
 EXPORT_SYMBOL(tcf_block_put);
 
+struct tcf_block_cb {
+	struct list_head list;
+	tc_setup_cb_t *cb;
+	void *cb_ident;
+	void *cb_priv;
+	unsigned int refcnt;
+};
+
+void *tcf_block_cb_priv(struct tcf_block_cb *block_cb)
+{
+	return block_cb->cb_priv;
+}
+EXPORT_SYMBOL(tcf_block_cb_priv);
+
+struct tcf_block_cb *tcf_block_cb_lookup(struct tcf_block *block,
+					 tc_setup_cb_t *cb, void *cb_ident)
+{	struct tcf_block_cb *block_cb;
+
+	list_for_each_entry(block_cb, &block->cb_list, list)
+		if (block_cb->cb == cb && block_cb->cb_ident == cb_ident)
+			return block_cb;
+	return NULL;
+}
+EXPORT_SYMBOL(tcf_block_cb_lookup);
+
+void tcf_block_cb_incref(struct tcf_block_cb *block_cb)
+{
+	block_cb->refcnt++;
+}
+EXPORT_SYMBOL(tcf_block_cb_incref);
+
+unsigned int tcf_block_cb_decref(struct tcf_block_cb *block_cb)
+{
+	return --block_cb->refcnt;
+}
+EXPORT_SYMBOL(tcf_block_cb_decref);
+
+struct tcf_block_cb *__tcf_block_cb_register(struct tcf_block *block,
+					     tc_setup_cb_t *cb, void *cb_ident,
+					     void *cb_priv)
+{
+	struct tcf_block_cb *block_cb;
+
+	block_cb = kzalloc(sizeof(*block_cb), GFP_KERNEL);
+	if (!block_cb)
+		return NULL;
+	block_cb->cb = cb;
+	block_cb->cb_ident = cb_ident;
+	block_cb->cb_priv = cb_priv;
+	list_add(&block_cb->list, &block->cb_list);
+	return block_cb;
+}
+EXPORT_SYMBOL(__tcf_block_cb_register);
+
+int tcf_block_cb_register(struct tcf_block *block,
+			  tc_setup_cb_t *cb, void *cb_ident,
+			  void *cb_priv)
+{
+	struct tcf_block_cb *block_cb;
+
+	block_cb = __tcf_block_cb_register(block, cb, cb_ident, cb_priv);
+	return block_cb ? 0 : -ENOMEM;
+}
+EXPORT_SYMBOL(tcf_block_cb_register);
+
+void __tcf_block_cb_unregister(struct tcf_block_cb *block_cb)
+{
+	list_del(&block_cb->list);
+	kfree(block_cb);
+}
+EXPORT_SYMBOL(__tcf_block_cb_unregister);
+
+void tcf_block_cb_unregister(struct tcf_block *block,
+			     tc_setup_cb_t *cb, void *cb_ident)
+{
+	struct tcf_block_cb *block_cb;
+
+	block_cb = tcf_block_cb_lookup(block, cb, cb_ident);
+	if (!block_cb)
+		return;
+	__tcf_block_cb_unregister(block_cb);
+}
+EXPORT_SYMBOL(tcf_block_cb_unregister);
+
+static int tcf_block_cb_call(struct tcf_block *block, enum tc_setup_type type,
+			     void *type_data, bool err_stop)
+{
+	struct tcf_block_cb *block_cb;
+	int ok_count = 0;
+	int err;
+
+	list_for_each_entry(block_cb, &block->cb_list, list) {
+		err = block_cb->cb(type, type_data, block_cb->cb_priv);
+		if (err) {
+			if (err_stop)
+				return err;
+		} else {
+			ok_count++;
+		}
+	}
+	return ok_count;
+}
+
 /* Main classifier routine: scans classifier chain attached
  * to this qdisc, (optionally) tests for protocol and asks
  * specific classifiers.
-- 
2.9.5
