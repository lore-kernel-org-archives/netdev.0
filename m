From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/9] rhashtable: simplify rhashtable_remove()
Date: Fri, 30 Jan 2015 07:46:26 +0000
Message-ID: <1422603994-5836-2-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34093 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbbA3Hqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:42 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some duplicated code by moving the restart label up a few
lines. Also use rcu_access_pointer() for the pointer comparison
instead of rht_dereference_rcu().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 lib/rhashtable.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index aca6998..5f079f7 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -588,12 +588,12 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 
 	rcu_read_lock();
 	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
 	hash = head_hashfn(ht, tbl, obj);
 
 	lock = bucket_lock(tbl, hash);
 	spin_lock_bh(lock);
 
-restart:
 	pprev = &tbl->buckets[hash];
 	rht_for_each(he, tbl, hash) {
 		if (he != obj) {
@@ -613,14 +613,10 @@ restart:
 		return true;
 	}
 
-	if (tbl != rht_dereference_rcu(ht->future_tbl, ht)) {
+	if (tbl != rcu_access_pointer(ht->future_tbl)) {
 		spin_unlock_bh(lock);
 
 		tbl = rht_dereference_rcu(ht->future_tbl, ht);
-		hash = head_hashfn(ht, tbl, obj);
-
-		lock = bucket_lock(tbl, hash);
-		spin_lock_bh(lock);
 		goto restart;
 	}
 
-- 
2.1.0
