From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] net: sched: don't do tcf_chain_flush from tcf_chain_destroy
Date: Tue, 22 Aug 2017 22:46:50 +0200
Message-ID: <20170822204650.7016-3-jiri@resnulli.us>
References: <20170822204650.7016-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35407 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdHVUq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 16:46:57 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so291809wmd.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 13:46:56 -0700 (PDT)
In-Reply-To: <20170822204650.7016-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

tcf_chain_flush needs to be called with RTNL. However, on
free_tcf->
 tcf_action_goto_chain_fini->
  tcf_chain_put->
   tcf_chain_destroy->
    tcf_chain_flush
callpath, it is called without RTNL.
This issue was notified by following warning:

[  155.599052] WARNING: suspicious RCU usage
[  155.603165] 4.13.0-rc5jiri+ #54 Not tainted
[  155.607456] -----------------------------
[  155.611561] net/sched/cls_api.c:195 suspicious rcu_dereference_protected() usage!

Since on this callpath, the chain is guaranteed to be already empty
by check in tcf_chain_put, move the tcf_chain_flush call out and call it
only where it is needed - into tcf_block_put.

Fixes: db50514f9a9c ("net: sched: add termination action to allow goto chain")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 45cd34e..6c5ea84 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -219,8 +219,6 @@ static void tcf_chain_destroy(struct tcf_chain *chain)
 	if (!list_empty(&chain->list))
 		list_del_init(&chain->list);
 
-	tcf_chain_flush(chain);
-
 	/* There might still be a reference held when we got here from
 	 * tcf_block_put. Wait for the user to drop reference before free.
 	 */
@@ -296,8 +294,10 @@ void tcf_block_put(struct tcf_block *block)
 	if (!block)
 		return;
 
-	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
+		tcf_chain_flush(chain);
 		tcf_chain_destroy(chain);
+	}
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
-- 
2.9.3
