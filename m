From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] net/sched: properly assign RCU pointer in tcf_chain_tp_insert/remove
Date: Sat, 20 May 2017 15:01:31 +0200
Message-ID: <20170520130132.1626-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, daniel@iogearbox.net,
        simon.horman@netronome.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33635 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdETNBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 09:01:38 -0400
Received: by mail-wm0-f68.google.com with SMTP id b84so7090883wmh.0
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 06:01:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

*p_filter_chain is rcu-dereferenced on reader path. So here in writer,
property assign the pointer.

Fixes: 2190d1d0944f ("net: sched: introduce helpers to work with filter chains")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 4020b8d..85088ed 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -351,7 +351,7 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
 {
 	if (chain->p_filter_chain &&
 	    *chain_info->pprev == chain->filter_chain)
-		*chain->p_filter_chain = tp;
+		rcu_assign_pointer(*chain->p_filter_chain, tp);
 	RCU_INIT_POINTER(tp->next, tcf_chain_tp_prev(chain_info));
 	rcu_assign_pointer(*chain_info->pprev, tp);
 }
@@ -363,7 +363,7 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
 	struct tcf_proto *next = rtnl_dereference(chain_info->next);
 
 	if (chain->p_filter_chain && tp == chain->filter_chain)
-		*chain->p_filter_chain = next;
+		RCU_INIT_POINTER(*chain->p_filter_chain, next);
 	RCU_INIT_POINTER(*chain_info->pprev, next);
 }
 
-- 
2.9.3
