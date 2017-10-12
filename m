From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 32/34] net: sched: introduce block mechanism to handle netif_keep_dst calls
Date: Thu, 12 Oct 2017 19:18:21 +0200
Message-ID: <20171012171823.1431-33-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:53555 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755927AbdJLRSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:55 -0400
Received: by mail-wm0-f68.google.com with SMTP id q132so15247001wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:54 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of classifiers call netif_keep_dst directly on q->dev. That is
not possible to do directly for shared blocke where multiple qdiscs are
owning the block. So introduce a infrastructure to keep track of the
block owners in list and use this list to implement block variant of
netif_keep_dst.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h     |  1 +
 include/net/sch_generic.h |  2 ++
 net/sched/cls_api.c       | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_bpf.c       |  4 +--
 net/sched/cls_flow.c      |  2 +-
 net/sched/cls_route.c     |  2 +-
 6 files changed, 75 insertions(+), 4 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 1c8ef4f..66d4e71 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -37,6 +37,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 				bool create);
 void tcf_chain_put(struct tcf_chain *chain);
 
+void tcf_block_netif_keep_dst(struct tcf_block *block);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q);
 int tcf_block_get_ext(struct tcf_block **p_block,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index dfa9617..17c908a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -276,6 +276,8 @@ struct tcf_block {
 	struct net *net;
 	struct Qdisc *q;
 	struct list_head cb_list;
+	struct list_head owner_list;
+	bool keep_dst;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5a647e0..fba6a85 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -320,6 +320,7 @@ static struct tcf_block *tcf_block_create(struct net *net, struct Qdisc *q)
 	block->net = net;
 	block->q = q;
 	INIT_LIST_HEAD(&block->cb_list);
+	INIT_LIST_HEAD(&block->owner_list);
 
 	/* Create chain 0 by default, it has to be always present. */
 	chain = tcf_chain_create(block, 0);
@@ -405,6 +406,64 @@ static void tcf_block_offload_unbind(struct tcf_block *block, struct Qdisc *q,
 	tcf_block_offload_cmd(block, q, ei, TC_BLOCK_UNBIND);
 }
 
+struct tcf_block_owner_item {
+	struct list_head list;
+	struct Qdisc *q;
+	enum tcf_block_binder_type binder_type;
+};
+
+static void
+tcf_block_owner_netif_keep_dst(struct tcf_block *block,
+			       struct Qdisc *q,
+			       enum tcf_block_binder_type binder_type)
+{
+	if (block->keep_dst &&
+	    binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		netif_keep_dst(qdisc_dev(q));
+}
+
+void tcf_block_netif_keep_dst(struct tcf_block *block)
+{
+	struct tcf_block_owner_item *item;
+
+	block->keep_dst = true;
+	list_for_each_entry(item, &block->owner_list, list)
+		tcf_block_owner_netif_keep_dst(block, item->q,
+					       item->binder_type);
+}
+EXPORT_SYMBOL(tcf_block_netif_keep_dst);
+
+static int tcf_block_owner_add(struct tcf_block *block,
+			       struct Qdisc *q,
+			       enum tcf_block_binder_type binder_type)
+{
+	struct tcf_block_owner_item *item;
+
+	item = kmalloc(sizeof(*item), GFP_KERNEL);
+	if (!item)
+		return -ENOMEM;
+	item->q = q;
+	item->binder_type = binder_type;
+	list_add(&item->list, &block->owner_list);
+	return 0;
+}
+
+static void tcf_block_owner_del(struct tcf_block *block,
+				struct Qdisc *q,
+				enum tcf_block_binder_type binder_type)
+{
+	struct tcf_block_owner_item *item;
+
+	list_for_each_entry(item, &block->owner_list, list) {
+		if (item->q == q && item->binder_type == binder_type) {
+			list_del(&item->list);
+			kfree(item);
+			return;
+		}
+	}
+	WARN_ON(1);
+}
+
 int tcf_block_get_ext(struct tcf_block **p_block,
 		      struct tcf_proto __rcu **p_filter_chain, struct Qdisc *q,
 		      struct tcf_block_ext_info *ei)
@@ -432,6 +491,12 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 		}
 	}
 
+	err = tcf_block_owner_add(block, q, ei->binder_type);
+	if (err)
+		goto err_block_owner_add;
+
+	tcf_block_owner_netif_keep_dst(block, q, ei->binder_type);
+
 	err = tcf_chain_filter_chain_ptr_add(tcf_block_chain_zero(block),
 					     p_filter_chain);
 	if (err)
@@ -442,6 +507,8 @@ int tcf_block_get_ext(struct tcf_block **p_block,
 	return 0;
 
 err_chain_filter_chain_ptr_add:
+	tcf_block_owner_del(block, q, ei->binder_type);
+err_block_owner_add:
 	if (created) {
 		if (ei->shareable)
 			tcf_block_remove(block, net);
@@ -473,6 +540,7 @@ void tcf_block_put_ext(struct tcf_block *block,
 	tcf_block_offload_unbind(block, q, ei);
 	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block),
 				       p_filter_chain);
+	tcf_block_owner_del(block, q, ei->binder_type);
 
 	if (--block->refcnt == 0) {
 		if (ei->shareable)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 0f8b510..e21cdd0 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -383,8 +383,8 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 	prog->bpf_name = name;
 	prog->filter = fp;
 
-	if (fp->dst_needed && !(tp->q->flags & TCQ_F_INGRESS))
-		netif_keep_dst(qdisc_dev(tp->q));
+	if (fp->dst_needed)
+		tcf_block_netif_keep_dst(tp->chain->block);
 
 	return 0;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f3be666..4b5ce2e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -508,7 +508,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
 			       (unsigned long)fnew);
 
-	netif_keep_dst(qdisc_dev(tp->q));
+	tcf_block_netif_keep_dst(tp->chain->block);
 
 	if (tb[TCA_FLOW_KEYS]) {
 		fnew->keymask = keymask;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 9ddde65..cd2cd0d 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -504,7 +504,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 		if (f->handle < f1->handle)
 			break;
 
-	netif_keep_dst(qdisc_dev(tp->q));
+	tcf_block_netif_keep_dst(tp->chain->block);
 	rcu_assign_pointer(f->next, f1);
 	rcu_assign_pointer(*fp, f);
 
-- 
2.9.5
