From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] net/sched: fix filter flushing
Date: Sat, 20 May 2017 15:01:32 +0200
Message-ID: <20170520130132.1626-2-jiri@resnulli.us>
References: <20170520130132.1626-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, daniel@iogearbox.net,
        simon.horman@netronome.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34638 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdETNBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 09:01:38 -0400
Received: by mail-wm0-f65.google.com with SMTP id d127so22922240wmf.1
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 06:01:37 -0700 (PDT)
In-Reply-To: <20170520130132.1626-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When user instructs to remove all filters from chain, we cannot destroy
the chain as other actions may hold a reference. Also the put in errout
would try to destroy it again. So instead, just walk the chain and remove
all existing filters.

Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 85088ed..01a8b8b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -201,15 +201,22 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 	return chain;
 }
 
-static void tcf_chain_destroy(struct tcf_chain *chain)
+static void tcf_chain_flush(struct tcf_chain *chain)
 {
 	struct tcf_proto *tp;
 
-	list_del(&chain->list);
+	if (*chain->p_filter_chain)
+		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_proto_destroy(tp);
 	}
+}
+
+static void tcf_chain_destroy(struct tcf_chain *chain)
+{
+	list_del(&chain->list);
+	tcf_chain_flush(chain);
 	kfree(chain);
 }
 
@@ -510,7 +517,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
-		tcf_chain_destroy(chain);
+		tcf_chain_flush(chain);
 		err = 0;
 		goto errout;
 	}
-- 
2.9.3
