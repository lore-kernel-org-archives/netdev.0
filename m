From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: only create filter chains for new filters/actions
Date: Tue, 23 May 2017 09:42:37 -0700
Message-ID: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33487 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdEWQnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:43:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id f27so28783487pfe.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:43:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_chain_get() always creates a new filter chain if not found
in existing ones. This is totally unnecessary when we get or
delete filters, new chain should be only created for new filters
(or new actions).

Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h |  3 ++-
 net/sched/act_api.c   |  2 +-
 net/sched/cls_api.c   | 13 +++++++++----
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2c213a6..f776229 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -18,7 +18,8 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 #ifdef CONFIG_NET_CLS
-struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index);
+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
+				bool create);
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 0ecf2a8..aed6cf2 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -34,7 +34,7 @@ static int tcf_action_goto_chain_init(struct tc_action *a, struct tcf_proto *tp)
 
 	if (!tp)
 		return -EINVAL;
-	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index);
+	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index, true);
 	if (!a->goto_chain)
 		return -ENOMEM;
 	return 0;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 01a8b8b..23d2236 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -220,7 +220,8 @@ static void tcf_chain_destroy(struct tcf_chain *chain)
 	kfree(chain);
 }
 
-struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
+				bool create)
 {
 	struct tcf_chain *chain;
 
@@ -230,7 +231,10 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
 			return chain;
 		}
 	}
-	return tcf_chain_create(block, chain_index);
+	if (create)
+		return tcf_chain_create(block, chain_index);
+	else
+		return NULL;
 }
 EXPORT_SYMBOL(tcf_chain_get);
 
@@ -509,9 +513,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 		err = -EINVAL;
 		goto errout;
 	}
-	chain = tcf_chain_get(block, chain_index);
+	chain = tcf_chain_get(block, chain_index,
+			      n->nlmsg_type == RTM_NEWTFILTER);
 	if (!chain) {
-		err = -ENOMEM;
+		err = n->nlmsg_type == RTM_NEWTFILTER ? -ENOMEM : -EINVAL;
 		goto errout;
 	}
 
-- 
2.5.5
