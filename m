From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Sat, 31 Jan 2015 20:36:38 +1100
Message-ID: <20150131093637.GA29106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57178 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbAaJgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 04:36:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current being_destroyed check in rhashtable_expand is not
enough since if we start a shrinking process after freeing all
elements in the table that's also going to crash.

This patch adds a being_destroyed check to the deferred worker
thread so that we bail out as soon as we take the lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 69a4eb0..4c3da1f 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -489,6 +489,9 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
+	if (ht->being_destroyed)
+		goto unlock;
+
 	tbl = rht_dereference(ht->tbl, ht);
 
 	list_for_each_entry(walker, &ht->walkers, list)
@@ -499,6 +502,7 @@ static void rht_deferred_worker(struct work_struct *work)
 	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
 		rhashtable_shrink(ht);
 
+unlock:
 	mutex_unlock(&ht->mutex);
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
