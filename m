From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 3/3] net_sched: carefully handle tcf_block_put()
Date: Mon, 11 Sep 2017 16:33:32 -0700
Message-ID: <20170911233332.7594-4-xiyou.wangcong@gmail.com>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Cc: jiri@mellanox.com, jakub.kicinski@netronome.com, jhs@mojatatu.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37905 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdIKXdy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 19:33:54 -0400
Received: by mail-pg0-f67.google.com with SMTP id m30so361833pgn.5
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 16:33:54 -0700 (PDT)
In-Reply-To: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Jiri, there is still a race condition between
tcf_block_put() and tcf_chain_destroy() in a RCU callback. There
is no way to make it correct without proper locking or synchronization,
because both operate on a shared list.

Locking is hard, because the only lock we can pick here is a spinlock,
however, in tc_dump_tfilter() we iterate this list with a sleeping
function called (tcf_chain_dump()), which makes using a lock to protect
chain_list almost impossible.

Jiri suggested the idea of holding a refcnt before flushing, this works
because it guarantees us there would be no parallel tcf_chain_destroy()
during the loop, therefore the race condition is gone. But we have to
be very careful with proper synchronization with RCU callbacks.

Suggested-by: Jiri Pirko <jiri@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d29e79d98a69..0b2219adf520 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -275,15 +275,27 @@ void tcf_block_put(struct tcf_block *block)
 
 	/* XXX: Standalone actions are not allowed to jump to any chain, and
 	 * bound actions should be all removed after flushing. However,
-	 * filters are destroyed in RCU callbacks, we have to flush and wait
-	 * for them inside the loop, otherwise we race with RCU callbacks on
-	 * this list.
+	 * filters are destroyed in RCU callbacks, we have to hold the chains
+	 * first, otherwise we would always race with RCU callbacks on this list
+	 * without proper locking.
 	 */
-	list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
+
+	/* Wait for existing RCU callbacks to cool down. */
+	rcu_barrier();
+
+	/* Hold a refcnt for all chains, except 0, in case they are gone. */
+	list_for_each_entry(chain, &block->chain_list, list)
+		if (chain->index)
+			tcf_chain_hold(chain);
+
+	/* No race on the list, because no chain could be destroyed. */
+	list_for_each_entry(chain, &block->chain_list, list)
 		tcf_chain_flush(chain);
-		rcu_barrier();
-	}
 
+	/* Wait for RCU callbacks to release the reference count. */
+	rcu_barrier();
+
+	/* At this point, all the chains should have refcnt == 1. */
 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 		tcf_chain_put(chain);
 	kfree(block);
-- 
2.13.0
