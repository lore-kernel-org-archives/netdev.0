From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: remove tcf_block_put_deferred()
Date: Mon, 30 Oct 2017 11:10:09 -0700
Message-ID: <20171030181009.18340-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48473 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbdJ3SKU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 14:10:20 -0400
Received: by mail-pf0-f193.google.com with SMTP id b79so11636056pfk.5
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 11:10:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
I defer tcf_chain_flush() to a workqueue, this causes a use-after-free
because qdisc is already destroyed after we queue this work.

The tcf_block_put_deferred() is no longer necessary after we get RTNL
for each tc filter destroy work, no others could jump in at this point.
Same for tcf_chain_hold(), we are fully serialized now.

This also reduces one indirection therefore makes the code more
readable. Note this brings back a rcu_barrier(), however comparing
to the code prior to commit 7aa0045dadb6 we still reduced one
rcu_barrier(). For net-next, we can consider to refcnt tcf block to
avoid it.

Fixes: 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 37 ++++++++-----------------------------
 1 file changed, 8 insertions(+), 29 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 231181c602ed..b2d310745487 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -280,8 +280,8 @@ static void tcf_block_put_final(struct work_struct *work)
 	struct tcf_block *block = container_of(work, struct tcf_block, work);
 	struct tcf_chain *chain, *tmp;
 
-	/* At this point, all the chains should have refcnt == 1. */
 	rtnl_lock();
+	/* Only chain 0 should be still here. */
 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 		tcf_chain_put(chain);
 	rtnl_unlock();
@@ -289,23 +289,17 @@ static void tcf_block_put_final(struct work_struct *work)
 }
 
 /* XXX: Standalone actions are not allowed to jump to any chain, and bound
- * actions should be all removed after flushing. However, filters are destroyed
- * in RCU callbacks, we have to hold the chains first, otherwise we would
- * always race with RCU callbacks on this list without proper locking.
+ * actions should be all removed after flushing. However, filters are now
+ * destroyed in tc filter workqueue with RTNL lock, they can not race here.
  */
-static void tcf_block_put_deferred(struct work_struct *work)
+void tcf_block_put(struct tcf_block *block)
 {
-	struct tcf_block *block = container_of(work, struct tcf_block, work);
-	struct tcf_chain *chain;
+	struct tcf_chain *chain, *tmp;
 
-	rtnl_lock();
-	/* Hold a refcnt for all chains, except 0, in case they are gone. */
-	list_for_each_entry(chain, &block->chain_list, list)
-		if (chain->index)
-			tcf_chain_hold(chain);
+	if (!block)
+		return;
 
-	/* No race on the list, because no chain could be destroyed. */
-	list_for_each_entry(chain, &block->chain_list, list)
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 		tcf_chain_flush(chain);
 
 	INIT_WORK(&block->work, tcf_block_put_final);
@@ -314,21 +308,6 @@ static void tcf_block_put_deferred(struct work_struct *work)
 	 */
 	rcu_barrier();
 	tcf_queue_work(&block->work);
-	rtnl_unlock();
-}
-
-void tcf_block_put(struct tcf_block *block)
-{
-	if (!block)
-		return;
-
-	INIT_WORK(&block->work, tcf_block_put_deferred);
-	/* Wait for existing RCU callbacks to cool down, make sure their works
-	 * have been queued before this. We can not flush pending works here
-	 * because we are holding the RTNL lock.
-	 */
-	rcu_barrier();
-	tcf_queue_work(&block->work);
 }
 EXPORT_SYMBOL(tcf_block_put);
 
-- 
2.13.0
