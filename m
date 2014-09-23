From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] rhashtable: fix lockdep splat in rhashtable_destroy()
Date: Tue, 23 Sep 2014 11:24:46 +0200
Message-ID: <1411464288-18069-4-git-send-email-pablo@netfilter.org>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53467 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298AbaIWJXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 05:23:50 -0400
In-Reply-To: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for rht_dereference() from rhashtable_destroy() since the
existing callers don't hold the mutex when invoking this function
from:

1) Netlink, this is called in case of memory allocation errors in the
   initialization path, no nl_sk_hash_lock is held.
2) Netfilter, this is called from the rcu callback, no nfnl_lock is
   held either.

I think it's reasonable to assume that the caller has to make sure
that no hash resizing may happen before releasing the bucket array.
Therefore, the caller should be responsible for releasing this in a
safe way, document this to make people aware of it.

This resolves a rcu lockdep splat in nft_hash:

===============================
[ INFO: suspicious RCU usage. ]
3.16.0+ #178 Not tainted
-------------------------------
lib/rhashtable.c:596 suspicious rcu_dereference_protected() usage!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 1
1 lock held by ksoftirqd/2/18:
 #0:  (rcu_callback){......}, at: [<ffffffff810918fd>] rcu_process_callbacks+0x27e/0x4c7

stack backtrace:
CPU: 2 PID: 18 Comm: ksoftirqd/2 Not tainted 3.16.0+ #178
Hardware name: LENOVO 23259H1/23259H1, BIOS G2ET32WW (1.12 ) 05/30/2012
 0000000000000001 ffff88011706bb68 ffffffff8143debc 0000000000000000
 ffff880117062610 ffff88011706bb98 ffffffff81077515 ffff8800ca041a50
 0000000000000004 ffff8800ca386480 ffff8800ca041a00 ffff88011706bbb8
Call Trace:
 [<ffffffff8143debc>] dump_stack+0x4e/0x68
 [<ffffffff81077515>] lockdep_rcu_suspicious+0xfa/0x103
 [<ffffffff81228b1b>] rhashtable_destroy+0x46/0x52
 [<ffffffffa06f21a7>] nft_hash_destroy+0x73/0x82 [nft_hash]

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a2c7881..fc0dd8e 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -589,13 +589,13 @@ EXPORT_SYMBOL_GPL(rhashtable_init);
  * rhashtable_destroy - destroy hash table
  * @ht:		the hash table to destroy
  *
- * Frees the bucket array.
+ * Frees the bucket array. This function is not rcu safe, therefore the caller
+ * has to make sure that no resizing may happen by unpublishing the hashtable
+ * and waiting for the quiescent cycle before releasing the bucket array.
  */
 void rhashtable_destroy(const struct rhashtable *ht)
 {
-	const struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
-
-	bucket_table_free(tbl);
+	bucket_table_free(ht->tbl);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
 
-- 
1.7.10.4
