From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] net: sched: provide stubs for tcf_chain_{get,put} for CONFIG_NET_CLS=n
Date: Thu, 18 May 2017 18:24:34 +0200
Message-ID: <01ab2339375fd161310945aa4eb77c3ecb46b26a.1495124042.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754281AbdERQYn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 12:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also changes tcf_chain_get() to return an error pointer instead of
NULL, so that tcf_action_goto_chain_init() can differentiate memory
allocation failure from lack of support.

Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
I'm not sure this EOPNOTSUPP is really necessary, ie if we can really
reach the tcf_action_goto_chain_init() call when CONFIG_NET_CLS=n.
If not, a simpler patch would add a tcf_chain_get() stub that just
returns NULL, as we wouldn't have to care about returning an incorrect
error code from tcf_action_goto_chain_init().

 include/net/pkt_cls.h |  7 +++++++
 net/sched/act_api.c   | 10 +++++++---
 net/sched/cls_api.c   | 10 +++++-----
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2c213a69c196..ad0d2899529f 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -27,6 +27,13 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
 #else
+static inline struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+static inline void tcf_chain_put(struct tcf_chain *chain)
+{
+}
 static inline
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain)
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 0ecf2a858767..502e0bbf35a6 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -31,12 +31,16 @@
 static int tcf_action_goto_chain_init(struct tc_action *a, struct tcf_proto *tp)
 {
 	u32 chain_index = a->tcfa_action & TC_ACT_EXT_VAL_MASK;
+	struct tcf_chain *chain;
 
 	if (!tp)
 		return -EINVAL;
-	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index);
-	if (!a->goto_chain)
-		return -ENOMEM;
+
+	chain = tcf_chain_get(tp->chain->block, chain_index);
+	if (IS_ERR(chain))
+		return PTR_ERR(chain);
+
+	a->goto_chain = chain;
 	return 0;
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 4020b8d932a1..8c14af3b77ae 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -193,7 +193,7 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 
 	chain = kzalloc(sizeof(*chain), GFP_KERNEL);
 	if (!chain)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	list_add_tail(&chain->list, &block->chain_list);
 	chain->block = block;
 	chain->index = chain_index;
@@ -256,8 +256,8 @@ int tcf_block_get(struct tcf_block **p_block,
 	INIT_LIST_HEAD(&block->chain_list);
 	/* Create chain 0 by default, it has to be always present. */
 	chain = tcf_chain_create(block, 0);
-	if (!chain) {
-		err = -ENOMEM;
+	if (IS_ERR(chain)) {
+		err = PTR_ERR(chain);
 		goto err_chain_create;
 	}
 	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
@@ -503,8 +503,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		goto errout;
 	}
 	chain = tcf_chain_get(block, chain_index);
-	if (!chain) {
-		err = -ENOMEM;
+	if (IS_ERR(chain)) {
+		err = PTR_ERR(chain);
 		goto errout;
 	}
 
-- 
2.13.0
