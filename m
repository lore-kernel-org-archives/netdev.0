From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Wed, 04 Feb 2015 07:33:22 +1100
Message-ID: <E1YIk9y-00062w-3E@gondolin.me.apana.org.au>
References: <20150203203213.GA23177@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57608 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161144AbbBCUd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 15:33:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current being_destroyed check in rhashtable_expand is not
enough since if we start a shrinking process after freeing all
elements in the table that's also going to crash.

This patch adds a being_destroyed check to the deferred worker
thread so that we bail out as soon as we take the lock.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index c41e210..904b419 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -487,6 +487,9 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
+	if (ht->being_destroyed)
+		goto unlock;
+
 	tbl = rht_dereference(ht->tbl, ht);
 
 	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
@@ -494,6 +497,7 @@ static void rht_deferred_worker(struct work_struct *work)
 	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
 		rhashtable_shrink(ht);
 
+unlock:
 	mutex_unlock(&ht->mutex);
 }
 
