From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/4] net: sched: introduce shared filter blocks infrastructure
Date: Mon, 10 Jul 2017 20:51:09 +0200
Message-ID: <20170710185110.3180-4-jiri@resnulli.us>
References: <20170710185110.3180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, stephen@networkplumber.org, jbenc@redhat.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        john.fastabend@gmail.com, alexander.h.duyck@intel.com,
        daniel@iogearbox.net, ogerlitz@mellanox.com, mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35045 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754679AbdGJSvY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:51:24 -0400
Received: by mail-wr0-f195.google.com with SMTP id z45so27005123wrb.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:51:18 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
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
 include/net/pkt_cls.h     |  22 +++++-
 include/net/sch_generic.h |   2 +
 net/sched/cls_api.c       | 180 ++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 189 insertions(+), 15 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 537d0a0..4381cbc 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -23,7 +23,12 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain);
+int tcf_block_get_shared(struct tcf_block **p_block,
+			 struct net *net, u32 block_index,
+			 struct tcf_proto __rcu **p_filter_chain);
 void tcf_block_put(struct tcf_block *block);
+void tcf_block_put_shared(struct tcf_block *block, struct net *net,
+			  struct tcf_proto __rcu **p_filter_chain);
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
@@ -35,7 +40,22 @@ int tcf_block_get(struct tcf_block **p_block,
 	return 0;
 }
 
-static inline void tcf_block_put(struct tcf_block *block)
+static inline
+int tcf_block_get_shared(struct tcf_block **p_block,
+			 struct net *net, u32 block_index,
+			 struct tcf_proto __rcu **p_filter_chain)
+{
+	return 0;
+}
+
+static inline
+void tcf_block_put(struct tcf_block *block)
+{
+}
+
+static inline
+void tcf_block_put_shared(struct tcf_block *block, struct net *net,
+			  struct tcf_proto __rcu **p_filter_chain)
 {
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 7396de8..cbc7313 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -266,6 +266,8 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	u32 index; /* block index for shared blocks */
+	unsigned int refcnt;
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 411f5577..098b9a2 100644
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
@@ -286,52 +287,175 @@ tcf_chain_filter_chain_ptr_del(struct tcf_chain *chain,
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
-		  struct tcf_proto __rcu **p_filter_chain)
+static void tcf_block_remove(struct tcf_block *block, struct net *net)
+{
+	struct tcf_net *tn = net_generic(net, tcf_net_id);
+
+	idr_remove(&tn->idr, block->index);
+}
+
+static struct tcf_block *tcf_block_create(void)
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
+
 	/* Create chain 0 by default, it has to be always present. */
 	chain = tcf_chain_create(block, 0);
 	if (!chain) {
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_add(chain, p_filter_chain);
-	*p_block = block;
-	return 0;
+	return block;
 
 err_chain_create:
 	kfree(block);
+	return ERR_PTR(err);
+}
+
+static void tcf_block_destroy(struct tcf_block *block)
+{
+	struct tcf_chain *chain, *tmp;
+
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+		tcf_chain_destroy(chain);
+	kfree(block);
+}
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
+static int __tcf_block_get(struct tcf_block **p_block, bool shared,
+			   struct net *net, u32 block_index,
+			   struct tcf_proto __rcu **p_filter_chain)
+{
+	struct tcf_block *block = NULL;
+	bool created = false;
+	int err;
+
+	if (shared) {
+		block = tcf_block_lookup(net, block_index);
+		if (block)
+			block->refcnt++;
+	}
+
+	if (!block) {
+		block = tcf_block_create();
+		if (IS_ERR(block))
+			return PTR_ERR(block);
+		created = true;
+		if (shared) {
+			err = tcf_block_insert(block, net, block_index);
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
+		if (shared)
+			tcf_block_remove(block, net);
+err_block_insert:
+		tcf_block_destroy(block);
+	} else {
+		block->refcnt--;
+	}
 	return err;
 }
+
+int tcf_block_get(struct tcf_block **p_block,
+		  struct tcf_proto __rcu **p_filter_chain)
+{
+	return __tcf_block_get(p_block, false, NULL, 0, p_filter_chain);
+}
 EXPORT_SYMBOL(tcf_block_get);
 
-void tcf_block_put(struct tcf_block *block)
+int tcf_block_get_shared(struct tcf_block **p_block,
+			 struct net *net, u32 block_index,
+			 struct tcf_proto __rcu **p_filter_chain)
 {
-	struct tcf_chain *chain, *tmp;
+	return __tcf_block_get(p_block, true, net, block_index, p_filter_chain);
+}
+EXPORT_SYMBOL(tcf_block_get_shared);
 
+static void __tcf_block_put(struct tcf_block *block,
+			    bool shared, struct net *net,
+			    struct tcf_proto __rcu **p_filter_chain)
+{
 	if (!block)
 		return;
 
 	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block), NULL);
 
-	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
-		tcf_chain_destroy(chain);
-	kfree(block);
+	if (--block->refcnt == 0) {
+		if (shared)
+			tcf_block_remove(block, net);
+		tcf_block_destroy(block);
+	}
+}
+
+void tcf_block_put(struct tcf_block *block)
+{
+	__tcf_block_put(block, false, NULL, NULL);
 }
 EXPORT_SYMBOL(tcf_block_put);
 
+void tcf_block_put_shared(struct tcf_block *block, struct net *net,
+			  struct tcf_proto __rcu **p_filter_chain)
+{
+	__tcf_block_put(block, true, net, p_filter_chain);
+}
+EXPORT_SYMBOL(tcf_block_put_shared);
+
 /* Main classifier routine: scans classifier chain attached
  * to this qdisc, (optionally) tests for protocol and asks
  * specific classifiers.
@@ -1035,8 +1159,36 @@ int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 }
 EXPORT_SYMBOL(tcf_exts_get_dev);
 
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
 	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
-- 
2.9.3
