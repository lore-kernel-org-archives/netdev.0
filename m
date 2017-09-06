From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix a memory leak of filter chain
Date: Tue,  5 Sep 2017 22:03:10 -0700
Message-ID: <20170906050310.26474-1-xiyou.wangcong@gmail.com>
Cc: jakub.kicinski@netronome.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36000 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdIFFDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 01:03:18 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so2974988pgt.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 22:03:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_chain_destroy() is called by tcf_block_put() and tcf_chain_put().
tcf_chain_put() is refcn'ed and paired with tcf_chain_get(),
but tcf_block_put() is not, it should be paired with tcf_block_get()
and we still need to decrease the refcnt. However, tcf_block_put()
is special, it stores the chains too, we have to detach them if
it is not the last user.

What's more, index 0 is not special at all, it should be treated
like other chains. This also makes the code more readable.

Fixes: 744a4cf63e52 ("net: sched: fix use after free when tcf_chain_destroy is called multiple times")
Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6c5ea84d2682..c6d25b29bcd4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -213,17 +213,17 @@ static void tcf_chain_flush(struct tcf_chain *chain)
 	}
 }
 
-static void tcf_chain_destroy(struct tcf_chain *chain)
+static void tcf_chain_detach(struct tcf_chain *chain)
 {
 	/* May be already removed from the list by the previous call. */
 	if (!list_empty(&chain->list))
 		list_del_init(&chain->list);
+}
 
-	/* There might still be a reference held when we got here from
-	 * tcf_block_put. Wait for the user to drop reference before free.
-	 */
-	if (!chain->refcnt)
-		kfree(chain);
+static void tcf_chain_destroy(struct tcf_chain *chain)
+{
+	tcf_chain_detach(chain);
+	kfree(chain);
 }
 
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
@@ -246,10 +246,7 @@ EXPORT_SYMBOL(tcf_chain_get);
 
 void tcf_chain_put(struct tcf_chain *chain)
 {
-	/* Destroy unused chain, with exception of chain 0, which is the
-	 * default one and has to be always present.
-	 */
-	if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
+	if (--chain->refcnt == 0)
 		tcf_chain_destroy(chain);
 }
 EXPORT_SYMBOL(tcf_chain_put);
@@ -296,8 +293,11 @@ void tcf_block_put(struct tcf_block *block)
 
 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
 		tcf_chain_flush(chain);
-		tcf_chain_destroy(chain);
+		tcf_chain_put(chain);
 	}
+	/* If tc actions still hold the chain, just detach it. */
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+		tcf_chain_detach(chain);
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
-- 
2.13.0
