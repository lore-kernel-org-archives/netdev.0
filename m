From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: nft_hash: no need for rcu in the hash set destroy path
Date: Tue, 23 Sep 2014 11:24:44 +0200
Message-ID: <1411464288-18069-2-git-send-email-pablo@netfilter.org>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53443 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbaIWJXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 05:23:48 -0400
In-Reply-To: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sets are released from the rcu callback, after the rule is removed
from the chain list, which implies that nfnetlink cannot update the
hashes (thus, no resizing may occur) and no packets are walking on the
set anymore.

This resolves a lockdep splat in the nft_hash_destroy() path since the
nfnl mutex is not held there.

===============================
[ INFO: suspicious RCU usage. ]
3.16.0-rc2+ #168 Not tainted
-------------------------------
net/netfilter/nft_hash.c:362 suspicious rcu_dereference_protected() usage!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 1
1 lock held by ksoftirqd/0/3:
 #0:  (rcu_callback){......}, at: [<ffffffff81096393>] rcu_process_callbacks+0x27e/0x4c7

stack backtrace:
CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 3.16.0-rc2+ #168
Hardware name: LENOVO 23259H1/23259H1, BIOS G2ET32WW (1.12 ) 05/30/2012
 0000000000000001 ffff88011769bb98 ffffffff8142c922 0000000000000006
 ffff880117694090 ffff88011769bbc8 ffffffff8107c3ff ffff8800cba52400
 ffff8800c476bea8 ffff8800c476bea8 ffff8800cba52400 ffff88011769bc08
Call Trace:
 [<ffffffff8142c922>] dump_stack+0x4e/0x68
 [<ffffffff8107c3ff>] lockdep_rcu_suspicious+0xfa/0x103
 [<ffffffffa079931e>] nft_hash_destroy+0x50/0x137 [nft_hash]
 [<ffffffffa078cd57>] nft_set_destroy+0x11/0x2a [nf_tables]

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 net/netfilter/nft_hash.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 28fb8f3..8892b7b 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -180,15 +180,17 @@ static int nft_hash_init(const struct nft_set *set,
 static void nft_hash_destroy(const struct nft_set *set)
 {
 	const struct rhashtable *priv = nft_set_priv(set);
-	const struct bucket_table *tbl;
+	const struct bucket_table *tbl = priv->tbl;
 	struct nft_hash_elem *he, *next;
 	unsigned int i;
 
-	tbl = rht_dereference(priv->tbl, priv);
-	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(he, next, tbl->buckets[i], priv, node)
+	for (i = 0; i < tbl->size; i++) {
+		for (he = rht_entry(tbl->buckets[i], struct nft_hash_elem, node);
+		     he != NULL; he = next) {
+			next = rht_entry(he->node.next, struct nft_hash_elem, node);
 			nft_hash_elem_destroy(set, he);
-
+		}
+	}
 	rhashtable_destroy(priv);
 }
 
-- 
1.7.10.4
