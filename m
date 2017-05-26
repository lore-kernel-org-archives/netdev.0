From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net/sched: let chain_get to figure out the return value
Date: Fri, 26 May 2017 09:21:29 +0200
Message-ID: <20170526072129.11075-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33138 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdEZHVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 03:21:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id b84so1932669wmh.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 00:21:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Alhough I believe that this create/nocreate dance is completelly
pointless, at least make it a bit nicer and easier to read.
Push the decision on what error value is returned to chain_get function
and use ERR macros.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/act_api.c |  4 ++--
 net/sched/cls_api.c | 15 ++++++---------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index aed6cf2..42bb75a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -35,8 +35,8 @@ static int tcf_action_goto_chain_init(struct tc_action *a, struct tcf_proto *tp)
 	if (!tp)
 		return -EINVAL;
 	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index, true);
-	if (!a->goto_chain)
-		return -ENOMEM;
+	if (IS_ERR(a->goto_chain))
+		return PTR_ERR(a->goto_chain);
 	return 0;
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 39da0c5..deec814 100644
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
@@ -231,10 +231,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 			return chain;
 		}
 	}
-	if (create)
-		return tcf_chain_create(block, chain_index);
-	else
-		return NULL;
+	return create ? tcf_chain_create(block, chain_index) : ERR_PTR(-EINVAL);
 }
 EXPORT_SYMBOL(tcf_chain_get);
 
@@ -267,8 +264,8 @@ int tcf_block_get(struct tcf_block **p_block,
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
@@ -517,8 +514,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	}
 	chain = tcf_chain_get(block, chain_index,
 			      n->nlmsg_type == RTM_NEWTFILTER);
-	if (!chain) {
-		err = n->nlmsg_type == RTM_NEWTFILTER ? -ENOMEM : -EINVAL;
+	if (IS_ERR(chain)) {
+		err = PTR_ERR(chain);
 		goto errout;
 	}
 
-- 
2.9.3
